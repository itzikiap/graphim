program calculator;
uses app,boxes,exbox,bmenu,mousebx,calccmd,cldef,bituy,general,proc;



procedure initmenus;
var
	b:border;
begin
	ib(b,0,0,210,200);
	initmenu2(@calc,150,150,1,0,calcdef,b);
  ib(b,0,0,0,0);
	initmenu2(@menub,0,15,1,0,menudef,b);
  calc.start;
  menub.start;
	app1.insert(evntmouse,mcalc,100,normal);
	app1.insert(evntmouse,mmenu,101,normal);
end;

procedure installcmd;
begin
	app1.insert(evntcmd,pequel,clcalc,normal);
	app1.insert(evntcmd,pon,clon,normal);
	app1.insert(evntcmd,pclr,clclr,normal);

	app1.insert(evntcmd,pchar,clnum+0,normal);
	app1.insert(evntcmd,pchar,clnum+1,normal);
	app1.insert(evntcmd,pchar,clnum+2,normal);
	app1.insert(evntcmd,pchar,clnum+3,normal);
	app1.insert(evntcmd,pchar,clnum+4,normal);
	app1.insert(evntcmd,pchar,clnum+5,normal);
	app1.insert(evntcmd,pchar,clnum+6,normal);
	app1.insert(evntcmd,pchar,clnum+7,normal);
	app1.insert(evntcmd,pchar,clnum+8,normal);
	app1.insert(evntcmd,pchar,clnum+9,normal);
	app1.insert(evntcmd,pchar,clplus,normal);
	app1.insert(evntcmd,pchar,clminus,normal);
	app1.insert(evntcmd,pchar,cldiv,normal);
	app1.insert(evntcmd,pchar,clmul,normal);
	app1.insert(evntcmd,pchar,clpower,normal);
end;


begin
  graphinit(7);
  line.init('0000000000',150,50);
  line.setfont(2,7);
  line.setjustify(left);
  line.set3d(on,on);
  line.set3Dmode(inside);
  line.setmcolor(15,0,7);
  line.autosize := false;
  line.chngmsg('');
  line.display;
  mouse.init;
  app1.init;
  initmenus;
  installcmd;
  app1.run;
end.

