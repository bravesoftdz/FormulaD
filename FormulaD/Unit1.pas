unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, CnButtons, Vcl.ExtCtrls,Vcl.StdCtrls,
  StrUtils, IniFiles, System.Generics.Defaults, System.Generics.Collections,

  formulaDBrain,

  ZLIBEX,

  DSE_Panel,
  DSE_Misc,
  DSE_theater,
  DSE_Bitmap,
  DSE_GRID,
  DSE_SearchFiles,
  OverbyteIcsWndControl,
  OverbyteIcsWSocket,
  OverbyteIcsWSocketS,
  OverbyteIcsWSocketTS, DSE_ThreadTimer;


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
    SE_Theater1: SE_Theater;
    SE_EngineBack: SE_Engine;
    btnCancelGame: TCnSpeedButton;
    ThreadCurMove: SE_ThreadTimer;
    SE_EngineCells: SE_Engine;
    procedure FormCreate(Sender: TObject);
    procedure btnCreateGameClick(Sender: TObject);
    procedure btnStartServerClick(Sender: TObject);
    procedure btnStartGameClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnCancelGameClick(Sender: TObject);

    procedure cbHumanPlayersCloseUp(Sender: TObject);
    procedure cbCPUCloseUp(Sender: TObject);
    procedure cbLapsCloseUp(Sender: TObject);
    procedure SE_GridQualGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer; Sprite: SE_Sprite);
    procedure SE_GridSetupPlayersGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer; Sprite: SE_Sprite);
    procedure SE_GridCarColorGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer; Sprite: SE_Sprite);


    procedure TcpserverClientConnect(Sender: TObject; Client: TWSocketClient; Error: Word);
    procedure TcpserverLineLimitExceeded(Sender: TObject; RcvdLength: Integer; var ClearData: Boolean);
    procedure TcpserverBgException(Sender: TObject; E: Exception; var CanClose: Boolean);
    procedure TcpserverClientDisconnect(Sender: TObject; Client: TWSocketClient; Error: Word);
    procedure TcpserverDataAvailable(Sender: TObject; ErrCode: Word);


        function validate_and_WriteSetupCar (  Cli: TWSocketThrdClient;  Commatext : string ):Boolean;
        procedure LoadCarRndPreset ( aCar : TCar );

    procedure tcpSessionConnected(Sender: TObject; ErrCode: Word);
    procedure tcpDataAvailable(Sender: TObject; ErrCode: Word);

    procedure FormDestroy(Sender: TObject);
    procedure SE_Theater1SpriteMouseMove(Sender: TObject; lstSprite: TObjectList<DSE_theater.SE_Sprite>; Shift: TShiftState;
      var Handled: Boolean);
    procedure SE_EngineCarsSpriteDestinationReached(ASprite: SE_Sprite);
    procedure ThreadCurMoveTimer(Sender: TObject);
    procedure SE_Theater1SpriteMouseDown(Sender: TObject; lstSprite: TObjectList<DSE_theater.SE_Sprite>; Button: TMouseButton;
      Shift: TShiftState);
  private
    { Private declarations }
    procedure RefreshPlayerCPU;
    procedure SetWeather (aGridWeather: Se_grid; Col : Integer );
    procedure ResetSetupQual;
    procedure SelectSetupQual ( Col : Integer );
    procedure ResetCarColor;
    function FindCarBmpPos ( Pos : Integer ): pTCarBmp;
    procedure ConnectClient;

    function GetbrainStream ( brain: TFormulaDBrain) : string;
    procedure LoadCircuit ( CircuitName: string );
    procedure LoadBrain   ( incMove: Byte; FirstTime: boolean );
    function GetCell ( Guid : SmallInt ) : TCell;
    procedure CarSpritesReset ( StartingGrid : Boolean );
  public
    { Public declarations }
    procedure ResetSetupWeather  ( aGridWeather: Se_grid);
    procedure InitializeCar ( aCar : Tcar );
    procedure StartQualifications;
    procedure StartRace;
  end;

  const EndofLine = 'ENDFD';
  type TArray8192 = array [0..8191] of AnsiChar; // i buf[0..255] of  TArray8192 contengono il buffer Tcp in entrata

var
  Form1: TForm1;
  dir_tmp, dir_bmpWeather, dir_Cars, dir_Circuits: string;
  CarBmp : array[1..10] of TCarBmp;
  RowPlayer: Integer; // per il cambio di colore
  Brain: TFormulaDBrain;
  mm : TMemoryStream;

  FirstLoadOK: Boolean; // Primo caricamento della partita avvenuto. Avviene anche durante un reconnect
  Buf3 : array [0..255] of TArray8192;    // array globali. vengono riempiti in Tcp.dataavailable. una partita non va oltre 255 turni, di solito 120 + recupero
  MM3 : array [0..255] of TMemoryStream;  // copia di cui sopra ma in formato stream, per un accesso rapido a certe informazioni

  MyCarAccount,LastTcpincMove,CurrentIncMove: byte;
  BmpTiresDry, BmpTiresWet, bmpPlus, bmpMinus : SE_Bitmap;

