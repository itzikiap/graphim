program test;
uses general,boxes,mouse2,app,event;
var
	mouse:themouse;
	thebox:msgbox;
	quitbox:msgbox;
	dragbox:msgbox;
	cmtbox:msgbox;

const
	somepoint:mousepointertype=
	(hotpx:4; hotpy:4;mpointer:
	((-1,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1),
	 (-1,-1,-1, 0,15,15,15, 0,-1,-1,-1),
	 (-1,-1, 0,15, 0, 0, 0,15, 0,-1,-1),
	 (-1,-1,-1, 0,-1,-1, 0,15, 0,-1,-1),
	 (-1,-1,-1,-1,-1,-1, 0,15, 0,-1,-1),
	 (-1,-1,-1,-1,-1, 0,15, 0,-1,-1,-1),
	 (-1,-1,-1,-1, 0,15, 0,-1,-1,-1,-1),
	 (-1,-1,-1,-1,-1, 0,-1,-1,-1,-1,-1),
	 (-1,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1),
	 (-1,-1,-1,-1, 0,15, 0,-1,-1,-1,-1),
	 (-1,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1)));


begin
	graphinit(4);
{	setfillstyle(1,4);
	bar(0,0,swidth,shight);}
	randomize;
  with dragbox do begin
		init('DRAG ME !',swidth div 2,shight div 2-100);
		setmcolor(12,1,2);
		set3D(on,off);
		display;
	end;
	with cmtbox do begin
		init('CHANGE CURSOR',200,350);
		setmcolor(15,8,7);
		set3D(on,off);
		display;
	end;
	with thebox do begin
		init('PRESS ME !',swidth div 2,shight div 2);
		setmcolor(14,13,12);
		set3D(on,off);
		display;
	end;
	with quitbox do begin
		init('EXIT',100,100);
		setmcolor(0,7,8);
		set3D(on,off);
		display;
	end;
	with mouse do begin
		init;
		setmousetype(arrow);
		display;
  	installuserpointer(somepoint);
	end;
	repeat
		mouse.update;
		with mouse do begin
			if buttompressed[1] then begin
				thebox.chngmsg('Pressed !');
				if dragbox.isin(x,y) then begin
					while buttompressed[1] do begin
						dragbox.chngmsg('DRAGGED !');
						update;
            erase;
						dragbox.move(xmove,ymove,relboxmove);
          	display;
					end;
					dragbox.chngmsg('DRAG ME !');
				end else
				if thebox.isin(x,y) then begin
					with thebox do begin
						mouse.erase;
						move(random(swidth-50)+25,random(shight-50)+25,absboxmove);
						mouse.display;
					end;
				end else
				if cmtbox.isin(x,y) then begin
					if pressed[1] then begin
            case mousetype of
					  	box3d : setmousetype(arrow);
						  arrow : setmousetype(wait) ;
						  wait  : setmousetype(cross);
						  cross : setmousetype(mline);
						  mline : setmousetype(user);
              user  : setmousetype(box3d);
          	end;
        	end;
				end else
				if quitbox.isin(x,y) then begin
					with quitbox do begin
          	if pressed[1] then begin
              set3d(on,on);
            	repeat
								mouse.update;
              until released[1];
            end;
        	end;
				end;
			end else begin
				cmtbox.set3d(on,off);
				thebox.chngmsg('PRESS ME !');
			end;
		end;
	until quitbox.is3Dinverse;
	mouse.bye;
	dragbox.bye;
	cmtbox.bye;
	thebox.bye;
	quitbox.bye;
end.