unit menugr;
{ MENUES }
interface
uses mousebx,boxes,general,drivers,set_gr;

var
	description:msgbox; { description line }

const
	miAutoPlaceX = $0001; { put next item to the right of this item }
	miAutoPlaceY = $0002; { put next item under this item }
	miXdist1     = $0004; { how far away? }
	miXdist2     = $0008;
	miYdist1     = $0010;
	miYdist2     = $0020;
	miMoveX      = $0040;
	miMoveY      = $0080;
	miSameSize   = $0100; { make all of them the same size }
  miWrap       = $0200; { menu item out of screen will get into it }

type
	pmenuitem=^menuitem;
	menuitem=object(msgbox)
		ID:word; { identipicetion number }
		selected:boolean; { is selected }
		options:word;
		ctl:byte; { control number }
		Help:word; { the help }
		next:PmenuItem; { the next menu item }
{		private}
		desc:string; { help string }
		AutoPlaceX:boolean;
		AutoPlaceY:boolean;
		Xdist1    :boolean;
		Xdist2    :boolean;
		Ydist1    :boolean;
		Ydist2    :boolean;
		MoveX     :boolean;
		MoveY     :boolean;
		SameSize  :boolean;
    Wrap      :boolean;
		public
		constructor init(st:string;x,y:integer;ctrl,helpID:byte;st2:string;IDnum:byte); { initialize }
		procedure chngmnu(st:string;ctrl:byte;st2:string); { change menu item, dont need to enter x and y }
		procedure displayall; { display all items }
		procedure hide; { hide all chaind items }
		procedure move(what:byte;dx,dy:integer;isrelative:boolean); { move selected menu item }
		procedure findbiggest(var wid,hit:integer;changesize:boolean); { fine the bigest box and change it size }
		function whatselected:byte; { the ID of the selected menu item }
		function getisin(x,y:integer):byte;	{ the mouse is inside what menu item ID ? }
		function getctl:byte; { give the control number }
		function gethelp:byte;
    function gettitle:string;
		procedure insert(title,helpst:string;ctrl,helpID:byte;x,y:integer); { insert menu in last place }
		procedure option(newopt:integer); { insert option }
		function doselect(selectID:byte):byte; { retuns the CTL }
		function select:byte; { return the CTL - used for chain select }
		procedure unselect;
		function isselect:boolean;
		procedure free; { free up all items from memory }
		destructor bye; virtual;
	end;

	hordir=(left,right,centerh);
	verdir=(up,down,centerv);
	Menu = object
		firstitem:menuitem;
		private
		horjustify:hordir; { the place of the entire menu relative }
		verjustify:verdir; { to the INIT point }
		operate:boolean;
		public
		NumOfItems : byte;
		HideAfter : boolean;
		x1,y1,x2,y2:integer; { the space of the entire menu }
		cx,cy:integer; { the center }
		constructor init(nx,ny:integer;hj:hordir;vj:verdir;noption:integer); { initialize }
		procedure insert(st:string;ctl:byte); { inset a menu item }
		procedure setfont(nfont,nsize:byte); {set the font }
		procedure fittoregion(nx1,nx2,ny1,ny2:integer); { fit the menu to specified region }
		procedure getready; { preper the menu for first use }
		function domenu:byte; { do the menu - return the CTRL }
		destructor bye;
	end;

	{ this is a main menu }
	{ it display title and everiy menu item in the center of the screen}
	menudisplay=object
		private
		title:msgbox; { the title }
		numofitems:byte; { how meny items (max_menu_item) }
		selected:byte; { what item is selected }
		displayed:boolean;
		item:Pmenuitem; { all items }
		ctl:byte; { selected control }
		public
		procedure init(menutitle:string); { initialize the menu items according to	MenuTitle,	MenuItemTitle,	MenuHelp,	and MenuCtl }
		procedure reinit(st:string); { same as init but without memory handaling }
		procedure insert(st,helpst:string;ctrl,helpId:byte); { insert item to menu }
		procedure makesamesize; { makes all menuitems in the same size }
		procedure hide; { hide all menues }
		procedure bye; { hide and release all memory }
		function getctl:byte; { what ctl is selected }
		function gethelp:byte; { give the help number }
		procedure domenu; { do the interactive menu until hit ENTER or ESC or F1-F10}
		procedure dtitle; { draw ther title }
		procedure select(index:byte); { select menu item }
		procedure tab(incr:shortint); { select next menu }
		function whatselected:byte; { what selected ? }
	end;

