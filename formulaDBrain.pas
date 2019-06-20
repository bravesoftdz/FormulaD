unit formulaDBrain;

interface
uses DSE_list, generics.collections, generics.defaults, system.classes, System.SysUtils, System.Types,Winapi.Windows, Vcl.StdCtrls, StrUtils,

  ZLIBEX,
  DSE_Theater, DSE_Random;

const StageSetupQ = 0;
const StageQualifications = 1;
const StageSetupRace = 2;
const StageRace = 3;
const StagePitStop = 4;

const QualLap = 0;
const QualRnd = 1;

const WeatherHot = 0;
const WeatherSunny = 1;
const WeatherCloudy = 2;
const WeatherRain = 3;
const WeatherRnd = 4;

const TrackDry = 0;
const TrackWet = 1;

type TCircuitDescr = record
  Name : string[25];
  Corners: string[255];
end;
type TCell = Class
  public
  Guid : SmallInt;
  Lane : ShortInt; // -1 = box
  LinkForward : SE_IntegerList;
  Adjacent : SE_IntegerList;
  Corner : Byte;
  StartingGrid : Byte;
  Box : Byte;
  Angle: Single;
  FinishLine : Boolean;
  PixelX,PixelY : SmallInt;
  DistCorner : Byte;
  DistStraight : Byte;
  constructor Create;
  destructor Destroy;override;
end;
type TChanceCell = Class
  Cell : TCell;
  Roll : Integer;
  Distance : Integer;
  Risk : string;
end;
type TCar = Class
  Guid : Byte;
  CliId : Integer;
  UserName: string[25];
  CarColor: Byte;    // il colore e il box sulla mappa sul quale mi devo fermare
  AI: Boolean;

  Cell :TCell;
  CurrentLap: Byte;
  CurrentGear: ShortInt;
  NextCorner : Byte;
  Stops : ShortInt;

  Box : Byte;
  SE_Sprite : SE_Sprite;
  Path : SE_IntegerList;

  TiresType : Byte;
  Tires : ShortInt;
  Brakes: ShortInt;
  Gear: ShortInt;
  Body: ShortInt;
  Engine: ShortInt;
  Suspension: ShortInt;

  TiresMax : ShortInt;
  BrakesMax: ShortInt;
  GearMax: ShortInt;
  BodyMax: ShortInt;
  EngineMax: ShortInt;
  SuspensionMax: ShortInt;


  ConfirmedSetupQ : Boolean;
  ConfirmedSetupR : Boolean;
  inGame: Boolean;
  constructor Create;
  destructor Destroy;override;

end;
type TPossiblePath = class
  Path : TObjectList<TCell>;
  Finished : Boolean;
  ZigZagLane : array [0..1] of ShortInt;
  ZigZagTot : Byte;
  constructor Create();
  destructor Destroy; override;
end;

type TFormulaDBrain = class
  private
  public
//    CarSetup : TCarSetup;
    MMbraindata,MMbraindataZIP: TMemoryStream;
    RandGen: TtdBasePRNG;
    ServerIncMove : Integer;

    CarSetupPoints: Byte;
    Qualifications: Byte;
    WeatherStart: Byte;
    Weather : Byte;
    Track : Byte; // 0 dry 1 wet
    Stage: Byte;
    fCurrentCar: Byte;
    CurrentTCar : TCar;

    Laps: Byte;

    lstCars: TObjectList<TCar>;
    lstCarsTmp: TObjectList<TCar>;
    lstCarsStartingGrid: TObjectList<TCar>;
    lstCarsPositions: TObjectList<TCar>;
    Circuit : TObjectList<TCell>;
    CircuitDescr: TCircuitDescr;

    PossiblePaths : TObjectList<TPossiblePath>;

   // PossiblePaths : TObjectList<TObjectList<TCell>>;
    DebugComboBox: TComboBox;
    CurrentRoll: ShortInt;
    procedure SetCurrentCar ( aValue: Byte );
  constructor Create;
  destructor Destroy;override;
  procedure CreateRndStartingGrid;
    function FindStartingGrid ( Position : Byte ): TCell;
    function FindCell ( Guid : SmallInt ): TCell;
    function FindCellStartingGrid ( Position : Byte ): TCell;

  function FindCar ( Guid : Integer ): TCar;
  function GetCarAtCell ( aCell : Tcell ): TCar;

  procedure SaveData ( CurMove: Integer ) ;

  procedure CreatePossiblePath   ( aCar: TCar );
  procedure GetLinkForward ( aCell: TCell; IncludeCellWithCar: Boolean; var lstLinkForward: TObjectList<TCell>);
  function GetLinkForwardSameLane ( aCell: TCell ): TCell;
  procedure CalculateAllChance ( aCar : TCar; RollDice: string; MaxDistance: integer );
  function IsThereACar ( aCell: TCell ): TCar;
  function CheckZigZag (aCar: TCar; aPossiblePath :TPossiblePath ; aCell: TCell) : Boolean;
  function RndGenerate( Upper: integer ): integer;
  function RndGenerate0( Upper: integer ): integer;
  function RndGenerateRange( Lower, Upper: integer ): integer;
  function BrainInput ( InputCar: TCar; InputText : string ): string;
  property CurrentCar : byte read fCurrentCar write SetCurrentCar;
  procedure AI_Think;
    procedure AI_Think_Straight;
    procedure AI_Think_Corner;
    function AI_Roll_MaxGear: string;
