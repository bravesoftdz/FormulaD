unit Unit3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DSE_theater, DSE_GRID, Vcl.ExtCtrls, CnButtons, DSE_Bitmap, Vcl.StdCtrls;
Type TStat = ( statTires, StatBrakes, StatGear, StatBody, StatEngine, StatSuspension );
type
  TForm3 = class(TForm)
    SE_GridWeather: SE_Grid;
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
    Button2: TButton;
    Button3: TButton;
    btnConfirmSetup: TCnSpeedButton;
    lblTiresType: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure SE_GridTiresGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer;
      Sprite: SE_Sprite);
    procedure btnTiresDryClick(Sender: TObject);
    procedure btnTiresWetClick(Sender: TObject);
    procedure SE_GridBrakesGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer;
      Sprite: SE_Sprite);
    procedure SE_GridBodyGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer;
      Sprite: SE_Sprite);
    procedure SE_GridEngineGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer;
      Sprite: SE_Sprite);
    procedure SE_GridGearGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer;
      Sprite: SE_Sprite);
    procedure SE_GridSuspensionGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer;
      Sprite: SE_Sprite);
    procedure btnConfirmSetupClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SetupQ;
    procedure SetupPitStop;
    procedure SetupR;


    procedure ShowCarStat ( Editing : boolean; CarAccount : Byte; Stat : TStat );
  end;

var
  Form3: TForm3;

implementation
uses Unit1, formulaDBrain;

{$R *.dfm}
procedure TForm3.btnConfirmSetupClick(Sender: TObject);
var
  aCar : TCar;
  prefix: Char;
begin
  if (Brain.Stage = StageSetupQ) then
    prefix := 'Q'
  else if (Brain.Stage = StageSetupRace) then
    prefix := 'R';

  aCar := Brain.FindCar( MycarAccount ); // lavoro solo sulla mia car
  Form1.tcp.SendStr( 'S' + prefix + ',' + IntTostr(aCar.TiresType) + ','
                     + IntTostr(aCar.TiresMax)+ ','
                     + IntTostr(aCar.BrakesMax) + ','
                     + IntTostr(aCar.GearMax)+ ','
                     + IntTostr(aCar.BodyMax)+ ','
                     + IntTostr(aCar.EngineMax)+ ','
                     + IntTostr(aCar.Suspension)
                     + EndofLine );
end;

procedure TForm3.btnTiresDryClick(Sender: TObject);
var
  aCar : TCar;
begin
  //if (Brain.Stage = StageSetupQ) or (Brain.Stage = StageSetupRace) then begin
  if (Brain.Stage = StageSetupQ) or (Brain.Stage = StageSetupRace)  then begin
    aCar := Brain.FindCar( MycarAccount ); // lavoro solo sulla mia car
    aCar.TiresType := 0;
    aCar.Tires :=  SE_GridTires.ColCount -2;
     ShowcarStat( true, MycarAccount, StatTires );
  end
  else if (Brain.Stage = StagePitStop) then begin
    aCar := Brain.FindCar( MycarAccount ); // lavoro solo sulla mia car
    aCar.TiresType := 0;
    aCar.Tires :=  SE_GridTires.ColCount;
    ShowcarStat( False, MycarAccount, StatTires )

  end;
end;

procedure TForm3.btnTiresWetClick(Sender: TObject);
var
  aCar : TCar;
begin
  if (Brain.Stage = StageSetupQ) or (Brain.Stage = StageSetupRace)  then begin
    aCar := Brain.FindCar( MycarAccount ); // lavoro solo sulla mia car
    aCar.TiresType := 1;
    aCar.Tires :=  SE_GridTires.ColCount -2;
    ShowcarStat( true, MycarAccount, StatTires );
  end
  else if (Brain.Stage = StagePitStop) then begin
    aCar := Brain.FindCar( MycarAccount ); // lavoro solo sulla mia car
    aCar.TiresType := 1;
    aCar.Tires :=  SE_GridTires.ColCount;
    ShowcarStat( False, MycarAccount, StatTires )

  end;


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

  SE_GridBrakes.left := SE_GridTires.Left;
  SE_GridBrakes.Top := SE_GridTires.Top + SE_GridTires.Height;
  SE_GridGear.left := SE_GridTires.Left;
  SE_GridGear.Top := SE_GridBrakes.Top + SE_GridBrakes.Height;
  SE_GridBody.left := SE_GridTires.Left;
  SE_GridBody.Top := SE_GridGear.Top + SE_GridGear.Height;
  SE_GridEngine.left := SE_GridTires.Left;
  SE_GridEngine.Top := SE_GridBody.Top + SE_GridBody.Height;
  SE_GridSuspension.left := SE_GridTires.Left;
  SE_GridSuspension.Top := SE_GridEngine.Top + SE_GridEngine.Height;

