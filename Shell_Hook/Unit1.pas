{Автор Зорков Игорь - zorkovigor@mail.ru}

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, ShlObj, ActiveX, ShellAPI,
  PsAPI, ImgList;

type
  TForm1 = class(TForm)
    ListView1: TListView;
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    ImageList1: TImageList;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure ListView1CustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
  protected
    procedure WndProc(var Msg: TMessage); override;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  MHSHELL_WINDOWACTIVATED: Cardinal;
  MHSHELL_WINDOWCREATED: Cardinal;
  MHSHELL_WINDOWDESTROYED: Cardinal;
  HookEnable: Boolean = False;

  {Сначала откройте и скомпилируйте проект SHELLHook
  (File->Open Project...->SHELLHook.dpr)
  Project->Compile SHELLHook}

  function StartMouseHook(State: Boolean; Wnd: HWND): Boolean; stdcall; external 'SHELLHook.dll';
  function StopMouseHook(): Boolean; stdcall; external 'SHELLHook.dll';

implementation

{$R *.dfm}

function GetIcon(const FileName: string):
  TIcon;
var
  FileInfo: TShFileInfo;
  ImageList: TImageList;
begin
  Result := TIcon.Create;
  ImageList := TImageList.Create(nil);
  FillChar(FileInfo, Sizeof(FileInfo), #0);
  ImageList.ShareImages := true;
  ImageList.Handle := SHGetFileInfo(
    PChar(FileName),
    SFGAO_SHARE,
    FileInfo,
    SizeOf(FileInfo),
    SHGFI_SMALLICON or SHGFI_SYSICONINDEX
    );
  ImageList.GetIcon(FileInfo.iIcon, Result);
  ImageList.Free;
end;

function GetWndClassName(Wnd: HWND): String;
var
  WndClassName: array[0..256] of Char;
begin
  if GetClassName(Wnd, WndClassName, 256) <> 0 then
    Result:= WndClassName
  else
    Result:= '';
end;

function GetWndExePath(Wnd: HWND): String;
var
  ProcessHandle: THANDLE;
  ProcessId: DWORD;
  ExePath: array[0..256] of Char;
begin
  GetWindowThreadProcessId(Wnd, ProcessId);
  ProcessHandle:= OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, ProcessId);
  if GetModuleFileNameEx(ProcessHandle, 0, ExePath, 256) <> 0 then
    Result:= ExePath
  else
    Result:= '';
end;

procedure TForm1.WndProc(var Msg: TMessage);
begin
  inherited;
  if (Msg.Msg = MHSHELL_WINDOWCREATED) then
  begin
    ImageList1.AddIcon(GetIcon(GetWndExePath(Msg.LParam)));
    with ListView1.Items.Insert(0) do
    begin
      Caption:= 'HSHELL_WINDOWCREATED';
      SubItems.Add(GetWndClassName(Msg.LParam));
      SubItems.Add(GetWndExePath(Msg.LParam));
      SubItems.Add(IntToStr(Msg.LParam));
      ImageIndex:= ImageList1.Count - 1;
      Data:= Pointer(clLime);
    end;
  end;
  if (Msg.Msg = MHSHELL_WINDOWDESTROYED) then
  begin
    ImageList1.AddIcon(GetIcon(GetWndExePath(Msg.LParam)));
    with ListView1.Items.Insert(0) do
    begin
      Caption:= 'HSHELL_WINDOWDESTROYED';
      SubItems.Add(GetWndClassName(Msg.LParam));
      SubItems.Add(GetWndExePath(Msg.LParam));
      SubItems.Add(IntToStr(Msg.LParam));
      ImageIndex:= ImageList1.Count - 1;
      Data:= Pointer(clRed);
    end;
  end;
  if (Msg.Msg = MHSHELL_WINDOWACTIVATED) then
  begin
    ImageList1.AddIcon(GetIcon(GetWndExePath(Msg.LParam)));
    with ListView1.Items.Insert(0) do
    begin
      Caption:= 'HSHELL_WINDOWACTIVATED';
      SubItems.Add(GetWndClassName(Msg.LParam));
      SubItems.Add(GetWndExePath(Msg.LParam));
      SubItems.Add(IntToStr(Msg.LParam));
      ImageIndex:= ImageList1.Count - 1;
      Data:= Pointer(RGB(240, 240, 240));
    end;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
 if StartMouseHook(True, Handle) = True then
  begin
    HookEnable:= True;
    Button1.Enabled:= False;
    Button2.Enabled:= True;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if StopMouseHook = True then
  begin
    HookEnable:= False;
    Button1.Enabled:= True;
    Button2.Enabled:= False;
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if HookEnable <> False then
    StopMouseHook;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  if CheckBox1.Checked then
    SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE);
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  if CheckBox1.Checked then
    SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE)
  else
    SetWindowPos(Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE);
end;

procedure TForm1.ListView1CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  Sender.Canvas.Brush.Color := TColor(Item.Data);
end;

initialization
  MHSHELL_WINDOWACTIVATED:= RegisterWindowMessage('MHSHELL_WINDOWACTIVATED');
  MHSHELL_WINDOWCREATED:= RegisterWindowMessage('MHSHELL_WINDOWCREATED');
  MHSHELL_WINDOWDESTROYED:= RegisterWindowMessage('MHSHELL_WINDOWDESTROYED');
end.