implementation
uses Unit3;
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
  Brain.Laps := StrToInt( cblaps.text );
  LoadCircuit ( cbCircuit.text ) ; // le car sono già caricate anche come sprite

  for r := 0 to StrToInt( cbHumanPlayers.Text ) -1 do begin     // cb punta alla gri. sono sempre per primi gli hp al contrario delle cpu
    for I := 0 to Tcpserver.ClientCount -1 do begin
      if TcpServer.Client[i].UserName =  SE_GridSetupPlayers.Cells[1,R].text then begin  // corrispondenza gridplayer e tcpClient, altrimenti Spectator
        aCar := TCar.Create;
        aCar.Guid := i ;
        TcpServer.Client[i].Account := aCar.Guid; // -->
        aCar.CliId := TcpServer.Client[i].CliId;
        aCar.AI  := False;
        aCar.UserName := TcpServer.Client[i].UserName;
        aCar.CarColor := StrToInt( SE_GridSetupPlayers.Cells[0,R].ids );
        aCar.box := aCar.CarColor;
        aCar.cell := Brain.Circuit[0]; // lo metto in una cella qualunque invisibile

        InitializeCar ( aCar );


        brain.lsTCars.Add(aCar);

      end;

    end;
  end;

  for r := StrToInt( cbHumanPlayers.Text ) to SE_GridSetupPlayers.RowCount -1 do begin

        aCar := TCar.Create;
        aCar.Guid := r ;
        aCar.CliId := 0;
        aCar.AI := True;
        aCar.UserName := SE_GridSetupPlayers.Cells[1,r].Text;
        aCar.CarColor := StrToInt( SE_GridSetupPlayers.Cells[0,r].ids );
        aCar.box := aCar.CarColor;
        aCar.cell := Brain.Circuit[0]; // lo metto in una cella qualunque invisibile

        InitializeCar ( aCar );

        brain.lsTCars.Add(aCar);

  end;

  if Brain.lsTCars.Count = StrToInt( cbHumanPlayers.Text ) + StrToInt( cbCPU.Text ) then begin   // tutti connessi

   // LoadCircuit ( cbCircuit.text ) ; // le car sono già caricate anche come sprite
    PanelCreateGame.Visible := False; //<-- solo per il server
    Brain.Weather := Brain.rndGenerate0 ( 3 );
    case Brain.Weather of
      0: Brain.Track :=0;
      1: Brain.Track :=0;
      2: Brain.Track :=0;
      3: Brain.Track :=1;
    end;

    if Brain.Qualifications = QualLap then begin
      Brain.ServerIncMove := 0;
      Brain.Stage := StageSetupQ;
    end
    else if Brain.Qualifications = QualRnd then begin
      // random StartGrid
      Brain.CreateRndStartingGrid;
      Brain.ServerIncMove := 0;
      Brain.Stage := StageSetupRace; // prima qui poi alla gara
//      Brain.Stage := StageRace;

    end;

    Brain.CarSetupPoints :=  StrToInt(LeftStr( cbCarSetup.Text,2)); // setup car Points

    Brain.SaveData ( Brain.ServerIncMove ) ;
    for I := 0 to Tcpserver.ClientCount -1 do begin
        { TODO : ansichar dovrà occuparsi di un valore più alto di 255, diventa smallint }
        TcpServer.Client[i].SendStr( 'BEGINBRAIN'  + AnsiChar (  Brain.ServerIncMove  )
                                                   + AnsiChar (  tcpserver.Client[i].Account )
                                                   + GetbrainStream ( brain ) +  EndOfLine );
    end;
    Brain.ServerIncMove := Brain.ServerIncMove + 1;

  end;
end;
procedure TForm1.InitializeCar ( aCar : Tcar );
begin
  aCar.TiresType := 0;

  aCar.Tires := 1;
  aCar.Brakes := 1;
  aCar.Gear:= 1;
  aCar.Body := 1;
  aCar.Engine := 1;
  aCar.Suspension := 1;

  if Brain.CarSetupPoints = 15 then begin

    aCar.TiresMax := 9;
    aCar.BrakesMax := 9;
    aCar.GearMax:= 9;
    aCar.BodyMax := 9;
    aCar.EngineMax := 9;
    aCar.SuspensionMax := 9;

  end
  else if Brain.CarSetupPoints = 18 then begin

    aCar.TiresMax := 12;
    aCar.BrakesMax := 12;
    aCar.GearMax:= 12;
    aCar.BodyMax := 12;
    aCar.EngineMax := 12;
    aCar.SuspensionMax := 12;

  end
  else if Brain.CarSetupPoints = 20 then begin

    aCar.TiresMax := 14;
    aCar.BrakesMax := 7;
    aCar.GearMax:= 7;
    aCar.BodyMax := 7;
    aCar.EngineMax := 7;
    aCar.SuspensionMax := 7;

  end

end;
procedure TForm1.CarSpritesReset ( StartingGrid : Boolean );
var
  i,StartAngle: Integer;
begin

  for I := 0 to brain.lstCars.Count -1 do begin
    Brain.lstCars[i].SE_Sprite.PositionX := Brain.lstCars[i].Cell.PixelX;
    Brain.lstCars[i].SE_Sprite.PositionY := Brain.lstCars[i].Cell.PixelY;
    Brain.lstCars[i].SE_Sprite.Angle := Brain.lstCars[i].Cell.Angle;

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
  { TODO : per il momento no AI }
  cbCPU.ItemIndex := 0;
  Exit;
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

  if (cbLaps.Text = '1')  then begin
    cbCarSetup.Items.Add( '15 Free Points');  // x1 lap  4-3-2-2-2-2
  end;
  if (cbLaps.Text ='2') then begin
//    cbCarSetup.Items.Add( 'Preset');  // x1 x2  lap         6-3-3-2-2-2   + 2 meccanici
    cbCarSetup.Items.Add( '18 Free Points');  // x1 x2  lap
  end
  else if cbLaps.Text = '3' then begin
    cbCarSetup.Items.Add( '20 Points limit 14/7');         //6-3-3-3-3-2
  end;
  cbCarSetup.ItemIndex := 0;

  Brain.Laps := StrToInt(cbLaps.text);
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
    SE_GridSetupPlayers.Cells[1,i].FontColor := clGray;
    SE_GridSetupPlayers.Cells[1,i].Guid := 0;

    if i < StrtoInt ( cbHumanPlayers.text ) then begin
      SE_GridSetupPlayers.Cells[1,i].FontColor := clBlack;
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
  for I := 0 to 255 do begin
    MM3[i]:= TMemoryStream.Create;
  end;
  Brain := TFormulaDBrain.Create;

  dir_tmp :=  ExtractFilePath (Application.ExeName)+ 'tmp\';
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
  Brain.Laps := StrToInt(cbLaps.text);

  for I := 1 to 10 do begin
    cbHumanPlayers.Items.add ( IntTostr(i));
  end;
  cbHumanPlayers.ItemIndex := 0;
  for I := 0 to 9 do begin
    cbCPU.Items.add ( IntTostr(i));
  end;
  cbCPU.ItemIndex := 0;// no AI

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

  cbCarSetup.Items.Add( '15 Free Points');  // x1 lap
  cbCarSetup.ItemIndex := 0;

  Brain := TFormulaDBrain.Create;

