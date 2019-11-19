unit gr_main;
{ use the new box bank to create the main window }
{ including the graph, cascading menues, and a status line }
interface
uses general,boxes,draw_gr,udr_gr,udr_dlg,app,bxlist,set_gr,grmancmd,mousebx,bmenu,initiali;

var
	ox1,ox2,oy1,oy2:integer;

procedure GR_init;
procedure GR_run;
Procedure GR_Quit; { To main menu }

implementation
Procedure GR_Init;
var b:border;
begin
  mouse.forcemove := off;
  mouse.movewhenhide := off;
  ib(B,0,0,swidth,shight);
  kbtimer.reset;
  timeron := false;
  kbtimeout := 30;
  crd_sum:= coords;
  vers := version;

  with coordinates do begin
	  init('(-0000.00,-0000.00)',swidth-75,12);
    settextoffset(0,-11);
  	setfont(2,5);
    setmcolor(7,14,1);
    set3dmode(boxes.inside);
    set3D(on,on);
    autosize := off;
  end;
  initmenu2(@Mstatus,swidth-230,12,1,0,mnu_def_status,'status',b);
  Mstatus.onclick := true;

  fastmsgbox(dover  ,on,on,on,off ,boxes.small,15,7,7,2,6,center,off);
  fastmsgbox(dpress ,on,on,on,on  ,boxes.small,14,7,8,2,6,center,off);
  fastmsgbox(dnormal,on,on,off,off,boxes.small,15,7,7,2,6,center,off);

 	initmenu2(@Mmain,-40,12,1,0,mnu_def_main,'MAIN',b);
  MMain.onclick := false;
  with {Main_}the_Graph do begin
    init(0,27,swidth,shight);
    ox1 := x1;
    oy1 := y1;
    ox2 := x2;
    oy2 := y2;
{  	chngdim(,cornerbox);}
    form^.gets(activeformula);
    setfunc(activeformula);
    jump := smallzoomstep;
{    getready;}
  end;
	Main_App.init;
  Main_app.insert(evntmouse,cmain       ,grp_Main  ,6);
  Main_app.insert(evntmouse,cstatusline ,grp_status,6);
  Main_app.insert(evntmouse,Pgraph      ,grp_graph ,6);

  main_app.insert(evntcmd,Csubmenu    ,mnu_Filemenu     ,6);
  main_app.insert(evntcmd,Csubmenu    ,mnu_Formulamenu  ,6);
  main_app.insert(evntcmd,Csubmenu    ,mnu_graphmenu    ,6);
  main_app.insert(evntcmd,Csubmenu    ,mnu_inspectmenu  ,6);
  main_app.insert(evntcmd,Csubmenu    ,mnu_invSmenu     ,6);
  main_app.insert(evntcmd,Csubmenu    ,mnu_Helpmenu     ,6);
  main_app.insert(evntcmd,Csubmenu    ,mnu_compEmenu    ,6);
  main_app.insert(evntcmd,Csubmenu    ,mnu_compDmenu    ,6);
  main_app.insert(evntcmd,Csubmenu    ,mnu_compSmenu    ,6);
  main_app.insert(evntcmd,Csubmenu    ,mnu_copycomp     ,6);
  main_app.insert(evntcmd,Csubmenu    ,mnu_swichcomp    ,6);

  main_app.insert(evntcmd, Phandleevent,mnu_autofit      ,6);
  main_app.insert(evntcmd, Phandleevent,mnu_functionfill ,6);
  main_app.insert(evntcmd, Phandleevent,mnu_axes         ,6);
  main_app.insert(evntcmd, Phandleevent,mnu_axestext     ,6);
  main_app.insert(evntcmd, Phandleevent,mnu_colorize     ,6);
  main_app.insert(evntcmd, Phandleevent,mnu_reset        ,6);
  main_app.insert(evntcmd, Phandleevent,mnu_ZoomBox      ,6);
  main_app.insert(evntcmd, Phandleevent,mnu_Ranges       ,6);
  main_app.insert(evntcmd, Phandleevent,mnu_Investigate  ,6);
  main_app.insert(evntcmd, Phandleevent,mnu_hires        ,6);
  main_app.insert(evntcmd, Phandleevent,mnu_fill2color   ,6);
  main_app.insert(evntcmd, Phandleevent,mnu_fillbuttom   ,6);
  main_app.insert(evntcmd, Phandleevent,mnu_graphwidth   ,6);
  main_app.insert(evntcmd, Phandleevent,mnu_Help1        ,6);
  main_app.insert(evntcmd, Phandleevent,mnu_Help2        ,6);
  main_app.insert(evntcmd, Phandleevent,mnu_Help3        ,6);
  main_app.insert(evntcmd, Phandleevent,mnu_Calibarate   ,6);
  main_app.insert(evntcmd, Phandleevent,mnu_Restore      ,6);
  main_app.insert(evntcmd, Phandleevent,mnu_Save         ,6);
  main_app.insert(evntcmd, Phandleevent,mnu_Saveimg      ,6);
  main_app.insert(evntcmd, Phandleevent,mnu_InvCross     ,6);
  main_app.insert(evntcmd, Phandleevent,mnu_InvMinMax    ,6);
  main_app.insert(evntcmd, Phandleevent,mnu_InvColor     ,6);

  Main_app.insert(evntcmd,PFastZoomPan,mnu_FastZoom     ,6);
  Main_app.insert(evntcmd,PFastZoomPan,mnu_FastPan      ,6);

  Main_app.insert(evntcmd,PFastfunc,mnu_Fastfunc        ,6);
  Main_app.insert(evntcmd,PFastfunc,mnu_invfunc         ,6);
  Main_app.insert(evntcmd,PFastfunc,mnu_lastfunc        ,6);

  Main_app.insert(evntcmd,PCompare ,cmp_one             ,6);
  Main_app.insert(evntcmd,PCompare ,cmp_two             ,6);
  Main_app.insert(evntcmd,PCompare ,cmp_tree            ,6);
  Main_app.insert(evntcmd,PCompare ,cmp_four            ,6);
  Main_app.insert(evntcmd,PCompare ,mnu_comparelink     ,6);
  Main_app.insert(evntcmd,PCompare ,mnu_compadd         ,6);

  Main_app.insert(evntKey,Ckey       ,kb_keyevent ,6);

  Main_app.insert(evntcmd,GrpRedraw  ,Grp_Redraw  ,6);
  Main_app.insert(evntcmd,Pcoords    ,Grp_coords  ,6);
  Main_app.insert(evntcmd,GrpTimer   ,Grp_TimerOn ,6);
  Main_app.insert(evntcmd,GrpCalib   ,Grp_TimerCal,6);

  Main_app.insert(evntproccess,GrpTimer   ,Grp_TimerOff,6);
end;
procedure GR_run;
begin
  Mmain.start;
  mstatus.start;
  mouse.update;
	grpredraw(grp_redraw);
  grpcalib(grp_timercal);
  main_app.run;
end;

procedure GR_Quit;
begin
  mouse.forcemove := off;
  mouse.erase;
  mmain.bye;
  mstatus.bye;
  coordinates.bye;
  the_graph.form^.gets(activeformula);
{  the_graph.erase;}
  the_graph.chngdim(ox1,oy1,ox2,oy2,cornerbox);
  the_graph.comp_link := false;
  main_app.done;
  mouse.display;
end;
end.
