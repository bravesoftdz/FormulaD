object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 862
  ClientWidth = 1424
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object SE_Theater1: SE_Theater
    Left = 16
    Top = 8
    Width = 1200
    Height = 857
    MouseScrollRate = 1.000000000000000000
    MouseWheelInvert = False
    MouseWheelValue = 10
    MouseWheelZoom = True
    MousePan = True
    MouseScroll = False
    BackColor = clBlack
    AnimationInterval = 20
    GridInfoCell = False
    GridVisible = False
    GridColor = clSilver
    GridCellWidth = 40
    GridCellHeight = 30
    GridCellsX = 10
    GridCellsY = 4
    GridHexSmallWidth = 10
    CollisionDelay = 0
    ShowPerformance = False
    OnSpriteMouseMove = SE_Theater1SpriteMouseMove
    OnSpriteMouseDown = SE_Theater1SpriteMouseDown
    OnTheaterMouseMove = SE_Theater1TheaterMouseMove
    OnTheaterMouseDown = SE_Theater1TheaterMouseDown
    OnTheaterMouseUp = SE_Theater1TheaterMouseUp
    VirtualWidth = 212
    Virtualheight = 212
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 1214
    Top = 8
    Width = 202
    Height = 65
    TabOrder = 1
    Visible = False
    object Label1: TLabel
      Left = 8
      Top = 26
      Width = 23
      Height = 13
      Caption = 'Lane'
    end
    object CnSpinEdit1: TCnSpinEdit
      Left = 72
      Top = 18
      Width = 57
      Height = 29
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      MaxValue = 2
      MinValue = -2
      ParentFont = False
      TabOrder = 0
      Value = 0
    end
  end
  object Panel2: TPanel
    Left = 1214
    Top = 79
    Width = 202
    Height = 66
    TabOrder = 2
    Visible = False
    object Label2: TLabel
      Left = 9
      Top = 16
      Width = 33
      Height = 13
      Caption = 'Corner'
    end
    object CnSpinEdit2: TCnSpinEdit
      Left = 72
      Top = 16
      Width = 57
      Height = 29
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      MaxValue = 100
      MinValue = 0
      ParentFont = False
      TabOrder = 0
      Value = 0
    end
  end
  object Button1: TButton
    Left = 1322
    Top = 711
    Width = 75
    Height = 25
    Caption = 'Save'
    TabOrder = 3
    OnClick = Button1Click
  end
  object PanelLoad: TPanel
    Left = 1214
    Top = 351
    Width = 202
    Height = 354
    TabOrder = 4
    Visible = False
    object StringGrid2: TStringGrid
      Left = 8
      Top = 9
      Width = 137
      Height = 328
      ColCount = 1
      DefaultColWidth = 120
      DefaultRowHeight = 18
      FixedCols = 0
      RowCount = 4
      FixedRows = 0
      Options = []
      ScrollBars = ssVertical
      TabOrder = 0
      OnSelectCell = StringGrid2SelectCell
    end
  end
  object Button2: TButton
    Left = 1214
    Top = 711
    Width = 75
    Height = 25
    Caption = 'Load'
    TabOrder = 5
    OnClick = Button2Click
  end
  object Panel3: TPanel
    Left = 1214
    Top = 151
    Width = 202
    Height = 66
    TabOrder = 6
    Visible = False
    object Label3: TLabel
      Left = 8
      Top = 25
      Width = 60
      Height = 13
      Caption = 'Starting Grid'
    end
    object CnSpinEdit3: TCnSpinEdit
      Left = 74
      Top = 20
      Width = 57
      Height = 29
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      MaxValue = 10
      MinValue = 0
      ParentFont = False
      TabOrder = 0
      Value = 0
    end
  end
  object Panel4: TPanel
    Left = 1214
    Top = 223
    Width = 202
    Height = 58
    TabOrder = 7
    Visible = False
    object Label4: TLabel
      Left = 16
      Top = 17
      Width = 18
      Height = 13
      Caption = 'Box'
    end
    object CnSpinEdit4: TCnSpinEdit
      Left = 74
      Top = 12
      Width = 57
      Height = 29
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      MaxValue = 100
      MinValue = 0
      ParentFont = False
      TabOrder = 0
      Value = 0
    end
  end
  object Panel5: TPanel
    Left = 1214
    Top = 287
    Width = 202
    Height = 58
    TabOrder = 8
    Visible = False
    object Label5: TLabel
      Left = 16
      Top = 17
      Width = 41
      Height = 13
      Caption = 'Distance'
    end
    object CnSpinEdit5: TCnSpinEdit
      Left = 74
      Top = 12
      Width = 57
      Height = 29
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      MaxValue = 100
      MinValue = 0
      ParentFont = False
      TabOrder = 0
      Value = 0
    end
    object CnSpinEdit6: TCnSpinEdit
      Left = 137
      Top = 12
      Width = 57
      Height = 29
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      MaxValue = 100
      MinValue = 0
      ParentFont = False
      TabOrder = 1
      Value = 0
    end
  end
  object PanelMode: TPanel
    Left = 1214
    Top = 807
    Width = 202
    Height = 58
    TabOrder = 9
    object LabelMode: TLabel
      Left = 16
      Top = 17
      Width = 5
      Height = 19
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
  object Button3: TButton
    Left = 1214
    Top = 742
    Width = 75
    Height = 25
    Caption = 'Reset Guid'
    TabOrder = 10
    Visible = False
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 1322
    Top = 742
    Width = 75
    Height = 25
    Caption = 'Remove Duplicate'
    TabOrder = 11
    Visible = False
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 1322
    Top = 773
    Width = 75
    Height = 25
    Caption = 'Check Integrity'
    TabOrder = 12
    Visible = False
    OnClick = Button5Click
  end
  object Panel6: TPanel
    Left = 1214
    Top = 287
    Width = 202
    Height = 58
    TabOrder = 13
    Visible = False
    object Label6: TLabel
      Left = 16
      Top = 17
      Width = 47
      Height = 13
      Caption = 'Car Angle'
    end
    object CnSpinEdit7: TCnSpinEdit
      Left = 74
      Top = 12
      Width = 57
      Height = 29
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      MaxValue = 360
      MinValue = -360
      ParentFont = False
      TabOrder = 0
      Value = 0
    end
  end
  object SE_Engine1: SE_Engine
    ClickSprites = False
    PixelCollision = False
    IsoPriority = False
    Priority = 0
    Theater = SE_Theater1
    Left = 1231
    Top = 760
  end
  object SE_Engine2: SE_Engine
    PixelClick = True
    PixelCollision = False
    IsoPriority = False
    Priority = 2
    Theater = SE_Theater1
    Left = 1279
    Top = 760
  end
  object SE_SearchFiles1: SE_SearchFiles
    SubDirectories = True
    Left = 1383
    Top = 760
  end
  object SE_EngineCars: SE_Engine
    ClickSprites = False
    PixelCollision = False
    IsoPriority = False
    Priority = 1
    Theater = SE_Theater1
    Left = 1287
    Top = 720
  end
end
