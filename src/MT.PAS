uses mousebx,general,boxes,exbox;
var
	j,k:comp;
  i :byte;
  l:progress;
  r:real;
	m:timer;
  g:msgbox;
  f:msgbox;
  e:boolean;
  fn:array [1..4] of msgbox;
  mn:array [1..4] of msgbox;
begin
	graphinit(4);
  mouse.init;
  m.init;
  m.resetms := 100;
  e := false;
  with g do begin
  	init('PRESS TO START',swidth div 2,shight div 2-70);
  	setmcolor(12,6,3);
  	set3d(on,off);
  	display;
  end;
  with f do begin
  	init('0000 ',swidth div 2,shight div 2-10);
  	setmcolor(14,6,9);
  	set3d(on,on);
  	set3dmode(inside);
  	autosize := true;
  	saveback := true;
  	display;
  end;
  for i := 1 to 3 do begin
  	with fn[i] do begin
			init('0000 ',swidth div 2+(i-2)*130,shight div 2+40);
	  	setmcolor(12,6,1);
		 	set3d(on,on);
 	 		set3dmode(inside);
 	 		autosize := true;
  		saveback := true;
  		display;
    end;
  	with mn[i] do begin
			init('0000 ',swidth div 2+(i-2)*130,shight div 2+90);
	  	setmcolor(9,6,4);
		 	set3d(on,on);
 	 		set3dmode(inside);
 	 		autosize := true;
  		saveback := true;
  		display;
    end;
  end;

  l.init(swidth div 2-120,shight div 2+165,swidth div 2+120,shight div 2+175,1,65535);
  l.display;
  mouse.display;
  with mouse do
	  repeat
  		update;
  	until released[1] and (g.isin(x,y) or f.isin(x,y));
  g.chngmsg('RUNNING...');
  m.reset;
  repeat
		mouse.update;
    if i mod 1 = 0 then begin
      j := m.get;
      k := j / 100;
			f.chngmsg(stry(j,0,0));
      fn[1].chngmsg(stry(k / 60,0,0));
      fn[2].chngmsg(stry(k ,0,0));
      fn[3].chngmsg(stry(m.firsttime,0,0));
      mn[1].chngmsg(stry(m.minut,0,0));
      mn[2].chngmsg(stry(m.second,0,0));
      mn[3].chngmsg(stry(m.sec100,0,0));
	    l.incby(1);
    end;
		if mouse.pressed[1] and g.isin(mouse.x,mouse.y) then e := true;
  until e;
	graphend;
end.



