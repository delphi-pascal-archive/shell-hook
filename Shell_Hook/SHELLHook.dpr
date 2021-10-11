library SHELLHook;

uses
  SysUtils,
  Classes,
  Windows;

const
  MMFName: PChar = 'MMF';

type
  PGlobalDLLData = ^TGlobalDLLData;
  TGlobalDLLData = packed record
    HookWnd: HWND;
    Wnd: HWND;
  end;

var
  GlobalData: PGlobalDLLData;
  MMFHandle: THandle;
  MHSHELL_WINDOWACTIVATED: Cardinal;
  MHSHELL_WINDOWCREATED: Cardinal;
  MHSHELL_WINDOWDESTROYED: Cardinal;

function ShellProc(Code: Integer; wParam: DWORD; lParam: DWORD): Longint; stdcall;
begin
  Result:= CallNextHookEx(GlobalData.HookWnd, Code, wParam, lParam);
  if (Code = HSHELL_WINDOWACTIVATED) then
    SendMessage(GlobalData.Wnd, MHSHELL_WINDOWACTIVATED, 0, Integer(wParam));
  if (Code = HSHELL_WINDOWCREATED) then
    SendMessage(GlobalData.Wnd, MHSHELL_WINDOWCREATED, 0, Integer(wParam));
  if (Code = HSHELL_WINDOWDESTROYED) then
    SendMessage(GlobalData.Wnd, MHSHELL_WINDOWDESTROYED, 0, Integer(wParam));
end;

function StartMouseHook(State: Boolean; Wnd: HWND): Boolean; export; stdcall;
begin
  Result:= False;
  if State = True then
  begin
    GlobalData^.HookWnd:= SetWindowsHookEx(WH_SHELL, @ShellProc, hInstance, 0);
    GlobalData^.Wnd:= Wnd;
    if GlobalData^.HookWnd <> 0 then
      Result:= True;
  end
  else
  begin
    UnhookWindowsHookEx(GlobalData^.HookWnd);
    Result:= False;
  end;
end;

function StopMouseHook(): Boolean; export; stdcall;
begin
  UnhookWindowsHookEx(GlobalData^.HookWnd);
  if GlobalData^.HookWnd = 0 then
    Result:= False
  else
    Result:= True;
end;

procedure OpenGlobalData();
begin
  MHSHELL_WINDOWACTIVATED:= RegisterWindowMessage('MHSHELL_WINDOWACTIVATED');
  MHSHELL_WINDOWCREATED:= RegisterWindowMessage('MHSHELL_WINDOWCREATED');
  MHSHELL_WINDOWDESTROYED:= RegisterWindowMessage('MHSHELL_WINDOWDESTROYED');

  MMFHandle:= CreateFileMapping(INVALID_HANDLE_VALUE, nil, PAGE_READWRITE, 0, SizeOf(TGlobalDLLData), MMFName);
  GlobalData:= MapViewOfFile(MMFHandle, FILE_MAP_ALL_ACCESS, 0, 0, SizeOf(TGlobalDLLData));
  if GlobalData = nil then
    CloseHandle(MMFHandle);
end;

procedure CloseGlobalData();
begin
  UnmapViewOfFile(GlobalData);
  CloseHandle(MMFHandle);
end;

procedure DLLEntryPoint(Reason: DWORD);
begin
  case Reason of
    DLL_PROCESS_ATTACH: OpenGlobalData;
    DLL_PROCESS_DETACH: CloseGlobalData;
  end;
end;

exports StartMouseHook, StopMouseHook;

begin
  DLLEntryPoint(DLL_PROCESS_ATTACH);
end. 