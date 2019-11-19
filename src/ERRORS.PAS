unit errors;
{ programmed by ITZHAK ARZONY }
{ this unit trys to handle errors }
interface
uses graph,dos;
const
	errFile_Disk    = 1;
	errHardware     = 2;
	errDiv_By_zero  = 3;
	errOverflow     = 4;
	errGPF          = 5;
	errGeneral      = 6;

	error_list:array[1..6] of string=
		('FILE/DISK ERROR.',
		'HARDWARE FAILURE.',
		'DIVIDE BY ZERO.',
		'OVERFLOW.',
		'GENERAL PROTECTION FAULT.',
		'ERROR: ');

var errmsg:string;
		errfunction:string;
		firststate:pointer;

procedure fatalerror(errnum:byte);
implementation
procedure fatalerror(errnum:byte);
begin
	{$I-}
	restorecrtmode;
	release(firststate);
	if errfunction <> '' then write(errfunction,' reports :');
	writeln(errmsg);
	if errnum < 6 then writeln(error_list[errnum]);
	halt(errnum);
end;

begin
	mark(firststate);
end.


