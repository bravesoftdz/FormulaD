unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, CnButtons, Vcl.ExtCtrls,Vcl.StdCtrls,
  StrUtils, IniFiles, System.Generics.Defaults, System.Generics.Collections,

  formulaDBrain,

  DSE_Panel,
  DSE_Misc,
  DSE_theater,
  DSE_Bitmap,
  DSE_GRID,
  DSE_SearchFiles,
  OverbyteIcsWndControl,
  OverbyteIcsWSocket,
  OverbyteIcsWSocketS,
  OverbyteIcsWSocketTS;


type TCarBmp = record
  Ids: String;
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
    SE_GridWeather: SE_Grid;
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
    btnStartServer: TCnSpeedButton;
    cbCarSetup: TComboBox;
    SE_Panel1: SE_Panel;
    tcp: TWSocket;
    Button1: TButton;
    WSocket1: TWSocket;
    WSocket2: TWSocket;
    WSocket3: TWSocket;
    WSocket4: TWSocket;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    lblServerPwd: TLabel;
    lblServerPort: TLabel;
    SE_EngineCars: SE_Engine;
    PanelCarSetup: SE_Panel;
    SE_GridCarSetup: SE_Grid;
    SE_Theater1: SE_Theater;
    SE_EngineBack: SE_Engine;
    btnCancelGame: TCnSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure btnCreateGameClick(Sender: TObject);
    procedure SE_GridWeatherGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer;
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
    procedure cbLapsCloseUp(Sender: TObject);
    procedure btnStartServerClick(Sender: TObject);
    procedure TcpserverClientConnect(Sender: TObject; Client: TWSocketClient; Error: Word);
    procedure TcpserverLineLimitExceeded(Sender: TObject; RcvdLength: Integer; var ClearData: Boolean);
    procedure TcpserverBgException(Sender: TObject; E: Exception; var CanClose: Boolean);
    procedure TcpserverClientDisconnect(Sender: TObject; Client: TWSocketClient; Error: Word);
    procedure TcpserverDataAvailable(Sender: TObject; ErrCode: Word);
    procedure Button1Click(Sender: TObject);
    procedure tcpSessionConnected(Sender: TObject; ErrCode: Word);
    procedure btnExitClick(Sender: TObject);
    procedure btnCancelGameClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    procedure RefreshPlayerCPU;
    procedure ResetSetupWeather;
    procedure SelectSetupWeather ( Col : Integer );
    procedure ResetSetupQual;
    procedure SelectSetupQual ( Col : Integer );
    procedure ResetCarColor;
    function FindCarBmpPos ( Pos : Integer ): pTCarBmp;
    procedure ConnectClient;

    procedure LoadCircuit ( CircuitName: string );
    procedure CarSpritesReset ( StartingGrid : Boolean );
  public
    { Public declarations }
  end;

  const EndofLine = 'ENDFD';

var
  Form1: TForm1;
  dir_bmpWeather, dir_Cars, dir_Circuits: string;
  CarBmp : array[1..10] of TCarBmp;
  RowPlayer: Integer; // per il cambio di colore
  Brain: TFormulaDBrain;
  mm : TMemoryStream;

implementation

{$R *.dfm}

function RemoveEndOfLine(const Line : String) : String;
begin
    if (Length(Line) >= Length(EndOfLine)) and
       (StrLComp(PChar(@Line[1 + Length(Line) - Length(EndOfLine)]),
                 PChar(EndOfLine),
                 Length(EndOfLine)) = 0) then
        Result := Copy(Line, 1, Length(Line) - Length(EndOfLine))
    else
        Result := Line;
end;
function IsStandardText(const aValue: string): Boolean; // accetta solo certi caratteri in input dal client
const
  CHARS = ['0'..'9', 'a'..'z', 'A'..'Z', ',', ':','=','.','_' ,'-' ];
var
  i: Integer;
  aString: string;
