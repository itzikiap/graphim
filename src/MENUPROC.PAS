unit menuproc;
{       PROGRAMMED BY ITZHAK (c)               	    		    }
{       some procedures for input/output       	  	 	 	    }
{       for use in GRAPHIM only !              	    		    }
{       ---------------------------------------------		    }
{         procedure GetAutoFit - ask if user want to        }
{						active autofit or not.                          }
{         procedure GetFunctionFill - ask if user want to   }
{						active Function Fill.                           }
{         procedure GetInvestigate - ask if user want to    }
{           investigate the graph                           }
{					procedure DoTheHelp - soppose to do the help      }
{						but it doesnt work                              }
{					procedure GetLineWidth - set the width of the     }
{						graph line                                      }
{				 	procedure SetLowZoom - set the small zoom step    }
{				 	procedure SetHighZoom - set the large zoom step   }
{       ---------------------------------------------       }
interface
uses boxes,general,menugr,drivers,graph,set_gr,bxdialog,help;

Function GetAutoFit:boolean;
procedure GetFunctionFill;
procedure GetInvestigate;
procedure GetRangesReset;
procedure doTheHelp(helpnum:word);
procedure getLineWidth;
procedure setlowzoom;
procedure sethighzoom;

implementation
{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
{*           GENERAL    PROCEDURES           *}
{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
function GetAutoFit;
{         is activate autofit             }
begin
	GetAutoFit := getyesno('Active AutoFit ?','YES','NO',7,6);
end;

procedure GetFunctionFill;
{ To fill the function ? }
begin
	FunctionFill := getyesno('Active Function Fill ?','YES','NO',7,5);
end;

procedure GetInvestigate;
{ Colorize graph according to state }
begin
	ToColorize := getyesno('Colorize graph ?','YES','NO',7,6);
end;

procedure GetRangesReset;
{ Reset the ranges ? }
begin
	RangesReset := getyesno('Reset ranges after exiting the graph?','YES','NO',7,3);
end;

procedure doTheHelp;
{ make help }
var thehelp:helpbox;
begin
	with thehelp do begin
		init('graphim.hlp',helpnum);
		if good then userinterface;
		done;
	end;
end;

procedure getLineWidth;
{ the graph line width }
var
	ask:MsgBox;
	TheWidth:array[1..3] of MenuItem;
	linedemo:msgbox;
	Ok,Abort:boolean;
	selected:byte;
	i:integer;
begin
	with ask do begin
		init('Select line width',swidth div 2,shight div 2 - 50);
		set3D(on,off);
		setbox(on,on);
		setfont(8,5);
		setmcolor(12,4,5);
		display;
	end;
	for i := 1 to 3 do with thewidth[i] do begin
		init(stry(i,1,0),swidth div 2 + 70*(i-2),ask.y2+40,i,0,'You selcted line width '+stry(i,1,0),1);
		unselect;
		txtX:=0;
		txtY:=0;
		theWidth[i].display;
	end;
	with linedemo do begin
		init('                 ',swidth div 2,thewidth[i].y2 + 70);
		setmcolor(4,backgroundcolor xor 3,2);
		display;
	end;
	ok := false;
	abort := false;
	selected:=linewidth;
	TheWidth[linewidth].select;
	setcolor(linedemo.color);
	if selected=1 then setlinestyle(0,0,1) else
	if selected>=2 then setlinestyle(0,0,3);
	with lineDemo do begin
		if selected <= 2 then line(x1+2,cy,x2-2,cy) else
		if selected=3 then begin
			line(x1+2,cy-1,x2-2,cy-1);
			line(x1+2,cy,x2-2,cy);
		end;
	end;
	repeat
		getkeyevent(ev);
		if ev.what = evkeydown then begin
			case ev.keycode of
				kbRight,kbTab: begin
						TheWidth[selected].unselect;
						inc(selected);
						if selected > 3 then selected := 1;
						TheWidth[selected].select;
					end;
				kbLeft: begin
						TheWidth[selected].unselect;
						dec(selected);
						if selected < 1 then selected := 3;
						TheWidth[selected].select;
					end;
				kbf1:dothehelp(15);
				kbEnter:ok:=true;
				kbEsc:abort:=true;
			end;
			LineDemo.display;
			setcolor(linedemo.color);
			if selected=1 then setlinestyle(0,0,1) else
			if selected>=2 then setlinestyle(0,0,3);
			with lineDemo do
				if selected <= 2 then line(x1+2,y1+hight div 2,x2-2,y1+hight div 2) else
				if selected=3 then begin
					line(x1+2,y1+hight div 2-1,x2-2,y1+hight div 2-1);
					line(x1+2,y1+hight div 2,x2-2,y1+hight div 2);
				end;
		end;
	until ok or abort;
	if ok then LineWidth:=selected;
	for i := 1 to 3 do TheWidth[i].bye;
	LineDemo.bye;
	ask.bye;
end;

procedure setlowzoom;
var
	lowzoom:counter;
	zoomdisp:msgbox;
	ev:Tevent;
	e,a:boolean;
begin
	lowzoom.init(0,LargeZoomStep,smallZoomStep,2);
	zoomdisp.init('SmallZoomStep = '+stry(lowzoom.get,0,0),swidth div 2,shight div 2);
	zoomdisp.display;
	e:=false;
	a:=false;
	repeat
		getkeyevent(ev);
		if ev.what <> evnothing then begin
			with lowzoom do
			case ev.keycode of
				kbup:inc;
				kbdown:dec;
				kbpgup:incby(10);
				kbpgdn:decby(10);
				kbhome:restore;
				kbenter:e:=true;
				kbesc:a:=true;
			end;
			zoomdisp.chngmsg('SmallZoomStep = '+stry(lowzoom.get,0,0));
		end;
	until e or a;
	if a then lowzoom.restore;
	SmallZoomStep:=lowzoom.get;
	zoomdisp.bye;
end;

procedure sethighzoom;
var
	highzoom:counter;
	zoomdisp:msgbox;
	ev:Tevent;
	e,a:boolean;
begin
	highzoom.init(smallZoomStep,0,LargeZoomStep,2);
	zoomdisp.init('LargeZoomStep = '+stry(highzoom.get,0,0),swidth div 2,shight div 2);
	zoomdisp.display;
	e:=false;
	a:=false;
	repeat
		getkeyevent(ev);
		if ev.what <> evnothing then begin
			with highzoom do
			case ev.keycode of
				kbup:inc;
				kbdown:dec;
				kbpgup:incby(10);
				kbpgdn:decby(10);
				kbhome:restore;
				kbenter:e:=true;
				kbesc:a:=true;
			end;
			zoomdisp.chngmsg('LargeZoomStep = '+stry(highzoom.get,0,0));
		end;
	until e or a;
	if a then highzoom.restore;
	largeZoomStep:=highzoom.get;
	zoomdisp.bye;
end;

end.