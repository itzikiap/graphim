unit mouse2;
{ this unit dosn't handles the mouse. }
{ it makes an object of a mouse from object box }
interface
uses boxes,graph{,dos},general;
const
	msize = 11;

var
  mouseratio:word;

type
	mt=(arrow,cross,wait,mline,box3D,user);
  marray=array[1..msize,1..msize] of shortint;
	mousepointertype=record
		hotpx,hotpy:byte;
		mpointer: marray;
	end;


const
	arrowpoint:mousepointertype=
	(hotpx:0; hotpy:0;mpointer: { arrow }
	((0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,-1,-1,-1),
	 (0 ,15,15,15,15,15,0 ,-1,-1,-1,-1),
	 (0 ,15,15,15,15,0 ,-1,-1,-1,-1,-1),
	 (0 ,15,15,15,15,0 ,-1,-1,-1,-1,-1),
	 (0 ,15,15,15,15,15,0 ,-1,-1,-1,-1),
	 (0 ,15,0 ,0 ,15,15,15,0 ,-1,-1,-1),
	 (0 ,0 ,-1,-1,0 ,15,15,15,0 ,-1,-1),
	 (0 ,-1,-1,-1,-1,0 ,15,15,0 ,-1,-1),
	 (-1,-1,-1,-1,-1,-1,0 ,0 ,0 ,-1,-1),
	 (-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1),
	 (-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1)));

	waitpoint:mousepointertype=
	(hotpx:6; hotpy:6; mpointer: { houreglass }
	((-1,-1, 0, 0, 0, 0, 0, 0, 0,-1,-1),
	 (-1,-1, 0,15,15,15,15,15, 0,-1,-1),
	 (-1,-1, 0,15, 0,15, 0,15, 0,-1,-1),
	 (-1,-1,-1, 0,15, 0,15, 0,-1,-1,-1),
	 (-1,-1,-1,-1, 0,15, 0,-1,-1,-1,-1),
	 (-1,-1,-1,-1,-1, 0,-1,-1,-1,-1,-1),
	 (-1,-1,-1,-1, 0,15, 0,-1,-1,-1,-1),
	 (-1,-1,-1, 0,15, 0,15, 0,-1,-1,-1),
	 (-1,-1, 0,15, 0, 0, 0,15, 0,-1,-1),
	 (-1,-1, 0, 0, 0, 0, 0, 0, 0,-1,-1),
	 (-1,-1, 0, 0, 0, 0, 0, 0, 0,-1,-1)));

	userpointer:mousepointertype=
	(hotpx:1; hotpy:0;mpointer: { It suppose to be a hand ... }
 	((-1, 0,-1,-1,-1,-1,-1,-1,-1,-1,-1),
	 ( 0,15, 0,-1,-1,-1,-1,-1,-1,-1,-1),
	 ( 0,15, 0, 0,-1, 0,-1, 0,-1,-1,-1),
	 ( 0,15, 0,15, 0,15, 0,15, 0, 0,-1),
	 ( 0,15, 0,15, 0,15, 0,15, 0,15, 0),
	 ( 0,15, 0,15, 0,15, 0,15, 0,15, 0),
	 ( 0,15,15,15,15,15,15,15,15,15, 0),
	 ( 0,15,15,15,15,15,15,15,15,15, 0),
	 (-1, 0,15,15,15,15,15,15,15, 0,-1),
	 (-1, 0,15,15,15,15,15,15,15, 0,-1),
	 (-1,-1, 0, 0, 0, 0, 0, 0, 0,-1,-1)));

type
	themouse=object(box)
		changed:boolean; { does mouse position and buttons changed since last update }
		hotpx,hotpy:byte; { the hotpoint of the mouse relative to mouse icon }
		midx,midy:byte; { the middle of the box }
		x,y:integer; { the hotpoint of the mouse relative to screen }
{		redhotpoint:boolean; { display the red point as a ered dot }
		mousetype:mt; { type of mouse }
		xmove,ymove:integer; { movement of the mouse in both axes }
		drag:boolean; { used to determine if mose is being held and moved at the same time }
		pressed:array[1..3] of boolean; { the actual pressing on the button }
		released:array[1..3] of boolean; { the actual releasing the button }
		ButtomPressed:array[1..3] of boolean; { the buttom that is being pressed }
		winx1,winy1,winx2,winy2:integer; { mouse window coordinates }
    mpic:mousepointertype;
		constructor init; { iniitialize variables }
		procedure getmove(var mx,my:integer); { get the movement of the mouse }
		function getmhoriz:integer; { horizontal move }
		function getmvert:integer; { vertical move }
		function getmkey(keynum:word):boolean; { is key number KEYNUM pressed }
		procedure setvisiableP; { for use with save back }
		procedure setmousetype(mtype:mt); { set the mouse type }
		procedure update; { update coordinates }
		procedure mwindow(nx1,ny1,nx2,ny2:integer); { define mouse window }
    procedure installuserpointer(newpointer:mousepointertype);
		procedure move(mx,my:integer);
    procedure moveto(mx,my:integer);
{    procedure eventmove; { sit on the interrupt and called when mouse move }
{    procedure eventkey; { sit on the interrupt and called when mouse key pressed }
{    procedure insertmove(}
		procedure display; virtual;
	end;

var
	mouse:themouse;
	checked,mouseOK : boolean;

{ Check If Mouse Respondes }
Function Check_Mouse:Boolean;

implementation

{ Check If Mouse Respondes }
Function Check_Mouse;
var
	RAX : word;
Begin
	checked := true;
	MouseOK:=False;
	asm
		mov   Ax,0  { function 0 }
		Int   $33 { the mouse interrupt }
		mov   RAx,Ax { get rsult to variable }
	end;
	If RAx = 0 Then begin
		Check_mouse:=True;
		MouseOK:=false;
	end Else Begin
	 Check_Mouse:=True;
	 MouseOK:=True;
	End;
End;

{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
{*		  	THEMOUSE OBJECT PROCEDURES		     *}
{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
constructor themouse.init;
{ initialize all vriable }
var i:byte;
begin
	{ mouse reset }
	if not checked then check_mouse;
	if mouseOK then begin
		saveback := true;
		asm
			mov     ax,06h          { reset button counts by reading them }
			mov     bx,0
			int     33h
			mov     ax,06h
			mov     bx,1
			int     33h
			mov     ax,05h
			mov     bx,0
			int     33h
			mov     ax,0Bh          { reset motion counters by reading }
			int     33h
		end;
		box.init(swidth div 2,shight div 2,msize*2,msize*2,centerbox);
		setbox(off,on);
		midx := width div 2;
		midy := hight div 2;
		hotpx := 0;
		hotpy := 0;
		x := cx;
    y := cy;
		xmove := 0;
		ymove := 0;
    mousetype := wait;
		setmousetype(arrow);
		for i := 1 to 3 do begin
			ButtomPressed[i]:=false;
		end;
		mwindow(0,0,swidth,shight);
		setvisiableP;
	end;
end;

procedure themouse.setvisiableP;
begin
	if x1 < winx1 then vx1 := winx1 else if x1 > winx2 then vx1 := winx2 else vx1 := x1;
	if x2 < winx1 then vx2 := winx1 else if x2 > winx2 then vx2 := winx2 else vx2 := x2;
	if y1 < winy1 then vy1 := winy1 else if y1 > winy2 then vy1 := winy2 else vy1 := y1;
	if y2 < winy1 then vy2 := winy1 else if y2 > winy2 then vy2 := winy2 else vy2 := y2;
end;

procedure themouse.update;
{ update the mouse pointer according to mose movement }
var i:byte;
	bp:array[1..3] of boolean;
  l:boolean;
begin
	if not mouseOK then exit;
	getmove(xmove,ymove);
  xmove := xmove;
  ymove := ymove;
	changed := ((xmove <> 0) or (ymove <> 0));
	if changed then
		move(xmove,ymove); { move will display the mouse }
  for i := 1 to 3 do begin
		BP[i]:=getmkey(i);
	  released[i] := false;
		pressed[i] := false;
		if not bp[i] and ButtomPressed[i] then released[i] := true;
		if bp[i] and not ButtomPressed[i] then pressed[i] := true;
		changed := changed or (bp[i] <> buttompressed[i]);
		ButtomPressed[i] := bp[i];
    if (mousetype=box3D) and (Pressed[i] or released[i]) then display;
	end;
	drag:=Buttompressed[1] and ((xmove <> 0) or (ymove <> 0));
end;

procedure themouse.getmove;
var u,v:integer;
begin
	asm
		mov     ax,0Bh          { get motion counters }
		int     33h
		mov     u,cx   					{ horizontal movement }
		mov     v,dx            { vertical movement }
	end;
	mx := u;
	my := v;
end;

function themouse.getmhoriz;
begin
	asm
		mov     ax,0Bh          { get motion counters }
		int     33h
		mov     @Result,dx      { horiz motion }
	end;
end;

function themouse.getmvert;
begin
	asm
		mov     ax,0Bh          { get motion counters }
		int     33h
		mov     @Result,dx      { vert motion }
	end;
end;

function themouse.getmkey;
begin
	asm
					mov     ax,06h          { get button press info  }
					int     33h
					cmp     keynum,1        { whant first mouse buttom ?}
					je      @key1           { yse }
					cmp     keynum,2        { whant second mouse buttom ?}
					je      @key2           { yse }
					cmp     keynum,3        { whant third mouse buttom ?}
					je      @key3           { yse }
@key1:
					cmp     ax,1            { is pressed }
					jne      @nopress        { no }
					jmp     @yespress       { yes }
@key2:
					cmp     ax,2            { is pressed }
					jne      @nopress        { no }
					jmp     @yespress       { yes }
@key3:
					cmp     ax,4            { is pressed }
					jne      @nopress        { no }
					jmp     @yespress       { yes }
@yespress:mov     @Result,true    { yes }
					jmp 		@byebye
@nopress:	mov			@Result,false   { no }
@byebye:
	end;
end;

procedure themouse.mwindow;
begin
	asm
		mov     ax,nx1
		mov     bx,nx2
		cmp 		ax,bx         { is nx1 > nx2 ? }
		jl      @xok          { ... }
		push    nx1           { yes }
		push    nx2           { need to reverse nx1 and nx2 }
		pop     nx1
		pop     nx2
@xok:nop                  { nx1 is smaller then nx2 }
		mov     ax,ny1
		mov     bx,ny2
		cmp 		ax,bx         { is ny1 > ny2 ? }
		jl      @yok          { ... }
		push    ny1           { yes }
		push    ny2           { need to reverse ny1 and ny2 }
		pop     ny1
		pop     ny2
@yok:nop                  { ny1 is smaller then ny2 }
	end;
	winx1 := nx1;
	winy1 := ny1;
	winx2 := nx2;
	winy2 := ny2;
	setvisiableP;
end;

procedure themouse.display;
var i,i1:integer;
	 u,v:integer;
begin
	if not mouseOK then exit;
  if buttompressed[1] or buttompressed[2] or buttompressed[3] then
		is3Dinverse := on else is3Dinverse := off;
	box.display;
	u := midx-mpic.hotpx+x1;
	v := midy-mpic.hotpy+y1;
	case mousetype of
		arrow,wait,user:begin
			for i := 1 to 11 do
				for i1:= 1 to 11 do
					if mpic.mpointer[i,i1] >= 0 then putpixel(i1+u,i+v,mpic.mpointer[i,i1]);
		end;
		cross:begin
			for i := 1 to 5 do begin
				putpixel(cx-1 ,cy-i-1,0 );
				putpixel(cx   ,cy-i-1,15);
				putpixel(cx+1 ,cy-i-1,0 );
				putpixel(cx-1 ,cy+i+1,0 );
				putpixel(cx   ,cy+i+1,15);
				putpixel(cx+1 ,cy+i+1,0 );

				putpixel(cx-i-1 ,cy-1,0 );
				putpixel(cx-i-1 ,cy  ,15);
				putpixel(cx-i-1 ,cy+1,0 );
				putpixel(cx+i+1 ,cy-1,0 );
				putpixel(cx+i+1 ,cy  ,15);
				putpixel(cx+i+1 ,cy+1,0 );
			end;
			putpixel(cx-1,cy  ,0);
			putpixel(cx+1,cy  ,0);
			putpixel(cx  ,cy+1,0);
			putpixel(cx  ,cy-1,0);
		end;
		mline:begin
			for i := 1 to 10 do begin
				putpixel(cx  ,cy+i,15);
				putpixel(cx-1,cy+i,0 );
				putpixel(cx+1,cy+i,0 );
			end;
			for i := cx-2 to cx+2 do begin
				putpixel(i,cy      ,0);
				putpixel(i,cy+msize,0);
			end;
		end;
		box3D:begin
		end;
		{ dont need box3D becuse box.display is handeling the 3D }
	end;
end;

procedure themouse.setmousetype;
var old:boolean;
begin
	if mtype <> mousetype then begin{ new mouse is eqwel to old mouse }
		old := displayed;
		erase;
		set3d(off,off);
    setbox(off,on);
    chngdim(cx,cy,msize*2,msize*2,centerbox);
    with mpic do begin
			case mtype of
        user:begin
        	mpic:=userpointer;
					mousetype := user;
				end;
        arrow:begin
        	mpic:=arrowpoint;
					mousetype := arrow;
				end;
				wait:begin
        	mpic:=waitpoint;
					mousetype := wait;
				end;
				cross:begin
					hotpx := msize div 2;
					hotpy := msize div 2;
					mousetype := cross;
				end;
				mline:begin
					hotpx := msize div 2;
					hotpy := msize div 2;
					mousetype := mline;
				end;
				box3d:begin
					hotpx := msize div 2;
					hotpy := msize div 2;
					mousetype := box3d;
					set3d(on,off);
 	        chngdim(cx,cy,msize,msize,centerbox);
				end;
			end;
    end;
		x:=cx;
		y:=cy;
		if old then display;
	end;
end;

procedure themouse.installuserpointer(newpointer:mousepointertype);
begin
  with newpointer do begin
  	if (hotpx in[0..msize]) and (hotpy in[0..msize]) then begin
			userpointer := newpointer;
	    mousetype := arrow;
  		setmousetype(user);
    end;
  end;
end;

procedure themouse.move;
var old : boolean;
	xok,yok:boolean;
begin
	xok := false;
	yok := false;
	if mx < 0 then
		if cx + mx >= winx1 then xok := true
		else begin
			xok := false;
      if displayed then	xmove := 0;
    end
	else if mx > 0 then
		if cx + mx <= winx2 then xok := true
		else begin
			xok := false;
      if displayed then	xmove := 0;
    end;

	if my < 0 then
		if cy + my >= winy1 then yok := true
		else begin
			yok := false;
      if displayed then ymove := 0;
    end
	else if my > 0 then
		if cy + my <= winy2 then yok := true
		else begin
			yok := false;
      if displayed then ymove := 0;
    end;

	if xok or yok then begin
		old := displayed;
		erase;
    displayed := old;
  end;

	if xok then begin
		inc(cx,mx);
		inc(x1,mx);
		inc(x2,mx);
		inc(x ,mx);
	end;

	if yok then begin
		inc(cy,my);
		inc(y1,my);
		inc(y2,my);
		inc(y ,my);
	end;

	if xok or yok then begin
		displayed := old;
		setvisiableP;
		getbackimage;
		if displayed then display;
  end;
end;

procedure themouse.moveto;
{ move the mouse to specipied point }
var
	gx,gy:integer;
begin
	gx := cx-mx;
  gy := cy-my;
  move(gx,gy);
end;

begin
	checked := false;
	mouseok := false;
end.