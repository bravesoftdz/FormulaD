unit Unit3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DSE_theater, DSE_GRID, Vcl.ExtCtrls, CnButtons, DSE_Bitmap, Vcl.StdCtrls;

type
  TForm3 = class(TForm)
    SE_GridWeather: SE_Grid;
    SE_GridCars: SE_Grid;
    imgTrack: TImage;
    SE_GridTires: SE_Grid;
    btnTiresDry: TCnSpeedButton;
    btnTiresWet: TCnSpeedButton;
    SE_GridBrakes: SE_Grid;
    SE_GridBody: SE_Grid;
    SE_GridEngine: SE_Grid;
    SE_GridGear: SE_Grid;
    SE_GridSuspension: SE_Grid;
    lblWeather: TLabel;
    lblTrack: TLabel;
    lblPoints: TLabel;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SE_GridTiresGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer;
      Sprite: SE_Sprite);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SetupQ;
    procedure SetupPitStop;
    procedure SetupRace;


    procedure ShowTires ( Editing : boolean; CarAccount: Byte );
  end;

var
  Form3: TForm3;

implementation
uses Unit1, formulaDBrain;

{$R *.dfm}
procedure TForm3.Button1Click(Sender: TObject);
begin
  // il client conferma i car setup points. CliId con username fa fede per la car assegnata
  // setupQ e SetupR --> setta i tiresMAX ecc.. di nuovo
  // il server ottenuti tutti gli input dal client vengono settati i preset per le CPU

  // durante il pitstop viene mostrata la car MyCarAccount


end;

procedure TForm3.FormCreate(Sender: TObject);
var
  bmp : SE_Bitmap;
begin
  bmp := SE_Bitmap.Create  ( dir_bmpWeather + 'TiresDry.bmp' );
  bmp.Stretch( 20,24 );
  bmp.Bitmap.SaveToFile( dir_tmp  + 'TiresDry.bmp' );
  bmp.Free;
  btnTiresDry.Glyph.LoadFromFile( dir_tmp  + 'TiresDry.bmp' );
  btnTiresDry.NumGlyphs := 1;

  bmp := SE_Bitmap.Create  ( dir_bmpWeather + 'TiresWet.bmp' );
  bmp.Stretch( 20,24 );
  bmp.Bitmap.SaveToFile( dir_tmp  + 'TiresWet.bmp' );
  bmp.Free;
  btnTiresWet.Glyph.LoadFromFile( dir_tmp  + 'TiresWet.bmp' );
  btnTiresWet.NumGlyphs := 1;


  BmpTiresDry := SE_Bitmap.Create (dir_tmp  + 'TiresDry.bmp');
  BmpTiresWet := SE_Bitmap.Create (dir_tmp  + 'TiresWet.bmp');

end;

procedure TForm3.SetupQ;   // abilita btn scelta gomme
begin
  SE_GridCars.Visible := False;
  // wet dry dipende dal brain
  if Brain.Track = 0 then
    btnTiresDry.Down := True
    else btnTiresWet.Down := True;

  lblPoints.Caption := 'Points: ' + IntToStr( Brain.CarSetupPoints );
  // sono visibili i pulsanti per settare i points

  ShowTires ( True, MyCarAccount ); // --> True = editing possibile con pulsanti aggiuntivi

end;
procedure TForm3.SetupPitStop;  // abilita img mechanic points, btn scelta gomme, continue, leave box
begin
  // sono visibili i pulsanti per settare i points fino a 2 punti meccanici
  // le gomme sono solo settabili dai due btn come treno nuovo
end;
procedure TForm3.SetupRace; // abilita lista cars , btn gear 1-6
begin
  // Nessun pulsate per edting è visibile
  btnTiresDry.Visible := false;
  btnTiresWet.Visible := false;
end;
procedure TForm3.SE_GridTiresGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer; Sprite: SE_Sprite);
var
  aCar : TCar;
begin
  if (Brain.Stage = StageSetupQ) or (Brain.Stage = StageSetupRace) then begin  { TODO : fare pistop }
    aCar := Brain.FindCar( MycarAccount ); // lavoro solo sulla mia car
    if CellX = 1 {Add} then begin
      aCar.Tires := aCar.Tires + 1;
    end
    else if CellX = 0 {Del}then begin
      if aCar.Tires > 1 then
        aCar.Tires := aCar.Tires - 1;
    end;
    ShowTires ( True, MycarAccount );
  end;

end;

procedure TForm3.ShowTires ( Editing : boolean; CarAccount : Byte );
var
  bmp : SE_bitmap;
  i,StartCol: Integer;
  aCar: TCar;
begin
  aCar := Brain.FindCar( carAccount );

  SE_GridTires.ClearData;   // importante anche pr memoryleak
  SE_GridTires.DefaultColWidth := 20;
  SE_GridTires.DefaultRowHeight := 24;

  SE_GridTires.ColCount := aCar.Tires;
  if Editing then
    SE_GridTires.ColCount := SE_GridTires.ColCount + 2; // i 2 pulsanti per aggiungere e sottrarre in fase di eediting

  SE_GridTires.RowCount := 1;

  for I := 0 to SE_GridTires.ColCount -1 do begin
    SE_GridTires.Columns[i].Width := 20;
  end;

  SE_GridTires.Rows[0].Height := 24;
  SE_GridTires.Height := 24;

  SE_GridTires.Width := 20* SE_GridTires.ColCount ;

  if Editing then StartCol := 2 else
    StartCol := 0;
  for I := StartCol to SE_GridTires.ColCount -1 do begin
  if btnTiresDry.down then
    SE_GridTires.AddSE_Bitmap ( i, 0, 1 , bmpTiresDry , false )
  else if btnTiresWet.down then
    SE_GridTires.AddSE_Bitmap ( i, 0, 1 , bmpTiresWet, false );

  end;



  SE_GridTires.CellsEngine.ProcessSprites(20);
  SE_GridTires.RefreshSurface ( SE_GridTires );

end;
end.
