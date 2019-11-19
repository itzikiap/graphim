program builder;
{--------------------------------------}
{  Interface builder                   }
{     An attempt to make a program that}
{     build an interface and save it   }
{			into a unit that you can use in  }
{     programs.                        }
{--------------------------------------}
uses general,drivers,mousebx,boxes,exbox,bxlist,bmenu;
const
  menu1=6;

	Mexit=11;
  Mboom=16;
  Mshowmem=13;
  Mshowobj=14;
  Mautomode=15;
  Mmenu=12;
  Mlist=17;

  Bdisplay=21;


  cmd:array[1..menu1] of command=(
	(name:'EXIT';ctrl:mexit),
	(name:'MENU';ctrl:mmenu),
	(name:'MEM'; ctrl:mshowmem),
	(name:'OBJ'; ctrl:mshowobj),
	(name:'AUTO';ctrl:mautomode),
	(name:'BOOM';ctrl:mboom));

var
  l:objbank;
{  ctrl:pobjbank;}
  Xm:msgbox;
  m:^msgbox;
  i1,c:word;
  p:pobjlist;
  po:pointer;
  e:boolean;

  mauto,mmem:boolean;

type
	buildmenu=object(menubar)
    constructor init;
  	function handleevent(ev:word):boolean; virtual;
    destructor bye;
  end;


procedure handlelist; forward;

{ app funcs }
function Pauto(ID:word):word;
begin
	mauto := not mauto;
  pauto := 0;
end;
function Pmem(ID:word):word;
begin
	if id=mshowmem then mmem := true else mmem := false;
  pmem := 0;
end;
function Pboom(ID:word):word;
begin
	l.delete(0);
	pboom := 0;
end;
function PMenu(ID:word):word;
var
	m:buildmenu;
  b:border;
  c:word;
begin
  ib(b,0,0,0,0);
    m.init;
	initmenu2(@m,mouse.x,mouse.y,1,0,cmd,b);
  m.exclusive := false;
  mouse.erase;
  m.noctl := mlist;
  m.start;
  mouse.display;
  repeat
    c:=m.exerunit;
  	m.handleevent(c);
	until c <> 0;
  pmenu := c;
  mouse.erase;
	m.bye;
  mouse.bye;
end;
function plist(ID:word):word;
begin
  with mouse do begin
    erase;
		if not mauto then begin
			if pressed[1] then handlelist;
		end else begin
			repeat update; handlelist; until released[1];
	  end;
  	display;
  end;
end;

constructor buildmenu.init;
begin
 inherited init('build',0,0,0,0);
end;
destructor buildmenu.bye;
begin
 inherited bye;
end;
function buildmenu.handleevent(ev:word):boolean;
begin
  inherited handleevent(ev);
  with mouse do begin
		case ev of
     	Mexit:handleevent := true;
      Mboom:pboom(mboom);
      Mshowmem:pmem(mshowmem);
      Mshowobj:pmem(mshowobj);
      Mautomode:pauto(mautomode);
      Mmenu: handleevent := pmenu(c)=Mexit;
      Mlist: plist(2);
    end;
	end;
end;

procedure handlelist;
{--------------------------------------}
var
	x,y:integer;
  p :pobjlist;
	m : ^msgbox;
  i:msgbox;
begin
  x := mouse.x;
  y := mouse.y;
  with i do begin
		init('00',x,y);
  	setjustify(center);
    setmcolor(random(7)+8,1,random(7)+1);
    set3D(on,on);
    saveback := off;
    autosize := off;
    chngmsg('');
	end;
  if not mauto then	p := l.findbyisin(x,y)
  else begin
  	p := nil;
    if not mouse.changed then exit;
  end;
  if (p=nil) then begin
  	m := l.insert(7,'BOX',tmsgbox,sizeof(msgbox));
    if m=nil then begin
			l.delete(1);
	    l.select(1);
  	  repeat
    	 	m := l.selected^.obj;
      	m^.chngmsg(stry(l.selected^.id,0,0));
    	until l.selectnext = 0;
    	m := l.insert(7,'BOX',tmsgbox,sizeof(msgbox));
    end;
  	c := l.objects;
    m^.init(stry(c,0,0),0,0);
    m^.copy(i);
    m^.chngmsg(stry(c,0,0));
    m^.display;
    if mmem then Xm.chngmsg(stry(maxavail,0,0)) else if c <> 0 then Xm.chngmsg(stry(c,0,0));
  end else begin
  	c := l.delete(p^.id);
    if mmem then Xm.chngmsg(stry(maxavail,0,0)) else if c <> 0 then Xm.chngmsg(stry(c,0,0));
    l.select(1);
    repeat
     	m := l.selected^.obj;
      m^.chngmsg(stry(l.selected^.id,0,0));
    until l.selectnext = 0;
  end;
end;


function run(ID:word):word;
var
	m:buildmenu;
  b:border;
begin
  ib(b,0,0,0,0);
  m.init;
	initmenu2(@m,0,17,0,1,cmd,b);
  m.exclusive := true;
  m.noctl := Mlist;
  m.start;
  repeat
  until	m.exerunit=Mexit;
  m.bye;
end;
{--------------------------------------------}
begin
  graphinit(4);
  mauto := off;
  mmem := off;
  randomize;
  mouse.init;
  mouse.display;
  Xm.init('000000',505,460);
  xm.autosize := false;
  xm.setmcolor(1,12,7);
  xm.set3D(on,off);
  xm.display;
  l.init('boxes');
  c := 0;
  e:=off;
	run(0);
{	ctrl:=initmenu(15,15,1,0,cmd);
  ctrl^.display(0);
  while not e do begin
    with mouse do begin
			update;
      if pressed[1] then begin
        erase;
        c := ctrl^.getisinctl(x,y);
        handlemenu(c);
        menueffect(ctrl);
        display;
    	end;
      if pressed[2] then e := true;
    end;
  end;}
	l.bye;
  xm.bye;
end.

