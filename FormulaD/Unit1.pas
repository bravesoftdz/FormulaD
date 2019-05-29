unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, CnButtons, Vcl.ExtCtrls, DSE_Panel, Vcl.StdCtrls,
  DSE_Misc, DSE_theater, DSE_Bitmap, DSE_GRID, DSE_SearchFiles, OverbyteIcsWndControl, OverbyteIcsWSocket, OverbyteIcsWSocketS,
  OverbyteIcsWSocketTS ;
type TCarBmp = record
  bmp : SE_Bitmap;
  PosGrid : Integer;
end;
type pTCarBmp = ^TCarBmp;
type
  TForm1 = class(TForm)
    PanelMain: SE_Panel;
    btnCreateGame: TCnSpeedButton;
    btnJoinGame: TCnSpeedButton;
    btnExit: TCnSpeedButton;
    PanelCreateGame: SE_Panel;
    cbCircuit: TComboBox;
    lblCircuit: TLabel;
    lblLap: TLabel;
    cbLaps: TComboBox;
    lblWeather: TLabel;
    SE_GridWheater: SE_Grid;
    lblHumanPlayers: TLabel;
    cbHumanPlayers: TComboBox;
    SE_SearchFiles1: SE_SearchFiles;
    cbCPU: TComboBox;
    lblCPU: TLabel;
    SE_GridSetupPlayers: SE_Grid;
    lblQual: TLabel;
    SE_GridQual: SE_Grid;
    Tcpserver: TWSocketThrdServer;
    EdtPwd: TEdit;
    edtPort: TEdit;
    btnStartGame: TCnSpeedButton;
    lblCarSetup: TLabel;
    SE_GridCarColor: SE_Grid;
    procedure FormCreate(Sender: TObject);
    procedure btnCreateGameClick(Sender: TObject);
    procedure SE_GridWheaterGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer;
      Sprite: SE_Sprite);
    procedure SE_GridQualGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer;
      Sprite: SE_Sprite);
    procedure cbHumanPlayersCloseUp(Sender: TObject);
    procedure cbCPUCloseUp(Sender: TObject);
    procedure btnStartGameClick(Sender: TObject);
    procedure SE_GridSetupPlayersGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer;
      Sprite: SE_Sprite);
    procedure SE_GridCarColorGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer;
      Sprite: SE_Sprite);
  private
    { Private declarations }
    procedure RefreshPlayerCPU;
    procedure ResetSetupWheater;
    procedure SelectSetupWheater ( Col : Integer );
    procedure ResetSetupQual;
    procedure SelectSetupQual ( Col : Integer );
    procedure ResetCarColor;
    function FindCarBmpPos ( Pos : Integer ): pTCarBmp;
  public
    { Public declarations }
  end;

  const EndofLine = 'ENDFD';
var
  Form1: TForm1;
  dir_bmpWheater, dir_Cars, dir_Circuits: string;
  CarBmp : array[1..10] of TCarBmp;
  RowPlayer: Integer; // per il cambio di colore
implementation

{$R *.dfm}

procedure TForm1.btnCreateGameClick(Sender: TObject);
begin
  SelectSetupWheater (4);
  SelectSetupQual (1);
  TcpServer.Port :=  edtPort.Text ;
  TcpServer.LineMode            := true;
  TcpServer.LineEdit            := false;
  TcpServer.LineEnd             := EndOfLine;
  TcpServer.LineLimit           := 1024;
  TcpServer.Addr                := '0.0.0.0';
  TcpServer.MaxClients          := StrToInt(cbHumanPlayers.text);
  TcpServer.Listen ;

  RefreshPlayerCPU;

end;

procedure TForm1.btnStartGameClick(Sender: TObject);
begin
// quando tutti sono connessi
end;

procedure TForm1.cbCPUCloseUp(Sender: TObject);
var
  i: Integer;
