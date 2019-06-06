unit Unit3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DSE_theater, DSE_GRID, Vcl.ExtCtrls, CnButtons, DSE_Bitmap, Vcl.StdCtrls;
Type TStat = ( statTires, StatBrakes, StatGear, StatBody, StatEngine, StatSuspension );
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
    procedure btnTiresDryClick(Sender: TObject);
    procedure btnTiresWetClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SetupQ;
    procedure SetupPitStop;
    procedure SetupRace;


    procedure ShowCarStat ( Editing : boolean; CarAccount : Byte; Stat : TStat );
  end;

var
  Form3: TForm3;

implementation
uses Unit1, formulaDBrain;

{$R *.dfm}
procedure TForm3.btnTiresDryClick(Sender: TObject);
var
  aCar : TCar;
begin
  //if (Brain.Stage = StageSetupQ) or (Brain.Stage = StageSetupRace) then begin
  aCar := Brain.FindCar( MycarAccount ); // lavoro solo sulla mia car
  aCar.TiresType := 0;
  ShowcarStat( True, MycarAccount, StatTires );

end;

procedure TForm3.btnTiresWetClick(Sender: TObject);
var
  aCar : TCar;
begin
  //if (Brain.Stage = StageSetupQ) or (Brain.Stage = StageSetupRace) then begin
  aCar := Brain.FindCar( MycarAccount ); // lavoro solo sulla mia car
  aCar.TiresType := 1;
  ShowcarStat( True, MycarAccount, StatTires );

end;

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

  Bmp := SE_Bitmap.Create (dir_Cars  + 'plus.bmp');
  Bmp.stretch( 20,24 );
  Bmp.Bitmap.SaveToFile( dir_tmp  + 'plus.bmp' );
  Bmp.Free;
  Bmp := SE_Bitmap.Create (dir_Cars  + 'minus.bmp');
  Bmp.stretch( 20,24 );
  Bmp.Bitmap.SaveToFile( dir_tmp  + 'Minus.bmp' );
  Bmp.Free;

  BmpPlus := SE_Bitmap.Create (dir_tmp  + 'plus.bmp');
  BmpMinus := SE_Bitmap.Create (dir_tmp  + 'Minus.bmp');


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

  ShowcarStat ( True, MyCarAccount, StatTires ); // --> True = editing possibile con pulsanti aggiuntivi
  ShowcarStat ( True, MyCarAccount, StatBrakes );
  ShowcarStat ( True, MyCarAccount, StatGear );
  ShowcarStat ( True, MyCarAccount, StatBody );
  ShowcarStat ( True, MyCarAccount, StatEngine );
  ShowcarStat ( True, MyCarAccount, StatSuspension );

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
    ShowcarStat ( True, MycarAccount, StatTires );
  end;

end;

procedure TForm3.ShowCarStat ( Editing : boolean; CarAccount : Byte; Stat : TStat );
var
  bmp : SE_bitmap;
  i,StartCol,w,h: Integer;
  aCar: TCar;
  Grid : SE_Grid;
begin
  aCar := Brain.FindCar( carAccount );


  if Stat = StatTires then begin
    Grid := SE_GridTires;
    Grid.ColCount := aCar.Tires;
    bmp := SE_Bitmap.Create ( dir_tmp + 'TiresDry.bmp');  // non utilizzato
    w := 20;
    h := 24;
  end
  else if Stat = StatBrakes then begin
    Grid := SE_GridBrakes;
    Grid.ColCount := aCar.Brakes;
    bmp := SE_Bitmap.Create ( dir_Cars + 'brakes.bmp');
    w := 20;
    h := 24;
  end
  else if Stat = StatGear then begin
    Grid := SE_GridGear;
    Grid.ColCount := aCar.Gear;
    bmp := SE_Bitmap.Create ( dir_Cars + 'Gear.bmp');
    w := 20;
    h := 24;
  end
  else if Stat = StatBody then begin
    Grid := SE_GridBody;
    Grid.ColCount := aCar.Body;
    bmp := SE_Bitmap.Create ( dir_Cars + 'Body.bmp');
    w := 37;
    h := 24;
  end
  else if Stat = StatEngine then begin
    Grid := SE_GridEngine;
    Grid.ColCount := aCar.Engine;
    bmp := SE_Bitmap.Create ( dir_Cars + 'Engine.bmp');
    w := 20;
    h := 24;
  end
  else if Stat = StatSuspension then begin
    Grid := SE_GridSuspension;
    Grid.ColCount := aCar.Suspension;
    bmp := SE_Bitmap.Create ( dir_Cars + 'Suspension.bmp');
    w := 20;
    h := 24;
  end;

  Grid.ClearData;   // importante anche pr memoryleak
  Grid.DefaultColWidth := w;
  Grid.DefaultRowHeight := h;

  if Editing then
    Grid.ColCount := Grid.ColCount + 2; // i 2 pulsanti per aggiungere e sottrarre in fase di eediting

  Grid.RowCount := 1;

  for I := 0 to Grid.ColCount -1 do begin
    Grid.Cells[i,0].BackColor:=  $007B5139;
    Grid.Columns[i].Width := w;
  end;

  Grid.Rows[0].Height := h;
  Grid.Height := w;

  Grid.Width := w* Grid.ColCount ;

  if Editing then begin
    Grid.AddSE_Bitmap ( 0, 0, 1 , bmpMinus , true );
    Grid.AddSE_Bitmap ( 1, 0, 1 , bmpPlus , true );
  end;

  if Editing then StartCol := 2 else
    StartCol := 0;

  if Stat = StatTires then begin
    for I := StartCol to Grid.ColCount -1 do begin
    if aCar.TiresType = 0 then
      Grid.AddSE_Bitmap ( i, 0, 1 , bmpTiresDry , true )
    else if aCar.TiresType = 1 then
      Grid.AddSE_Bitmap ( i, 0, 1 , bmpTiresWet, true );

    end;
  end
  else begin
    for I := StartCol to Grid.ColCount -1 do begin
      Grid.AddSE_Bitmap ( i, 0, 1 , bmp , true )
    end;
  end;

//  if bmp <> nil then // non tires
    bmp.Free;

  Grid.CellsEngine.ProcessSprites(20);
  Grid.RefreshSurface ( Grid );
end;
end.
