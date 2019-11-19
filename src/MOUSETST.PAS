program mouse_test;
uses general,mousebx,boxes;
const
	outside    = '     OUTSIDE ME     ';
	inside     = '     INSIDE ME      ';
	pressin    = ' PRESSED INSIDE ME  ';
	pressout   = ' PRESSED OUTSIDE ME ';
	dragmsg    = '    DRAGGING ME     ';

  ratio      = 'RATIO : ';
  incrat     = '+ RATIO INCREASED > ';
  decrat     = '- RATIO DECREASED < ';

var
	mousebox:msgbox;
  ratiobox:msgbox;
	exitbox:msgbox;
	x,y:integer;
	k1,k2,k3:boolean;
  rmsg,msg :string;

begin
	randomize;
	graphinit(4);
	mousebox.init(inside,swidth div 2,shight div 2);
  mousebox.setfont(2,6);
  ratiobox.init(ratio,swidth-150,100);
  ratiobox.setfont(2,6);
  ratiobox.display;
	exitbox.init('PRESS HERE TO EXIT',random(swidth-150)+75,random(shight-50)+25);
	mousebox.display;
	exitbox.display;
  mouse.init;
  mouse.display;
	with mouse do
		repeat
      update;
      msg :='('+stry(x,1,1)+','+stry(y,1,1)+')';
      with ratiobox do begin
      	if isin(x,y) then begin
        	if pressed[1] then setratio(mouseratio+25);
          if pressed[2] then setratio(mouseratio-25);
        end;
	      rmsg := stry(mouseratio,1,1);
      	chngmsg(ratio+rmsg);
      end;
			if mousebox.isin(x,y) then begin
        if drag then begin
        	msg := dragmsg+msg;
          mousebox.move(xmove,ymove,relboxmove);
      	end else if buttompressed[1] then msg := pressin+msg else msg := inside+msg
      end else if buttompressed[1] then msg := pressout+msg else msg := outside+msg;
      mousebox.chngmsg(msg)
		until exitbox.isin(x,y) and pressed[1];
	mousebox.bye;
	exitbox.bye;
end.