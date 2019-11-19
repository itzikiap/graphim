unit initiali;
{ for use with GRAPHIM only ! }
{ initialize ALL variables depending on : }
{ 1 - GRAPHIM.INI file }
interface
uses general,boxes,graph,inifiles,set_gr,drivers,mousebx,errors;

const
	Version      = 'V2.6dev';
	Itzhak       = 'ITZHAK';
	ARzony       = 'ARZONY';
	Presents     = 'PRESENTS';
	Productions  = 'Production';
	IAP          = 'I.A.P';
	Graphim      = 'GRAPHIM';
	IAPproduct : string = '       I.A.P Productions (c)      ';

procedure init;
procedure intro;
procedure goodbye;

implementation
procedure doinifile(sector:string);
{ READ THE INI FILE AND INITIALIZE VARIABLES }
var error:boolean;
	whanteddriver:string;
	whantedmode:byte;
begin
	whanteddriver := '';
	whantedmode := 0;
	clearvalue := true;
	upcasevalue := true;
	OpenIni('graphim.ini');
	if getinierr = iniFileNotExist then begin
		writeln('File GRAPHIM.INI could not be opened. Possibely doesnt exist');
    error := true;
		exit;
	end;
	error := false;
	if sector <> '' then begin
		gotosector(sector);
		if getinierr = iniSectorNotFound then begin
      writeln('Sector "',sector,'" not found. Using first sector.');
			resetini;
    end;
	end;
	repeat
		if variable='' then value:='' else
		{ NewInterface - To use the event driven interface MAIN GRAPH }
		if variable =	'NEWINTERFACE' then NewInterface := gettruefalse(value) else
		{ DefaultFormula - the formula that will be calculated at start }
		if variable = 'DEFAULTFORMULA' then DefaultFormula:=value else
		{ SpaceSeperator - If false, converts 1 12 3 to 1123. otherwise: 3 }
		if variable =	'SPACESEPERATOR' then SpaceSeperator := gettruefalse(value) else
		{ AutoFit - let the computer calculate the minimum and maximum of Y }
		if variable =	'AUTOFIT' then autofit := gettruefalse(value) else
		{ Fill - let the computer fill the area betwin the graph and tyhe Y axis }
		if variable =	'FILL' then FunctionFill := gettruefalse(value) else
    { FillTwoColors - Fill with 2 different colors }
    if variable =	'FILLTWOCOLORS' then Fill2Colors := gettruefalse(value) else
    { UpColor - The fill color above the X axis }
		if (variable = 'UPCOLOR') and (value<>'') then FillUpColor := vali(value) mod 16 else
    { DownColor - The fill color below the X axis }
		if (variable = 'DOWNCOLOR') and (value<>'') then FillDownColor := vali(value) mod 16 else
		{ MinY - the minimum of Y }
		if (variable = 'MINY') and (value<>'') then DefaultMinY := valr(value) else
		{ MinY - the minimum of Y }
		if (variable = 'MAXY') and (value<>'') then DefaultMaxY := valr(value) else
		{ MinX - the minimum of X }
		if (variable = 'MINX') and (value<>'') then DefaultMinX := valr(value) else
		{ MinX - the minimum of X }
		if (variable = 'MAXX') and (value<>'') then DefaultMaxX := valr(value) else
    { RangesReset - Reset the ranges when you exit the graph }
		if variable =	'RANGESRESET' then RangesReset := gettruefalse(value) else
    { ScreenBackGround - change the back groundof the menu }
		if (variable = 'SCREENBACKGROUND') and (value<>'') then BackGroundColor := vali(value) mod 16 else
		{ MenuSelectedFore - the foregroud color of selected menu }
		if (variable = 'MENUSELECTEDFORE') and (value<>'') then SelectedFore := vali(value) mod 16 else
		{ MenuSelectedBack - the background color of selected menu }
		if (variable = 'MENUSELECTEDBACK') and (value<>'') then SelectedBack := vali(value) mod 16 else
		{ MenuUnselectedFore - the foregroud color of unselected menu }
		if (variable = 'MENUUNSELECTEDFORE') and (value<>'') then UnselectedFore := vali(value) mod 16 else
		{ MenuUnselectedBack - the background color of uselected menu }
		if (variable = 'MENUUNSELECTEDBACK') and (value<>'') then UnselectedBack := vali(value) mod 16 else
		{ MenuAutoSize - Make all menuitems the same size }
		if (variable = 'MENUAUTOSIZE') and (value<>'') then MenuAutoSize := gettruefalse(value) else
		{ Menu3DEffect - make the menues look like 3D }
		if (variable = 'MENU3DEFFECT') then begin
			if value = 'LARGE' 		then Menu3DEffect := ord(LARGE)    else
			if value = 'L_DOUBLE' then Menu3DEffect := ord(L_double) else
			if value = 'L_INSIDE' then Menu3DEffect := ord(L_inside) else
			if value = 'INSIDE' 	then Menu3DEffect := ord(inside) 	 else
			if value = 'DOUBLE' 	then Menu3DEffect := ord(DOUBLE) 	 else
			if value = 'BIG' 			then Menu3DEffect := ord(big) 		 else
			if value = 'SMALL'		then Menu3DEffect := ord(small) 	 else
			if value = 'NONE' 		then Menu3DEffect := ord(none);
		end else
		{ XAxisTickSapace - the space betwin the X axes ticks in pixels }
		if (variable = 'XAXISTICKSPACE') and (value<>'') then  XAxisTickSpace := vali(value) else
		{ YAxisTickSapace - the space betwin the Y axes ticks in pixels }
		if (variable = 'YAXISTICKSPACE') and (value<>'') then  YAxisTickSpace := vali(value) else
		{ GraphLineWidth - the width of the graph line 1-3 }
		if (variable = 'GRAPHLINEWIDTH') and (value<>'') then  LineWidth := vali(value) mod 3 else
		{ GraphLineColor - the color of the graph line }
		if (variable = 'GRAPHLINECOLOR') and (value<>'') then  GraphColor := vali(value) mod 16 else
		{ GraphAxesColor - the color of the graph axes }
		if (variable = 'GRAPHAXESCOLOR') and (value<>'') then  GraphAxes := vali(value) mod 16 else
		{ GraphBackColor - the color of the graph background }
		if (variable = 'GRAPHBACKCOLOR') and (value<>'') then  GraphBack := vali(value) mod 16 else
		{ GraphFillColor - the color of the function fill }
		if (variable = 'GRAPHFILLCOLOR') and (value<>'') then  GraphFill := vali(value) mod 16 else
    { Investigate - active the investigation function }
    if variable =	'GRAPHCOLORIZE' then ToColorize := gettruefalse(value) else
		{ SmallZoomStep - the small step zooming }
		if (variable = 'SMALLZOOMSTEP') and (value<>'') then  SmallZoomStep := vali(value) mod 256 else
		{ LargeZoomStep - the large step zooming }
		if (variable = 'LARGEZOOMSTEP') and (value<>'') then  LargeZoomStep := vali(value) mod 256 else
    { ZoomBoxPreview - See a preview of the graph in ZoomBox mode }
		if (variable = 'ZOOMBOXPREVIEW') and (value<>'') then  ZoomBoxPreview := gettruefalse(value) else
		{ ZBZoomOutRatio - Multiply of the zoom out}
		if (variable = 'ZBZOOMOUTRATIO') and (value<>'') then ZoomOutRatio := vali(value) else
    { FastDrawResolution - the resolution for fast zooming }
		if (variable = 'FASTDRAWRESOLUTION') and (value<>'') then  FastDrawRes := vali(value) mod 256 else
    { AutoHighResolutionDraw - Draws the graph in high resolution quality automaticaly }
    if variable =	'AUTOHIGHRESOLUTIONDRAW' then AutoHighResPlot := gettruefalse(value) else
    { HighResPlotRatio - How many caculations between two pixels in High Res Draw }
		if (variable = 'HIGHRESPLOTRATIO') and (value<>'') then  HighResPlotRatio := vali(value) mod 256 else
    { InvestigationAccuracy - The accuracy of the investigation (more accurate = more time) }
		if (variable = 'INVESTIGATIONACCURACY') and (value<>'') then  InvestigatAccuracy := vali(value) mod 256 else
    { InvestigateMinMax - to show the minimum and maximum dots of the graph when investigating }
    if variable =	'INVESTIGATEMINMAX' then InvShowMinMax := gettruefalse(value) else
    { InvestigateCrossing - To show the crossing with the axes when investigating }
    if variable =	'INVESTIGATECROSSING' then InvShowCrossing := gettruefalse(value) else
    { InvestigateColorize - To colorize the graph when investigating }
    if variable =	'INVESTIGATECOLORIZE' then InvGraphColorize := gettruefalse(value) else
    { SnapMouseToGraph - snaps mouse to be on the graph line }
    if variable =	'SNAPMOUSETOGRAPH' then SnapMouseToGraph := gettruefalse(value) else
    { ShowFormulaInCoordMode - Display the formula box in the mouse coords mode }
    if variable =	'SHOWFORMULAINCOORDMODE' then FormulaInCoordMode := gettruefalse(value) else
    { PanMouseInvert - Invert Mouse when pressing the P button in the main graph }
    if variable =	'PANMOUSEINVERT' then MainPanMouseInvert := gettruefalse(value) else
		{ MouseAutoSelect - mouse over menu automaticaly select it }
		if variable =	'MOUSEAUTOSELECT' then MouseAutoSelect := gettruefalse(value) else
    { MenuFontSize - The size of the menu font }
		if (variable = 'MENUFONTSIZE') and (value<>'') then MenuFontSize := vali(value) mod 16 else
    { MouseZoomFastDraw - Fast Draw on mouse zooming in Main Grpah }
		if (variable = 'MOUSEZOOMFASTDRAW') and (value<>'') then  FastDrawMouseZoom := gettruefalse(value) else
    { DefaultHelpBG    - The default background of the help }
		if (variable = 'DEFAULTHELPBG') and (value<>'') then  DefaultHelpBG := vali(value) mod 16 else
	  { DefaultHelpColor - The Default Text color of the help }
		if (variable = 'DEFAULTHELPCOLOR') and (value<>'') then  DefaultHelpColor := vali(value) mod 16 else
	  { DefaultHelpFont	 - The Defautl font of the help }
		if (variable = 'DEFAULTHELPFONT') and (value<>'') then  DefaultHelpFont := vali(value) else
	  { DefaultHelpSize  - The default size of the help line }
		if (variable = 'DEFAULTHELPSIZE') and (value<>'') then  DefaultHelpSize := vali(value) else
		{ MenuFile - if you have several menu definition and you want to use one of them }
		if (variable = 'MENUFILE') then begin
			if value = '' then value := 'GRAPHIM.MNU';
			MenuFile := value;
		end else
		{ MenuFont - The font used in the menues }
		if (variable = 'MENUFONT') and (value<>'') then begin
			MenuFont := installuserfont(value);
			if GraphResult <> grOk then MenuFont := 6;
		end else
		{ UserDriver - use a driver defined by user }
		if  variable = 'USERDRIVER' then whanteddriver:=value else
		{ UserMode - Use another mode }
		if  variable = 'USERMODE' then whantedmode:=vali(value) else
		{ PathToDrivers - the path of graphics drivers }
		if (variable = 'PATHTODRIVERS') then PTD := copy(value,2,length(value)-2) else
		{----- UnKnown Variable -----}
		begin
			writeln ('UnKnown Variable ',variable,', with parameter : ',value,'.');
			error := true;
		end;
		GetNextParameter;
	until GetIniErr<>0;
	if whanteddriver <> '' then
		if not MakeUserDriver(whanteddriver,whantedmode) then begin
			writeln('Unable to install graphic driver : ',upstr(whanteddriver));
			error := true;
		end;
	delay(25);
	if error then delay(250);
	closeini;
