program extended_boxes_tester;
uses general,exbox,mousebx;
var	progline:progress;
begin
	graphinit(14);
	mouse.init;
	mouse.display;
	progline.init(300,90,600,120,0,1200);
	progline.display;
	repeat
		with mouse do begin
			update;
			if progline.isin(x,y) then begin
				while buttompressed[1] do begin
					erase;
					update;
					progline.move(xmove,ymove,true);
					display;
				end;
				if buttompressed[2] then begin
					erase;
					progline.incby(1);
					display;
				end;
				if buttompressed[3] then begin
					erase;
					progline.decby(1);
					display;
				end;
			end;
		end;
	until progline.get = progline.limit(true);
	progline.bye;
	mouse.bye;
end.