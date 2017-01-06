unit mainclient;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.Layouts, IdCustomTCPServer,
  IdTCPServer, IdContext, IdExplicitTLSClientServerBase, FMX.Gestures, System.IOUtils,
  FMX.ListBox, FMX.Colors;

type
  TForm5 = class(TForm)
    IdTCPClient1: TIdTCPClient;
    Panel1: TPanel;
    Edit1: TEdit;
    Label1: TLabel;
    Button3: TButton;
    lefttopbtn: TButton;
    topbtn: TButton;
    righttopbtn: TButton;
    leftbtn: TButton;
    rightbtn: TButton;
    centerbtn: TButton;
    leftbottombtn: TButton;
    rightbottombtn: TButton;
    bottombtn: TButton;
    bigbtn: TButton;
    Panel2: TPanel;
    setupbtn: TButton;
    Panel3: TPanel;
    ListBox1: TListBox;
    Button1: TButton;
    Button2: TButton;
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure leftbtnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure leftbtnMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure setupbtnClick(Sender: TObject);
    procedure leftbtnlClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  mythread = class(TThread)
    protected
      procedure execute; override;
    public
      int : integer;
  end;

//  TCloser = class(TThread)
//    protected
//      procedure execute; override;
//    public
//      counter : byte;
//  end;

  mytcpthread = class(TThread)
    protected
      procedure execute; override;
  end;


var
  Form5: TForm5;
  ip : string;
  thread : mythread;
  tcp : mytcpthread;
  connected, moved, setup, noerrors : boolean;
  x, y, p3x, p3y : extended;
  btnarray : array[0..9] of tbutton;
  t : tbutton;

implementation

{$R *.fmx}
{$R *.LgXhdpiTb.fmx ANDROID}
{$R *.XLgXhdpiTb.fmx ANDROID}


function gettext(btn : tbutton) : string;
begin
  case btn.Tag of
    0 : result := 'Empty';
    vkEscape : result := 'Esc';
    vkBack : result := 'Backspace';
    vkReturn : result := 'Enter';
    vkSpace : result := 'Space';
    vkCapital : result := 'Caps Lock';
    vkRight : result := 'Right';
    vkLeft : result := 'Left';
    vkUp : result := 'Up';
    vkDown : result := 'Down';
    vk0 : result := '0';
    vk1 : result := '1';
    vk2 : result := '2';
    vk3 : result := '3';
    vk4 : result := '4';
    vk5 : result := '5';
    vk6 : result := '6';
    vk7 : result := '7';
    vk8 : result := '8';
    vk9 : result := '9';
    vkA : result := 'A';
    vkb : result := 'B';
    vkc : result := 'C';
    vkd : result := 'D';
    vke : result := 'E';
    vkf : result := 'F';
    vkg : result := 'G';
    vkh : result := 'H';
    vki : result := 'I';
    vkj : result := 'J';
    vkk : result := 'K';
    vkl : result := 'L';
    vkm : result := 'M';
    vkn : result := 'N';
    vko : result := 'O';
    vkp : result := 'P';
    vkq : result := 'Q';
    vkr : result := 'R';
    vks : result := 'S';
    vkt : result := 'T';
    vku : result := 'U';
    vkv : result := 'V';
    vkw : result := 'W';
    vkx : result := 'X';
    vky : result := 'Y';
    vkz : result := 'Z';
    vkf1 : result := 'F1';
    vkf2 : result := 'F2';
    vkf3 : result := 'F3';
    vkf4 : result := 'F4';
    vkf5 : result := 'F5';
    vkf6 : result := 'F6';
    vkf7 : result := 'F7';
    vkf8 : result := 'F8';
    vkf9 : result := 'F9';
    vkf10 : result := 'F10';
    vkf11 : result := 'F11';
    vkf12 : result := 'F12';
  end;
end;

