unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Generics.Defaults, System.Generics.Collections,

  DSE_list, FormulaDBrain, DSE_theater, DSE_Bitmap, DSE_SearchFiles, DSE_Misc, Vcl.ExtCtrls, Vcl.StdCtrls, CnSpin, System.IniFiles, Vcl.Grids;

type TMode = ( modeAddCell{C}, modeLinkForward{L}, modeAdjacent{A}, modeMoveCell{M}, modeSelectCell{S}, modePanZoom{Z},
                modeCorner{K},modeStartingGrid{G}, modeBox{B}, modefinishLine{F},modeDistance{D}, modeAngle{N},modeGuid{I} ) ;
type
  TForm1 = class(TForm)
    SE_Theater1: SE_Theater;
    Panel1: TPanel;
    SE_Engine1: SE_Engine;
    SE_Engine2: SE_Engine;
    CnSpinEdit1: TCnSpinEdit;
    Label1: TLabel;
    Panel2: TPanel;
    Button1: TButton;
    Label2: TLabel;
    CnSpinEdit2: TCnSpinEdit;
    PanelLoad: TPanel;
    StringGrid2: TStringGrid;
    Button2: TButton;
    SE_SearchFiles1: SE_SearchFiles;
    Panel3: TPanel;
    Label3: TLabel;
    Panel4: TPanel;
    Label4: TLabel;
    CnSpinEdit3: TCnSpinEdit;
    CnSpinEdit4: TCnSpinEdit;
    Panel5: TPanel;
    Label5: TLabel;
    CnSpinEdit5: TCnSpinEdit;
    CnSpinEdit6: TCnSpinEdit;
    PanelMode: TPanel;
    LabelMode: TLabel;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Panel6: TPanel;
    Label6: TLabel;
    CnSpinEdit7: TCnSpinEdit;
    SE_EngineCars: SE_Engine;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SE_Theater1TheaterMouseDown(Sender: TObject; VisibleX, VisibleY, VirtualX, VirtualY: Integer; Button: TMouseButton;Shift: TShiftState);
    procedure Button1Click(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure SE_Theater1TheaterMouseMove(Sender: TObject; VisibleX, VisibleY, VirtualX, VirtualY: Integer; Shift: TShiftState);
    procedure SE_Theater1TheaterMouseUp(Sender: TObject; VisibleX, VisibleY, VirtualX, VirtualY: Integer; Button: TMouseButton; Shift: TShiftState);
    procedure SE_Theater1SpriteMouseDown(Sender: TObject; lstSprite: TObjectList<DSE_theater.SE_Sprite>; Button: TMouseButton; Shift: TShiftState);
    procedure Button2Click(Sender: TObject);
    procedure StringGrid2SelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure SE_Theater1SpriteMouseMove(Sender: TObject; lstSprite: TObjectList<DSE_theater.SE_Sprite>; Shift: TShiftState;
      var Handled: Boolean);
  private
    { Private declarations }
    fmode : TMode;
    procedure SetMode ( aMode : Tmode );
  public
    { Public declarations }
    function GetNextGuid: SmallInt;
    function FindDuplicateCell ( Guid,Index: Integer): TCell;

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
    procedure ShowAngle;
    procedure ShowGuid;
    procedure ShowStartingGrid;
    procedure ShowBox;
    procedure ShowfinishLine;
    procedure ShowDistance;
    procedure LoadCircuit ( CircuitName: string );
    property Mode :Tmode read fmode write SetMode;
  end;

var
  Form1: TForm1;
  Circuit : TObjectList<TCell>;
  CircuitDescr: TCircuitDescr;
  incGuid : SmallInt;
  SelectedCell : SE_Sprite;
  DeletedCell: Boolean;
  ClickedCell: Boolean;
  mm : TMemoryStream;
  dir_Cars, dir_circuits : string;
  carSprite: SE_Sprite;
implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  i,L,a,count,tmpI: Integer;
  TotCells: SmallInt;
  TotLinkForward, TotAdjacent, tmpb: Byte;
begin
  mm.Clear;

  TotCells := Circuit.Count;
  mm.Write( @TotCells, sizeof(SmallInt) );
  for I :=  0 to Circuit.Count -1 do begin
    mm.Write( @Circuit[i].Guid , SizeOf(SmallInt));
    mm.Write( @Circuit[i].Lane , SizeOf(ShortInt));
    mm.Write( @Circuit[i].Corner , SizeOf(Byte));
    mm.Write( @Circuit[i].Angle , SizeOf(Single));
    mm.Write( @Circuit[i].StartingGrid , SizeOf(Byte));
    mm.Write( @Circuit[i].Box , SizeOf(Byte));
    mm.Write( @Circuit[i].FinishLine , SizeOf(Boolean));
    mm.Write( @Circuit[i].DistCorner , SizeOf(Byte));
    mm.Write( @Circuit[i].DistStraight , SizeOf(Byte));
    mm.Write( @Circuit[i].PixelX , SizeOf(SmallInt));
    mm.Write( @Circuit[i].PixelY , SizeOf(SmallInt));
    TotLinkForward := Circuit[i].LinkForward.Count;
    mm.Write( @TotLinkForward, sizeof(byte) );
    for L := Circuit[i].LinkForward.Count -1 Downto 0 do begin
      tmpI := Circuit[i].LinkForward.Items[L];
      mm.Write( @tmpI, sizeof(integer) );
    end;

    TotAdjacent := Circuit[i].Adjacent.Count;
    mm.Write( @TotAdjacent, sizeof(byte) );
    for a := Circuit[i].Adjacent.Count -1 Downto 0 do begin
      tmpI := Circuit[i].Adjacent.Items[a];
      mm.Write( @tmpI, sizeof(integer) );
    end;

  end;

  mm.SaveToFile( dir_circuits + 'barcelona.fd' );


end;
procedure TForm1.LoadCircuit ( CircuitName: string );
var
  ini : TIniFile;
  TotCells,tmpSmallInt: SmallInt;
  i,L,a,count,tmpI: Integer;
  aCell: TCell;
  TotLinkForward, TotAdjacent, tmpb: Byte;
  aBmp: SE_Bitmap;
  aSprite: SE_Sprite;
begin
  Circuit.clear;
  aBmp:= Se_bitmap.Create (22,16);
  aBmp.Bitmap.Canvas.Brush.color := clGray;
  aBmp.Bitmap.Canvas.Ellipse(2,2,22,16);

//  ini := TIniFile.Create( dir_circuits + CircuitName + '.ini' );
//  CircuitDescr.Corners := ini.ReadString('setup','Corners','');
//  ini.Free;

  mm.LoadFromFile(  dir_circuits + CircuitName + '.fd' );
  mm.Position := 0;
  mm.Read ( TotCells, SizeOf(SmallInt) );
  for I := 0 to TotCells -1 do begin
    aCell := TCell.Create;
    mm.Read( aCell.Guid , SizeOf(SmallInt) );
    mm.Read( aCell.Lane , SizeOf(ShortInt) );
    mm.Read( aCell.Corner , SizeOf(Byte) );
    mm.Read( aCell.Angle , SizeOf(Single) );
    mm.Read( aCell.StartingGrid , SizeOf(Byte) );
    mm.Read( aCell.Box , SizeOf(Byte) );
    mm.Read( aCell.FinishLine , SizeOf(Boolean) );
    mm.Read( aCell.DistCorner , SizeOf(Byte) );
    mm.Read( aCell.DistStraight , SizeOf(Byte) );
    mm.Read( aCell.PixelX , SizeOf(SmallInt) );
    mm.Read( aCell.PixelY , SizeOf(SmallInt) );
      // load linkForward e Adjacent
    mm.Read( TotLinkForward, SizeOf(Byte) );
    for L := 0 to TotLinkForward -1 do begin
      mm.Read( tmpI , SizeOf(integer) );
      aCell.LinkForward.add ( tmpI );
    end;
    mm.Read( TotAdjacent, SizeOf(Byte) );
    for A := 0 to TotAdjacent -1 do begin
      mm.Read( tmpI , SizeOf(integer) );
      aCell.Adjacent.add ( tmpI );
    end;

    // tutte clgray all'inizio
    Circuit.Add(aCell);
    aSprite := SE_Sprite.Create (aBmp.bitmap, IntToStr(aCell.Guid) ,1,1,1000,0,0,true );
    SE_Engine2.AddSprite( aSprite );
    aSprite.Position := Point (  aCell.PixelX , aCell.PixelY  );

  end;
  incGuid := GetNextGuid;

  aBmp.free;



end;

procedure TForm1.Button2Click(Sender: TObject);
var
  i: Integer;
begin

  SE_SearchFiles1.FromPath :=  ( dir_circuits );
  SE_SearchFiles1.MaskInclude.Add(  '*.ini');
  SE_SearchFiles1.Execute;

  while SE_SearchFiles1.SearchState <> ssIdle do begin
    application.ProcessMessages;
  end;

  StringGrid2.RowCount := SE_SearchFiles1.ListFiles.count ;

  for I := 0 to SE_SearchFiles1.ListFiles.Count -1 do begin
    StringGrid2.Cells[ 0, i] :=  JustNameL (SE_SearchFiles1.ListFiles[i]);
  end;

  PanelLoad.Visible := True;

end;

procedure TForm1.Button3Click(Sender: TObject);
var
  i: Integer;
  can : boolean;
begin

  if Application.MessageBox('LinkForward and Adjacent will be cleared. Are you Sure?',
			   'Warning!', MB_YESNO) = ID_YES then begin

    for I := 0 to Circuit.Count -1 do begin
  //    Circuit[i].Guid := i + 1;
      Circuit[i].LinkForward.Clear;
      Circuit[i].Adjacent.Clear;
    end;
    Button1Click(Button1);
    can := True;
    StringGrid2SelectCell(StringGrid2, 0,  StringGrid2.Row , Can );
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  i: Integer;
  aCell:TCell;
  label Retry;
begin

  Circuit.sort(TComparer<TCell>.Construct(
  function (const L, R: TCell): integer
  begin
    Result := (L.Guid ) - (R.Guid  );
  end
  ));

Retry:
  for I := Circuit.Count -1 downto 0 do begin
    aCell := FindDuplicateCell (Circuit[i].Guid, I );
    if aCell <> nil then begin
      Circuit.Delete( i );
      goto retry;
    end;
  end;

  ShowMessage(('done!'));
end;
function TForm1.FindDuplicateCell ( Guid,Index: Integer): TCell;
var
  i: Integer;
begin
  Result := nil;
  for I := Circuit.Count -1 downto 0 do begin
    if i = Index then Continue;
    if Circuit[i].Guid = Guid then begin
      Result := Circuit[i];
      Exit;
    end;
  end;

end;
procedure TForm1.SetMode ( aMode : Tmode );
var
  aColor : TColor;
  aText : string;
begin
                  Panel1.Visible := False;
                  Panel2.Visible := false;
                  Panel3.Visible := false;
                  Panel4.Visible := false;
                  Panel5.Visible := false;
                  Panel6.Visible := false;
                  carSprite.Visible := false;

  fmode := aMode;
  case aMode of
    modeAddCell: begin
                  Panel1.Visible := True;
                  CnSpinEdit1.Enabled := true;
                  aColor := clBlack;
                  aText := 'Add Cell';
                 end;
    modeLinkForward:begin
                  if SelectedCell <> nil then begin
                    showLinkForward ( SelectedCell );
                  end;
                  aColor := clGreen;
                  aText := 'Show LinkForward';
                 end;
    modeAdjacent: begin
                  if SelectedCell <> nil then begin
                    showAdjacent ( SelectedCell );
                  end;
                  aColor := $32B4FE;
                  aText := 'Show Adjacent';
                 end;
    modeMoveCell:begin
                  Panel1.Visible := true;
                  CnSpinEdit1.Enabled := False;
                  aColor := clBlack;
                  aText := 'Move Cell';
                 end;
    modeSelectCell:begin
                  Panel1.Visible := True;
                  CnSpinEdit1.Enabled := false;
                  aColor := clRed;
                  aText := 'Select Cell';
                 end;
    modePanZoom: begin
                  SE_Theater1.MousePan := True;
                  SE_Theater1.MouseWheelZoom := True;
                  aColor := clBlack;
                  aText := 'Zoom/Pan';
                 end;
    modeCorner:  begin
                  Panel2.Visible := true;
                  ShowCorners;
                  aColor := clAqua;
                  aText := 'Set Corner/Straight';
                 end;
    modeAngle:   begin
                  Panel6.Visible := true;
                  ShowAngle;
                  aColor := cllime;
                  aText := 'Set Car Angle';
                  carSprite.Visible := True;
                 end;
    modeGuid:    begin
                  ShowGuid;
                  aColor := clBlack;
                  aText := 'Guid Info';
                 end;
    modeStartingGrid:  begin
                  Panel3.Visible := True;
                  ShowStartingGrid;
                  aColor := clBlack;
                  aText := 'Set Starting Grid';
                 end;
    modeBox:     begin
                  Panel4.Visible := True;
                  ShowBox;
                  aColor := clWhite;
                  aText := 'Set Box';
                 end;
    modeFinishLine: begin
                  ShowFinishLine;
                  aColor := clBlack;
                  aText := 'Set Finish Line';
                 end;
    modeDistance: begin
                  Panel5.Visible := True;
                  ShowDistance;
                  aColor := clBlack;
                  aText := 'Set Distance';
                 end;
  end;


  LabelMode.Font.Color := aColor;
  LabelMode.Caption :=  aText ;


end;
procedure TForm1.FormCreate(Sender: TObject);
begin
  dir_cars :=  ExtractFilePath (Application.ExeName)+ 'bmp\cars\';
  dir_circuits := ExtractFilePath (Application.ExeName)+'circuits\';

  Circuit := TObjectList<TCell>.Create(True);
  SE_Theater1.Active := True;
  mm := TMemoryStream.Create;

  carSprite:=  SE_EngineCars.CreateSprite( dir_Cars + '1.bmp', 'car',1,1,1000,0,0,true);
  carSprite.Scale := 86;
  carSprite.Visible := False;

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
  else if UpperCase(Key) = 'L' then begin
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
  else if UpperCase(Key) = 'N' then begin
    Mode := modeAngle;
  end
  else if UpperCase(Key) = 'I' then begin
    Mode := modeGuid;
  end
  else if UpperCase(Key) = 'G' then begin
    Mode := modeStartingGrid;
  end
  else if UpperCase(Key) = 'B' then begin
    Mode := modeBox;
  end
  else if UpperCase(Key) = 'F' then begin
    Mode := modeFinishLine;
  end
  else if UpperCase(Key) = 'D' then begin
    Mode := modeDistance;
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
        SelectedCell := nil;
      end;
    end;

  end
  else if mode = modeLinkForward then begin
    ClickedCell := True;
    case Button of
      mbLeft: begin
        if SelectedCell <> nil then begin
          AddAdjacent ( SelectedCell, lstSprite[0] );     // prima colora di giallo
          AddLinkForward ( SelectedCell, lstSprite[0] );  // poi colora di Verde
        end;
      end;
      mbRight: begin
        if SelectedCell <> nil then begin
          RemoveLinkForward ( SelectedCell, lstSprite[0] );
          RemoveAdjacent ( SelectedCell, lstSprite[0] );
        end;
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

  end
  else if mode = modeAngle then begin
    ClickedCell := True;
    aCell := GetCell( StrToInt(lstsprite[0].guid) );
    case Button of
      mbLeft: begin
        aCell.Angle := CnSpinEdit7.Value;
      end;
      mbRight: begin
        aCell.Angle := 0;
      end;
    end;
    ShowAngle;

  end
  else if mode = modeStartingGrid then begin
    ClickedCell := True;
    aCell := GetCell( StrToInt(lstsprite[0].guid) );
    case Button of
      mbLeft: begin
        aCell.StartingGrid := CnSpinEdit3.Value;
      end;
      mbRight: begin
        aCell.StartingGrid := 0;
      end;
    end;
    ShowStartingGrid;

  end
  else if mode = modeBox then begin
    ClickedCell := True;
    aCell := GetCell( StrToInt(lstsprite[0].guid) );
    case Button of
      mbLeft: begin
        aCell.Box := CnSpinEdit4.Value;
      end;
      mbRight: begin
        aCell.Box := 0;
      end;
    end;
    ShowBox;

  end
  else if mode = modeFinishLine then begin
    ClickedCell := True;
    aCell := GetCell( StrToInt(lstsprite[0].guid) );
    case Button of
      mbLeft: begin
        aCell.finishLine := True;
      end;
      mbRight: begin
        aCell.finishLine := false;
      end;
    end;
    ShowFinishLine;

  end
  else if mode = modeDistance then begin
    ClickedCell := True;
    aCell := GetCell( StrToInt(lstsprite[0].guid) );
    case Button of
      mbLeft: begin
        aCell.DistCorner := CnSpinEdit5.Value ;
        aCell.DistStraight := CnSpinEdit6.Value ;
        CnSpinEdit5.Value := CnSpinEdit5.Value + 1;
        CnSpinEdit6.Value := CnSpinEdit6.Value + 1;
      end;
      mbRight: begin
        aCell.DistCorner := 0 ;
        aCell.DistStraight := 0 ;
      end;
    end;
    ShowDistance;

  end;

end;

procedure TForm1.SE_Theater1SpriteMouseMove(Sender: TObject; lstSprite: TObjectList<DSE_theater.SE_Sprite>; Shift: TShiftState; var Handled: Boolean);
var
  aCell: TCell;
begin
  Handled:= True;
  if lstSprite[0].Engine = se_engine2 then begin
    if mode = modeAngle then begin
      aCell := GetCell ( StrToInt (lstSprite[0].Guid) );                   // dallo sprite alla cella
      carSprite.Position := lstSprite[0].Position;
      carSprite.Angle := aCell.Angle;
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
      aCell.Lane := CnSpinEdit1.Value;
      CnSpinEdit1.Enabled := True;
      aCell.Guid := incGuid;

      Circuit.Add(aCell);


      aBmp:= Se_bitmap.Create (20,16);
      aBmp.Bitmap.Canvas.Brush.color := clGray;
      aBmp.Bitmap.Canvas.Ellipse(2,2,22,16);

      aSprite := SE_Sprite.Create (aBmp.bitmap, IntToStr(incGuid) ,1,1,1000,0,0,true );
      incGuid := GetNextGuid;
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
      Break;
    end;
  end;
  incGuid := GetNextGuid;

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
      Break;
    end;
  end;
  incGuid := GetNextGuid;

end;
function TForm1.GetNextGuid: SmallInt;
var
  i: Integer;
begin
  Result := Circuit.Count + 1;

  Circuit.sort(TComparer<TCell>.Construct(
  function (const L, R: TCell): integer
  begin
    Result := (L.Guid ) - (R.Guid  );
  end
  ));

  for I := 0 to Circuit.Count -2 do begin
    if Circuit[i].Guid <> i + 1 then begin
      result := i + 1;
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
    SE_Engine2.Sprites[i].bmp.Bitmap.Canvas.Ellipse(2,2,22,16);
  end;

  if SelectedCell <> nil then begin
    SelectedCell.Bmp.Bitmap.Canvas.Brush.color := clGray;
    SelectedCell.Bmp.Bitmap.Canvas.Ellipse(2,2,22,16);
  end;

  SelectedCell := aSprite;
  aSprite.Bmp.Bitmap.Canvas.Brush.color := clRed;
  aSprite.Bmp.Bitmap.Canvas.Ellipse(2,2,22,16);

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
    LinkedSprite.bmp.Bitmap.Canvas.Ellipse(2,2,22,16);
  end;
end;
procedure TForm1.StringGrid2SelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var
  aSprite : SE_Sprite;
  i: Integer;
  ini: TInifile;
begin
  Circuit.Clear;

  SE_Theater1.Active := False;
  aSprite := SE_Sprite.Create (dir_circuits + JustNameL ( StringGrid2.Cells[0,aRow] )+'.bmp','circuit',1,1,1000,0,0,false );

  SE_Engine1.RemoveAllSprites;
  SE_Engine2.RemoveAllSprites;
  SelectedCell := nil;

  SE_Theater1.VirtualWidth := aSprite.BMP.Width;
  SE_Theater1.VirtualHeight := aSprite.BMP.Height;

  SE_Engine1.AddSprite( aSprite );
  aSprite.Position := Point (  SE_Theater1.VirtualWidth div 2 , SE_Theater1.Virtualheight div 2  );
  SE_Theater1.Active := True;

  Mode := modePanZoom;
  PanelLoad.Visible := False;
  LoadCircuit ( JustNameL( StringGrid2.Cells[0,aRow]))  ;
  incGuid := GetNextGuid;
  Mode := modePanZoom;

  Button3.Visible := True;
  Button4.Visible := True;
  Button5.Visible := True;
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
    AdjacentSprite.bmp.Bitmap.Canvas.Brush.color := $32B4FE;
    AdjacentSprite.bmp.Bitmap.Canvas.Ellipse(2,2,22,16);
  end;
end;
procedure TForm1.AddLinkForward ( MainSprite, aSprite : SE_Sprite );
var
  aCell :TCell;
begin
  aCell := GetCell ( StrToInt (MainSprite.Guid) );                   // dallo sprite alla cella
  aCell.LinkForward.Add( StrToInt (aSprite.Guid) );
  aSprite.bmp.Bitmap.Canvas.Brush.color := clGreen;
  aSprite.bmp.Bitmap.Canvas.Ellipse(2,2,22,16);

end;
procedure TForm1.AddAdjacent ( MainSprite, aSprite : SE_Sprite );
var
  aCell  :TCell;
begin
  aCell := GetCell ( StrToInt (MainSprite.Guid) );                   // dallo sprite alla cella
  aCell.Adjacent.Add( StrToInt (aSprite.Guid) );
  aSprite.bmp.Bitmap.Canvas.Brush.color := $32B4FE;
  aSprite.bmp.Bitmap.Canvas.Ellipse(2,2,22,16);

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
      aSprite.bmp.Bitmap.Canvas.Ellipse(2,2,22,16);
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
      aSprite.bmp.Bitmap.Canvas.Ellipse(2,2,22,16);
    end;
  end;


end;
procedure TForm1.ResetSpriteCells;
var
  i: Integer;
begin
  for I := 0 to SE_Engine2.SpriteCount -1 do begin
    SE_Engine2.Sprites[i].bmp.Bitmap.Canvas.Brush.color := clWhite;
    SE_Engine2.Sprites[i].bmp.Bitmap.Canvas.FillRect( Rect(0,0,SE_Engine2.Sprites[i].bmp.Width,SE_Engine2.Sprites[i].bmp.Height) );
    SE_Engine2.Sprites[i].bmp.Bitmap.Canvas.Brush.color := clGray; // torna normale.
    SE_Engine2.Sprites[i].bmp.Bitmap.Canvas.Ellipse(2,2,22,16);
  end;

  if (SelectedCell <> nil) then begin
    SelectedCell.Bmp.Bitmap.Canvas.Brush.color := clRed;
    SelectedCell.Bmp.Bitmap.Canvas.Ellipse(2,2,22,16);
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
      aSprite.bmp.Bitmap.Canvas.Ellipse(2,2,22,16);
      aSprite.bmp.Bitmap.Canvas.Font.color := clNavy;
      aSprite.Bmp.Bitmap.Canvas.Font.Name := 'Calibri';
      aSprite.bmp.Bitmap.Canvas.Font.Size := 8;
      aSprite.bmp.Bitmap.Canvas.Font.Style := [fsBold];
      aSprite.bmp.Bitmap.Canvas.Font.Quality := fqAntialiased;

      aSprite.bmp.Bitmap.Canvas.TextOut( 7,2, IntToStr(Circuit[i].Corner ));
    end;
  end;

end;
procedure TForm1.ShowAngle;
var
  i: Integer;
  aSprite: SE_Sprite;
begin
  ResetSpriteCells;
  for i := Circuit.Count -1 downto 0 do begin

      aSprite := SE_Engine2.FindSprite( IntToStr(Circuit[i].Guid) ); // dalla cella allo sprite
      aSprite.bmp.Bitmap.Canvas.Brush.color := clLime;
      aSprite.bmp.Bitmap.Canvas.Ellipse(2,2,22,16);
      aSprite.bmp.Bitmap.Canvas.Font.color := clNavy;
      aSprite.Bmp.Bitmap.Canvas.Font.Name := 'Calibri';
      aSprite.bmp.Bitmap.Canvas.Font.Size := 8;
      aSprite.bmp.Bitmap.Canvas.Font.Style := [fsBold];
      aSprite.bmp.Bitmap.Canvas.Font.Quality := fqAntialiased;

      aSprite.bmp.Bitmap.Canvas.TextOut( 7,2, FloatToStr(Circuit[i].Angle ));

  end;

end;
procedure TForm1.ShowGuid;
var
  i: Integer;
  aSprite: SE_Sprite;
begin
  ResetSpriteCells;
  for i := Circuit.Count -1 downto 0 do begin

      aSprite := SE_Engine2.FindSprite( IntToStr(Circuit[i].Guid) ); // dalla cella allo sprite
      aSprite.bmp.Bitmap.Canvas.Brush.color := clLime;
      aSprite.bmp.Bitmap.Canvas.Ellipse(2,2,22,16);
      aSprite.bmp.Bitmap.Canvas.Font.color := clNavy;
      aSprite.Bmp.Bitmap.Canvas.Font.Name := 'Calibri';
      aSprite.bmp.Bitmap.Canvas.Font.Size := 8;
    //  aSprite.bmp.Bitmap.Canvas.Font.Style := [fsBold];
      aSprite.bmp.Bitmap.Canvas.Font.Quality := fqAntialiased;

      aSprite.bmp.Bitmap.Canvas.TextOut( 7,2, FloatToStr(Circuit[i].Guid ));

  end;

end;
procedure TForm1.ShowStartingGrid;
var
  i: Integer;
  aSprite: SE_Sprite;
  aCell : TCell;
begin
  ResetSpriteCells;
  for i := Circuit.Count -1 downto 0 do begin
    aCell := Circuit[i];
    if aCell.StartingGrid <> 0 then begin
      aSprite := SE_Engine2.FindSprite( IntToStr(aCell.Guid) ); // dalla cella allo sprite
      aSprite.bmp.Bitmap.Canvas.Brush.color := clBlack;
      aSprite.bmp.Bitmap.Canvas.Ellipse(2,2,22,16);
      aSprite.bmp.Bitmap.Canvas.Font.color := clWhite;
      aSprite.Bmp.Bitmap.Canvas.Font.Name := 'Calibri';
      aSprite.bmp.Bitmap.Canvas.Font.Size := 8;
      aSprite.bmp.Bitmap.Canvas.Font.Style := [fsBold];
      aSprite.bmp.Bitmap.Canvas.Font.Quality := fqAntialiased;

      aSprite.bmp.Bitmap.Canvas.TextOut( 7,2, IntToStr(aCell.StartingGrid ));
    end;
  end;

end;
procedure TForm1.ShowBox;
var
  i: Integer;
  aSprite: SE_Sprite;
begin
  ResetSpriteCells;
  for i := Circuit.Count -1 downto 0 do begin
    if Circuit[i].Box <> 0 then begin
      aSprite := SE_Engine2.FindSprite( IntToStr(Circuit[i].Guid) ); // dalla cella allo sprite
      aSprite.bmp.Bitmap.Canvas.Brush.color := clWhite-1;
      aSprite.bmp.Bitmap.Canvas.Ellipse(2,2,22,16);
      aSprite.bmp.Bitmap.Canvas.Font.color := clBlack;
      aSprite.Bmp.Bitmap.Canvas.Font.Name := 'Calibri';
      aSprite.bmp.Bitmap.Canvas.Font.Size := 8;
      aSprite.bmp.Bitmap.Canvas.Font.Style := [fsBold];
      aSprite.bmp.Bitmap.Canvas.Font.Quality := fqAntialiased;

      aSprite.bmp.Bitmap.Canvas.TextOut( 7,2, IntToStr(Circuit[i].Box ));
    end;
  end;

end;
procedure TForm1.ShowFinishLine;
var
  i: Integer;
  aSprite: SE_Sprite;
begin
  ResetSpriteCells;
  for i := Circuit.Count -1 downto 0 do begin
    if Circuit[i].FinishLine  then begin
      aSprite := SE_Engine2.FindSprite( IntToStr(Circuit[i].Guid) ); // dalla cella allo sprite
      aSprite.bmp.Bitmap.Canvas.Brush.color := clWhite-1;
      aSprite.bmp.Bitmap.Canvas.Ellipse(2,2,22,16);
      aSprite.bmp.Bitmap.Canvas.Font.color := clBlack;
      aSprite.Bmp.Bitmap.Canvas.Font.Name := 'Calibri';
      aSprite.bmp.Bitmap.Canvas.Font.Size := 8;
      aSprite.bmp.Bitmap.Canvas.Font.Style := [fsBold];
      aSprite.bmp.Bitmap.Canvas.Font.Quality := fqAntialiased;

      aSprite.bmp.Bitmap.Canvas.TextOut( 7,2, IntToStr(  Integer(Circuit[i].FinishLine) ));
    end;
  end;

end;
procedure TForm1.ShowDistance;
var
  i: Integer;
  aSprite: SE_Sprite;
begin
  ResetSpriteCells;
  for i := Circuit.Count -1 downto 0 do begin
      aSprite := SE_Engine2.FindSprite( IntToStr(Circuit[i].Guid) ); // dalla cella allo sprite
      aSprite.bmp.Bitmap.Canvas.Brush.color := clBlack;
      aSprite.bmp.Bitmap.Canvas.Ellipse(2,2,22,16);
      aSprite.bmp.Bitmap.Canvas.Font.color := clWhite-1;
      aSprite.Bmp.Bitmap.Canvas.Font.Name := 'Calibri';
      aSprite.bmp.Bitmap.Canvas.Font.Size := 6;
      //aSprite.bmp.Bitmap.Canvas.Font.Style := [fsBold];
      aSprite.bmp.Bitmap.Canvas.Font.Quality := fqAntialiased;

      aSprite.bmp.Bitmap.Canvas.TextOut( 0,2, IntToStr(Circuit[i].DistCorner)+ '-'+IntToStr(Circuit[i].DistStraight));
  end;

end;
procedure TForm1.Button5Click(Sender: TObject);
var
  i: Integer;
  aCell:TCell;
  label Retry;
begin

  Circuit.sort(TComparer<TCell>.Construct(
  function (const L, R: TCell): integer
  begin
    Result := (L.Guid ) - (R.Guid  );
  end
  ));

Retry:
  for I := Circuit.Count -1 downto 0 do begin
    if Circuit[i].Guid <> i + 1 then begin
      ShowMessage('Check failed' );
      Exit;
    end;
  end;

  ShowMessage(('done! Integrity OK'));
end;


end.