end;


procedure intro;
{  make a nice introduction  }
type
	RGBRec = record
		RedVal, GreenVal, BlueVal: Integer;
	end;

var i,v,l:integer;
	ibx,abx,pbx,vbx,grbx:msgbox;
  dx1,dx2:real;
	icount,acount,pcount,grcount:timer;
	copyright:msgbox;
	crcount:timer;
	colorcycle:timer;
	oldpl:palettetype;
label byebye,doneit;

procedure prepare(var what:msgbox);
begin
	setrgbpalette(1,0,0,0);
	with what do begin
		saveback := false;
		setmcolor(1,0,0);
		setfont(3 ,5);
		setbox(off,on);
		display;
	end;
	i:=0;
end;

function loop(var what:timer;var p:integer;r:byte):boolean;
{ TRUE if key pressed }
begin
	if crcount.cycle(6) then begin
		IAPproduct:=rotate(IAPproduct,1);
		copyright.chngmsg(copy(IAPproduct,7,17));
	end;

  if (p > 0) and (p < 64)then
	  if what.cycle(2) then begin
			setrgbpalette(1,p,p,p);
			inc(p,r);
		end;
  getkeyevent(ev);
	if ev.what <> evnothing then loop := true else loop := false;
end;

begin
	{ background }
	getkeyevent(ev);
	if ev.what <> evnothing then exit;
	getpalette(oldpl);
	i := 0;
	setfillstyle(solidfill,4);
	bar(0,0,swidth,shight);
	setrgbpalette(4,0,0,0);
	setrgbpalette(5,63,63,63);
	crcount.init;
	grcount.init;
	copyright.init(copy(iapproduct,7,17),swidth div 2,20);
	ibx.init(itzhak,swidth div 2-200,70);
	abx.init(arzony,swidth div 2-30,70);
	pbx.init(presents,swidth div 2+170,70);
	grbx.init(graphim,swidth div 2,220);
	vbx.init(version,swidth div 2,320);
	with copyright do begin
		setfont(2,1);
		setmcolor(5,5,0);
{    set3Dmode(inside);}
{    set3D(on,on);}
		display;
    icount.reset;
    i := 1;
    v := -1;
    repeat
      if loop(acount,v,0) then goto byebye;
      if icount.cycle(3) then begin
				inc(i);
				setfont(2,i);
		  	setjustify(center);
	  		settextoffset(0,-12+i);
      end;
		until i=7;
  	setjustify(center);
  	settextoffset(0,-5);
		AutoSize := false;
	end;

	{ ITZHAK }
  prepare(ibx);
	icount.reset;
  i := 1;

	repeat
		if loop(icount,i,3) then goto doneit;
	until i >= 63;
	ibx.setmcolor(5,0,0);

	{ ARZONY }
  prepare(abx);
	acount.reset;
  i := 1;
	repeat
		if loop(acount,i,3) then goto doneit;
	until i >= 63;
	abx.setmcolor(5,0,0);

	{ PRESENTS }
  prepare(pbx);
	pcount.reset;
  i := 1;
	repeat
		if loop(pcount,i,3) then goto doneit;
	until i >= 63;
	pbx.setmcolor(5,0,0);

	{ GRAPIM }
	setrgbpalette(1,0,0,0);
	i := 0;
  l := swidth div 2;
	with grbx do begin
    move(l,cy,absboxmove);
		saveback := false;
		setmcolor(1,0,0);
		setfont(7,14);
		setbox(off,on);
    setjustify(center);
    settextoffset(0,5);
    chngdim(0,0,0,1,on);
		display;
	end;
	with vbx do begin
    move(l,cy,absboxmove);
		saveback := false;
		setmcolor(1,0,0);
		setfont(7,14);
		setbox(off,on);
    setjustify(center);
    settextoffset(0,5);
    chngdim(0,0,0,1,on);
		display;
	end;
	crcount.reset;
	grcount.reset;
	i := 1;
  v := 1;
  dx1 := 1;
  dx2 := 0.94;
	repeat
		if loop(grcount,i,1) then goto doneit;
    grbx.chngdim(0,0,0,round(dx1),on);
    for v := 1 to 1900 do write;
    vbx.chngdim(0,0,0,round(dx1),on);
    for v := 1 to 1900 do write;
		dx1 := dx1+dx2;
    dx2 := dx2 / 1.007;
	until dx2 < 0.1;
	grbx.setmcolor(5,0,0);
	vbx.setmcolor(5,0,0);
	i := 0;
	crcount.reset;
  grcount.reset;
  v := -1;
	repeat
		if loop(icount,v,0) then goto doneit;
		if grcount.cycle(3) then inc(i);
	until i = 30;