implementation
{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
{*			 MENUITEM OBJECT PROCEDURES		 	    *}
{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
constructor menuitem.init;
{ initialize the menu item }
var
	i:integer;
begin
	msgbox.init(st,x,y);
	setfont(MenuFont,MenuFontSize);
	inc(width,4);
	inc(hight,1);
	desc:=st2;
	ctl:=ctrl;
	help := HelpID;
	ID:=IDnum;
	case menu3Deffect of
		none : begin
			set3D(off,off);
			mode3D := boxes.none;
		end;
		small : begin
			set3D(on,off);
			mode3D := boxes.small;
		end;
		big : begin
			set3D(on,off);
			mode3D := boxes.big;
		end;
		double : begin
			set3D(on,off);
			mode3D := boxes.double;
		end;
		inside : begin
			set3D(on,off);
			mode3D := boxes.inside;
		end;
  	large : begin
			set3D(on,off);
			mode3D := boxes.large;
		end;
  	l_inside : begin
			set3D(on,off);
			mode3D := boxes.l_inside;
		end;
  	l_double : begin
			set3D(on,off);
			mode3D := boxes.l_double;
		end;
	end;
	setbox(on,on);
	selected:=false;
	next := nil;
	if ID = 0 then setmcolor(menutitlecolor,backgroundcolor,menutitleback) else
	setmcolor(UnselectedFore,BackGroundColor,UnselectedBack);
	option(miAutoPlaceY+miWrap);
end;

procedure menuitem.insert;
{           insert a menu item         }
var
	newx,newy:integer;
begin
	if next <> nil then next^.insert(title,helpst,ctrl,helpID,x,y)
	else begin
		new(next);
		newx := x;
		newy := y;
		if newx = 0 then newx := cx;
		if newy = 0 then newy := cy;
		next^.init(title,0,0,ctrl,helpID,helpst,ID+1);
		next^.option(options);
		next^.setfont(fontname,fontsize);
		if autoplaceX then begin
			newx := x2+next^.txtwidth div 2;
      if Wrap then
      	if x2+next^.txtwidth >= swidth then begin
					newX := next^.txtwidth div 2+5;
          newY := y2+next^.txthight div 2 +1;
        end;
			if Xdist1 then inc(newX,4);
			if Xdist2 then inc(newX,14);
		end;
		if autoplaceY then begin
			newy := y2+next^.txthight div 2 +1;
      if Wrap then
      	if y2+next^.txthight >= shight then begin
					newX := x2+next^.txtwidth div 2+5;
          newY := next^.txthight div 2 +1;
        end;
			if Ydist1 then inc(newY,4);
			if Ydist2 then inc(newY,14);
		end;
    next^.move(next^.ID,newx,newy,absboxmove);
{		IF SameSize and (id > 0) then next^.chngdim(0,0,width,hight,centerbox);}
  	next^.setjustify(justify);
	end;
end;

procedure menuitem.findbiggest;
{ find the biggest box }
begin
	if wid < width then wid := width;
	if hit < hight then hit := hight;
	if next <> nil then next^.findbiggest(wid,hit,changesize);
	if changesize then begin
		samesize := true;
		if ((options and miSameSize) 	  <> miSameSize) then options := options+miSameSize;
		chngdim(0,0,wid,hit,centerbox);
  	setjustify(justify);
	end;
end;

procedure menuitem.move;
{ move selected item }
{ WHAT = 0 to move all items }
begin
	if what = 0 then begin
		if next<>nil then next^.move(what,dx,dy,isrelative);
		if ID <> 0 then msgbox.move(dx,dy,isrelative);
	end else
		if ID <> what then begin
			if next<>nil then next^.move(what,dx,dy,isrelative);
		end else msgbox.move(dx,dy,isrelative);
end;

function menuitem.whatselected;
begin
	if next <> nil then begin
		if selected then whatselected := ID
		else whatselected := next^.whatselected;
	end else begin
		if selected then whatselected := ID
		else whatselected := 0;
	end;
end;

function menuitem.getisin;
begin
	if next <> nil then begin
		if isin(x,y) then getisin := ID
		else getisin := next^.getisin(x,y);
	end else begin
		if isin(x,y) then getisin := ID
		else getisin := 0;
	end;
end;

function menuitem.doselect;
begin
	if selected then unselect; { if this item is selected }
	if next<>nil then doselect:=next^.doselect(selectID); { continue to search - return CTL }
	if ID = selectID then doselect := select; { we want to select this item }
end;

function menuitem.gethelp;
begin
	if not selected then begin
		if next <> nil then gethelp := next^.gethelp
		else gethelp := 0;
	end else gethelp := help;
end;

function menuitem.gettitle;
begin
	if not selected then begin
		if next <> nil then gettitle := next^.gettitle
		else gettitle := '';
	end else gettitle := msg;
end;

procedure menuitem.chngmnu;
{ change the menu item }
begin
	msgbox.chngmsg(st);
	desc := st2;
	ctl := ctrl;
	selected:=false;
	setmcolor(UnselectedFore,BackGroundColor,UnselectedBack);
end;

procedure menuitem.displayall;
begin
	if ID <> 0 then display;
	if (next <> nil) then next^.displayall; { if first then display all chain }
end;

procedure menuitem.hide;
begin
	erase;
	if next <> nil then next^.hide;
end;

function menuitem.getctl;
{ get the control }
begin
	getctl:=ctl;
end;

function menuitem.select;
{ select this item }
begin
	selected:=true;
	set3D(on,on);
	setmcolor(SelectedFore,BackGroundColor,SelectedBack);
	description.chngmsg(desc);
	select:=ctl;
end;

procedure menuitem.unselect;
{ unselect this item }
begin
	selected:=false;
	setmcolor(UnselectedFore,BackGroundColor,UnselectedBack);
	set3D(on,off);
end;

procedure menuitem.option;
{ ------¯> EFFECTS ONLY THE LAST MENUITEM }
begin
	if next <> nil then next^.option(newopt)
	else begin
		options := newopt;
		AutoPlaceX 	:= ((options and miAutoPlaceX) 	= miAutoPlaceX);
		AutoPlaceY 	:= ((options and miAutoPlaceY) 	= miAutoPlaceY);
		Xdist1 			:= ((options and miXdist1) 			= miXdist1);
		Xdist2 			:= ((options and miXdist2) 			= miXdist2);
		Ydist1 			:= ((options and miYdist1) 			= miYdist1);
		Ydist2 			:= ((options and miYdist2) 			= miYdist2);
		MoveX 			:= ((options and miMoveX) 			= miMoveX);
		MoveY 			:= ((options and miMoveY) 			= miMoveY);
		SameSize	  := ((options and miSameSize) 	  = miSameSize);
    Wrap        := ((options and miWrap) 	      = miWrap);
	end;
end;

function menuitem.isselect;
{ is this item selected ? }
begin
	isselect:=selected;
end;

procedure menuitem.free;
begin
	msgbox.erase;
	if next<>nil then begin
		next^.free;
		next^.bye;
		dispose(next);
		next := nil;
	end;
end;

destructor menuitem.bye;
begin
	msgbox.bye;
	if next <> nil then begin
		next^.bye;
		dispose(next);
		next := nil;
	end;
end;
{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
{*        	MENU OBJECT PROCEDURES	         *}
{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
constructor menu.init;
begin
	firstitem.init('',nx,ny,0,0,'',0);
	NumOfItems :=0;
  horjustify := hj;
  verjustify := vj;
  firstitem.option(noption);
	HideAfter := false;
	operate := false;
end;

procedure menu.insert;
begin
	if not operate then begin
		firstitem.insert(st,'',ctl,0,0,0);
		inc(NumOfItems);
	end;
end;

procedure menu.setfont;
begin
	firstitem.setfont(nfont,nsize);
end;

procedure menu.fittoregion;
{ fit menu to given region }
begin

end;

procedure menu.getready;
var wid,hit:integer;
	dx,dy:integer;
	fx,fy:integer;
begin
	hit := 0;
	wid := 0;
	if firstitem.samesize then firstitem.findbiggest(wid,hit,on);
	hit := hit * NumOfItems;
	fx := firstitem.cx;
	fy := firstitem.cy;
	x1 := firstitem.x1;
	y1 := firstitem.y1;
	x2 := x1 + wid;
	y2 := y1 + hit;
	cx := x1+(wid div 2);
	cy := y1+(hit div 2);
	case horjustify of
		left   :	dx := fx-x1;
		right  :	dx := fx+x2;
		centerh:	dx := fx-cx;
	end;
	case verjustify of
		up     :	dy := fy-y1;
		down   :	dy := fy+y2;
		centerv:	dy := fy-cy;
	end;
	firstitem.move(0,dx,dy,relboxmove);
	operate := true;
end;

function menu.domenu;
{ do the interactive menu until pressing ENTER or ESC }
var i,i1:integer;
	c,e:boolean;
{	dx,ddx:integer;}
	selected:integer;
	ctl :integer;
	whatselected :integer;

procedure select(index:integer);
{ select menu item }
begin
	ctl:=firstitem.doselect(index);
	whatselected := index;
end;

procedure tab(incr:integer);
{ select next menu item }
var i:integer;
begin
	i:=whatselected+incr;
	if i<=0 then i:=numofitems;
	if i>=numofitems+1 then i:=1;
	select(i);
end;

begin
	c:=false;
	e:=false;
	firstitem.displayall;
	if mouseok then mouse.display;
	repeat
		{ mouse }
	with mouse do begin
		update;
		if changed then begin
			if not displayed then display;
			i1 := firstitem.getisin(cx,cy);
			if i1 <> 0 then begin
				setmousetype(arrow);
				if MouseAutoSelect and (whatselected <> i1) then begin
					erase;
					select(i1);
					display;
        end;
				if pressed[1] then begin
					if whatselected <> i1 then begin
						erase;
						select(i1);
						display;
						e := true;
						c := true;
						repeat update; until not buttompressed[1];
					end	else begin
						e := true;
						c := true;
					end;
				end;
				if pressed[2] then e := true;
			end else begin
				setmousetype(wait);
				if pressed[1] or pressed[2] or pressed[3] then e := true;
			end;
		end;
	end;
		{ keyboard }
		getkeyevent(ev);
		if ev.what <> evNothing then begin
			mouse.erase;
			if ev.what = evkeydown then begin
				case ev.keycode of
					kbright,kbdown,kbtab:begin
						tab(1);
					end;
					kbleft,kbup,kbshifttab:begin
						tab(-1);
					end;
					kbenter:begin
						e:=true;
						c:=true;
					end;
					kbesc:begin
						ctl:=doexit;
						e:=true;
					end;
				end;
			end;
		end;
	until e;
	if not c then ctl := 0;
	mouse.erase;
	domenu := ctl;
	if hideafter then firstitem.hide;
end;

destructor menu.bye;
begin
	firstitem.free;
	firstitem.bye;
end;

{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
{*    	MENUDISPLAY OBJECT PROCEDURES	       *}
{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
procedure menudisplay.init;
{ initialize the menu }
var i:byte;
begin
	item := nil;
	with title do begin
		init(MenuTitle,swidth div 2,30);
		setfont(MenuFont,4);
		setmcolor(5,BackgroundColor,2);
		set3D(on,off);
		setbox(on,on);
	end;
	with description do begin
		init('',swidth div 2,shight div 2);
		autosize := off;
		set3D(on,off);
		setbox(on,on);
		setmcolor (0,BackGroundColor,12);
		setfont(MenuFont,1);
		chngDim (1,shight-txthight-5,swidth-1,shight-1,cornerbox);
	end;
	numofitems:=0;
	selected := 0;
	if item = nil then new(item);
	item^.init(menutitle,swidth div 2,title.y2*2,0,0,menutitle,0);
	item^.option(miautoplaceY);
end;


function menudisplay.gethelp;
begin
	gethelp := item^.gethelp;
end;

procedure menudisplay.reinit;
{ initialize the menu without the backgroundsave }
var i:byte;
begin
	title.chngmsg(st);
	title.setmcolor(5,BackGroundColor,2);
	numofitems:=0;
	selected:=1;
	item^.free;
{	item^.chngmsg(st);}
end;

procedure menudisplay.select;
{ select menu item }
begin
	ctl:=item^.doselect(index);
	selected := index;
end;

procedure menudisplay.tab;
{ select next menu item }
var i:integer;
begin
	i:=selected+incr;
	if i=0 then i:=numofitems;
	if i=numofitems+1 then i:=1;
	select(i);
end;

procedure menudisplay.dtitle;
{ draw hte title }
begin
	title.display;
end;

function menudisplay.whatselected;
{ what menu is selected }
begin
	whatselected:=selected;
end;

function menudisplay.getctl;
{ what control is has }
begin
	getctl:=ctl;
end;

procedure menudisplay.makesamesize;
{ make all menuitems in the same size }
var
	hit,wid:integer;
begin
	hit := 0;
	wid := 0;
	item^.findbiggest(wid,hit,on);
end;

procedure menudisplay.hide;
{ hid all menu items }
var i:byte;
begin
	mouse.erase;
	item^.hide;
	description.erase;
	title.erase;
end;

procedure menudisplay.insert;
begin
	inc(numofitems);
	item^.insert(st,helpst,ctrl,helpID,0,0);
end;

procedure menudisplay.domenu;
{ do the interactive menu until pressing ENTER or ESC }
var i,i1:integer;
	c,e:boolean;
	dx,ddx:integer;
begin
	c:=true;
	e:=false;
	dtitle;
	description.display;
	item^.displayall;
	mouse.display;
  if ctl=100 then select(whatselected);
	repeat
		c:=false;
		{ mouse }
		with mouse do begin
			update;
			if changed then begin
				if not displayed then display;
				i1 := item^.getisin(cx,cy);
				if i1 <> 0 then begin
					setmousetype(arrow);
					if MouseAutoSelect then begin
						if whatselected <> i1 then begin
							erase;
							select(i1);
							display;
						end;
					end;
					if pressed[1] then begin
						if whatselected <> i1 then begin
							erase;
							select(i1);
							display;
						end	else e := true;
					end;
					if pressed[2] then begin
						if whatselected <> i1 then begin
							erase;
							select(i1);
							display;
						end;
						e := true;
						ctl := showhelp;
					end;
				end else setmousetype(wait);
			end;
		end;
		{ keyboard }
		getkeyevent(ev);
		if ev.what <> evNothing then begin
			mouse.erase;
			c:=true;
			if ev.what = evkeydown then begin
				case ev.keycode of
					kbleft,kbdown,kbtab:begin
						tab(1);
					end;
					kbright,kbup,kbshifttab:begin
						tab(-1);
					end;
					kbenter:begin
						ctl := getctl;
						e:=true;
					end;
					kbesc:begin
						ctl := doesc;
						e:=true;
					end;
					kbF1:begin
						ctl:=showhelp;
						e:=true;
					end;
					else c:=false;
				end;
			end;
		end;
	until e;
	mouse.erase;
end;

procedure menudisplay.bye;
{ hide and release memory }
var i:integer;
begin
	item^.bye;
	description.bye;
	title.bye;
end;

{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
{*						GENERAL PROCEDURES		     	   *}
{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
end.