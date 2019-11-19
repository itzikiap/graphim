unit bxlbox;
{ Implementation of list of boxes }
interface
uses general,bxlist,mousebx,app,boxes,exbox,drivers;
type
  PIbox=^inputbox;
	PBoxBank=^BoxBank;

  BoxBank=Object(ObjBank)
{    boxmode:boolean; { Turn on if you sure that all your objects are boxes }
    lastbox:pointer;
{    LastBox:Pbox;}
    DefaultBox:^box;
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

  Inputbank=object(msgbank)
{    lastIbox:Pibox;}
		enabled : byte; { the input box to get the input }
    readyforinput:boolean; { is thaat input box ready to get its input or not? }
  	constructor init(name:string8);
    function inserti(st:string;x2,y2:integer;tname:string8;nctl:byte):pibox;
    procedure setvalue(wid:word;nvlu:string);
		function get(wid:byte):string;
    procedure setallselection(wid:word);
    procedure enable(wid:word;toenable:boolean);
    procedure sendkey(kb:tevent);
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
{ 	boxmode := true;}
  new(defaultbox);
	with defaultbox^ do begin
  	init(0,0,20,20,on);
    setmcolor(15,7);
    set3D(on,off);
  end;

  lastbox:=nil;
  objects := 0;
	selected := nil;
  list.init(name,'BOX');
end;

{ INSERT - V1 Creates the object and return its pointer }
{ INSERT2- V2 Gets a pointer (NOT INITIALIZED)          }
function boxbank.insert;
var b:pbox;
begin
	lastbox:=objbank.insert(nctl,tname,'BOX',sizeof(msgbox));
  b := lastbox;
  b^.init(x1,y1,x2,y2,cornerbox);
  b^.copyb(defaultbox);
  b^.chngdim(x1,y1,x2,y2,off);
  b := b;
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
  se:pobjlist;
begin
	if n <> 0 then begin
  	se := list.getid(n);
    if se^.isboxtype then begin
			t := se^.obj;
			t^.display;
      t^.displayed := true;
    end;
  end else {if boxmode then} begin
  	se := list.next;
		repeat
      if se^.isboxtype then begin
	    	t:=se^.obj;
        t^.display;
    	  t^.displayed := true;
      end;
  		se := se^.next;
  	until se = nil;
  end;
end;

procedure boxbank.hide;
{ HIDE THE REQUESTED ITEM (if it a box type...)   }
{ 0 - Display all items                           }
{     0 parameter works ONLY if boxmode is on!!!  }
var
	t:^box;
  se:pobjlist;
begin
	if n <> 0 then begin
  	se := list.getid(n);
    if se^.isboxtype then begin
			t := se^.obj;
			t^.erase;
    end;
  end else {if boxmode then} begin
  	se := list.next;
		repeat
  		se := se^.next;
    	t := se^.obj;
			t^.erase;
  	until se^.next = nil;
  end;
end;
{ MOVE the desirable object }
procedure boxbank.move;
var b:pbox;
begin
	if what <> 0 then begin
		list.getid(what);
    lastbox := selected^.obj;
    b := lastbox;
    b^.move(dx,dy,isrelative);
  end else begin
  	list.getid(1);
    lastbox := selected^.obj;
    b := lastbox;
    b^.move(dx,dy,isrelative);
    while selected^.next <> nil do begin
      b := selected^.obj;
      b^.move(dx,dy,isrelative);
    	selected:= selected^.next;
    end;
  end;
end;

{ CHNGDIM the desirable object }
procedure boxbank.msize;
var
	b:pbox;
begin
	if what <> 0 then begin
		list.getid(what);
    lastbox := selected^.obj;
    b := lastbox;
    with b^ do begin
	    if iscenter then chngdim(0,0,width+nx2,hight+ny2,on)
      else chngdim(x1,y1,x2+nx2,y2+ny2,off);
    end;
  end else begin
  	list.getid(1);
    lastbox := selected^.obj;
    b := lastbox;
    with b^ do begin
	    if iscenter then chngdim(0,0,width+nx2,hight+ny2,on)
   	  else chngdim(x1,y1,x2+nx2,y2+ny2,off);
    end;
    while selected^.next <> nil do begin
      lastbox := selected^.obj;
	    b := lastbox;
	    with b^ do begin
		    if iscenter then chngdim(0,0,width+nx2,hight+ny2,on)
    	  else chngdim(x1,y1,x2+nx2,y2+ny2,off);
      end;
    	selected:= selected^.next;
    end;
  end;
end;

{ set3D the desirable object }
procedure boxbank.set3D;
var
	b:pbox;
begin
	if what <> 0 then begin
		list.getid(what);
    lastbox := selected^.obj;
    b := lastbox;
    b^.set3D(is3D,is3Dinv);
  end else begin
  	list.getid(1);
    lastbox := selected^.obj;
    b := lastbox;
    b^.set3D(is3D,is3Dinv);
    while selected^.next <> nil do begin
      lastbox := selected^.obj;
	    b := lastbox;
      b^.set3D(is3D,is3Dinv);
    	selected:= selected^.next;
    end;
  end;
end;

{ setMcolor the desirable object }
procedure boxbank.setmcolor;
var
	b:pbox;
begin
	if what <> 0 then begin
		list.getid(what);
    lastbox := selected^.obj;
    b := lastbox;
    b^.setmcolor(backcolor,forecolor);
  end else begin
  	list.getid(1);
    lastbox := selected^.obj;
    b := lastbox;
    b^.setmcolor(backcolor,forecolor);
    while selected^.next <> nil do begin
      lastbox := selected^.obj;
 	 	  b := lastbox;
      b^.setmcolor(backcolor,forecolor);
    	selected:= selected^.next;
    end;
  end;
end;

{ copy the box to the wanted object or all }
procedure boxbank.copybox;
var
	b:pbox;
begin
	if what <> 0 then begin
		list.getid(what);
    lastbox := selected^.obj;
    b := lastbox;
    b^.copyb(@whatbox);
  end else begin
  	list.getid(1);
    lastbox := selected^.obj;
    b := lastbox;
    b^.copyb(@whatbox);
    while selected^.next <> nil do begin
      lastbox := selected^.obj;
	    b := lastbox;
      b^.copyb(@whatbox);
    	selected:= selected^.next;
    end;
  end;
end;

destructor boxbank.bye;
begin
	lastbox := nil;
  inherited bye;
end;

{*******************************************************}
{*******************************************************}
{*******************************************************}
constructor msgbank.init;
begin
	inherited init(name);
  list.tpe := TmsgBox;
end;

{ INSERT - V1 Creates the object and return its pointer }
{ INSERT2- V2 Gets a pointer (NOT INITIALIZED)          }
function msgbank.insertm;
var
	b:pmbox;
begin
	lastbox:=objbank.insert(nctl,tname,'BMS',sizeof(msgbox));
  b := lastbox;
  b^.init(st,x2,y2);
  b^.copyb(defaultbox);
  b^.move(x2,y2,absboxmove);
  insertm:=lastbox;
end;

procedure msgbank.setfont;
var
	b:pmbox;
begin
	if wid <> 0 then begin
		list.getid(wid);
    lastbox := selected^.obj;
    b := lastbox;
    b^.setfont(fn,fs);
  end else begin
  	list.getid(1);
    lastbox := selected^.obj;
    b := lastbox;
    if selected^.tpe = 'BMS' then b^.setfont(fn,fs);
    while selected^.next <> nil do begin
      lastbox := selected^.obj;
 	    b := lastbox;
	    if selected^.tpe = 'BMS' then b^.setfont(fn,fs);
    	selected:= selected^.next;
    end;
  end;
end;

procedure msgbank.chngmsg;
var
	b:pmbox;
begin
	if wid <> 0 then begin
		list.getid(wid);
    lastbox := selected^.obj;
    b := lastbox;
    b^.chngmsg(nmsg);
  end;
end;

function msgbank.getmsg;
var
	st : string;
  b:pmbox;
begin
	if wid <> 0 then begin
		list.getid(wid);
    lastbox := selected^.obj;
    b := lastbox;
    b^.getmsg(st);
    getmsg := st;
  end;
end;

destructor msgbank.bye;
begin
	inherited bye;
end;

{*******************************************************}
{*******************************************************}
{*******************************************************}
constructor inputbank.init;
begin
	inherited init(name);
  list.tpe := TinputBox;
end;

function inputbank.inserti;
var
	b:pibox;
begin
	lastbox:=objbank.insert(nctl,tname,'BIN',sizeof(inputbox));
  b := lastbox;
  b^.init(st,'',x2,y2);
  b^.copyb(defaultbox);
  b^.move(x2,y2,absboxmove);
  inserti:=lastbox;
end;

procedure inputbank.setvalue;
var
	b:pibox;
  p:pobjlist;
begin
	p := list.getid(WID);
  b := pibox(p^.obj);
  with b^ do begin
  	firststr := nvlu;
    secondstr := '';
    selection := '';
    fcs := length(nvlu);
    scs := fcs;
  end;
end;

function inputbank.get;
var
	b:pibox;
  p:pobjlist;
begin
	p := list.getid(WID);
  b := pibox(p^.obj);
	get := b^.get;
end;

procedure inputbank.setallselection;
var
	b:pibox;
  p:pobjlist;
begin
	p := list.getid(WID);
  b := pibox(p^.obj);
  with b^ do begin
  	setallselection;
  end;
end;

procedure inputbank.enable;
var
	b:pibox;
  p:pobjlist;
begin
	p := list.getid(WID);
  b := pibox(p^.obj);
  with b^ do begin
  	setfocus(toenable);
  end;
end;

procedure inputbank.sendkey;
var
	b:pibox;
  p:pobjlist;
begin
  if not readyforinput then exit;
	p := list.getid(enabled);
  b := pibox(p^.obj);
  with b^ do begin
    sendkey(kb);
  end;
end;

destructor inputbank.bye;
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