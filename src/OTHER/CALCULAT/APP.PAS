unit app;
interface
uses event,proc,mousebx,general,drivers;
const
  { ID types (1..10 are reserved) }
	PrMouse = 1;
  PrKey   = 2;

type
  EventType=(EvntMouse,EvntKey,EvntProccess,EvntCmd);
  application=object
		MouseProcs:ProcLine;
  	KeyProcs:ProcLine;
  	ProccessProcs:ProcLine;
    CmdProcs:ProcLine;
  	NumOfProcs:word;
    Running:boolean;
    ExitOk:boolean; { Set to true by an external procedure to indicate application hs finished }
    constructor init;
    procedure insert(WhatLine:EventType;WhatProc:EventProcPtr;CID:word;pri:byte);
    procedure Delete(WhatLine:EventType;CID:word);
    procedure run; virtual;
    destructor done;
  end;

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
  getkeyevent(ev);
  if ev.what = evkeydown then begin
  	tpa.inf := ev;
    eventline.put(tpa);
  end;
  kbupdate := 0;
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
	cyclemsg:word;

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
  repeat
  	ExitOK := ExitOK or cyclecmd(ProccessProcs.run);
    if mouse.changed then
			ExitOK := ExitOK or cyclecmd(MouseProcs.run);
  	ExitOK := ExitOK or cyclecmd(KeyProcs.run);
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






