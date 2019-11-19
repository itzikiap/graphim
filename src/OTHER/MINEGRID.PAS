unit Minegrid;
interface
uses general,boxes,mousebx,exbox;

type
  gridID=record
    X,Y: Byte;
    MaxX,MaxY: byte;
  end;

  MinePtr= ^MineBx;
 	Minebx = object(msgbox)
    NOM:byte;
    ID     :  gridID;
    done   : boolean; { set to yes by external procedure }
		HasMine: boolean;
    Opened : Boolean;
    Marked : Boolean;
    Sorounding :byte; { The number of sorounding mines }
		U,D,L,R :MinePtr;
    constructor init(Info:gridID);
    Procedure IncSor;
    function ProccessMouse:boolean; { Return False if opened Mine }
    procedure Open;
    procedure Doneit;
    procedure Dodone(fline:mineptr);
    destructor Bye; virtual;
  end;

function SetMine(var grid:mineptr;WX,WY:byte;x,y:integer):boolean;
Function IsMine(grid:mineptr;Wx,Wy:byte):boolean; { Check If Specifide Box has a mine }
Procedure open(var grid:mineptr;Wx,Wy:byte);
procedure initgrid(var thegrid:mineptr;maxx,maxy,noms:byte);

var
  pasul:boolean;
  won:boolean;
  MarkedNum,FoundNum,OpenedNum,MarkedRightNum:integer;

implementation
var
	mousefound:boolean;

{****************************************}
{*     MINEBX Object Implementation     *}
{****************************************}
{ INIT - gets its position and the number of boxes }
{		then recursively Creates dynamic objects       }
constructor MineBx.INIT(Info:gridid);
begin
  ID:=info;
  R       :=   nil;
  L       :=   nil;
  U       :=   nil;
  D       :=   nil;
  Done    := false;
  HasMine := False;
  Opened  := False;
  Marked  := False;
  mousefound := false;
  Sorounding :=  0;
  MsgBox.init('O',id.x*15,id.Y*20);
  setfont(2,5);
  settextoffset(-1,-10);
  chngdim(cx,cy,width-4,hight-4,centerbox);
  setmcolor(15,9,7);
  set3D(on,off);
  set3Dmode(small);
  autosize := false;
  chngmsg('');
  display;
end;

(*****************************************************)
(*****************************************************)
procedure MineBx.incsor;
begin
  if Not HasMine then begin
		if sorounding = 0 then setmcolor(0,7,bkcolor);
    inc(sorounding);
    setmcolor(txtcolor+1,7,bkcolor);
    set3Dmode(small);
    msg := chr(sorounding+48);
  end;
end;

(*****************************************************)
(*  proccess mouse buttons. first find what box is uner the mouse *)
(*****************************************************)
Function MineBx.ProccessMouse;
var
	m:boolean;
  nmarked:byte;

