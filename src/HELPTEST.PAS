program help_tester;
uses general,help;
var help1:helpbox;
begin
	if paramcount > 0 then begin
		graphinit(4);
		help1.init('graphim.hlp',vali(paramstr(1)));
		HELP1.USERINTERFACE;
		graphEnd;
	end else writeln('plees enter topic number.');
end.