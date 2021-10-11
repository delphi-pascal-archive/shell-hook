object Form1: TForm1
  Left = 238
  Top = 129
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Shell Hook'
  ClientHeight = 393
  ClientWidth = 699
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnActivate = FormActivate
  OnDestroy = FormDestroy
  PixelsPerInch = 120
  TextHeight = 16
  object ListView1: TListView
    Left = 8
    Top = 8
    Width = 681
    Height = 345
    Columns = <
      item
        Caption = 'Message'
        Width = 185
      end
      item
        Caption = 'Class Name'
        Width = 148
      end
      item
        Caption = 'Exe Path'
        Width = 246
      end
      item
        AutoSize = True
        Caption = 'Handle'
      end>
    RowSelect = True
    SmallImages = ImageList1
    TabOrder = 0
    ViewStyle = vsReport
    OnCustomDrawItem = ListView1CustomDrawItem
  end
  object Button1: TButton
    Left = 8
    Top = 360
    Width = 121
    Height = 25
    Caption = 'Start Hook'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 136
    Top = 360
    Width = 121
    Height = 25
    Caption = 'Stop Hook'
    Enabled = False
    TabOrder = 2
    OnClick = Button2Click
  end
  object CheckBox1: TCheckBox
    Left = 584
    Top = 360
    Width = 105
    Height = 17
    Caption = 'Stay On Top'
    Checked = True
    State = cbChecked
    TabOrder = 3
    OnClick = CheckBox1Click
  end
  object ImageList1: TImageList
    BlendColor = clWhite
    BkColor = clWhite
    DrawingStyle = dsTransparent
    Left = 24
    Top = 44
  end
end
