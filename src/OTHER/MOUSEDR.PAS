program mouse_draw;
uses app,event,mouse2,general,boxes;
const
	{ app const }
  chpressed=20;
  chreset=21;
  exit_pressed=22;
  mpressed=50;

type
	mdraw=object
  	mat:array[1..11,1..11] of box;
    constructor init(size:byte);
    procedure get_mpointer(p:marray);
    procedure reset;
  	destructor bye;
  end;

function Proccess_box(ID:word):boolean;
begin
 	proccess_box := false;
   if buttompressed[1] then