end;

procedure TForm3.SetupQ;   // abilita btn scelta gomme
var
  aCar : TCar;
begin

  // wet dry dipende dal brain
  if Brain.Track = 0 then
    btnTiresDry.Down := True
    else btnTiresWet.Down := True;

  lblPoints.Tag := Brain.CarSetupPoints -6;
  lblPoints.Caption := 'Points: ' + IntToStr( lblPoints.Tag );
  // sono visibili i pulsanti per settare i points

  aCar := Brain.FindCar( MycarAccount ); // lavoro solo sulla mia car
  aCar.TiresMax := Brain.CarSetupPoints - 6;
  aCar.BrakesMax := Brain.CarSetupPoints - 6;
  aCar.BodyMax := Brain.CarSetupPoints - 6;
  aCar.GearMax := Brain.CarSetupPoints - 6;
  aCar.EngineMax := Brain.CarSetupPoints - 6;
  aCar.SuspensionMax := Brain.CarSetupPoints - 6;
  if Brain.laps = 3 then begin
    aCar.TiresMax := 14;
    aCar.BrakesMax := 7;
    aCar.BodyMax := 7;
    aCar.GearMax := 7;
    aCar.EngineMax := 7;
    aCar.SuspensionMax := 7;
  end;

  ShowcarStat ( True, MyCarAccount, StatTires ); // --> True = editing possibile con pulsanti aggiuntivi
  ShowcarStat ( True, MyCarAccount, StatBrakes );
  ShowcarStat ( True, MyCarAccount, StatGear );
  ShowcarStat ( True, MyCarAccount, StatBody );
  ShowcarStat ( True, MyCarAccount, StatEngine );
  ShowcarStat ( True, MyCarAccount, StatSuspension );

end;
procedure TForm3.SetupR; // abilita lista cars , btn gear 1-6
var
  aCar : TCar;
begin
  // Nessun pulsate per edting è visibile
  btnTiresDry.Visible := false;
  btnTiresWet.Visible := false;

  aCar := Brain.FindCar( MycarAccount ); // lavoro solo sulla mia car
  aCar.TiresMax := Brain.CarSetupPoints - 6;
  aCar.BrakesMax := Brain.CarSetupPoints - 6;
  aCar.BodyMax := Brain.CarSetupPoints - 6;
  aCar.GearMax := Brain.CarSetupPoints - 6;
  aCar.EngineMax := Brain.CarSetupPoints - 6;
  aCar.SuspensionMax := Brain.CarSetupPoints - 6;
  if Brain.laps = 3 then begin
    aCar.TiresMax := 14;
    aCar.BrakesMax := 7;
    aCar.BodyMax := 7;
    aCar.GearMax := 7;
    aCar.EngineMax := 7;
    aCar.SuspensionMax := 7;
  end;

  ShowcarStat ( False, MyCarAccount, StatTires ); // --> True = editing possibile con pulsanti aggiuntivi
  ShowcarStat ( False, MyCarAccount, StatBrakes );
  ShowcarStat ( False, MyCarAccount, StatGear );
  ShowcarStat ( False, MyCarAccount, StatBody );
  ShowcarStat ( False, MyCarAccount, StatEngine );
  ShowcarStat ( False, MyCarAccount, StatSuspension );

end;
procedure TForm3.SetupPitStop;  // abilita img mechanic points, btn scelta gomme, continue, leave box
var
  aCar : TCar;
