unit Bmnudef;
{ Menu defuinition for builder }
interface
uses general,mousebx,bmenu,boxes,app,proc,event;
const
	prRun     =51; { run the futurly applicable "script" }
  prTest    =52;
  prRedraw  =53;
  FrmRedraw =54;

  BMainMenu  = 61;
  BForm      = 62;
  BProperty  = 63;

  mnuFileMenu=110;
  cmFlSave   =111;
  cmFlLoad   =112;
  cmFlNew    =113;

  mnuAddMenu  =120;
  cmAdBox   =121;
  cmAdInput =122;
  cmAdMsg   =123;
  cmAdProc  =124;

  mnuPropertymenu=130;
  mnuPrColor =131;
  cmPrSize  =132;
  mnuPr3D   =133;
  cmPrFont  =134;
  cmPrMsg   =136;

  cmMove    =140;
  cmSize    =141;
  cmDel     =300; { What ID to delete is added to the cmDel }

  d3dinv       = 160;
  d3dNone      = 161;
  d3dSmall     = 162;
  d3dBig       = 163;
  d3dLarge     = 164;
  d3dDouble    = 165;
  d3dLDouble   = 166;
  d3dInside    = 167;
  d3dLinside   = 168;

  clrBlack     = 170;
  clrBlue      = 171;
  clrGreen     = 172;
  clrCyne      = 173;
  clrRed       = 174;
  clrMagent    = 175;
  clrBrown     = 176;
  clrWhite     = 177;
  clrBright    = 178; { Tuggle }

  txtjust      = 147;
  txtoffset    = 148;

	DefMainMenu : array [1..3] of command =
   ((Name:'FILE'    ;Ctrl:mnuFileMenu),
    (Name:'ADD'     ;Ctrl:mnuAddMenu  ),
    (Name:'PROPERTY';Ctrl:mnuPropertyMenu));

	DefFileMenu : array [1..4] of command =
   ((Name:'NEW'   ;Ctrl:cmFlNew ),
    (Name:'SAVE'  ;Ctrl:cmFlSave),
    (Name:'LOAD'  ;Ctrl:cmFlLoad),
    (Name:'EXIT'  ;Ctrl:PrExit  ));

	DefAddMenu : array [1..3] of command =
   ((Name:'BOX'      ;Ctrl:cmAdBox  ),
    (Name:'MSGBOX'   ;Ctrl:cmAdMsg  ),
    (Name:'INPUTBOX' ;Ctrl:cmAdInput));

	DefPropMenu : array [1..5] of command =
   ((Name:'COLOR'     ;Ctrl:mnuPrColor),
    (Name:'3D LOOK'   ;Ctrl:mnuPr3D   ),
    (Name:'FONT'      ;Ctrl:cmPrFont  ),
    (Name:'CHNG MSG'  ;Ctrl:cmPrMSG 	),
    (Name:'DELETE'    ;Ctrl:cmDel     ));

	Def3DMenu : array [1..9] of command =
   ((Name:'INVERSE'  ;Ctrl:d3dinv    ),
    (Name:'NONE'     ;Ctrl:d3dNone   ),
    (Name:'SMALL'    ;Ctrl:d3dSmall  ),
    (Name:'BIG'      ;Ctrl:d3dBig    ),
    (Name:'LARGE'    ;Ctrl:d3dlarge  ),
    (Name:'DOUBLE'   ;Ctrl:d3dDouble ),
    (Name:'INSIDE'   ;Ctrl:d3dInside ),
    (Name:'L_DOUBLE' ;Ctrl:d3dLDouble),
    (Name:'L_INSIDE' ;Ctrl:d3dLinside));

	DefClrMenu : array [1..8] of command =
   ((Name:'BRIGHT '  ;Ctrl:clrBright ),
    (Name:'BLACK'    ;Ctrl:clrBlack  ),
    (Name:'BLUE'     ;Ctrl:clrBlue   ),
    (Name:'GREEN'    ;Ctrl:clrGreen  ),
    (Name:'CYNE'     ;Ctrl:clrCyne   ),
    (Name:'RED'      ;Ctrl:clrRed    ),
    (Name:'BROWN'    ;Ctrl:clrBrown  ),
    (Name:'WHITE'    ;Ctrl:clrWhite  ));

implementation
end.