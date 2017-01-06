unit mainserver;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdUDPServer, IdGlobal, IdSocketHandle,
  IdBaseComponent, IdComponent, IdUDPBase, IdCustomTCPServer, IdTCPServer,
  IdContext, Vcl.StdCtrls, IdTCPConnection, IdTCPClient, IdCmdTCPServer,
  IdExplicitTLSClientServerBase, IdFTPServer, IdMessageClient, IdPOP3,
  IdPOP3Server, IdIPWatch, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Samples.Spin,
  sSkinManager, System.ImageList, Vcl.ImgList, acPNG, IdScheduler,
  IdSchedulerOfThread, IdSchedulerOfThreadDefault, IdAntiFreezeBase,
  Vcl.IdAntiFreeze;

type
  TForm3 = class(TForm)
    srv: TIdTCPServer;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    IdIPWatch1: TIdIPWatch;
    Edit1: TEdit;
    UpDown1: TUpDown;
    Label2: TLabel;
    Memo1: TMemo;
    Timer1: TTimer;
    sSkinManager1: TsSkinManager;
    Image1: TImage;
    Image2: TImage;
    Label3: TLabel;
    Label4: TLabel;
    IdAntiFreeze1: TIdAntiFreeze;
    IdSchedulerOfThreadDefault1: TIdSchedulerOfThreadDefault;
    ComboBox1: TComboBox;
    Button3: TButton;
    portsrv: TIdTCPServer;
    procedure srvExecute(AContext: TIdContext);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure UpDown1Click(Sender: TObject; Button: TUDBtnType);
    procedure Timer1Timer(Sender: TObject);
    procedure srvConnect(AContext: TIdContext);
    procedure srvDisconnect(AContext: TIdContext);
    procedure Button3Click(Sender: TObject);
    procedure portsrvExecute(AContext: TIdContext);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;
  count : integer;
  PortHandle : thandle;
  Dcb: TDcb;
  dwWrite: DWORD;
  OverWrite: TOverlapped;
  arr1 : array[0..10] of byte;
  arr2 : array[0..12] of byte;

implementation

procedure ReadComportList;
var
  I: Integer;
  H: THandle;
begin {опрос существующих портов}
  form3.ComboBox1.Clear;
  for I := 0 to 255 do {цикл опроса}
  begin {пробуем получить дескриптор порта}
    H := CreateFile(PChar('COM' + IntToStr(i + 1)),
      GENERIC_READ or GENERIC_WRITE,
      0,
      nil,
      OPEN_EXISTING, FILE_FLAG_OVERLAPPED, 0);

    if (H <> INVALID_HANDLE_VALUE) or (GetLastError = 5) then {если порт есть то добавить в список}
      form3.ComboBox1.AddItem('COM' + IntToStr(i + 1), nil);

    if H <> 0 then
      CloseHandle(H); {закрыть дескриптор}
  end;
end;

procedure setuppasswords;
begin

  arr1[0] := ord('s');
  arr1[1] := ord('a');
  arr1[2] := ord('t');
  arr1[3] := ord('a');
  arr1[4] := ord('e');
  arr1[5] := ord('v');
  arr1[6] := ord('e');
  arr1[7] := ord('m');
  arr1[8] := ord('i');
  arr1[9] := ord('l');
  arr1[10] := 0;

  arr2[0] := ord('e');
  arr2[1] := ord('w');
  arr2[2] := ord('F');
  arr2[3] := ord('a');
  arr2[4] := ord('I');
  arr2[5] := ord('a');
  arr2[6] := ord('s');
  arr2[7] := ord('4');
  arr2[8] := ord('z');
  arr2[9] := ord('o');
  arr2[10] := ord('m');
  arr2[11] := ord('r');
  arr2[12] := 0;

end;

{$R *.dfm}