begin
  if (StrToInt(cbHumanPlayers.Text) + StrToInt(cbCPU.Text) ) > 10 then
    cbHumanPlayers.ItemIndex := ( 10 -  StrToInt(cbCPU.Text) ) ;

  RefreshPlayerCPU;

end;

procedure TForm1.cbHumanPlayersCloseUp(Sender: TObject);
var
  i: Integer;
begin
  if (StrToInt(cbHumanPlayers.Text) + StrToInt(cbCPU.Text) ) > 10 then
    cbCPU.ItemIndex := ( 10 -  StrToInt(cbHumanPlayers.Text) ) ;

    RefreshPlayerCPU;

end;
procedure TForm1.RefreshPlayerCPU;
var
  i,TotRow: Integer;
  aCarBmp: pTCarBmp;
begin
//  Refresh Grid e Tcp

  TotRow := StrtoInt ( cbHumanPlayers.text ) + StrtoInt ( cbCPU.text ) ;
  for I := High (CarBmp) downto TotRow  do begin
    aCarBmp:= FindCarbmpPos ( i );
    if aCarBmp <> nil then
       aCarBmp.PosGrid := -1;
  end;

  // Grid HumanPlayers ----------------------------------------------------
  SE_GridSetupPlayers.ClearData;   // importante anche pr memoryleak
  SE_GridSetupPlayers.DefaultColWidth := 51;
  SE_GridSetupPlayers.DefaultRowHeight := 24;
  SE_GridSetupPlayers.ColCount := 2;
  SE_GridSetupPlayers.RowCount := TotRow;
  SE_GridSetupPlayers.Columns[0].Width := 51;
  SE_GridSetupPlayers.Columns[1].Width := 160;


  for I := 0 to TotRow -1 do begin
    SE_GridSetupPlayers.Rows[i].Height := 24;
    SE_GridSetupPlayers.Cells[1,i].FontColor := clWhite;

    if i < StrtoInt ( cbHumanPlayers.text )   then
      SE_GridSetupPlayers.Cells[1,i].Text  := 'Waiting for Tcp connection'
      else SE_GridSetupPlayers.Cells[1,i].Text  := 'CPU' + IntToStr(I+1);

    aCarBmp:= FindCarbmpPos ( i );

    if aCarBmp = nil then  begin                    // se ancora non è assegnata
      aCarBmp:= FindCarbmpPos ( -1 );                           // cerco la prima libera con valore -1
      aCarBmp.PosGrid := i;
      SE_GridSetupPlayers.AddSE_Bitmap(0,i,1,aCarBmp.bmp ,true);
    end
    else begin
      if aCarBmp.PosGrid > -1 then                                // se la car è già assegnata alla row
        SE_GridSetupPlayers.AddSE_Bitmap(0,i,1,aCarBmp.bmp ,true)

    end;
  end;
  SE_GridSetupPlayers.Height := 24 * TotRow ;
  if SE_GridSetupPlayers.Height <= 0 then
     SE_GridSetupPlayers.Height :=1;

  SE_GridSetupPlayers.Width := 160+51;

  //----------------------------------------------------------------------

            // ----- Tcp refresh Grid players --------
        for I := 0 to Tcpserver.ClientCount -1 do begin
          if i <= StrtoInt ( cbHumanPlayers.text ) then begin
            SE_GridSetupPlayers.Cells[1,i+1].Text := Tcpserver.Client[i].UserName;
          end;
        end;

            // ---------------------------------------


  SE_GridSetupPlayers.CellsEngine.ProcessSprites(20);
  SE_GridSetupPlayers.RefreshSurface ( SE_GridSetupPlayers );