begin
  aString := aValue.Trim;
  for i := 1 to Length(aString) do begin
    if not (aString[i] in CHARS) then begin
      Result := False;
      Exit;
    end;
  end;
  Result := true;
end;

procedure TForm1.btnCancelGameClick(Sender: TObject);
begin
  Tcpserver.DisconnectAll;
  btnStartServer.Font.Color := clLime;
  btnStartServer.Caption := 'Start Server';
  cbHumanPlayers.Enabled := true;
  cbCPU.Enabled := true;
  lblHumanPlayers.Enabled := true;
  lblCPU.Enabled := True;
  btnStartGame.Enabled := False;
  Tcpserver.Close;
  PanelCreateGame.Visible:= False;
  PanelMain.Visible := True;
end;

procedure TForm1.btnCreateGameClick(Sender: TObject);
begin
  PanelCreateGame.Visible := True;
  PanelMain.Visible := False;
  SelectSetupWeather (4);
  SelectSetupQual (1);
  RefreshPlayerCPU;
end;

procedure TForm1.btnExitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm1.btnStartGameClick(Sender: TObject);
var
  aCar: TCar;
  i,r: Integer;
begin
// quando tutti sono connessi
  for r := 0 to StrToInt( cbHumanPlayers.Text ) -1 do begin     // cb punta alla gri. sono sempre per primi gli hp al contrario delle cpu
    for I := 0 to Tcpserver.ClientCount -1 do begin
      if TcpServer.Client[i].UserName =  SE_GridSetupPlayers.Cells[1,R].text then begin  // corrispondenza gridplayer e tcpClient, altrimenti Spectator
        aCar := TCar.Create;
        aCar.Guid := i ;
        aCar.CliId := TcpServer.Client[i].CliId;
        aCar.AI  := False;
        aCar.UserName := TcpServer.Client[i].UserName;
        aCar.Car := StrToInt( SE_GridSetupPlayers.Cells[0,R].ids );
        aCar.SE_Sprite := SE_EngineCars.CreateSprite ( dir_cars  + IntToStr(aCar.Car) + '.bmp', IntToStr(aCar.CliId),1,1,1000,0,0,true );
        aCar.box := aCar.Car;
        aCar.SE_Sprite.Scale := 86;
        aCar.SE_Sprite.Visible := False;

        brain.lsTCars.Add(aCar);

      end;

    end;
  end;

  for r := StrToInt( cbHumanPlayers.Text ) to SE_GridSetupPlayers.RowCount -1 do begin

        aCar := TCar.Create;
        aCar.Guid := r ;
        aCar.CliId := 0;
        aCar.AI := True;
        aCar.UserName := SE_GridSetupPlayers.Cells[0,r].Text;
        aCar.Car := StrToInt( SE_GridSetupPlayers.Cells[0,r].ids );
        aCar.SE_Sprite := SE_EngineCars.CreateSprite ( dir_cars  + IntToStr(aCar.Car) + '.bmp', aCar.UserName,1,1,1000,0,0,true );
        aCar.box := aCar.Car;
        aCar.SE_Sprite.Scale := 86;
        aCar.SE_Sprite.Visible := False;


        brain.lsTCars.Add(aCar);

  end;

  if Brain.lsTCars.Count = StrToInt( cbHumanPlayers.Text ) + StrToInt( cbCPU.Text ) then begin   // tutti connessi

    LoadCircuit (cbCircuit.text ) ; // le car sono già caricate anche come sprite

    if Brain.Qualifications = QualLap then begin

    end
    else if Brain.Qualifications = QualRnd then begin
      // random StartGrid
      Brain.CreateRndStartingGrid;

    for I := 0 to Tcpserver.ClientCount -1 do begin
        TcpServer.Client[i].SendStr( 'setupq' + EndOfLine );  // non può modificare nulla della macchina, ma viene mostrato il weather
    end;

      CarSpritesReset ( True ); // starting grid angle

      PanelCreateGame.Visible := False;
      SE_Theater1.Active := True;
      SE_Theater1.Visible := True;
    end;
  end;
