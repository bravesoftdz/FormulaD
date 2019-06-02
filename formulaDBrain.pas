unit formulaDBrain;

interface
uses DSE_list, generics.collections, generics.defaults, system.classes, System.SysUtils, System.Types, DSE_Theater, DSE_Random;

type TQualifications = ( QualLap , QualRnd  );
type TCircuitDescr = record
  Name : string;
  Corners: Byte;
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
  FinishLine : Boolean;
  PixelX,PixelY : SmallInt;
  DistCorner : Byte;
  DistStraight : Byte;
  constructor Create;
  destructor Destroy;override;
end;
type TCar = Class
  Guid : Integer;
  CliId : Integer;
  UserName: string;
  Car: Integer;            // il box sulla mappa sul quale mi devo fermare
  AI: Boolean;

  Cell :TCell;
  Box : Byte;
  SE_Sprite : SE_Sprite;


  Tire : ShortInt;
  Brakes: ShortInt;
  Gear: ShortInt;
  Body: ShortInt;
  Engine: ShortInt;
  Suspension: ShortInt;

  LastGear: ShortInt;

end;

type TFormulaDBrain = class
  private
  public
//    CarSetup : TCarSetup;
    RandGen: TtdBasePRNG;
    Qualifications: TQualifications;
    Wheater : Integer;
    lstCars: TObjectList<TCar>;
    Circuit : TObjectList<TCell>;
    CircuitDescr: TCircuitDescr;

  constructor Create;
  destructor Destroy;override;
  procedure CreateRndStartingGrid;
    function FindStartingGrid ( Position : Byte ): TCell;
    function FindCell ( Guid : SmallInt ): TCell;

  function FindCar ( Guid : Integer ): TCar;

  function RndGenerate( Upper: integer ): integer;
  function RndGenerate0( Upper: integer ): integer;
  function RndGenerateRange( Lower, Upper: integer ): integer;
end;
implementation
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

end;
destructor TFormulaDBrain.Destroy;
begin
  Circuit.Free;
  lstCars.Free;
  RandGen.Free;
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
end.