end;
procedure TForm1.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  Tcpserver.DisconnectAll;
  Tcpserver.Close;
  Tcpserver.Free;
  BmpTiresDry.Free;
  BmpTiresWet.Free;
  BmpPlus.Free;
  BmpMinus.Free;
  mm.Free;
  for I := 0 to 255 do begin
    MM3[i].Free;
  end;
  Brain.Free;
  CloseHandle(Mutex);

end;

procedure TForm1.ResetSetupWeather ( aGridWeather: Se_grid);
var
  bmp : SE_bitmap;
begin
  aGridWeather.ClearData;   // importante anche pr memoryleak
  aGridWeather.DefaultColWidth := 51;
  aGridWeather.DefaultRowHeight := 24;
  aGridWeather.ColCount := 4;
  aGridWeather.RowCount := 1;
  aGridWeather.Columns[0].Width := 51;
  aGridWeather.Columns[1].Width := 51;
  aGridWeather.Columns[2].Width := 51;
  aGridWeather.Columns[3].Width := 51;
  aGridWeather.Rows[0].Height := 24;

  aGridWeather.Height := 24;
  aGridWeather.Width := 51*4;


  bmp := SE_bitmap.Create ( dir_bmpWeather + '0.bmp' );
  bmp.Stretch(51,24);
  aGridWeather.AddSE_Bitmap ( 0, 0, 1 , bmp, true );
  bmp.Free;

  bmp := SE_bitmap.Create ( dir_bmpWeather + '1.bmp' );
  bmp.Stretch(51,24);
  aGridWeather.AddSE_Bitmap ( 1, 0, 1 , bmp, true );
  bmp.Free;

  bmp := SE_bitmap.Create ( dir_bmpWeather + '2.bmp' );
  bmp.Stretch(51,24);
  aGridWeather.AddSE_Bitmap ( 2, 0, 1 , bmp, true );
  bmp.Free;

  bmp := SE_bitmap.Create ( dir_bmpWeather + '3.bmp' );
  bmp.Stretch(51,24);
  aGridWeather.AddSE_Bitmap ( 3, 0, 1 , bmp, true );
  bmp.Free;

  aGridWeather.CellsEngine.ProcessSprites(20);
  aGridWeather.RefreshSurface ( aGridWeather );

end;
procedure TForm1.SetWeather (aGridWeather: Se_grid; Col : integer);
begin
  ResetSetupWeather ( aGridWeather ) ;
  aGridWeather.Cells[Col,0].Bitmap.Bitmap.Canvas.Pen.Color := clRed;
  aGridWeather.Cells[Col,0].Bitmap.Bitmap.Canvas.MoveTo(1,1);
  aGridWeather.Cells[Col,0].Bitmap.Bitmap.Canvas.LineTo(50,1);
  aGridWeather.Cells[Col,0].Bitmap.Bitmap.Canvas.LineTo(50,23);
  aGridWeather.Cells[Col,0].Bitmap.Bitmap.Canvas.LineTo(1,23);
  aGridWeather.Cells[Col,0].Bitmap.Bitmap.Canvas.LineTo(1,1);
  aGridWeather.CellsEngine.ProcessSprites(20);
  aGridWeather.RefreshSurface ( aGridWeather );


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
  SE_GridQual.AddSE_Bitmap ( 0, 0, 1 , bmp, True );
  bmp.Free;

  bmp := SE_bitmap.Create ( dir_bmpWeather + 'r.bmp' );
  bmp.Stretch(51,24);
  SE_GridQual.AddSE_Bitmap ( 1, 0, 1 , bmp, True );
  bmp.Free;

  SE_GridQual.CellsEngine.ProcessSprites(20);
  SE_GridQual.RefreshSurface ( SE_GridQual );

end;
procedure TForm1.SelectSetupQual ( Col : integer);  // Disegno un bordo rosso
begin
  ResetSetupQual;
  SE_GridQual.Cells[Col,0].Bitmap.Bitmap.Canvas.Pen.Color := clRed;
  SE_GridQual.Cells[Col,0].Bitmap.Bitmap.Canvas.MoveTo(1,1);
  SE_GridQual.Cells[Col,0].Bitmap.Bitmap.Canvas.LineTo(50,1);
  SE_GridQual.Cells[Col,0].Bitmap.Bitmap.Canvas.LineTo(50,23);
  SE_GridQual.Cells[Col,0].Bitmap.Bitmap.Canvas.LineTo(1,23);
  SE_GridQual.Cells[Col,0].Bitmap.Bitmap.Canvas.LineTo(1,1);
  SE_GridQual.CellsEngine.ProcessSprites(20);
  SE_GridQual.RefreshSurface ( SE_GridQual );

  if Col = 0 then Brain.Qualifications:= QualLap
    else Brain.Qualifications:= QualRnd;

end;

procedure TForm1.SE_EngineCarsSpriteDestinationReached(ASprite: SE_Sprite);
begin
  // Quando una Car raggiunge la cella indicata nel path, riavvia il Thread dell'animazione
  ThreadCurMove.Enabled := True;
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

procedure TForm1.SE_Theater1SpriteMouseDown(Sender: TObject; lstSprite: TObjectList<DSE_theater.SE_Sprite>; Button: TMouseButton; Shift: TShiftState);
begin
  if lstsprite[0].Engine = SE_EngineCells then begin
    SE_EngineCells.RemoveAllSprites;
    tcp.SendStr(  'SETCAR,'+ lstsprite[0].Guid + EndOfLine);
  end;

end;

procedure TForm1.SE_Theater1SpriteMouseMove(Sender: TObject; lstSprite: TObjectList<DSE_theater.SE_Sprite>; Shift: TShiftState; var Handled: Boolean);
begin
  SE_Theater1.ChangeCursor := True;
  Handled := True;
  if lstsprite[0].Engine = SE_EngineCars then
    Cursor := crHandPoint;

