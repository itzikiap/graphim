unit bmenu;
{**************************************************}
{*     Menu initialization and handeling routings *}
{**************************************************}
interface
uses general,drivers,mousebx,boxes,bxlist,app;

type
	command=record
  	name:string;
    ctrl:word;
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
    OnClick:Boolean; { Set true if you want to return the CTL on mouse click or release }
    noctl : word; { ctl if mouse not inside menu }
    overctl:word; { the ctl of the box that is currently in over mode }
    overID:byte; { the ID of that box }
    pressed:boolean;
    over,press,normal:msgbox;
  	constructor init(name:string8;x1,y1,x2,y2:integer);
    function cycle(id:word):word; { to insert in APP object }
    procedure chngmsg(wid:word;newmsg:string);
    function getmsg(wid:word):string;
    function GetISINCTL(wx,wy:word):word;{ return the ctl of the object under these coordinates }
    procedure display(wid:boolean); { Display OR ERASE. depending on WID }
    procedure newboxes; { if you changed the boxes, you must update the menu with this }
    function exerunit:word;
    procedure start;
    function handleevent(EV:word):boolean; virtual;
    destructor bye;
  end;

var
	dover,dnormal,dpress:msgbox; { the default boxes for the next menu to be created }


{ IB InitBorder                                 }
{		Initialize the border to your needsd.       }
{    	give 0 to use default value               }
procedure IB(var b:border;x1,y1,x2,y2:integer);
{ INITMENU                                            }
{  INITMENU2                                          }
{  - Initialize a menyu using object bank.            }
{  InitMenu2 get an empty bank and fills it with menu }
{  InitMenu is a function that create NEW bank        }
function initmenu(wx,wy,dx,dy:integer;cmd:array of command;name:string8;b:border):pmenubar;
procedure initmenu2(c:pmenubar;wx,wy,dx,dy:integer;cmd:array of command;name:string8;b:border);
{ DEFAULTMENUS - initialize the menuboxes to be  }
{   copyed to the next menu                      }
procedure DefaultMenus;


implementation
{****************************}
{*    Menubar   methods     *}
{****************************}
{ INIT }
constructor menubar.init;
begin
  inherited init(name);
  if dover.initialized <> initnum then defaultmenus;

  noctl := 0;
  over.init('',0,0);
  press.init('',0,0);
  normal.init('',0,0);
  over.copym(dover);
  press.copym(dpress);
  normal.copym(dnormal);
  OnClick := false;
  active := false;
end;

function menubar.GetISINCTL;
{--------------------------------}
{           GET ISIN CTL         }
{ return the ctl of the object   }
{  under these coordinates       }
{ NOTE: Always get the last      }
{				(topmost) object.        }
{--------------------------------}
var
	p,me:pobjlist;
  b:^box;
	e:boolean;
begin
  e := on;
  p := nil;
  me := @list;
 	if me^.next=nil then e:=off	else me := me^.next;
  while e do begin
    if me^.isboxtype then begin
      b:=me^.obj;
			if b^.isin(wx,wy) then p := me;
    end;
    if me^.next=nil then e:=off	else me := me^.next;
  end;
  if selectfind then selected := p;
  if p <> nil then getisinctl := p^.ctl else getisinctl := 0;
end;


function menubar.getmsg;
var b:^msgbox;
begin
	selected := list.getid(wid);
  b := selected^.obj;
  getmsg := b^.msg;
end;

procedure menubar.chngmsg;
var b:^msgbox;
begin
	if wid <> 0 then selected := list.getid(wid);
  b := selected^.obj;
  b^.chngmsg(newmsg);
end;

procedure menubar.newboxes;
{ update the boxes to the new box }
var
	b:^msgbox;
