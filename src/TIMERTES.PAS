program timertest;
{ a program that test the timer }
uses dos,mycrt,general,mousebx,boxes;
const tbs=15;


var
	tb:array [1..tbs] of msgbox;
	tb2:array [1..tbs] of msgbox;
  mtb:msgbox;
  mtb2:msgbox;
  t:timer;
  i:integer;
  st,st1 : string;

begin
	graphinit(8);
  t.init;
  for i := 1 to tbs do begin
		with tb[i] do begin
 	 		init('00000',swidth div 2+100,shight+40-i*41);
			display;
		end;
		with tb2[i] do begin
 	 		init('00000',swidth div 2-100,shight+40-i*41);
			display;
		end;
  end;
  mtb.init('00000',swidth div 2+250,shight div 2);;
  mtb.display;
  mtb2.init('00000',swidth div 2-250,shight div 2);;
  mtb2.display;
	repeat
{    if t.get < 0 then t.reset;}
  	for i := 1 to tbs do begin
{      delay(0);}
{			tb[i].chngmsg(stry(t.get,0,0));}
      port[$0042]:=port[$0039];
			tb2[i].chngmsg(stry(port[$0040],0,0));
    	delay(2);
    end;
    mtb.getmsg(st);
    tb[1].getmsg(st1);
		if vali(st) < vali(st1) then mtb.chngmsg(st1);
    mtb2.getmsg(st);
    tb2[1].getmsg(st1);
  	if vali(st) < vali(st1) then mtb2.chngmsg(st1);
  until keypressed;
end.