{   good   bye      }
  i := 30;
doneit:
	crcount.reset;
	grcount.reset;
  l := -1;
	v := 64-i;
	repeat
		if loop(icount,l,0) then goto byebye;
		if grcount.cycle(2) then begin
			dec(i);
			setrgbpalette(1,i,i,i);
			setrgbpalette(5,i+v,i+v,i+v);
		end;
	until i = 0;
	repeat
		if loop(icount,l,0) then goto byebye;
		if grcount.cycle(2) then begin
			dec(v);
			setrgbpalette(5,v,v,v);
		end;
	until v = 0;
byebye:
	if ibx.initialized = initnum then ibx.bye;
	if icount.initialized then icount.done;
	if abx.initialized = initnum then abx.bye;
	if acount.initialized then acount.done;
	if pbx.initialized = initnum then pbx.bye;
	if pcount.initialized then pcount.done;
	if grbx.initialized = initnum then grbx.bye;
	if vbx.initialized = initnum then vbx.bye;
	if grcount.initialized then grcount.done;
	if copyright.initialized = initnum then copyright.bye;
	if crcount.initialized then crcount.done;
	graphdefaults;
	closegraph;
	general.graphinit(0);
	setfillstyle(solidfill,BackGroundColor);
	if backgroundcolor = 4 then begin
		setrgbpalette(4,0,0,0);
		bar(0,0,swidth,shight);
		i := 0;
		while i < 48 do begin
			inc(i,3);
			setrgbpalette(4,i,0,0);
			delay(1);
		end;
  end;
	general.graphinit(4);