begin
  m := false;
  if (mouse.Y > y2) and (D <> nil) and (not m) then begin
		m := D^.proccessmouse;
  end;
  if (mouse.X > x2) and (R <> nil) and (not m) then begin
		m := R^.proccessmouse;
  end;
	if isin(mouse.x,mouse.y) and (not opened) then begin
    proccessmouse := true;
    mouse.erase;
 	  if mouse.pressed[1] then open;
  	if mouse.pressed[2] and not is3Dinverse then begin
      if marked then begin
				if hasmine then dec(foundnum);
        dec(markednum);
				setmcolor(15,9,bkcolor);
        chngmsg('');
        marked := off;
      end else if markednum < nom then begin
        setmcolor(14,12,bkcolor);
				if hasmine then begin
{          setmcolor(14,12,4);}
					inc(foundnum);
        end;
        inc(markednum);
      	chngmsg('V');
				marked := on;
      end;
    end; { if pressed [2] }
		if mouse.pressed[3] and (sorounding > 0) then begin
    	nmarked:=0;
      if u <> nil then begin
				if u^.marked then inc(nmarked);
        if u^.l <> nil then if u^.l^.marked then inc(nmarked);
        if u^.r <> nil then if u^.r^.marked then inc(nmarked);
      end;
      if d <> nil then begin
				if d^.marked then inc(nmarked);
        if d^.l <> nil then if d^.l^.marked then inc(nmarked);
        if d^.r <> nil then if d^.r^.marked then inc(nmarked);
      end;
      if l <> nil then if l^.marked then inc(nmarked);
      if r <> nil then if r^.marked then inc(nmarked);
      if nmarked = sorounding then begin
	      if u <> nil then begin
					if not u^.hasmine then u^.open;
    	    if u^.l <> nil then if not u^.l^.hasmine then u^.l^.open;
      	  if u^.r <> nil then if not u^.l^.hasmine then u^.r^.open;
	      end;
  	    if d <> nil then begin
					if not d^.hasmine then d^.open;
    	    if d^.l <> nil then if not d^.l^.hasmine then d^.l^.open;
      	  if d^.r <> nil then if not d^.l^.hasmine then d^.r^.open;
	      end;
   	    if l <> nil then if not l^.hasmine then l^.open;
     	  if r <> nil then if not l^.hasmine then r^.open;
      end;
    end; { if pressed[3] }
  	mouse.display;
 	end;
end;

(*****************************************************)
(*  CALL IT AFTER INITIALIZE TO COMPLETE             *)
(*****************************************************)
procedure minebx.doneit;
begin
  if (not done) and (R <> nil) then dodone(R^.l);
end;

(*****************************************************)
(*****************************************************)
procedure minebx.dodone;
begin
  done := true;
  if R <> nil then R^.dodone(fline)
  else if fline^.D <> nil then begin
    fline := fline^.D;
    Fline^.done := true;
		fline^.R^.dodone(fline);
  end;
end;

(*****************************************************)
(*   Opens all "openables" boxes. writes sorounding  *)
(*****************************************************)
procedure MineBx.Open;
begin
	if not (marked or opened or hasmine or is3dinverse) then begin
    set3D(on,on);
    set3Dmode(inside);
{    setmcolor(15,9,1);}
		inc(openednum);
		delay(115);
    sorounding := 0;
    if U <> nil then begin
    	if u^.hasmine then incsor;

    	if u^.L <> nil then
    		if u^.l^.hasmine then incsor;
    	if u^.R <> nil then
    		if u^.r^.hasmine then incsor;
    end;

    if D <> nil then begin
    	if d^.hasmine then incsor;
    	if d^.L <> nil then
    		if d^.l^.hasmine then incsor;
    	if d^.R <> nil then
    		if d^.r^.hasmine then incsor;
    end;
    if L <> nil then begin
    	if l^.hasmine then incsor;
		end;
    if R <> nil then begin
    	if r^.hasmine then incsor;
    end;
    if sorounding > 0 then begin
      { massege been changed in "IncSor" }
			display;
    end else begin
    	if U <> nil then begin
				U^.open;
        if u^.L <> nil then u^.l^.open;
        if u^.R <> nil then u^.r^.open;
      end;
    	if L <> nil then L^.open;
    	if D <> nil then begin
				D^.open;
        if d^.L <> nil then d^.l^.open;
        if d^.R <> nil then d^.r^.open;
      end;
    	if R <> nil then R^.open;
			set3Dmode(small);
{	    setmcolor(15,9,9);}
    end;
  end else if hasmine and not marked then begin
    pasul := true;
    erase;
    setmcolor(4,12,12);
    set3D(on,on);
    chngmsg('X');
    display;
  end;
end;

(*****************************************************)
(*****************************************************)
destructor minebx.bye;
begin
	if R<>nil then R^.bye;
	if D<>nil then D^.bye;
  done := false;
	erase;
end;

(*****************************************************)
(*****************************************************)
(*****************************************************)

procedure initgrid(var thegrid:mineptr;maxx,maxy,noms:byte);
var
	i,i1:integer;
  nx,lx,ny,ly,fy1,fy2:mineptr;
  id:gridID;
