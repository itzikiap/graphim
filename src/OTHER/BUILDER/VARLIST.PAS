unit varlist;
{ Implements a dinamic list of variants }
Interface
uses bxlist,general;

type
	vartype=(vbyte,vinteger,vreal,vstring,vchar,vboolean,varrayin,varrayrl,varrayst);

type
  s=string[255];
  s10=string[10];
  s50=string[50];
  s100=string[100];
  s128=string[128];

const
  var_byte    = 'VBT';
  var_integer = 'VNT';
  var_string  = 'VST';
  var_real    = 'VRL';
  var_char    = 'VCR';
  var_boolean = 'VBL';
  var_arrayin = 'VAN';
  var_arrayrl = 'VAR';
  var_arrayst = 'VAT';

  {Error Codes}
  ErrDiv0        = 0;
  ErrTypeMismach = 1;
  ErrOverflow    = 2;
  ErrConversion  = 3;
  ErrOutLimit    = 4;
  ErrNoMem       = 5;

type
	variable=object(objbank)
    limit:byte; { limit number of vars. 0= unlimited }
    allow_convarsions:boolean; { allow type conversions. N/A for now }
    Error_code:byte;

    constructor init(Mlimit:byte);
    procedure Dim(vname:string8;vtype:string3;vsize:byte);
    procedure vsetr(vname:string8;vdata:real);
    procedure vsets(vname:string8;vdata:string);
{    procedure asetr(vname:string8;index:byte;vdata:real);  }
{    procedure asets(vname:string8;index:byte;vdata:string);}
    function vget(vname:string8):string; { Sorry - ints and real it converts to string }
    function Pget(vname:string8;vtype:string3):pointer;
{    function aget(vname:string8):string;                   }
    destructor bye;
  end;

Implementation
{*************************************}
{*     Var List                      *}
{*************************************}
constructor Variable.init;
begin
	inherited init('VARLIST');
  limit := mlimit;
end;


{*********}
procedure variable.dim;
{ Vsize only implements on artray and string }
{ AND IT NOT IMPLEMENTED YET                 }
var
	P:Pobjlist;
	Msize : word;

begin
  if vtype=var_byte    then msize := sizeof(byte);
  if vtype=var_integer then msize := sizeof(integer);
  if vtype=var_string  then msize := sizeof(s128);
  if vtype=var_real    then msize := sizeof(real);
  if vtype=var_char    then msize := sizeof(char);
  if vtype=var_boolean then msize := sizeof(boolean);
{  if vtype=var_arrayin then msize := sizeof(
	if vtype=var_arrayrl then msize := sizeof(
  if vtype=var_arrayst then msize := sizeof(}
  if insert(vsize,vname,vtype,msize) = nil then error_code := errnomem;
end;

{********}
procedure variable.vsetr;
var
	p:pobjlist;
  i:^integer;
  r:^real;
  st:^s128;
  b:^byte;
  c:^char;
  bl:^boolean;

begin
	p := findbyname(vname);
  if p^.tpe = var_byte    then begin b := p^.obj; b^ := round(vdata); end;
  if p^.tpe = var_integer then begin i := p^.obj; i^ := round(vdata); end;
	if p^.tpe = var_string  then begin st := p^.obj; st^ := stry(vdata,0,0); end;
  if p^.tpe = var_real    then begin r := p^.obj; r^ := vdata; end;
  if p^.tpe = var_char    then begin c := p^.obj; c^ := chr(round(vdata)); end;
  if p^.tpe = var_boolean then begin bl := p^.obj; bl^ := (round(vdata) = 1); end;
end;

{********}
procedure variable.vsets;
var
	p:pobjlist;
  i:^integer;
  r:^real;
  st:^s128;
  b:^byte;
  c:^char;
  bl:^boolean;

begin
	p := findbyname(vname);
  if p^.tpe = var_byte    then begin b := p^.obj; b^ := vali(vdata); end;
  if p^.tpe = var_integer then begin i := p^.obj; i^ := vali(vdata); end;
	if p^.tpe = var_string  then begin st := p^.obj; st^ := vdata; end;
  if p^.tpe = var_real    then begin r := p^.obj; r^ := valr(vdata); end;
  if p^.tpe = var_char    then begin c := p^.obj; c^ := vdata[1]; end;
  if p^.tpe = var_boolean then begin bl := p^.obj; bl^ := (upstr(vdata) = 'TRUE'); end;
end;

function variable.vget;
var
	p:pobjlist;
  i:^integer;
  r:^real;
  st:^s128;
  b:^byte;
  c:^char;
  bl:^boolean;
  str : string;
begin
	p := findbyname(vname);
  if p^.tpe = var_byte    then begin b := p^.obj; str := stry(b^,0,0); end;
  if p^.tpe = var_integer then begin i := p^.obj; str := stry(i^,0,0); end;
	if p^.tpe = var_string  then begin st := p^.obj; str := st^; end;
  if p^.tpe = var_real    then begin r := p^.obj; str := stry(r^,0,0); end;
  if p^.tpe = var_char    then begin c := p^.obj; str := c^ end;
  if p^.tpe = var_boolean then begin bl := p^.obj; if bl^ then str := '1' else str := '0'; end;
  vget := str;
end;

function variable.pget;
var
	p:pobjlist;
begin
	p := findbyname(vname);
	if vtype='' then vtype := p^.tpe;
  if p^.tpe <> vtype then pget := nil else pget := p^.obj;
end;

destructor variable.bye;
begin
	inherited bye;
end;

end.