end;

procedure commandline(command:string);
var
	param,valu:string;
	i:byte;

function getnextparam(st:string;i:byte;var param,valu:string):boolean;
var
	lc:set of char;
begin
	if i >= length(st) then begin
		param := '';
		valu := '';
		exit;
	end;
	lc := ['=',' '];
	if st[i] = '"' then begin
		lc := ['=','"'];
		inc(i);
	end;
	if i >= length(st) then begin
		param := '';
		valu := '';
		exit;
	end;
	param := '';
	while not(st[i] in lc) do begin
		param := param+st[i];
		inc(i);
	end;
	inc(i);
	lc :=[];
	if st[i] ='"' then lc := ['"'];
	if '"' in lc then lc := ['"'] else lc := ['"',' '];
	valu := '';
	if i >= length(st) then begin
		param := '';
		valu := '';
		exit;
	end;
	while not(st[i] in lc) do begin
		valu := valu+st[i];
		inc(i);
	end;
end;

function dist(st1,st2:string):boolean;
var i :byte;
	st:string;
begin
	st:='';
	for i := 1 to length(st1) do begin
		st1[i] :=upcase(st1[i]);
		if st1[i] <> ' ' then st := st + st1[i];
	end;
	st:='';
	for i := 1 to length(st2) do begin
		st2[i] :=upcase(st1[i]);
		if st2[i] <> ' ' then st := st + st2[i];
	end;
	if pos(st1,st2) = 1 then dist := true else dist := false;
