unit bituy;
{         PROGRAMMED BY ITZHAK (c)             						   	}
{   unit for solving general functions          			     	 	}
{   ------------------------------------------- 						 	}

interface
uses general,stack,set_gr;

const

  { *************** HOW TO ADD A FUNCTION *********}
  { *********- STEP 1 -*********                   }
  {     write the name of the function             }
	{     to use as constant+inc. the maxfunc        }
  { - STEP 2 -                                     }
	{			write in the marked place the name         }
	{			that the user will give to identify        }
  {     the formula                                }
  { - STEP 3 -                                     }
  {			define in the marked place the name of     }
	{			the function that will do the calculation. }
  {     MUST END WITH P                            }
  { - STEP 4 -                                     }
  {     write the calculating function itself      }
  { - STEP 5 -                                     }
  {	   	assosiate the function with the constant   }
	{ functions }
	maxfunc  = 9;

	sinus    = 1;
	cosinus  = 2;
	absValue = 3;
	Sqr      = 4;
	tangence = 5;
  cotan    = 6;
  loge     = 7;
{ the folowing are like a constants }
	Cpi      = 8;
  Ce       = 9;

  { ******************** Function   S T E P   2 ******************}
  { write here the string the user enters to identify the formula }
	{ the chars F and X are not good }
	FuncName :array [1..maxfunc] of string =
						('SIN','COS','ABS','SQR','TAN','COTAN','LN','PI','E');