end;

procedure TForm1.tcpDataAvailable(Sender: TObject; ErrCode: Word);
var
  LEN : Integer;
  Buf     : array [0..8191] of AnsiChar;
  tmpStr: string;
  DeCompressedStream: TZDecompressionStream;
  MM,MM2 : TMemoryStream;
  label firstload;
begin


    MM := TMemoryStream.Create;  // potrebbe anche non servire a nulla
    MM.Size := Sizeof(Buf) - 1;
    Len := TWSocket(Sender).Receive( MM.Memory,  Sizeof(Buf) - 1);
    CopyMemory( @Buf, MM.Memory, Len  ); // metto nel buffer per i comandi non compressi
    TWSocket(Sender).DeleteBufferedData ;
//    Len := TWSocket(Sender).Receive(@Buf, Sizeof(Buf) - 1);

    if Len <= 0 then begin
      MM.Free;
      Exit;
    end;

    // COMPRESSED PACKED
    { string(buf) mi tronca la stringa zippata }
 //   SetLength( dataStr ,  Len - 19 );
    tmpStr := String(Buf);
    if MidStr( tmpStr,1,10 )= 'BEGINBRAIN' then begin   // il byte incmove nella stringa

//        MemoC.Lines.Add( 'Compressed size: ' + IntToStr(Len) );

        LastTcpIncMove := ord (buf [10]);
        MyCarAccount := ord (buf [11]);
//        MemoC.Lines.Add('BEGINBRAIN '+  IntToStr(LastTcpIncMove) );

        // elimino beginbrain
        MM2:= TMemoryStream.Create;
        MM2.Write( buf[12] , len - 12 ); // elimino beginbrain   e incmove 11 -11  e MycarAccount

        // su mm3 ho 9c78 compressed
         DeCompressedStream:= TZDeCompressionStream.Create( MM2  );
  //       mm3[incmove].clearM
         MM3[LastTcpIncMove].Clear;
  //       DeCompressedStream.Position := 0;
         MM3[LastTcpIncMove].CopyFrom ( DeCompressedStream, 0);
         MM2.free;     // endfd si perde da solo decomprimendo
         DeCompressedStream.Free;
  //      CopyMemory( @Buf3, mm3.Memory , mm3.size  ); // copia del buf per non essere sovrascritti
        CopyMemory( @Buf3[LastTcpIncMove], mm3[LastTcpIncMove].Memory , mm3[LastTcpIncMove].size  ); // copia del buf per non essere sovrascritti
        MM3[LastTcpIncMove].SaveToFile( dir_tmp + IntToStr(LastTcpIncMove) + '.IS');

          CurrentIncMove := LastTcpIncMove;
    firstload:
//          if not FirstLoadOK  then begin   // avvio partita o ricollegamento. se è la prima volta
            LoadBrain (CurrentIncMove, true) ;   // (incmove)
//            FirstLoadOK := True;

//            CarSpritesReset ( False );
//            ThreadCurMove.Enabled := true;

//          end
//          else begin
//            LoadBrain (CurrentIncMove, true) ;   // (incmove)

    end;
          MM.Free;
          Exit;

//    MemoC.Lines.Add( 'normal size: ' + IntToStr(Len) );


    MM.Free;


end;
procedure TForm1.LoadBrain   ( incMove: Byte; FirstTime: boolean );
var
  SS : TStringStream;
  lenCircuitName, lenUsername, aCarColor: byte;
  dataStr: string;
  Cur: Integer;
  totCars, totPath: Byte;
  aSprite: se_Sprite;
  aCellGuid : SmallInt;
  i,p: integer;
  aGuid,aBox,aTiresType,aTires,aBrakes,aGear,aBody,anEngine,aSuspension,aPathCount: Byte;
  aTiresMax,aBrakesMax,aGearMax,aBodyMax,anEngineMax,aSuspensionMax: Byte;
  aCell: TCell;
  PathGuid:integer;
  aPoint : TPoint;
  aUserName: string;
  aCar : TCar;
  inGame: Boolean;
begin

//  if FirstTime then begin
  if Brain.lstCars.Count = 0 then begin
    se_EngineCars.RemoveAllSprites ;
    se_EngineCars.ProcessSprites(2000);
  //  Brain.lstCars.Clear;
  end;

  SS := TStringStream.Create;
  SS.Size := MM3[incMove].Size;
  MM3[incMove].Position := 0;
  ss.CopyFrom( MM3[incMove], MM3[incMove].size );
  dataStr := SS.DataString;
  SS.Free;

  if RightStr(dataStr,2) <> 'IS' then Exit;

  cur := 0;
  lenCircuitName:=  Ord( buf3[incMove] [ cur ]);                 // ragiona in base 0
  Brain.CircuitDescr.name := MidStr( dataStr, cur + 2  , lenCircuitName );// ragiona in base 1
  cur  := cur + lenCircuitName + 1;

  LoadCircuit ( Brain.CircuitDescr.name ) ; // load del client. Sovrascrive il Server. i debris sono a parte


  Brain.Qualifications :=  Ord( buf3[incMove][ cur ]);
  cur := cur + 1 ;
  Brain.WeatherStart :=  Ord( buf3[incMove][ cur ]);
  cur := cur + 1 ;
  Brain.Weather :=  Ord( buf3[incMove][ cur ]);
  cur := cur + 1 ;
  Brain.Track :=  Ord( buf3[incMove][ cur ]);
  cur := cur + 1 ;
  Brain.Stage :=  Ord( buf3[incMove][ cur ]);
  cur := cur + 1 ;

  Brain.fCurrentCar :=  Ord( buf3[incMove][ cur ]);  // <-- non innesca la AI
  cur := cur + 1 ;
  Brain.CurrentRoll :=  Ord( buf3[incMove][ cur ]);
  cur := cur + 1 ;

  Brain.Laps :=  Ord( buf3[incMove][ cur ]);
  cur := cur + 1 ;