end;

begin
	i:=1;
	getnextparam(command,i,param,valu);
	while param <> '' do begin
		if dist(param,'FORMULA')     then begin
			defaultformula := valu;
			skipmenu := true;
		end	else
		if dist(param,'MENUFILE')    then menufile := valu else
		if dist(param,'INISETTING')  then doinifile(valu);
	end;
end;


procedure init;
var i,v:longint;

begin
	writeln('GRAHIM (c). programmed by ITZHAK !');
	swidth:=0;
	shight:=0;
	doinifile('');
	if not exist(menufile) then begin
		errfunction := 'INIT_MENU()';
		errmsg := 'Cannot find : '+menufile;
		fatalerror(6);
	end;
	write('Searching for mouse ...');
	if check_mouse then writeln(' Found') else begin
		writeln(' Not Found');
    delay(123);
  end;
	graphinit(BackGroundColor);
	mouse.init;
end;

procedure goodbye;
begin
	mouse.bye;
	closegraph;
	writeln('Thank you for trying GRAPHIM.');
	writeln;
	writeln('GOOD BYE, AND HAVE A NICE DAY.');
end;

end.
{ paste it in INTRO }
{	if maxcolor > 16 then begin
		v := ((shight+1) div 240);
		for i := 1 to 256 -16 do begin
			if i * v < shight div 2 then setrgbpalette(i+16,      i div v,      i div  v,      i div v)
															else setrgbpalette(i+16,252 - i div v,252 - i div  v,252 - i div v);
			setfillstyle(solidfill,i+16);
			bar(0,i*v,swidth,i*v+v);
		end;
		l := 1;
		while true do begin
			for i := 1 to 255 -16 do begin
				setpalette(i+16,((i+l) mod 240) +16);
				setfillstyle(solidfill,((i+l) mod 240)+16);
				bar(0,i*v,swidth,i*v+v);
			end;
			inc(l);
			if l=240 then l := 0
		end;
	end;   }