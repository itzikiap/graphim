unit Bproc;
{ Procedures for the builder }
interface
uses app,proc,general,boxes,bxlist,bxlbox,bglobal,bmnudef,bmenu,mousebx,bxdialog,bdlg;

var
	bapp:application;

function Phandleevent(ID:word):word; far;
function Phandlebox(ID:word):word; far;
{function PFile(ID:word):word; far;}

function Bmredraw(ID:word):word; far;
{*******}
function CMain(ID:word):word; far;
function CForm(ID:word):word; far;
function Csubmenu(ID:word):word; far;

implementation
{*}function Cmain;
  var i:byte;
begin
  if mouse.buttompressed[1] then i := 1 else i := 2;
	Cmain := MMain.cycle(i);
end;

{*}function Cform;
var
	m : integer;
  b:pbox;
begin
  if id = Bform then begin
    m := 0;
	  if mouse.pressed[3] or mouse.pressed[1] or mouse.pressed[2] then
			m := mainform.getisin(mouse.x,mouse.y);
  	if m <> 0 then with Mainform.form do begin
  		cform := 0;
      bapp.vars.vsetr('LastId',m);
			if mouse.pressed[1] then cform := cmMove;
    	if mouse.pressed[2] then cform := cmSize;
      if mouse.pressed[3] then cform := txtoffset;
		end;
  end else begin
    with mouse do begin
	 	 	erase;
    	with mainform.form do
			case ID of
  			cmMove    : box(lastbox^).move(xmove,ymove,relboxmove);
				cmSize    : msize(selected^.ID,xmove,ymove,on);
        txtoffset : msgbox(lastbox^).settextoffset(x-box(lastbox^).cx,y-box(lastbox^).cy);
  		end;
  		display;
			if buttompressed[1] or buttompressed[2] or buttompressed[3] then cform := id
  		else cform:= frmRedraw;
    end;
	end;
end;

(*}function Cstatusline;
var i:byte;
begin
  with mouse do begin
  end;
  if mouse.buttompressed[1] then i := 1 else i := 2;
  CStatusline := MStatus.cycle(i);
end;  *)

{*}function Csubmenu;
var b:border;
	ct : word;
function ison(value:boolean):string;
{ returns * if on }
begin
	if value then ison := '*' else ison := '';
end;
begin
  ib(b,0,0,swidth,shight);
  case ID of
		mnuFileMenu     : Msub:=initmenu(mouse.x,mouse.y,0,1,defFileMenu,'file',b);
		mnupropertyMenu : Msub:=initmenu(mouse.x,mouse.y,0,1,defPropMenu,'prop',b);
		mnuaddMenu      : Msub:=initmenu(mouse.x,mouse.y,0,1,defAddMenu ,'add',b);
		mnuPr3D         : Msub:=initmenu(mouse.x,mouse.y,0,1,def3DMenu  ,'3D',b);
    mnuPrColor      : Msub:=initmenu(mouse.x,mouse.y,0,1,defClrMenu ,'Color',b);
  end;
  msub^.onclick := false;
  msub^.noctl := 456;
  mouse.erase;
  Msub^.start;
  mouse.display;
  msub^.exclusive := false;
  ct := 0;
	repeat
  	mouse.update;
    if mouse.buttompressed[1] then ct := msub^.cycle(1)
    else ct := msub^.cycle(2);
  until (ct = msub^.noctl) or (ct <> 0);
  Csubmenu := ct;{Msub^.exerunit;}
  mouse.erase;
  Msub^.bye;
  dispose(Msub);
  mouse.display;
end;

{*}function PHandleBox;
{ propertyes }
var
	s:string;
  i:byte;
  vf,vs:byte;

begin
  phandlebox := frmredraw;
  with msgbox(mainform.form.lastbox^) do
		case id of
   		d3dnone..d3dnone+8    : set3Dmode(the3dmodes(id-d3dnone));
      d3dinv                : set3d(on,not is3Dinverse);
   		clrblack..clrblack+7  : setmcolor(0,0,id-clrblack);
   		clrbright             : if bkcolor>7 then setmcolor(0,0,bkcolor-8) else setmcolor(0,0,bkcolor+8);
      cmprmsg               : begin
      													getstr(swidth div 2,shight div 2,'',msg);
      												 	chngmsg(msg);
      												end;
      cmprfont              : begin
      													vf := fontname;
                                vs := fontsize;
                                chngfont(vf,vs);
                                setfont(vf,vs);
      												end;
		end;
end;



{*}function PHandleEvent;
begin
  case id of
  	cmadmsg   : mainform.add('MSGBOX');
  	cmadbox   : mainform.add('BOX');
  	cmadinput : mainform.add('INPUTBOX');
    cmdel     : mainform.del(byte(bapp.vars.pget('LastId','VBT')^));
  end;
  bapp.vars.vsetr('LastId',mainform.form.objects);
	PhandleEvent := PrRedraw;
end;

{*function Pfile;
begin
	case cm}

{*}function BmRedraw;
begin
  mouse.erase;
	if id = prredraw then begin
		eraseScreen;
  	MMain.display(true);
  end;
	mainform.form.display(0);
	mouse.display;
  bmredraw:=0;
end;

end.