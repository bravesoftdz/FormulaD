unit formulaDBrain;

interface
uses DSE_list, generics.collections, generics.defaults, system.classes, System.SysUtils, System.Types,Winapi.Windows,

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

  LastGear: ShortInt;

  ConfirmedSetupQ : Boolean;
  ConfirmedSetupR : Boolean;
  inGame: Boolean;
  constructor Create;
  destructor Destroy;override;

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

    Laps: Byte;

    lstCars: TObjectList<TCar>;
    lstCarsTmp: TObjectList<TCar>;
    lstCarsStartingGrid: TObjectList<TCar>;
    lstCarsPositions: TObjectList<TCar>;
    Circuit : TObjectList<TCell>;
    CircuitDescr: TCircuitDescr;


    lstLinkForwardDist1 : array[1..30] of TObjectList<TCell>;


    procedure SetCurrentCar ( aValue: Byte );
  constructor Create;
  destructor Destroy;override;
  procedure CreateRndStartingGrid;
    function FindStartingGrid ( Position : Byte ): TCell;
    function FindCell ( Guid : SmallInt ): TCell;
    function FindCellStartingGrid ( Position : Byte ): TCell;

  function FindCar ( Guid : Integer ): TCar;
  procedure SaveData ( CurMove: Integer ) ;

  procedure CalculateAllChance ( aCar : TCar; RollDice: string; var lstChanceCell: TObjectList<TChanceCell> );
  procedure GetAllChanceCells ( aCar : TCar;  DistanceMax: integer; var lstChanceCell: TObjectList<TChanceCell> );
  procedure GetLinkForward ( aCell: TCell; var lstLinkForward: TObjectList<TCell>);
  function IsThereACar ( aCell: TCell ): TCar;

  function RndGenerate( Upper: integer ): integer;
  function RndGenerate0( Upper: integer ): integer;
  function RndGenerateRange( Lower, Upper: integer ): integer;

  property CurrentCar : byte read fCurrentCar write SetCurrentCar;
end;
implementation
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
  for i := Low(lstLinkForwardDist1) to High(lstLinkForwardDist1) do begin
    lstLinkForwardDist1[i] := TObjectList<TCell>.Create ( true );
  end;

end;
destructor TFormulaDBrain.Destroy;
var
  i: Integer;
begin
  for i := Low(lstLinkForwardDist1) to High(lstLinkForwardDist1) do begin
    lstLinkForwardDist1[i].Free;  // non elimina le celle di circuit
  end;

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
var
  aCar : TCar;
begin
  fCurrentCar := aValue;
  aCar := FindCar( fCurrentCar );
  if aCar.AI then begin
//    AI_Think;
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
function TFormulaDBrain.IsThereACar ( aCell: TCell ): TCar;
var
  i: Integer;
begin
  for I := 0 to lstcars.Count -1 do begin
    if lstCars[i].Cell = aCell then begin
      result := lstCars[i];
    end;
  end;

end;
procedure TFormulaDBrain.CalculateAllChance ( aCar : TCar; RollDice: string; var lstChanceCell: TObjectList<TChanceCell> );
var
  i,B,L,R,Rmin,Rmax,pp: Integer;
  aPath : TObjectList<TCell>;
  PossiblePaths :TObjectList<TObjectList<TCell>>;
  TmplstChanceCell : TObjectList<TChanceCell>;
  aChanceCell  : TChanceCell;
  lstNextCells : TObjectList<TCell>;
  Base:Integer;
  aNewPath : TObjectList<TCell>;
function DuplicatePath ( aPath:TObjectList<TCell> ):TObjectList<TCell>;
var
  aNewPath : TObjectList<TCell>;
  i: Integer;
begin
  aNewPath := TObjectList<TCell>.Create(False);
  for I := 0 to aPath.Count -1 do begin
    aNewPath.Add( aPath[i] );
  end;
  Result := aNewPath;
