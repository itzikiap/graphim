unit 3Dstack;
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
  line=record
  	p1,p2:point;
  	c:byte; { color }
  end;

	(* start of data type *)
	s=object { STACK HANDELING OBJECT }
		sa:array[1..maxp] of pa; { STACK array }
		tail:byte;
		procedure init; { initialize the stack }
		procedure push(inf:pa); { push item to the stack }
		procedure pop; { remove top item }
		procedure top(var inf:pa); { look at top item  }
		procedure toppop(var inf:pa); { look at top item and remove it }
		function isempty:boolean; { checks if empty }
		function isfull:boolean; { check if full }
	end;

implementation
{       STACK Procedures     }

procedure s.init;
{ put 0 in all the fields }
var i:byte;
	a:pa;
begin
	a.p:=number;
	a.num:=0;
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
    sa[tail].p  :=number;
    sa[tail].num:=0.0;
		dec(tail);
  end;
end;

procedure s.top;
{ look at topest item and leav it there }
begin
	if tail > 0 then inf:=sa[tail]
	else begin
		inf.p:=number;
		inf.num:=0;
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
