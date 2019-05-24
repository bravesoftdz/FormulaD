unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Generics.Defaults, System.Generics.Collections,

  DSE_list, FormulaDBrain, DSE_theater, DSE_Bitmap, Vcl.ExtCtrls, Vcl.StdCtrls, CnSpin;

type TMode = ( modeAddCell{C}, modeLinkForward{L}, modeAdjacent{A}, modeMoveCell{M}, modeSelectCell{S}, modePanZoom{Z}, modeCorner{K} ) ;
type
  TForm1 = class(TForm)
    SE_Theater1: SE_Theater;
    Panel1: TPanel;
    SE_Engine1: SE_Engine;
    SE_Engine2: SE_Engine;
    CnSpinEdit1: TCnSpinEdit;
    Label1: TLabel;
    SE_Engine3: SE_Engine;
    SE_Engine4: SE_Engine;
    Panel2: TPanel;
    Button1: TButton;
    Label2: TLabel;
    Label3: TLabel;
    CnSpinEdit2: TCnSpinEdit;
    CnSpinEdit3: TCnSpinEdit;
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
    fmode : TMode;
    procedure SetMode ( aMode : Tmode );
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
    procedure ShowCorners;
    property Mode :Tmode read fmode write SetMode;
  end;

var
  Form1: TForm1;
  Circuit : TObjectList<TCell>;
  incGuid : SmallInt;
  SelectedCell : SE_Sprite;
  DeletedCell: Boolean;
  ClickedCell: Boolean;
  mm : TMemoryStream;
implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  ISMARK : array [0..1] of ansichar;
  i,L,a,count: Integer;
  dummy : Word;
  TotCells, TotLinkForward, TotAdjacent, tmpb: Byte;
begin
  ISMARK [0] := 'I';
  ISMARK [1] := 'S';
  mm.Clear;
  { TODO : lo start }
  mm.Write( @dummy , SizeOf(word) );    // reserved: indica il byte dove comincia la descrizione delle curve, lo start, la griglia etc... ( incCorner, Stop )

  TotCells := Circuit.Count;
  mm.Write( @TotCells, sizeof(SmallInt) );
  for I := Circuit.Count -1 Downto 0 do begin
    mm.Write( @Circuit[i].Guid , SizeOf(SmallInt));
    mm.Write( @Circuit[i].Lane , SizeOf(ShortInt));
    mm.Write( @Circuit[i].Corner , SizeOf(Byte));
    mm.Write( @Circuit[i].PixelX , SizeOf(SmallInt));
    mm.Write( @Circuit[i].PixelY , SizeOf(SmallInt));

    TotLinkForward := Circuit[i].LinkForward.Count;
    mm.Write( @TotLinkForward, sizeof(byte) );
    for L := Circuit[i].LinkForward.Count -1 Downto 0 do begin
      tmpb := Circuit[i].LinkForward.Items[L];
      mm.Write( @tmpb, sizeof(byte) );
    end;

    TotAdjacent := Circuit[i].Adjacent.Count;
    mm.Write( @TotAdjacent, sizeof(byte) );
    for a := Circuit[i].Adjacent.Count -1 Downto 0 do begin
      tmpb := Circuit[i].Adjacent.Items[a];
      mm.Write( @tmpb, sizeof(byte) );
    end;

  end;


{  Dummy := mm.Position ;

  mm.Write( @LentsScript, sizeof(word) );  gestione corner
  mm.Position  := 0; // la prima word indica dove comincia la descrizione delle curve
  mm.Write( @Dummy, sizeof(word) ); // setto nella integer riservato dove comincia la descrizione delle curve

  mm.Position := mm.size;  }
  mm.Write( @ISMARK[0], 2 );
  mm.SaveToFile( '..\server\circuits\barcelona.fd' );

end;

procedure TForm1.SetMode ( aMode : Tmode );
var
  aBmp: Se_bitmap;
  aSprite : SE_Sprite;
  aColor : TColor;
  aText : string;
  w: Integer;