end;
implementation
constructor TPossiblePath.Create;
begin
  Path := TObjectList<TCell>.Create(False);
  ZigZagLane [0] := -3;
  ZigZagLane [1] := -3;
  ZigZagTot:=0;
  Finished := False;

end;
destructor TPossiblePath.Destroy;
begin
  Path.Free;
  inherited;
end;
constructor TCar.Create;
begin
  Path := SE_IntegerList.Create;
end;
destructor TCar.Destroy;
begin
  Path.Free;
  inherited;
end;
constructor TCell.Create;
begin
  LinkForward := SE_IntegerList.Create;
  Adjacent := SE_IntegerList.Create;
end;
destructor TCell.Destroy;
begin
  LinkForward.Free;
  Adjacent.Free;
  inherited;
end;
constructor TFormulaDBrain.Create;
var
  i: Integer;
begin

  Circuit := TObjectList<TCell>.Create (True);
  lstCars:= TObjectList<TCar>.Create(true);
  lstCarsTmp:= TObjectList<TCar>.Create(false);
  lstCarsStartingGrid:= TObjectList<TCar>.Create(False);
  lstCarsPositions:= TObjectList<TCar>.Create(False);

  RandGen := TtdCombinedPRNG.Create(0, 0);
  MMbraindata:= TMemoryStream.Create;
  MMbraindataZIP:= TMemoryStream.Create ;
  PossiblePaths := TObjectList<TPossiblePath>.Create(True);

end;
destructor TFormulaDBrain.Destroy;
var
  i: Integer;
begin

  PossiblePaths.Free;

  Circuit.Free;
  lstCarsTmp.Free;
  lstCarsStartingGrid.Free;
  lstCarsPositions.Free;
  lstCars.Free;
  RandGen.Free;
  MMbraindata.Free;
  MMbraindataZIP.Free;

end;
procedure TFormulaDBrain.SetCurrentCar( aValue : Byte );
begin
  fCurrentCar := aValue;
  CurrentTCar := FindCar( fCurrentCar );
  if CurrentTCar.AI then begin
    AI_Think;
  end;

end;
function TFormulaDBrain.RndGenerate( Upper: integer ): integer;
begin
  Result := Trunc(RandGen.AsLimitedDouble (1, Upper + 1));
end;
function TFormulaDBrain.RndGenerate0( Upper: integer ): integer;
begin
  Result := Trunc(RandGen.AsLimitedDouble (0, Upper + 1));
end;
function TFormulaDBrain.RndGenerateRange( Lower, Upper: integer ): integer;
begin
  Result := Trunc(RandGen.AsLimitedDouble (Lower, Upper + 1));
end;
procedure TFormulaDBrain.CreateRndStartingGrid;
var
  i: Byte;
  aCell : TCell;
  ACar,atmpCar: TCar;
  tmpCars : TObjectList<TCar>;
  aRnd : Integer;

begin
  tmpCars := TObjectList<TCar>.Create(false);
  for I := 0 to lstCars.Count -1 do begin
    tmpCars.add ( lstCars[i] );
  end;

  for I := 0 to lstCars.Count -1 do begin
    aCell := FindStartingGrid ( i + 1 );
    aRnd := RndGenerate0(tmpCars.Count-1 );
    atmpCar := tmpCars [ aRnd ];
    aCar := FindCar ( atmpCar.guid );
    aCar.Cell := FindCell ( aCell.guid ); // devo passare il puntatore alla lista originale
    tmpCars.Delete(aRnd);
  end;
  tmpCars.Free;

end;
function TFormulaDBrain.FindStartingGrid ( Position : Byte ): TCell;
var
  i: Integer;
begin
  for I := 0 to Circuit.Count -1 do begin
    if Circuit[i].StartingGrid = Position then begin
      Result := Circuit[i];
      Exit;
    end;
  end;
end;
function TFormulaDBrain.FindCell ( Guid : SmallInt ): TCell;
var
  i: Integer;
begin
  for I := 0 to Circuit.Count -1 do begin
    if Circuit[i].Guid = Guid then begin
      Result := Circuit[i];
      Exit;
    end;
  end;
end;
function TFormulaDBrain.FindCar ( Guid : Integer ): TCar;
var
  i: Integer;
begin
  for I := 0 to lstCars.Count -1 do begin
    if lstCars[i].Guid = Guid then begin
      Result := lstCars[i];
      Exit;
    end;
  end;
end;
function TFormulaDBrain.FindCellStartingGrid ( Position : Byte ): TCell;
var
  i: integer;
begin
  for I := 0 to Circuit.Count -1 do begin
    if Circuit[i].StartingGrid = Position then begin
      Result := Circuit[i];
      Exit;
    end;

  end;

end;
function TFormulaDBrain.GetCarAtCell ( aCell : Tcell ): TCar;
var
  i: Integer;
begin
  for I := 0 to lstCars.Count -1 do begin
    if lstCars[i].Cell = aCell then begin
      Result := lstCars[i];
      Exit;
    end;
  end;
