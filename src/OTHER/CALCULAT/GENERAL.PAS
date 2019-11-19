unit general;
{  GENERAL PROCEDURES, FUNCTIONS, VARIABLES AND CONNTENTS   }
{       PROGRAMMED BY ITZHAK (c)               	    		    }
{       ---------------------------------------------		    }

interface
uses boxes,drivers,graph,dos,inifiles,errors,
		 BGIDriv,   { all the BGI drivers }
		 BGIFont;   { all the BGI fonts }

const
	off= false;
	on =true;

	isVesa:boolean=false;

	PTD:string='c:\program\tp7\bgi'; { Path To graph Drivers }
	nums=['0','1','2','3','4','5','6','7','8','9']; { set of leagel numbers }

  { OBJ types }
  { All the box type must start with B }
  { All the other mustnt! }
  Tbox         ='BOX';
  Tmsgbox      ='BMS';
  Tinputbox    ='BIN';
  TMenuitem    ='BMI';
  Tpopupmenu   ='BMU';
  Tmainmenu    ='BMN';
  Tvirtbox     ='BVR';

  VInteger     ='INT';
  Vword        ='WRD';
  Vlongint     ='LNG';
  Vshortint    ='SRT';
  Vbyte        ='SWD'; { Short word }


type
  string8=string[8];
  string3=string[3];



  cp=^counter;
	counter=object
		min,max:longint; { minimum and maximum of counter }
    linkenabled:boolean;
		private
		initialized:boolean;
    Link:cp;
    islinked:boolean;
		lastover,lastunder:boolean; { set to true if last operation exided nim or max }
		first:word; { save the first value }
		value:longint; { the current value }
		step:word; { increesing step - MUST BE POSITIVE }
		public
		constructor init(fmin,fmax:longint;firstvalue:longint;fstep:word); { initialize the counter }
		procedure restore; { restore the default value }
		procedure inc; { increes in STEP }
		procedure dec; { decrees in STEP }
		procedure incby(by:word); { increes in othe value }
		procedure decby(by:word); { decrees in othe value }
		procedure setmax(newmax:longint); { set new maximum value }
		procedure setmin(newmin:longint); { set new minimum value }
		procedure setstep(newstep:word); { set new step value }
		function isover:boolean; { is last opperation got over the maximum ? }
		function isunder:boolean; { is last opperation got under the minimum ? }
		function get:longint; { get value }
    procedure setlink(p:cp); { set linked counter if you want to link hour:minuts etc. }
		destructor done; { finish }
	end;

	timer=object
		initialized:boolean;
		firsttime:longint; { the start time }
		fhour,fminut,fsecond,fsec100:word; { the time }
    hour,minut,second,sec100:word;
		constructor init; { initialize }
		function getmilisecond:longint; { conver the time to milisecond }
		procedure reset; { reset the timer }
		procedure waituntil(milisec:longint); { wait until time has past }
		function cycle(ms:longint):boolean; { if pass ms - return true and reset }
		function get:longint; { get the milliseconds passed from last reset }
		destructor done; { good bye }
	end;

	charset = set of char;

var
  UserDriverName:string;
  UserDriver:byte;
  UserMode:byte;
	swidth,shight:integer; { screen width and hight }
  maxcolor:byte;
	ev:tevent; { keyboard event }
	mscount:integer; { howmany times is it take to loop until MS has gone }

{ checks if file exist }
{ f - the file name (can use *,?)     }
{ RETURN - true if exist false if not }
function exist(F:string):boolean;

{ 'itzhak ' -> 'k itzha' -> 'ak itzh' -> 'hak itz' ... }
{ st     - the string to rotate  }
{ num    - how meny rotates      }
{ RETURN - the rotated string    }
function rotate(st:string;num:byte):string;

{ plot massage }
{ st   - the massage }
{ x,y  - the CENTER location }
{ width,hight - width and hight of the box (put 0 to use autosize) }
{ color,bkcolor - foreground and background color }
{ the current font is being used, you must change it menualy }
procedure pplot(st:string;x,y,width,hight:integer;color,bgcolor:byte);

{ remove left space }
{ '  itzhak' -> 'itzhak' }
{ st - the string }
procedure Ltrim(var st:string);

{ remove right space }
{ 'itzhak  ' -> 'itzhak' }
{ st - the string }
procedure Rtrim(var st:string);

{ string to real }
{ st - the string (floating point, not scientific)}
{ RETURN - the real number }
{ the function will ignor unknown characters }
function valr(s:string):extended;

{ string to integer }
{ st - the string}
{ RETURN - the integer number }
{ the function will ignor unknown characters }
function vali(s:string):longint;

{ number to string }
{ r - the number }
{ par1 - the width of the field }
{ par2 - number after decimel point }
function stry(r:real;par1,par2:byte):string;