end;
procedure TForm1.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  dir_cars :=  ExtractFilePath (Application.ExeName)+ 'bmp\cars\';
  dir_Circuits := ExtractFilePath (Application.ExeName)+'circuits\';
  dir_bmpWheater :=  ExtractFilePath (Application.ExeName)+ 'bmp\Wheater\';

  SE_SearchFiles1.FromPath :=  ( dir_circuits );
  SE_SearchFiles1.MaskInclude.Add(  '*.ini');
  SE_SearchFiles1.Execute;

  while SE_SearchFiles1.SearchState <> ssIdle do begin
    application.ProcessMessages;
  end;

  cbCircuit.Clear;
  for I := 0 to SE_SearchFiles1.ListFiles.Count -1 do begin
    cbCircuit.Items.add (justNameL (SE_SearchFiles1.ListFiles[i]));
  end;
  cbCircuit.ItemIndex := 0;


  cbLaps.Items.Add('1');
  cbLaps.Items.Add('2');
  cbLaps.Items.Add('3');
  cbLaps.ItemIndex := 0;

  for I := 0 to 10 do begin
    cbHumanPlayers.Items.add ( IntTostr(i));
  end;
  cbHumanPlayers.ItemIndex := 1;
  for I := 0 to 10 do begin
    cbCPU.Items.add ( IntTostr(i));
  end;
  cbCPU.ItemIndex := 9;

  CarBmp[1].bmp := SE_Bitmap.Create ( dir_Cars + '1.bmp');
  CarBmp[2].bmp := SE_Bitmap.Create ( dir_Cars + '1.bmp');
  CarBmp[3].bmp := SE_Bitmap.Create ( dir_Cars + '3.bmp');
  CarBmp[4].bmp := SE_Bitmap.Create ( dir_Cars + '3.bmp');
  CarBmp[5].bmp := SE_Bitmap.Create ( dir_Cars + '5.bmp');
  CarBmp[6].bmp := SE_Bitmap.Create ( dir_Cars + '5.bmp');
  CarBmp[7].bmp := SE_Bitmap.Create ( dir_Cars + '7.bmp');
  CarBmp[8].bmp := SE_Bitmap.Create ( dir_Cars + '7.bmp');
  CarBmp[9].bmp := SE_Bitmap.Create ( dir_Cars + '9.bmp');
  CarBmp[10].bmp := SE_Bitmap.Create ( dir_Cars + '9.bmp');

  for I := Low (CarBmp) to High (CarBmp) do begin
    CarBmp[i].PosGrid := -1;
  end;

  CarBmp[1].PosGrid := 0;
  ResetCarColor;

end;
procedure TForm1.ResetSetupWheater;
var
  bmp : SE_bitmap;
begin
  SE_GridWheater.ClearData;   // importante anche pr memoryleak
  SE_GridWheater.DefaultColWidth := 51;
  SE_GridWheater.DefaultRowHeight := 24;
  SE_GridWheater.ColCount := 5;
  SE_GridWheater.RowCount := 1;
  SE_GridWheater.Columns[0].Width := 51;
  SE_GridWheater.Columns[1].Width := 51;
  SE_GridWheater.Columns[2].Width := 51;
  SE_GridWheater.Columns[3].Width := 51;
  SE_GridWheater.Columns[4].Width := 51;
  SE_GridWheater.Rows[0].Height := 24;

  SE_GridWheater.Height := 24;
  SE_GridWheater.Width := 51*5;


  bmp := SE_bitmap.Create ( dir_bmpWheater + '0.bmp' );
  bmp.Stretch(51,24);
  SE_GridWheater.AddSE_Bitmap ( 0, 0, 1 , bmp, false );
  bmp.Free;

  bmp := SE_bitmap.Create ( dir_bmpWheater + '1.bmp' );
  bmp.Stretch(51,24);
  SE_GridWheater.AddSE_Bitmap ( 1, 0, 1 , bmp, false );
  bmp.Free;

  bmp := SE_bitmap.Create ( dir_bmpWheater + '2.bmp' );
  bmp.Stretch(51,24);
  SE_GridWheater.AddSE_Bitmap ( 2, 0, 1 , bmp, false );
  bmp.Free;

  bmp := SE_bitmap.Create ( dir_bmpWheater + '3.bmp' );
  bmp.Stretch(51,24);
  SE_GridWheater.AddSE_Bitmap ( 3, 0, 1 , bmp, false );
  bmp.Free;

  bmp := SE_bitmap.Create ( dir_bmpWheater + 'r.bmp' );
  bmp.Stretch(51,24);
  SE_GridWheater.AddSE_Bitmap ( 4, 0, 1 , bmp, false );
  bmp.Free;

  SE_GridWheater.CellsEngine.ProcessSprites(20);
  SE_GridWheater.RefreshSurface ( SE_GridWheater );