end;

procedure TFormulaDBrain.SaveData ( CurMove: Integer ) ;
var
  ISMARK : array [0..1] of ansichar;
  i,p: integer;
  totCars,CarGuid, totPath: Byte;
  tmp: string;
  tmpStream, MM : TMemoryStream;
  PathGuid : Integer;
  str : AnsiString;
  CompressedStream: TZCompressionStream;
  DeCompressedStream: TZDeCompressionStream;
  Dummy : SmallInt;
begin
  // il formato dei dati è proprietario. byte per byte salvo in memoria ciò che serve.
  // MMbrainData contiene lo streaming
  // 2 bytes che indicano l'offset dell'inizio di tsScript
  // variabili globali
  // lstcar.count
  // lista car
  // (l'animazione è il path della Car)
  // Info --> crash, consumo freni, gomme, eliminazione, cambio clima ecc.... e mappa dei debris
  Dummy:=0;
  ISMARK [0] := 'I';
  ISMARK [1] := 'S';
  MMbraindata.Clear;
  MMbraindataZIP.size := 0;

  MMbraindata.Write( @CircuitDescr.Name [0], length ( CircuitDescr.Name) +1 );      // +1 byte 0 indica lunghezza stringa
  MMbraindata.Write( @Qualifications, SizeOf(Byte) );
  MMbraindata.Write( @WeatherStart, SizeOf(Byte) );
  MMbraindata.Write( @Weather, SizeOf(Byte) );
  MMbraindata.Write( @Track, SizeOf(Byte) );
  MMbraindata.Write( @Stage, SizeOf(Byte) );
  MMbraindata.Write( @fCurrentCar, SizeOf(Byte) );
  MMbraindata.Write( @CurrentRoll, SizeOf(Byte) );

  MMbraindata.Write( @Laps, SizeOf(Byte) );

  totCars :=  lstCars.Count ;
  MMbraindata.Write( @totCars, sizeof(byte) );

  for i := 0 to lstCars.Count -1 do begin
    MMbraindata.Write( @lstCars[i].Guid, sizeof(Byte) );
    MMbraindata.Write( @lstCars[i].Username [0], length ( lstCars[i].Username) +1 );      // +1 byte 0 indica lunghezza stringa
    MMbraindata.Write( @lstCars[i].CarColor, sizeof(Byte) );  // il bmp
    MMbraindata.Write( @lstCars[i].Box, sizeof(Byte) );  // il box sulla mappa sul quale mi devo fermare

    if lstCars[i].Cell = nil then
      MMbraindata.Write( @Dummy, sizeof(SmallInt) )    // in fase di setup la cell non è assegnata
    else
    MMbraindata.Write( @lstCars[i].Cell.Guid, sizeof(SmallInt) );

    MMbraindata.Write( @lstCars[i].TiresType, sizeof(Byte) );
    MMbraindata.Write( @lstCars[i].Tires, sizeof(ShortInt) );
    MMbraindata.Write( @lstCars[i].Brakes, sizeof(ShortInt) );
    MMbraindata.Write( @lstCars[i].Gear, sizeof(ShortInt) );
    MMbraindata.Write( @lstCars[i].Body, sizeof(ShortInt) );
    MMbraindata.Write( @lstCars[i].Engine, sizeof(ShortInt) );
    MMbraindata.Write( @lstCars[i].Suspension, sizeof(ShortInt) );
    MMbraindata.Write( @lstCars[i].TiresMax, sizeof(ShortInt) );
    MMbraindata.Write( @lstCars[i].BrakesMax, sizeof(ShortInt) );
    MMbraindata.Write( @lstCars[i].GearMax, sizeof(ShortInt) );
    MMbraindata.Write( @lstCars[i].BodyMax, sizeof(ShortInt) );
    MMbraindata.Write( @lstCars[i].EngineMax, sizeof(ShortInt) );
    MMbraindata.Write( @lstCars[i].SuspensionMax, sizeof(ShortInt) );

    MMbraindata.Write( @lstCars[i].InGame, sizeof(Boolean) );

    totPath := lstCars[i].Path.Count;
    MMbraindata.Write( @totPath, sizeof(Byte) );
    for p := 0 to totPath -1 do begin
      PathGuid := lstCars[i].Path[p];
      MMbraindata.Write( @PathGuid, sizeof(Integer) );
    end;

  end;

  // note

  MMbraindata.Write( @ISMARK[0], 2 );

// if log   MMbraindata.SaveToFile( dir_log +  brainIds  + '\' + Format('%.*d',[3, incMove]) + '.IS'  );
end;
function TFormulaDBrain.CheckZigZag (aCar: TCar; aPossiblePath :TPossiblePath ; aCell: TCell) : Boolean;
var
  StartLane, CurrentLane : ShortInt;
  aCellStraight: TCell;
