program kbt;
uses general,boxes,app,event,proc,mousebx,exbox,drivers;
const
	maxbox=18;
	showportbase=30;

  portbox=showportbase+maxbox+1;
  changeportbase=50;
  exit=70;
  getinputnum=20;
  inputctl=25;

  SeePort:word=$0043;

var
	show_box:array [0..maxbox+2] of inputbox;
  tstbox:msgbox;
  exitbx:msgbox;
  appl:application;

procedure getinput(ID:byte);
begin
	show_box[id].enabled:= true;
  show_box[id].set3D(on,off);
  show_box[id].setallselection;
end;
procedure stopinput(ID:byte);
begin
  show_box[id].setallselection;
	show_box[id].enabled:= false;
  show_box[id].set3D(on,on);
  if id<=maxbox then port[seeport+id-1] := vali(show_box[id].get) MOD 255
  else seeport:=vali(show_box[id].get) MOD 255;
end;

function kbinput(ID:word):word; far;
var ev:tevent;
	b:pa;
begin
  kbinput := 0;
	getkeyevent(ev);
 	if ev.keycode = kbesc then kbinput := prexit
  else begin
    b.inf := ev;
    b.cmd := 1;
		eventline.put(b);
  end;
end;

function showport(ID:word):word; far;
var
	v:byte;
  n:word;
	ev : pa;
begin
	showport := 0;
  n := ID-showportbase;
{  v := mem[SeePort:$0012+n];}
  v := port[seeport+n-1];
  mouse.erase;
  if show_box[n].enabled then
		while not eventline.isempty do begin
	  	eventline.get(ev,-1);
    	eventline.unput;
			if show_box[n].sendkey(ev.inf) then stopinput(n);
    end;
  if mouse.buttompressed[1] then begin
  	if show_box[n].isin(mouse.x,mouse.y) then getinput(n) else begin
      if show_box[n].enabled then stopinput(n);
{ 		show_box[n].chngmsg(stry(v,0,0))};
    end;
  end else if not show_box[n].enabled then show_box[n].chngmsg(stry(v,0,0));
  mouse.display;
end;

function Doexit(id:word):word; far;
begin
  doexit := 0;
	with mouse do
  	with exitbx do begin
      if isin(x,y) then begin
				if pressed[1] then set3D(on,on);
        if released[1] and is3Dinverse then doexit := prexit;
      end else set3D(on,off);
    end;
end;

procedure linear2matrix(l,mx,my:word;var lx,ly:integer);
begin
	lx:=l mod mx;
  ly:=l div mx;
end;

var
	i:integer;
  w,h:integer;

begin
	graphinit(4);
  appl.init;
{  dokb := true;}
  for i := 0 to maxbox do begin
		with show_box[i] do begin
      linear2matrix(i,4,4,w,h);
      inc(w);
			h := h-2;
    	init('','0000',w*95+60,h*50+220);
      autosize := false;
      setjustify(center);
      setmcolor(12,7,5);
      set3D(on,on);
      set3Dmode(inside);
      enabled := false;
      display;
    	appl.insert(evntProccess,showport,showportbase+i,normal);
    end;
	end;
  with show_box[maxbox+1] do begin
      linear2matrix(i,4,4,w,h);
      inc(w);
			h := h-2;
    	init('',stry(seeport,0,0),swidth div 2,50);
      autosize := false;
      setjustify(center);
      setmcolor(15,7,1);
      set3D(on,on);
      set3Dmode(inside);
      enabled := false;
      display;
    end;

  with exitbx do begin
  	init('EXIT',swidth div 2,shight-50);
    setmcolor(15,0,7);
    set3D(on,off);
    display;
  end;
 	appl.insert(evntProccess,showport,portbox,normal);
  appl.insert(evntMouse,doexit,exit,normal);
  appl.insert(evntkey,kbinput,inputctl,normal);
  appl.run;

	appl.done;
end.







