program msgtest;
uses general,boxes;

var
	t:msgbox;
  i,x : integer;

begin
  graphinit(8);
	t.init('ttthhhrty',swidth div 2,shight div 2);
  x := t.width;
  t.saveback := false;
  t.display;
	readln;
  for i := x to 700 do
    t.chngdim(i,0,0,0,cornerbox);
  for i := 700 downto x do
    t.chngdim(i,0,0,0,cornerbox);

  t.setjustify(left);
  for i := x to 700 do
    t.chngdim(i,0,0,0,cornerbox);
  for i := 700 downto x do
    t.chngdim(i,0,0,0,cornerbox);
  t.setjustify(right);
  for i := x to 700 do
    t.chngdim(i,0,0,0,cornerbox);
  for i := 700 downto x do
    t.chngdim(i,0,0,0,cornerbox);
  readln;
  t.bye;
end.