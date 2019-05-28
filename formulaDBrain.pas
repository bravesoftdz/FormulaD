unit formulaDBrain;

interface
uses DSE_list, generics.collections, generics.defaults, system.classes, System.SysUtils, System.Types, DSE_Theater;
type TCircuitDescr = record
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
  Tire : ShortInt;
  SE_Sprite : SE_Sprite;

End;

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

end.