begin
  selected := @list;
  while selected^.next <> nil do begin
  	b := selected^.obj;
    b^.copym(normal);
  	selected := selected^.next;
  end;
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
        b^.copym(over);
        b^.displayed := true;
        mouse.display;
        overID := selected^.ID;
        if (overctl <> 0) then begin
        	select(IDD);
        	b := selected^.obj;
          mouse.erase;
        	b^.copym(normal);
	        b^.displayed := true;
          mouse.display;
        end;
        overctl := ct;
      end else if pressed then begin { released a mouse over a selected menu }
        if onclick then cycle:= noctl else cycle := ct;
        b := selected^.obj;
        mouse.erase;
        b^.copym(normal);
        b^.displayed := true;
        mouse.display;
        overID :=selected^.ID;
      end;
    	pressed := false;
    end else begin { CT = 0 -> mouse not on menu }
      if (overctl <> 0) then begin
        select(overID);
        b := selected^.obj;
        mouse.erase;
       	b^.copym(normal);
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
        if not onclick then cycle := 0 else cycle := ct;
        select(overID);
        b := selected^.obj;
        mouse.erase;
        b^.copym(press);
        b^.displayed := true;
        mouse.display;
        overID := selected^.ID;
      end;
      pressed := true;
    end else
			cycle := noctl;
  end;
end;

procedure menubar.display;
{ DISPLAY OR HIDE THE ENTIRE MENU                 }
{ 0 - Display all items                           }
{ 1 - Erase All items                             }

var
	t:^box;
begin
 	selected := list.next;
	repeat
    if selected^.isboxtype then begin
	   	t:=selected^.obj;
      if wid then begin
	      t^.display;
  	 	  t^.displayed := true;
      end else begin
	      t^.erase;
  	 	  t^.displayed := false;
      end;
    end;
  	selected := selected^.next;
  until selected = nil;
end;

function menubar.exerunit;
var
	ct:word;
  e:boolean;
begin
  ct := 0;
	repeat
  	mouse.update;
    if mouse.buttompressed[1] then ct := cycle(1)
    else ct := cycle(2);
    chngmsg(1,stry(ct,1,1));
    e := not exclusive or (ct <> 0);
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
  display(true);
end;

function menubar.handleevent;
begin
	handleevent := false;
end;

destructor menubar.bye;
begin
  display(false);
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
  bw,bh:word;
  m:^msgbox;
begin
  x := wx+b.x1;
  y := wy+b.y1;

  bw := 0;
  bh := 0;

  s := '';
	for i1 := 0 to high(cmd) do
		if length(cmd[i1].name) > length(s) then s := cmd[i1].name;
  for i1 := 1 to length(s) do s[i1] := 'X';

  with c^ do begin
  	init(name,b.x1,b.y1,b.x2,b.y2);
    for I1 := 0 to high(cmd) do begin
      v := cmd[i1].name;
    	m := insert(cmd[i1].ctrl,v,Tmenuitem,sizeof(msgbox));
      m^.init(s,0,0);
      m^.copym(normal);
      m^.autosize := off;
      if m^.hight > bh then bh := m^.hight;
      if m^.width > bw then bw := m^.width;
      y:=y+(m^.hight+1)*dy;
      if (dy <> 0) and ((y > b.y2) or (y<b.y1)) then begin
				y := wy;
        x := x+(bw+1);
      end;
      x:=x+(m^.width+1)*dx;
      if (dx <> 0) and ((x > b.x2) or (x<b.x1)) then begin
				x := wx;
        y := y+(bh+1);
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
  initmenu2(c,wx,wy,dx,dy,cmd,name,b);
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

procedure DefaultMenus;
begin
  dover.init('',0,0);
  dover.autosize := false;
  dpress.init('',0,0);
  dpress.autosize := false;
  dnormal.init('',0,0);
  dnormal.autosize := false;
  fastmsgbox(dover  ,on,on,on,on ,small,15,0,7,2,6,center,off);
  fastmsgbox(dpress ,on,on,on,on ,small,14,0,8,2,6,center,off);
  fastmsgbox(dnormal,on,on,on,off,small,15,0,7,2,6,center,off);
end;

end.