begin
  // sono visibili i pulsanti per settare i points fino a 2 punti meccanici

  // wet dry dipende dal brain
  if Brain.Track = 0 then
    btnTiresDry.Down := True
    else btnTiresWet.Down := True;

  aCar := Brain.FindCar( MycarAccount ); // lavoro solo sulla mia car
  aCar.Tires := aCar.TiresMax;

  lblPoints.Tag := 2;
  lblPoints.Caption := 'Points: 2';
  // sono visibili i pulsanti per settare i points

  ShowcarStat ( True, MyCarAccount, StatTires ); // --> True = editing possibile con pulsanti aggiuntivi
  ShowcarStat ( True, MyCarAccount, StatBrakes );
  ShowcarStat ( True, MyCarAccount, StatGear );
  ShowcarStat ( True, MyCarAccount, StatBody );
  ShowcarStat ( True, MyCarAccount, StatEngine );
  ShowcarStat ( True, MyCarAccount, StatSuspension );

  // le gomme sono solo settabili dai due btn come treno nuovo
end;
procedure TForm3.SE_GridBodyGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer; Sprite: SE_Sprite);
var
  aCar : TCar;
begin
//  lblPoints.Tag --> Points
  if (Brain.Stage = StageSetupQ) or (Brain.Stage = StageSetupRace) then begin
    aCar := Brain.FindCar( MycarAccount ); // lavoro solo sulla mia car

    if CellX = 1 {Add} then begin
      if lblPoints.Tag > 0 then begin                    // points è il setup 15,18,20
        if aCar.Body + 1 <= aCar.BodyMax  then begin // riferimento ai points del setup
          aCar.Body := aCar.Body + 1;
          lblPoints.Tag:=lblPoints.Tag-1; lblPoints.Caption := 'Points: ' + IntToStr(lblPoints.Tag);
        end;
      end;
    end
    else if CellX = 0 {Del}then begin
      if aCar.Body > 1 then begin
        aCar.Body := aCar.Body - 1;
        lblPoints.Tag:=lblPoints.Tag+1; lblPoints.Caption := 'Points: ' + IntToStr(lblPoints.Tag);
      end;
    end;
    ShowcarStat ( True, MycarAccount, StatBody );
    if lblPoints.Tag = 0 then
      btnConfirmSetup.Enabled := True
      else btnConfirmSetup.Enabled := False;
  end
  else if (Brain.Stage = StagePitStop) then begin
    // durante il pitstop ci sono 2 punti da assegnare e nulla da sottrarre
    if CellX = 1 {Add} then begin
      if lblPoints.Tag > 0 then begin                    // points è i 2 meccanici in race
        if aCar.Body + 1 <= aCar.BodyMax  then begin // riferimento ai points del setup
          aCar.Body := aCar.Body + 1;
          lblPoints.Tag:=lblPoints.Tag-1; lblPoints.Caption := 'Points: ' + IntToStr(lblPoints.Tag);
        end;
      end;
    end
  end;

end;

procedure TForm3.SE_GridBrakesGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer; Sprite: SE_Sprite);
var
  aCar : TCar;
begin
//  lblPoints.Tag --> Points
  if (Brain.Stage = StageSetupQ) or (Brain.Stage = StageSetupRace) then begin
    aCar := Brain.FindCar( MycarAccount ); // lavoro solo sulla mia car

    if CellX = 1 {Add} then begin
      if lblPoints.Tag > 0 then begin                    // points è il setup 15,18,20
        if aCar.Brakes + 1 <= aCar.BrakesMax  then begin // riferimento ai points del setup
          aCar.Brakes := aCar.Brakes + 1;
          lblPoints.Tag:=lblPoints.Tag-1; lblPoints.Caption := 'Points: ' + IntToStr(lblPoints.Tag);
        end;
      end;
    end
    else if CellX = 0 {Del}then begin
      if aCar.Brakes > 1 then begin
        aCar.Brakes := aCar.Brakes - 1;
        lblPoints.Tag:=lblPoints.Tag+1; lblPoints.Caption := 'Points: ' + IntToStr(lblPoints.Tag);
      end;
    end;
    ShowcarStat ( True, MycarAccount, StatBrakes );
    if lblPoints.Tag = 0 then
      btnConfirmSetup.Enabled := True
      else btnConfirmSetup.Enabled := False;
  end
  else if (Brain.Stage = StagePitStop) then begin
    // durante il pitstop ci sono 2 punti da assegnare e nulla da sottrarre
    if CellX = 1 {Add} then begin
      if lblPoints.Tag > 0 then begin                    // points è i 2 meccanici in race
        if aCar.Brakes + 1 <= aCar.BrakesMax  then begin // riferimento ai points del setup
          aCar.Brakes := aCar.Brakes + 1;
          lblPoints.Tag:=lblPoints.Tag-1; lblPoints.Caption := 'Points: ' + IntToStr(lblPoints.Tag);
        end;
      end;
    end
  end;