begin
  // Qui devo ancora aggiungere aCell al PossiblePath e valuto il zigzag che avviene solo in rettilineo . Nel caso di Box nessun checkZigZag
  //if aCell.Guid = 219 then asm int 3; end;

  Result := false;

  StartLane := aCar.Cell.Lane;
  if StartLane < 0 then Exit;   // Box

  // la current Lane dell'ultmo elemento del path
  CurrentLane := aPossiblePath.Path[aPossiblePath.Path.Count -1].Lane;
  if CurrentLane < 0 then Exit;  // Box
  if aCell.Lane < 0 then Exit;   // Box
  if CurrentLane = aCell.Lane then Exit; // stessa lane. nessun zigzag
  // qui siamo in rettilineo e c'è un cambio di lane
  // se c'è una car nella cella linkforward sulla stessa lane
  aCellStraight := GetLinkForwardSameLane ( aPossiblePath.Path[aPossiblePath.Path.Count -1] );
  if IsThereACar( aCellStraight ) = nil then begin // dritto non c'è nessuna car
    If aPossiblePath.ZigZagTot = 2 then begin
      aPossiblePath.ZigZagTot := 3;
      aPossiblePath.Finished := True; // e in seguito non aggiunge aCell.
      Result := True;
      Exit;
    end
    else If aPossiblePath.ZigZagTot = 1 then begin
      if ( (aPossiblePath.ZigZagLane[0] = aCell.lane)  or (aPossiblePath.ZigZagLane[0] = Startlane))
      or ( aCell.Lane = StartLane)
       then begin // torno su una precedente lane quindi non posso
        aPossiblePath.Finished := True; // e in seguito non aggiunge aCell.
        Result := True;
        Exit;
      end
      else begin
        aPossiblePath.ZigZagLane[1]:= aCell.Lane; // zigzagtot diventa 2
        aPossiblePath.ZigZagTot := 2;              // ma non finished
      end;
    end
    else If aPossiblePath.ZigZagTot = 0 then begin
      aPossiblePath.ZigZagLane[0]:= aCell.Lane;
      aPossiblePath.ZigZagTot := 1;
    end;

  end;
  // se dritto c'è una car non conta il zigzag

end;
function TFormulaDBrain.IsThereACar ( aCell: TCell ): TCar;
var
  i: Integer;
begin
  result := nil;
  for I := 0 to lstcars.Count -1 do begin
    if lstCars[i].Cell = aCell then begin
      result := lstCars[i];
      Exit;
    end;
  end;

end;
procedure TFormulaDBrain.CreatePossiblePath   ( aCar: TCar);
var
  StartCell: TCell;
  i: Integer;
  aPossiblePath : TPossiblePath;
  //aPath : TObjectList<Tcell>;
  lstTmpCells: TObjectList<TCell>;
begin
  lstTmpCells:= TObjectList<TCell>.Create(False);
  StartCell := aCar.Cell;
  GetLinkForward ( StartCell, false, lstTmpCells);
  for I := 0 to lstTmpCells.Count -1 do begin
    aPossiblePath := TPossiblePath.Create;
    aPossiblePath.Path.add ( aCar.Cell );
    PossiblePaths.Add(aPossiblePath);

    if not CheckZigZag ( aCar, aPossiblePath ,lstTmpCells[i]) then    //<-- può porre Finished = true
      aPossiblePath.Path.add ( lstTmpCells[i] );

  end;
  lstTmpCells.Free;
end;

procedure TFormulaDBrain.CalculateAllChance ( aCar : TCar; RollDice: string; MaxDistance: integer );
var
  i,k,Rmax,D: Integer;
  TmplstChanceCell : TObjectList<TChanceCell>;
  aChanceCell  : TChanceCell;
  lstNextCells,lstCellsTmp : TObjectList<TCell>;
  Base:Integer;
  aNewPossiblePath,CurrentPath : TPossiblePath;
  StartPossiblePathCount: Integer;
function DuplicatePossiblePath ( aPossiblePath:TPossiblePath  ): TPossiblePath;
var
  aNewPossiblePath : TPossiblePath;
  i: Integer;
begin
  aNewPossiblePath := TPossiblePath.Create;
  for I := 0 to aPossiblePath.Path.Count -1 do begin
    aNewPossiblePath.Path.Add( aPossiblePath.Path[i] );
    aNewPossiblePath.Finished := aPossiblePath.Finished;
    aNewPossiblePath.ZigZagTot := aPossiblePath.ZigZagTot;
    aNewPossiblePath.ZigZagLane[0] := aPossiblePath.ZigZagLane[0];
    aNewPossiblePath.ZigZagLane[1] := aPossiblePath.ZigZagLane[1];
  end;
  Result := aNewPossiblePath;
end;
label c0,c0b,c2;
begin

  if RollDice = 'R12' then begin
    Rmax := 2;
  end
  else if RollDice = 'R24' then begin
    Rmax := 4;
  end
  else if RollDice = 'R48' then begin
    Rmax := 8;
  end
  else if RollDice = 'R712' then begin
    Rmax := 12;
  end
  else if RollDice = 'R79' then begin
    Rmax := 9;
  end
  else if RollDice = 'R1012' then begin
    Rmax := 12;
  end
  else if RollDice = 'R1120' then begin
    Rmax := 20;
  end
  else if RollDice = 'R1115' then begin
    Rmax := 15;
  end
  else if RollDice = 'R1620' then begin
    Rmax := 20;
  end
  else if RollDice = 'R2130' then begin
    Rmax := 30;
  end;

  if Maxdistance <> 0 then begin
    Rmax := MaxDistance; // Override
  end;

  PossiblePaths.Clear;
  CreatePossiblePath   ( aCar );
  lstCellsTmp := TObjectList<TCell>.Create ( false );

  for D := 1 to rMax -1 do begin

    StartPossiblePathCount := PossiblePaths.Count;
    for I := StartPossiblePathCount -1 downto 0 do begin
  //    OutputDebugString( pchar(  IntToStr( PossiblePaths[i].Path.Items[PossiblePaths[i].Path.Count-1].Guid )));
      if PossiblePaths[i].Finished then continue;

     // if PossiblePaths[i].Path.Count = 2 then
