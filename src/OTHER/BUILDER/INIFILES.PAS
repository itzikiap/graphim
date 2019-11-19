unit inifiles;
{ this unit hanles the INI files }
interface
uses dos;

const
	{ some error constants }
	iniOK             = 0;
	iniEndOfFile      = 1;
	iniEndOfSector    = 2;
	iniFileNotExist		= 3;
	iniSectorNotFound	= 4;

	NotGoodChar=[' ',#13,#12,#10,#9];

var
	inifile:text;
	CurrentLine:word;
	SectorName:string;
	variable,value:string;
	UpCaseValue:boolean;
	ClearValue:boolean;

procedure OpenINI(name:string);
procedure resetINI;
procedure gotosector(WhatSector:string);
function getnextsector:string;
function SearchVar(vary:string):boolean;
function GetVariable:string;
function GetValue:string;
function getTrueFalse(s:string):boolean;
procedure GetNextParameter;
procedure closeINI;
function getinierr:byte;

implementation
var
	iniFileName:string;
	INIerr:byte;

function getTrueFalse;
begin
	if (value = '1') or (value = 'ON') or (value = 'YES') or (value='TRUE') then
		gettruefalse:=true
	else if (value = '0') or (value='OFF') or (value='NO') or (value='FALSE') then
		gettruefalse:=false;
end;

procedure resetini;
begin
	reset(INIfile);
	sectorname := '';
	variable := '';
	value := '';
	inierr := 0;
end;

procedure OpenINI;
begin
	{$I-}
	INIFileName:=name;
	assign(INIfile,INIfileName);
	reset(INIfile);
	CurrentLine:=1;
	ClearValue:=true;
	{$i+}
	if ioresult <> 0 then INIErr := iniFileNotExist;
end;

procedure gotosector;
var st:string;
	err:byte;
begin
{	closeINI;
	openINI(inifilename);}
	reset(inifile);
	repeat
		st:=GetNextSector;
		err:=getinierr;
	until (st=WhatSector) or (Err<>0);
	if err <> 0 then begin
		inierr:=iniSectorNotFound;
		st:='';
	end else sectorname:=whatsector
end;

function SearchVar;
var st:string;
	err:byte;
begin
	GotoSector(SectorName);
	repeat
{		readln(INIFIle);
		inc(CurrentLine);}
		st:=getvariable;
		err:=getinierr;
	until (st=vary) or seekeof(inifile) or (err<>0);
	if st=vary then begin
		variable:=st;
		value:=getvalue;
		searchvar:=true;
	end else begin
		searchvar:=false;
		inierr := iniEndOfFile;
	end;
end;

function getvariable:string;
var
	c:char;
	i:byte;
	st:string;
begin
	read(inifile,c);
	c:=upcase(c);
	st:='';
	while c in[#0..#13] do begin
		read(inifile,c);
		c:=upcase(c);
		st:='';
	end;
	if c = '[' then begin
		inierr := iniEndOfSector;
		exit;
	end;
	while  not ((c in ['=',';']) or seekeoln(inifile)) do begin
		if (not (c in notgoodchar)) and (c <> ' ') then st:=st+c;
		read(inifile,c);
		c:=upcase(c);
	end;
	if c=';' then begin
		st := '';
		readln(inifile);
	end;
	if c = #13 then begin
		st := '';
		getvariable:=st;
		readln(inifile);
		exit;
	end;
	if eoln(inifile) then readln(inifile);
	getvariable:=st;
end;

function getvalue:string;
var
	c:char;
	i,i1:byte;
	st:string;
begin
	if not eoln(inifile) then read(inifile,c);
	st:='';
	while not (eoln(inifile) or (c=';')) do begin
		if upcasevalue then
			 c := upcase(c);
		if ClearValue then if not(c in NotGoodChar) then st:=st+c;
		if not ClearValue then st:=st+c;
		read(inifile,c);
	end;
	if upcasevalue then
		 c := upcase(c);
	if ClearValue then if not(c in NotGoodChar) then st:=st+c;
	if not ClearValue then begin
		st:=st+c;
		i := 1;
		while (st[i] in notgoodchar) and (i < length(st)) do inc(i);
		i1 := length(st);
		while (st[i1] in notgoodchar) and (i1 > 1) do dec(i1);
		st := copy(st,i,length(st)-(i-i1)+1);
	end;
	getvalue:=st;
	readln(inifile);
end;

procedure GetNextParameter;
begin
	repeat
		variable:=getvariable;
		if inierr = iniEndOfSector then exit;
		if (variable='') and not seekeof(INIFile) then continue;
		value:=getvalue;
	until eof(INIFile) or (variable<>'');
	if eof(INIFile) then begin
		variable:='';
		value:='';
		INIerr:=1;
	end;
end;

function GetNextSector;
var st:string;
	c:char;
begin
	st:='';
	repeat
		{$i-}
		read(inifile,c);
		{$i+}
		if c = '[' then begin
			readln(inifile,st);
			st := copy(st,1,length(st)-1);
		end else readln(inifile);
	until seekeof(inifile) or (st<>'');
	inierr := 0;
	if st = '' then inierr := 1;
	getnextsector:=st;
end;

procedure closeini;
begin
	close(inifile);
end;

function getinierr;
begin
	getinierr:=INIerr;
	INIerr:=0;
end;

end.