program massege_box_list_test;
uses general,bxdialog,exbox;
var
	mbl:msgboxlist;
  q,w:integer;
	st:string;
begin
	graphinit(6);
	with mbl do begin
		init('',swidth div 2,20,0);
		option(miautoplacey);
		setfont(7,2);
		displayall;
 	end;
	repeat
	  q := 0;
 		w := 0;
		st := '';
		getstr(swidth div 2,30,'new : ',st);
		mbl.insert(st,0,0);
    mbl.FindBiggest(q,w,on);
{		mbl.displayall;
{		readln;}
	until st = 'bye';
	mbl.bye;
	graphend;
end.