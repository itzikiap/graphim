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

{  CounterBox=object(msgbox)
  { a box with a number that you can change it by clicking and dragging }
{  	Number : counter;
    prompt :}


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

end.




