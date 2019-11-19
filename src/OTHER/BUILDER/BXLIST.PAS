unit bxlist;
{ provide an object that can contain and access  }
{  a list of box objects with all of its types.  }
{  can be dynamicaly changed.                    }
interface
uses general,boxes;

const
	maxobj:byte=75;

type
  pborder = ^border;
	border=record
  	x1,y1,x2,y2:integer;
    clip:boolean;
  end;



	PObjList=^ObjList;
  ObjList=object
		ID:byte;     { identipicetion number }
		ctl:word;     { control number }
		Next:PObjList; { the next menu item }
		Prev:PObjList; { the Previous menu item }
		Obj:pointer;
    size:word;
  	initialized:boolean;
    IsBoxType:boolean; { If true then the program will know to apply box proprties }
    name:string8; { name of the object }
    tpe:string3;  { Type of object }
  	selected:boolean; { is selected }

		public
		constructor init(tname:string8;ttpe:string3); { initialize }
		function insert(nctl:word;tname:string8;ttpe:string3;msize:word):pointer; { insert in last place }
		function getid(Wid:byte):pobjlist; { give the object of wanted ID (0=last) }
		function getisin(wx,wy:word):pobjlist; { Give the box in current position }
    function nextID:word; { give the next ID to be created. 0 if cant }
    function delete(Wid:word):byte; { delete a specific item - return num of obj}
		procedure free; { free up all items from memory }
		destructor bye; virtual;

	end;
  Pobjbank = ^objbank;
	objbank=object
    list:objlist;
    objects:byte;
    selected:Pobjlist;
    selectfind:boolean; { Does find operation alsow select the object? }
    selectnew:boolean; { Does insert operation select the object? }
    constructor init(name:string8);
    function insert(nctl:word;tname:string8;ttpe:string3;msize:word):pointer;
    function delete(wid:byte):byte; { 0=all }
    function select(wid:byte):byte; { return CTL }
    function selectprev:byte; { return ctl }
    function selectnext:byte; { return ctl }
    procedure unselect;
    Function findbyname(What:string8):Pobjlist;
    Function findbytype(what:string3;N:byte):Pobjlist; { N-th item of that type (0=1st) N bigger then count then get last}
    Function counttype(what:string3):byte;

(*    { BOX MODE PROCEDUERS }
		procedure move(what:byte;dx,dy:integer;isrelative:boolean); { move selected menu item }
    procedure chngmsg(What:byte;newmsg:string);
		procedure findbiggest(var wid,hit:integer;changesize:boolean); { fine the bigest box and change it size }
    Function findbyisin(wx,wy:word):Pobjlist;
    function insertMSG(x1,y1:integer;msg:string;nctl:byte;tname:string8;ttpe:string3):pointer;
    function insertBOX(x1,y1,x2,y2:integer;iscenter:boolean;nctl:byte;tname:string8;ttpe:string3):pointer;
    function insertINP(x1,y1:integer;prm:string;iscenter:boolean;nctl:byte;tname:string8;ttpe:string3):pointer;
    function insertMNU(x1,y1:integer;prm:string;iscenter:boolean;nctl:byte;tname:string8;ttpe:string3):pointer; *)
    destructor bye;
  end;


implementation
{---------------------------------------------}
{               PlistObj                      }
{---------------------------------------------}

constructor ObjList.init;
{      INIT      }
{ initialize the first object of a chain }
begin
  { The given objec should already be initialized }
	obj:=nil;
  initialized := true;
  ID := 0;
  name := tname;
  tpe := ttpe;
  isboxtype:=(tpe[1] = 'B');
{  selected := false;}
  next := nil;
  prev := nil;
end;

function ObjList.insert;
{     INSERT      }
{ insert an object in the last place                }
{ THIS PROCEDURE GIVE THE MEMORY TO THE OBJECT!!!!  }
{ [-] PREV pointer is set only in in the 3RD object }
begin
  if (ID=maxobj) or (maxavail < sizeof(objlist)+msize) then begin
    insert := nil;
		exit;
  end;
	if next <> nil then insert := next^.insert(nctl,tname,ttpe,size)
  else begin
  	new(next,init(tname,ttpe));
    getmem(next^.obj,msize);
    size := msize;
		insert := next^.obj;
    next^.ctl := nctl;
    next^.ID := ID+1;
    if prev <> nil then next^.prev := prev^.next; { assign the prev value }
{		insert := ID+1;}
  end;
end;

function objlist.getisin;
{        GETISIN         }
{ Get the box that lyes under the coordinates }
var b:^box;
	me:pobjlist;
	e:boolean;
begin
  getisin := nil;
  e := on;
  if next <> nil then me := next else e := false;
  while e do begin
    if me^.isboxtype then begin
			b:=me^.obj;
			if b^.isin(wx,wy) then begin
				e:=false;
				getisin := me;
    	end else begin
    		if me^.next=nil then e:=off	else me := me^.next;
    	end;
    end else begin
    	if me^.next=nil then e:=off	else me := me^.next;
    end;
  end;
end;

function objlist.getid;
{        GETID       }
{ give you the object number that you want }
begin
  getid := nil;
  if next <> nil then
		if (wid=0) or (wid > id+1) then begin
  	  getid := next^.getid(wid);
  	end else if wid=id+1 then getid := next;
  if wid=0 then if next^.next=nil then
		getid := next; { get the last object }
end;

function objlist.nextID;
{        NEXTID         }
{ Give the next ID to be created.            }
{ return 0 if cant.                          }
{ actually simulate insert without inserting }
begin
  if ID=maxobj then begin
    nextID := 0;
		exit;
  end;
	if next <> nil then nextID := next^.nextID
  else begin
		nextID := ID+1;
  end;