end;
procedure TForm1.CarSpritesReset ( StartingGrid : Boolean );
var
  i,StartAngle: Integer;
  ini : TIniFile;
begin
  if StartingGrid then begin
    ini := TIniFile.Create( dir_circuits + Brain.CircuitDescr.Name + '.ini' );
    brain.CircuitDescr.CarAngle := ini.ReadInteger('setup','CarAngle',0);
    ini.Free;
  end;

  for I := 0 to brain.lstCars.Count -1 do begin
    Brain.lstCars[i].SE_Sprite.PositionX := Brain.lstCars[i].Cell.PixelX;
    Brain.lstCars[i].SE_Sprite.PositionY := Brain.lstCars[i].Cell.PixelY;
    if StartingGrid then begin
      Brain.lstCars[i].SE_Sprite.Angle := brain.CircuitDescr.CarAngle;
    end;
    Brain.lstCars[i].SE_Sprite.Visible := True;
  end;
end;

procedure TForm1.btnStartServerClick(Sender: TObject);
begin

  if btnStartServer.Caption = 'Start Server' then begin
    TcpServer.Port :=  edtPort.Text ;
    TcpServer.LineMode            := true;
    TcpServer.LineEdit            := false;
    TcpServer.LineEnd             := EndOfLine;
    TcpServer.LineLimit           := 1024;
    TcpServer.Addr                := '0.0.0.0';
    TcpServer.MaxClients          := StrToInt(cbHumanPlayers.text);
    TcpServer.Listen ;
    btnStartServer.Font.Color := clRed;
    btnStartServer.Caption := 'Stop Server';
    cbHumanPlayers.Enabled := False;
    cbCPU.Enabled := False;
    lblHumanPlayers.Enabled := False;
    lblCPU.Enabled := False;

    ConnectClient;

  end
  else begin
    TcpServer.DisconnectAll;
    Tcpserver.Close;
    btnStartServer.Font.Color := clLime;
    btnStartServer.Caption := 'Start Server';
    cbHumanPlayers.Enabled := true;
    cbCPU.Enabled := true;
    lblHumanPlayers.Enabled := true;
    lblCPU.Enabled := True;
    btnStartGame.Enabled := False;
  end;
end;
procedure TForm1.ConnectClient;
begin
  tcp.Addr := '127.0.0.1';
  Tcp.Port := EdtPort.Text;

  tcp.LineMode := true;
  tcp.LineLimit := 8192;
  tcp.LineEdit  := false;
  tcp.LineEnd := EndOfLine;
  tcp.LingerOnOff := wsLingerOn;
  Tcp.Connect;

end;
procedure TForm1.Button1Click(Sender: TObject);
var
  c: TWsocket;
begin

    if LeftStr ( TButton(Sender).Caption ,3) = 'Con'  then begin
      TButton(Sender).Caption := 'Disconnect client ' + IntToStr(TButton(Sender).Tag);
      c:= FindComponent( 'WSocket' + IntToStr(  TButton(Sender).Tag ) ) as TWsocket;
      c.Addr := '127.0.0.1';
      c.Port := EdtPort.Text;

      c.LineMode := true;
      c.LineLimit := 8192;
      c.LineEdit  := false;
      c.LineEnd := EndOfLine;
      c.LingerOnOff := wsLingerOn;
      c.Connect;
   end
   else if LeftStr ( TButton(Sender).Caption ,3) = 'Dis' then begin
      TButton(Sender).Caption := 'Connect client ' + IntToStr(TButton(Sender).Tag);
      c:= FindComponent( 'WSocket' + IntToStr(  TButton(Sender).Tag ) ) as TWsocket;
      c.Close;
   end;

end;

procedure TForm1.cbCPUCloseUp(Sender: TObject);
begin
  if (StrToInt(cbHumanPlayers.Text) + StrToInt(cbCPU.Text) ) > 10 then
    cbHumanPlayers.ItemIndex := ( 10 -  StrToInt(cbCPU.Text) ) ;

  RefreshPlayerCPU;

