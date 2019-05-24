unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Generics.Defaults, System.Generics.Collections,

  DSE_list, FormulaDBrain, DSE_theater, DSE_Bitmap, Vcl.ExtCtrls, Vcl.StdCtrls;

type TMode = ( modeAddCell{C}, modeLinkForward{L}, modeAdjacent{A}, modeMoveCell{M}, modeSelectCell{S}, modePanZoom{Z} ) ;
type
  TForm1 = class(TForm)
    SE_Theater1: SE_Theater;
    Panel1: TPanel;
    SE_Engine1: SE_Engine;
    Button1: TButton;
    SE_Engine2: SE_Engine;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SE_Theater1TheaterMouseDown(Sender: TObject; VisibleX, VisibleY, VirtualX, VirtualY: Integer; Button: TMouseButton;
      Shift: TShiftState);
    procedure Button1Click(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure SE_Theater1TheaterMouseMove(Sender: TObject; VisibleX, VisibleY, VirtualX, VirtualY: Integer; Shift: TShiftState);
    procedure SE_Theater1TheaterMouseUp(Sender: TObject; VisibleX, VisibleY, VirtualX, VirtualY: Integer; Button: TMouseButton;
      Shift: TShiftState);
    procedure SE_Theater1SpriteMouseDown(Sender: TObject; lstSprite: TObjectList<DSE_theater.SE_Sprite>; Button: TMouseButton;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    function GetCell ( Guid : SmallInt ) : TCell;
    procedure DeleteCellCircuit ( aCell : TCell ); overload;
    procedure DeleteCellCircuit ( aSprite : SE_Sprite ); overload;
    procedure SelectCell ( aSprite : SE_Sprite );
    procedure ShowLinkForward ( MainSprite : SE_Sprite );
    procedure ShowAdjacent ( MainSprite : SE_Sprite );
    procedure AddLinkForward ( MainSprite,aSprite : SE_Sprite );
    procedure removeLinkForward ( MainSprite,aSprite : SE_Sprite );
    procedure AddAdjacent ( MainSprite,aSprite : SE_Sprite );
    procedure RemoveAdjacent ( MainSprite,aSprite : SE_Sprite );
    procedure ResetSpriteCells;
  end;

var
  Form1: TForm1;
  Circuit : TObjectList<TCell>;
  incGuid : SmallInt;
  mode  : TMode;
  SelectedCell : SE_Sprite;
  DeletedCell: Boolean;
  ClickedCell: Boolean;
implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin

 // mm.write @Circuit[0].Guid
 // @Circuit[0].Lane
 // mm.savetofile
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  aCell : TCell;
  aSprite : SE_Sprite;
begin

  Circuit := TObjectList<TCell>.Create(True);

  aSprite := SE_Sprite.Create ('..\client\bmp\circuits\barcelona.bmp','circuit',1,1,1000,0,0,false );

  SE_Theater1.VirtualWidth := aSprite.BMP.Width;
  SE_Theater1.VirtualHeight := aSprite.BMP.Height;

  SE_Engine1.AddSprite( aSprite );
  aSprite.Position := Point (  SE_Theater1.VirtualWidth div 2 , SE_Theater1.Virtualheight div 2  );

  Mode := modePanZoom;
  SE_Theater1.Active := True;
  incGuid := 0;

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Circuit.Free;
end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
  SE_Theater1.MousePan := false;
  SE_Theater1.MouseWheelZoom := False;

  if UpperCase(Key) = 'C' then
    Mode := modeAddCell
    else if UpperCase(Key) = 'L' then
     begin
      Mode := modeLinkForward;
        if SelectedCell <> nil then begin
          showLinkForward ( SelectedCell );
        end;
     end
      else if UpperCase(Key) = 'A' then begin
        Mode := modeAdjacent;
        if SelectedCell <> nil then begin
          showAdjacent ( SelectedCell );
        end;
      end
        else if UpperCase(Key) = 'M' then
          Mode := modeMoveCell
          else if UpperCase(Key) = 'S' then
            Mode := modeSelectCell
          else if UpperCase(Key) = 'Z' then begin
            Mode := modePanZoom;
            SE_Theater1.MousePan := True;
            SE_Theater1.MouseWheelZoom := True;
          end;
end;

procedure TForm1.SE_Theater1SpriteMouseDown(Sender: TObject; lstSprite: TObjectList<DSE_theater.SE_Sprite>; Button: TMouseButton;  Shift: TShiftState);
var
  aCell: TCell;
begin
  if mode = modeSelectCell then begin
    ClickedCell := True;
    case Button of
      mbLeft: begin
        SelectCell ( lstSprite[0] );
      end;
      mbRight: begin
        DeleteCellCircuit ( lstSprite[0] );
      end;
    end;

  end
  else if mode = modeAddCell then begin
    ClickedCell := True;
    case Button of
      mbRight: begin
        DeleteCellCircuit ( lstSprite[0] );
      end;
    end;

  end
  else if mode = modeLinkForward then begin
    ClickedCell := True;
    case Button of
      mbLeft: begin
        if SelectedCell <> nil then AddLinkForward ( SelectedCell, lstSprite[0] );
      end;
      mbRight: begin
        if SelectedCell <> nil then RemoveLinkForward ( SelectedCell, lstSprite[0] );
      end;
    end;

  end
  else if mode = modeAdjacent then begin
    ClickedCell := True;
    case Button of
      mbLeft: begin
        if SelectedCell <> nil then AddAdjacent ( SelectedCell, lstSprite[0] );
      end;
      mbRight: begin
        if SelectedCell <> nil then RemoveAdjacent ( SelectedCell, lstSprite[0] );
      end;
    end;

  end;

end;

procedure TForm1.SE_Theater1TheaterMouseDown(Sender: TObject; VisibleX, VisibleY, VirtualX, VirtualY: Integer; Button: TMouseButton; Shift: TShiftState);
var
  aCell : TCell;
  aBmp: SE_Bitmap;
  aSprite : SE_Sprite;
begin

  if DeletedCell or ClickedCell then begin
    DeletedCell := False;
    ClickedCell := False;
    Exit;
  end;

  if mode = modeAddCell then begin

    // creo un piccolo sprite circle
    if Button = mbleft then begin

      aCell := TCell.Create;
      aCell.PixelX := VirtualX;
      aCell.PixelY := VirtualY;
      aCell.Lane := 0;
      aCell.Guid := incGuid;

      Circuit.Add(aCell);


      aBmp:= Se_bitmap.Create (20,20);
      aBmp.Bitmap.Canvas.Brush.color := clGray;
      aBmp.Bitmap.Canvas.Ellipse(2,2,16,16);

      aSprite := SE_Sprite.Create (aBmp.bitmap, IntToStr(incGuid) ,1,1,1000,0,0,true );
      inc ( incGuid );
      SE_Engine2.AddSprite( aSprite );
      aSprite.Position := Point (  VirtualX , VirtualY  );
      SelectCell ( aSprite );
      aBmp.free;
    end;
  end;


end;

procedure TForm1.SE_Theater1TheaterMouseMove(Sender: TObject; VisibleX, VisibleY, VirtualX, VirtualY: Integer; Shift: TShiftState);
begin
  if (mode = modeMoveCell) and (SelectedCell <> nil) then
    SelectedCell.Position := Point (VirtualX, VirtualY);
end;

procedure TForm1.SE_Theater1TheaterMouseUp(Sender: TObject; VisibleX, VisibleY, VirtualX, VirtualY: Integer; Button: TMouseButton;
  Shift: TShiftState);
begin
  if (mode = modeMoveCell) and (SelectedCell <> nil) then begin
    // salvo le nuove coordinate in pixel
    SelectedCell := nil;
  end;

end;
function TForm1.GetCell ( Guid : SmallInt ) : TCell;
var
  i: Integer;
begin
  Result := nil;
  for i := Circuit.Count -1 downto 0 do begin
    if Circuit[i].Guid = Guid then begin
      Result := Circuit[i];
      Exit;
    end;
  end;

end;
procedure TForm1.DeleteCellCircuit ( aCell : Tcell );
var
  i: Integer;
begin
  for i := Circuit.Count -1 downto 0 do begin
    if Circuit[i].Guid = aCell.Guid then begin
      Circuit.Delete(i);
      Exit;
    end;
  end;

end;
procedure TForm1.DeleteCellCircuit ( aSprite : SE_Sprite );
var
  i: Integer;
begin
  aSprite.Dead := True;
//  SelectedCell := nil;
  DeletedCell := True;
  for i := Circuit.Count -1 downto 0 do begin
    if Circuit[i].Guid =  StrToInt(aSprite.Guid) then begin
      Circuit.Delete(i);
      Exit;
    end;
  end;

end;
procedure TForm1.SelectCell ( aSprite : SE_Sprite );
var
  i: Integer;
begin
  // reset di tutti gli sprite Cell

  for I := 0 to SE_Engine2.SpriteCount -1 do begin
    SE_Engine2.Sprites[i].bmp.Bitmap.Canvas.Brush.color := clGray;
    SE_Engine2.Sprites[i].bmp.Bitmap.Canvas.Ellipse(2,2,16,16);
  end;

  if SelectedCell <> nil then begin
    SelectedCell.Bmp.Bitmap.Canvas.Brush.color := clGray;
    SelectedCell.Bmp.Bitmap.Canvas.Ellipse(2,2,16,16);
  end;

  SelectedCell := aSprite;
  aSprite.Bmp.Bitmap.Canvas.Brush.color := clRed;
  aSprite.Bmp.Bitmap.Canvas.Ellipse(2,2,16,16);

  if mode = modeAdjacent then begin
    // coloro adiacenti
    ShowAdjacent ( aSprite );
  end
  else if mode = modeLinkForward then begin
    // coloro Linkforward
    ShowLinkForward ( aSprite );
  end;


end;

procedure TForm1.ShowLinkForward ( MainSprite: SE_Sprite );
var
  i: Integer;
  aCell, aCellLinked :TCell;
  LinkedSprite: SE_Sprite;
begin
  ResetSpriteCells;

  aCell := GetCell ( StrToInt (MainSprite.Guid ) );                   // dallo sprite alla cella
  for I := 0 to aCell.LinkForward.Count -1 do begin
    aCellLinked :=  GetCell( aCell.LinkForward.Items[i]);         // dalla cella alla linkedCell
    LinkedSprite := SE_Engine2.FindSprite( IntTostr (aCellLinked.guid) );    // dalla linkedCell allo sprite della linked
    LinkedSprite.bmp.Bitmap.Canvas.Brush.color := clGreen;
    LinkedSprite.bmp.Bitmap.Canvas.Ellipse(2,2,16,16);
  end;
end;
procedure TForm1.ShowAdjacent ( MainSprite: SE_Sprite );
var
  i: Integer;
  aCell, aCellAdjacent :TCell;
  AdjacentSprite: SE_Sprite;
begin
  ResetSpriteCells;

  aCell := GetCell ( StrToInt (MainSprite.Guid) );                   // dallo sprite alla cella
  for I := 0 to aCell.Adjacent.Count -1 do begin
    aCellAdjacent :=  GetCell( aCell.Adjacent.Items[i]);         // dalla cella alla AdjacentCell
    AdjacentSprite := SE_Engine2.FindSprite( IntTostr(aCellAdjacent.guid ));    // dalla linkedCell allo sprite della AdjacentCell
    AdjacentSprite.bmp.Bitmap.Canvas.Brush.color := clYellow;
    AdjacentSprite.bmp.Bitmap.Canvas.Ellipse(2,2,16,16);
  end;
end;
procedure TForm1.AddLinkForward ( MainSprite, aSprite : SE_Sprite );
var
  i: Integer;
  aCell, aCellLinked :TCell;
  LinkedSprite: SE_Sprite;
begin
  aCell := GetCell ( StrToInt (MainSprite.Guid) );                   // dallo sprite alla cella
  aCell.LinkForward.Add( StrToInt (aSprite.Guid) );
  aSprite.bmp.Bitmap.Canvas.Brush.color := clGreen;
  aSprite.bmp.Bitmap.Canvas.Ellipse(2,2,16,16);

end;
procedure TForm1.AddAdjacent ( MainSprite, aSprite : SE_Sprite );
var
  i: Integer;
  aCell  :TCell;
begin
  aCell := GetCell ( StrToInt (MainSprite.Guid) );                   // dallo sprite alla cella
  aCell.Adjacent.Add( StrToInt (aSprite.Guid) );
  aSprite.bmp.Bitmap.Canvas.Brush.color := clYellow;
  aSprite.bmp.Bitmap.Canvas.Ellipse(2,2,16,16);

end;
procedure TForm1.RemoveLinkForward ( MainSprite, aSprite : SE_Sprite );
var
  L: Integer;
  aCell :TCell;
begin
  aCell := GetCell ( StrToInt (MainSprite.Guid) );                   // dallo sprite alla cella

  for L := aCell.LinkForward.Count -1 downto 0 do begin
    if aCell.LinkForward.Items[L] = StrToInt(aSprite.Guid) then begin
      aCell.LinkForward.Delete(L);
      aSprite.bmp.Bitmap.Canvas.Brush.color := clGray; // torna normale.
      aSprite.bmp.Bitmap.Canvas.Ellipse(2,2,16,16);
    end;
  end;


end;
procedure TForm1.RemoveAdjacent ( MainSprite, aSprite : SE_Sprite );
var
  L: Integer;
  aCell :TCell;
begin

  aCell := GetCell ( StrToInt (MainSprite.Guid) );                   // dallo sprite alla cella

  for L := aCell.Adjacent.Count -1 downto 0 do begin
    if aCell.Adjacent.Items[L] = StrToInt(aSprite.Guid) then begin
      aCell.Adjacent.Delete(L);
      aSprite.bmp.Bitmap.Canvas.Brush.color := clGray; // torna normale.
      aSprite.bmp.Bitmap.Canvas.Ellipse(2,2,16,16);
    end;
  end;


end;
procedure TForm1.ResetSpriteCells;
var
  i: Integer;
begin
  for I := 0 to SE_Engine2.SpriteCount -1 do begin
    SE_Engine2.Sprites[i].bmp.Bitmap.Canvas.Brush.color := clGray; // torna normale.
    SE_Engine2.Sprites[i].bmp.Bitmap.Canvas.Ellipse(2,2,16,16);
  end;

  if (SelectedCell <> nil) then begin
    SelectedCell.Bmp.Bitmap.Canvas.Brush.color := clRed;
    SelectedCell.Bmp.Bitmap.Canvas.Ellipse(2,2,16,16);
  end;

end;


end.