//      if (PossiblePaths[i].Path[0].Guid = 525) and (PossiblePaths[i].Path[1].Guid = 219) then  asm int 3 ; end;


      GetLinkForward ( PossiblePaths[i].Path.Items[PossiblePaths[i].Path.Count-1], false, lstCellsTmp ); // dall'ultimo elemento, quindi ultima cella . lstcellstmp è sempre clear
      CurrentPath :=  PossiblePaths[i];
     // if lstCellsTmp.Count = 0 then asm int 3; end; // <-- DEBUG
      if lstCellsTmp[0].Corner = 0 then begin
        case lstCellsTmp.count  of   // ne trova per forza da 1 a 3
          1: begin
            if CheckZigZag ( aCar, CurrentPath , lstCellsTmp[0]) then Continue;  //<-- può porre Finished = true
            CurrentPath.Path.Add(lstCellsTmp[0]);   //<-- trova e aggiunge un livello successivo. tutte le cell sono linked almeno a 1 cella
          end;
          2: begin
            aNewPossiblePath := DuplicatePossiblePath ( CurrentPath );  //<-- aggiunge un nuovo Tpossiblepath privo dell'ultima cella trovata

            if CheckZigZag ( aCar, aNewPossiblePath ,lstCellsTmp[1]) then goto c0 ;  //<-- può porre Finished = true
            aNewPossiblePath.Path.Add( lstCellsTmp[1] );
            PossiblePaths.Add( aNewPossiblePath );

  c0:
            if CheckZigZag ( aCar, CurrentPath,lstCellsTmp[0]) then continue ;  //<-- può porre Finished = true
            CurrentPath.Path.Add(lstCellsTmp[0]);   //<-- infine trova e aggiunge un livello successivo. tutte le cell sono linked almeno a 1 cella
          end;
          3: begin  // non possono esostere celle con 4 linkedCell
            aNewPossiblePath := DuplicatePossiblePath ( CurrentPath );  //<-- aggiunge un nuovo path privo dell'ultima cella trovata
            if CheckZigZag ( aCar, aNewPossiblePath,lstCellsTmp[1]) then goto c2 ;  //<-- può porre Finished = true

            aNewPossiblePath.Path.Add( lstCellsTmp[1] );                 // aggiunge l'ultima cella trovata
            PossiblePaths.Add( aNewPossiblePath );                   // aggiunge il nuovo path alla lista dei path possibili


  c2:
            aNewPossiblePath := DuplicatePossiblePath (CurrentPath );  //<-- aggiunge un nuovo path privo dell'ultima cella trovata
            if CheckZigZag ( aCar, aNewPossiblePath,lstCellsTmp[2]) then goto c0b ;  //<-- può porre Finished = true

            aNewPossiblePath.Path.Add( lstCellsTmp[2] );                 // aggiunge l'ultima cella trovata
            PossiblePaths.Add( aNewPossiblePath );                   // aggiunge il nuovo path alla lista dei path possibili


  c0b:

            if CheckZigZag ( aCar, CurrentPath,lstCellsTmp[0]) then continue ;  //<-- può porre Finished = true
            CurrentPath.Path.Add(lstCellsTmp[0]);   //<-- infine trova e aggiunge un livello successivo. tutte le cell sono linked almeno a 1 cella
          end;
        end;

      end
      else begin  // in curva non si può zigzagare quindi si seguono per forza le frecce
        for k := 0 to lstCellsTmp.count -1 do begin
          aNewPossiblePath := DuplicatePossiblePath ( CurrentPath );  //<-- aggiunge un nuovo Tpossiblepath privo dell'ultima cella trovata
          aNewPossiblePath.Path.Add( lstCellsTmp[k] );
          PossiblePaths.Add( aNewPossiblePath );

        end;


      end;
    end;


  end;

  lstCellsTmp.Free;

  DebugComboBox.Clear;
  for I := 0 to PossiblePaths.Count -1  do begin  // tutti i path creati
    if  not PossiblePaths[i].Finished then
      DebugComboBox.AddItem( IntToStr(i), PossiblePaths[i].Path );
  end;

  if MaxDistance <> 0 then begin // seleziono solo i path con le celle finali a distanza MaxDistance
    for i := PossiblePaths.Count -1 downto 0 do begin
      if (PossiblePaths[i].Path.Count - (MaxDistance + 1)) <> 0  then begin // +1 perchè la cella di partenza è inclusa
        PossiblePaths.Delete(i);
      end;
    end;
    // rimangono solo i path con celle finali a distanza maxxdistance
  end;