end;

procedure TForm3.SE_GridEngineGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer; Sprite: SE_Sprite);
var
  aCar : TCar;
begin
//  lblPoints.Tag --> Points
  if (Brain.Stage = StageSetupQ) or (Brain.Stage = StageSetupRace) then begin
    aCar := Brain.FindCar( MycarAccount ); // lavoro solo sulla mia car

    if CellX = 1 {Add} then begin
      if lblPoints.Tag > 0 then begin                    // points è il setup 15,18,20
        if aCar.Engine + 1 <= aCar.EngineMax  then begin // riferimento ai points del setup
          aCar.Engine := aCar.Engine + 1;
          lblPoints.Tag:=lblPoints.Tag-1; lblPoints.Caption := 'Points: ' + IntToStr(lblPoints.Tag);
        end;
      end;
    end
    else if CellX = 0 {Del}then begin
      if aCar.Engine > 1 then begin
        aCar.Engine := aCar.Engine - 1;
        lblPoints.Tag:=lblPoints.Tag+1; lblPoints.Caption := 'Points: ' + IntToStr(lblPoints.Tag);
      end;
    end;
    ShowcarStat ( True, MycarAccount, StatEngine );
    if lblPoints.Tag = 0 then
      btnConfirmSetup.Enabled := True
      else btnConfirmSetup.Enabled := False;
  end
  else if (Brain.Stage = StagePitStop) then begin
    // durante il pitstop ci sono 2 punti da assegnare e nulla da sottrarre
    if CellX = 1 {Add} then begin
      if lblPoints.Tag > 0 then begin                    // points è i 2 meccanici in race
        if aCar.Engine + 1 <= aCar.EngineMax  then begin // riferimento ai points del setup
          aCar.Engine := aCar.Engine + 1;
          lblPoints.Tag:=lblPoints.Tag-1; lblPoints.Caption := 'Points: ' + IntToStr(lblPoints.Tag);
        end;
      end;
    end
  end;

end;

procedure TForm3.SE_GridGearGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer;Sprite: SE_Sprite);
var
  aCar : TCar;
begin
//  lblPoints.Tag --> Points
  if (Brain.Stage = StageSetupQ) or (Brain.Stage = StageSetupRace) then begin
    aCar := Brain.FindCar( MycarAccount ); // lavoro solo sulla mia car

    if CellX = 1 {Add} then begin
      if lblPoints.Tag > 0 then begin                    // points è il setup 15,18,20
        if aCar.Gear + 1 <= aCar.GearMax  then begin // riferimento ai points del setup
          aCar.Gear := aCar.Gear + 1;
          lblPoints.Tag:=lblPoints.Tag-1; lblPoints.Caption := 'Points: ' + IntToStr(lblPoints.Tag);
        end;
      end;
    end
    else if CellX = 0 {Del}then begin
      if aCar.Gear > 1 then begin
        aCar.Gear := aCar.Gear - 1;
        lblPoints.Tag:=lblPoints.Tag+1; lblPoints.Caption := 'Points: ' + IntToStr(lblPoints.Tag);
      end;
    end;
    ShowcarStat ( True, MycarAccount, StatGear );
    if lblPoints.Tag = 0 then
      btnConfirmSetup.Enabled := True
      else btnConfirmSetup.Enabled := False;
  end
  else if (Brain.Stage = StagePitStop) then begin
    // durante il pitstop ci sono 2 punti da assegnare e nulla da sottrarre
    if CellX = 1 {Add} then begin
      if lblPoints.Tag > 0 then begin                    // points è i 2 meccanici in race
        if aCar.Gear + 1 <= aCar.GearMax  then begin // riferimento ai points del setup
          aCar.Gear := aCar.Gear + 1;
          lblPoints.Tag:=lblPoints.Tag-1; lblPoints.Caption := 'Points: ' + IntToStr(lblPoints.Tag);
        end;
      end;
    end
  end;

