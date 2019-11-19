unit stack3D;
{ Now using this stack for GRAPHIM.                             }
{ To change the destination of the stack - just change the type }
{ ALWAYS CALL YOUR DATA TYPE "PA" IN 'GENERAL.PAS'              }
{ Don't forget to change the INIT procedure                     }
{ open GENERAL.PAS to change options }
interface
uses general;

const maxp = 12;

type
  point=record
  	X,Y,Z:real;
  end;
  vline=record
  	p1,p2:point;
  	c:byte; { color }
  end;

	(* start of data type *)
	s=object { STACK HANDELING OBJECT }
		sa:array[1..maxp] of vline; { STACK array }
		tail:byte;
		procedure init; { initialize the stack }
		procedure push(inf:vline); { push item to the stack }
		procedure pop; { remove top item }
		procedure top(var inf:vline); { look at top item  }
		procedure toppop(var inf:vline); { look at top item and remove it }
		function isempty:boolean; { checks if empty }
		function isfull:boolean; { check if full }
	end;

implementation
{       STACK Procedures     }

procedure s.init;
{ put 0 in all the fields }
var i:byte;
	a:vline;
begin
	a.p1.x := 0;
	a.p1.y := 0;
	a.p1.z := 0;
	a.p2.x := 0;
	a.p2.y := 0;
	a.p2.z := 0;
  a.c := 0;

	for i := 1 to maxp do sa[i]:=a;
	tail:=0;
end;

procedure s.push;
{ put item in top of the stack }
begin
	if not isfull then begin
		inc(tail);
		sa[tail]:=inf;
	end;
end;

procedure s.pop;
{ remove the topest item }
begin
	if not isempty then begin
    sa[tail].p1.x := 0;
		sa[tail].p1.y := 0;
		sa[tail].p1.z := 0;
		sa[tail].p2.x := 0;
		sa[tail].p2.y := 0;
		sa[tail].p2.z := 0;
  	sa[tail].c := 0;
		dec(tail);
  end;
end;

procedure s.top;
{ look at topest item and leav it there }
begin
	if tail > 0 then inf:=sa[tail]
	else begin
    inf.p1.x := 0;
		inf.p1.y := 0;
		inf.p1.z := 0;
		inf.p2.x := 0;
		inf.p2.y := 0;
		inf.p2.z := 0;
  	inf.c := 0;
	end;
end;

procedure s.toppop;
{ look at topest item and remove it }
begin
	top(inf);
	pop;
end;

function s.isfull;
{ check if the stack is full }
begin
	isfull:=(tail=maxp);
end;

function s.isempty;
{ check if the stack is empty }
begin
	isempty:=(tail=0);
end;
end.
