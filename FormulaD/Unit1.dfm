object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'FormulaD'
  ClientHeight = 862
  ClientWidth = 1424
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PanelMain: SE_Panel
    Left = 509
    Top = 60
    Width = 241
    Height = 125
    BevelOuter = bvNone
    Color = 8081721
    ParentBackground = False
    TabOrder = 0
    object btnCreateGame: TCnSpeedButton
      Left = 3
      Top = 17
      Width = 233
      Height = 32
      Cursor = crHandPoint
      Color = clGray
      DownBold = False
      FlatBorder = False
      HotTrackBold = False
      Caption = 'Create Game'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 4308735
      Font.Height = -21
      Font.Name = 'Calibri'
      Font.Style = [fsBold]
      Margin = 4
      ParentFont = False
      OnClick = btnCreateGameClick
    end
    object btnJoinGame: TCnSpeedButton
      Left = 3
      Top = 49
      Width = 233
      Height = 32
      Cursor = crHandPoint
      Color = clGray
      DownBold = False
      FlatBorder = False
      HotTrackBold = False
      Caption = 'Join Game'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 4308735
      Font.Height = -21
      Font.Name = 'Calibri'
      Font.Style = [fsBold]
      Margin = 4
      ParentFont = False
    end
    object btnExit: TCnSpeedButton
      Left = 3
      Top = 80
      Width = 233
      Height = 32
      Cursor = crHandPoint
      Color = clGray
      DownBold = False
      FlatBorder = False
      HotTrackBold = False
      Caption = 'btnExit'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 4308735
      Font.Height = -21
      Font.Name = 'Calibri'
      Font.Style = [fsBold]
      Margin = 4
      ParentFont = False
    end
  end
  object PanelCreateGame: SE_Panel
    Left = 394
    Top = 191
    Width = 503
    Height = 530
    BevelOuter = bvNone
    Color = 8081721
    ParentBackground = False
    TabOrder = 1
    object lblCircuit: TLabel
      Left = 8
      Top = 16
      Width = 50
      Height = 16
      AutoSize = False
      Caption = 'Circuit:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblLap: TLabel
      Left = 368
      Top = 60
      Width = 58
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Laps:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblWeather: TLabel
      Left = 8
      Top = 60
      Width = 50
      Height = 16
      AutoSize = False
      Caption = 'Weather:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblHumanPlayers: TLabel
      Left = 8
      Top = 100
      Width = 97
      Height = 16
      AutoSize = False
      Caption = 'Human Players:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblCPU: TLabel
      Left = 329
      Top = 100
      Width = 97
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'CPU:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblQual: TLabel
      Left = 289
      Top = 16
      Width = 89
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Qualifications:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object btnStartGame: TCnSpeedButton
      Left = 123
      Top = 481
      Width = 233
      Height = 32
      Cursor = crHandPoint
      Color = clGray
      DownBold = False
      FlatBorder = False
      HotTrackBold = False
      Caption = 'Start'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 4308735
      Font.Height = -21
      Font.Name = 'Calibri'
      Font.Style = [fsBold]
      Margin = 4
      ParentFont = False
      OnClick = btnStartGameClick
    end
    object cbCircuit: TComboBox
      Left = 64
      Top = 16
      Width = 177
      Height = 22
      BevelEdges = []
      BevelInner = bvNone
      BevelOuter = bvNone
      Style = csOwnerDrawFixed
      Color = 8081721
      Ctl3D = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 0
    end
    object cbLaps: TComboBox
      Left = 440
      Top = 57
      Width = 41
      Height = 22
      BevelEdges = []
      BevelInner = bvNone
      BevelOuter = bvNone
      Style = csOwnerDrawFixed
      Color = 8081721
      Ctl3D = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      MaxLength = 1
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 1
    end
    object SE_GridWheater: SE_Grid
      Left = 64
      Top = 56
      Width = 256
      Height = 24
      Cursor = crHandPoint
      MouseScrollRate = 1.000000000000000000
      MouseWheelInvert = False
      MouseWheelValue = 10
      MouseWheelZoom = False
      MousePan = False
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
      VirtualWidth = 212
      Virtualheight = 212
      Passive = True
      TabOrder = 2
      OnGridCellMouseDown = SE_GridWheaterGridCellMouseDown
      CellBorder = CellBorderNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
    end
    object cbHumanPlayers: TComboBox
      Left = 128
      Top = 96
      Width = 49
      Height = 22
      BevelEdges = []
      BevelInner = bvNone
      BevelOuter = bvNone
      Style = csOwnerDrawFixed
      Color = 8081721
      Ctl3D = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      MaxLength = 2
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 3
      OnCloseUp = cbHumanPlayersCloseUp
    end
    object cbCPU: TComboBox
      Left = 432
      Top = 96
      Width = 49
      Height = 22
      BevelEdges = []
      BevelInner = bvNone
      BevelOuter = bvNone
      Style = csOwnerDrawFixed
      Color = 8081721
      Ctl3D = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      MaxLength = 2
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 4
      OnCloseUp = cbCPUCloseUp
    end
    object SE_GridHumanPlayers: SE_Grid
      Left = 8
      Top = 124
      Width = 233
      Height = 101
      Cursor = crHandPoint
      MouseScrollRate = 1.000000000000000000
      MouseWheelInvert = False
      MouseWheelValue = 10
      MouseWheelZoom = False
      MousePan = False
      MouseScroll = False
      BackColor = 8081721
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
      VirtualWidth = 212
      Virtualheight = 212
      Passive = True
      TabOrder = 5
      OnGridCellMouseDown = SE_GridWheaterGridCellMouseDown
      CellBorder = CellBorderNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
    end
    object SE_GridCPU: SE_Grid
      Left = 247
      Top = 124
      Width = 233
      Height = 101
      Cursor = crHandPoint
      MouseScrollRate = 1.000000000000000000
      MouseWheelInvert = False
      MouseWheelValue = 10
      MouseWheelZoom = False
      MousePan = False
      MouseScroll = False
      BackColor = 8081721
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
      VirtualWidth = 212
      Virtualheight = 212
      Passive = True
      TabOrder = 6
      OnGridCellMouseDown = SE_GridWheaterGridCellMouseDown
      CellBorder = CellBorderNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
    end
    object SE_GridQual: SE_Grid
      Left = 384
      Top = 14
      Width = 102
      Height = 24
      Cursor = crHandPoint
      MouseScrollRate = 1.000000000000000000
      MouseWheelInvert = False
      MouseWheelValue = 10
      MouseWheelZoom = False
      MousePan = False
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
      VirtualWidth = 212
      Virtualheight = 212
      Passive = True
      TabOrder = 7
      OnGridCellMouseDown = SE_GridQualGridCellMouseDown
      CellBorder = CellBorderNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
    end
    object EdtPwd: TEdit
      Left = 8
      Top = 440
      Width = 121
      Height = 21
      TabOrder = 8
      Text = 'Password!'
    end
    object edtPort: TEdit
      Left = 256
      Top = 440
      Width = 121
      Height = 21
      NumbersOnly = True
      TabOrder = 9
      Text = '2019'
    end
  end
  object SE_SearchFiles1: SE_SearchFiles
    SubDirectories = True
    Left = 272
    Top = 616
  end
  object Tcpserver: TWSocketThrdServer
    LineLimit = 1024
    LineEnd = #13#10
    Proto = 'tcp'
    LocalAddr = '0.0.0.0'
    LocalAddr6 = '::'
    LocalPort = '0'
    SocksLevel = '5'
    ExclusiveAddr = False
    ComponentOptions = []
    SocketErrs = wsErrTech
    MultiListenSockets = <>
    ClientsPerThread = 1
    Left = 264
    Top = 672
    Banner = ''
  end
end
