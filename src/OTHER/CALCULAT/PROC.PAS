unit proc;
{ Attremt to make an event driven unit }
interface
uses	mousebx,general,boxes,event;

const
	VeryHigh = 10;
  High     = 8;
  Normal   = 6;
  Low      = 4;
  VeryLow  = 2;

  { Some commands 2..10 are reserved }
  PrExit = 1;

type
  {$F+}
  EventProcPtr = function(ID:word):word;{ return command }

  ProcLinePtr = ^ProcLineRec;
  ProcLineRec=record
    ID:word;
    priority:byte;
  	proc:EventProcPtr;
    Next:ProcLinePtr;
  end;

  ProcLine=object
    Cmd:word; { command to compare to all ID's }
    NumOfObjects:word;
  	Initialized:boolean;
    Line:ProcLinePtr;
    constructor init;
    procedure Insert(WhatProc:EventProcPtr;CID:word;pri:byte);
    procedure Delete(CID:word);
    procedure Destroy(What:ProcLinePtr);
    Function Run:word;
    Function Runs(wid:word):word;
    destructor bye;
  end;

(*
{ Initialize Given Line }
procedure ProcLine_init(var What:ProcLinePtr);
{ Add Procedure to the line. Can give costume ID. CID=0 give last ID +1}
procedure ProcLine_Insert(var WhatLine:ProcLinePtr;WhatProc:EventProcPtr;CID:word;pri:byte);
{ Delete Procedure from the line }
procedure ProcLine_Del(var WhatLine:ProcLinePtr;CID:word);
{ Delete ALL procs in line }
procedure ProcLine_Destroy(var What:ProcLinePtr);
*)

implementation
{ Initialize an event line }
constructor ProcLine.init;
begin
  Line := nil;
  New(Line);
  line^.ID := 0;
  line^.Priority := 0;
  line^.Proc := nil;
  line^.Next := nil;
  NumOfObjects := 0;
  Initialized:=true;
end;

{ Insert Item to event line }
procedure ProcLine.Insert(WhatProc:EventProcPtr;CID:word;pri:byte);
var
	found:boolean;
  current,save:ProcLinePtr;
  LastID:word;
procedure DoInsert(var current:ProcLinePtr);
begin
  current := Current^.next;
  current^.proc := Whatproc;
  if CID = 0 then current^.ID := lastID+1 else Current^.ID := CID;
  Current^.Priority := pri;
  Current^.next := nil;
end;

begin
  if not initialized then init;
	if Line = nil then init;
  found := false;
  current := Line;
  while {(current^.priority >= pri) and }(current^.next <> nil) do
		current := current^.next;
  if current^.next = nil then begin
    new(current^.next);
    doinsert(current);
   	found := true;
  end else begin
  	save := current^.next;
    new(current^.next);
    doinsert(current^.next);
    current^.next^.next := save;
  end;
	inc(NumOfObjects);
end;

{ delete an event ID from the line }
procedure ProcLine.Delete(CID:word);
var
	current,save:ProcLinePtr;
begin
  if NumOfObjects = 0 then exit;
  current := Line;
  while (current^.Next^.ID <> CID) and (current^.next <> nil) do current := current^.next;
  if Current^.next <> nil then begin
  	save := Current^.next^.next;
    dispose(Current^.next);
    current^.next := save;
    dec(NumOfObjects);
    if NumOfObjects < 0 then begin
      writeln('Bad FreMem!!!');
			halt;
    end;
  end;
end;

{ Destroy all events procedures in line }
procedure ProcLine.Destroy;
{ Do it recursively }
begin
  if NumOfObjects = 0 then exit;
	if What^.next <> nil then Destroy(What^.next);
  dispose(what);
  dec(NumOfObjects);
  if NumOfObjects < 0 then begin
    writeln('Bad FreMem!!!');
		halt;
  end;
  initialized := false;
end;

Function ProcLine.Run;
var
	current,save:ProcLinePtr;
  proc : EventProcPtr;
	toexit:boolean;
  c:word;
begin
  toexit := false;
  c := 0;
	run := 0;
  if NumOfObjects = 0 then exit;
  current := Line^.next;
  while not toexit do begin
    proc := current^.proc;
		c := proc(current^.ID);
    if c <> 0 then toexit := true;
		current := current^.next;
    if current=nil then toexit := true;
  end;
	run := c;
end;

Function ProcLine.Runs;
var
	current,save:ProcLinePtr;
  proc : EventProcPtr;
	toexit:boolean;
  c:word;
begin
  toexit := false;
  c := 0;
	runs := 0;
  if Wid=0 then exit;
  if NumOfObjects = 0 then exit;
  current := Line^.next;
  while not toexit do begin
    proc := current^.proc;
		if wid=current^.id then begin
			c := proc(current^.ID);
      toexit := true;
    end;
		current := current^.next;
    if current=nil then toexit := true;
  end;
	runs := c;
end;

Destructor ProcLine.Bye;
begin
	destroy(line);
	initialized := false;
end;

end.