//  MyBrain.Score.TeamGuid [0] :=  PDWORD(@buf3[incMove][ cur ])^;
//  cur := cur + 4 ;
//  MyBrain.Score.TeamGuid [1] :=  PDWORD(@buf3[incMove][ cur ])^;


//  MyBrain.Score.Country [0] :=  PWORD(@buf3[incMove][ cur ])^;
//  cur := cur + 2 ;
//  MyBrain.Score.Country [1] :=  PWORD(@buf3[incMove][ cur ])^;
//  cur := cur + 2 ;

  totCars :=  Ord( buf3[incMove][ cur ]);
  Cur := Cur + 1;
  // cursore posizionato sul primo player
  for I := 0 to totCars -1 do begin

    aGuid := Ord( buf3[incMove][ cur ]);
    Cur := Cur + 1;
    lenUsername :=  Ord( buf3[incMove][ cur ]);
    aUsername := MidStr( dataStr, cur + 2  , lenUsername );// ragiona in base 1  e l'elemento 0 è la len della stringa quindi + 2
    cur  := cur + lenUsername + 1;

    aCarColor := Ord( buf3[incMove][ cur ]);
    Cur := Cur + 1 ;
    aBox := Ord( buf3[incMove][ cur ]);
    Cur := Cur + 1 ;

    aCellGuid := PWORD(@buf3[incMove][ cur ])^;
    Cur := Cur + 2 ;

    aTiresType := Ord( buf3[incMove][ cur ]);
    Cur := Cur + 1 ;
    aTires := Ord( buf3[incMove][ cur ]);
    Cur := Cur + 1 ;
    aBrakes := Ord( buf3[incMove][ cur ]);
    Cur := Cur + 1 ;
    aGear := Ord( buf3[incMove][ cur ]);
    Cur := Cur + 1 ;
    aBody := Ord( buf3[incMove][ cur ]);
    Cur := Cur + 1 ;
    anEngine := Ord( buf3[incMove][ cur ]);
    Cur := Cur + 1 ;
    aSuspension := Ord( buf3[incMove][ cur ]);
    Cur := Cur + 1 ;
    aTiresMax := Ord( buf3[incMove][ cur ]);
    Cur := Cur + 1 ;
    aBrakesMax := Ord( buf3[incMove][ cur ]);
    Cur := Cur + 1 ;
    aGearMax := Ord( buf3[incMove][ cur ]);
    Cur := Cur + 1 ;
    aBodyMax := Ord( buf3[incMove][ cur ]);
    Cur := Cur + 1 ;
    anEngineMax := Ord( buf3[incMove][ cur ]);
    Cur := Cur + 1 ;
    aSuspensionMax := Ord( buf3[incMove][ cur ]);
    Cur := Cur + 1 ;
    inGame :=  Boolean( Ord( buf3[incMove][ cur ]));
    Cur := Cur + 1 ;

    aPathCount := Ord( buf3[incMove][ cur ]);
    Cur := Cur + 1 ;





   // if FirstTime then begin
    if Brain.lstCars.Count = 0 then begin

      aCar := TCar.Create;
      aCar.Guid := aGuid ;
      aCar.UserName := aUsername;
      aCar.CarColor := aCarColor;
      aCar.box := aCarColor;


      brain.lstCars.Add(aCar);
    end
    else begin

      aCar := Brain.FindCar ( aGuid );
    end;


//    aCar.lastGear
    aCar.TiresType := aTiresType;
    aCar.Tires := aTires;
    aCar.Brakes := aBrakes;
    aCar.Gear := aGear;
    aCar.Body := aBody;
    aCar.Engine := anEngine;
    aCar.Suspension := aSuspension;
    aCar.TiresMax := aTiresMax;
    aCar.BrakesMax := aBrakesMax;
    aCar.GearMax := aGearMax;
    aCar.BodyMax := aBodyMax;
    aCar.EngineMax := anEngineMax;
    aCar.SuspensionMax := aSuspensionMax;

    aCar.Path.Clear;
    for p := 0 to aPathCount -1 do begin
      PathGuid := PDWORD(@buf3[incMove][ cur ])^;
      Cur := Cur + 4 ;
      aCar.Path.Add( PathGuid );
    end;
    aCar.inGame := inGame;

    aCell := GetCell ( aCellGuid );
    aCar.Cell  := aCell;


//    if FirstTime then begin
    if SE_EngineCars.SpriteCount < Brain.lstCars.Count then begin

      aCar.SE_Sprite := SE_EngineCars.CreateSprite ( dir_cars  + IntToStr(aCar.CarColor) + '.bmp', IntToStr(aCar.Guid),1,1,1000,0,0,true );
      aCar.SE_Sprite.Scale := 86;
      aCar.SE_Sprite.Visible := False;
      aCar.Se_Sprite.MoverData.Speed := 12;

    end;


    if (Brain.Stage = StageQualifications) then begin
      //<-- in quelification quand la car è la currentCar diventa visibile per sempre
      if aCar.inGame then
        aCar.SE_Sprite.Visible := True;
    end
    else if (Brain.Stage = StageRace) then
      aCar.SE_Sprite.Visible := True;
