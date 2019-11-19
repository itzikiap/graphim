unit save_gr;
{ by I.A.P   }
{ 23-6-2000  }
{ This unit SAVES a formula with all the DATA needed to RESTORE it }
{ 23-11-2002 }
{ Added more things to the save list }
interface
uses set_gr,general,boxes,exbox,mousebx,inifiles,initiali,dos;
const
  Extention:string[3]='GRP';
	default_file_name:string[8]='GRAPH01';

  sv_Formula      :string='X ^ 2 ';
  sv_MinX         :extended=-20;
	sv_MaxX         :extended=20;
	sv_MinY 				:extended=-20;
	sv_MaxY 				:extended=20;
  sv_CompFormula  :String='X ^ 2 ';
  sv_CompLink 		:boolean=false;
  sv_FunctionFill :boolean=False;
  sv_Fill2Color 	:boolean=True;
  sv_LineWidth  	:byte=1;
  sv_Colorize 		:boolean=false;
  sv_Axes 				:boolean=True;
  sv_AxesText     :boolean=True;


{ SAVESETTINGS the parameters needed to draw the graph }
procedure SaveSettings(filename:pathstr;description:string);

{ RESTORESETTINGS saved parameters from a file }
function RestoreSettings(filename:pathstr;Description:string):boolean; { return FALSE if failed }

{ DEFAULTS restore parameters to defaults }
procedure Defaults;

{ UPDATE updates the settings FROM the SET_GR }
{procedure Update;}

{ DOWNDATE updates the settings TO the SET_GR }
{procedure DownDate;}

implementation
{========================}
{     SAVE SETTINGS      }
{========================}
procedure saveSettings;
var
	savefile:text;
	s : pathstr;
	y,m,d,w:word;
begin
  { Opens the file }
	assign(savefile,filename);
  s := Fsearch(filename,'');
  if s <> '' then append(savefile) else rewrite(savefile);
  { Writing setting }
  getdate(y,m,d,w);
  writeln(savefile,'[',upstr(description),']');
  writeln(savefile,'; Arzony GRAPHIM '+version+' programmed by Itzhak Arzony.');
  writeln(savefile,'; Saved on ',d,'-',m,'-',y);
  writeln(savefile,';---------------------------');
  writeln(savefile,'Formula = '   	,sv_Formula);
  writeln(savefile,'MinX = '  		  ,stry(sv_MinX,0,5));
  writeln(savefile,'MaxX = '   			,stry(sv_MaxX,0,5));
  writeln(savefile,'MinY = '   			,stry(sv_MinY,0,5));
  writeln(savefile,'MaxY = '   			,stry(sv_MaxY,0,5));
  writeln(savefile,'FunctionFill = ',sv_FunctionFill);
  writeln(savefile,'2ColorFill = '	,sv_Fill2Color);
  writeln(savefile,'Colorize = '		,sv_colorize);
  writeln(savefile,'Axes = '				,sv_Axes);
  writeln(savefile,'AxesLabels = '	,sv_AxesText);
  writeln(savefile,'LineWidth = ',stry(sv_LineWidth,0,0));
  if sv_compLink then begin
  	writeln(savefile,'CompareFormula = ',sv_CompFormula);
  	writeln(savefile,'CompareLink = '   ,sv_CompLink);
  end;
  writeln(savefile,'OK = OK');
  writeln(savefile,';======================================================');
  writeln(savefile);
	{ Close File }
  close(savefile);
end;

function RestoreSettings;
begin
  defaults;
  clearvalue := true;
	upcasevalue := true;
	OpenIni(FileName);
	if getinierr = iniFileNotExist then begin
    RestoreSettings := false;
		exit;
	end;
	gotosector(Description);
	if getinierr = iniSectorNotFound then begin
   	RestoreSettings := false;
    exit;
  end;
	repeat
		if variable='' then value:='' else
		if variable = 'FORMULA'       then sv_Formula:=value else
		if variable = 'MINX'          then sv_MinX:=valr(value) else
		if variable = 'MAXX'          then sv_MaxX:=valr(value) else
		if variable = 'MINY'          then sv_MinY:=valr(value) else
		if variable = 'MAXY'          then sv_MaxY:=valr(value) else
    if variable = 'FUNCTIONFILL'  then sv_FunctionFill:=gettruefalse(value) else
    if variable = '2COLORFILL'    then sv_Fill2Color:=gettruefalse(value) else
    if variable = 'COLORIZE'      then sv_Colorize:=gettruefalse(value) else
    if variable = 'AXES'          then sv_axes:=gettruefalse(value) else
    if variable = 'AXESLABELS'    then sv_axestext:=gettruefalse(value) else
    if variable = 'COMPARELINK'   then sv_CompLink:=gettruefalse(value) else
		if variable = 'COMPAREFORMULA'then sv_CompFormula:=value else
    if variable = 'LINEWIDTH'     then sv_LineWidth:=ValI(value);
		GetNextParameter;
	until GetIniErr<>0;
  RestoreSettings:=true;
	CloseIni;
end;

procedure defaults;
begin
  sv_MinX         :=-20;
	sv_MaxX         :=20;
	sv_MinY 				:=-20;
	sv_MaxY 				:=20;
  sv_CompFormula  :='X ^ 2 ';
  sv_CompLink 		:=false;
  sv_FunctionFill :=False;
  sv_Fill2Color 	:=True;
  sv_LineWidth  	:=1;
  sv_Colorize 		:=false;
  sv_Axes 				:=True;
  sv_AxesText     :=True;
end;

end.