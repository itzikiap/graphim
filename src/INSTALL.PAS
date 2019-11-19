{ $M 65360,32768,75536}
{ for debugging erase this space : }
{ $define debug}
{ this will skip the copy file }
program install;
{     install to HD        }
uses general,graph,exbox,boxes,bxdialog,drivers,dos,inifiles;
type
	actiontype=(abort,ignor,retry);

var
	i,i1:integer;
  s,s2:string;
	dirinfo:searchrec;
	current_dir:string;
	destintion_dir:string;
	totalsize : longint;
	stitle:string;
	EndMsg:string;
	description:string;
	fname:string;

	RunAtEnd:string;
	RunAtEndArgs:string;
	RunAtEndPrompt:string;
	DoRunAtEnd:boolean;

	wtd:actiontype;
	cr:msgbox;
	title:msgbox;
	msg:array[1..3] of msgbox;
	file_name:msgbox;
	file_description:msgbox;
	file_destintion:msgbox;
	file_prog:progress;
	total_prog:progress;

function copyf(filename,destintion,description:string):boolean { return TRUE on success };
var
	FromF, ToF: file;
	NumRead, NumWritten: Word;
	size,sizedone:longint;
	Buf: array[1..2048] of Char;
	i:integer;
begin
	Assign(FromF,filename);
	{$I-}
	Reset(FromF, 1);
	{$I+}
	i := ioresult;
	if (I <> 0) and (I <> 5) then begin
		copyf := false;
		exit;
	end;
	{$ifndef debug}
	Assign(ToF, destintion+'\'+filename);
	Rewrite(ToF, 1);
	{$endif}
	size := FileSize(FromF);
	sizedone := 0;
	file_description.chngmsg(description);
	file_name.chngmsg('FROM : '+filename);
	file_destintion.chngmsg('TO : '+destintion);
	file_prog.init(swidth div 2 - 250,shight - 100,swidth div 2 + 250,shight - 60,0,size);
	file_prog.display;
	{$ifndef debug}
	repeat
	{$I-}
		BlockRead(FromF, Buf, SizeOf(Buf), NumRead);
		i := ioresult;
		if (I <> 0) and (I <> 5) then begin
			copyf := false;
			exit;
		end;
		BlockWrite(ToF, Buf, NumRead, NumWritten);
		i := ioresult;
		if (I <> 0) and (I <> 5) then begin
			copyf := false;
			exit;
		end;
	{$I+}
		inc(sizedone,NumWritten);
		file_prog.incby(NumWritten);
		total_prog.incby(NumWritten);
	until (NumRead = 0) or (NumWritten <> NumRead) or (sizedone = size) ;
	{$else}
	sizedone:=size;
	{$endif}
	Close(FromF);
	{$ifndef debug}
	Close(ToF);
	{$endif}
	if sizedone <> size then begin
		copyf := false;
		exit;
	end;
	file_prog.bye;
	copyf := true;
end;

function calcTotalSize:longint;
var
	dirinfo:searchrec;
	dirsize:longint;
begin
	dirsize := 0;
	gotosector('FILES');
	i := 0;
	getNextParameter;
	while getinierr = 0 do begin
		inc(i);
		if variable = 'FILE'+stry(i,0,0) then fname := value;
		getNextParameter;
		getNextParameter;
		i1 := 0;
		findfirst(fname,anyfile,dirinfo);
		while doserror = 0 do begin
			inc(i1);
			dirsize := dirsize + dirinfo.size;
			findnext(dirinfo);
		end;
		getNextParameter;
	end;
	gotosector('GROUPS');
	i := 0;
	getNextParameter;
	while getinierr = 0 do begin
		inc(i);
		if variable = 'GROUP'+stry(i,0,0) then fname := value;
		getNextParameter;
		getNextParameter;
		i1 := 0;
		findfirst(fname,anyfile,dirinfo);
		while doserror = 0 do begin
			inc(i1);
			dirsize := dirsize + dirinfo.size;
			findnext(dirinfo);
		end;
		getNextParameter;
		getNextParameter;
	end;
	calcTotalSize := dirsize;
end;

procedure error(errmsg:string;action:actiontype);
begin
	if action = Abort then begin
		cr.bye;
		title.bye;
		file_name.bye;
		file_description.bye;
		file_destintion.bye;
		total_prog.bye;
		closeini;
	end;
	with msg[1] do begin
		init(errmsg,swidth div 2,shight div 2 - 50);
		setmcolor(14,0,4);
		set3d(on,off);
		display;
	end;
	with msg[2] do begin
		case action of
			abort:init('ACTION : ABORTING !',swidth div 2,shight div 2 );
			ignor:init('ACTION : IGNORING !',swidth div 2,shight div 2 );
			retry:init('ACTION : RETRYING !',swidth div 2,shight div 2 );
		end;
		setmcolor(15,0,4);
		set3d(on,off);
		display;
	end;
	with msg[3] do begin
		init('PRESS ENTER.',swidth div 2,shight div 2 + 50);
		setmcolor(14,0,4);
		setfont(1,2);
		set3d(on,off);
		display;
	end;
	readln;
	msg[1].bye;
	msg[2].bye;
	msg[3].bye;
	if action=abort then begin
		closegraph;
		writeln('Error msg : "',errmsg);
		halt(1);
	end;
end;

procedure makewindows;
var
	windows_dir:string;
begin
	if getyesno('INSTALL CAN ONLY MAKE SHORTCUTS ON THE ENGLISH VERSION OF WINDOW.','OK','CANCEL',0,1) then begin
		Windows_dir := 'C:\WINDOWS';
		with msg[1] do begin
			init('ENTER YOUR WINDOWS DIRECTORY :',swidth div 2,200);
			setfont(2,8);
			setmcolor(1,2,3);
			set3d(on,off);
			display;
		end;
		getstr(swidth div 2,shight div 2,'',windows_dir);
		windows_dir:=windows_dir+'\STARTM~1\PROGRAMS\IAP';
		{$I-}
		mkdir(windows_dir);
		{$I+}
		msg[1].bye;
		findfirst('*.PIF',anyfile,dirinfo);
		while doserror = 0 do begin
			if not copyf(dirinfo.name,windows_dir,'THE START MENU SHORTCUTS') then error('ERROR COPYING FILE '+dirinfo.name,ignor);
			findnext(dirinfo);
		end;
		with msg[1] do begin
			init('BECAUSE THIS IS A DOS PROGRAM THERE MAY BE INCOMPATIBILITIES!',swidth div 2,shight div 2 - 50);
			setfont(6,1);
			setmcolor(14,0,4);
			set3d(on,off);
			display;
		end;
		with msg[2] do begin
			init('AT FIRST LOADIG, WAIT UNTIL WINDOWS FIND THE PROGRAM.',swidth div 2,shight div 2 );
			setfont(2,5);
			setfont(11,1);
			setmcolor(15,0,4);
			set3d(on,off);
			display;
		end;
		with msg[3] do begin
			init('PRESS ENTER.',swidth div 2,shight div 2 + 50);
			setmcolor(14,0,4);
			setfont(1,2);
			set3d(on,off);
			display;
		end;
		readln;
		msg[1].bye;
		msg[2].bye;
		msg[3].bye;
	end;
end;


begin
	builtingraph;
	OpenINI('install.ini');
	if getINIerr <> 0 then begin
		writeln('Error openning INSTALL.INI.');
		halt(1);
	end;
	graphinit(1);
	upcasevalue := true;
	clearvalue := false;
	gotosector('SETUP');
	if not searchvar('TITLE') then value := 'INSTALL';
	stitle := value;
	upcasevalue := false;
	if not searchvar('ENDMASSEGE') then endmsg := '' else endmsg := value;
	with cr do begin
		init('I.A.P Production Installer',swidth div 2,50);
		setfont(6,3);
		setmcolor(5,7,7);
		set3D(on,off);
		display;
	end;
	delay(30);
	with title do begin
		init(stitle,swidth div 2,100);
		setfont(6,5);
		setmcolor(13,7,5);
		set3d(on,on);
		display;
	end;
	delay(50);
	if searchvar('SHOWCOPYRIGHT') and gettruefalse(value) then begin
		with msg[1] do begin
			init('Programmed by ITZHAK.',swidth div 2,200);
			set3d(on,off);
			display;
		end;
		delay(30);
		with msg[2] do begin
			init('All rights reserved !',swidth div 2,300);
			set3d(on,off);
			display;
		end;
		delay(121);
		msg[2].bye;
		delay(90);
		msg[1].bye;
		setfillstyle(solidfill,1);
		bar(0,0,swidth,shight);
		title.display;
		cr.display;
	end;
	with msg[3] do begin
		init('Pleas wait ...',swidth div 2,200);
		setfont(9,5);
		setmcolor(3,3,8);
		set3d(on,off);
		display;
	end;
	DoRunAtEnd := false;
	if searchvar('RUNATEND') then begin
		i1 := 1;
		RunAtEnd := gettochar(value,i1,[' '],on);
		RunAtEndArgs := gettochar(value,i1,['*'],on);{copy (value,i1,length(value)-i1+1);}
		DoRunAtEnd := true;
		clearvalue := false;
		upcasevalue := false;
		if searchvar('RUNPROMPT') then RunAtEndPrompt := value;
	end;
	getdir(0,current_dir);
	if not searchvar('DEFAULTDIR') then error('NO DEFAULT DIR IN INSTALL.INI',ignor);
	destintion_dir := value;
	totalsize := calctotalsize;
	total_prog.init(50,shight-50,swidth-50,shight-1,0,totalsize);
	msg[3].bye;
	with msg[1] do begin
		init('ENTER DESTINTION DIRECTORY :',swidth div 2,200);
		setfont(2,8);
		setmcolor(1,2,3);
		set3d(on,off);
		display;
	end;
	getstr(swidth div 2,shight div 2,'',destintion_dir);
	msg[1].bye;
	setfillstyle(solidfill,1);
	bar(0,0,swidth,shight);
	title.display;
	cr.display;
	with file_description do begin
		init('',swidth div 2,150);
		set3D(on,on);
		setmcolor(7,4,1);
	end;
	with file_name do begin
		init('FROM : ',swidth div 2,200);
		set3D(on,on);
		setmcolor(7,7,8);
	end;
	with file_destintion do begin
		init('TO : '+destintion_dir,swidth div 2,250);
		set3D(on,on);
		setmcolor(7,7,8);
	end;
	total_prog.display;
  i := 0;
  s:='';
  getdir(0,s2);
  s:=s+gettochar(destintion_dir,i,['\'],on)+'\';
	repeat
    s:=s+gettochar(destintion_dir,i,['\'],on);
    if s[1] < #31 then s := copy(s,2,length(s));
    {$I-}
    chdir(s);
    {$I+}
		if ioresult <> 0 then	begin
			mkdir(s);
    end;
    s := s+'\';
  until i>=length(destintion_dir);
	if ioresult <> 0 then;
  chdir(s2);
	begin { start copying the files }
		file_name.display;
		file_description.display;
		file_destintion.display;
		gotosector('FILES');
		i := 0;
		getNextParameter;
		while getinierr = 0 do begin
			inc(i);
			if variable = 'FILE'+stry(i,0,0) then fname := value else error('ERROR IN INI FILE ('+variable+').',abort);
			getNextParameter;
			if variable = 'DESC'+stry(i,0,0) then description := value else description := 'NO DESCRIPTION';
			if description = '' then description := 'NO DESCRIPTION';
			getNextParameter;
			if variable = 'ACT'+stry(i,0,0) then begin
				if value = 'ABORT' then wtd := abort
				else wtd := ignor;
			end else wtd := ignor;
			if not copyf(fname,destintion_dir,description) then error('ERROR COPYING FILE '+fname,wtd);
			getNextParameter;
		end;
		gotosector('GROUPS');
		i := 0;
		getNextParameter;
		while getinierr = 0 do begin
			inc(i);
			if variable = 'GROUP'+stry(i,0,0) then fname := value else error('ERROR IN INI FILE ('+variable+').',abort);
			getNextParameter;
			if variable = 'DESC'+stry(i,0,0) then description := value else description := 'NO DESCRIPTION';
			if description = '' then description := 'NO DESCRIPTION';
			getNextParameter;
			if variable = 'INDACT'+stry(i,0,0) then begin
				if value = 'ABORT' then wtd := abort
				else wtd := ignor;
			end else wtd := ignor;
			i1 := 0;
			findfirst(fname,anyfile,dirinfo);
			while doserror = 0 do begin
				if not copyf(dirinfo.name,destintion_dir,description) then error('ERROR COPYING FILE '+dirinfo.name,wtd);
				inc(i1);
				findnext(dirinfo);
			end;
			getNextParameter;
			if variable = 'ALLACT'+stry(i,0,0) then begin
				if value = 'ABORT' then wtd := abort
				else wtd := ignor;
			end else wtd := ignor;
			if i1=0 then error('NO FILES IN GROUP !',wtd);
			getNextParameter;
		end;
	end;
	total_prog.bye;
	file_name.bye;
	file_description.bye;
	file_destintion.bye;
	chdir(destintion_dir);
	if endmsg <> '' then begin
		with msg[1] do begin
			init(endmsg,swidth div 2,200);
			setMcolor(13,6,9);
			set3d(on,off);
			display;
		end;
		delay(30);
		with msg[2] do begin
			init('Press Enter.',swidth div 2,300);
			setMcolor(12,5,10);
			setfont(1,2);
			set3d(on,off);
			display;
		end;
	end;
	readln;
	msg[1].bye;
	msg[2].bye;
	if DoRunAtEnd then begin
		if (runatendprompt <> '') then begin
			if getyesno(runatendprompt,'YES','NO',7,3) then dorunatend := true
			else dorunatend := false;
		end;
	end;
	closegraph;
	closeINI;
	if dorunatend then begin
		swapvectors;
		exec(runatend,runatendargs);
		swapvectors;
	end;
	writeln(endmsg);
end.