//      CarSpritesReset ( True );

    if aCar.Path.Count = 0 then begin
      aCar.Se_Sprite.Position := Point( aCar.Cell.PixelX,aCar.Cell.PixelY);
      aCar.Se_Sprite.Angle := aCar.Cell.Angle;
      aCar.Se_Sprite.MoverData.Destination := Point ( aCar.Cell.PixelX, aCar.Cell.PixelY );
    end
    else begin // se c'è un path mostro il movimento
      aCell := GetCell ( aCar.Path[0] );   //<-- l'elemento 0 è la vecchia cella di partenza
      aCar.Se_Sprite.Position := Point( aCell.PixelX , aCell.PixelY );
      aCar.Se_Sprite.Angle := aCell.Angle;
      ThreadCurMove.Enabled := True;

    end;

  end;

  if (Brain.Stage = StageSetupQ) or (brain.Stage = StageSetupRace)  or (brain.Stage = StagePitStop) then begin
    Form3.SE_PanelGear.Visible:=false;
    if Brain.Track = TrackDry then
      Form3.imgTrack.Picture.LoadFromFile(  dir_bmpWeather + 'dry.bmp' )
      else Form3.imgTrack.Picture.LoadFromFile(  dir_bmpWeather + 'wet.bmp' );
    if (Brain.Stage = StageSetupQ) or (brain.Stage = StageSetupRace) then
      Form3.lblPoints.Tag := Brain.CarSetupPoints - 6
    else if (brain.Stage = StagePitStop) then
      Form3.lblPoints.Tag := 2;

    Form3.Show;
    if (Brain.Stage = StageSetupQ) then begin
      Form3.setupQ;
    end
    else if (brain.Stage = StageSetupRace) then begin

      Form3.setupR;
    end
    else if (brain.Stage = StagePitStop) then
      Form3.setupPitStop
    else if (brain.Stage = StageRace) then begin
      Form3.showGear ( MyCarAccount );
    end;


    Form1.SetWeather ( Form3.SE_GridWeather,  brain.Weather );
  //  Exit;
  end
  else if (brain.Stage = StageQualifications)  or (brain.Stage = StageRace) then begin
    SE_Theater1.Active := True;
    SE_Theater1.Visible := True;
    Form3.SE_PanelGear.Visible:=True;
    Form3.Show;
    if Brain.CurrentRoll = 0 then
      Form3.ShowGear ( MyCarAccount )
    else begin
      form3.ShowDestinationCells; // <-- illumina le celle come debugcb
      for i := 0 to Brain.lstcars.Count -1 do begin
        if Brain.lstcars[i].path.count > 0 then begin
          ThreadCurMove.Enabled := True;
          Break;
        end;
      end;
    end;
  end;

// NOTE HERE





end;
function TForm1.GetCell ( Guid : SmallInt ) : TCell;
var
  i: Integer;
begin
  Result := nil;
  for i := Brain.Circuit.Count -1 downto 0 do begin
    if Brain.Circuit[i].Guid = Guid then begin
      Result := Brain.Circuit[i];
      Exit;
    end;
  end;

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
        Client.Account := -1;
        SE_GridSetupPlayers.Cells[1,i].Guid := 0;
        SE_GridSetupPlayers.Cells[1,i].FontColor := clBlack;
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
procedure TForm1.LoadCarRndPreset ( aCar : TCar );
begin
// preset lap 1,2,3  4-3-2-2-2-2  6-3-3-2-2-2  6-3-3-3-3-2
  aCar.TiresType := Brain.Track; // se piove setta le gomme da pioggia

  if brain.Laps = 1 then begin
    aCar.TiresMax     := 4 ;
    aCar.BrakesMax    := 3 ;
    aCar.GearMax      := 2;
    aCar.BodyMax      := 2;
    aCar.EngineMax    := 2;
    aCar.SuspensionMax := 2;

  end
  else if brain.Laps = 2 then begin
    aCar.TiresMax     := 6 ;
    aCar.BrakesMax    := 3 ;
    aCar.GearMax      := 3;
    aCar.BodyMax      := 2;
    aCar.EngineMax    := 2;
    aCar.SuspensionMax := 2;

  end
  else if brain.Laps = 3 then begin
    aCar.TiresMax     := 6 ;
    aCar.BrakesMax    := 3 ;
    aCar.GearMax      := 3;
    aCar.BodyMax      := 3;
    aCar.EngineMax    := 3;
    aCar.SuspensionMax := 2;

  end;

  aCar.Tires := aCar.TiresMax;
  aCar.Brakes :=  aCar.BrakesMax;
  aCar.Gear := aCar.GearMax;
  aCar.Body :=  aCar.BodyMax;
  aCar.Engine :=  aCar.EngineMax;
  aCar.Suspension := aCar.SuspensionMax;

end;

function TForm1.validate_and_WriteSetupCar (  Cli: TWSocketThrdClient;  Commatext : string ):Boolean;
var
  aCar : TCar;
  ts : TStringList;
  i,TotPoints: Integer;
begin
  ts := TStringList.Create;
  ts.CommaText := Commatext;
  ts.Delete(0); // elimino Sq o SR

  if ts.Count <> 7 then begin
      result := False;
      ts.Free;
      Exit;
  end;

  TotPoints := 0;
  for I := 1 to ts.Count -1 do begin  // parte da 1. 0 è  la carGuid
    TotPoints := TotPoints + StrToIntdef(ts[i],-1);
    if StrToIntDef(ts[i],-1) = -1 then begin // devono essere 7 numeri. tirestype + 6 stats
      result := False;
      ts.Free;
      Exit;
    end;
  end;

  if totPoints <> brain.CarSetupPoints then begin
      result := False;
      ts.Free;
      Exit;
  end;

  aCar := brain.FindCar( Cli.Account ); // account = aCar.Guid
  aCar.TiresType := StrToInt(ts[0] ) ;

  if (brain.Stage = StageSetupQ) or (brain.Stage = StageSetupRace) then begin

    aCar.TiresMax := StrToInt(ts[1] ) ;
    aCar.BrakesMax := StrToInt(ts[2] ) ;
    aCar.GearMax := StrToInt(ts[3] ) ;
    aCar.BodyMax := StrToInt(ts[4] ) ;
    aCar.EngineMax := StrToInt(ts[5] ) ;
    aCar.SuspensionMax := StrToInt(ts[6] ) ;

    aCar.Tires := StrToInt(ts[1] ) ;
    aCar.Brakes := StrToInt(ts[2] ) ;
    aCar.Gear := StrToInt(ts[3] ) ;
    aCar.Body := StrToInt(ts[4] ) ;
    aCar.Engine := StrToInt(ts[5] ) ;
    aCar.Suspension := StrToInt(ts[6] ) ;

  end;

  ts.Free;
  Result := True;
end;
procedure TForm1.TcpserverDataAvailable(Sender: TObject; ErrCode: Word);
var
    Cli: TWSocketThrdClient;
    RcvdLine: string;
    ts: TStringList;
    i: Integer;
    aCar : TCar;
    found: Boolean;
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


  if LeftStr(ts[0],1) ='R' then begin