end;
procedure TFormulaDBrain.GetLinkForward ( aCell: TCell; IncludeCellWithCar: Boolean; var lstLinkForward: TObjectList<TCell>);
var
  i,c: Integer;
  aCellLinked :TCell;
  label NextLF;
begin
  lstLinkForward.Clear;
  for I := 0 to aCell.LinkForward.Count -1 do begin
    aCellLinked :=  Findcell ( aCell.LinkForward.Items[i] );         // dalla cella alla linkedCell
    if not IncludeCellWithCar then begin
      for C := 0 to lstCars.Count -1 do begin
        if lstCars[C].Cell = aCellLinked then goto NextLF;
          Continue;
      end;
    end;

    lstLinkForward.Add(aCellLinked);
NextLF:
  end;
end;
function TFormulaDBrain.GetLinkForwardSameLane ( aCell: TCell ): TCell;
var
  i,c: Integer;
  aCellLinked :TCell;
begin
  for I := 0 to aCell.LinkForward.Count -1 do begin
    aCellLinked :=  Findcell ( aCell.LinkForward.Items[i] );         // dalla cella alla linkedCell
    if aCellLinked.Lane = aCell.Lane then begin
      Result := aCellLinked;
      Exit;
    end;

  end;

end;
function TFormulaDBrain.BrainInput ( InputCar: TCar;  InputText : string ): string;
var
  aCell : TCell;
  Ts : TStringList;
  I: Integer;
begin
  if CurrentTCar <> FindCar( InputCar.Guid ) then
    Exit;

  if InputText = 'R12' then begin
    if (CurrentTCar.CurrentGear = 0) or (CurrentTCar.CurrentGear = 1) or (CurrentTCar.CurrentGear = 2) or (CurrentTCar.CurrentGear = 3)   then begin
      CurrentRoll:= RndGenerate( 2 );
      CurrentTCar.CurrentGear := 1;
    end;
  end
  else if InputText = 'R24' then begin
    if (CurrentTCar.CurrentGear = 1) or (CurrentTCar.CurrentGear = 2) or (CurrentTCar.CurrentGear = 3) or (CurrentTCar.CurrentGear = 4)  then begin
      CurrentRoll:= RndGenerateRange ( 2,4 );
      CurrentTCar.CurrentGear := 2;
    end;
  end
  else if InputText = 'R48' then begin
    if (CurrentTCar.CurrentGear = 2) or (CurrentTCar.CurrentGear = 3) or (CurrentTCar.CurrentGear = 4)  or (CurrentTCar.CurrentGear = 5) then begin
      CurrentRoll:= RndGenerateRange ( 4,8 );
      CurrentTCar.CurrentGear := 3;
    end;
  end
  else if InputText = 'R712' then begin
    if (CurrentTCar.CurrentGear = 3) or (CurrentTCar.CurrentGear = 4)  or (CurrentTCar.CurrentGear = 5) or (CurrentTCar.CurrentGear = 6) then begin
      CurrentRoll:= RndGenerateRange ( 7,12 );
      CurrentTCar.CurrentGear := 4;
    end;
  end
  else if InputText = 'R1120' then begin
    if (CurrentTCar.CurrentGear = 4)  or (CurrentTCar.CurrentGear = 5) or (CurrentTCar.CurrentGear = 6) then begin
      CurrentRoll:= RndGenerateRange ( 11,20 );
      CurrentTCar.CurrentGear := 5;
    end;
  end
  else if InputText = 'R2130' then begin
    if (CurrentTCar.CurrentGear = 5) or (CurrentTCar.CurrentGear = 6) then begin
     { TODO : fare tutti i chack_stats }
      CurrentRoll:= RndGenerateRange ( 21,30 );
      CurrentTCar.CurrentGear := 6;
    end;
  end
  else if InputText = 'R79' then begin
    if (CurrentTCar.CurrentGear = 3) or (CurrentTCar.CurrentGear = 4)  or (CurrentTCar.CurrentGear = 5) or (CurrentTCar.CurrentGear = 6) then begin
      CurrentRoll:= RndGenerateRange ( 7,9 );
      CurrentTCar.CurrentGear := 4;
    end;
  end
  else if InputText = 'R1012' then begin
    if (CurrentTCar.CurrentGear = 3) or (CurrentTCar.CurrentGear = 4)  or (CurrentTCar.CurrentGear = 5) or (CurrentTCar.CurrentGear = 6) then begin
      CurrentRoll:= RndGenerateRange ( 10,12 );
      CurrentTCar.CurrentGear := 4;
    end;
  end
  else if InputText = 'R1115' then begin
    if (CurrentTCar.CurrentGear = 4)  or (CurrentTCar.CurrentGear = 5) or (CurrentTCar.CurrentGear = 6) then begin
      CurrentRoll:= RndGenerateRange ( 11,15 );
      CurrentTCar.CurrentGear := 5;
    end;
  end
  else if InputText = 'R1620' then begin
    if (CurrentTCar.CurrentGear = 4)  or (CurrentTCar.CurrentGear = 5) or (CurrentTCar.CurrentGear = 6) then begin
      CurrentRoll:= RndGenerateRange ( 16,20 );
      CurrentTCar.CurrentGear := 5;
    end;
  end
  else if leftstr(InputText,6) = 'SETCAR' then begin
    Ts := TStringList.Create;
    ts.CommaText := InputText;
    aCell := FindCell(  StrToInt( ts[1]) );
    // calcola tutti i path e vede se c'è' brain.CurrentRoll
    CalculateAllChance( CurrentTCar, '', CurrentRoll );
    if PossiblePaths.Count > 0 then begin
      Currentroll := 0;
      // setta la car .riempe il path della car
      CurrentTCar.Path.Clear;
      for I := 0 to PossiblePaths[0].Path.Count -1 do begin
        CurrentTCar.Path.Add( PossiblePaths[0].Path[i].Guid );
      end;

      CurrentTCar.Cell := FindCell( StrToInt( ts[1] )); // nel client l'animazione ha come elemento 0 la cell attuale prima del movimento
      // calcolare cordoli in curva
    end;
    Ts.Free;
  end;

