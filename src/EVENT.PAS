unit event;
interface
uses
	drivers,general;

const maxp=50;

type

  pa = record
		inf:Tevent;
  	cmd:word;
  end;

	bpa=array[1..maxp] of Pa;
	bparray=object
		data:bpa;
    ex:counter;
    head:counter;
		tail:counter;
		procedure init;
		function isempty:boolean;
		function isfull:boolean;
		function isin(i:integer):boolean;
    function search(tcmd:word):boolean; { search a command }
		procedure combine(what:bparray);
		procedure put(inf:pa);
		procedure putc(c:word);
		procedure unput; { pull first data (like Queu.POP) }
		procedure get(var inf:pa;i:integer); { I is the place , if I=0 then i:=maxp }
	end;

var
	EventLine:bparray;
implementation

{           PARAY Procures              }
procedure bparray.init;
var i:1..maxp;
	tpa1:pa;
begin
	tail.init(1,maxp,0,1);
  head.init(1,maxp,0,1);
  ex.init(0,1,0,1);
  tail.setlink(@ex);
  head.setlink(@ex);
{	for i := 1 to maxp do put(tpa1);}
end;

function bparray.isempty;
begin
	isempty:=(tail.get=head.get);
end;

function bparray.isfull;
begin
	isfull:=((tail.get-head.get=-1) or (tail.get-head.get=maxp));
end;

function bparray.isin;
var t:boolean;
begin
  t :=ex.get=0;
  if t then t:=((i>=tail.get) and (I<=head.get)) else t:= ((i<=tail.get) or (I>=head.get));
  isin := t;
end;

function bparray.search;
var
	t,b:boolean;
  i:integer;
begin
  t :=ex.get=0;
  b := false;
  if t then
    for i := head.get to tail.get do b := b or (data[i].cmd = tcmd)
  else begin
    for i := head.get to maxp do b := b or (data[i].cmd = tcmd);
    for i := 1 to tail.get do b := b or (data[i].cmd = tcmd);
  end;
end;

procedure bparray.combine;
var i:integer;
	tpa1:pa;
begin
	i := 1;
	while what.isin(i) do begin
		what.get(tpa1,i);
		put(tpa1);
		inc(i);
	end;
end;
procedure bparray.put;
begin
	if not isfull then begin
		tail.inc;
		data[tail.get]:=inf;
	end;
end;
procedure bparray.putc;
var
	inf:pa;
begin
  inf.cmd := c;
	if not isfull then begin
		tail.inc;
		data[tail.get]:=inf;
	end;
end;

procedure bparray.unput;
begin
	if not isempty then head.inc;
end;

procedure bparray.get;
begin
	if not isin(i) then i:=head.get;
	inf:=data[i];
end;

end.