end;

procedure TForm1.cbHumanPlayersCloseUp(Sender: TObject);
begin
  if (StrToInt(cbHumanPlayers.Text) + StrToInt(cbCPU.Text) ) > 10 then
    cbCPU.ItemIndex := ( 10 -  StrToInt(cbHumanPlayers.Text) ) ;

    RefreshPlayerCPU;

end;
procedure TForm1.cbLapsCloseUp(Sender: TObject);
begin
  cbCarSetup.Clear;

  if (cbLaps.Text = '1') or (cbLaps.Text ='2') then begin
    cbCarSetup.Items.Add( 'Preset');  // x1 x2  lap        4-3-2-2-2 2m  6-4-3-3-3 2m
    cbCarSetup.Items.Add( 'Setup Free 18 Points');  // x1 x2  lap
  end
  else if cbLaps.Text = '3' then begin
    cbCarSetup.Items.Add( 'Setup 20 Points limit 14/7');
  end;
  cbCarSetup.ItemIndex := 0;


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
    SE_GridSetupPlayers.Cells[1,i].Guid := 0;

    if i < StrtoInt ( cbHumanPlayers.text ) then begin
      SE_GridSetupPlayers.Cells[1,i].FontColor := clYellow;
      SE_GridSetupPlayers.Cells[1,i].Text  := 'Waiting for Tcp connection'
    end
      else SE_GridSetupPlayers.Cells[1,i].Text  := 'CPU' + IntToStr(I+1);

    aCarBmp:= FindCarbmpPos ( i );

    if aCarBmp = nil then  begin                    // se ancora non è assegnata
      aCarBmp:= FindCarbmpPos ( -1 );                           // cerco la prima libera con valore -1
      aCarBmp.PosGrid := i;
      SE_GridSetupPlayers.AddSE_Bitmap(0,i,1,aCarBmp.bmp ,true);
      SE_GridSetupPlayers.Cells[0,i].ids := aCarBmp.Ids;
    end
    else begin
      if aCarBmp.PosGrid > -1 then begin                               // se la car è già assegnata alla row
        SE_GridSetupPlayers.AddSE_Bitmap(0,i,1,aCarBmp.bmp ,true);
        SE_GridSetupPlayers.Cells[0,i].ids := aCarBmp.Ids;
      end;
    end;
  end;
  SE_GridSetupPlayers.Height := 24 * TotRow ;
  if SE_GridSetupPlayers.Height <= 0 then
     SE_GridSetupPlayers.Height :=1;

  SE_GridSetupPlayers.Width := 160+51;

  SE_GridSetupPlayers.CellsEngine.ProcessSprites(20);
  SE_GridSetupPlayers.RefreshSurface ( SE_GridSetupPlayers );

