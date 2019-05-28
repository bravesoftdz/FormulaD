unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, CnButtons, Vcl.ExtCtrls, DSE_Panel, Vcl.StdCtrls,
  DSE_Misc, DSE_theater, DSE_Bitmap, DSE_GRID, DSE_SearchFiles, OverbyteIcsWndControl, OverbyteIcsWSocket, OverbyteIcsWSocketS,
  OverbyteIcsWSocketTS ;

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
    SE_GridHumanPlayers: SE_Grid;
    SE_GridCPU: SE_Grid;
    lblQual: TLabel;
    SE_GridQual: SE_Grid;
    Tcpserver: TWSocketThrdServer;
    EdtPwd: TEdit;
    edtPort: TEdit;
    btnStartGame: TCnSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure btnCreateGameClick(Sender: TObject);
    procedure SE_GridWheaterGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer;
      Sprite: SE_Sprite);
    procedure SE_GridQualGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer;
      Sprite: SE_Sprite);
    procedure cbHumanPlayersCloseUp(Sender: TObject);
    procedure cbCPUCloseUp(Sender: TObject);
    procedure btnStartGameClick(Sender: TObject);
  private
    { Private declarations }
    procedure RefreshPlayerCPU;
    procedure ResetSetupWheater;
    procedure SelectSetupWheater ( Col : Integer );
    procedure ResetSetupQual;
    procedure SelectSetupQual ( Col : Integer );
  public
    { Public declarations }
  end;

  const EndofLine = 'ENDFD';
var
  Form1: TForm1;
  dir_bmpWheater, dir_Cars, dir_Circuits: string;
  CarBmp : array[1..10] of SE_Bitmap;
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


end;

procedure TForm1.btnStartGameClick(Sender: TObject);
begin
// quando tutti sono connessi
end;

procedure TForm1.cbCPUCloseUp(Sender: TObject);
begin
  cbHumanPlayers.ItemIndex := ( 10 -  StrToInt(cbCPU.Text) ) ;
  RefreshPlayerCPU;

end;

procedure TForm1.cbHumanPlayersCloseUp(Sender: TObject);
begin
  cbCPU.ItemIndex := ( 10 -  StrToInt(cbHumanPlayers.Text) ) ;
  RefreshPlayerCPU;

end;
procedure TForm1.RefreshPlayerCPU;
var
  i: Integer;
begin
//  Refresh Grid e Tcp

  // Grid HumanPlayers ----------------------------------------------------
  SE_GridHumanPlayers.ClearData;   // importante anche pr memoryleak
  SE_GridHumanPlayers.DefaultColWidth := 51;
  SE_GridHumanPlayers.DefaultRowHeight := 24;
  SE_GridHumanPlayers.ColCount := 2;
  SE_GridHumanPlayers.RowCount := StrtoInt ( cbHumanPlayers.text );
  SE_GridHumanPlayers.Columns[0].Width := 51;
  SE_GridHumanPlayers.Columns[1].Width := 160;


  for I := 0 to StrtoInt (cbHumanPlayers.text) -1 do begin
    SE_GridHumanPlayers.Rows[i].Height := 24;
    SE_GridHumanPlayers.Cells[1,i].Text  := 'Waiting for Tcp connection';
  end;

  SE_GridHumanPlayers.Height := 24 * StrtoInt (cbHumanPlayers.text) ;
  if SE_GridHumanPlayers.Height <= 0 then
     SE_GridHumanPlayers.Height :=1;

  SE_GridHumanPlayers.Width := 160+51;

  //----------------------------------------------------------------------

            // ----- Tcp refresh Grid players --------
        for I := 0 to Tcpserver.ClientCount -1 do begin
          if i <= StrtoInt ( cbHumanPlayers.text ) then begin
            SE_GridHumanPlayers.Cells[1,i+1].Text := Tcpserver.Client[i].UserName;
            SE_GridHumanPlayers.AddSE_Bitmap(0,i,1, CarBmp[i+1] ,true);
          end;
        end;

            // ---------------------------------------

  // Grid CPU ----------------------------------------------------
  SE_GridCPU.ClearData;   // importante anche pr memoryleak
  SE_GridCPU.DefaultColWidth := 51;
  SE_GridCPU.DefaultRowHeight := 24;
  SE_GridCPU.ColCount := 2;
  SE_GridCPU.RowCount := StrtoInt ( cbCPU.text );
  SE_GridCPU.Columns[0].Width := 51;
  SE_GridCPU.Columns[1].Width := 160;


  for I := 0 to StrtoInt (cbCPU.text) -1 do begin
    SE_GridCPU.Rows[i].Height := 24;
    SE_GridCPU.Cells[1,i].Text  := 'CPU' + IntToStr(i+1) ;
    SE_GridCPU.AddSE_Bitmap(0,i,1,CarBmp[i+1],true);
  end;

  SE_GridCPU.Height := 24 * StrtoInt (cbCPU.text) ;
  if SE_GridCPU.Height <= 0 then
     SE_GridCPU.Height :=1;

  SE_GridCPU.Width := 160+51;

  //----------------------------------------------------------------------

  SE_GridHumanPlayers.CellsEngine.ProcessSprites(20);
  SE_GridHumanPlayers.RefreshSurface ( SE_GridHumanPlayers );
  SE_GridCPU.CellsEngine.ProcessSprites(20);
  SE_GridCPU.RefreshSurface ( SE_GridCPU );

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

  CarBmp[1] := SE_Bitmap.Create ( dir_Cars + '1.bmp');
  CarBmp[2] := SE_Bitmap.Create ( dir_Cars + '1.bmp');
  CarBmp[3] := SE_Bitmap.Create ( dir_Cars + '3.bmp');
  CarBmp[4] := SE_Bitmap.Create ( dir_Cars + '3.bmp');
  CarBmp[5] := SE_Bitmap.Create ( dir_Cars + '5.bmp');
  CarBmp[6] := SE_Bitmap.Create ( dir_Cars + '5.bmp');
  CarBmp[7] := SE_Bitmap.Create ( dir_Cars + '7.bmp');
  CarBmp[8] := SE_Bitmap.Create ( dir_Cars + '7.bmp');
  CarBmp[9] := SE_Bitmap.Create ( dir_Cars + '9.bmp');
  CarBmp[10] := SE_Bitmap.Create ( dir_Cars + '9.bmp');

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

procedure TForm1.SE_GridQualGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer; Sprite: SE_Sprite);
begin
  SelectSetupQual ( CellX );
end;

procedure TForm1.SE_GridWheaterGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer;  Sprite: SE_Sprite);
begin
  SelectSetupWheater ( CellX );
end;

end.