end;

function objlist.delete;
{        DELETE      }
{ delete a specific object with the given ID }
var
	me:Pobjlist;
begin
  if next <> nil then begin
		if wid > id+1 then delete := next^.delete(wid)
		else if wid=id+1 then begin
     	me := next;
      if next^.next = nil then next := nil else next := next^.next;
      me^.next := nil;
      freemem(me^.obj,size);
      me^.obj := nil;
      dispose(me,bye);
      if next <> nil then delete := next^.nextID else delete := id;
    end else if wid=0 then begin
     	ID := ID-1;
      delete := next^.delete(0);
    end;
  end else begin
		if wid = 0 then id := id-1;
		delete := ID;
  end;
end;

procedure objlist.free;
{-----------------------}
{          FREE         }
{  Empty the list       }
{-----------------------}
var
	me:Pobjlist;
	b:^box;
begin
  while next <> nil do begin
   	me := next;
    next := next^.next;
    if me^.isboxtype then begin
      b := me^.obj;
			b^.bye;
    end;
    freemem(me^.obj,size);
    me^.obj := nil;
    dispose(me,bye);
  end;
end;

destructor objlist.bye;
{---------------------------}
{           BYE             }
{ DOES NOT ERASE LIST !!!!! }
{ MUST USE 'FREE' PROCEDURE }
{---------------------------}
var
	b:^box;
begin
  next := nil;
  prev := nil;
  if obj <> nil then begin
  	if isboxtype then begin
			b := obj;
      b^.bye;
		end;
		if obj <> nil then freemem(obj,size);
  end;
  initialized := false;
  id := 0;
end;

(********************************************************)
(*                  OBJ BANK                            *)
(********************************************************)
constructor objbank.init;
{      INIT     }
begin
  selectfind := true;
  selectnew  := true;

  objects := 0;
  selected := nil;
  list.init(name,'');
end;

function objbank.insert;
{           INSERT         }
{ insert new object        }
var
	t:pointer;
  p:pobjlist;
begin
	t := list.insert(nctl,tname,ttpe,msize);
  insert := nil;
  if t <> nil then begin
    p:= list.getid(0);
		objects := p^.id;
    if selectnew then selected := @p;
  	insert := t;
  end;
  if objects=1 then list.next^.prev := @list;
end;

function objbank.delete;
{        DELETE       }
{ Delete selected object. wid=0 - delete all!!! }
begin
  if wid <> 0 then begin
    if (selected <> nil) and (selected^.id = wid) then selected := nil;
		objects:=list.delete(wid);
  	delete:=objects;
  end else begin
    selected := nil;
  	list.free;
    objects := 0;
  end;
end;

function objbank.select;
{          SELECT        }
{ Return the CTL of selected OBJ }
begin
	selected := list.getid(wid);
  if selected <> nil then begin
  	select := selected^.ctl;
  end else select := 0;
end;

function objbank.selectnext;
{         SELECT NEXT       }
begin
  selectnext :=0;
	if selected<>nil then
  	if selected^.next <> nil then begin
			selected := selected^.next;
      selectnext := selected^.ctl;
    end;
end;
function objbank.selectprev;
{         SELECT PREV       }
begin
  selectprev :=0;
	if selected<>nil then
  	if selected^.prev <> nil then begin
			selected := selected^.prev;
      selectprev := selected^.ctl;
    end;
end;


procedure objbank.unselect;
{          UNSELECT         }
begin
	selected := nil;
end;

function objbank.findbyname;
{           FIND BY NAME           }
{ Find the object of given name    }
var
	p,me:pobjlist;
	e:boolean;
begin
	findbyname:=nil;
  if selected^.name = what then begin
		if selected <> nil then findbyname := selected;
    exit;
  end;
  e := on;
  p := nil;
  me := @list;
 	if me^.next=nil then e:=off	else me := me^.next;
  while e do begin
    if me^.name=what then begin
    	p := me;
      e := off;
    end else begin
    	if me^.next=nil then e:=off	else me := me^.next;
    end;
  end;
  findbyname := p;
  if selectfind then selected := p;
end;

function objbank.findbytype;
{           FIND BY TYPE           }
{ Find object with given type      }
{ N= the N-th object of that type  }
{ if N=0 then the last object      }
{ if N>number of objectas that type}
{				      then give last object}
var
	p,me:pobjlist;
	e:boolean;
  nth:byte;
begin
  e := on;
  p := nil;
  nth := 0;
  if selected^.tpe = what then begin
		p := selected;
    exit;
  end;
  me := @list;
 	if me^.next=nil then e:=off	else me := me^.next;
  while e do begin
    if me^.tpe=what then begin
    	p := me;
      inc(nth);
      if (n<>0) and not (n>nth) then e := off;
    end;
   	if me^.next=nil then e:=off	else me := me^.next;
  end;
  findbytype := p;
  if selectfind then selected := p;
end;

function objbank.counttype;
{           COUNT TYPE                }
{ Count howmany objects of given type }
var
	me:pobjlist;
	e:boolean;
  nth:byte;
begin
  e := on;
  nth := 0;
  me := @list;
 	if me^.next=nil then e:=off	else me := me^.next;
  while e do begin
    if me^.tpe=what then inc(nth);
   	if me^.next=nil then e:=off	else me := me^.next;
  end;
  counttype := nth;
end;


destructor objbank.bye;
{               BYE              }
begin
	list.free;
  list.bye;
  selected := nil;
end;

end.