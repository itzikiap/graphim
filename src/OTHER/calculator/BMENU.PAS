unit bmenu;
{**************************************************}
{*     Menu initialization and handeling routings *}
{**************************************************}
interface
uses general,drivers,mousebx,boxes,bxlist,app;
type
	command=record
  	name:string;
    ctrl:byte;
  end;

  pborder = ^border;
	border=record
  	x1,y1,x2,y2:integer;
    clip:boolean;
  end;

  Pmenubar = ^menubar;
	Menubar=object(objbank)
    active:boolean;
    exclusive:boolean;
    noctl : word; { ctl if mouse not inside menu }
    overctl:word; { the ctl of the box that is currently in over mode }
    overID:byte; { the ID of that box }
    pressed:boolean;
    over,press,normal:msgbox;
  	constructor init(name:string8;x1,y1,x2,y2:integer);
    function cycle(id:word):word; { to insert in APP object }
    function exerunit:word;
    procedure start;
    function handleevent(EV:word):boolean; virtual;
    destructor bye;
  end;

{ IB InitBorder                                 }
{		Initialize the border to your needsd.       }
{    	give 0 to use default value               }
procedure IB(var b:border;x1,y1,x2,y2:integer);
{ INITMENU                                            }
{  INITMENU2                                          }
{  - Initialize a menyu using object bank.            }
{  InitMenu2 get an empty bank and fills it with menu }
{  InitMenu is a function that create NEW bank        }
function initmenu(wx,wy,dx,dy:integer;cmd:array of command;b:border):pmenubar;
procedure initmenu2(c:pmenubar;wx,wy,dx,dy:integer;cmd:array of command;b:border);

implementation
{****************************}
{*    Menubar   methods     *}
{****************************}
{ INIT }
constructor menubar.init;
begin
  inherited init(name);
  noctl := 0;
  over.init('',0,0);
  over.autosize := false;
  press.init('',0,0);
  press.autosize := false;
  normal.init('',0,0);
  normal.autosize := false;
  fastmsgbox(over  ,on,on,on,on ,small,15,0,7,2,6,center,off);
  fastmsgbox(press ,on,on,on,on ,small,14,0,8,2,6,center,off);
  fastmsgbox(normal,on,on,on,off,small,15,0,7,2,6,center,off);
  active := false;
end;

function menubar.cycle;
{ Main functuion of the menu. }
{ you should install this in the app }
{ ID have a meaning! if even - no mouse pressed if odd mouse pressed }
var
	ct,idd:word;
  b:^msgbox;

begin
  cycle := 0;
  if not active then exit;
	if ID mod 2 = 0 then begin
  	{ Nothing pressed }
		ct := getisinctl(mouse.x,mouse.y);
    idd := overID;
    if ct <> 0 then begin
    	if (overctl <> ct) then begin
        b := selected^.obj;
        if b=nil then exit;
        mouse.erase;
        b^.copy(over);
        b^.displayed := true;
        mouse.display;
        overID := selected^.ID;
        if (overctl <> 0) then begin
        	select(IDD);
        	b := selected^.obj;
          mouse.erase;
        	b^.copy(normal);
	        b^.displayed := true;
          mouse.display;
        end;
        overctl := ct;
      end else if pressed then begin { released a mouse over a selected menu }
        cycle:= ct;
        b := selected^.obj;
        mouse.erase;
        b^.copy(normal);
        b^.displayed := true;
        mouse.display;
        overID := selected^.ID;
      end;
    	pressed := false;
    end else begin { CT = 0 -> mouse not on menu }
      if (overctl <> 0) then begin
        select(overID);
        b := selected^.obj;
        mouse.erase;
       	b^.copy(normal);
        b^.displayed := true;
        mouse.display;
        overID :=0;
        overctl :=0;
      end;
		end;
  end else begin
  { something pressed }
  	ct := getisinctl(mouse.x,mouse.y);
    idd := overID;
    if ct <> 0 then begin
    	if pressed = false then begin
        select(overID);
        b := selected^.obj;
        mouse.erase;
        b^.copy(press);
        b^.displayed := true;
        mouse.display;
        overID := selected^.ID;
      end;
      pressed := true;
    end else
			cycle := noctl;
  end;
end;

function menubar.exerunit;
var
	ct:word;
  e:boolean;
begin
	repeat
  	mouse.update;
    if mouse.buttompressed[1] then ct := cycle(1)
    else ct := cycle(2);
    e := not exclusive or (ct <> 0);
    if exclusive then e := handleevent(ct);
  until e;
  exerunit := ct;
end;

procedure menubar.start;
{ Initialize for running }
begin
	active := true;
  overctl := 0;
  overID:= 0;
  pressed := off;
  display(0);
end;

function menubar.handleevent;
begin
	handleevent := false;
end;

destructor menubar.bye;
begin
	inherited bye;
end;






procedure initmenu2;
{ INITIALIZE a menu                                    }
{ Get:                                                 }
{	 	C - the menu object. MUST BE EMPTY                 }
{   WX,WY- the base point                              }
{   DX,DY - the offset (1,0 for horiz 0,1 for vert)    }
{   CMD - the commands                                 }
{   B - the border in the form of a record             }
var
	i1:word;
  s:string;
  v:string8;
  x,y:word;
  m:^msgbox;
begin
  x := wx+b.x1;
  y := wy+b.y1;

  s := '';
	for i1 := 0 to high(cmd) do
		if length(cmd[i1].name) > length(s) then s := cmd[i1].name;
  for i1 := 1 to length(s) do s[i1] := 'X';

  with c^ do begin
  	init('Menu',b.x1,b.y1,b.x2,b.y2);
    for I1 := 0 to high(cmd) do begin
      v := cmd[i1].name;
    	m := insert(cmd[i1].ctrl,v,Tmenuitem,sizeof(msgbox));
      m^.init(s,0,0);
      m^.copy(normal);
      m^.autosize := off;
      y:=y+(m^.hight+2)*dy;
      if (dy <> 0) and ((y > b.y2) or (y<b.y1)) then begin
				y := wy;
        x := x+(m^.width+2);
      end;
      x:=x+(m^.width+2)*dx;
      if (dx <> 0) and ((x > b.x2) or (x<b.x1)) then begin
				x := wx;
        y := y+(m^.hight+2);
      end;
      m^.move(x,y,absboxmove);
      m^.chngmsg(cmd[i1].name);
      m^.textshadow := on;
    end;
  end;
	m := nil;
end;

function initmenu;
var
	c:pmenubar;
begin
  if maxavail<sizeof(pobjbank) then begin
  	initmenu := nil;
  	exit;
  end;
  new(c);
  initmenu2(c,wx,wy,dx,dy,cmd,b);
	initmenu := c;
end;



procedure ib;
{ INITBORDER - good for use in functions }
var
  i:integer;
begin
  if x1 > x2 then begin
  	i := x2;
		x2 := x1;
		x1 := i;
	end;
  if y1 > y2 then begin
  	i := y2;
		y2 := y1;
		y1 := i;
	end;
  if x2 = 0 then x2 := swidth;
  if y2 = 0 then y2 := shight;
	b.x1 := x1;
	b.x2 := x2;
	b.y1 := y1;
	b.y2 := y2;
  b.clip := true;
end;

end.