{ Find a substring in a string                 }
{ What - the string to find                    }
{ FindIn - The string to search in             }
{ Where - From which character start searching }
{ Clear - Ignor case                           }
{ RETURN - the Position of the text that found.}
{     			0 if not found                     }
function FindStr(what,findin:string;where:byte;clear:boolean):byte;

{ gets word from place until the charset         }
{ s - the string                                 }
{ place - the character to begin the search from }
{ cs - the characters to stop searching          }
{         empty group will return until the end  }
{         of the string                          }
{ clear - skip all CS chars when get there       }
{ RETURN - the word                              }
{ example:                                       }
{	   gettochar('ITZHAK ARZONY PROD',7,[' '],on); }
{ will return 'ARZONY'                           }
function gettochar(s:string;var place:integer;cs:charset;clear:boolean):string;

{ conver a string into uppercase }
function upstr(st:string):string;

{ make the program not depended on .BGI and .CHR files }
procedure builtingraph;

{ initialize the graph and paint background with color }
procedure graphinit(color:byte);

{ install user driver }
{ RETURN - True if OK }
function makeuserdriver(driver:string;mode:byte):boolean;

{ close the graph }
procedure graphend;

{ create a delay }
{ d - milliseconds }
procedure delay(D:word);

implementation

{ checks if file exist }
function exist(f:string):boolean;
var
	dir,n,e:string;
	s:string;
begin
	fsplit(f,dir,n,e);
	f := n+e;
	s := fsearch(f,dir);
	exist := (s <> '');
end;

procedure pplot(st:string;x,y,width,hight:integer;color,bgcolor:byte);
{ write massage in a box }
{ without the need of MSGBOX object }
begin
	settextjustify(centertext,centertext);
	setfillstyle(solidfill,bgcolor);
	if width = 0 then width := textwidth(st)+3;
	if hight = 0 then hight := textheight(st)+3;
	setcolor(color);
	bar3d(x-width div 2-1,y-hight div 2-1,x+width div 2+1,y+hight div 2+1,0,true);
	outtextxy(x,y-1,st);
end;

{ RETURN true if number is friction }
{(*function isfruc(f:extended):boolean;
*******************************************************************
function chk4win:boolean;*)}

function rotate;
{ take a string and rotate it :}
{ ROTATE ->E ROTAT->TE ROTA->ATE ROT->TATE RO->OTATE R-> ROTATE }
var i:byte;
	c:char;
	l:byte;
begin
	l:=length(st);
	c:=st[1];
	for i := 1 to l-1 do st[i]:=st[i+1];
	st[l]:=c;
	rotate := st;
end;

procedure builtingraph;
begin
	{ Register all the drivers }
	RegisterBGIdriver(@CGADriverProc);
	RegisterBGIdriver(@EGAVGADriverProc);
	RegisterBGIdriver(@HercDriverProc);
	RegisterBGIdriver(@ATTDriverProc);
	RegisterBGIdriver(@PC3270DriverProc);


	{ Register all the fonts }
	RegisterBGIfont(@GothicFontProc);
	RegisterBGIfont(@SansSerifFontProc);
	RegisterBGIfont(@SmallFontProc);
	RegisterBGIfont(@TriplexFontProc);
end;

function MakeUserdriver;
var err:integer;
begin
  if ptd<>'' then ptd := ptd+'\';
	if exist(ptd+driver+'.BGI') then begin
		userdrivername:=driver;
		userdriver := InstallUserDriver(userdrivername, nil);
		usermode := mode;
		makeuserdriver := true;
		Err:=graphresult;
		if Err <> GrOk then begin
			userdrivername:='';
			userdriver := 0;
			usermode := 0;
			makeuserdriver := false;
		end else isvesa := true;
	end else makeuserdriver := false;
end;

procedure graphinit;
{ INITIALIZE THE GRAPH MODE }
var
	gm,gd:integer;
	err:integer;
	i:byte;
	st:char;

begin
	if isvesa then gm:=usermode else gm := 0;
	if isvesa then gd:=userdriver else gd := 0;
	initgraph(gd,gm,ptd);
	Err:=graphresult;
	if Err <> GrOk then begin
		Writeln('Graph error message : ',GraphErrorMsg(err));
		while (err=GrFileNotFound) and (ptd<>'BYE')do begin
			writeln;
			write('I''m very sory I can''t find my graph drivers in ');
			if ptd='' then writeln('currend directory.') else writeln(ptd);
			writeln('Pleas write down the path where I can find my BGI drivers');
			writeln('Enter blank line to search corrent directory.');
			writeln('write BYE to exit.');
			write('>');
			readln(ptd);
			for i := 1 to length(ptd) do ptd[i]:=upcase(ptd[i]);
			if ptd <> 'BYE' then initgraph(gm,gd,ptd);
			Err:=graphresult;
		end;
		if err <> grOK then begin
			Writeln('Graph error message : ',GraphErrorMsg(err));
			halt;
		end;
		if ptd='BYE' then halt;
	end;
	swidth:=getmaxx;
	shight:=getmaxy;
	maxcolor := getmaxcolor;
	setfillstyle(solidfill,color);
	bar(0,0,swidth,shight);
	backcolor := color;