procedure TForm3.Button1Click(Sender: TObject);
begin
  srv.Active := true;
  srv.MaxConnections := strtoint(edit1.Text);
  updown1.Enabled:=false;
  button1.Enabled := false;
  button2.Enabled:=true;
  memo1.Lines.Add('Server starting...');

  PortHandle := CreateFile(PWideChar(ComboBox1.Items[ComboBox1.ItemIndex]),
   GENERIC_READ or GENERIC_WRITE,
   0,
   nil,
   OPEN_EXISTING,
   FILE_ATTRIBUTE_NORMAL,
   0);
  if PortHandle = INVALID_HANDLE_VALUE then

  if not GetCommState(PortHandle, Dcb) then
     memo1.Lines.Add('Error setup port...');

  Dcb.BaudRate := CBR_9600;
  Dcb.Parity := NOPARITY;
  Dcb.ByteSize := 8;
  Dcb.StopBits := ONESTOPBIT;

  if not SetCommState(PortHandle, Dcb) then
    memo1.Lines.Add('Error setup port...');
  PurgeComm(PortHandle, PURGE_TXCLEAR or PURGE_RXCLEAR);

end;

procedure TForm3.Button2Click(Sender: TObject);
var
  tempList : TList;
  i : integer;
begin
  tempList := TList.Create;
  tempList := srv.Contexts.LockList;
  try
    if tempList.Count <> 0 then
    begin
      for I := 0 to tempList.Count - 1 do
      begin
        TIdContext(tempList.Items[i]).Connection.Socket.WriteLn('exit');
      end;
    end;
  finally
    srv.Contexts.UnlockList;
  end;
  srv.Scheduler.ActiveYarns.Clear;
  srv.Active := false;
  updown1.Enabled:=true;
  button2.Enabled:=false;
  button1.Enabled:=true;
  memo1.Lines.Add('Server stopped.');
  CloseHandle(PortHandle);


end;



procedure TForm3.Button3Click(Sender: TObject);
begin
  ReadComportList;
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
  Label1.Caption := 'IP: ' + IdIPWatch1.LocalIP;
  button2.Enabled:=false;
  count := 0;
  setuppasswords;
end;

procedure TForm3.portsrvExecute(AContext: TIdContext);
var
  s : string;
begin
  s := acontext.Connection.Socket.ReadLn();
  if s[1] = '9' then
  begin
    WriteFile(PortHandle, arr1, 11,
      dwWrite, @OverWrite);
  end;
  if s[1] = 'G' then
  begin
    WriteFile(PortHandle, arr2, 13,
      dwWrite, @OverWrite);
  end;
end;

procedure TForm3.srvConnect(AContext: TIdContext);
begin
  memo1.Lines.Add('Connected!');
  inc(count);
  image1.Visible := false;
  image2.Visible := true;
end;

procedure TForm3.srvDisconnect(AContext: TIdContext);
begin
  memo1.Lines.Add('Disconnected!');
  dec(count);
  if count < 1 then
  begin
    image1.Visible := true;
    image2.Visible := false;
  end;
end;

procedure TForm3.srvExecute(AContext: TIdContext);
var
  s:string;
begin
  s:= AContext.Connection.Socket.ReadLn;
  //memo1.Lines.Add(s);
  keybd_event(strtoint(s), 0, 0, 0);
  Application.ProcessMessages;
  sleep(50);
  keybd_event(strtoint(s), 0, KEYEVENTF_KEYUP, 0);
  Application.ProcessMessages;
end;

procedure TForm3.Timer1Timer(Sender: TObject);
begin
  Label1.Caption := 'IP: ' + IdIPWatch1.LocalIP;
end;

procedure TForm3.UpDown1Click(Sender: TObject; Button: TUDBtnType);
begin
  if button = btNext then
  begin
    edit1.Text := inttostr(strtoint(edit1.Text) + 1);
  end
  else
  begin
    if strtoint(edit1.Text) > 0 then
    begin
      edit1.Text := inttostr(strtoint(edit1.Text) - 1);
    end;
  end;
end;

end.
