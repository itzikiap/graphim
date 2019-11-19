program d3D;
uses graph,general,boxes,virt_bx,mousebx,stack3D;
type
	dvbox=object(virtbox)
    XaxisTickSpace,YaxisTickSpace:byte;
    no_axes:boolean;
    axes_text:boolean;
    constructor init(nx1,ny1,nx2,ny2:integer);
    procedure draw_axes;
    procedure display; virtual;
    destructor bye; virtual;
  end;

  bxvirt3D=object(dvbox)
    poly:s;
		Perspective:real; { 0 - off. the larger, the more perspective }
    constructor init; { fullscreen. -20 to 20 in both axes }
    procedure insertP(px1,py1,pz1,px2,py2,pz2:real;c:byte);
    procedure PtoXY(P:point;var x,y:real);
    procedure draw_axes;
    procedure display; virtual;
    destructor bye; virtual;
  end;

var
	s:vline;
(*******************************)
(*     dvbox Procedures        *)
(*******************************)
constructor dvbox.init;
begin
	virtbox.init(nx1,ny1,nx2,ny2);
  XaxisTickSpace:= 60;
  YaxisTickSpace:= 40;
  axes_text := true;
  assign(-20,19,-20,19);
end;

procedure dvbox.display;
begin
	box.display;
  draw_axes;
end;

procedure dvbox.draw_axes;
{ draws the axes on the screen }
var i:integer;
	temp:integer;
	SXstep,SYstep:integer;

begin
  if no_axes then exit;
{	setviewport(vx1,vy1,vx2,xy2,true);}
	setlinestyle(0,0,1);
  setcolor(15);
	SXstep:=XaxisTickSpace;
	SYstep:=YaxisTickSpace;
	if axes_text then settextstyle(2,0,(x2-x1) div 160 + 1);
	{ the Y axis }
	if minx > xstep*2 then begin
		i:=y1;
		if axes_text then settextjustify(lefttext,centertext);
		while i <= y2 do begin
			line(x1+1,y1+y2-i,x1+2,y1+y2-i);
			if axes_text then outtextxy(x1+3,y1+y2-i,stry(SYtoY(i),2,2));
			inc(i,SYstep);
		end;
	end else if maxx < xstep*2 then begin
		if axes_text then settextjustify(righttext,centertext);
		i:=y1;
		while i <= y2 do begin
			line(x2-2,y1+y2-i,x2,y1+y2-i);
			if axes_text then outtextxy(x2,y1+y2-i,stry(SYtoY(i),2,2));
			inc(i,SYstep);
		end;
	end else begin
		temp:=XtoSX(0);
		line(temp,y1,temp,y2);
		if axes_text then settextjustify(righttext,centertext);
		i:=y1;
		while i <= y2 do begin
			line(temp-2,y1+y2-i,temp+2,y1+y2-i);
			if axes_text then outtextxy(temp,y1+y2-i,stry(SYtoY(i),0,2));
			inc(i,SYstep);
		end;
	end;
	{ the X axis }
	if maxy < 0+ystep*2 then begin
		i:=x1;
		if axes_text then settextjustify(centertext,toptext);
		while i <= x2 do begin
			line(i,y1+2,i,y1);
			if axes_text then outtextxy(i,y1+3,stry(SXtoX(i),2,2));
			inc(i,SXstep);
		end;
	end else if miny > 0-ystep*2 then begin
		i:=x1;
		if axes_text then settextjustify(centertext,bottomtext);
		while i <= x2 do begin
			line(i,y2-2,i,y2);
			if axes_text then outtextxy(i,y2-3,stry(SXtoX(i),2,2));
			inc(i,SXstep);
		end;
	end else begin
		temp:=YtoSY(0);
		line(x1+1,temp,x2,temp);
		if axes_text then settextjustify(centertext,toptext);
		i:=x1+1;
		while i <= x2 do begin
			line(i-1,temp-3,i-1,temp+3);
			if axes_text then outtextxy(i-1,temp+1,stry(SXtoX(i),2,2));
			inc(i,SXstep);
		end;
	end;
	setviewport(0,0,swidth,shight,true);
end;

destructor dvbox.bye;
begin
end;

{*******************************}
{*   3D box Procedure          *}
{*******************************}
constructor bxvirt3D.init;
begin
	inherited init(0,0,swidth,shight);
  poly.init;
end;

procedure bxvirt3D.insertp;
var
	s:vline;
begin
	s.p1.x := px1;
	s.p1.y := py1;
	s.p1.z := pz1;
	s.p2.x := px2;
	s.p2.y := py2;
	s.p2.z := pz2;
  s.c := c;
  poly.push(s);
end;

procedure bxvirt3D.PtoXY;
begin






var
	bx:circbx;
  k:boolean;

begin
	graphinit(1);
  mouse.init;
  with bx do begin
  	init(0,0,swidth,shight);
    set3Dmode(L_inside);
    display;
  end;
  k := false;
	repeat
  	mouse.update;
    with mouse do begin
      if changed then begin
	    	if pressed[2] then k := true;
        if pressed[3] then bx.keepaspect := not bx.keepaspect;
  	    if drag then with bx do abszoom(-xmove,ymove) else bx.absscroll(-xmove,ymove);
    	end;
    end;
  until k;
end.