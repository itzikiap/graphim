unit clmenu;
{ define the menu of the calculator }
interface
uses app,mousebx,bxlist,general,bmenu,cldef;

function checkmenu(ID:word:word);

procedure createmenu;
procedure delmenu;

implementation
var
	m:objbank;

procedure createmenu;
begin
	initmenu2(@m,15,15,1,0,menudef);
	m.display(0);
end;
procedure delmenu;
begin
	m.bye;
end;

function checkmenu;
var
	b:box;
begin
	m.select(1);
	with mouse do
		if buttompressed[1] then
			m.getisinctl(x,y);
			sel
