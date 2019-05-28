unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, CnButtons, Vcl.ExtCtrls, DSE_Panel, Vcl.StdCtrls,
  DSE_Misc, DSE_theater, DSE_Bitmap, DSE_GRID, DSE_SearchFiles ;

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
    procedure FormCreate(Sender: TObject);
    procedure btnCreateGameClick(Sender: TObject);
    procedure SE_GridWheaterGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer;
      Sprite: SE_Sprite);
  private
    { Private declarations }
    procedure ResetSetupWheater;
    procedure SelectSetupWheater ( Col : Integer );
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  dir_bmpWheater, dir_Cars, dir_Circuits: string;
implementation

{$R *.dfm}

procedure TForm1.btnCreateGameClick(Sender: TObject);
begin
  SelectSetupWheater (4);
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

  for I := 1 to 10 do begin
    cbHumanPlayers.Items.add ( IntTostr(i));
  end;
  cbHumanPlayers.ItemIndex := 0;
  for I := 1 to 10 do begin
    cbCPU.Items.add ( IntTostr(i));
  end;
  cbCPU.ItemIndex := 8;

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

procedure TForm1.SE_GridWheaterGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer;  Sprite: SE_Sprite);
begin
  SelectSetupWheater ( CellX );
end;

end.
