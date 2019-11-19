unit boxes;
{        PROGRAMMED BY ITZHAK ARZONY (c)                    }
{      this unit draws some boxes on the screen             }
{     -------------------------------------------					  }
interface
uses graph;
const
	relboxmove=true;
	absboxmove=false;
	centerbox=true;
	cornerbox=false;

var
	backcolor:byte; { for use with SAVEBACK=OFF in box }

type
  the3Dmodes=(none,small,big,large,double,L_double,inside,L_inside);
  just=(left,center,right);

  { this object draws a box on the screen. the box can alsow be erased }
	box=object
		cx,cy,
		width,hight   	:integer;     { center X,Y. and width and hight }
		x1,y1,x2,y2   	:integer;     { the end points }
		vx1,vy1,vx2,vy2 :integer;     { the visiable end points }
		color,bkcolor 	:byte; 		    { color and background colors }
		initialized,
		displayed		  	:boolean;   	{ is initialized, is displayed }
		size          	:longint;   	{ the size of memory to store the background }
		saveback     	 	:boolean;     { do you want to store the background? }
    noerase         :boolean;     { if on - leav trails on the screen }
		backimage    	 	:pointer; 	  { memory to store the background }
		dbox      	    :boolean; 	  { to draw the box or not }
		mode3D          :the3Dmodes;  { the type of 3D effect }
		is3D						:boolean; 	  { to use 3D effect ? }
		is3Dinverse			:boolean; 	  { look like poshed butttrue }
		noFrame					:boolean;	    { draw the box without a frame (good for 3D) }
    draged 					:boolean; 		{ only a tag for external procs }
		public
		constructor init(x,y,wid,hit:integer;iscenter:boolean); { initialize variables }
		procedure   chngDim(nx1,ny1,nx2,ny2:integer;iscenter:boolean); { changing the dim }
    procedure   copy(b1:box);
		procedure 	setvisiableP; { set the visiable points based true the edge of the screen }
		procedure   getbackimage; { save the background }
		procedure   setmcolor(c,bkc:integer); { change the color }
		procedure   set3Dmode(what3D:the3Dmodes); { set the type of 3D }
		procedure   set3D(setis3d,set3dinv:boolean);
		procedure   setbox(setdraw,setnoframe:boolean);
		procedure   display; virtual;{ display the box }
		procedure   erase; { erase the box }
		procedure   move(x,y:integer;isrelative:boolean); { Moves the box }
		function    isin(x,y:integer):boolean; { is coorinates are inside the box ? }
		destructor  bye; virtual; { delete image and free memory }
	end;

  { puts MASSAGE true the screen }
 	msgbox=object(box)
		autosize:boolean; { size the box window automaticly to feet text dimetitrue }
    textshadow : boolean; { does the text have shadow when it's pressed? }
		fontname,fontsize:byte; { the font and his size }
		msg:string;	{ the MASSAGE }
    justify:just; { the justification of the text }
		txtcolor:byte;
		txtX,txtY:integer; { the locatitrue of the text relative to window }
    ofX,ofY:ShortInt; { the offset of the text }
    spaceX,spaceY:integer;  { extends the box size byond the text size }
		txtwidth,txthight:integer; { the width and hight of the text }
		constructor init(st:string;x,y:integer); { initialize variables }
    procedure copy(b1:msgbox);
		procedure setfont(fname,fsize:byte); { change the font }
    procedure settextoffset(offx,offy:integer); { the center of the text relative to box center }
    procedure setjustify(j:just); { set the justification }
{		procedure chngDim(nx1,ny1,nx2,ny2:integer;iscenter:boolean); virtual; { changing the dim }
		procedure resize(chfont:boolean;sX,sY:integer); { reinitialize the variables }
		procedure display; virtual;{ virtual; display the mssage }
		procedure setmcolor(txt,fore,back:byte);
		procedure getmsg(var st:string); { WHAT is the massage ? }
		procedure chngmsg(st:string); { change the massage }
		destructor bye; virtual;
	end;

procedure fastbox(var b:box;ibx,nfr,i3d,i3din:boolean;m3d:the3Dmodes;c,bc:byte;disp:boolean);
procedure fastmsgbox(var b:msgbox;ibx,nfr,i3d,i3din:boolean;m3d:the3Dmodes;txc,c,bc:byte;fn,fs:integer;j:just;disp:boolean);
implementation
{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
{*           BOX OBJECT PROCEDURES           *}
{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
constructor box.init;
begin
	backimage	  := nil;
	mode3D      := small;
	is3D     	  := false;
	is3Dinverse := false;
	noframe 	  := false;
	dbox     	  := true;
	saveback 		:= true;
  noerase 		:= false;
	if iscenter then begin
		width  := wid;
		hight  := hit;
		cx     := x;
		cy     := y;
		x1     := cx-width div 2; { setting end points }
		x2     := cx+width div 2; { setting end points }
		y1     := cy-hight div 2; { setting end points }
		y2     := cy+hight div 2; { setting end points }
	end else begin
		x1     := x;
		y1     := y;
		x2     := wid;
		y2     := hit;
		width  := x2-x1;
		hight  := y2-y1;
		cx     := (x1+x2) div 2;
		cy     := (y1+y2) div 2;
	end;
	setvisiableP;
{	if saveback and noerase then getbackimage; { saving the background }
	displayed:=false;
	color:=15;
	bkcolor:=0;
	initialized:=true;
end;

procedure box.copy;
{ copy the charecaristics of another box }
{ if width or hight = 0 then the box will not move }
var
	old : boolean;
begin
  old := displayed;
  erase;
	setmcolor(b1.color,b1.bkcolor);
	set3Dmode(b1.mode3D);
	set3D(b1.is3d,b1.is3dinverse);
	setbox(b1.dbox,b1.noframe);
	if (b1.width <> 0) and (b1.hight <> 0) then chngdim(b1.x1,b1.y1,b1.x2,b1.y2,cornerbox)
  else if (b1.cx <> 0) and (b1.cy <> 0) then move(b1.cx,b1.cy,absboxmove);
  setvisiablep;
  if old then display;
end;

procedure box.getbackimage;
{ saving the background }
begin
	if not saveback then exit;
	if backimage <> nil then freemem(backimage,size);
	backimage:=nil;
	size:=imagesize(vx1,vy1,vx2,vy2);
	if size=0 then begin
		saveback := false;
		exit;
	end;
  if maxavail < size then begin
		saveback := false;
    exit;
  end else begin
		getmem(backimage,size);
		if backimage<> nil then
			getimage(vx1,vy1,vx2,vy2,backimage^)
		else halt;
  end;
end;

procedure box.setvisiableP;
var swidth,shight : integer;
begin
	swidth := getmaxx;
	shight := getmaxy;
	if x1 < 0 then vx1 := 0 else if x1 > swidth then vx1 := swidth else vx1 := x1;
	if x2 < 0 then vx2 := 0 else if x2 > swidth then vx2 := swidth else vx2 := x2;
	if y1 < 0 then vy1 := 0 else if y1 > shight then vy1 := shight else vy1 := y1;
	if y2 < 0 then vy2 := 0 else if y2 > shight then vy2 := shight else vy2 := y2;
end;

procedure box.set3Dmode;
begin
	if what3D <> mode3D then begin
		if mode3D = none then begin
			setbox(true,true);
			set3D(true,false);
		end else if what3D = none then begin
			setbox(true,false);
			set3D(false,false);
		end;
		mode3D := what3D;
		if displayed then display;
	end;
end;

procedure box.set3d;
var b:boolean;
begin
	b := false;
	if setis3d <> is3d then begin
		b := true;
		is3d := setis3d;
		if is3D then begin
			noframe := true;
		end else begin
			noframe := false;
		end;
	end;
	if set3dinv <> is3dinverse then begin
		is3dinverse := set3dinv;
		b := true;
	end;
	if b and displayed then display;
end;

procedure box.setbox;
var b:boolean;
begin
	b := false;
	if setdraw <> dbox then begin
		b := true;
		dbox := setdraw;
	end;
	if setnoframe <> noframe then begin
		noframe := setnoframe;
		b := true;
	end;
	if b and displayed then display;
end;

procedure box.chngDim;
var
	oldd:boolean;
	issame : boolean;
begin
	issame := true;
	if iscenter then begin
		if width <> nx2 then issame := false;
		if hight <> ny2 then issame := false;
		if cx    <> nx1 then issame := false;
		if cy    <> ny1 then issame := false;
	end else begin
		if x1 <> nx1 then issame := false;
		if y1 <> ny1 then issame := false;
		if x2 <> nx2 then issame := false;
		if y2 <> ny2 then issame := false;
	end;
	if not issame then begin
		oldd:=displayed;
		if displayed and not noerase then erase;
		displayed:=oldd;
		if iscenter then begin
			if nx2 <> 0 then width  := nx2;
			if ny2 <> 0 then hight  := ny2;
			if nx1 <> 0 then cx     := nx1;
			if ny1 <> 0 then cy     := ny1;
			x1     := cx-width div 2; { setting end points }
			x2     := cx+width div 2; { setting end points }
			y1     := cy-hight div 2; { setting end points }
			y2     := cy+hight div 2; { setting end points }
		end else begin
			if nx1 <> 0 then x1     := nx1;
			if ny1 <> 0 then y1     := ny1;
			if nx2 <> 0 then x2     := nx2;
			if ny2 <> 0 then y2     := ny2;
			width  := x2-x1;
			hight  := y2-y1;
			cx     := (x1+x2) div 2;
			cy     := (y1+y2) div 2;
		end;
		setvisiableP;
		if saveback and not noerase then getbackimage;
		if displayed then display;
	end;
end;


procedure box.erase;
{ draw the saved background }
begin
	if displayed and (saveback and (backimage<>nil)) then begin
		putimage(vx1,vy1,backimage^,normalput);
		if (size<>0) then freemem(backimage,size);
		backimage:=nil;
  end	else if displayed then begin
		setcolor(backcolor);
		setfillstyle(solidfill,backcolor);
		bar(vx1,vy1,vx2,vy2);
	end;
	displayed:=false;
end;

procedure box.setmcolor;
{ set the color }
begin
	if c<>-1 then color:=c;
	if bkc<>-1 then bkcolor:=bkc;
	if displayed then display;
end;

function box.isin;
var tp:boolean;
begin
	if (x > x1) and (y > y1) and (x < x2) and (y < y2) then isin := true
	else isin := false;
end;

procedure box.display;
{ display the box on the screen }
var w,h:integer;

procedure d3d(offset:shortint;isinv:boolean);
begin
  setlinestyle(0,1,1);
	if isinv then setcolor(0) else setcolor(15);
	line(x1+offset,y1+offset,x1+offset,y2-offset); { ษออออออออ  }
	line(x1+offset,y1+offset,x2-offset,y1+offset); { บ          }
  if isinv then setcolor(15) else setcolor(0);
	line(x2-offset,y2-offset,x1+offset,y2-offset); {         บ  }
	line(x2-offset,y2-offset,x2-offset,y1+offset); { ออออออออผ  }
end;

begin
	if not displayed and saveback then getbackimage;
	if dbox then begin
		setfillstyle(solidfill,bkcolor);
		bar(x1,y1,x2,y2);
	end;
	if not noframe then begin
		setcolor(color);
		setlinestyle(0,1,1);
		rectangle(x1,y1,x2,y2);
  end;
	if is3D then begin
		case mode3D of
			small:d3D(0,is3Dinverse);
			big:begin
				d3D(0,is3Dinverse);
				d3D(1,is3Dinverse);
			end;
      large:begin
				d3D(0,is3Dinverse);
				d3D(1,is3Dinverse);
				d3D(2,is3Dinverse);
				d3D(3,is3Dinverse);
      end;
      l_double:begin
				d3D(0,is3Dinverse);
				d3D(1,is3Dinverse);
				d3D(4,is3Dinverse);
				d3D(5,is3Dinverse);
      end;
      double:begin
				d3D(0,is3Dinverse);
				d3D(2,is3Dinverse);
			end;
			inside:begin
				d3D(0,false);
				d3D(2,is3Dinverse);
			end;
      L_inside:begin
				d3D(0,false);
				d3D(1,false);
				d3D(3,is3Dinverse);
				d3D(4,is3Dinverse);
      end;
		end;
	end;{ else}
	displayed:=true;
end;

procedure box.move;
{ moves the box. }
{	RELBOXMOVE - moves the box relatively to it's corrent position }
{ ABSBOXMOVE - moves the box to the absolute location }
var old:boolean;
	changed:boolean;
begin
  changed := false;
  if isrelative=relboxmove then changed := ((x<>0) or (Y<>0))
  	else changed := ((X<>CX) or (Y<>CY));
	if changed then begin
		old := displayed;
		if not noerase then erase;
		displayed := old;
		if isrelative=relboxmove then begin
			cx:=cx+x;
			cy:=cy+y;
		end else begin
			if x <> 0 then cx:=x;
			if y <> 0 then cy:=y;
		end;
		x1:=cx-width div 2;
		x2:=cx+width div 2;
		y1:=cy-hight div 2;
		y2:=cy+hight div 2;
		setvisiableP;
		if displayed then	begin
			if saveback then getbackimage;
		  display;
	  end;
  end;
end;

destructor box.bye;
{ erase massage and free background }
begin
	erase;
	if (size<>0) and saveback and (backimage <> nil) then freemem(backimage,size);
	backimage:=nil;
end;
procedure fastbox;
{ Quick create a box                       }
{******************************************}
begin
  with b do begin
  	setmcolor(c,bc);
    set3Dmode(m3D);
    setbox(ibx,nfr);
    set3D(i3d,i3din);
  	if disp then display;
  end;
end;

{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
{*         MSGBOX OBJECT PROCEDURES          *}
{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
constructor msgbox.init;
{ initialize all variables }
var i:byte;
begin
	ofX:=0;
	ofY:=-5;
	autosize := true;
  textshadow := false;
	initialized:=false;
  justify := center;
	setfont(1,4); { setting font }
	msg:=st; { setting massage }
	settextstyle(1,horizdir,4);
	txthight:=textheight('Xg'); { setting the size }
	txtwidth:=textwidth(msg);
  spaceX :=5;
  spacey :=5;
	box.init(x,y,txtwidth+spacex,txthight+spacey,centerbox);
	setbox(true,false);
	set3dmode(small);
	setmcolor(15,15,0);
	txtX := width div 2;
  txtY := hight div 2;
end;

procedure msgbox.copy;
{ copy the charecaristics of another box }
{ if width or hight = 0 then the box will not move }
var
	old : boolean;
begin
  old := displayed;
  erase;
  saveback := b1.saveback;
	setmcolor(b1.txtcolor,b1.color,b1.bkcolor);
	set3Dmode(b1.mode3D);
	set3D(b1.is3d,b1.is3dinverse);
	setbox(b1.dbox,b1.noframe);
  setfont(b1.fontname,b1.fontsize);
  setjustify(b1.justify);
	autosize := b1.autosize;
  textshadow := b1.textshadow;
  if b1.msg <> '' then chngmsg(b1.msg);
	if (b1.width <> 0) and (b1.hight <> 0) then chngdim(0,0,width,hight,centerbox);
  if (b1.cx <> 0) and (b1.cy <> 0) then move(b1.cx,b1.cy,absboxmove);
  setvisiablep;
  if old then display;
end;

procedure msgbox.setfont;
{ set the font and reinitialize }
var fc:boolean;
begin
	fc := false;
	if (fontname=fname) and (fontsize=fsize) then fc:=true;
	fontname:=fname;
	fontsize:=fsize;
	if initialized then resize(not fc,spacex,spacey);
end;

procedure msgbox.resize(chfont:boolean;sx,sy:integer);
{ setting new size and saving the new background }
var
	i:integer;
	oldd:boolean;
begin
	if chfont then settextstyle(fontname,horizdir,fontsize);
  spaceX:=sX;
  spaceY:=sY;
	txthight:=textheight(msg)+sY+5;
	txtwidth:=textwidth(msg)+sX+5;
	if ((txthight<>hight) or (txtwidth<>width)) and autosize then begin
		box.chngDim(cx-txtwidth div 2,cy-txthight div 2,cx+txtwidth div 2,cy+txthight div 2,cornerbox);
	end;
  setjustify(justify);
end;

procedure msgbox.setmcolor(txt,fore,back:byte);
begin
	txtcolor:=txt;
	box.setmcolor(fore,back);
end;

procedure msgbox.settextoffset(offx,offy:integer);
{ the place of the text relative to the center of the box }
begin
	ofX:=offx;
  ofY:=offy;
  if displayed then display;
end;

procedure msgbox.setjustify;
var t:boolean;
begin
  t := (justify=j);
	justify := j;
  case j of
  	left : txtX := 3;
		center : txtX := width div 2;
    right : txtX := width - 3;
  end;
	if displayed and not t then display;
end;

procedure msgbox.display;
{ display the massage true the screen }
var w,h:integer;
begin
	box.display;
  w := width div 2;
  h := hight div 2;
  setviewport(vx1,vy1,vx2,vy2,clipon);
	settextstyle(fontname,horizdir,fontsize);
  case justify of
  	right  : settextjustify(righttext,centertext);
    center : settextjustify(centertext,centertext);
    left   : settextjustify(lefttext,centertext);
  end;
	if is3Dinverse and textshadow then begin
		setcolor(0);
		outtextxy(txtX+2+ofX,txtY+2+ofY,msg);
  end else if is3Dinverse then begin
		txtX := txtX +2;
		txtY := txtY +2;
  	if mode3D = small then begin
			txtX := txtX -1;
			txtY := txtY -1;
    end;
  end;
	setcolor(txtcolor);
	outtextxy(txtX+ofX,txtY+ofY,msg);
	if is3Dinverse and not textshadow then begin
		txtX := txtX -2;
		txtY := txtY -2;
  	if mode3D = small then begin
			txtX := txtX +1;
			txtY := txtY +1;
    end;
  end;
	setviewport(0,0,getmaxx,getmaxy,clipon);
end;

procedure msgbox.chngmsg;
{ change the massage and reinitialize }
begin
	if msg <> st then begin
		msg:=st;
		resize(true,spacex,spacey);
		if displayed then display;
	end;
end;

procedure msgbox.getmsg;
{ give massage to outside }
begin
	st:=msg;
end;

destructor msgbox.bye;
begin
	box.bye;
end;

procedure fastmsgbox;
{ Quick create a msgbox                    }
{******************************************}
begin
  with b do begin
  	setmcolor(txc,c,bc);
    set3Dmode(m3D);
    setbox(ibx,nfr);
    set3D(i3d,i3din);
    setfont(fn,fs);
    setjustify(j);
  	if disp then display;
  end;
end;

end.
