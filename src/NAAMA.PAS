unit help;
{ this unit writes a help box with context sensitivity   }
{ the help file must be in this format :                 }
{   ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿   }
{   ³Header (the header of all screens)              ³   }
{   ³TOPIC 1 : topic title                           ³   }
{   ³  some words about the topic                    ³   }
{   ³  and more words                                ³   }
{   ³^4this line will be printed in color number 4   ³   }
{   ³  this line will return to be color 15 (WHITE)  ³   }
{   ³END                                             ³   }
{   ³TOPIC 2 : topic title                           ³   }
{   ³  here some sentenses about the 2'nd            ³   }
{   ³  topic                                         ³   }
{   ³END                                             ³   }
{   ³TOPIC 3 : topic title                           ³   }
{   ³  here some sentenses about the 3'rd            ³   }
{   ³  topic                                         ³   }
{   ³END                                             ³   }
{   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   }
interface
uses boxes,general,graph,drivers,objects,dos,set_gr,exbox,mousebx;

const
	{ Errors }
	sbErrOk=0 ; { no errors }
	sbErrNoMemory=1; { Out of memory }

type
	helpbox=object
		page           :byte;
		pages          :byte;
    line           :byte;
		lines          :byte;
		linesinpage    :byte;
		helpFileName   :string;
		HelpTopic      :word;
		HelpFile       :text;
		MainTitle      :msgbox;
		TopicTitle     :msgbox;
		Prompt         :msgbox;
		HelpText       :Msgboxlist;
		good           :boolean;
		topic          :word;
		constructor init(helpname:string;thetopic:word);
		function    gotoTopic(thetopic:word;var topicTtl:string):boolean;
    function    loadpage:boolean; { loads a page, starting from current line in the file }
		function    gotopage(pagenum:byte):boolean;
    function    gotoline(linenum:byte):boolean;
		procedure   proccessline(var theline:string;var color:integer);
		procedure   makelines;
		procedure   display; virtual;
		procedure   hide;
		procedure   userinterface;
		destructor  done;
	end;

implementation
{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
{*          HelpBox OBJECT PROCEDURES        *}
{*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*}
constructor HelpBox.init;
var st:string;
	wid,hit:integer;
	sx1,sx2,sy1,sy2:integer;
begin
	topic := thetopic;
	page := 0;
	helpFIleName       := helpname;
	assign             (HelpFile,HelpFileName);
	reset              (HelpFile);
	readln             (HelpFile,st);
	with maintitle do begin
		init    (st,swidth div 2,20);
		setfont (3,4);
		setmcolor(1,0,2);
		set3d(on,off);
	end;
	if not gotoTopic (topic,st) then begin
		good:=false;
		exit;
	end else good:=true;
	with topictitle do begin
		init       (st,swidth div 2,MainTitle.cy+MainTitle.hight+5);
		setfont    (6,3);
		setmcolor  (14,0,3);
		set3d(on,on);
	end;
	with prompt do begin
		saveback   := false;
		init       ('ENTER OR ESC TO EXIT',swidth div 2,shight-TopicTitle.hight-2);
		setfont    (11,9);
		setmcolor  (10,1,0);
    setjustify(center);
	end;
	with HelpText do begin
		with topictitle do helptext.init('HELP TEXT',cx,cy+10,0); { first is the controll }
    setmcolor(1{DefaultHelpColor},5{DefaultHelpBg},2{DefaultHelpBg},0);
		option(miautoplacey);
    setjustify(left);
		set3d(on,off);
		setbox(on,on);
    setfont(defaultHelpFont,DefaultHelpSize);
    display;
{		setfont(2,7);}
	end;
	makelines;
	wid := Swidth -5;
	hit := 0;
	HelpText.FindBiggest(wid,hit,on);
	page := 1;
end;

function HelpBox.gototopic;
{ read the desired topic (find it first) }
var i,i1,i2  : integer;
		st,st1   : string;
		ok,notok : boolean;
begin
	reset  (HelpFile);
	ok     := false;
	notok  := false;
	repeat
		notok   := seekeof(HelpFile);
		i				:=1;
		readln  (HelpFile,st);
		if not notok then while not eoln(HelpFile) do begin
			 st1    := GetToChar(st,i,[' ',#9],on);
			 for i1 := 1 to length(st1) do st1[i1]:=upcase(st1[i1]);
			 if st1 = 'TOPIC' then begin
					st1   := GetToChar(st,i,[' ',#9],on);
					while st1 <> ':' do begin
						i2    := vali(st1);
						if i2 = thetopic then ok := true;
						st1   := GetToChar(st,i,[' ',#9],on);
					end;
					topicttl:='';
					if ok then for i := i to length(st) do topicttl:=topicttl+st[i];
			 end else break;
		end;
	until ok or notok;
	gototopic := ok;
	if ok then topic := thetopic;
end;

procedure helpBox.proccessline;
{ read a line, and checks the color and allingment }
var i,l:integer;
	c:char;
	st1:string;
  j:just;

function prjustify(s:string):just;
{ Gets : 'center' or 'left' or 'right'
	or any number of first letters from these words
  in any case.
  Returns : justification in JUST type }
var
	st:string;
begin
	st := upstr(s);
  if FindStr(s,'CENTER',0,on) <> 0 then prjustify := center;
  if FindStr(s,'LEFT',0,on)   <> 0 then prjustify := left;
  if FindStr(s,'RIGHT',0,on)  <> 0 then prjustify := right;
end;

begin
	st1 := '';
	color := defaultHelpColor;
	l := length(theline);
	for i := 1 to l do begin
		c := theline[i];
		case c of
			#0..#31:;
      '~':j := prjustify(gettochar(theline,i,[' ',#9,#33..#47,#58..#256],on));
			'@':color := vali(gettochar(theline,i,[' ',#9,#33..#47,#58..#256],on));
			'ş':;
			else st1 := st1+c;
		end;
	end;
	ltrim(st1);
	rtrim(st1);
	theline := st1;
end;

procedure HelpBox.makelines;
{ initialize the lines for the first time }
var st,st1 : string;
	i,clr    : integer;
	x1,y1    : integer;
	x2,y2    : integer;
	ok       : boolean;
  dpage    : boolean;
begin
	clr := 0;
	st   := '';
	ok   := false;
  dpage := false;
  lines := 0;
	settextstyle(DefaultHelpfont,horizdir,DefaultHelpsize);
{  helptext.erase;}
	while not ok do begin
		st := '';
		readln(HelpFile,st);
		st1   :=st;
		for i := 1 to length(st1) do st1[i]:=upcase(st1[i]);
		if st1 = 'END' then ok := true else inc(lines);
		if not DPage then begin
			proccessline(st,clr);
			with helptext do begin
				ok := not insert(st,0,0);
				setmcolor(clr,DefaultHelpBg,DefaultHelpBg,getlastID);
			end;
			helptext.getdims(x1,y1,x2,y2,cornerbox,helptext.getlastID);
			if y2 >= prompt.y1-prompt.hight then begin
				linesinpage := helptext.getlastID;
				dpage := true;
			end;
		end;
	end;
end;

function helpbox.loadpage;
{ load a page into the "textboxes" }
var
	ok:boolean;
  i,i1,clr:integer;
  st1,st:string;

begin
  clr  := 0;
	ok   := false;
	i1 := 0;
	while not ok do begin
		st := '';
		inc(i1);
		readln(HelpFile,st);
		st1   :=st;
		for i := 1 to length(st1) do st1[i]:=upcase(st1[i]);
		if (st1 <> 'END') and (i1 <= linesinpage) then begin
			proccessline(st,clr);
			with helptext do begin
				chngmsg(st,i1);
				setmcolor(clr,DefaultHelpBg,DefaultHelpBg,i1);
			end;
		end else ok := true;
	end;
	if st1 = 'END' then begin
		ok := false;
		dec(i1);
		while not ok do begin
			inc(i1);
			if (i1 <= linesinpage) then HelpText.chngmsg('',i1)
		else ok := true;
		end;
		loadpage := false
	end else begin
		readln(HelpFile,st);
		st1   :=st;
		for i := 1 to length(st1) do st1[i]:=upcase(st1[i]);
		if st1 = 'END' then begin
			ok := false;
			dec(i1);
			while not ok do begin
				inc(i1);
				if (i1 <= linesinpage) then HelpText.chngmsg('',i1)
				else ok := true;
			end;
			loadpage := false
		end else loadpage := true;
	end;
end;

function helpbox.gotopage;
{ read the lines of a page }
{ ("PAGE" is defined as the number of lines displayed) }
var st : string;
	i    : integer;
begin
	st   := '';
	gototopic(topic,st);
  line := (pagenum-1)*linesinpage;
	for i := 1 to line do readln(helpfile);
  gotopage := loadpage;
end;

function helpbox.gotoline;
var st : string;
	i    : integer;
begin
	st   := '';
	gototopic(topic,st);
  page := line div linesinpage+1;
	for i := 1 to linenum do readln(helpfile);
  gotoline := loadpage;
end;


procedure HelpBox.display;
begin
	MainTitle.display;
	TopicTitle.display;
	HelpText.displayall;
	Prompt.display;
end;

procedure HelpBox.hide;
begin
	MainTitle.erase;
	TopicTitle.erase;
	HelpText.erase;
	Prompt.erase;
end;

procedure helpbox.userinterface;
var ok : boolean;
	lastpage : boolean;
	i,i1:word;
	enteresc:string;
	pgdn:string;
	pgup:string;
  kup,kdn :string;
	wid,hit:integer;
begin
	ok := false;
	display;
	i:=1;
	i1:=1;
	lastpage := gotopage(1);
	page := 1;
  line := 1;
	enteresc := 'ENTER OR ESC TO EXIT';
	if page > 1       then pgup := 'PG-UP' else pgup := '-----';
	if lastpage       then pgdn := 'PG-DN' else pgdn := '-----';
  if line < lines-7 then kdn  := 'DN'    else kdn  := '--';
  if line > 1       then kup  := 'UP'    else kup  := '--';
	prompt.chngmsg(kup+'/'+pgup+' | '+pgdn+'/'+kdn+' '+enteresc);
  prompt.autosize := false;
	repeat
		getkeyevent(ev);
		if ev.what = evkeydown then begin
			case ev.keycode of
				kbpgup  : if page > 1 then begin
					dec(page);
					lastpage := gotopage(page);
				end;
				kbpgdn  : if lastpage then begin
					inc(page);
					lastpage := gotopage(page);
				end;
        kbdown  : if line < lines-7 then begin
					inc(line);
					lastpage := gotoline(line);
				end;
        kbup  : if line >= 1 then begin
					dec(line);
					lastpage := gotoline(line);
				end;

				kbenter : ok := true;
				kbesc   : ok := true;
			end;
{			wid := Swidth -5;
			hit := 0;
			HelpText.FindBiggest(wid,hit,on);}
			if page > 1 then pgup := 'PG-UP' else pgup := '-----';
			if lastpage then pgdn := 'PG-DN' else pgdn := '-----';
  		if line < lines-7 then kdn  := 'DN'     else kdn  := '--';
  		if line > 1       then kup  := 'UP'     else kup  := '--';
{			prompt.chngmsg(pgup+'/'+pgdn+' '+enteresc);}
			prompt.chngmsg(kup+'/'+pgup+' | '+pgdn+'/'+kdn+' '+enteresc);
		end;
	until ok;
end;

destructor HelpBox.done;
begin
	MainTitle.bye;
	TopicTitle.bye;
	if good then HelpText.bye;
	Prompt.bye;
	close(helpfile);
end;

end.