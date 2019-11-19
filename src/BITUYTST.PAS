program bituytst;
uses bituy;
var st:string;
begin
	repeat
		write('enter formula : ');
		readln(st);
		writeln(st,' = ',solve(st):4:4);
	until st='';
end.