end;
procedure TForm1.SelectSetupWheater ( Col : integer);
begin
  ResetSetupWheater;
  SE_GridWheater.Cells[Col,0].Bitmap.Bitmap.Canvas.Pen.Color := clRed;
  SE_GridWheater.Cells[Col,0].Bitmap.Bitmap.Canvas.MoveTo(0,0);
  SE_GridWheater.Cells[Col,0].Bitmap.Bitmap.Canvas.LineTo(50,0);
  SE_GridWheater.Cells[Col,0].Bitmap.Bitmap.Canvas.LineTo(50,23);
  SE_GridWheater.Cells[Col,0].Bitmap.Bitmap.Canvas.LineTo(0,23);
  SE_GridWheater.Cells[Col,0].Bitmap.Bitmap.Canvas.LineTo(0,0);
  SE_GridWheater.CellsEngine.ProcessSprites(20);
  SE_GridWheater.RefreshSurface ( SE_GridWheater );
end;
procedure TForm1.ResetSetupQual;
var
  bmp : SE_bitmap;
begin
  SE_GridQual.ClearData;   // importante anche pr memoryleak
  SE_GridQual.DefaultColWidth := 51;
  SE_GridQual.DefaultRowHeight := 24;
  SE_GridQual.ColCount := 2;
  SE_GridQual.RowCount := 1;
  SE_GridQual.Columns[0].Width := 51;
  SE_GridQual.Columns[1].Width := 51;
  SE_GridQual.Rows[0].Height := 24;

  SE_GridQual.Height := 24;
  SE_GridQual.Width := 51*2;


  bmp := SE_bitmap.Create ( dir_bmpWheater + 't.bmp' );
  bmp.Stretch(51,24);
  SE_GridQual.AddSE_Bitmap ( 0, 0, 1 , bmp, false );
  bmp.Free;

  bmp := SE_bitmap.Create ( dir_bmpWheater + 'r.bmp' );
  bmp.Stretch(51,24);
  SE_GridQual.AddSE_Bitmap ( 1, 0, 1 , bmp, false );
  bmp.Free;

  SE_GridQual.CellsEngine.ProcessSprites(20);
  SE_GridQual.RefreshSurface ( SE_GridQual );

end;
procedure TForm1.SelectSetupQual ( Col : integer);
begin
  ResetSetupQual;
  SE_GridQual.Cells[Col,0].Bitmap.Bitmap.Canvas.Pen.Color := clRed;
  SE_GridQual.Cells[Col,0].Bitmap.Bitmap.Canvas.MoveTo(0,0);
  SE_GridQual.Cells[Col,0].Bitmap.Bitmap.Canvas.LineTo(50,0);
  SE_GridQual.Cells[Col,0].Bitmap.Bitmap.Canvas.LineTo(50,23);
  SE_GridQual.Cells[Col,0].Bitmap.Bitmap.Canvas.LineTo(0,23);
  SE_GridQual.Cells[Col,0].Bitmap.Bitmap.Canvas.LineTo(0,0);
  SE_GridQual.CellsEngine.ProcessSprites(20);
  SE_GridQual.RefreshSurface ( SE_GridQual );
end;

procedure TForm1.SE_GridCarColorGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer; Sprite: SE_Sprite);
var
  ACarBmp : pTCarBmp;