//    if (Brain.CurrentCar = Cli.Account) and ( (brain.Stage = StageQualifications) or (brain.Stage = StageRace) ) then begin  // solo se sta a quel player
 { TODO : rimettere la riga sopra. solo per debug }
    if ( (brain.Stage = StageQualifications) or (brain.Stage = StageRace) ) then begin  // solo se sta a quel player
      { TODO : anche qui in brainInput perchè la Ai passa di li }
      if (ts[0] = 'R12') or (ts[0] = 'R24') or (ts[0] = 'R48') or (ts[0] = 'R712') or (ts[0] = 'R1120') or (ts[0] = 'R2130') or (ts[0] = 'R79') or
        (ts[0] = 'R1012') or (ts[0] = 'R1115') or (ts[0] = 'R1620') then begin
          Brain.BrainInput ( Brain.FindCar(Cli.Account), ts[0] ); // check se può usare quella marcia
      end
      else begin
        ts.Free;
        Exit;
      end;
    end
    else begin
      ts.Free;
      Exit;
    end;
      // la richiesta di Roll viene elaborata e salcata nel brain. è come in time120 con i freekick
      Brain.SaveData ( Brain.ServerIncMove ) ;
      for I := 0 to Tcpserver.ClientCount -1 do begin
          { TODO : ansichar dovrà occuparsi di un valore più alto di 255, diventa smallint }
          TcpServer.Client[i].SendStr( 'BEGINBRAIN'  + AnsiChar (  Brain.ServerIncMove  )
                                                     + AnsiChar (  tcpserver.Client[i].Account )
                                                     + GetbrainStream ( brain ) +  EndOfLine );  //<-- stageQualifications e currentCar util nel client
      end;
      Brain.ServerIncMove := Brain.ServerIncMove + 1;
  end
  else if ts[0] ='SETCAR' then begin
      found := False;
      if (ts.Count <> 2) then begin
        ts.Free;
        exit;
      end;
      if StrToIntDef( ts[1],-1) = -1 then begin
        ts.Free;
        exit;
      end;
      for I := 0 to brain.Circuit.Count -1 do begin
        if Brain.Circuit[i].Guid = StrToInt( ts[1]) then begin
          found := True;
          Break;
        end;

      end;
      if not found then begin
        ts.Free;
        exit;
      end;
      brain.BrainInput ( Brain.FindCar(Cli.Account), ts.commaText ); // --> anche la AI passa di qui
      Brain.SaveData ( Brain.ServerIncMove ) ;
      for I := 0 to Tcpserver.ClientCount -1 do begin
          { TODO : ansichar dovrà occuparsi di un valore più alto di 255, diventa smallint }
          TcpServer.Client[i].SendStr( 'BEGINBRAIN'  + AnsiChar (  Brain.ServerIncMove  )
                                                     + AnsiChar (  tcpserver.Client[i].Account )
                                                     + GetbrainStream ( brain ) +  EndOfLine );  //<-- stageQualifications e currentCar util nel client
      end;
      Brain.ServerIncMove := Brain.ServerIncMove + 1;
  end
  else if ts[0] ='login' then begin
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
        Cli.Account := I;
        SE_GridSetupPlayers.Cells[1,i].Guid := Cli.CliId;
        SE_GridSetupPlayers.Cells[1,i].Text := Cli.UserName;
        SE_GridSetupPlayers.Cells[1,i].FontColor := clGray;
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
  end
  else if ts[0] ='SQ' then begin // setup Qualifications
    if Brain.Stage <> StageSetupQ then Exit;

    if validate_and_WriteSetupCar ( Cli, ts.CommaText ) then begin
      aCar := Brain.FindCar( cli.Account );
      aCar.ConfirmedSetupQ := True;
      // se tutte le car sono validate le cpu si autosettano con dei preset
      for I := 0 to StrToInt( cbHumanPlayers.Text ) -1 do begin
        if not brain.lstCars[i].ConfirmedSetupQ then
          Exit;
      end;
      // setto le cpu rimanenti
      for I := StrToInt( cbHumanPlayers.Text ) to SE_GridSetupPlayers.RowCount -1 do begin
        aCar := brain.lstCars[i];
        LoadCarRndPreset ( aCar );
        aCar.ConfirmedSetupQ := true;
      end;

      StartQualifications;

      Brain.SaveData ( Brain.ServerIncMove ) ;
      for I := 0 to Tcpserver.ClientCount -1 do begin
          { TODO : ansichar dovrà occuparsi di un valore più alto di 255, diventa smallint }
          TcpServer.Client[i].SendStr( 'BEGINBRAIN'  + AnsiChar (  Brain.ServerIncMove  )
                                                     + AnsiChar (  tcpserver.Client[i].Account )
                                                     + GetbrainStream ( brain ) +  EndOfLine );  //<-- stageQualifications e currentCar util nel client
      end;
      Brain.ServerIncMove := Brain.ServerIncMove + 1;
    end;

  end
  else if ts[0] ='SR' then begin // setup Race
    if Brain.Stage <> StageSetupRace then Exit;

    if validate_and_WriteSetupCar ( Cli, ts.CommaText ) then begin
      aCar := Brain.FindCar( cli.Account );
      aCar.ConfirmedSetupR := True;
      // se tutte le car sono validate le cpu si autosettano con dei preset
      for I := 0 to StrToInt( cbHumanPlayers.Text ) -1 do begin
        if not brain.lstCars[i].ConfirmedSetupR then
          Exit;
      end;
      // setto le cpu rimanenti
      for I := StrToInt( cbHumanPlayers.Text ) to SE_GridSetupPlayers.RowCount -1 do begin
        aCar := brain.lstCars[i];
        LoadCarRndPreset ( aCar );
        aCar.ConfirmedSetupR := true;
        brain.lstCars[i].ConfirmedSetupR := true;
      end;

      StartRace;
      Brain.SaveData ( Brain.ServerIncMove ) ;
      for I := 0 to Tcpserver.ClientCount -1 do begin
          { TODO : ansichar dovrà occuparsi di un valore più alto di 255, diventa smallint }
          TcpServer.Client[i].SendStr( 'BEGINBRAIN'  + AnsiChar (  Brain.ServerIncMove  )
                                                     + AnsiChar (  tcpserver.Client[i].Account )
                                                     + GetbrainStream ( brain ) +  EndOfLine );  //<-- stageQualifications e currentCar util nel client
      end;
      Brain.ServerIncMove := Brain.ServerIncMove + 1;

    end;
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

