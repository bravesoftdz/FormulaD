unit formulaDBrain;

interface
uses DSE_list, generics.collections, generics.defaults, system.classes, System.SysUtils, System.Types,

  ZLIBEX,
  DSE_Theater, DSE_Random;

const StageSetupQ = 0;
const StageQualifications = 1;
const StageSetupRace = 2;
const StageRace = 3;

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
  CarAngle: SmallInt;
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
  Angle: SmallInt;
  FinishLine : Boolean;
  PixelX,PixelY : SmallInt;
  DistCorner : Byte;
  DistStraight : Byte;
  constructor Create;
  destructor Destroy;override;
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
  Path : TList<TPoint>;

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

    Qualifications: Byte;
    WeatherStart: Byte;
    Weather : Byte;
    Track : Byte; // 0 dry 1 wet
    Stage: Byte;
    CurrentCar: Byte;

    lstCars: TObjectList<TCar>;
    Circuit : TObjectList<TCell>;
    CircuitDescr: TCircuitDescr;
  constructor Create;
  destructor Destroy;override;
  procedure CreateRndStartingGrid;
    function FindStartingGrid ( Position : Byte ): TCell;
    function FindCell ( Guid : SmallInt ): TCell;

  function FindCar ( Guid : Integer ): TCar;
  procedure SaveData ( CurMove: Integer ) ;

  function RndGenerate( Upper: integer ): integer;
  function RndGenerate0( Upper: integer ): integer;
  function RndGenerateRange( Lower, Upper: integer ): integer;
end;
implementation
constructor TCar.Create;
begin
  Path := TList<TPoint>.Create;
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
begin
  Circuit := TObjectList<TCell>.Create (True);
  lstCars:= TObjectList<TCar>.Create(true);
  RandGen := TtdCombinedPRNG.Create(0, 0);
  MMbraindata:= TMemoryStream.Create;
  MMbraindataZIP:= TMemoryStream.Create ;

end;
destructor TFormulaDBrain.Destroy;
begin
  Circuit.Free;
  lstCars.Free;
  RandGen.Free;
  MMbraindata.Free;
  MMbraindataZIP.Free;

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
procedure TFormulaDBrain.SaveData ( CurMove: Integer ) ;
var
  ISMARK : array [0..1] of ansichar;
  i,p: integer;
  totCars,CarGuid, totPath: Byte;
  tmp: string;
  tmpStream, MM : TMemoryStream;
  PathX, PathY : Integer;
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
  MMbraindata.Write( @CurrentCar, SizeOf(Byte) );


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

    totPath := lstCars[i].Path.Count;
    MMbraindata.Write( @totPath, sizeof(Byte) );
    for p := 0 to totPath -1 do begin
      PathX := lstCars[i].Path[p].X;
      PathY := lstCars[i].Path[p].X;
      MMbraindata.Write( @PathX, sizeof(Integer) );
      MMbraindata.Write( @PathY, sizeof(Integer) );
    end;

  end;

  // note

  MMbraindata.Write( @ISMARK[0], 2 );

// if log   MMbraindata.SaveToFile( dir_log +  brainIds  + '\' + Format('%.*d',[3, incMove]) + '.IS'  );
end;


end.