begin
  id.x := 1;
  id.y := 1;
  id.maxX := maxx;
  id.maxY := maxy;
	new(thegrid,init(id));
  thegrid^.nom := noms;
  lx := thegrid;
  fy1 := thegrid;
  inc(id.x);
	while id.x < id.maxx do begin
		new(nx,init(id));
    nx^.nom := lx^.nom;
    lx^.R := nx;     { OÍOÍOÍOÍOÍO }
    nx^.L := lx;     {             }
    lx    := nx;     { . . . . . . }
    inc(id.X);
  end;
	new(nx,init(id));
  lx^.R := nx;
  nx^.L := lx;
  while id.y < id.maxy do begin
    id.x  :=   1;
    inc(id.y);
    new(fy2,init(id));
    fy2^.nom := noms;
    fy1^.D := fy2;
    fy2^.U := fy1;
{    fy1    := fy2;}
    inc(id.x);
		lx     := fy2;
		while id.x < id.maxx do begin
			new(nx,init(id));
    	nx^.nom := noms;
      lx^.R := nx;                { OÍOÍOÍOÍOÍO }
      nx^.L := lx;                {             }
      lx    := nx;                { . . . . . . }
      inc(id.X);
    end;
		new(nx,init(id));
    nx^.nom := noms;
    lx^.R := nx;        { OÍOÍOÍOÍOÍO }
    nx^.L := lx;        {             }
    ly := fY1;
    ny := fy2;
    i  :=   1;
    While i < id.maxx do begin
      ly := ly^.R;  { OÍOÍOÍOÍOÍO }
      ny := ny^.R;  { º º º º º º }
	    ly^.D := ny;  { OÍOÍOÍOÍOÍO }
  	  ny^.U := ly;
      inc(i);
    end;
    fy1 := fy2;
    lx := fy2;
	end;
  thegrid^.doneit;
end;

(*****************************************************)
(*****************************************************)
(*****************************************************)
Function Getcell(var grid:mineptr;Wx,Wy:byte):mineptr;
var
	current:mineptr;
begin
  if grid^.done then begin{ Do it only if all pointers are set }
  	current:=grid;
   	if WX > current^.ID.Maxx then WX := current^.ID.MaxX;
   	if WY > current^.ID.MaxY then WY := current^.ID.MaxY;
 		while WX > current^.ID.X do
     	current:=current^.R;
 		while WY > current^.ID.Y do
     	current:=current^.D;
    if (WX = current^.ID.X) and (WY = current^.ID.Y) then
 	    getcell:=current;
  end;
end;

(*****************************************************)
(*****************************************************)
(*****************************************************)
function SetMine;
{ SetMine - Put Mine In Current Box      }
{ Alsow increes the number of sorounding }
{  Boxes by one                          }
var
	current:mineptr;
begin
  setmine := false;
  if grid^.done then begin{ Do it only if all pointers are set }
  	current:=getcell(grid,wx,wy);
    if not current^.hasmine then
    	if not current^.isin(x,y) then begin
        setmine := true;
				current^.HasMine := on;
      end;
  end;
end;

(*****************************************************)
(*****************************************************)
(*****************************************************)
function Ismine;
var
	current:mineptr;
begin
  if grid^.done then begin{ Do it only if all pointers are set }
  	current:=getcell(grid,wx,wy);
    ismine :=Current^.hasmine;
	end;
end;

(*****************************************************)
(*****************************************************)
(*****************************************************)
procedure open;
var
	current:mineptr;
begin
  if grid^.done then begin{ Do it only if all pointers are set }
  	current:=getcell(grid,wx,wy);
    Current^.open;
	end;
end;

(*****************************************************)
(*****************************************************)
begin
	mousefound     := false;
  pasul          := false;
  won            := false;
  MarkedNum      := 0;
	FoundNum       := 0;
	OpenedNum      := 0;
	MarkedRightNum := 0;
end.