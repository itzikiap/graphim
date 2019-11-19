unit bxlbox;
{ Implementation of list of boxes }
interface
uses general,bxlist,mousebx,app,boxes,exbox;
type
  PBox=^box;
  PMBox=^msgbox;
	PBoxBank=^BoxBank;

  BoxBank=Object(ObjBank)
    boxmode:boolean; { Turn on if you sure that all your objects are boxes }
    LastBox:Pmbox;
    DefaultBox:box;
    {parimiter:border;}
    constructor init(name:string8);
    function insert(x1,y1,x2,y2:integer;ICntr:boolean;tname:string8;nctl:byte):pbox;
{    procedure insert2(x1,y1,x2,y2:integer;ICntr:boolean;tname:string8;nctl:byte;Newbox:Pbox);}
{    function GetISINCTL(wx,wy:word):byte; { return the ctl of the object under these coordinates }
    function GetISINCTL(wx,wy:word):word;{ return the ctl of the object under these coordinates }
    Function findbyisin(wx,wy:word):Pobjlist;
		procedure display(n:byte); { display item (0=all) }
		procedure hide(N:byte); { hide item (0=all) }
    { specific operation (on one box) that not listed }
		{ can be achived by List.GetID() }
    { in all procedures: What=0 meen ALL boxes }
    procedure move(what:byte;dx,dy:integer;isrelative:boolean); { move selected menu item if 0 then move all }
    procedure msize(what:byte;nx2,ny2:integer;iscenter:boolean); { how much to increes }
    procedure set3D(what:byte;is3D,is3Dinv:boolean);
    procedure setmcolor(what:byte;backcolor,forecolor:byte);
    procedure copybox(What:byte;whatbox:box); { copy all attributes of specific box  }
{    procedure zoom(dx,dy:integer;iscenter:boolean); { zoom all items }
    { SendTO - in Z order. Where- 1: all back; 2: step back; 3:step fore; 4: all fore}
		{                             10 and above - to specific place minus 10          }
{  	procedure sendto(what,where:byte);{sorry }
    destructor bye;
  end;

  msgbank=object(boxbank)
{  	lastmbox:pmbox;}
    constructor init(name:string8);
    function insertm(st:string;x2,y2:integer;tname:string8;nctl:byte):pmbox;
{    procedure insert2m(x1,y1,x2,y2:integer;ICntr:boolean;tname:string8;nctl:byte;Newbox:Pmbox);}
    procedure setfont(Wid:word;fn,fs:byte);
    procedure chngmsg(wid:word;nmsg:string);
    function getmsg(wid:word):string;
    destructor bye;
  end;


  { the prototype: this box will be copyed to all boxes. }
	{ x1 and y1 are the starting point (x2 and y2 should be equel to x1 and y1)}
{	procedure makeboxlist(var wbank:boxbank;prototype:box;rx:byte);
  procedure makeboxmatrix(var wbank:boxbank;prototype:box;rx,ry:byte);}

implementation

(********************************)
(*           Box Bank           *)
(********************************)
constructor boxbank.init;
begin
  selectfind := true;
  selectnew  := true;
 	boxmode := true;
	with defaultbox do begin
  	init(0,0,20,20,on);
    setmcolor(15,7);
    set3D(on,off);
  end;

  boxmode := true;
  lastbox:=nil;
  objects := 0;
	selected := nil;
  list.init(name,'BOX');
end;

{ INSERT - V1 Creates the object and return its pointer }
{ INSERT2- V2 Gets a pointer (NOT INITIALIZED)          }
function boxbank.insert;
begin
	lastbox:=objbank.insert(nctl,tname,'BOX',sizeof(msgbox));
 	boxmode := true;
  lastbox^.init('',x2-x1,y2-y1);
  lastbox^.autosize := off;
  lastbox^.copy(defaultbox);
  lastbox^.chngdim(x1,y1,x2,y2,off);
  insert:=lastbox;
end;

{procedure boxbank.insert2;
begin
  newbox^.init('',x2-x1,y2-y1);
  newbox^.chngdim(x1,y1,x2,y2,off);
	objbank.insert(nctl,tname,'BOX',sizeof(box));
  lastbox := newbox;
end;}

function boxbank.findbyisin;
{--------------------------------}
{          FIND BY ISIN          }
{ return the object under these  }
{				coordinates              }
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
  findbyISIN := p;
  if selectfind then selected := p;
end;


function boxbank.GetISINCTL;
{--------------------------------}
{           GET ISIN CTL         }
{ return the ctl of the object   }
{  under these coordinates       }
{ NOTE: Always get the last      }
{				(topmost) object.        }
{--------------------------------}
var p:pobjlist;
	c:byte;
begin
	p:=findbyisin(wx,wy);
  if p <> nil then c := p^.ctl else c := 0;
  if c <>0 then lastbox := selected^.obj;
  getisinctl:= c;
end;

procedure boxbank.display;
{ DISPLAY THE REQUESTED ITEM (if it a box type...) }
{ 0 - Display all items                           }
{     0 parameter works ONLY if boxmode is on!!!  }
var
	t:^box;
begin
	if n <> 0 then begin
  	selected := list.getid(n);
    if selected^.isboxtype then begin
			t := selected^.obj;
			t^.display;
      t^.displayed := true;
    end;
  end else {if boxmode then} begin
  	selected := list.next;
		repeat
      if selected^.isboxtype then begin
	    	t:=selected^.obj;
        t^.display;
    	  t^.displayed := true;
      end;
  		selected := selected^.next;
  	until selected = nil;
  end;
end;

procedure boxbank.hide;
{ HIDE THE REQUESTED ITEM (if it a box type...)   }
{ 0 - Display all items                           }
{     0 parameter works ONLY if boxmode is on!!!  }
var
	t:^box;
begin
	if n <> 0 then begin
  	selected := list.getid(n);
    if selected^.isboxtype then begin
			t := selected^.obj;
			t^.erase;
    end;
  end else if boxmode then begin
  	selected := list.next;
		repeat
  		selected := selected^.next;
    	t := selected^.obj;
			t^.erase;
  	until selected^.next = nil;
  end;
end;
{ MOVE the desirable object }
procedure boxbank.move;
begin
	if what <> 0 then begin
		list.getid(what);
    lastbox := selected^.obj;
    lastbox^.move(dx,dy,isrelative);
  end else begin
  	list.getid(1);
    lastbox := selected^.obj;
    lastbox^.move(dx,dy,isrelative);
    while selected^.next <> nil do begin
      lastbox := selected^.obj;
      lastbox^.move(dx,dy,isrelative);
    	selected:= selected^.next;
    end;
  end;
end;

{ CHNGDIM the desirable object }
procedure boxbank.msize;
begin
	if what <> 0 then begin
		list.getid(what);
    lastbox := selected^.obj;
    with lastbox^ do begin
	    if iscenter then chngdim(0,0,width+nx2,hight+ny2,on)
      else chngdim(x1,y1,x2+nx2,y2+ny2,off);
    end;
  end else begin
  	list.getid(1);
    lastbox := selected^.obj;
    with lastbox^ do begin
	    if iscenter then chngdim(0,0,width+nx2,hight+ny2,on)
   	  else chngdim(x1,y1,x2+nx2,y2+ny2,off);
    end;
    while selected^.next <> nil do begin
      lastbox := selected^.obj;
	    with lastbox^ do begin
		    if iscenter then chngdim(0,0,width+nx2,hight+ny2,on)
    	  else chngdim(x1,y1,x2+nx2,y2+ny2,off);
      end;
    	selected:= selected^.next;
    end;
  end;
end;

{ set3D the desirable object }
procedure boxbank.set3D;
begin
	if what <> 0 then begin
		list.getid(what);
    lastbox := selected^.obj;
    lastbox^.set3D(is3D,is3Dinv);
  end else begin
  	list.getid(1);
    lastbox := selected^.obj;
    lastbox^.set3D(is3D,is3Dinv);
    while selected^.next <> nil do begin
      lastbox := selected^.obj;
      lastbox^.set3D(is3D,is3Dinv);
    	selected:= selected^.next;
    end;
  end;
end;

{ setMcolor the desirable object }
procedure boxbank.setmcolor;
begin
	if what <> 0 then begin
		list.getid(what);
    lastbox := selected^.obj;
    lastbox^.setmcolor(0,backcolor,forecolor);
  end else begin
  	list.getid(1);
    lastbox := selected^.obj;
    lastbox^.setmcolor(0,backcolor,forecolor);
    while selected^.next <> nil do begin
      lastbox := selected^.obj;
      lastbox^.setmcolor(0,backcolor,forecolor);
    	selected:= selected^.next;
    end;
  end;
end;

{ copy the box to the wanted object or all }
procedure boxbank.copybox;
begin
	if what <> 0 then begin
		list.getid(what);
    lastbox := selected^.obj;
    lastbox^.copy(whatbox);
  end else begin
  	list.getid(1);
    lastbox := selected^.obj;
    lastbox^.copy(whatbox);
    while selected^.next <> nil do begin
      lastbox := selected^.obj;
      lastbox^.copy(whatbox);
    	selected:= selected^.next;
    end;
  end;
end;

destructor boxbank.bye;
begin
	lastbox := nil;
  inherited bye;
end;

{**********************************************}
constructor msgbank.init;
begin
	inherited init(name);
  list.tpe := TmsgBox;
end;

{ INSERT - V1 Creates the object and return its pointer }
{ INSERT2- V2 Gets a pointer (NOT INITIALIZED)          }
function msgbank.insertm;
begin
	lastbox:=objbank.insert(nctl,tname,'BMS',sizeof(msgbox));
  lastbox^.init(st,x2,y2);
  lastbox^.copy(defaultbox);
  lastbox^.move(x2,y2,absboxmove);
  insertm:=lastbox;
end;

procedure msgbank.setfont;
begin
	if wid <> 0 then begin
		list.getid(wid);
    lastbox := selected^.obj;
    lastbox^.setfont(fn,fs);
  end else begin
  	list.getid(1);
    lastbox := selected^.obj;
    if selected^.tpe = 'BMS' then lastbox^.setfont(fn,fs);
    while selected^.next <> nil do begin
      lastbox := selected^.obj;
	    if selected^.tpe = 'BMS' then lastbox^.setfont(fn,fs);
    	selected:= selected^.next;
    end;
  end;
end;

procedure msgbank.chngmsg;
begin
	if wid <> 0 then begin
		list.getid(wid);
    lastbox := selected^.obj;
    lastbox^.chngmsg(nmsg);
  end;
end;

function msgbank.getmsg;
var
	st : string;
begin
	if wid <> 0 then begin
		list.getid(wid);
    lastbox := selected^.obj;
    lastbox^.getmsg(st);
    getmsg := st;
  end;
end;

destructor msgbank.bye;
begin
	inherited bye;
end;

{procedure boxbank.insert2m;
begin
  newbox^.init(x1,x2,y1,y2,icntr);
	objbank.insert(nctl,tname,'BMS',sizeof(msgbox));
  lastmbox := newbox;
end;}

end.