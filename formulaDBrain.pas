unit formulaDBrain;

interface
uses DSE_list, generics.collections, generics.defaults, system.classes, System.SysUtils, System.Types;
type TCell = Class
  public
  Guid : SmallInt;
  Lane : Byte;
  LinkForward : SE_IntegerList;
  Adjacent : SE_IntegerList;
//  Kind : LaneCorner
  PixelX,PixelY : Integer;
  Angle : SmallInt;
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

end.

