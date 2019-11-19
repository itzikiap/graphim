unit help;
{ this unit writes a help box with context sensitivity   }
{ the help file must be in this format :                 }
{   ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿   }
{   ³Header (the header of all screens)              ³   }
{   ³TOPIC 1 : topic title                           ³   }
{   ³  some words about the topic                    ³   }
{   ³  and more words                                ³   }
{   ³^4tthis line will be printed in color number 4  ³   }
{   ³  this line will return to be color 15 (WHITE)  ³   }
{   ³END                                             ³   }
{   ³TOPIC 2 : topic title                           ³   }
{   ³  here some sentenses about the 2'nd            ³   }
{   ³  topic                                         ³   }
{   ³~CtThis line will be centered in the box        ³   }
{   ³~LtThis line will be left alliened              ³   }
{   ³END                                             ³   }
{   ³TOPIC 3 : topic title                           ³   }
{   ³  here some sentenses about the 3'rd            ³   }
{   ³  topic                                         ³   }
{   ³  Notice that you must give a dummy letter after³   }
{   ³	 the color or justify mark                     ³   }
{   ³END                                             ³   }
{   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   }
interface
uses boxes,general,graph,drivers,objects,dos,set_gr,exbox,exbox2,mousebx;

const
	{ Errors }
	sbErrOk=0 ; { no errors }
	sbErrNoMemory=1; { Out of memory }

type
	helpbox=object
    p1						 :pointer;
		page           :byte;
		pages          :byte;
    line           :byte;
		lines          :byte;
		linesinpage    :byte;
		helpFileName   :string;
		HelpTopic      :word;
		HelpFile       :text;
		MainTitle      :^msgbox;
		TopicTitle     :^msgbox;
		Prompt         :^msgbox;
		HelpText       :^Msgboxlist;
		good           :boolean;
		topic          :word;
		constructor init(helpname:string;thetopic:word);
		function    gotoTopic(thetopic:word;var topicTtl:string):boolean;
    function    loadpage:boolean; { loads a page, starting from current line in the file }
		function    gotopage(pagenum:byte):boolean;
    function    gotoline(linenum:byte):boolean;
		procedure   proccessline(var theline:string;var color:integer;var justi:just);
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
{  mark(p1);}
	topic := thetopic;
	page := 0;
  lines := 0;
 	helpFIleName       := helpname;
	assign             (HelpFile,HelpFileName);
	reset              (HelpFile);
	readln             (HelpFile,st);
	if not gotoTopic (topic,st) then begin
		good:=false;
		exit;
	end else good:=true;
  new(maintitle);
	with maintitle^ do begin
		init    (st,swidth div 2,20);
    saveback := false;
		setfont (3,4);
		setmcolor(1,0,2);
		set3d(on,off);
	end;
  getmem(topictitle,sizeof(msgbox));
	with topictitle^ do begin
		init       (st,swidth div 2,MainTitle^.cy+MainTitle^.hight+5);
    saveback := false;
		setfont    (6,3);
		setmcolor  (14,0,3);
		set3d(on,on);
	end;
  getmem(prompt,sizeof(msgbox));
	with prompt^ do begin
		init       ('ENTER OR ESC TO EXIT',swidth div 2,shight-TopicTitle^.hight-2);
		saveback   := false;
		setfont    (11,9);
		setmcolor  (10,1,0);
    setjustify(center);
	end;
  new(helptext);
	with HelpText^ do begin
		init('HELP TEXT',topictitle^.cx,topictitle^.cy+10,0); { first is the controll }
    ismarked := false;
    saveback := false;
    setmcolor(DefaultHelpColor,DefaultHelpBg,DefaultHelpBg,0);
		option(miautoplacey+misamesize);
    setjustify(left);
		set3d(off,off);
		setbox(on,off);
    setfont(defaultHelpFont,DefaultHelpSize);
    settextoffset(0,-4);
    chngdim(0,0,swidth-5,0,centerbox,0);
    autosize := false;
	end;
	makelines;
{	wid := Swidth -5;
	hit := 0;
 HelpText.FindBiggest(wid,hit,on);}
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
  prjustify := right;
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
      '~':justi := prjustify(gettochar(theline,i,[' ',#9,#33..#47,#58..#256],on));
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
  jst      : just;
begin
	clr := 0;
	st   := '';
	ok   := false;
  dpage := false;
  lines := 0;
	settextstyle(DefaultHelpfont,horizdir,DefaultHelpsize);
  helptext^.erase;
	while not ok do begin
		st := '';
		readln(HelpFile,st);
		st1   :=st;
		for i := 1 to length(st1) do st1[i]:=upcase(st1[i]);
		if st1 = 'END' then ok := true else inc(lines);
		if not DPage then begin
			proccessline(st,clr,jst);
			with helptext^ do begin
				ok := not insert(st,0,0);
        setjustify(jst);
				setmcolor(clr,DefaultHelpBg,DefaultHelpBg,getlastID);
			end;
			helptext^.getdims(x1,y1,x2,y2,cornerbox,helptext^.getlastID);
			if y2 >= prompt^.y1-prompt^.hight then begin
				linesinpage := helptext^.getlastID;
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
  jst:just;

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
			proccessline(st,clr,jst);
			with helptext^ do begin
        setjustify(jst);
				setmcolor(clr,DefaultHelpBg,DefaultHelpBg,i1);
				chngmsg(st,i1);
			end;
		end else ok := true;
	end;
	if st1 = 'END' then begin
		ok := false;
		dec(i1);
		while not ok do begin
			inc(i1);
			if (i1 <= linesinpage) then HelpText^.chngmsg('',i1)
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
				if (i1 <= linesinpage) then HelpText^.chngmsg('',i1)
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
	MainTitle^.display;
	TopicTitle^.display;
	HelpText^.displayall;
	Prompt^.display;
end;

procedure HelpBox.hide;
begin
	MainTitle^.erase;
	TopicTitle^.erase;
	HelpText^.erase;
	Prompt^.erase;
end;

procedure helpbox.userinterface;
var ok : boolean;
	lastpage : boolean;
	i,i1:word;
	enteresc:string;
  mouseint:string;
	pgdn:string;
	pgup:string;
  kup,kdn :string;
	wid,hit:integer;
  kp : integer;
begin
	ok := false;
	lastpage := gotopage(1);
	display;
	i:=1;
	i1:=1;
	page := 1;
  line := 1;
	enteresc := 'ENTER OR ESC TO EXIT';
  if mouseok then mouseint := '| MOUSE '+chr(24)+chr(25)+' / PRESS 2-EXIT 1,3-SCROLL';
	if page > 1       then pgup := 'PG-UP' else pgup := '-----';
	if lastpage       then pgdn := 'PG-DN' else pgdn := '-----';
  if line < lines-7 then kdn  := 'DN'    else kdn  := '--';
  if line > 1       then kup  := 'UP'    else kup  := '--';
	prompt^.chngmsg(kup+'/'+pgup+' | '+pgdn+'/'+kdn+' '+enteresc+mouseint);
  prompt^.autosize := false;
	repeat
    kp := 0;
    repeat
      getkeyevent(ev);
			if ev.what = evkeydown then kp := ev.keycode;
      with mouse do begin
      	update;
      	if changed then begin
      		if ymove < -4 then kp := kbup;
      		if ymove > 4 then kp := kbdown;
        	if pressed[1] then kp := kbpgdn;
        	if pressed[3] then kp := kbpgup;
        	if pressed[2] then kp := kbesc;
      	end;
      end;
    until kp <> 0;
		case kp of
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
		if page > 1 then pgup := 'PG-UP' else pgup := '-----';
		if lastpage then pgdn := 'PG-DN' else pgdn := '-----';
 		if line < lines-7 then kdn  := 'DN'     else kdn  := '--';
 		if line > 1       then kup  := 'UP'     else kup  := '--';
		prompt^.chngmsg(kup+'/'+pgup+' | '+pgdn+'/'+kdn+' '+enteresc+mouseint);
	until ok;
end;

destructor HelpBox.done;
begin
	close(helpfile);
	MainTitle^.bye;
	TopicTitle^.bye;
	if good then begin
		HelpText^.free;
    helptext^.bye;
    dispose(helptext)
  end;
	Prompt^.bye;
  freemem(topicTitle,sizeof(msgbox));
  dispose(MainTitle);
  freemem(prompt,sizeof(msgbox));
{	release(p1);}
end;

end.