end;
procedure TForm1.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  SE_Theater1.Left:=0;
  SE_Theater1.Top:=0;
  SE_Theater1.Width := Form1.Width;
  SE_Theater1.height := Form1.Height;
  SE_Theater1.Visible := False;

  mm := TMemoryStream.Create;
  Brain := TFormulaDBrain.Create;

  dir_cars :=  ExtractFilePath (Application.ExeName)+ 'bmp\cars\';
  dir_Circuits := ExtractFilePath (Application.ExeName)+'circuits\';
  dir_bmpWeather :=  ExtractFilePath (Application.ExeName)+ 'bmp\Weather\';

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

  for I := 1 to 10 do begin
    cbHumanPlayers.Items.add ( IntTostr(i));
  end;
  cbHumanPlayers.ItemIndex := 0;
  for I := 0 to 9 do begin
    cbCPU.Items.add ( IntTostr(i));
  end;
  cbCPU.ItemIndex := 9;

  CarBmp[1].bmp := SE_Bitmap.Create ( dir_Cars + '1.bmp');
  CarBmp[2].bmp := SE_Bitmap.Create ( dir_Cars + '1.bmp');
  CarBmp[3].bmp := SE_Bitmap.Create ( dir_Cars + '2.bmp');
  CarBmp[4].bmp := SE_Bitmap.Create ( dir_Cars + '2.bmp');
  CarBmp[5].bmp := SE_Bitmap.Create ( dir_Cars + '3.bmp');
  CarBmp[6].bmp := SE_Bitmap.Create ( dir_Cars + '3.bmp');
  CarBmp[7].bmp := SE_Bitmap.Create ( dir_Cars + '4.bmp');
  CarBmp[8].bmp := SE_Bitmap.Create ( dir_Cars + '4.bmp');
  CarBmp[9].bmp := SE_Bitmap.Create ( dir_Cars + '5.bmp');
  CarBmp[10].bmp := SE_Bitmap.Create ( dir_Cars + '5.bmp');

  for I := Low (CarBmp) to High (CarBmp) do begin
    CarBmp[i].PosGrid := -1;
  end;

  CarBmp[1].PosGrid := 0;

  CarBmp[1].Ids := '1';
  CarBmp[2].Ids := '1';
  CarBmp[3].Ids := '2';
  CarBmp[4].Ids := '2';
  CarBmp[5].Ids := '3';
  CarBmp[6].Ids := '3';
  CarBmp[7].Ids := '4';
  CarBmp[8].Ids := '4';
  CarBmp[9].Ids := '5';
  CarBmp[10].Ids := '5';


  ResetCarColor;

  cbCarSetup.Items.Add( 'Preset');  // x1 x2  lap        4-3-2-2-2 2m  6-4-3-3-3 2m
  cbCarSetup.Items.Add( 'Setup Free 18 Points');  // x1 x2  lap
  cbCarSetup.ItemIndex := 0;

  Brain := TFormulaDBrain.Create;

end;
procedure TForm1.FormDestroy(Sender: TObject);
begin
  mm.Free;
  Brain.Free;
end;

procedure TForm1.ResetSetupWeather;
var
  bmp : SE_bitmap;
begin
  SE_GridWeather.ClearData;   // importante anche pr memoryleak
  SE_GridWeather.DefaultColWidth := 51;
  SE_GridWeather.DefaultRowHeight := 24;
  SE_GridWeather.ColCount := 5;
  SE_GridWeather.RowCount := 1;
  SE_GridWeather.Columns[0].Width := 51;
  SE_GridWeather.Columns[1].Width := 51;
  SE_GridWeather.Columns[2].Width := 51;
  SE_GridWeather.Columns[3].Width := 51;
  SE_GridWeather.Columns[4].Width := 51;
  SE_GridWeather.Rows[0].Height := 24;

  SE_GridWeather.Height := 24;
  SE_GridWeather.Width := 51*5;


  bmp := SE_bitmap.Create ( dir_bmpWeather + '0.bmp' );
  bmp.Stretch(51,24);
  SE_GridWeather.AddSE_Bitmap ( 0, 0, 1 , bmp, false );
  bmp.Free;

  bmp := SE_bitmap.Create ( dir_bmpWeather + '1.bmp' );
  bmp.Stretch(51,24);
  SE_GridWeather.AddSE_Bitmap ( 1, 0, 1 , bmp, false );
  bmp.Free;

  bmp := SE_bitmap.Create ( dir_bmpWeather + '2.bmp' );
  bmp.Stretch(51,24);
  SE_GridWeather.AddSE_Bitmap ( 2, 0, 1 , bmp, false );
  bmp.Free;

  bmp := SE_bitmap.Create ( dir_bmpWeather + '3.bmp' );
  bmp.Stretch(51,24);
  SE_GridWeather.AddSE_Bitmap ( 3, 0, 1 , bmp, false );
  bmp.Free;

  bmp := SE_bitmap.Create ( dir_bmpWeather + 'r.bmp' );
  bmp.Stretch(51,24);
  SE_GridWeather.AddSE_Bitmap ( 4, 0, 1 , bmp, false );
  bmp.Free;

  SE_GridWeather.CellsEngine.ProcessSprites(20);
  SE_GridWeather.RefreshSurface ( SE_GridWeather );

