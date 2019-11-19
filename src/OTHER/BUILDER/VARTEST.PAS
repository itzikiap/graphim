uses varlist;
var
	v:variable;
  n:string;
  s:string;
  t:byte;

procedure makelist;
var
	i : string;

begin
  v.selected := @v.list;
  v.selectfind := false;
  while v.selectnext <> 0 do begin
    i := v.selected^.name;
		writeln(v.selected^.id,' - ',i,'  :=  ',v.vget(i));
  end;
end;


begin
    v.init(20);
	repeat
    write('NAME: ');
    readln(n);
    write('DATA: ');
  	readln(s);
    write('TYPE(1-bt,2-ch,3-rl,4-st,10-see,11-del,12-list: ');
    readln(t);
    case t of
    	1 : v.dim(n,var_byte,sizeof(byte));
      2 : v.dim(n,var_char,sizeof(char));
      3 : v.dim(n,var_real,sizeof(real));
      4 : v.dim(n,var_string,sizeof(s128));
      10 : writeln(v.vget(n));
      11 : begin
        v.selectfind := true;
				v.findbyname(n);
        v.delete(v.selected^.id);
      end;
      12 : makelist;
    end;
    if t<10 then v.vsets(n,s);
  until n='';
  makelist;
	v.bye;
end.