end;

procedure graphend;
begin
	closegraph;
	swidth := 0;
	shight := 0;
end;

procedure Ltrim;
{ remove left space }
var i:byte;
begin
	i := 1;
	while (st[i] in notgoodchar) and (i < length(st)) do inc(i);
end;

procedure Rtrim;
{ remove right space }
var i:byte;
begin
	i := length(st);
	while (st[i] in notgoodchar) and (i > 1) do dec(i);
	st := copy(st,1,length(st)-(1-i)+1);
end;

function upstr;
var l,i:integer;
	st1:string;
begin
	i := 1;
	st1 := '';
	l := length(st);
	while i <= l do begin
		st1 := st1 + upcase(st[i]);
		inc(i);
	end;
	upstr := st1;
end;

function stry;
{ CONVERT NUBER TO STRING }
var i:integer;
	s:string;
begin
	str(r:par1:par2,s);
	stry:=s;
end;

function vali;
{ convert string to an integer number }
var i,v,l,d:longint;
begin
  {$Q-,R-}
	v:=0;
	l:=1;
	i:=1;
	if s[1] = '-' then begin
		d := -1;
		inc(i);
	end else d:=1;
	for i:=length(s) downto i do if s[i] in nums then begin
		v:=v+(ord(s[i])-48)*l;
		l:=l*10;
	end;
	v:=v*d;
	vali:=v;
  {$Q+,R+}
end;

function valr;
{ convert string to a real number }
var i,f,v,d:longint;
	r,l:extended;
begin
  {$Q-,R-}
	i:=0;
	while (i < length(s)) and (s[i] <> '.') do inc(i);
	if (i=length(s)) and (s[i] <> '.') then begin
		valr := vali(s);
    exit;
  end;
	v:=0;
	l:=1;
	i:=1;
	r:=0;
	if s[1] = '-' then begin
		d := -1;
		inc(i);
	end else d:=1;
	f:=i;
	inc(i);
	while (s[i]<>'.') do begin
		l:=l*10;
		inc(i);
	end;
	while s[f] <> '.' do begin
		v:=v+(ord(s[f])-48)*trunc(l);
		l:=l / 10;
		inc(f);
	end;
	v:=v*d;
	for i := f to length(s) do if s[i] in nums then begin
		r:=r+(ord(s[i])-48)*l;
		l:=l / 10;
	end;
	r:=r+v;
	valr:=r;
  {$Q+,R+}
end;

{         Find STR           }
function FindStr(what,findin:string;where:byte;clear:boolean):byte;
var i:byte;
   v:byte;
   l,lw:byte;

begin
  l := length(findin);
  lw := length(what);
  FindStr := 0;
  if (l < lw) or (where > l) then exit;
	v := 1;
  i := where;
  while (i<l) or (v<lw) do begin
    if clear then begin
      what[v] := upcase(what[v]);
      FindIn[i] := upcase(FindIn[i]);
    end;
  	if what[v] = FindIn[i] then begin
			inc(v);
{      inc(i);}
    end else if v > 0 then v := 0;
    inc(i);
  end;
  if v = lw then FindStr := i else FindStr := 0;
end;

{         get to char        }
function gettochar(s:string;var place:integer;cs:charset;clear:boolean):string;
var st:string;
	l : byte;
begin
	l := length(s);
	s:=s+' ';
	st:='';
	while s[place] in cs do inc(place);
	while not(s[place] in cs) and (place <= l) do begin
		st := st+s[place];
		inc(place);
	end;
	gettochar:=st;
	if clear then while s[place] in cs do inc(place);
end;

{                         Delay                  }
procedure delay;
var {hour,minut,second,sec100:word;
	hour2,minut2,second2,sec100_2:word;}
	i,time1,time2:longint;
  c: counter;
begin
	{$Q-}
  if d < 254 then begin
  	port[$0040] := 0;
    repeat until port[$0040] >= d;
  end;
(*	GetTime(hour,minut,second,sec100);
	time1:=sec100+second*100+minut*60{+hour*60};
	i:=0;
	repeat
		GetTime(hour2,minut2,second2,sec100_2);
		time2:=sec100_2+second2*100+minut2*60{+hour2*60};
	until time2-time1 >= d;*)
	{$Q+}
end;

