unit formulaDBrain;

interface
uses DSE_list, generics.collections, generics.defaults, system.classes, System.SysUtils, System.Types, DSE_Theater, DSE_Random;

type TQualifications = ( QualLap , QualRnd  );
type TCircuitDescr = record
  Corners: Byte;
  CarAngle: SmallInt;
end;
type TPlayer = Class
  CliId : Integer;
  UserName: string;
  Car: Integer;            // il box sulla mappa sul quale mi devo fermare
  AI: Boolean;

  SE_Sprite : SE_Sprite;

  Tire : ShortInt;
  Brakes: ShortInt;
  Gear: ShortInt;
  Body: ShortInt;
  Engine: ShortInt;
  Suspension: ShortInt;

  LastGear: ShortInt;

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

type TFormulaDBrain = class
  private
  public
//    CarSetup : TCarSetup;
    RandGen: TtdBasePRNG;
    Qualifications: TQualifications;
    Wheater : Integer;
    lstPlayers: TObjectList<TPlayer>;
  constructor Create;
  destructor Destroy;override;
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
  lstPlayers:= TObjectList<TPlayer>.Create(true);
  RandGen := TtdCombinedPRNG.Create(0, 0);

end;
destructor TFormulaDBrain.Destroy;
begin
  lstPlayers.Free;
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

end.

