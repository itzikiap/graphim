unit set_gr;
{ all the general setting for GRAPHIM }
interface
uses bmenu;
const
{ GRAPHIM.INI changeble variables and defaults }
  ActiveFormula     :string		='X ^ 2 ';
	Defaultformula		:string		='X ^ 2 ';  	{ the default formula }
  NewInterface      :Boolean  =True;        { To use the MAIN GRAPH window }
  SpaceSeperator    :Boolean  =True;        { If false then 1 2 3 is turned into 123 }
	AutoFit						:Boolean	=false;   		{ set to MAXY & MINY will be generated automaticly }
	FunctionFill      :Boolean  =False;       { set to fill the surface of the graph with the axes }
  Fill2Colors       :Boolean  =True;        { To fill up and down in diferent colors }
  FillUpColor       :byte     =4;           { Fill color above X axis }
  FillDownColor     :byte     =5;           { Fill color below X axis }
	BackGroundColor		:byte			=4;						{ the global background }
	SelectedFore			:byte			=12;   				{ the color of the letters in the selected menu }
	SelectedBack			:byte			=8;  					{ color of background in the selected menu }
	UnSelectedFore		:byte			=15;  				{ color of letters in unselected menu }
	UnSelectedBack		:byte			=7;    				{ color of background in unselected menu }
	MenuTitleColor    :byte			=1;						{ the text color of the menu title }
	MenuTitleBack     :byte			=2;						{ the background color of the menu title }
	Menu3DEffect			:byte     =2;  	    		{ to use 3D menues (numbers are the ord of 3D mode) }
	MenuFont					:integer	=6;           { The font Number used in the menues }
  MenuFontSize      :integer  =4;           { The size of that font }
	MenuAutoSize      :boolean  =false;       { Make all menuitems the same size }
	MouseAutoSelect   :boolean  =false;       { Is mouse moved over a menuitem automaticly select it }
	DefaultMinX				:real			=-20;  		 		{ the default minimum X value }
	DefaultMaxX				:real			=20;   	 			{ the default maximum X value }
	DefaultMinY				:real			=-20; 				{ the default minimum Y value }
	DefaultMaxY				:real			=20;	 				{ the default maximum Y value }
	RangesReset       :boolean  =false;       { will the ranges be reset to the default, or be set to last position }
	LineWidth					:byte			=3;						{ the graph line width }
	GraphColor				:byte			=14;					{ the graph line color }
	GraphAxes					:byte			=15;					{ the graph axes color }
	GraphBack					:byte			=1; 					{ the graph background color }
	GraphFill         :byte     =13;          { the graph fill color }
  CompLineColor     :byte     =5;					  { the compare graph color }
  ToColorize        :boolean  =false;       { Colorize the graph according to its state }
  AutoHighResPlot   :boolean  =false;       { Plot the graph with hi res calculation after timeout }
  HighResPlotRatio  :byte     =19;          { How many caculations between two pixels }
	XAxisTickSpace		:byte			=50;					{ the space betwin two ticks in pixels on the x axis }
	YAxisTickSpace		:byte			=30;					{ the space betwin two ticks in pixels on the y axis }
  DefaultHelpBG     :byte     =1;           { The default background of the help }
	DefaultHelpColor	:byte			=15; 			    { The Default Text color of the help }
	DefaultHelpFont		:byte     =2;  		  	  { The Defautl font of the help }
	DefaultHelpSize   :byte     =7;  	 	    	{ the default size of the help line }
	SmallZoomStep			:byte			=5;    		   	{ when zooming in the graph }
	LargeZoomStep     :byte     =50;  	    	{ to switch between large and small press DEL }
  SnapMouseToGraph  :boolean  =true;        { do the mouse "snaps" to the graph line }
  FastDrawRes       :byte     =5;           { the number of pixels between each dot on fast draw }
  FormulaInCoordMode:boolean  =true;        { To display the formula in the MouseCoord mode }
  ZoomBoxPreview    :boolean  =true;        { To see a preview of the graph in ZooomBox }
  ZoomOutRatio      :byte     =3;           { In the ZoomBox - multiply of zoom out }
  MainPanMouseInvert:boolean  =true;        { Inverse the mouse movement while panning }
  InvestigatAccuracy:byte     =3;           { the accurasy of the investigation (Like HighResPlotRatio) }
  MaxCompare        :byte     =4;           { The maximum number of compared graphs }
  InvShowMinMax     :boolean  =True;        { Show the minimum and maximum dots }
  InvShowCrossing   :boolean  =True;        { Show the crossing withe the axes }
  InvGraphColorize  :boolean  =True;        { Colorize the graph When investigating }
	SkipMenu					:boolean  =false;		   	{ skip the menues and draw the default formula }
  FastDrawMouseZoom :boolean  =false;       { Active fast draw when zooming with mouse in Main Graph }
	MenuFile					:string		='ENGLISH.MNU';{ the file containing the menues definition }

