unit Bdlg;
{ some simple dialogs for builder }
interface
uses boxes,general,drivers;

procedure chngfont(var vf,vs:byte);

implementation
procedure chngfont(var vf,vs:byte);
{ Display the font and size       }
{ change them with the arrow keys }
var size:msgbox;
	cfont:counter;
	csize:counter;
	e:boolean;
begin
	e:=false;
	cfont.init(1,18,vf,1);
	csize.init(1,15,vs,1);
	with size do begin
		init('font: 00 size: 00',swidth div 2 , shight div 2);
 		setjustify(center);
    setmcolor(14,4,7);
    set3Dmode(inside);
    set3D(on,on);
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
        kbenter:e := true;
				kbesc  :begin
					e:=true;
          csize.reset;
          cfont.reset;
        end;
			end;
			size.setfont(cfont.get,csize.get);
			with size do
				chngmsg('font: '+stry(fontname,0,0)+' size: '+stry(fontsize,0,0));
		end;
	until e;
	size.erase;
  vf := cfont.get;
  vs := csize.get;
	csize.done;
	cfont.done;
end;

end.