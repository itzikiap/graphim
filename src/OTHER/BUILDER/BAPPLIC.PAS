unit Bapplic;
{ Makes the application for the builder }
interface
uses app,event,proc,bglobal,bmnudef,bproc,mousebx,general,bmenu;

procedure initapp;
procedure runapp;
procedure byeapp;

implementation
procedure initapp;
var
	b:border;
  i:integer;
begin
  mouse.init;
	bapp.init;

  ib(B,1,1,swidth,shight);
	initmenu2(@Mmain,-40,20,1,0,DefMainMenu,'MAIN',b);
  MainForm.init;

  with bapp do begin
    vars.dim('LastId','VBT',0);
    insert(evntmouse,cmain       ,BMainMenu ,6);
    insert(evntmouse,cform       ,Bform     ,6);

  	insert(EvntCmd,Csubmenu,mnuFileMenu     ,normal);

  	insert(EvntCmd,Csubmenu,mnuFileMenu     ,normal);
  	insert(EvntCmd,Csubmenu,mnuAddMenu      ,normal);
  	insert(EvntCmd,Csubmenu,mnuPropertymenu ,normal);
  	insert(EvntCmd,Csubmenu,mnuPr3D         ,normal);
  	insert(EvntCmd,Csubmenu,mnuPrColor      ,normal);

    insert(EvntCmd,bmRedraw    ,prRedraw   ,normal);
    insert(EvntCmd,bmRedraw    ,FrmRedraw  ,normal);

    insert(EvntCmd,Phandleevent,cmFlSave  ,normal);
    insert(EvntCmd,Phandleevent,cmFlLoad  ,normal);
    insert(EvntCmd,Phandleevent,cmFlNew   ,normal);

		insert(EvntCmd,Phandleevent,cmAdBox   ,normal);
    insert(EvntCmd,Phandleevent,cmAdInput ,normal);
    insert(EvntCmd,Phandleevent,cmAdMsg   ,normal);
    insert(EvntCmd,Phandleevent,cmAdProc  ,normal);
    insert(EvntCmd,Phandleevent,cmDel     ,normal);

    insert(EvntCmd,Phandlebox,cmPrSize  ,normal);
    insert(EvntCmd,Phandlebox,cmPrFont  ,normal);
    insert(EvntCmd,Phandlebox,cmPrMsg   ,normal);

    for i := 0 to 8 do
    	insert(EvntCmd,Phandlebox,d3dinv+i  ,normal);
    for i := 0 to 9 do
    	insert(EvntCmd,Phandlebox,clrblack+i  ,normal);


    insert(EvntCmd,Cform,cmMove    ,normal);
    insert(EvntCmd,Cform,cmSize    ,normal);
    insert(EvntCmd,Cform,txtoffset ,normal);
    insert(EvntCmd,Cform,cmDel     ,normal); { What ID to delete is added to the cmDel }
  end;
end;

procedure runapp;
begin
  Mmain.start;
	bapp.run;
end;

procedure byeapp;
begin
	bapp.done;
  mouse.bye;
end;

end.