end;
procedure TFormulaDBrain.AI_Think;
begin
  if ( (Stage = StageQualifications) or (Stage = StageRace)  ) and (CurrentTCar.AI) then begin
    if CurrentRoll = 0 then begin
      if CurrentTCar.CurrentGear = 0 then
        BrainInput( CurrentTCar, 'R12' )
      else begin
        if CurrentTCar.Cell.Corner = 0 then ai_think_straight
          else ai_think_Corner;

      end;
    end;
  end;

end;
procedure TFormulaDBrain.AI_Think_Straight;
var
  Roll: string;
begin

  if (CurrentTCar.CurrentLap = laps) and (CurrentTCar.NextCorner = 1) then begin // ultimo giro, sul rettilineo finale --> rollo al massimo
    Roll := AI_Roll_MaxGear;
    BrainInput( CurrentTCar, Roll );
    Exit;
  end;
  // verifico ultima curva: posso giocarmi tutte le stats
  // Quanto mi manca alla prossima curva. Adesso non mi interessa il numero di stop
  case CurrentTCar.Cell.DistCorner of
    30..255: begin
      Roll := AI_Roll_MaxGear;
      BrainInput( CurrentTCar, Roll );
      Exit;
    end;
  end;
// curva 1 stop --> risk gear+1 gear gear-1 gearspecial
// checkstats in base a giri/curve rimanenti if box possible
// curva 2 stop --> ragionamento più largo , preferisce scalare
// if box checkstats
  //      else if CurrentTCar.CurrentGear = 1 then begin
        //BrainInput( CurrentTCar, 'R12' )
        //BrainInput( CurrentTCar, 'SETCAR' )

end;
procedure TFormulaDBrain.AI_Think_Corner;
begin
//      else if CurrentTCar.CurrentGear = 1 then begin
        //BrainInput( CurrentTCar, 'R12' )
        //BrainInput( CurrentTCar, 'SETCAR' )

end;
function TFormulaDBrain.AI_Roll_MaxGear;
begin
  case CurrentTCar.CurrentGear of
    0: result := 'R12';
    1: result := 'R24';
    2: result := 'R48';
    3: result := 'R712';
    4: result := 'R1120';
    5: result := 'R2130';
    6: result := 'R2130';
  end;

end;

