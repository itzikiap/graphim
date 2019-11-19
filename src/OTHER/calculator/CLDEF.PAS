unit cldef;
{ definition to calculator }
interface
uses bmenu,proc,boxes;

const
	{ CMD defs }
	mnCalc = 11;
	mnClear= 12;
	mnCchar= 13;

	{ calculator }
  clNum  = 40; {CLNUM+ the number }
  clPlus = 31;
  clMinus= 32;
  clMul  = 33;
  clDiv  = 34;
  clPower= 35;
  clClr  = 36;
  clOn   = 37;
  clCalc = 39;
  clErr  = 38;

	menudef:array [1..4] of command=
		((name:'EXIT'      ;ctrl:prExit),
		 (name:'CALCULATE' ;ctrl:clCalc),
		 (name:'CLEAR'     ;ctrl:clOn),
		 (name:'CLEAR CHAR';ctrl:clClr));

  calcdef:array [1..17] of command=
    ((name:'c' ;ctrl:clclr),
     (name:'o' ;ctrl:clon),
		 (name:'1' ;ctrl:clnum+1),
		 (name:'2' ;ctrl:clnum+2),
		 (name:'3' ;ctrl:clnum+3),
		 (name:'4' ;ctrl:clnum+4),
		 (name:'5' ;ctrl:clnum+5),
		 (name:'6' ;ctrl:clnum+6),
		 (name:'7' ;ctrl:clnum+7),
		 (name:'8' ;ctrl:clnum+8),
		 (name:'9' ;ctrl:clnum+9),
		 (name:'0' ;ctrl:clnum+0),
     (name:'=' ;ctrl:clcalc),
		 (name:'+' ;ctrl:clPlus),
		 (name:'-' ;ctrl:clMinus),
		 (name:'x' ;ctrl:clMul),
		 (name:':' ;ctrl:clDiv));


	error:boolean=false;

var
	InChr:char;
  Wcommand:byte;

  Line:msgbox;
implementation
end.