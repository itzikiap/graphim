program Mine;
uses general,boxes,mousebx,exbox,minegrid,bxdialog;
{$R-,Q-}
const
	Xgrid :byte= 30;
  Ygrid :byte= 15;
  NumOfMines :byte= 54;

var
	id:gridID;
  mgrid:mineptr;
  bye:boolean;
  i,i1,l1,l2:integer;
  f,o,m:msgbox;
  t:timer;
  c100,c60,csec,cmin:counter;
  st:string;

begin
	graphinit(4);
  st := stry(xgrid,0,0);
  getstr(swidth div 2,150,'MAX X: ',st);
  xgrid := vali(st);
  st := stry(ygrid,0,0);
  getstr(swidth div 2,200,'MAX Y: ',st);
  ygrid := vali(st);
  st := stry(numofmines,0,0);
  getstr(swidth div 2,250,'MINES: ',st);
  numofmines := vali(st);

  initgrid(mgrid,xgrid,ygrid,NumOfMines);
  c100.init(0,2,0,1);
  csec.init(0,59,0,1);
  cmin.init(0,59,0,1);
  c100.setlink(@csec);
  csec.setlink(@cmin);

  with f do begin
		init('00:00',50,shight-20);
    autosize := false;
  	display;
  end;
  with o do begin
		init('00000',swidth div 2,shight-20);
    autosize := false;
  	display;
  end;
  with m do begin
		init('00000',swidth-50,shight-20);
    autosize := false;
  	display;
  end;
  mouse.init;
  randomize;
  mouse.move(-110,-110);
  mouse.display;
  repeat
  	mouse.update;
  until mouse.pressed[1] or mouse.pressed[2];
	for i := 1 to numofmines do
  	if not setmine(mgrid,random(xgrid-1)+1,random(ygrid-1)+1,mouse.x,mouse.y) then dec(i);
	bye:=mgrid^.proccessmouse;
  t.init;
  t.reset;
  while (not (won or pasul))  do begin
    mouse.update;
    if t.cycle(100) then csec.inc;
   	f.chngmsg(stry(cmin.get,0,0)+':'+stry(csec.get,0,0){+':'+stry(c60.get,0,0)});
    if mouse.changed then begin
			bye:=mgrid^.proccessmouse;
    	o.chngmsg(stry(openednum,0,0));
	   	m.chngmsg(stry(numofmines-markednum,0,0));
    end;
  	won := (openednum+foundnum = xgrid*ygrid) and (foundnum = numofmines);
  end;
end.