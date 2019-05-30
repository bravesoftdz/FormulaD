unit formulaDBrain;

interface
uses DSE_list, generics.collections, generics.defaults, system.classes, System.SysUtils, System.Types, DSE_Theater;
type TCircuitDescr = record
  Corners: Byte;
  CarAngle: SmallInt;
end;
type TPlayer = Class
  CliId : Integer;
  UserName: string;
  Car: Byte;            // il box sulla mappa sul quale mi devo fermare

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
    lstPlayers: TObjectList<TPlayer>;
    EngineCars : SE_Engine;
  constructor Create;
  destructor Destroy;override;
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
end;
destructor TFormulaDBrain.Destroy;
begin
  lstPlayers.Free;
end;
end.