const
	{ Menu commands }
	doMenu1  			= 1;
	doMenu2 			= 2;
	doMenu3   		=	3;
	doMenu4   		=	4;
	doMenu5   		=	5;
	doExit       	= 6;
	doReturn  		= 7;
	doInput      	= 8;
	doGraph      	= 9;
  doMinimumX   	=10;
	doMaximumX   	=11;
	doMinimumY   	=12;
	doMaximumY   	=13;
	doRanges      =14;
	doAutoFit			=15;
	doLineWidth		=16;
	doScRange			=17;
	doHelp				=18;
	dofunctionfill=19;
	doRangesReset =20;
  doProgramReset=21;
  doInvestigate =22;
  doEsc         =23;
  doMain        =24;
	showhelp      =100;

	nums=['0','1','2','3','4','5','6','7','8','9']; { set of leagel numbers }
	leagle_action=['{','[','(','}',']',')','+','-','*','/','^']; { as is }


const
  { The new MAIN window menu commands }
  mnu_FileMenu      = 201;
  mnu_FormulaMenu   = 202;
  mnu_InspectMenu   = 203;
  mnu_GraphMenu     = 204;
  mnu_helpMenu      = 205;
  mnu_invSMenu      = 206;
  mnu_compSMenu     = 207;
  mnu_compDMenu     = 208; { delete comp }
  mnu_compEMenu     = 209; { edit comp }

  mnu_FunctionFill  = 210;
	mnu_AutoFit       = 211;
	mnu_Axes          = 212;
	mnu_AxesText      = 213;
  mnu_colorize      = 214;
	mnu_Calibarate    = 215;
	mnu_reset         = 216;
	mnu_Ranges			  = 217;
  mnu_ZoomBox				= 218;
  mnu_CompAdd       = 220;
  mnu_CompareLink   = 222;
  mnu_Investigate   = 223;
  mnu_HIres         = 224;
  mnu_Return        = 225;
	mnu_Restore       = 226;
  mnu_Save          = 227;
  mnu_help1         = 228;
  mnu_help2         = 229;
  mnu_help3         = 230;
  mnu_area          = 231; { not implemented }
  mnu_MenuByKb      = 232; { Give the user KB control over the menues }
  mnu_Fill2Color    = 233;
  mnu_fillbuttom    = 245;
  mnu_graphwidth    = 244;
	mnu_Fastzoom      = 234;
  mnu_Fastpan       = 235;
  mnu_fastFunc      = 236;
  mnu_InvFunc       = 237;
  mnu_DefaultFunc   = 238;
  mnu_LastFunc      = 300; { For later implementation of MRU - add slot number }
  mnu_SwichComp     = 239; { replace active formula with compared one }
  mnu_saveimg       = 240;
  mnu_invminmax     = 241;
  mnu_invcross      = 242;
  mnu_invcolor      = 243;
  mnu_copycomp      = 246;
  grp_redraw        = 250; { Redraw the screen }
  grp_Main          = 251;
  grp_status        = 252;
  grp_graph         = 253;
  grp_coords        = 254;
  grp_timercal      = 255;
  grp_timeron       = 256;
  grp_timeroff      = 257;
  kb_Keyevent       = 260; { main kb handeler }

  cmp_one           = 270; { Compare formula number }
  cmp_two           = 271; { Compare formula number }
  cmp_tree          = 272; { Compare formula number }
  cmp_four          = 273; { Compare formula number }

  prExit            = 1;

  mnu_def_main:array [1..5] of command=
   ((name: 'FILE'    ;ctrl: mnu_filemenu),
    (name: 'GRAPH'   ;ctrl: mnu_GraphMenu),
    (name: 'INSPECT' ;ctrl: mnu_Inspectmenu),
    (name: 'FORMULA' ;ctrl: mnu_FormulaMenu),
    (name: 'HELP!'   ;ctrl: mnu_HelpMenu));

  mnu_def_File:array [1..6] of command=
   ((name: ' SAVE '      ;ctrl: mnu_save),
    (name: ' RESTORE '   ;ctrl: mnu_Restore),
    (name: ' SAVE IMG '  ;ctrl: mnu_saveimg),
    (name: ' RESET '     ;ctrl: mnu_reset),
    (name: ' TIMING '    ;ctrl: mnu_calibarate),
    (name: ' EXIT '      ;ctrl: prExit));

  mnu_def_Formula:array [1..4] of command=
   ((name: 'Y = X ^ 2 '    ;ctrl: mnu_FastFunc),
    (name: 'COMPARED '     ;ctrl: mnu_SwichComp),
    (name: 'INVERT (1/F) ' ;ctrl: mnu_InvFunc),
    (name: 'LAST FUNCTION ';ctrl: mnu_lastfunc));

  mnu_def_Graph:array [1..11] of command=
{1 }((name: ' RANGES '       ;ctrl: mnu_ranges),
{2 } (name: ' AUTO FIT '     ;ctrl: mnu_autofit),
{3 } (name: ' ZOOM BOX '     ;ctrl: mnu_zoombox),
{4 } (name: ' ------------'     ;ctrl: 0), { A SEPERATOR }
{5 } (name: 'SHOW AXES '     ;ctrl: mnu_axes),
{6 } (name: 'AXES LABLES '   ;ctrl: mnu_axestext),
{7 } (name: 'COLORIZE '      ;ctrl: mnu_colorize),
{8 } (name: 'THICK LINE'     ;ctrl: mnu_graphwidth),
{9 } (name: 'FUNCTION FILL ' ;ctrl: mnu_functionfill),
{10} (name: '2 COLOR FILL '  ;ctrl: mnu_fill2color),
{11} (name: 'FROM BUTTOM'    ;ctrl: mnu_fillbuttom));

  mnu_def_inspect:array [1..4] of command=
   ((name: ' COMPARE... '   ;ctrl: mnu_compsmenu),
    (name: ' INVESTIGATE '  ;ctrl: mnu_investigate),
    (name: ' SETTINGS... '  ;ctrl: mnu_invSMenu),
    (name: ' HI-RES DRAW '  ;ctrl: mnu_hires));

   mnu_def_compare:array [1..6] of command=
   ((name: ' ADD COMPARE '     ;ctrl: mnu_compadd),
    (name: ' DEL COMPARE '     ;ctrl: mnu_compdmenu),
    (name: ' EDIT COMPARE '    ;ctrl: mnu_compemenu),
    (name: 'COMPARE LINK '     ;ctrl: mnu_comparelink),
    (name: ' COPY ACTIVE '     ;ctrl: mnu_CopyComp),
    (name: ' SWICH FORMULA '   ;ctrl: mnu_swichcomp));

   mnu_def_compare_num:array [1..4] of command=
   ((name: '1: UNAVAILABLE'     ;ctrl: cmp_one ),
    (name: '2: UNAVAILABLE'     ;ctrl: cmp_two ),
    (name: '3: UNAVAILABLE'     ;ctrl: cmp_tree),
    (name: '4: UNAVAILABLE'     ;ctrl: cmp_four));

   mnu_def_investigate:array [1..3] of command=
   ((name: 'MIN MAX'  ;ctrl: mnu_invminmax),
    (name: 'CROSSING' ;ctrl: mnu_invcross),
    (name: 'COLORIZE' ;ctrl: mnu_invcolor));

  mnu_def_help:array [1..3] of command=
   ((name: 'OVERVIEW'     ;ctrl: mnu_help1),
    (name: 'ABOUT'        ;ctrl: mnu_help3),
    (name: 'MENU ITEMS'   ;ctrl: mnu_help2));

  mnu_def_status:array [1..3] of command=
   ((name: 'Z' ;ctrl: mnu_fastzoom),
    (name: 'P' ;ctrl: mnu_fastpan ),
    (name: 'F' ;ctrl: mnu_Fastfunc));

type
	levels=(Initialized,GraphMode,FormulaEntered,XRangeEntered,YRangeEntered,Calculated,Error); { used by error N/A }

	peula=(number,func,X,add,sub,divd,mul,power,sogerp,sogerc); { which action to do (what type) }
	pa=record   {  ^-sin,cos,tan... }          {  ^-(    ^-) }
		p:peula;
		num:extended;
	end;

const
	maxp=50; { maximum number of PA }
	max_menu_item=7; { maximum number of menu items }

var
	level:array[levels] of boolean;
	oldformula:string; { saves the old formula }

implementation
end.