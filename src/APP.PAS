unit app;
interface
uses event,proc,mousebx,general,drivers;
const
  { ID types (1..10 are reserved) }
  PrExit  = 1;
	PrMouse = 2;
  PrKey   = 3;

type
  Kbd=record
    KbChar:char;
    KbScan:byte;
    KBST:byte;
  end;

  EventType=(EvntMouse,EvntKey,EvntProccess,EvntCmd);
  application=object
		MouseProcs:ProcLine;
  	KeyProcs:ProcLine;
  	ProccessProcs:ProcLine;
    CmdProcs:ProcLine;
    massages:string; { every proc can put or reag msg. last msg writen, deletes the one before }
  	NumOfProcs:word;
    Running:boolean;
    ExitOk:boolean; { Set to true by an external procedure to indicate application hs finished }
    constructor init;
    procedure insert(WhatLine:EventType;WhatProc:EventProcPtr;CID:word;pri:byte);
    procedure Delete(WhatLine:EventType;CID:word);
    procedure run; virtual;
    destructor done;
  end;

var
  KBp : tevent;
  kbdState:kbd;
  DoKB :Boolean;

implementation
{ Function of dealing with the mouse }
function MouseUpdate(ID:word):word; far;
begin
	If MouseOK then begin
  	mouse.update;
    MouseUpdate := 0;
  end;
end;

function KBUpdate(ID:word):word; far;
var ev:tevent;
	tpa : pa;
begin
  getkeyevent(kbp);
{  if ev.what = evkeydown then begin}
{		event := ev;}
{  	tpa.inf := ev;
    eventline.put(tpa);}
{  end;}
  doKB := (kbp.what = evkeydown);
  KBupdate := 0;
  kbdstate.kbst   := getshiftstate;
  if dokb then with kbdstate do begin
		kbchar := kbp.charcode;
    kbscan := kbp.keycode;
  end else if kbdstate.kbscan <> 0 then with kbdstate do begin
		kbchar := chr(0);
    kbscan := 0;
  end;
end;




{ initialize all vriables and lines }
constructor application.init;
begin
{  graphinit(4);}
  Running := false;
	MouseProcs.init;
  KeyProcs.Init;
  ProccessProcs.init;
  CmdProcs.Init;
  NumOfProcs := 0;
  ExitOk := false;
  Check_Mouse;
  if MouseOK then Begin
    Mouse.init;
    insert(EvntProccess,MouseUpdate,PrMouse,VeryHigh);
  end;
  eventline.init;
  insert(EvntProccess,KBUpdate,PrKey,VeryHigh);
end;

{ insert procedure to a specified line }
procedure application.insert;
begin
	case WhatLIne of
  	EvntMouse:MouseProcs.insert(WhatProc,CID,pri);
    EvntKey:KeyProcs.insert(WhatProc,CID,pri);
    EvntProccess:ProccessProcs.insert(WhatProc,CID,pri);
    EvntCmd:CmdProcs.insert(WhatProc,CID,pri);
  end;
  inc(NumOfProcs);
end;

procedure application.delete;
begin
	case WhatLIne of
  	EvntMouse:MouseProcs.delete(CID);
    EvntKey:KeyProcs.delete(CID);
    EvntProccess:ProccessProcs.delete(CID);
    EvntCmd:CmdProcs.delete(CID);
  end;
  dec(NumOfProcs);
end;

procedure application.run;
var
	c,cp:word;

function cyclecmd(wid:word):boolean;
var
	c:word;
begin
  c := wid;
  while not (c in [0,prexit]) do c := CmdProcs.runs(c);
  cyclecmd := c=prexit;
end;

begin
	If MouseOK then Mouse.display;
  Running := True;
  ExitOK := false;
  c := 0;
  repeat
    if c=0 then begin
				if dokb then c := KeyProcs.run;
    		if mouse.changed then c := MouseProcs.run;
    end;
  	cp := ProccessProcs.run;
    if cp <> 0 then c := cp;
    ExitOK := (c = prexit);
    if c <> 0 then c := CmdProcs.runs(c);
  until ExitOK;
	running := false;
end;

destructor application.done;
begin
  MouseProcs.bye;
	KeyProcs.bye;
 	ProccessProcs.bye;
end;

end.






