program application_unit_test;
uses
	general,event,app,mousebx,boxes,proc;

const
	Mouseexit=11;

  Tbpressed=90;
  Tbdragged=22;

  tbxs=14;
  maxx=10;
  maxy=10;

type
	movebx=object(box)
  	procedure moveit;
{    function tbproc(ID:word):boolean;}
  end;

var
	tb:array[1..tbxs] of movebx;
  i:integer;
	testapp : application;

function Cmouse(ID:word):word; far;
begin
	if mouse.released[3] then Cmouse := prexit else cmouse := 0;
end;

procedure movebx.moveit;
begin
	with mouse do begin
    movebx.move(xmove,ymove,relboxmove);
  end;
end;

function tbproc(ID:word):word; far;
var m:byte;
begin
  m:=id-tbpressed;
  tbproc := 0;
	with mouse do if pressed[1] then begin
  	if tb[m].isin(x,y) then begin
	    erase;
			tb[m].setmcolor(5,(tb[m].bkcolor+1) mod 15);
    	tb[m].set3D(on,on);
	    display;
    end;
  end else if pressed[2] then begin
    if tb[m].isin(x,y) then begin
      erase;
			tb[m].erase;
      display;
    end;
  end;
  if tb[m].is3dinverse then begin
		mouse.erase;
		tb[m].moveit;
    if mouse.released[1] then tb[m].set3D(on,off);
  	mouse.display;
  end;
end;


begin
  graphinit(3);
  mouse.init;

  testapp.init;
	testapp.insert(evntMouse,Cmouse,mouseexit,normal);
  randomize;
  for i := 1 to tbxs do with tb[i] do begin
  	init(random(swidth),random(shight),10+random(maxx-10),10+random(maxy-10),centerbox);
    setmcolor(1,i mod 15);
    set3D(on,off);
    display;
    testapp.insert(evntMouse,tbproc,tbpressed+i,normal);
  end;
  testapp.run;

  testapp.done;
end.
