unit exbox2;
{ Extended implementation of the exbox }
interface
uses general,graph,boxes,drivers;
const
	miAutoPlaceX = $0001;
	miAutoPlaceY = $0002;
	miXdist1     = $0004;
	miXdist2     = $0008;
	miYdist1     = $0010;
	miYdist2     = $0020;
	miMoveX      = $0040;
	miMoveY      = $0080;
	miSameSize   = $0100;

type
	Pmsgboxlist=^msgboxlist;
	msgboxlist=object(msgbox)
    IsMarked:boolean; { If true, do not dispose any object because the calling procedure marked the heap }
		ID:word; { identificetion number }
		options:word;
		next:Pmsgboxlist; { the next menu item }
		private
		AutoPlaceX:boolean;
		AutoPlaceY:boolean;
		Xdist1    :boolean;
		Xdist2    :boolean;
		Ydist1    :boolean;
		Ydist2    :boolean;
		MoveX     :boolean;
		MoveY     :boolean;
		SameSize  :boolean;
		public
		constructor init(st:string;x,y:integer;IDnum:byte); { initialize }
		procedure setboxoptions(bx3D,bx3dinv,bxdraw,bxnoframe,bxautosize:boolean); { work on last box }
		procedure setmcolor(tcolor,fcolor,bcolor,IDnum:byte);
		procedure getdims(var nx1,ny1,nx2,ny2:integer;iscenter:boolean;IDnum:byte);
		procedure findbiggest(var wid,hit:integer;changesize:boolean); { fine the bigest box and change it size }
		procedure chngdim(nx1,ny1,nx2,ny2:integer;iscenter:boolean;IDnum:integer);
		procedure chngmsg(st:string;IDnum:byte); { change massege }
		procedure displayall; { display all items }
		procedure hide; { hide all chaind items }
		function getisin(x,y:integer):byte; { the mouse is inside what msg box ID ? }
		function getlastID:byte; { give the last ID number }
		function insert(title:string;x,y:integer):boolean; { insert box in last place }
		procedure option(newopt:word); { insert option }
		procedure free; { free up all items from memory }
		destructor bye; virtual;
	end;

const
	MBLSize      = sizeof(msgboxlist);