function gettag(item : tlistboxitem) : integer;
begin
  if item.Text = 'Empty' then result := 0;
  if item.Text = 'Esc' then result := vkEscape;
  if item.Text = 'Backspace' then result := vkBack;
  if item.Text = 'Enter' then result := vkReturn;
  if item.Text = 'Space' then result := vkSpace;
  if item.Text = 'Right' then result := vkRight;
  if item.Text = 'Left' then result := vkLeft;
  if item.Text = 'Up' then result := vkUp;
  if item.Text = 'Down' then result := vkDown;
  if item.Text = '0' then result := vk0;
  if item.Text = '1' then result := vk1;
  if item.Text = '2' then result := vk2;
  if item.Text = '3' then result := vk3;
  if item.Text = '4' then result := vk4;
  if item.Text = '5' then result := vk5;
  if item.Text = '6' then result := vk6;
  if item.Text = '7' then result := vk7;
  if item.Text = '8' then result := vk8;
  if item.Text = '9' then result := vk9;
  if item.Text = 'A' then result := vkA;
  if item.Text = 'B' then result := vkb;
  if item.Text = 'C' then result := vkc;
  if item.Text = 'D' then result := vkd;
  if item.Text = 'E' then result := vke;
  if item.Text = 'F' then result := vkf;
  if item.Text = 'G' then result := vkg;
  if item.Text = 'H' then result := vkh;
  if item.Text = 'I' then result := vki;
  if item.Text = 'J' then result := vkj;
  if item.Text = 'K' then result := vkk;
  if item.Text = 'L' then result := vkl;
  if item.Text = 'M' then result := vkm;
  if item.Text = 'N' then result := vkn;
  if item.Text = 'O' then result := vko;
  if item.Text = 'P' then result := vkp;
  if item.Text = 'Q' then result := vkq;
  if item.Text = 'R' then result := vkr;
  if item.Text = 'S' then result := vks;
  if item.Text = 'T' then result := vkt;
  if item.Text = 'U' then result := vku;
  if item.Text = 'V' then result := vkv;
  if item.Text = 'W' then result := vkw;
  if item.Text = 'X' then result := vkx;
  if item.Text = 'Y' then result := vky;
  if item.Text = 'Z' then result := vkz;
  if item.Text = 'F1' then result := vkf1;
  if item.Text = 'F2' then result := vkf2;
  if item.Text = 'F3' then result := vkf3;
  if item.Text = 'F4' then result := vkf4;
  if item.Text = 'F5' then result := vkf5;
  if item.Text = 'F6' then result := vkf6;
  if item.Text = 'F7' then result := vkf7;
  if item.Text = 'F8' then result := vkf8;
  if item.Text = 'F9' then result := vkf9;
  if item.Text = 'F10' then result := vkF10;
  if item.Text = 'F11' then result := vkF11;
  if item.Text = 'F12' then result := vkF12;
  if item.Text = 'Caps Lock' then result := vkCapital;
end;


procedure TForm5.Button1Click(Sender: TObject);
begin
  panel3.Visible := false;
end;

procedure TForm5.Button2Click(Sender: TObject);
begin
  if listbox1.Selected <> nil then
  begin
    panel3.Visible := false;
    t.Tag := gettag(listbox1.Selected);
    t.Text := gettext(t);
  end
  else
  begin
    showmessage('Not selected!');
  end;
end;

procedure TForm5.Button3Click(Sender: TObject);
var
  i : byte;
begin
  if connected = false then
  begin
    noerrors := true;
    if noerrors then
    begin
      IdTCPClient1.Host:=edit1.Text;
      try
        tcp := mytcpthread.Create(false);
        sleep(500);
        tcp.Destroy;
        if IdTCPClient1.Connected = true then
        begin
          setupbtn.Visible := false;
          button3.Text:='Disonnect';
          connected:=true;
          panel1.Visible:=false;
          for I := 0 to 9 do
          begin
            if btnarray[i].Tag = 0 then
            begin
              btnarray[i].Visible := false;
            end;
          end;
          panel2.Visible:=true;
        end
        else
        begin
          showmessage('Incorrect IP address!');
          try
            IdTCPClient1.Disconnect;
          finally

          end;
        end;
      except
        showmessage('Incorrect IP address!');
        try
          IdTCPClient1.Disconnect;
        finally

        end;
      end;
    end
    else
    begin

    end;
  end
  else
  begin
    button3.Text:='Connect';
    connected:=false;
    try
      IdTCPClient1.Disconnect;
    finally

    end;
    panel1.Visible:=true;
    panel2.Visible:=false;
    setupbtn.Visible := true;
  end;
end;


procedure TForm5.FormClose(Sender: TObject; var Action: TCloseAction);
var
  settingsfile : system.Text;
  i:byte;
begin
  assignfile(settingsfile, TPath.Combine(TPath.GetDocumentsPath, 'settings.dat'));
  rewrite(settingsfile);
  for I := 0 to 9 do
  begin
    writeln(settingsfile, btnarray[i].tag);
  end;
  closefile(settingsfile);
  thread.Destroy;
  //closer.Destroy;
end;

procedure TForm5.FormCreate(Sender: TObject);
var
  i : byte;
  t : integer;
  settingsfile : system.Text;
begin
  connected:=false;
  button3.TintColor := TAlphaColorRec.Dodgerblue;
  setup := false;
  thread := mythread.create(false);
