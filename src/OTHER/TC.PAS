program TImeCode;
uses	dos,general,boxes;
var
	h,m,s,f:counter;
	th,tm,ts,tf:timer;
  i:longint;
  hb,mb,sb,fb:msgbox;
begin
  graphinit(4);
  th.init;
  tm.init;
  ts.init;
  tf.init;
	with hb do begin
  	init('00',swidth div 2-100,shight div 2);
    setmcolor(15,0,1);
    autosize := false;
    set3dmode(inside);
    set3d(on,on);
    display;
  end;
	with mb do begin
  	init('00',swidth div 2- 33,shight div 2);
    setmcolor(15,0,1);
    autosize := false;
    set3dmode(inside);
    set3d(on,on);
    display;
  end;
	with sb do begin
  	init('00',swidth div 2+ 33,shight div 2);
    setmcolor(15,0,1);
    autosize := false;
    set3dmode(inside);
    set3d(on,on);
    display;
  end;
	with fb do begin
  	init('00',swidth div 2+100,shight div 2);
    setmcolor(15,0,1);
    autosize := false;
    set3dmode(inside);
    set3d(on,on);
    display;
  end;
	h.init(0,23,0,1);
	m.init(0,60,0,1);
	s.init(0,60,0,1);
	f.init(0,24,0,1);
  f.setlink(@S);
  s.setlink(@M);
  m.setlink(@H);
  for i := 1 to 1436 do begin
  	s.inc;
  	hb.chngmsg(stry(h.get,2,0));
  	mb.chngmsg(stry(m.get,2,0));
  	sb.chngmsg(stry(s.get,2,0));
  	delay(1000);
  end;
  fb.chngmsg(stry(f.get,2,0));
  for i := 1 to 11000 do begin
  	f.dec;
  	hb.chngmsg(stry(h.get,2,0));
  	mb.chngmsg(stry(m.get,2,0));
  	sb.chngmsg(stry(s.get,2,0));
  	fb.chngmsg(stry(f.get,2,0));
  	delay(4);
  end;
  h.done;
  m.done;
  s.done;
  f.done;
end.