{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
{*         COUNTER OBJECT PROCEDURES         *}
{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
constructor counter.init;
{ initialize the variable }
begin
	if fmin<fmax then begin { min is always smaller then max }
		min:=fmin;
		max:=fmax;
	end else begin
		min := fmax;
		max := fmin;
	end;
	value:=firstvalue;
	if fstep > 0 then step := fstep { fstep mustbe positive }
	else if fstep < 0 then step := - step
	else step := 1;
	if value <= max then lastover:=false { is value in bounderies }
	else begin
		value := max;
		lastover:=true;
	end;

	if value >= min then lastunder:=false
	else begin
		value := min;
		lastunder:=true;
	end;
	initialized := true;
	link:=nil;
  islinked := false;
  linkenabled := false;
end;

procedure counter.restore;
{      restors the first value       }
begin
	value := first;
end;

procedure counter.inc;
{ increes value by step - if value exead max then value is set to max and isover to true }
begin
	value := value + step;
	if value <= max then lastover:=false
	else begin
    if linkenabled and islinked then begin
      value := min+value mod (max-min);
      lastover := true;
      link^.inc;
    end else begin
			value := max;
			lastover:=true;
  	end;
	end;
end;

procedure counter.dec;
{ decrees value by step - if value exead min then value is set to min and isunder to true }
begin
	value := value - step;
	if value >= min then lastunder:=false
	else begin
    if linkenabled and islinked then begin
      value := max-value mod (max-min);
      lastover := true;
      link^.dec;
    end else begin
			value := min;
			lastunder:=true;
  	end;
	end;
end;

procedure counter.incby;
{ increes value by BY variable - if value exead max then value is set to max and isover to true }
begin
	value := value + by;
	if value <= max then lastover:=false
	else begin
    if linkenabled and islinked then begin
      value := min+value mod (max-min);
      lastover := true;
      link^.inc;
    end else begin
			value := max;
			lastover:=true;
    end;
	end;
end;

procedure counter.decby;
{ decrees value by BY vriable - if value exead min then value is set to min and isunder to true }
begin
	value := value - by;
	if value >= min then lastunder:=false
	else begin
    if linkenabled and islinked then begin
      value := max-value mod (max-min);
      lastover := true;
      link^.dec;
    end else begin
			value := min;
			lastunder:=true;
    end;
	end;
end;

procedure counter.setmax;
{ set new maximum }
{ if maximum smaller then minimum then maximum IS SET TO MINIMUM }
{ if value is over maximum then a correction is made }
begin
	if newmax > min then max := newmax
	else max := min;
	if value <= max then lastover:=false
	else begin
		value := max;
		lastover:=true;
	end;
end;

procedure counter.setmin;
{ set new minimum }
{ if minimum biger then maximum then minimum IS SET TO MAXIMUM }
{ if value is under minimum then a correction is made }
begin
	if newmin < max then min := newmin
	else min := max;
	if value <= min then lastunder:=false
	else begin
		value := min;
		lastunder:=true;
	end;
end;

procedure counter.setstep;
{ set a new step to increes by }
begin
	if newstep > 0 then step := newstep
	else if newstep < 0 then step := -step
	else step := 1;
end;

function counter.isover;
{ true if last opperation was over the maximum }
begin
	isover:=lastover;
	lastover:=false;
end;

function counter.isunder;
{ true if last opperation was under the minimum }
begin
	isunder:=lastunder;
	lastunder:=false;
end;

procedure counter.setlink(P:cp);
{ set the linked counter }
begin
	link := p;
  if p = nil then islinked := false else islinked := true;
  linkenabled := islinked;
end;

function counter.get;
begin
{ get the value }
	get :=  value;
end;

destructor counter.done;
{ do nothing but must call it }
begin
end;

{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
{*          TIMER OBJECT PROCEDURES          *}
{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
constructor timer.init;
{ reset for the first time }
begin
	reset;
	initialized:=true;;
end;

procedure timer.reset;
{ reset the timer }
begin
	firsttime:=getmilisecond;
  fhour := hour;
  fminut := minut;
  fsecond := second;
  fsec100 := sec100;
  firsttime := sec100+second+minut*60;
end;

function timer.getmilisecond;
{ calculate the miliseconds based on the time in hour,minuts,seconds }

begin
	GetTime(hour,minut,second,sec100);
	getmilisecond:=sec100+second+minut*60;
end;

procedure timer.waituntil;
begin
	repeat until milisec <= get;
end;

function timer.cycle;
begin
	if get >= ms then begin
		reset;
		cycle := true;
	end else cycle := false;
end;

function timer.get;
{ get the timer }
var dhour,dminut,dsecond,dsec100:word;
begin

	get := abs(getmilisecond-firsttime);
end;

destructor timer.done;
begin
end;


begin
end.
