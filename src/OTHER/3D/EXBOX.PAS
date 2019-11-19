unit ExBox;
{  extended BOXES control unit  }
{  PROGRAMMED BY ITZHAK         }
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
  { display a progress line on the screen }
	progress=object(box)
		number:counter;
		stepsize:real;
		constructor init(nx1,ny1,nx2,ny2:integer;min,max:longint);
		procedure display; virtual;
		procedure decby(by:integer);
		procedure incby(by:integer);
		procedure setit(value:longint);
		function get:longint;
    function limit(isupper:boolean):integer; { check limits }
		destructor bye; virtual;
	end;

	inputbox=object(msgbox)
    limit           :byte;        { the maximum characters allowed }
    changed:boolean;
    userfilter: set of char;
    filter:(none,ucase,lcase,letters,nums,user);
		firststr,secondstr:string;
    selection:string;
    FCS,SCS:byte;
    f:boolean; { when true-selection updates by first }
    enabled:boolean;
		place:byte;
		scplace:integer;
		prompt:string;
		isinsert:boolean;
		constructor init(prom,inistr:string;x,y:integer); { initialize variables }
    procedure setallselection;
		procedure display; virtual;
		function sendkey(ev:tevent):boolean;
{    procedure SetCursorPosition(pos:byte;ischar:boolean);  { if ischar on - the cursor position set in character. }
		function get:string;   	   												     { else - in X on screen (for the mouse }
		destructor bye; virtual;
	end;

	Pmsgboxlist=^msgboxlist;
	msgboxlist=object(msgbox)
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
		procedure insert(title:string;x,y:integer); { insert box in last place }
		procedure option(newopt:word); { insert option }
		procedure free; { free up all items from memory }
		destructor bye; virtual;
	end;


implementation
{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
{*			  PROGRESS OBJECT PROCEDURES		     *}
{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
constructor progress.init;
begin
	box.init(nx1,ny1,nx2,ny2,cornerbox);
	number.init(min,max,min,1);
	stepsize := abs(nx2-nx1) / abs(max-min);
	set3D(on,off);
	setmcolor(9,7);
end;

procedure progress.display;
begin
	box.display;
	setfillstyle(solidfill,color);
	bar(x1+1,y1+1,x1+trunc(stepsize*(number.get-number.min)),y2-1);
end;

procedure progress.incby;
begin
	number.incby(by);
	if displayed then display;
end;

procedure progress.decby;
begin
	number.decby(by);
	if displayed then display;
end;

procedure progress.setit;
var i:integer;
begin
	i := number.get;
	if i < value then number.incby(i-value) else
	if i > value then number.decby(i-value);
	if displayed then display;
end;

function progress.limit;
begin
	if isupper then limit := number.max else limit := number.min;
end;

function progress.get;
begin
	get := number.get;
end;

destructor progress.bye;
begin
	box.bye;
	number.done;
end;

{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
{*			  INPUTBOX OBJECT PROCEDURES		     *}
{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
constructor inputbox.init;
begin
	msgbox.init(prom+inistr,x,y);
  changed := false;
  limit := 255;
	prompt:=prom;
	firststr := inistr;
	secondstr := '';
  selection := '';
  enabled := true;
	place := length(firststr);
  fcs := place;
  scs := place;
	isinsert := true;
	filter := none;
end;

procedure inputbox.setallselection;
{ set selection to the whole text }
{ that way the first character input will erase current string }
begin
	selection := firststr+selection+secondstr;
  firststr := '';
  secondstr := '';
  fcs := 1;
  scs := length(selection);
  place := scs;
end;

procedure inputbox.display;
{ display the input box }
var fcscs,scscs:integer;
  tfc,tsc,t1:integer;
begin
	msgbox.display;
  tfc:=textwidth(prompt+firststr);
  tsc:=textwidth(prompt+firststr+selection);
  if justify = center then begin
    t1 :=textwidth(prompt+firststr+selection+secondstr);
	  fcscs := cx-t1 div 2+tfc+ofx;
		scscs := cx-t1 div 2+tsc+ofx;
  end else if justify = left then begin
	  fcscs := x1+tfc+ofx;
		scscs := x1+tsc+ofx;
  end else if justify = right then begin
	  fcscs := x2-tfc+ofx;
		scscs := x2-tsc+ofx;
  end;
	if f then scplace := fcscs else scplace := scscs;
  if selection <> '' then begin
		line (fcscs,y2-5,scscs,y2-5);
		line (fcscs,y1+5,scscs,y1+5);
  end;
	if isinsert then setlinestyle(solidln,0,1) else setlinestyle(solidln,0,3);
	if enabled then line(scplace,y1+5,scplace,y2-5);
end;

function inputbox.sendkey;
{ proccess the keys sent to the input box }
{ Return true when pressed ENTER }
var c:char;

function mfilter(ch:char):char;
begin
 	mfilter := #0;
	case filter of
  	none:mfilter := ch;
    ucase:mfilter := upcase(ch);
    lcase:if (ord(ch)>=65) and (ord(ch)<=90) then mfilter := chr(ord(ch)+32) else mfilter := ch;
    letters:if ch in ['a'..'z','A'..'Z'] then mfilter := ch;
    nums:if ch in ['0'..'9','-','.'] then mfilter := ch;
    user:if ch in userfilter then mfilter := ch;
  end;
end;

begin
  sendkey := true;
  if not enabled then exit;
  sendkey := false;
	if ev.what = evkeydown then begin
		case ev.keycode of
			kbback: begin if selection <> '' then selection := ''
				else if firststr <> '' then begin
          changed := true;
					delete(firststr,length(firststr),1);
					dec(place);
        end;
        fcs := place;
        scs := fcs;
			end;
			kbdel:begin if selection <> '' then	selection := ''
				else if secondstr <> '' then begin
          changed := true;
					delete(secondstr,1,1);
					inc(place);
        end;
        fcs := place;
        scs := fcs;
			end;
			kbright: begin
        firststr := firststr+selection;
        selection := '';
				if secondstr <> '' then begin
					c := secondstr[1];
					firststr := firststr + c;
					delete (secondstr,1,1);
					inc(place);
        end;
        fcs := place;
        scs := fcs;
			end;
			kbleft:begin
        secondstr := selection+secondstr;
        selection := '';
				if firststr <> '' then begin
					c := firststr[length(firststr)];
					secondstr := c + secondstr;
					delete(firststr,length(firststr),1);
					dec(place);
        end;
        fcs := place;
        scs := fcs;
			end;
			kbhome:  if firststr <> '' then begin
				secondstr := firststr+selection+secondstr;
        selection := '';
				firststr := '';
				place := 0;
        fcs := place;
        scs := fcs;
			end;
			kbend:  if secondstr <> '' then begin
				firststr := firststr+selection+secondstr;
        selection := '';
				secondstr := '';
				place := length(firststr);
        fcs := place;
        scs := fcs;
			end;
			kbins:isinsert := not isinsert;
      kbenter:begin
      	enabled := false;
        sendkey := true;
        firststr := firststr+selection+secondstr;
        selection:='';
        secondstr:='';
        place := length(firststr);
        fcs := place;
        scs := fcs;
        display;
      end;
      kbesc:begin
        changed := false;
      	enabled := false;
        firststr := firststr+selection+secondstr;
        selection:='';
        secondstr:='';
        place := length(firststr);
        fcs := place;
        scs := fcs;
      end;
      kbctrlleft:begin { SHIFT+LEFT - for selection }
      	if selection = '' then begin
          f := true;
					if firststr <> '' then begin
						dec(fcs);
	          c := firststr[length(firststr)];
						selection := c + selection;
						delete(firststr,length(firststr),1);
						dec(place);
        	end;
        end else if f then begin
					if firststr <> '' then begin
						dec(fcs);
	          c := firststr[length(firststr)];
						selection := c + selection;
						delete(firststr,length(firststr),1);
						dec(place);
            changed := true;
        	end;
        end else begin
          if scs > fcs then begin
						dec(scs);
   	        c := selection[length(selection)];
						secondstr := c + secondstr;
						delete(selection,length(selection),1);
						dec(place);
        	end;
        end;
      end;
      kbctrlright:begin { SHIFT+RIGHT - for selection }
      	if selection = '' then begin
          f := false;
					if secondstr<>'' then begin
						inc(scs);
	          c := secondstr[1];
						selection := selection+c;
						delete(secondstr,1,1);
						inc(place);
        	end;
        end else if not f then begin
					if secondstr<>'' then begin
						inc(scs);
	          c := secondstr[1];
						selection := selection+c;
						delete(secondstr,1,1);
						inc(place);
        	end;
        end else begin
          if scs > fcs then begin
						inc(fcs);
   	        c := selection[1];
						firststr := firststr+c;
						delete(selection,1,1);
						inc(place);
        	end;
        end;
      end;
			else if ev.charcode in [#31..#128] then begin
        selection := '';
        changed := true;
				if (not isinsert) and (secondstr <> '') then delete (secondstr,1,1);
        if length(firststr)+length(secondstr) <= limit then begin
          if not((not autosize) and (x1+textwidth(prompt+firststr)+ofx > x2-3)) then begin
            c := mfilter(ev.charcode);
            if c <> #0 then firststr:=firststr+c;
	        	inc(place);
          end;
        end;
        fcs := place;
        scs := fcs;
			end;
		end;
{    erase;}
    chngmsg(prompt+firststr+selection+secondstr);
  	display;
	end;
end;

function inputbox.get;
begin
	get := firststr+selection+secondstr;
end;

destructor inputbox.bye;
begin
	msgbox.bye;
end;

{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
{*		 MSGBOXLIST OBJECT PROCEDURES	  	    *}
{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
constructor msgboxlist.init;
{ initialize the menu item }
var
	i:integer;
begin
	msgbox.init(st,x,y);
	inc(width,4);
	inc(hight,1);
	ID:=IDnum;
	setbox(on,on);
	next := nil;
	option(miAutoPlaceY);
end;

procedure msgboxlist.insert;
{           insert a masseg box         }
var
	newx,newy:integer;
begin
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
	msgbox.bye;
	if next <> nil then begin
		next^.bye;
		dispose(next);
		next := nil;
	end;
end;

end.