end;

procedure TForm3.SE_GridSuspensionGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer; Sprite: SE_Sprite);
var
  aCar : TCar;
begin
//  lblPoints.Tag --> Points
  if (Brain.Stage = StageSetupQ) or (Brain.Stage = StageSetupRace) then begin
    aCar := Brain.FindCar( MycarAccount ); // lavoro solo sulla mia car

    if CellX = 1 {Add} then begin
      if lblPoints.Tag > 0 then begin                    // points è il setup 15,18,20
        if aCar.Suspension + 1 <= aCar.SuspensionMax  then begin // riferimento ai points del setup
          aCar.Suspension := aCar.Suspension + 1;
          lblPoints.Tag:=lblPoints.Tag-1; lblPoints.Caption := 'Points: ' + IntToStr(lblPoints.Tag);
        end;
      end;
    end
    else if CellX = 0 {Del}then begin
      if aCar.Suspension > 1 then begin
        aCar.Suspension := aCar.Suspension - 1;
        lblPoints.Tag:=lblPoints.Tag+1; lblPoints.Caption := 'Points: ' + IntToStr(lblPoints.Tag);
      end;
    end;
    ShowcarStat ( True, MycarAccount, StatSuspension );
    if lblPoints.Tag = 0 then
      btnConfirmSetup.Enabled := True
      else btnConfirmSetup.Enabled := False;
  end
  else if (Brain.Stage = StagePitStop) then begin
    // durante il pitstop ci sono 2 punti da assegnare e nulla da sottrarre
    if CellX = 1 {Add} then begin
      if lblPoints.Tag > 0 then begin                    // points è i 2 meccanici in race
        if aCar.Suspension + 1 <= aCar.SuspensionMax  then begin // riferimento ai points del setup
          aCar.Suspension := aCar.Suspension + 1;
          lblPoints.Tag:=lblPoints.Tag-1; lblPoints.Caption := 'Points: ' + IntToStr(lblPoints.Tag);
        end;
      end;
    end
  end;

end;

procedure TForm3.SE_GridTiresGridCellMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; CellX, CellY: Integer; Sprite: SE_Sprite);
var
  aCar : TCar;
begin
//  lblPoints.Tag --> Points
  if (Brain.Stage = StageSetupQ) or (Brain.Stage = StageSetupRace) then begin
    aCar := Brain.FindCar( MycarAccount ); // lavoro solo sulla mia car

    if CellX = 1 {Add} then begin
      if lblPoints.Tag > 0 then begin                    // points è il setup 15,18,20
        if aCar.Tires + 1 <= aCar.TiresMax  then begin // riferimento ai points del setup
          aCar.Tires := aCar.Tires + 1;
          lblPoints.Tag:=lblPoints.Tag-1;  lblPoints.Caption := 'Points: ' + IntToStr(lblPoints.Tag);
        end;
      end;
    end
    else if CellX = 0 {Del}then begin
      if aCar.Tires > 1 then begin
        aCar.Tires := aCar.Tires - 1;
        lblPoints.Tag:=lblPoints.Tag+1; lblPoints.Caption := 'Points: ' + IntToStr(lblPoints.Tag);
      end;
    end;
    ShowcarStat ( True, MycarAccount, StatTires );
    if lblPoints.Tag = 0 then
      btnConfirmSetup.Enabled := True
      else btnConfirmSetup.Enabled := False;
  end
  else if (Brain.Stage = StagePitStop) then begin
    // durante il pitstop non può modificare le tires, ma solo cambiare l'intero treno
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
    w := 32;
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
    if i > 1 then
      Grid.Columns[i].Width := w
      else Grid.Columns[i].Width := 20;

  end;

  Grid.Rows[0].Height := h;
  Grid.Height := h;

  Grid.Width := (w * (Grid.ColCount -2) ) + 40 ;  //<-- 20+20 di plus e minus

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
