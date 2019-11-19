program test;
uses graph,general,boxes,mousebx;
var
	mouse:themouse;
	thebox:msgbox;
	quitbox:msgbox;
	dragbox:msgbox;
	cmtbox:msgbox;
begin
	graphinit(4);
	setfillstyle(1,4);
	bar(0,0,swidth,shight);
	randomize;
	with dragbox do begin
		init('DRAG ME !',swidth div 2,shight div 2-100);
		setmcolor(12,1,2);
		is3d := true;
		display;
	end;
	with cmtbox do begin
		init('CHANGE CURSOR',100,150);
		setmcolor(15,8,7);
		is3d := true;
		display;
	end;
	with thebox do begin
		init('PRESS ME !',swidth div 2,shight div 2);
		setmcolor(14,13,12);
		is3d := true;
		display;
	end;
	with quitbox do begin
		init('EXIT',100,100);
		setmcolor(0,7,8);
		is3D := true;
		display;
	end;
	with mouse do begin
		init;
		setmousetype(arrow);
		display;
	end;
	repeat
		mouse.update;
		with mouse do begin
			if buttompressed[1] then begin
				thebox.chngmsg('Pressed !');
				if dragbox.isin(x,y) then begin
					while buttompressed[1] do begin
						dragbox.chngmsg('DRAGGED !');
						erase;
						update;
						while drag do begin
							update;
							dragbox.move(x,y,absboxmove);
						end;
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
					if not cmtbox.is3Dinverse then cmtbox.set3d(on,on)
					else setmousetype(succ(mousetype));
				end else
				if quitbox.isin(x,y) then begin
					with quitbox do cbxoptions(bxdrawbox+bx3D+ bx3dinverse);
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