//  closer := TCloser.Create(false);
  panel1.Visible:=true;
  form5.Fill.Color:=TAlphaColor($F4F4F4);
  btnarray[0] := lefttopbtn;
  btnarray[1] := topbtn;
  btnarray[2] := righttopbtn;
  btnarray[3] := leftbtn;
  btnarray[4] := centerbtn;
  btnarray[5] := rightbtn;
  btnarray[6] := leftbottombtn;
  btnarray[7] := bottombtn;
  btnarray[8] := rightbottombtn;
  btnarray[9] := bigbtn;
  assignfile(settingsfile, TPath.Combine(TPath.GetDocumentsPath, 'settings.dat'));
  reset(settingsfile);
  for I := 0 to 9 do
  begin
    readln(settingsfile, t);
    if t <> 0 then
    begin
      btnarray[i].Tag := t;
      btnarray[i].Text := gettext(btnarray[i]);
    end
    else
    begin
      btnarray[i].Visible := false;
      btnarray[i].Text := 'Empty';
    end;
  end;
  closefile(settingsfile);
end;

procedure TForm5.FormPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
var
  i:byte;
  bord : extended;
begin
  if form5.Width > form5.Height then
  begin
    bord := form5.Height / 60;
  end
  else
  begin
    bord := form5.Width / 60;
  end;
  x := (panel2.Width - 4 * bord) / 3;
  y := (panel2.Height - 5 * bord) / 4;
  p3x := (form5.Width) / 1.5;
  p3y := (form5.Height) / 1.5;
  panel3.Width := p3x;
  panel3.Height := p3y;
  panel3.Position.X := (form5.Width - p3x) / 2;
  panel3.Position.Y := (form5.Height - p3y) / 2;
  button1.Position.X := 0;
  button1.Position.Y := panel3.Height - 60;
  button1.Width := p3x / 2;
  button2.Position.X := p3x / 2;
  button2.Position.Y := panel3.Height - 60;
  button2.Width := p3x / 2;
  listbox1.Height := p3y - 60;
  for I := 0 to 2 do
  begin
    btnarray[i].Position.X := bord + i * (x + bord);
    btnarray[i].Width := x;
    btnarray[i].Height := y;
    btnarray[i].Position.Y := bord;
  end;
  for I := 0 to 2 do
  begin
    btnarray[i+3].Position.X := bord + i * (x + bord);
    btnarray[i+3].Width := x;
    btnarray[i+3].Height := y;
    btnarray[i+3].Position.Y := 2 * bord + y;
  end;
  for I := 0 to 2 do
  begin
    btnarray[i+6].Position.X := bord + i * (x + bord);
    btnarray[i+6].Width := x;
    btnarray[i+6].Height := y;
    btnarray[i+6].Position.Y := 3 * bord + 2 * y;
  end;
  btnarray[9].Position.X := bord;
  btnarray[9].Width := 3 * x + 2 * bord;
  btnarray[9].Height := y;
  btnarray[9].Position.Y := 4 * bord + 3 * y;
end;

procedure TForm5.leftbtnlClick(Sender: TObject);
begin
  if setup = true then
  begin
    panel3.Visible:=true;
    t := (sender as tbutton);
  end;
end;

procedure TForm5.leftbtnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if setup = false then
  begin
    moved := true;
    thread.int:=(sender as tbutton).Tag;
  end;
end;

procedure TForm5.leftbtnMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  moved := false;
  thread.int:=0;
end;



procedure TForm5.setupbtnClick(Sender: TObject);
var
  I: byte;
  settingsfile : system.Text;
begin
  if setup = false then
  begin
    button3.Visible:=false;
    setupbtn.Text:='Save';
    setup := true;
    panel2.Visible:=true;
    for I := 0 to 9 do
    begin
      btnarray[i].Visible := true;
    end;
    setupbtn.BringToFront;
  end
  else
  begin
    button3.Visible:=true;
    setupbtn.Text:='Settings';
    setup := false;
    panel2.Visible:=false;
    assignfile(settingsfile, TPath.Combine(TPath.GetDocumentsPath, 'settings.dat'));
    rewrite(settingsfile);
    for I := 0 to 9 do
    begin
      writeln(settingsfile, btnarray[i].tag);
    end;
    closefile(settingsfile);
  end;
end;

{ mythread }

procedure mythread.execute;
begin
  while true do
  begin
    if self.int <> 0 then
    begin
      form5.IdTCPClient1.IOHandler.WriteLn(inttostr(self.int));
      sleep(200);
    end;
  end;
end;

{ mytcpthread }

procedure mytcpthread.execute;
begin
  inherited;
  form5.IdTCPClient1.Connect;
end;

{ mythread2 }

//procedure TCloser.execute;
//begin
//  while True do
//  begin
//    if connected then
//    begin
//      inc(self.counter);
//      if self.counter mod 5 = 0 then
//      begin
//        self.counter := 0;
//        if form5.IdTCPClient1.Socket.ReadLn = 'exit' then
//        begin
//          form5.button3.Text:='Connect';
//          connected:=false;
//          try
//            form5.IdTCPClient1.Disconnect;
//          finally
//
//          end;
//          form5.panel1.Visible:=true;
//          form5.panel2.Visible:=false;
//          form5.setupbtn.Visible := true;
//        end;
//      end;
//    end;
//    sleep(1000);
//  end;
//end;

end.


