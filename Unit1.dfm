object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 681
  ClientWidth = 1022
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
    Left = 8
    Top = 8
    Width = 825
    Height = 577
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
    OnSpriteMouseDown = SE_Theater1SpriteMouseDown
    OnTheaterMouseMove = SE_Theater1TheaterMouseMove
    OnTheaterMouseDown = SE_Theater1TheaterMouseDown
    OnTheaterMouseUp = SE_Theater1TheaterMouseUp
    VirtualWidth = 212
    Virtualheight = 212
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 839
    Top = 8
    Width = 185
    Height = 65
    TabOrder = 1
    Visible = False
    object Label1: TLabel
      Left = 8
      Top = 8
      Width = 23
      Height = 13
      Caption = 'Lane'
    end
    object CnSpinEdit1: TCnSpinEdit
      Left = 8
      Top = 24
      Width = 41
      Height = 22
      MaxValue = 2
      MinValue = -1
      TabOrder = 0
      Value = 0
    end
  end
  object Panel2: TPanel
    Left = 839
    Top = 79
    Width = 185
    Height = 66
    TabOrder = 2
    Visible = False
    object Label2: TLabel
      Left = 8
      Top = 9
      Width = 33
      Height = 13
      Caption = 'Corner'
    end
    object CnSpinEdit2: TCnSpinEdit
      Left = 8
      Top = 28
      Width = 41
      Height = 22
      MaxValue = 100
      MinValue = 0
      TabOrder = 0
      Value = 0
    end
  end
  object Button1: TButton
    Left = 939
    Top = 632
    Width = 75
    Height = 25
    Caption = 'Save'
    TabOrder = 3
    OnClick = Button1Click
  end
  object Panel4: TPanel
    Left = 839
    Top = 223
    Width = 185
    Height = 403
    TabOrder = 4
    object StringGrid2: TStringGrid
      Left = 8
      Top = 9
      Width = 137
      Height = 360
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
    Left = 839
    Top = 632
    Width = 75
    Height = 25
    Caption = 'Load'
    TabOrder = 5
    OnClick = Button2Click
  end
  object Panel3: TPanel
    Left = 839
    Top = 151
    Width = 185
    Height = 66
    TabOrder = 6
    Visible = False
    object Label3: TLabel
      Left = 8
      Top = 9
      Width = 60
      Height = 13
      Caption = 'Starting Grid'
    end
    object CnSpinEdit3: TCnSpinEdit
      Left = 8
      Top = 28
      Width = 41
      Height = 22
      MaxValue = 100
      MinValue = 0
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
    Left = 472
    Top = 592
  end
  object SE_Engine2: SE_Engine
    PixelClick = True
    PixelCollision = False
    IsoPriority = False
    Priority = 1
    Theater = SE_Theater1
    Left = 520
    Top = 592
  end
  object SE_Engine3: SE_Engine
    ClickSprites = False
    PixelCollision = False
    IsoPriority = False
    Priority = 0
    Theater = SE_Theater1
    RenderBitmap = VisibleRender
    Left = 576
    Top = 592
  end
  object SE_Engine4: SE_Engine
    PixelClick = True
    PixelCollision = False
    IsoPriority = False
    Priority = 2
    Theater = SE_Theater1
    Left = 624
    Top = 592
  end
  object SE_SearchFiles1: SE_SearchFiles
    SubDirectories = True
    Left = 688
    Top = 584
  end
end
