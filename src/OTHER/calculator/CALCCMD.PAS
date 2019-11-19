unit calccmd;
{ EXECUT ALL THE COMMANDS OF THE CALCULATOR }
interface
uses	general,boxes,exbox,app,bmenu,mousebx,cldef,bituy;

function Pchar(ID:word):word;
function PEquel(ID:word):word;
function Pon(ID:word):word;
function Pclr(ID:word):word;

function Mcalc(ID:word):word;
function Mmenu(ID:word):word;

var
	calc:menubar;
  menub:menubar;
  app1:application;

implementation
function Pchar;
var
	s : string3;
begin
	if (id >= clNUM) and (id <= clnum+9) then s := stry(id-clnum,0,0)
  else case ID of
  	clPlus : s := '+';
  	clMinus: s := '-';
  	clMul  : s := '*';
  	clDiv  : s := '/';
  	clPower: s := '^';
  end;

  line.chngmsg(line.msg+s);
end;
function PEquel;
begin
  line.chngmsg(stry(solve(line.msg),0,0));
end;
function Pon;
begin
  line.chngmsg('');
end;
function Pclr;
var s:string;
begin
  s := line.msg;
  delete(s,length(s),1);
	line.chngmsg(s);
end;
{------------}


function Mcalc;
var i:byte;
begin
  if mouse.buttompressed[1] then i := 1 else i := 2;
	mcalc := calc.cycle(i);
end;
function Mmenu;
var i:byte;
begin
  if mouse.buttompressed[1] then i := 1 else i := 2;
	mmenu := menub.cycle(i);
end;



end.