procedure TForm1.ThreadCurMoveTimer(Sender: TObject);
var
  i: Integer;
  aCar: TCar;
  aCell : TCell;
begin
  for I := 0 to brain.lstCars.Count -1 do begin
    aCar := brain.lstCars[i];
    if aCar.Path.Count > 0 then begin
      aCell := Brain.FindCell( aCar.Path[0] );
      aCar.SE_Sprite.MoverData.Destination := Point( aCell.PixelX, aCell.PixelY );
      aCar.Path.Delete(0);  // <-- elaborato il path viene svuotato di volta in volta
    end;
  end;

  ThreadCurMove.Enabled := False; //<-- viene riavviato in spritedestintionReached

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
  SE_GridCarColor.Cells[0,3].ids := '4';
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
  TotCells: SmallInt;
  i,L,a,tmpI: Integer;
  aCell: TCell;
  TotLinkForward, TotAdjacent: Byte;
  aSprite: SE_Sprite;
begin
  brain.Circuit.clear;

  ini := TIniFile.Create( dir_circuits + CircuitName + '.ini' );
  brain.CircuitDescr.Name := ini.ReadString('setup','Name','');
  brain.CircuitDescr.Corners := ini.ReadString('setup','Corners','');
  ini.Free;

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
      mm.Read( tmpI , SizeOf(Integer) );
      aCell.LinkForward.add ( tmpI );
    end;
    mm.Read( TotAdjacent, SizeOf(Byte) );
    for A := 0 to TotAdjacent -1 do begin
      mm.Read( tmpI , SizeOf(Integer) );
      aCell.Adjacent.add ( tmpI );
    end;

    brain.Circuit.Add(aCell);
  end;

  aSprite := SE_Sprite.Create (dir_circuits + CircuitName +'.bmp','circuit',1,1,1000,0,0,false );

  SE_EngineBack.RemoveAllSprites;
 // for i := 0 to SE_Theater1.EngineCount -1 do begin
 //   SE_Theater1.Engines [i].RemoveAllSprites;
 // end;

  SE_Theater1.VirtualWidth := aSprite.BMP.Width;
  SE_Theater1.VirtualHeight := aSprite.BMP.Height;

  SE_EngineBack.AddSprite( aSprite );
  aSprite.Position := Point (  SE_Theater1.VirtualWidth div 2 , SE_Theater1.Virtualheight div 2  );

end;

function TForm1.GetbrainStream ( brain: TFormulaDBrain) : string;
var
  CompressedStream: TZCompressionStream;
  SS: TStringStream;
begin
              // senza compressione
  {SS := TStringStream.Create('');
  SS.CopyFrom( brain.MMbraindata, 0);
  NewData := SS.DataString;
  SS.Free;   }

  // con compressione
  CompressedStream := TZCompressionStream.Create(brain.MMbraindataZIP, zcDefault); // create the compression stream
  CompressedStream.Write( brain.MMbraindata.Memory , brain.MMbraindata.size); // move and compress the InBuffer string -> destination stream  (MyStream)
  CompressedStream.Free;
  SS := TStringStream.Create('');
  SS.CopyFrom( brain.MMbraindataZIP, 0);
  Result := SS.DataString;
  SS.Free;
end;
procedure TForm1.StartQualifications;
var
  i: Integer;
  aCell: TCell;
begin
  // Utilizzo una lista false per i sort. la lista brain.lstCars non verrà ordinata per mantenere la struttura del tutto
  Brain.Stage := StageQualifications;
  Brain.lstCarsTmp.Clear;
  for I := 0 to brain.lstCars.count -1 do begin
    brain.lstCars[i].CurrentGear := 0;
    Brain.lstCarsTmp.Add( Brain.lstCars[i]  );
  end;

  // random ordine di qualifiche. Non è random la startinggrid
  for I := ((brain.lstCarsTmp.count -1) * 2 ) downto 0 do begin
    brain.lstCarsTmp.Exchange( Brain.RndGenerate0( brain.lstCarsTmp.count -1 ), Brain.RndGenerate0( brain.lstCarsTmp.count -1 ) );
  end;

  Brain.lstCarsTmp[0].inGame := True;  //<-- modifica anche l'oggetto in lstcars
  aCell := Brain.FindCellStartingGrid(1);
  Brain.lstCarsTmp[0].Cell := aCell;
  Brain.CurrentCar := Brain.lstCarsTmp[0].Guid; //<-- attiva ai_think


end;
procedure TForm1.StartRace;
var
  i: Integer;
  aCell: TCell;
begin
  // Utilizzo una lista false per i sort. la lista brain.lstCars non verrà ordinata per mantenere la struttura del tutto

  // in caso di qualRnd le car sono già piazzate nelle celle startingGrid
  // Nel caso dell qulifiche reali è da fare. FORZO un RND
  Brain.Stage := StageRace;
  //Brain.lstCarsTmp.Clear;
 // for I := 0 to brain.lstCars.count -1 do begin
 //   Brain.lstCarsTmp.Add( Brain.lstCars[i]  );
 // end;

//  Brain.lstCarsTmp.Sort

  aCell := brain.FindStartingGrid(1);
  Brain.CurrentCar := Brain.GetCarAtCell( aCell ).Guid; //<-- attiva ai_think
 // Brain.lstCarsTmp[0].inGame := True;  //<-- modifica anche l'oggetto in lstcars
 // aCell := Brain.FindCellStartingGrid(1);
 // Brain.lstCarsTmp[0].Cell := aCell;
//for I := 0 to brain.lstCars.count -1 do begin
//  brain.lstCars[i].CurrentGear := 0;

end;

end.
