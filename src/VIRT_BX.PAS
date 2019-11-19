unit Virt_Bx;
{---------------------------------------------------}
{ Programmed by Itzhak Arzoni -I.A.P                }
{ A box with virtual space capabilities             }
{---------------------------------------------------}
interface
uses boxes;

type
  VirtBox=object(box) { draw the graph on the screen }
		minx,maxx:real;    { the range of X }
		miny,maxy:real;    { the range of Y }
		xstep,ystep:real;   { the range from one pixel to the other }
    aspect:extended;
    keepaspect:boolean;
    clipping:boolean; { Clip the out of range? }
		public
		constructor init(sx1,sy1,sx2,sy2:integer); { initialize the virtual space, and the varibles }
		function XtoSX(x:extended):integer;  {}
		function YtoSY(y:extended):integer;  { converts from axes to screen }
		function SXtoX(sx:integer):real;     { and vice versa }
		function SYtoY(sy:integer):real;     {}

		procedure chngDim(nx1,ny1,nx2,ny2:integer;iscenter:boolean); { changing the dimentions of the box }
		procedure assign(nminx,nmaxx,nminy,nmaxy:extended); virtual; { assign new X and Y - 0 is unchanged }
		procedure zoom(Xfactor,Yfactor:extended); { zoom in }
		procedure abszoom(Xfactor,Yfactor:integer); { zoom in - pixel steps }
		procedure scroll(movx,movy:extended); { scroll the graph (without drawing) moves are relative }
		procedure absscroll(movx,movy:integer); { scroll the graph in pixels (without drawing) moves are relative }
		destructor bye; virtual;
	end;

implementation
(********************************)
(* Virtual graph methods        *)
(********************************)

constructor virtbox.init;
{ put zeros in all the varibles }
var
	i:integer;
begin
  clipping     := false;
	box.init(sx1,sy1,sx2,sy2,cornerbox);
	assign(0,0,20,20);
	setmcolor(14,1);
	set3D(true,true);
	keepaspect := true;
end;

function virtbox.XtoSX(x:extended):integer;
{ input X value from axes - output X value of screen }
var tmax,tmid,tmin:real; { temp axes boundries }
	tsmax,tsmid,tsmin:integer; { temp screen boundries }
	ts:real;
	found:boolean;
begin
	found:=false;
	if xstep=0 then xstep:=(x2-x1)/(maxx-minx); { calculate step size }
	tmax:=maxx;
	tmin:=minx;
	tsmax:=x2;
	tsmin:=x1;
	ts := xstep / 2;
	if x < tmin + ts then begin
		found := true;
		tsmid := tsmin;
	end;
	if x > tmax - ts then begin
		found := true;
		tsmid := tsmax;
	end;
	while not found do begin
		tmid:=(tmax+tmin)/2; { half of min,max }
		tsmid:=(tsmax+tsmin) div 2; { half of screen min,max }
		if x > tmid - ts then begin { if bigger }
			tmin:=tmid;
			tsmin:=tsmid;
		end else if x < tmid + ts then begin;
			tmax:=tmid;
			tsmax:=tsmid;
		end else found:=true;
		if tmax <= tmin - ts + xstep then begin
			tmid:=(tmax+tmin)/2;
			tsmid:=(tsmax+tsmin) div 2;
			found:=true;
		end;
	end;
	XtoSX:=tsmid;
end;

function VirtBox.YtoSY(Y:extended):integer;
{ input Y value from axes - output Y value of screen }
var tmax,tmid,tmin:real;
	tsmax,tsmid,tsmin:integer;
	found:boolean;
	yts:real;
begin
	found:=false;
{	if ystep=0 then }ystep:=(maxy-miny)/(y2-y1);
	tmax:=maxy;
	tmin:=miny;
	tsmax:=y2;
	tsmin:=y1;
 	yts:=ystep / 2;
	if y>tmax-yts then begin
		found:=true;
		tsmid:=tsmax;
	end;
	if y<tmin-yts then begin
		found := true;
		tsmid:=tsmin;
	end;
	while not found do begin
		tmid:=(tmax+tmin)/2;
		tsmid:=(tsmax+tsmin) div 2;
		if y > tmid - yts then begin
			tmin:=tmid;
			tsmin:=tsmid;
		end else if y < tmid + yts then begin;
			tmax:=tmid;
			tsmax:=tsmid;
		end else found:=true;
		if tmax-ystep <= tmin - yts + xstep then begin
			tmid:=(tmax+tmin)/2;
			tsmid:=(tsmax+tsmin) div 2;
			found:=true;
		end;
	end;
	YtoSY:=y2-tsmid+y1;
end;

function VirtBox.SXtoX(sx:integer):real;
{ input X of the screen - output X of the axes }
begin
	if xstep=0 then xstep:=(x2-x1)/(maxx-minx);
	SXtoX := minx+xstep*(sx-x1);
end;

function VirtBox.SYtoY(sY:integer):real;
{ input X of the screen - output X of the axes }
begin
	if ystep=0 then ystep:=(y2-y1)/(maxy-miny);
	SYtoY := maxy-ystep*(sy-y1); { need to revers the convertion, because virtual axes are inverted }
end;

procedure VirtBox.assign;
{ assign new values to X and Y }
var temp:extended;
	old:boolean;
begin
	if nminy <> 0 then miny := nminy;
	if nmaxy <> 0 then maxy := nmaxy;
	if miny > maxy then begin
		temp := miny;
		miny := maxy;
		maxy := temp;
	end else if miny = maxy then begin
{		miny := defaultminy;}
		maxy := miny+1;
	end;
	ystep:=(maxy-miny)/(y2-y1);
	if nminx <> 0 then minx := nminx;
	if nmaxx <> 0 then maxx := nmaxx;
	if minx > maxx then begin
		temp := minx;
		minx := maxx;
		maxx := temp;
	end else if minx = maxx then begin
{		minx := defaultminx;}
		maxx := minx+1;
	end;
	xstep:=(maxx-minx)/(x2-x1);
  aspect := xstep/ystep;
	if displayed then display;
end;


procedure VirtBox.zoom;
{ zoom in or out - minus meens out }
begin
  if keepaspect then yfactor := xfactor*aspect;
	assign(minx+Xfactor,maxx-xfactor,miny+yfactor,maxy-yfactor);
end;

procedure VirtBox.abszoom;
{ zoom in or out in pixels steps - minus meens out }
begin
  if keepaspect then yfactor := round(xfactor*aspect);
	assign(minx+xstep*Xfactor,maxx-xstep*xfactor,miny+ystep*yfactor,maxy-ystep*yfactor);
end;

procedure VirtBox.scroll;
{ scroll the graph - doest redraw or calculate it }
begin
	assign(minx+movx,maxx+movx,miny+movy,maxy+movy);
end;

procedure VirtBox.absscroll;
{ move the graph - doest redraw or calculate it }
begin
	assign(minx+xstep*movx,maxx+xstep*movx,miny+ystep*movy,maxy+ystep*movy);
end;

procedure virtbox.chngDim(nx1,ny1,nx2,ny2:integer;iscenter:boolean); { changing the dimention of the box }
begin
	box.chngDim(nx1,ny1,nx2,ny2,iscenter); { changing the dim }
	ystep:=(maxy-miny)/(y2-y1);
	xstep:=(maxx-minx)/(x2-x1);
end;

destructor Virtbox.bye;
begin
end;

end.