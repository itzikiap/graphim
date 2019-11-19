
type
	p=procedure(a:string);

procedure run(w:pointer;arg:string);
var
	m2:p;
begin
  m2:=p(W);
  m2('9');
{	p(W^);}
end;

procedure p1(what:string);
begin
	writeln(what);
end;

var
	m:string;

begin
  m := '11112';
  p1(m);
	run(@p1,m);
end.