end;
procedure TForm1.SelectSetupWeather ( Col : integer);
begin
  ResetSetupWeather;
  SE_GridWeather.Cells[Col,0].Bitmap.Bitmap.Canvas.Pen.Color := clRed;
  SE_GridWeather.Cells[Col,0].Bitmap.Bitmap.Canvas.MoveTo(0,0);
  SE_GridWeather.Cells[Col,0].Bitmap.Bitmap.Canvas.LineTo(50,0);
  SE_GridWeather.Cells[Col,0].Bitmap.Bitmap.Canvas.LineTo(50,23);
  SE_GridWeather.Cells[Col,0].Bitmap.Bitmap.Canvas.LineTo(0,23);
  SE_GridWeather.Cells[Col,0].Bitmap.Bitmap.Canvas.LineTo(0,0);
  SE_GridWeather.CellsEngine.ProcessSprites(20);
  SE_GridWeather.RefreshSurface ( SE_GridWeather );

  if Col = 4 then
    Brain.Weather := Brain.rndGenerate0 ( 4 )
    else Brain.Weather := Col;
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


  bmp := SE_bitmap.Create ( dir_bmpWeather + 't.bmp' );
  bmp.Stretch(51,24);
  SE_GridQual.AddSE_Bitmap ( 0, 0, 1 , bmp, false );
  bmp.Free;

  bmp := SE_bitmap.Create ( dir_bmpWeather + 'r.bmp' );
  bmp.Stretch(51,24);
  SE_GridQual.AddSE_Bitmap ( 1, 0, 1 , bmp, false );
  bmp.Free;

  SE_GridQual.CellsEngine.ProcessSprites(20);
  SE_GridQual.RefreshSurface ( SE_GridQual );

end;
procedure TForm1.SelectSetupQual ( Col : integer);  // Disegno un bordo rosso
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

  if Col = 0 then Brain.Qualifications:= QualLap
    else Brain.Qualifications:= QualRnd;

end;

procedure TForm1.SE_GridCarColorGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer; Sprite: SE_Sprite);
begin
  // qui c'è il PickCar
  SE_GridCarColor.Visible := False;

  case CellY of
    0: begin SE_GridSetupPlayers.Cells[0, RowPlayer].Bitmap :=  CarBmp[1].bmp; end;
    1: begin SE_GridSetupPlayers.Cells[0, RowPlayer].Bitmap :=  CarBmp[3].bmp; end;
    2: begin SE_GridSetupPlayers.Cells[0, RowPlayer].Bitmap :=  CarBmp[5].bmp; end;
    3: begin SE_GridSetupPlayers.Cells[0, RowPlayer].Bitmap :=  CarBmp[7].bmp; end;
    4: begin SE_GridSetupPlayers.Cells[0, RowPlayer].Bitmap :=  CarBmp[9].bmp; end;
  end;
  SE_GridSetupPlayers.Cells[0, RowPlayer].Ids := SE_GridCarColor.cells[0,CellY].ids;

  SE_GridSetupPlayers.RefreshSurface ( SE_GridCarColor );


end;

procedure TForm1.SE_GridQualGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer; Sprite: SE_Sprite);
begin
  SelectSetupQual ( CellX );
end;

procedure TForm1.SE_GridSetupPlayersGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer; Sprite: SE_Sprite);
begin
  // click sulla cellGrid. è per forza presente una CarBmp
  // mostro i 5 possibili colori. non sono tenuto a scambiarle
  if CellX = 0 then begin
    RowPlayer := CellY;
    SE_GridCarColor.Visible := True;
    SE_GridCarColor.RefreshSurface ( SE_GridCarColor );
  end;

end;

procedure TForm1.SE_GridWeatherGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer;  Sprite: SE_Sprite);
begin
  SelectSetupWeather ( CellX );
end;
procedure TForm1.TcpserverBgException(Sender: TObject; E: Exception; var CanClose: Boolean);
begin
//
end;

