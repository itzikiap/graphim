unit Bglobal;
{ global definitions for the builder }
interface
uses app,proc,event,bmnudef,bxlist,bxlbox,boxes,general,bmenu;

type
	boxform=object
	  form:inputbank;
    constructor init;
    function getIsin(x1,y1:integer):integer;
		procedure add(name:string8);
		function del(WID:word):boolean;
{		procedure Zfore(wid:word); { "Bring to front" }
{		procedure Zback(wid:word); { "Bring to back" }
    destructor bye;
  end;

var
  MainForm:BoxForm;
  MMain:menubar;
  Msub:Pmenubar;


procedure initialize;

implementation
procedure initialize;
var
	b1:border;

begin
	mainform.init;
  ib(b1,0,0,swidth,shight);
  initmenu2(@Mmain,0,0,1,0,DefMainMenu,'MAIN',B1);
end;

constructor boxform.init;
begin
  form.init('Default');
	with form.defaultbox^ do begin
 		init(swidth div 2,shight div 2,20,20,on);
   	setmcolor(15,7);
    set3D(on,off);
 	end;
end;

procedure Boxform.add;
begin
  with mainform.form do begin
    if name='BOX' then
			insert(swidth div 2 -10,shight div 2 -10,swidth div 2 +10,shight div 2 +10,on,name,list.nextID)
    else if name='MSGBOX' then
			insertm('(0)',swidth div 2,shight div 2,name,list.nextID)
    else if name='INPUTBOX' then
    	inserti('shmulik',swidth div 2,shight div 2,name,list.nextID);
  end;
{  mainform.form.lastbox^.display;}
end;

function boxform.del(Wid:word):boolean;
begin
  del := false;
  if mainform.form.delete(Wid) <> 0 then del := true;
end;

function boxform.getisin;
begin
	getisin := form.getisinctl(x1,y1);
end;

destructor boxform.bye;
begin
  form.bye;
end;


end.
