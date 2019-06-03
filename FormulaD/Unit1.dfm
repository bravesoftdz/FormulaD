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
  OnDestroy = FormDestroy
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
      Caption = 'Exit'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 4308735
      Font.Height = -21
      Font.Name = 'Calibri'
      Font.Style = [fsBold]
      Margin = 4
      ParentFont = False
      OnClick = btnExitClick
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
    Visible = False
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
      Left = 238
      Top = 102
      Width = 26
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
      Left = 332
      Top = 489
      Width = 169
      Height = 32
      Cursor = crHandPoint
      Color = clGray
      DownBold = False
      FlatBorder = False
      HotTrackBold = False
      Caption = 'Start Game'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clLime
      Font.Height = -21
      Font.Name = 'Calibri'
      Font.Style = [fsBold]
      Margin = 4
      ParentFont = False
      OnClick = btnStartGameClick
    end
    object lblCarSetup: TLabel
      Left = 8
      Top = 388
      Width = 97
      Height = 16
      AutoSize = False
      Caption = 'Car Setup:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object btnStartServer: TCnSpeedButton
      Left = 8
      Top = 489
      Width = 318
      Height = 32
      Cursor = crHandPoint
      Color = clGray
      DownBold = False
      FlatBorder = False
      HotTrackBold = False
      Caption = 'Start Server'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clLime
      Font.Height = -21
      Font.Name = 'Calibri'
      Font.Style = [fsBold]
      Margin = 4
      ParentFont = False
      OnClick = btnStartServerClick
    end
    object lblServerPwd: TLabel
      Left = 8
      Top = 467
      Width = 65
      Height = 16
      AutoSize = False
      Caption = 'Password:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblServerPort: TLabel
      Left = 203
      Top = 467
      Width = 73
      Height = 16
      AutoSize = False
      Caption = 'Server Port:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object btnCancelGame: TCnSpeedButton
      Left = 332
      Top = 451
      Width = 169
      Height = 32
      Cursor = crHandPoint
      Color = clGray
      DownBold = False
      FlatBorder = False
      HotTrackBold = False
      Caption = 'Cancel'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 8454143
      Font.Height = -21
      Font.Name = 'Calibri'
      Font.Style = [fsBold]
      Margin = 4
      ParentFont = False
      OnClick = btnCancelGameClick
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
      OnCloseUp = cbLapsCloseUp
    end
    object SE_GridWeather: SE_Grid
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
      OnGridCellMouseDown = SE_GridWeatherGridCellMouseDown
      CellBorder = CellBorderNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
    end
    object cbHumanPlayers: TComboBox
      Left = 111
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
      Left = 270
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
    object SE_GridSetupPlayers: SE_Grid
      Left = 8
      Top = 124
      Width = 313
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
      OnGridCellMouseDown = SE_GridSetupPlayersGridCellMouseDown
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
      TabOrder = 6
      OnGridCellMouseDown = SE_GridQualGridCellMouseDown
      CellBorder = CellBorderNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
    end
    object EdtPwd: TEdit
      Left = 79
      Top = 462
      Width = 121
      Height = 21
      TabOrder = 7
      Text = 'Password'
    end
    object edtPort: TEdit
      Left = 285
      Top = 462
      Width = 41
      Height = 21
      NumbersOnly = True
      TabOrder = 8
      Text = '2019'
    end
    object SE_GridCarColor: SE_Grid
      Left = 399
      Top = 124
      Width = 82
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
      Visible = False
      TabOrder = 9
      OnGridCellMouseDown = SE_GridCarColorGridCellMouseDown
      CellBorder = CellBorderNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
    end
    object cbCarSetup: TComboBox
      Left = 80
      Top = 385
      Width = 241
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
      TabOrder = 10
    end
  end
  object SE_Panel1: SE_Panel
    Left = 24
    Top = 24
    Width = 337
    Height = 321
    TabOrder = 2
    object Button1: TButton
      Tag = 1
      Left = 64
      Top = 53
      Width = 113
      Height = 25
      Caption = 'Connect Client 1'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Tag = 2
      Left = 64
      Top = 123
      Width = 113
      Height = 25
      Caption = 'Connect Client 2'
      TabOrder = 1
      OnClick = Button1Click
    end
    object Button3: TButton
      Tag = 3
      Left = 64
      Top = 180
      Width = 113
      Height = 25
      Caption = 'Connect Client 3'
      TabOrder = 2
      OnClick = Button1Click
    end
    object Button4: TButton
      Tag = 4
      Left = 64
      Top = 243
      Width = 113
      Height = 25
      Caption = 'Connect Client 4'
      TabOrder = 3
      OnClick = Button1Click
    end
  end
  object PanelCarSetup: SE_Panel
    Left = 37
    Top = 452
    Width = 241
    Height = 125
    BevelOuter = bvNone
    Color = 8081721
    ParentBackground = False
    TabOrder = 3
    Visible = False
    object SE_GridCarSetup: SE_Grid
      Left = 23
      Top = 8
      Width = 82
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
      Visible = False
      TabOrder = 0
      OnGridCellMouseDown = SE_GridCarColorGridCellMouseDown
      CellBorder = CellBorderNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
    end
  end
  object SE_Theater1: SE_Theater
    Left = 336
    Top = 740
    Width = 100
    Height = 100
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
    VirtualWidth = 212
    Virtualheight = 212
    TabOrder = 4
  end
  object SE_SearchFiles1: SE_SearchFiles
    SubDirectories = True
    Left = 272
    Top = 616
  end
  object Tcpserver: TWSocketThrdServer
    LineLimit = 1024
    LineEnd = #13#10
    OnLineLimitExceeded = TcpserverLineLimitExceeded
    Proto = 'tcp'
    LocalAddr = '0.0.0.0'
    LocalAddr6 = '::'
    LocalPort = '0'
    SocksLevel = '5'
    ExclusiveAddr = False
    ComponentOptions = []
    OnDataAvailable = TcpserverDataAvailable
    OnBgException = TcpserverBgException
    SocketErrs = wsErrTech
    OnClientDisconnect = TcpserverClientDisconnect
    OnClientConnect = TcpserverClientConnect
    MultiListenSockets = <>
    ClientsPerThread = 1
    Left = 264
    Top = 672
    Banner = ''
  end
  object tcp: TWSocket
    LineLimit = 1024
    LineEnd = #13#10
    Proto = 'tcp'
    LocalAddr = '0.0.0.0'
    LocalAddr6 = '::'
    LocalPort = '0'
    SocksLevel = '5'
    ExclusiveAddr = False
    ComponentOptions = []
    OnSessionConnected = tcpSessionConnected
    SocketErrs = wsErrTech
    Left = 39
    Top = 34
  end
  object WSocket1: TWSocket
    LineLimit = 1024
    LineEnd = #13#10
    Proto = 'tcp'
    LocalAddr = '0.0.0.0'
    LocalAddr6 = '::'
    LocalPort = '0'
    SocksLevel = '5'
    ExclusiveAddr = False
    ComponentOptions = []
    OnSessionConnected = tcpSessionConnected
    SocketErrs = wsErrTech
    Left = 39
    Top = 82
  end
  object WSocket2: TWSocket
    LineLimit = 1024
    LineEnd = #13#10
    Proto = 'tcp'
    LocalAddr = '0.0.0.0'
    LocalAddr6 = '::'
    LocalPort = '0'
    SocksLevel = '5'
    ExclusiveAddr = False
    ComponentOptions = []
    OnSessionConnected = tcpSessionConnected
    SocketErrs = wsErrTech
    Left = 39
    Top = 146
  end
  object WSocket3: TWSocket
    LineLimit = 1024
    LineEnd = #13#10
    Proto = 'tcp'
    LocalAddr = '0.0.0.0'
    LocalAddr6 = '::'
    LocalPort = '0'
    SocksLevel = '5'
    ExclusiveAddr = False
    ComponentOptions = []
    OnSessionConnected = tcpSessionConnected
    SocketErrs = wsErrTech
    Left = 39
    Top = 210
  end
  object WSocket4: TWSocket
    LineLimit = 1024
    LineEnd = #13#10
    Proto = 'tcp'
    LocalAddr = '0.0.0.0'
    LocalAddr6 = '::'
    LocalPort = '0'
    SocksLevel = '5'
    ExclusiveAddr = False
    ComponentOptions = []
    OnSessionConnected = tcpSessionConnected
    SocketErrs = wsErrTech
    Left = 39
    Top = 266
  end
  object SE_EngineCars: SE_Engine
    PixelCollision = False
    IsoPriority = False
    Priority = 1
    Theater = SE_Theater1
    Left = 520
    Top = 736
  end
  object SE_EngineBack: SE_Engine
    ClickSprites = False
    PixelCollision = False
    IsoPriority = False
    Priority = 0
    Theater = SE_Theater1
    Left = 455
    Top = 736
  end
end