const
	p=['+','-','*','/','^'];
	n=['0'..'9','.'];
	xs=['x','X'];
	spc=[' ',#9,','];
	s1=['(','{','['];
	s2=[')','}',']'];
	theF=['F','f'];
  funcs=['A'..'E','G'..'W','Y','Z','a'..'e','g'..'w','y','z'];

type
	bpa=array[1..maxp] of pa;
	bparray=object
		data:bpa;
		tail:0..maxp;
		procedure init;
		function isempty:boolean;
		function isfull:boolean;
		function isin(i:byte):boolean;
		procedure combine(what:bparray);
		procedure put(inf:pa);
		procedure unput; { pull last data (like STACK.POP) }
		procedure get(var inf:pa;i:integer); { I is the place , if I=0 then i:=maxp }
	end;

	bp=object { the OBJET that handels the formula }
		source,dest:bparray; { EXPRESSION  array }
		formula:string; { the formula in format 'X ^ 2 '. must have the last space }
		bpstack:s; { the stack }
    lastcalc:extended; { store the result of the last calculation }
    meaningless:boolean;
		procedure init; { initialize the vriable }
		procedure sets(st:string); { formula := S }
		procedure convert; { take the string 'formula' and convert it to 'source' of action }
		procedure doBP; { take normal expression 'source' and convert it to polanian expression 'dest' }
		function calculate(valx:extended):extended; { SOLVE the formula for value X }
		procedure gets(var st:string); { S := formula }
{    procedure getbp(var st:string); { S := polanian expression }
{    function waserror:boolean; { return TRUE if there was an error in the last calculation }
		function addp   (a1,a2:extended):extended;
		function subp	  (a1,a2:extended):extended;
		function mulp   (a1,a2:extended):extended;
		function divdp  (a1,a2:extended):extended;
		function powerp (a1,a2:extended):extended;

    {******************* function   S T E P   3 ***************}
    {the definition of the pascal functions are here.          }
    {ALL DEFINITION MUST BE THE SAME                           }
		{ in the folowing functions a2 parameter is ignored }
		function sinp   (a1,a2:extended):extended;
		function cosp   (a1,a2:extended):extended;
		function absp   (a1,a2:extended):extended;
		function sqrp   (a1,a2:extended):extended;
		function tanp   (a1,a2:extended):extended;
    function cotanp (a1,a2:extended):extended;
    function lnp    (a1,a2:extended):extended;
    function cPIp   (a1,a2:extended):extended;
    function cEp    (a1,a2:extended):extended;
	end;

function solve(formula:string):extended;
function clearform(st:string):string;
implementation

function clearform;
var testbp:bp;
begin
	testbp.sets(st);
	testbp.gets(st);
	clearform := st;
end;

function solve;
var
	calc:bp;
begin
	calc.init;
	calc.sets(formula);
	calc.convert;
	calc.dobp;
	solve:=calc.calculate(1);
end;

{           BPARAY Procures              }
procedure bparray.init;
var i:1..maxp;
	tpa1:pa;
begin
	tail:=0;
	tpa1.p:=number;
	tpa1.num:=0;
	for i := 1 to maxp do put(tpa1);
	tail:=0;
end;

function bparray.isempty;
begin
	isempty:=(tail=0);
end;

function bparray.isfull;
begin
	isfull:=(tail>=maxp);
end;

function bparray.isin;
begin
	isin:=(i<=tail) and (I>0);
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
		inc(tail);
		data[tail]:=inf;
	end;
end;

procedure bparray.unput;
begin
	if not isempty then dec(tail);
end;

procedure bparray.get;
begin
	if not isin(i) then i:=tail;
	inf:=data[i];
end;


{*************************************}
{        BITUI POLANI Procedures      }
{*************************************}
procedure bp.init;
{ initialize all vriables }
var i:byte;
	a:pa;
begin
  meaningless := false;
	bpstack.init;
	a.p:=number;
	a.num:=0;
  lastcalc := 0;
	source.init;
	dest.init;
	sets(DefaultFormula);
end;

{ matematical functions }
function bp.addp;
begin
	addp:=a1+a2;
end;
function bp.subp;
begin
	subp:=a1-a2;
end;
function bp.mulp;
begin
	mulp:=a1*a2;
end;
function bp.divdp;
begin
	divdp:=a1/a2;
end;
function bp.powerp;
var i:extended;
	v : extended;
  q : string;
  l : integer;
  t : boolean;
begin
  if a2=0 then begin
  	powerp:=1;
    exit;
  end;
  if a1=0 then begin
  	powerp :=0;
    exit;
  end;
	if frac(a2)=0 then begin
		i:=a1;
		a2:=a2-1;
		while a2 > 0 do begin
			i := i*a1;
			a2:=a2-1;
		end;
	end else
		i := exp(a2*ln(abs(a1)));
	powerp := i;
end;


{******** Function   S T E P   4 *******}
{ THE ACTUAL FUNCTION COMES HERE        }
{ unary functions }
{*}function bp.sinp;
begin
	sinp := sin(a1);
end;
{*}function bp.cosp;
begin
	cosp := cos(a1);
end;
{*}function bp.absp;
begin
	absp := abs(a1);
end;
{*}function bp.sqrp;
begin
	if a1 >= 0 then	sqrp := sqrt(a1) else sqrp := 0;
end;
{*}function bp.tanp;
begin
	tanp := sin(a1)/cos(a1);
end;
{*}function bp.cotanp;
begin
	cotanp := cos(a1)/sin(a1);
end;
{*}function bp.lnp;
begin
  if a1 > 0 then lnp := ln(a1) else lnp := 0;
end;
{*}function bp.cPIp;
begin
	cPIp := pi*a1;
end;
{*}function bp.cEp;
begin
	cEp := exp(a1);
end;


procedure bp.gets;
{ give the formula to outside procedures }
{ alsow conver F1-SIN ... }
var
	st1,st2:string;
  ch:char;
  ifc:boolean;
  i,i1:integer;

begin
  i:=1;
  ifc:=false;
  st1:='';
  for i := 1 to length(formula) do begin
  	ch:=formula[i];
    if ch in ['F','f'] then begin
    	st2:=gettochar(formula,i,[' '],off);
      i1 := vali(st2);
      st1 := st1+FuncName[i1]+' ';
    end else st1 := st1 + ch;
  end;
	st := st1;
end;

{function bp.waserror:boolean;
begin
	waserror := calcerror;
  calcerror := false;
end;}

procedure bp.sets;
{ gets a string and convert it to readable string formula }
type
	peula=(number,F,func,X,add,sub,divd,mul,power,Soger,sogerc,space,unknown); { which action to do (what type)}

var st1:string;
	ch:char;
	i4:byte;
	lasti,i:integer;
  len:byte;
	soger1:pa;
	last,curchr,curgrp:peula;
	nexttodo:(nothing,minus,multy);

function match(b:pa;c:char):boolean;
{ check if two opposites brakets are match }
begin
	match:=false;
	case round(b.num) of
		1:if c=']' then match:=true;
		2:if c='}' then match:=true;
		3:if c=')' then match:=true;
	end;
end;

function whatpeula(c:char):peula;
begin
	if c in	theF  then whatpeula := F       else
	if c in	funcs then whatpeula := func    else
	if c in n     then whatpeula := number 	else
	if c in	s1    then whatpeula := soger  	else
	if c in	s2    then whatpeula := sogerc 	else
	if c in	xs    then whatpeula := X      	else
	if c in	spc   then whatpeula := space  	else
  if c in	p     then case c of
									'*' : whatpeula := mul;
									'/' : whatpeula := divd;
									'+' : whatpeula := add;
									'-' : whatpeula := sub;
									'^' : whatpeula := power;
								end                       else
	whatpeula := unknown;
end;

{ F1 -> SIN; f2 -> COS ... }
function Fconvert(Fst:string):string;
var i:integer;
begin
	i:=vali(copy(Fst,2,4));
	if (i > 0) and (i <= maxfunc) then Fconvert := FuncName[i] else Fconvert := '';
end;

{ the procedure - SETS }
begin
	nexttodo:=nothing;
	bpstack.init; { initialize brakets stack }
  st1:='';
	for i := 1 to 255 do st1[i]:=#0;
	st1:=st; { reset temp string }
  st:='';
	for i := 1 to 255 do st[i]:=#0;
	st:=st1+' ';
  len := length(st);
  for i := 1 to 255 do formula[i]:=#0;
	formula:=''; { reset formula }
	st1:='';
	i := 1; { first letter }
	while (whatpeula(st[i]) in [unknown,space]) and (i <= length(st)) do inc(i); { skip unknown characters }
	last   := whatpeula(st[i]);
	curgrp := last;
	curchr := last;
	while i <= length(st) do begin
		st1:=''; { current 'eivar' }
		curgrp:=curchr;
		curchr := whatpeula(st[i]);
		while curchr = curgrp do begin { reads all chracters of the same type }
			while (whatpeula(st[i]) in [unknown,space]) and (i <= length(st)) do inc(i); { skip unknown characters }
			st1:=st1+upcase(st[i]);
			inc(i);
			if curchr = F then begin
				curgrp := Func;
				st1 := gettochar(st,i,p+spc+xs+s1+s2+funcs,off);
				st1 := Fconvert('F'+st1);
			end;
			curchr := whatpeula(st[i]);
      if (curchr in [space,unknown]) and not SpaceSeperator and (i<len) and (whatpeula(st[i+1]) = curgrp) then
				curchr := curgrp; { Treats spaces as garbage insted of a seperator }
		end;
		while (whatpeula(st[i]) in [unknown,space]) and (i <= length(st)) do inc(i); { skip unknown characters }
		curchr := whatpeula(st[i]);
		case curgrp of
			number  : begin
									if st1[1] = '.' then st1 := '0'+st1;
									if (last = sogerc) or (last = x) then st1:=concat('^ ',st1);
									if nexttodo = minus then begin
										st1:=concat(' -',st1);
										nexttodo := nothing;
									end;
									formula := formula + st1 + ' ';
								end;
			x       : begin
									if length (st1) > 1 then st1 := 'X ^ '+stry(length(st1),0,0) else st1 := 'X ';
									if (last = sogerc) or (last = number) then st1:=concat('* ',st1);
									if nexttodo = minus then begin
										st1:=concat(' -',st1);
										nexttodo := nothing;
									end;
									formula := formula + st1;
								end;
			func    : begin
									i4 := 1;
									while i4 <= maxfunc do begin
										if st1 = FuncName[i4] then begin
											st1 := 'F'+stry(i4,0,0)+' ';
											i4 := maxfunc; { exit loop }
											if (last = sogerc) or (last = number) or (last=x) then st1:=concat('* ',st1);
											formula := formula + st1;
										end;
										inc(i4);
									end;
								end;
			soger   : for lasti := 1 to length(st1) do begin
                  st1 := '';
									soger1.p:=set_gr.peula(soger); { put in stack }
									case st1[lasti] of { type of brakets }
										'[':soger1.num:=1;
										'{':soger1.num:=2;
										'(':soger1.num:=3;
									end;
                  st1:='(';
									bpstack.push(soger1);
									if (last = X) or (last = number) or (last = sogerc) then formula := formula + '* '+st1+' '
									else begin
										if nexttodo = minus then begin
											st1:=concat(' -',st1);
											nexttodo := nothing;
										end;
										formula := formula + st1+' ';
									end;
								end;
			sogerc  : for lasti := 1 to length(st1) do begin
									bpstack.top(soger1); { get from stack opening }
									if match(soger1,st1[lasti]) then begin { if two mach: () or [] or {}
                  	if last in [add,sub,mul,divd,power,f] then
                    	case last of
                      	add,sub : formula:=formula+'0 ';
                        mul,divd,power : formula:=formula+'1 ';
                        f : formula:=formula+'X ';
                      end;
										bpstack.pop;
										formula := formula + ') ';
									end;
								end;
			add     : if not(last in [add,sub,mul,divd,power]) then formula := formula + '+ ';
			sub     : if not(last in [add,sub,mul,divd,power]) then formula := formula + '- ' else nexttodo:=minus;
			mul     : if not(last in [add,sub,mul,divd,power]) then formula := formula + '* ';
			divd    : if not(last in [add,sub,mul,divd,power]) then formula := formula + '/ ';
			power   : if not(last in [add,sub,mul,divd,power]) then formula := formula + '^ ';
		end;
		last:=curgrp;
	end;
	if last in [add,sub,mul,divd,power,f] then
   	case last of
    	add,sub : formula:=formula+'0 ';
      mul,divd,power : formula:=formula+'1 ';
      f : formula:=formula+'X ';
    end;
	while not bpstack.isempty do begin
		bpstack.pop;
		formula := formula+') ';
	end;
	if formula = '' then sets(DefaultFormula);
  st := formula;
end;

procedure bp.convert;
{ convert formula string to computer 'peula' array : source }
const
	p=['(',')','+','-','*','/','^','X','x'];

var
	st:string;
	i:integer;
	res:pa;
	v:extended;

begin
	if formula = '' then formula := 'X ^ 2 ';
	source.init;
	st:='';
	i:=1;
	Ltrim(formula);
	Rtrim(formula);
	formula:=formula+' ';
	while i < length(formula) do begin
		st:=gettochar(formula,i,[' ',#9],on);
		case st[1] of
			'0'..'9','.' : begin
				v:=valr(st);
						res.p:=number;
						res.num:=v;
				end;
				'x','X':begin
						res.num:=0;
						res.p:=x;
				end;
				'*'    :begin
						res.p:=mul;
						res.num:=0;
				end;
				'/'    :begin
						res.p:=divd;
						res.num:=0;
				end;
				'+'		 :begin
						res.p:=add;
						res.num:=0;
				end;
				'-'	   :if length(st) > 1 then begin
              if st[2] = 'X' then begin
                res.p:=sub;
                res.num:=-1;
								source.put(res);
								res.p:=X;
								res.num:=1;
              	st := 'X';
              end else if st[2] = '(' then begin
                res.p:=sub;
                res.num:=-1;
								source.put(res);
                res.p:=sogerp;
                res.num:=1;
              	st := '(';
							end else begin
                res.p:=sub;
                res.num:=-1;
								source.put(res);
								v:=vali(st);
								res.p:=number;
								res.num:=-v;
                st := stry(-v,0,1);
            	end
						end else begin
							res.p:=sub;
							res.num:=0;
						end;
				'^'		 :begin
						res.p:=power;
						res.num:=0;
				end;
				'('    :begin
						res.p:=sogerp;
						res.num:=1;
				end;
				')'    :begin
						res.p:=sogerc;
						res.num:=-1;
				end;
				'F'    :begin
						res.p:=number;
						res.num:=1;
						source.put(res);
						res.p := func;
						res.num := vali(copy(st,2,3));
				end;
		end;
		source.put(res);
		res.num:=0;
	end;
	if not (st[1] in ['x','X','0'..'9',')']) then source.unput;
end;

procedure bp.dobp;
{ convert the "CVC" type of writing ( as we all write)           }
{	to "CCV" type (as the coputer can understand)        					 }
{ Example:                                        						   }
{		X + 3      => X 3 +                           					     }
{		X + 3 * 5  => 3 5 * X +                                      }
{ Rules                                                 				 }
{  	Peulas with higher Adifuts are always the first ones to put  }
{ 	Peulas with equel Adifut are put in order of appearance      }
{	In the calculation, the computer always take the first two nums}
{	and peula, calcs them together, and put the result back on the }
{ stack. ITS THAT SIMPLE!                                        }

var i:integer;
	tpa1,tpa2:pa;

function adifut(tpe:pa):byte;
begin
	case tpe.p of
		number      :adifut:=0;
		add			    :adifut:=1;
		mul,divd    :adifut:=2;
		func        :adifut:=3;
		power   		:adifut:=4;
    sub					:if tpa1.num=-1 then adifut := 3 else adifut := 1;
	end;
end;

function prcd(tpa1,tpa2:pa):boolean;
{ return true if tpa1 has bigger "adifut" over tpa2 }
begin
	if (tpa1.p = sogerp) then if tpa2.p=sogerc then prcd := false { '(' - ')' }
														else prcd:= false { '(' - op }
				else if tpa2.p=sogerc then prcd := true { op - ')' }
						 else if tpa2.p=sogerp then prcd := false { op - '(' }
									else prcd:=(adifut(tpa1) >= adifut(tpa2)); { op - op }
end;

begin
	if source.isempty then convert;
	dest.init;
	tpa1.p:=number;
	tpa1.num:=0.0;
	tpa2:=tpa1;
	i:=1;
	while source.isin(i) do begin
		source.get(tpa1,i);
		if (tpa1.p<>X)and(tpa1.p<>number) then begin
			bpstack.top(tpa2);
			while (not bpstack.isempty) and (prcd(tpa2,tpa1)) do begin
				dest.put(tpa2);
				bpstack.pop;
				bpstack.top(tpa2);
			end;
			if bpstack.isempty or (tpa1.p <> sogerc) then bpstack.push(tpa1)
			else bpstack.toppop(tpa2);
		end else dest.put(tpa1);
		inc(i);
	end;
	while not bpstack.isempty do begin
		bpstack.toppop(tpa1);
		if tpa1.p <> sogerp then dest.put(tpa1);
	end;
end;

function bp.calculate;
{ calculate the function - MUST PROSSESS IT WITH 'CONVERT' AND 'DOBP' }


procedure calc(x,y,p:pa;var z:pa);
{ Calculate one peula }
var x1,y1,z1:extended;
begin
	x1:=x.num;
	y1:=y.num;
	z.p:=number;
	z.num:=0;
	case p.p of
		add:z1:=addp(y1,x1);
		sub:z1:=subp(y1,x1);
		mul:z1:=mulp(y1,x1);
		divd:if x1<>0 then z1:=divdp(y1,x1) else z1:=0;
		power:z1:=powerp(y1,x1);
(************************************************************************)
(*       H E R E   Y O U   E N T E R   N E W   F U N C T I O N S        *)
(************************************************************************)
		func:case trunc(p.num) of
					 sinus    : z1:=sinp  (x1,y1);
					 cosinus  : z1:=cosp  (x1,y1);
					 absvalue : z1:=absp  (x1,y1);
					 sqr      : z1:=sqrp  (x1,y1);
					 tangence : z1:=tanp  (x1,y1);
           cotan    : z1:=cotanp(x1,y1);
           loge     : z1:=lnp   (x1,y1);
           Cpi      : z1:=cPIp  (x1,y1);
           Ce       : z1:=cEp   (x1,y1);
		end;
	end;
	z.num:=z1;
end;

var i:integer;
	tpa1,tpa2:pa;
	a,b:pa;
begin
	{$I-,R-}
	if dest.isempty then dobp;
	bpstack.init;
	i:=1;
	while dest.isin(i) do begin
		dest.get(tpa1,i);
		if (tpa1.p<>X)and(tpa1.p<>number) then begin
			bpstack.toppop(a);
      if (tpa1.p = sub) and (tpa1.num = -1.0) then begin
				b.p := number;
        b.num := 0.0;
      end else bpstack.toppop(b);
			calc(a,b,tpa1,tpa2);
			bpstack.push(tpa2);
		end else if tpa1.p=x then begin
			tpa2.p:=number;
			if tpa1.num = 1 then tpa2.num:=-valX else tpa2.num:=valX;
			bpstack.push(tpa2);
		end else bpstack.push(tpa1);
		inc(i);
	end;
	bpstack.top(tpa2);
	calculate:=tpa2.num;
end;
end.