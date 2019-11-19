program text_width_and_hight_tester;
uses boxes,general,drivers,savepic;
var size:msgbox;
	fonts:msgbox;
	cfont:counter;
	csize:counter;
	e:boolean;
begin
	e:=false;
	graphinit(2);
	cfont.init(1,18,1,1);
	csize.init(1,15,4,1);
	with size do begin
		init('font: 00 size: 00',swidth div 2 , shight div 2);
 		setjustify(center);
    setmcolor(14,4,7);
    set3D(on,off);
  	display;
		setfont(cfont.get,csize.get);
		chngmsg('font: '+stry(fontname,0,0)+' size: '+stry(fontsize,0,0));
  end;
	repeat
		getkeyevent(ev);
		if ev.what <> evnothing then begin
			case ev.keycode of
				kbup   :cfont.inc;
				kbdown :cfont.dec;
				kbleft :csize.dec;
				kbright:csize.inc;
				kbesc  :e:=true;
			end;
			size.setfont(cfont.get,csize.get);
			with size do
				chngmsg('font: '+stry(fontname,0,0)+' size: '+stry(fontsize,0,0));
		end;
	until e;
{  with size do savebmp(x1,y1,x2,y2,'ooo');
  savebmp(0,0,swidth,shight,'222');}
	size.erase;
	csize.done;
	cfont.done;
{  loadbmp(0,0,'222');
  loadbmp(1,1,'ooo');}
  readln;
  size.bye;
  graphend;
end.