implementation
{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
{*		 MSGBOXLIST OBJECT PROCEDURES	  	    *}
{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
constructor msgboxlist.init;
{ initialize the menu item }
var
	i:integer;
begin
	msgbox.init(st,x,y);
  ismarked := false;
  saveback := false;
	inc(width,4);
	inc(hight,1);
	ID:=IDnum;
	setbox(on,on);
	next := nil;
	option(miAutoPlaceY);
end;

function msgboxlist.insert;
{           insert a masseg box         }
var
	newx,newy:integer;
begin
  insert := true;

  if maxavail < mblsize then begin
  	insert := false;
    exit;
  end;
	if next <> nil then next^.insert(title,x,y)
	else begin
		new(next);
		newx := x;
		newy := y;
		if newx = 0 then newx := cx;
		if newy = 0 then newy := cy;
		if autoplaceX then begin
			newx := cx+width;
			if Xdist1 then inc(newX,4);
			if Xdist2 then inc(newX,14);
		end;
		if autoplaceY then begin
			newy := cy+hight;
			if Ydist1 then inc(newY,4);
			if Ydist2 then inc(newY,14);
		end;
		next^.init(title,newx,newy,ID+1);
{    next^.display;}
    if samesize then next^.autosize := false;
		next^.option(options);
		next^.setfont(fontname,fontsize);
		next^.setmcolor(txtcolor,color,bkcolor,ID+1);
		next^.set3D(is3D,is3Dinverse);
    next^.set3Dmode(mode3D);
		next^.setbox(dbox,noframe);
    next^.textshadow := textshadow;
    next^.saveback := false;
    next^.setjustify(justify);
    next^.settextoffset(ofX,ofY);
		IF SameSize then chngdim(0,0,width,hight,centerbox,next^.ID);
    if displayed then next^.display;
	end;
end;

procedure msgboxlist.findbiggest;
{ find the biggest box }
begin
	if wid < width then wid := width;
	if hit < hight then hit := hight;
	if next <> nil then next^.findbiggest(wid,hit,changesize);
	if changesize then begin
{		samesize := true;
		if ((options and miSameSize) <> miSameSize) then options := options+miSameSize;}
		chngdim(0,0,wid,hit,centerbox,ID);
	end;
end;


procedure msgboxlist.setmcolor;
begin
	if ID <> IDnum then begin
		if next <> nil then next^.setmcolor(tcolor,fcolor,bcolor,idnum);
	end else msgbox.setmcolor(tcolor,fcolor,bcolor);
end;

procedure msgboxlist.getdims;
begin
	if ID = IDnum then begin
		if iscenter then begin
			nx1 := cx;
			ny1 := cy;
			nx2 := width;
			ny2 := hight;
		end else begin
			nx1 := x1;
			ny1 := y1;
			nx2 := x2;
			ny2 := y2;
		end;
	end else begin
		if next <> nil then next^.getdims(nx1,ny1,nx2,ny2,iscenter,IDnum)
		else begin
			nx1 := 0;
			ny1 := 0;
			nx2 := 0;
			ny2 := 0;
		end;
	end;
end;

procedure msgboxlist.setboxoptions;
begin
	if next <> nil then next^.setboxoptions(bx3D,bx3dinv,bxdraw,bxnoframe,bxautosize)
	else begin
		setbox(bxdraw,bxnoframe);
		autosize:=bxautosize;
		set3d(bx3d,bx3dinv);
	end;
end;

procedure msgboxlist.chngdim;
var d:boolean;
begin
	if IDnum = 0 then begin
		if next <> nil then next^.chngdim(nx1,ny1,nx2,ny2,iscenter,IDnum);
    d := displayed;
    erase;
		box.chngdim(nx1,ny1,nx2,ny2,iscenter);
    saveback := true;
    getbackimage;
    saveback := false;
    if d then display;
    displayed := d;
		autosize := false;
	end else if (ID <> IDnum) then begin
		if next <> nil then next^.chngdim(nx1,ny1,nx2,ny2,iscenter,IDnum)
	end else begin
    d := displayed;
    erase;
		box.chngdim(nx1,ny1,nx2,ny2,iscenter);
    saveback := true;
    getbackimage;
    saveback := false;
    if d then display;
    displayed := d;
		autosize := false;
	end;
end;

function msgboxlist.getisin;
begin
	if next <> nil then begin
		if isin(x,y) then getisin := ID
		else getisin := next^.getisin(x,y);
	end else begin
		if isin(x,y) then getisin := ID
		else getisin := 0;
	end;
end;

procedure msgboxlist.chngmsg;
begin
	if ID <> IDnum then begin
		if next <> nil then next^.chngmsg(st,IDnum)
	end	else msgbox.chngmsg(st);
end;

procedure msgboxlist.displayall;
begin
	if ID <> 0 then display else displayed := true;
	if next <> nil then next^.displayall; { if first then display all chain }
end;

procedure msgboxlist.hide;
begin
	erase;
	if next <> nil then next^.hide;
end;

procedure msgboxlist.option;
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
	end;
end;

function msgboxlist.getlastID;
begin
	if next <> nil then getlastID := next^.getlastID else getlastID :=ID;
end;

procedure msgboxlist.free;
begin
	msgbox.erase;
	if next<>nil then begin
		next^.free;
		next^.bye;
		dispose(next);
		next := nil;
	end;
end;

destructor msgboxlist.bye;
begin
	if next <> nil then begin
		next^.bye;
		if not ismarked then dispose(next);
		next := nil;
	end;
	inherited bye;
end;
end.