{
    lstLinkForwardDist1 : array[1..30] of TObjectList<TCell>;
    lstChanceCell: TObjectList<TChanceCell>;

//  for i := Low(lstLinkForwardDist1) to High(lstLinkForwardDist1) do begin
//    lstLinkForwardDist1[i] := TObjectList<TCell>.Create ( false );
//  end;

//  lstChanceCell:= TObjectList<TChanceCell>.Create (False);
//  for i := Low(lstLinkForwardDist1) to High(lstLinkForwardDist1) do begin
//    lstLinkForwardDist1[i].Free;  // non elimina le celle di circuit
//  end;

//  lstChanceCell.Free;
procedure TFormulaDBrain.FindNextCells ( aPath: TObjectList<TCell>; index: Integer; lstChanceCell: TObjectList<TChanceCell>; var lstNextCells:TObjectList<TCell> );
var
  i: Integer;
begin
//  <-- ciclo sulla lstChanceCell dove distance = index ( non cerca sulla tmp ) . lstChanceCell è globale
  lstNextCells.Clear;
  for I := 0 to lstChanceCell.count -1 do begin
    if lstChanceCell[i].Distance = Index then begin
      lstNextCells.Add( lstChanceCell[i].Cell );
    end;
  end;

end;
procedure TFormulaDBrain.GetAllChanceCells ( aCar : TCar; DistanceMax: integer; var lstChanceCell: TObjectList<TChanceCell> );
var
  i,L,LL,R,Rmax: Integer;
  StartCell, aCell : TCell;
  aChanceCell : TChanceCell;
  label incR, MyExit;
begin

  lstChanceCell.Clear;
  for i := Low(lstLinkForwardDist1) to High(lstLinkForwardDist1) do begin
    lstLinkForwardDist1[i].Clear;  // non elimina le celle di circuit
  end;


  Rmax := DistanceMax;
  R := 1;   // si parte sempre da 1
  StartCell := aCar.Cell;
  GetUniqueLinkForward ( StartCell, lstLinkForwardDist1[1]);
  for L := 0 to lstLinkForwardDist1[1].Count -1 do begin
    aChanceCell := TChanceCell.Create;
    aCell := FindCell(  lstLinkForwardDist1 [1] [L].Guid); //<--- link all'originale cell in Circuit
    aChanceCell.Cell := aCell;
    aChanceCell.Roll := 1;
    aChanceCell.Distance := 1;
    lstChanceCell.Add( aChanceCell);
  end;

//  outputdebugstring ( PChar(IntToStr(Circuit.count)));
//  lstLinkForwardDist1.Free;          // non elimina le celle di circuit
//  outputdebugstring ( PChar(IntToStr(Circuit.count)));
incR:
  inc (R);
  if R > rmax then
    goto MyExit;


  for L := 0 to lstLinkForwardDist1[R-1].Count -1 do begin
    StartCell := lstLinkForwardDist1 [R-1] [L];        // bug svuota la precedente , non la current
    lstLinkForwardDist1[R].Clear; //<-- va sempre svuotata per ogni cella nuova che si elabora
    GetUniqueLinkForward ( StartCell, lstLinkForwardDist1[R]);  //<-- lstLinkForwardDist1[R] viene riempita cone le prossime 2-3 celle. non aggiunge doppie

    for LL := 0 to lstLinkForwardDist1[R].Count -1 do begin  // queste 2-3 celle sono aggiunte a lstChanceCell
      aChanceCell := TChanceCell.Create;
      aCell := FindCell(  lstLinkForwardDist1[R][LL].Guid); //<--- link all'originale cell in Circuit
      aChanceCell.Cell := aCell;
      aChanceCell.Roll := R;
      aChanceCell.Distance := R;
      lstChanceCell.Add( aChanceCell);
    end;
  end;

  goto IncR;

MyExit:

  // lstChanceCell contiene tutte le possibili cell con Roll = aChanceCell.Roll

  //  SetLength(lstLinkForwardDist1,0);
end;

procedure TFormulaDBrain.GetUniqueLinkForward ( aCell: TCell; var lstLinkForward: TObjectList<TCell>);
var
  i: Integer;
  aCellLinked :TCell;
  function InlstLinkForward ( aCellGuid : Integer): boolean;
  var
    ilst: Integer;
  begin
    Result := False;
    for ilst := 0 to lstLinkForward.Count -1 do begin
      if lstLinkForward[ilst].Guid = aCellGuid then begin
        Result := True;
        Exit;
      end;

    end;

  end;
begin

  for I := 0 to aCell.LinkForward.Count -1 do begin
    aCellLinked :=  Findcell ( aCell.LinkForward.Items[i]);         // dalla cella alla linkedCell

    if not InlstLinkForward ( aCellLinked.Guid ) then
      lstLinkForward.Add(aCellLinked);
  end;
end;


  GetAllChanceCells ( aCar, Rmax, lstChanceCell );
  TmplstChanceCell := TObjectList<TChanceCell>.Create ( false );
  lstNextCells := TObjectList<TCell>.Create ( false );


  Base := 1;
retry:

  for I := 0 to lstChanceCell.Count -1 do begin    // copia per delete successivi
    TmplstChanceCell.Add ( lstChanceCell[i]);
  end;

  // lstChanceCell contiene tutte le possibili cell con Roll = aChanceCell.Roll a partire da 1 fino al massimo Roll
  TmplstChanceCell.sort(TComparer<TChanceCell>.Construct(
    function (const L, R: TChanceCell): integer
    begin
      Result := L.Distance - R.Distance;
    end
     ));

  for I := TmplstChanceCell.Count -1 downto 0 do begin
    if TmplstChanceCell[i].Distance > Base then
    TmplstChanceCell.Delete(i);
  end;

  if TmplstChanceCell.Count > 0 then begin
    for I := 0 to TmplstChanceCell.Count -1 do begin  // creo i path iniziali (massimo 3)
        aPath := TObjectList<TCell>.Create(False);
        aPath.Add(TmplstChanceCell[i].cell);
        PossiblePaths.Add(aPath);
    end;

    for I := PossiblePaths.Count -1 downto 0 do begin  // tutti i path già creati. downto perchè il count incrementa con duplicatePath
//    Qui analizzo i vari path per trovare distanze, corner, car , ostacoli ecc...
      FindNextCells ( PossiblePaths[i], Base+1, lstChanceCell, lstNextCells);// <-- ciclo sulla lstChanceCell dove distance = i+1  ( non cerca sulla tmp )
      for pp := 0 to lstNextCells.count -1 do begin
        if Pp > PossiblePaths.Count then begin
          aNewPath := DuplicatePath ( PossiblePaths[i] );  //<-- aggiunge un nuovo path
          aNewPath.Add( lstNextCells[pp] );
        end
        else
          PossiblePaths[i].Add(lstNextCells[pp]);   //<-- trova un livello successivo
      end;
    end;

      inc (Base);
goto retry;
  end;

  TmplstChanceCell.Free;
  lstNextCells.Free;

  for I := 0 to PossiblePaths.Count -1  do begin  // tutti i path creati
    DebugComboBox.AddItem( IntToStr(i), PossiblePaths[i] );
  end;

}
end.