procedure TForm1.TcpserverClientConnect(Sender: TObject; Client: TWSocketClient; Error: Word);
begin
    if TcpServer.ClientCount > TcpServer.MaxClients then begin
     Client.CloseDelayed ;
     Exit;
    end;
    Client.LastTickCount       := 0;  // a mezzanotte ....bug
    Client.LineMode            := TRUE;
    Client.LineEnd             := EndOfLine;
    Client.LineEdit            := false;
    Client.LineLimit           := 1024;
    Client.OnDataAvailable     := TcpServerDataAvailable;
    Client.OnLineLimitExceeded := TcpServerLineLimitExceeded;
    Client.OnBgException       := TcpServerBgException;


end;

procedure TForm1.TcpserverClientDisconnect(Sender: TObject; Client: TWSocketClient; Error: Word);
var
  i: Integer;
begin


    for I := 0 to StrToInt (cbHumanPlayers.text)  -1 do begin
      if SE_GridSetupPlayers.Cells[1,i].Guid = Client.CliId then begin
        Client.UserName := '';
        SE_GridSetupPlayers.Cells[1,i].Guid := 0;
        SE_GridSetupPlayers.Cells[1,i].FontColor := clYellow;
        SE_GridSetupPlayers.Cells[1,i].Text := 'Waiting for connection';
        SE_GridSetupPlayers.refreshSurface (SE_GridSetupPlayers) ;
        Break;
      end;
    end;

    for I := 0 to StrToInt (cbHumanPlayers.text)  -1 do begin
      if SE_GridSetupPlayers.Cells[1,i].Guid = 0 then
        Exit;
    end;

    // se non è uscito con exit sopra, ci sono tutti i client collegati
    btnStartGame.Enabled := True;



end;

procedure TForm1.TcpserverDataAvailable(Sender: TObject; ErrCode: Word);
var
    Cli: TWSocketThrdClient;
    RcvdLine: string;
    ts: TStringList;
    i: Integer;