end;
  label retry;
begin
  if RollDice = 'R12' then begin
    Rmax := 2;
  end
  else if RollDice = 'R24' then begin
    Rmax := 4;
  end;

  GetAllChanceCells ( aCar, Rmax, lstChanceCell );
  PossiblePaths := TObjectList<TObjectList<TCell>>.Create;
  TmplstChanceCell := TObjectList<TChanceCell>.Create ( false );
  lstNextCells := TObjectList<TCell>.Create ( false );


  Base := 1;
retry:

  for I := 0 to lstChanceCell.Count -1 do begin    // copia per delete successivi
    TmplstChanceCell.Add ( lstChanceCell[i]);
  end;
  
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
    //  FindNextCells ( PossiblePaths[i], Base+1, lstNextCells);  <-- ciclo sulla lstChanceCell dove distance = i+1  ( non cerca sulla tmp )
    // for pp  lstNextCells.count -1
        if Pp > PossiblePaths.Count then begin
          aNewPath := DuplicatePath ( PossiblePaths[i] );
          aNewPath.Add(lstNextCells[pp]);
          aNewPath.Add( lstNextCells[pp] );
        end
        else
          aPath.Add(lstNextCells[pp]);
    end;

//     FindNextCells (Base+1, lstNextCells);  <-- ciclo sulla lstChanceCell dove distance = i+1  ( non cerca sulla tmp )
// for pp  lstNextCells.count -1
      aPath := TObjectList<TCell>.Create(False);
      aPath.Add( TmplstChanceCell[0].Cell );
//    aPath.Add( lstNextCells[pp].Cell );
      inc (Base);
goto retry;
  end;

  TmplstChanceCell.Free;
  lstNextCells.Free;

  PossiblePaths.Free;

  for I := lstChanceCell.Count -1 downto 0 do begin
    if IsThereACar ( lstChanceCell[i].Cell ) <> nil then begin
  //    lstChanceCell.Delete(i);
    end;
  end;
  // lstChanceCell contiene tutte le possibili cell con Roll = aChanceCell.Roll a partire da 1 fino al massimo Roll
  { TODO : Qui analizzo i vari path per trovare distanze, corner, car , ostacoli ecc... }
  // PER IL MOMENTO TUTTE VANNO BENE
end;
procedure TFormulaDBrain.GetAllChanceCells ( aCar : TCar; DistanceMax: integer; var lstChanceCell: TObjectList<TChanceCell> );
var
  i,L,R,Rmax: Integer;
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
  GetLinkForward ( StartCell, lstLinkForwardDist1[1]);
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

//  lstLinkForwardDist1.Clear; // <-- distanza 1 di nuovo vuota
  for L := 0 to lstLinkForwardDist1[R-1].Count -1 do begin
    StartCell := lstLinkForwardDist1 [R-1] [L];
    GetLinkForward ( StartCell, lstLinkForwardDist1[R]);

    aChanceCell := TChanceCell.Create;
    aCell := FindCell(  lstLinkForwardDist1[R][L].Guid); //<--- link all'originale cell in Circuit
    aChanceCell.Cell := aCell;
    aChanceCell.Roll := R;
    aChanceCell.Distance := R;
    lstChanceCell.Add( aChanceCell);
  end;

  goto IncR;

MyExit:

  // lstChanceCell contiene tutte le possibili cell con Roll = aChanceCell.Roll

  //  SetLength(lstLinkForwardDist1,0);
end;
procedure TFormulaDBrain.GetLinkForward ( aCell: TCell; var lstLinkForward: TObjectList<TCell>);
var
  i: Integer;
  aCellLinked :TCell;
begin
  for I := 0 to aCell.LinkForward.Count -1 do begin
    aCellLinked :=  Findcell ( aCell.LinkForward.Items[i]);         // dalla cella alla linkedCell
    lstLinkForward.Add(aCellLinked);
  end;
end;

end.