begin
  fmode := aMode;
  case aMode of
    modeAddCell: begin
                  Panel1.Visible := True;
                  Panel2.Visible := false;
                  CnSpinEdit1.Enabled := true;
                  aColor := clSilver;
                  aText := 'Add Cell';
                 end;
    modeLinkForward:begin
                  Panel1.Visible := False;
                  Panel2.Visible := false;
                  if SelectedCell <> nil then begin
                    showLinkForward ( SelectedCell );
                  end;
                  aColor := clGreen;
                  aText := 'Show LinkForward';
                 end;
    modeAdjacent: begin
                  Panel1.Visible := False;
                  Panel2.Visible := false;
                  if SelectedCell <> nil then begin
                    showAdjacent ( SelectedCell );
                  end;
                  aColor := clYellow;
                  aText := 'Show Adjacent';
                 end;
    modeMoveCell:begin
                  Panel1.Visible := true;
                  Panel2.Visible := false;
                  CnSpinEdit1.Enabled := False;
                  aColor := clSilver;
                  aText := 'Move Cell';
               end;
    modeSelectCell:begin
                  Panel1.Visible := True;
                  Panel2.Visible := false;
                  CnSpinEdit1.Enabled := false;
                  aColor := clRed;
                  aText := 'Select Cell';
                 end;
    modePanZoom: begin
                  Panel1.Visible := false;
                  Panel2.Visible := false;
                  SE_Theater1.MousePan := True;
                  SE_Theater1.MouseWheelZoom := True;
                  aColor := clSilver;
                  aText := 'Zoom/Pan';
                 end;
    modeCorner:  begin
                  Panel1.Visible := false;
                  Panel2.Visible := true;
                  ShowCorners;
                  aColor := clAqua;
                  aText := 'Set Corner/Straight';
                 end;
  end;

  SE_Engine3.RemoveAllSprites;
  aBmp:= Se_bitmap.Create (160,20);
  aBmp.Bitmap.Canvas.Brush.color := clBlack;
  aBmp.Bitmap.Canvas.FillRect( Rect(0,0,160,20)  );
  aBmp.Bitmap.Canvas.Font.color := aColor;
  aBmp.Bitmap.Canvas.Font.Size := 12;
  aBmp.Bitmap.Canvas.Font.Style := [fsBold];
  aBmp.Bitmap.Canvas.Font.Quality := fqAntialiased;

  w:= aBmp.Bitmap.Canvas.TextWidth( aText );
  aBmp.Bitmap.Canvas.TextOut( (aBmp.Width div 2) - (w div 2) ,0, aText);

  aSprite := SE_Sprite.Create (aBmp.bitmap, 'modeinfo' ,1,1,1000,SE_Theater1.Width Div 2,aBmp.Height div 2 ,False );
  SE_Engine3.AddSprite( aSprite );
  aBmp.free;


end;
procedure TForm1.FormCreate(Sender: TObject);
var
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
  mm := TMemoryStream.Create;

//  LoadCircuit;

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Circuit.Free;
  mm.free;
end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
  SE_Theater1.MousePan := false;
  SE_Theater1.MouseWheelZoom := False;

  if UpperCase(Key) = 'C' then begin
    Mode := modeAddCell;
  end
  else if UpperCase(Key) = 'L' then
  begin
    Mode := modeLinkForward;
  end
  else if UpperCase(Key) = 'A' then begin
    Mode := modeAdjacent;
  end
  else if UpperCase(Key) = 'M' then
    Mode := modeMoveCell
  else if UpperCase(Key) = 'S' then begin
    Mode := modeSelectCell;
  end
  else if UpperCase(Key) = 'K' then begin
    Mode := modeCorner;
  end
  else if UpperCase(Key) = 'Z' then begin
    Mode := modePanZoom;
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
        aCell := GetCell( StrToInt(lstsprite[0].guid) );
        CnSpinEdit1.Value := aCell.Lane;
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

  end
  else if mode = modeCorner then begin
    ClickedCell := True;
    aCell := GetCell( StrToInt(lstsprite[0].guid) );
    case Button of
      mbLeft: begin
        aCell.Corner := CnSpinEdit2.Value;
      end;
      mbRight: begin
        aCell.Corner := 0;
      end;
    end;
    ShowCorners;

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
      aCell.Lane := CnSpinEdit1.Value;
      CnSpinEdit1.Enabled := True;
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
  aCell: TCell;
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
    ShowAdjacent ( aSprite );
  end
  else if mode = modeLinkForward then begin
    ShowLinkForward ( aSprite );
  end;

  aCell := GetCell ( StrToInt (aSprite.Guid) );                   // dallo sprite alla cella
  CnSpinEdit1.Value := aCell.Lane;
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
  aCell :TCell;
begin
  aCell := GetCell ( StrToInt (MainSprite.Guid) );                   // dallo sprite alla cella
  aCell.LinkForward.Add( StrToInt (aSprite.Guid) );
  aSprite.bmp.Bitmap.Canvas.Brush.color := clGreen;
  aSprite.bmp.Bitmap.Canvas.Ellipse(2,2,16,16);

end;
procedure TForm1.AddAdjacent ( MainSprite, aSprite : SE_Sprite );
var
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
procedure TForm1.ShowCorners;
var
  i: Integer;
  aSprite: SE_Sprite;
begin
  ResetSpriteCells;
  for i := Circuit.Count -1 downto 0 do begin
    if Circuit[i].Corner <> 0 then begin
      aSprite := SE_Engine2.FindSprite( IntToStr(Circuit[i].Guid) ); // dalla cella allo sprite
      aSprite.bmp.Bitmap.Canvas.Brush.color := clAqua;
      aSprite.bmp.Bitmap.Canvas.Ellipse(2,2,16,16);
      aSprite.bmp.Bitmap.Canvas.Font.color := clNavy;
      aSprite.Bmp.Bitmap.Canvas.Font.Name := 'Calibri';
      aSprite.bmp.Bitmap.Canvas.Font.Size := 8;
      aSprite.bmp.Bitmap.Canvas.Font.Style := [fsBold];
      aSprite.bmp.Bitmap.Canvas.Font.Quality := fqAntialiased;

      aSprite.bmp.Bitmap.Canvas.TextOut( 7,2, IntToStr(Circuit[i].Corner ));
    end;
  end;

end;

end.