begin
  Cli := Sender as TWSocketThrdClient;


  RcvdLine :=  RemoveEndOfLine  (Cli.ReceiveStr);
  Cli.Processing := True;
  ts:= TStringList.Create;
  ts.StrictDelimiter := True;
  ts.CommaText := RcvdLine;


  {$IFDEF  useMemo}
  if memo1.Lines.Count > 300 then
    memo1.Lines.Clear;
  if Length(RcvdLine) = 0 then  Exit;
  Display('Received from ' + Cli.GetPeerAddr  + ': ''' + RcvdLine + '''');
  {$ENDIF  useMemo}

  if not IsStandardText ( RcvdLine ) then begin
    ts.Free;
    exit;
  end;

  if ts.Count < 1 then begin
    ts.Free;
    exit;
  end;


  if ts[0] ='login' then begin
    if ts.Count <> 3 then begin
      ts.Free;
      exit;
    end;
    if ts[2] <> EdtPwd.text then begin
      ts.Free;
      exit;
    end;

    for I := 0 to StrToInt (cbHumanPlayers.text)  -1 do begin
      if SE_GridSetupPlayers.Cells[1,i].Guid = 0 then begin
        Cli.UserName := ts[1];
        SE_GridSetupPlayers.Cells[1,i].Guid := Cli.CliId;
        SE_GridSetupPlayers.Cells[1,i].Text := Cli.UserName;
        SE_GridSetupPlayers.Cells[1,i].FontColor := clWhite;
        SE_GridSetupPlayers.refreshSurface (SE_GridSetupPlayers) ;
        Break;
      end;
    end;

    for I := 0 to StrToInt (cbHumanPlayers.text)  -1 do begin
      if SE_GridSetupPlayers.Cells[1,i].Guid = 0 then
        Exit;
    end;

    // se non è uscito con exit sopra, ci sono tutti i client collegati
    btnStartGame.Enabled := True;
  end;


end;

procedure TForm1.TcpserverLineLimitExceeded(Sender: TObject; RcvdLength: Integer; var ClearData: Boolean);
begin
//
end;

procedure TForm1.tcpSessionConnected(Sender: TObject; ErrCode: Word);
begin
  TWSocketClient(Sender).SendStr( 'login,'+ TWSocket(Sender).Name + ',' + EdtPwd.text + EndOfLine);
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
  SE_GridCarColor.Cells[0,0].ids := '1';
  bmp.Free;

  bmp := SE_bitmap.Create ( dir_Cars + '2.bmp' );
  bmp.Stretch(51,24);
  SE_GridCarColor.AddSE_Bitmap ( 0, 1, 1 , bmp, false );
  SE_GridCarColor.Cells[0,1].ids := '2';
  bmp.Free;

  bmp := SE_bitmap.Create ( dir_Cars + '3.bmp' );
  bmp.Stretch(51,24);
  SE_GridCarColor.AddSE_Bitmap ( 0, 2, 1 , bmp, false );
  SE_GridCarColor.Cells[0,2].ids := '3';
  bmp.Free;

  bmp := SE_bitmap.Create ( dir_Cars + '4.bmp' );
  bmp.Stretch(51,24);
  SE_GridCarColor.AddSE_Bitmap ( 0, 3, 1 , bmp, false );
  SE_GridCarColor.Cells[0,4].ids := '3';
  bmp.Free;

  bmp := SE_bitmap.Create ( dir_Cars + '5.bmp' );
  bmp.Stretch(51,24);
  SE_GridCarColor.AddSE_Bitmap ( 0, 4, 1 , bmp, false );
  SE_GridCarColor.Cells[0,4].ids := '5';
  bmp.Free;

  SE_GridCarColor.CellsEngine.ProcessSprites(20);
  SE_GridCarColor.RefreshSurface ( SE_GridCarColor );

end;
procedure TForm1.LoadCircuit ( CircuitName: string );
var
  ini : TIniFile;
  TotCells,tmpSmallInt: SmallInt;
  i,L,a,count: Integer;
  aCell: TCell;
  TotLinkForward, TotAdjacent, tmpb: Byte;
  aSprite: SE_Sprite;
begin
  brain.Circuit.clear;

  ini := TIniFile.Create( dir_circuits + CircuitName + '.ini' );
  brain.CircuitDescr.Name := ini.ReadString('setup','Name','');
  brain.CircuitDescr.Corners := ini.ReadInteger('setup','Corners',0);
  ini.Free;

  mm.LoadFromFile(  dir_circuits + CircuitName + '.fd' );
  mm.Position := 0;
  mm.Read ( TotCells, SizeOf(SmallInt) );
  for I := 0 to TotCells -1 do begin
    aCell := TCell.Create;
    mm.Read( aCell.Guid , SizeOf(SmallInt) );
    mm.Read( aCell.Lane , SizeOf(ShortInt) );
    mm.Read( aCell.Corner , SizeOf(Byte) );
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
      mm.Read( tmpB , SizeOf(Byte) );
      aCell.LinkForward.add ( tmpB );
    end;
    mm.Read( TotAdjacent, SizeOf(Byte) );
    for A := 0 to TotAdjacent -1 do begin
      mm.Read( tmpB , SizeOf(Byte) );
      aCell.Adjacent.add ( tmpB );
    end;

    brain.Circuit.Add(aCell);
  end;

  aSprite := SE_Sprite.Create (dir_circuits + CircuitName +'.bmp','circuit',1,1,1000,0,0,false );

  for i := 0 to SE_Theater1.EngineCount -1 do begin
    SE_Theater1.Engines [i].RemoveAllSprites;
  end;

  SE_Theater1.VirtualWidth := aSprite.BMP.Width;
  SE_Theater1.VirtualHeight := aSprite.BMP.Height;

  SE_EngineBack.AddSprite( aSprite );
  aSprite.Position := Point (  SE_Theater1.VirtualWidth div 2 , SE_Theater1.Virtualheight div 2  );

end;


end.