begin
  // qui c'è il PickCar
  SE_GridCarColor.Visible := False;

  case CellY of
    0: SE_GridSetupPlayers.Cells[0, RowPlayer].Bitmap :=  CarBmp[1].bmp;
    1: SE_GridSetupPlayers.Cells[0, RowPlayer].Bitmap :=  CarBmp[3].bmp;
    2: SE_GridSetupPlayers.Cells[0, RowPlayer].Bitmap :=  CarBmp[5].bmp;
    3: SE_GridSetupPlayers.Cells[0, RowPlayer].Bitmap :=  CarBmp[7].bmp;
    4: SE_GridSetupPlayers.Cells[0, RowPlayer].Bitmap :=  CarBmp[9].bmp;
  end;

  SE_GridSetupPlayers.RefreshSurface ( SE_GridCarColor );


end;

procedure TForm1.SE_GridQualGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer; Sprite: SE_Sprite);
begin
  SelectSetupQual ( CellX );
end;

procedure TForm1.SE_GridSetupPlayersGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer; Sprite: SE_Sprite);
var
  i: Integer;
begin
  // click sulla cellGrid. è per forza presente una CarBmp
  // mostro i 5 possibili colori. non sono tenuto a scambiarle
  if CellX = 0 then begin
    RowPlayer := CellY;
    SE_GridCarColor.Visible := True;
    SE_GridCarColor.RefreshSurface ( SE_GridCarColor );
  end;

end;

procedure TForm1.SE_GridWheaterGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer;  Sprite: SE_Sprite);
begin
  SelectSetupWheater ( CellX );
end;
function TForm1.FindCarBmpPos ( Pos : Integer ): pTCarBmp;
var
  i: Integer;
begin
  Result := nil;
  for I := Low ( CarBmp ) to High ( CarBmp ) do begin
    if CarBmp[i].PosGrid = Pos then begin
      Result := @(CarBmp[i]);
      Exit;
    end;

  end;
end;
procedure TForm1.ResetCarColor;
var
  bmp : SE_bitmap;
begin
  SE_GridCarColor.ClearData;   // importante anche pr memoryleak
  SE_GridCarColor.DefaultColWidth := 51;
  SE_GridCarColor.DefaultRowHeight := 24;
  SE_GridCarColor.ColCount := 1;
  SE_GridCarColor.RowCount := 5;
  SE_GridCarColor.Columns[0].Width := 51;
  SE_GridCarColor.Rows[0].Height := 24;
  SE_GridCarColor.Rows[1].Height := 24;
  SE_GridCarColor.Rows[2].Height := 24;
  SE_GridCarColor.Rows[3].Height := 24;
  SE_GridCarColor.Rows[4].Height := 24;

  SE_GridCarColor.Height := 24*5;
  SE_GridCarColor.Width := 51;


  bmp := SE_bitmap.Create ( dir_Cars + '1.bmp' );
  bmp.Stretch(51,24);
  SE_GridCarColor.AddSE_Bitmap ( 0, 0, 1 , bmp, false );
  bmp.Free;

  bmp := SE_bitmap.Create ( dir_Cars + '3.bmp' );
  bmp.Stretch(51,24);
  SE_GridCarColor.AddSE_Bitmap ( 0, 1, 1 , bmp, false );
  bmp.Free;

  bmp := SE_bitmap.Create ( dir_Cars + '5.bmp' );
  bmp.Stretch(51,24);
  SE_GridCarColor.AddSE_Bitmap ( 0, 2, 1 , bmp, false );
  bmp.Free;

  bmp := SE_bitmap.Create ( dir_Cars + '7.bmp' );
  bmp.Stretch(51,24);
  SE_GridCarColor.AddSE_Bitmap ( 0, 3, 1 , bmp, false );
  bmp.Free;

  bmp := SE_bitmap.Create ( dir_Cars + '9.bmp' );
  bmp.Stretch(51,24);
  SE_GridCarColor.AddSE_Bitmap ( 0, 4, 1 , bmp, false );
  bmp.Free;

  SE_GridCarColor.CellsEngine.ProcessSprites(20);
  SE_GridCarColor.RefreshSurface ( SE_GridCarColor );

end;

end.
