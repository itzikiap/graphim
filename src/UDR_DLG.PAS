unit Udr_Dlg;
{ dilogs for user draw }
interface
uses
	general,mousebx,event,app,proc,drivers,set_gr,exbox,boxes;

procedure getranges(var mx1,mx2,my1,my2:real);

implementation

const
  baseS=51;
	sminx=31;
  smaxx=32;
  sminy=33;
  smaxy=34;
  mmenu=35;
  mexit=40;
  mauto=41;
  mfind=42;

type
	rang=(bx1,bx2,by1,by2);

var st:string;
    ax1,ay1,ax2,ay2:extended;
  	bx:array [0..3] of inputbox;
    isok:boolean;
		menu:array[0..1] of msgbox; {0- OK; 1- autofit}
	  selected:byte;
  	i:byte;
		dialog:application;


function handleevent(ID:word):word; far;
begin
	case ID of
  	mexit : handleevent := prexit;
    mauto : begin
			bx[2].init('MINY = ','1',bx[2].cx,bx[2].cy);
			bx[3].init('MAXY = ','-1',bx[3].cx,bx[3].cy);
      handleevent := prexit;
    end;
  end;
end;


function domnu(ID:word):word; far;
var i:integer;
begin
  domnu := 0;
	i:=0;
  for i := 0 to 2 do begin
		with menu[i] do begin
			if isin(mouse.X,mouse.Y) and mouse.pressed[1] then begin
    	  isok := true;
				domnu := mexit+i;
	    end;
			if isin(mouse.X,mouse.Y) and mouse.pressed[2] then begin
    	  isok:= false;
				domnu := mexit+i;
	    end;
  	end;
  end;
end;

procedure select(c:byte);
begin
  mouse.erase;
  with bx[c] do begin
  	for i := 0 to 3 do begin
    	if i<>c then begin
     		bx[i].enabled := false;
     		bx[i].set3D(on,off);
    		bx[i].set3Dmode(small);
    	end;
  	end;
		selected := c;
	  enabled := true;
   	set3dmode(inside);
		set3d(on,on);
    setallselection;
  end;
  mouse.display;
end;

function cselect(ID:word):word; far;
var
	c:byte;
  i:integer;
begin
	c := ID-baseS;
  mouse.erase;
  with bx[c] do begin
  	if isin(mouse.x,mouse.y) then begin
    	set3dmode(inside);
    	if mouse.pressed[1] then begin
        for i := 0 to 3 do begin
          if i<>c then begin
	        	bx[i].enabled := false;
 	         	bx[i].set3D(on,off);
 	         	bx[i].set3Dmode(small);
          end;
        end;
				selected := c;
      end;
    end else if selected <> c then set3Dmode(small);
    if selected = c then begin
      enabled := true;
      setallselection;
			set3d(on,on);
    end else begin
      enabled := false;
			set3d(on,off);
    end;
  end;
 	mouse.display;
	cselect := 0;
end;

function skey(ID:word):word; far;
var
	e:boolean;
begin
  skey := 0;
{  getkeyevent(ev);}
{  if (ev.what = evkeydown) then begin}
  	if kbp.keycode = kbtab then select((selected +1) mod 4);
  	if kbp.keycode = kbshifttab then begin
      if selected = 0 then selected := 4;
			select(selected -1);
    end;
    if kbp.keycode = kbenter then skey := prexit;
{  end;}
  bx[selected].sendkey(kbp);
end;

procedure getranges;
{ ********** get the ranges for the graph }
{ use the new "multitasking" architecture }

var
	app:application;

begin
  app.init;
  isOK := true;
  for i := 0 to 1 do
		with menu[i] do begin
  		if i = 0 then init('     OK     ',swidth div 2,shight-50);
  		if i = 1 then init(' AUTO FIT ',swidth div 2,shight-90);
	    setmcolor(9,0,7);
      if i = 1 then setfont(1,2);
  	  set3D(on,off);
	  	display;
			app.insert(evntMouse,domnu,mmenu,normal);
  	end;
  for i := 0 to 3 do
		with bx[i] do begin
  		if rang(i)=bx1 then init('MINX = ',stry(mx1,5,3),swidth div 2-130,shight div 2-40);
  		if rang(i)=bx2 then init('MAXX = ',stry(mx2,5,3),swidth div 2+130,shight div 2-40);
  		if rang(i)=by1 then init('MINY = ',stry(my1,5,3),swidth div 2-130,shight div 2+40);
  		if rang(i)=by2 then init('MAXY = ',stry(my2,5,3),swidth div 2+130,shight div 2+40);
    	setjustify(just(left));
    	setmcolor(14,0,8);
      set3D(on,off);
      setfont(3,3);
      textshadow := true;
      autosize := false;
    	enabled := false;
	  	app.insert(evntMouse,cselect,baseS+i,normal);
      filter := nums;
      display;
  	end;
	app.insert(evntkey,skey,baseS,normal);
  app.insert(evntCmd,handleevent,mexit,normal);
  app.insert(evntCmd,handleevent,mauto,normal);

  select(0);
	app.run;

  if isOK then for i := 0 to 3 do
		with bx[i] do begin
  		if rang(i)=bx1 then mx1:=valr(get);
  		if rang(i)=bx2 then mx2:=valr(get);
  		if rang(i)=by1 then my1:=valr(get);
  		if rang(i)=by2 then my2:=valr(get);
    end;
  app.done
end;

end.