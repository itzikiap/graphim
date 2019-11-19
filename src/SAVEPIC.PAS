unit savepic;
{ I.A.P 29-11-2002 }
{------------------}
{ A unit that save part of the screen to a IMG file }
{ The format is very simple - just the data         }
interface
uses graph,general,mousebx;

const
  headr:string='BMvX'#0#0#0#0#0'v'#0#0#0'('#0#0#0;
  s1=#0#0;
  s2=#0#0''#0''#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0;
	palettestr=#0#0#0#0'¯'#0#0#0#0'®'+
	           #0#0'¯®'#0#0#0#0'¬'#0'¯'#0'¬'#0#0'®¬'#0'¯®¬'#0'PPP'#0'ÿPP'#0'PþP'#0'ÿþP'#0'PPü'#0'ÿPü'#0'Pþü'#0'ÿþü'#0;

type
	fob=file of byte;

procedure saveimg(x1,y1,x2,y2:integer;filename:string8);
procedure loadimg(x1,y1:integer;filename:string8);
procedure savebmp(x1,y1,x2,y2:integer;filename:string8);
procedure loadbmp(x1,y1:integer;filename:string8);
procedure saverawdata(x1,y1,x2,y2:integer;var f:fob);
procedure loadrawdata(x1,y1,x2,y2:integer;var f:fob);

implementation
{ write a string to a file byte by byte }
procedure writestr(var f:fob;st:string);
var b,i:byte;
begin
	for i := 1 to length(st) do begin
    b :=ord(st[i]);
		write(f,b);
  end;
end;

{ saves theimg without the headr to the disk }
procedure saverawdata;
var
	x,y:word;
  mxcolor:byte;
  b,b2:byte;
begin
  mxcolor := getmaxcolor;
  for y := y2 downto y1 do begin
    x := x1;
    while x <= x2 do  begin
      b :=getpixel(x,y);
      if mxcolor <= 16 then begin
        inc(x);
				b2 := getpixel(x,y);
	      b := b2 + b shl 4;
      end;
    	write(f,b);
      inc(x);
    end;
  end;
end;

{load raw data from file without the header and draw it }
procedure loadrawdata;
var
	x,y:word;
  mxcolor:byte;
  b,b2:byte;
begin
  mxcolor := getmaxcolor;
  for y := y2 downto y1 do begin
  	x := x1;
  	while x <= x2 do begin
      read(f,b);
      if mxcolor <= 16 then begin
        b2 := b shr 4;
  	  	putpixel(x,y,b2);
        inc(x);
      end;
    	putpixel(x,y,b);
      inc(x);
    end;
  end;
end;

{ save 'IAG' format }
{ simple format -   }
{  width LB/width HB/Hight LB/hight/HB/raw data }
procedure saveimg;
var
	savefile:fob;
  sxh,sxl,syh,syl:byte;
	x,y:word;
begin
	assign(savefile,filename+'.iag');
  rewrite(savefile);
  x := x2-x1;
  y := y2-y1;
  sxl := x shr 8;
  sxh := x;
  syl := y shr 8;
  syh := y;
  write(savefile,sxh);
  write(savefile,sxl);
  write(savefile,syh);
  write(savefile,syl);
  saverawdata(x1,y1,x2,y2,savefile);
  close(savefile);
end;

{ load 'IAG' format }
procedure loadimg;
var
	savefile:fob;
  sxh,sxl,syh,syl:byte;
	x,y:word;
  x2,y2:word;
begin
	assign(savefile,filename+'.iag');
  reset(savefile);
  read(savefile,sxh);
  read(savefile,sxl);
  read(savefile,syh);
  read(savefile,syl);
  x2 := sxl;
  x2 := x2 shl 8;
  x2 := x2+sxh;
  y2 := syl;
  y2 := y2 shl 8;
  y2 := y2+syh;
  x2 := x2+x1;
  y2 := y2+y1;
  loadrawdata(x1,y1,x2,y2,savefile);
  close(savefile);
end;

{ save 'BMP' format }
procedure savebmp;
var
	savefile:fob;
  sxh,sxl,syh,syl:byte;
	x,y:word;
begin
	assign(savefile,filename+'.bmp');
  rewrite(savefile);
  x := x2-x1;
  y := y2-y1;
  sxl := x shr 8;
  sxh := x;
  syl := y shr 8;
  syh := y;
  writestr(savefile,headr);
  write(savefile,sxh);
  write(savefile,sxl);
  writestr(savefile,s1);
  write(savefile,syh);
  write(savefile,syl);
  writestr(savefile,s2+palettestr);
  saverawdata(x1,y1,x2,y2,savefile);
  close(savefile);
end;

{ load 'BMP' format }
procedure loadbmp;
var
	savefile:fob;
  sxh,sxl,syh,syl:byte;
	x,y:word;
  x2,y2:word;
  b:byte;
begin
	assign(savefile,filename+'.bmp');
  reset(savefile);
  for x := 1 to length(headr) do read(savefile,b);
  read(savefile,sxh);
  read(savefile,sxl);
  for x := 1 to length(s1) do read(savefile,b);
  read(savefile,syh);
  read(savefile,syl);
  for x := 1 to length(s2) do read(savefile,b);
  for x := 1 to length(palettestr) do read(savefile,b);
  x2 := sxl;
  x2 := x2 shl 8;
  x2 := x2+sxh;
  y2 := syl;
  y2 := y2 shl 8;
  y2 := y2+syh;
  x2 := x2+x1;
  y2 := y2+y1;
  loadrawdata(x1,y1,x2,y2,savefile);
  close(savefile);
end;
end.