unit bxdialog;
{         procedures that ask questions         						}
{         PROGRAMMED BY ITZHAK (c)              						}
{       ---------------------------------------------		    }
{		USE :                                                   }
{			functions:                                            }
{				getyesno(title,yesq,noq,font,size):boolean          }
{					display a massage with a                          }
{					choice : yes or no                                }
{			procedures                                            }
{				getstr(x,y,msgstr,var string)                       }
{					display msgstr at x,y and get input               }
{   ------------------------------------------- 						}
{   UNIT LOG :                                  						}
{   -------------------------------------------						  }
{   23-10- 98 - created with first procedure: 						  }
{				 GetYesNo                      						          }
{       ---------------------------------------------		    }
{   26-10-98 :                                              }
{				Moved From GENERAL.PAS - getyesno                   }
interface
uses drivers,boxes,general{,menugr},mousebx,exbox;

function getyesno(title,yesq,noq:string;af,as:byte):boolean;
function getstr(x,y:integer;msgstr:string;var st1:string):boolean; { gets a string (return false on ESC) }
implementation

function getyesno(title,yesq,noq:string;af,as:byte):boolean;
var
	Quiz:MsgBox;
	YesM,NoM:msgbox;
	c:char;
	answer:(Yes,No,Abort);
	OK,abortB:boolean;
begin
	with quiz do begin
		init(title,swidth div 2,shight div 2 - 50);
		set3D(on,off);
		setbox(on,on);
		setfont(af,as);
		setmcolor(12,7,23);
		Display;
	end;
	with yesM do begin
		init ('YES',swidth div 2 - 50,quiz.y2+20);
    SetTextOffset(-5,-4);
    set3D(on,on);
    setmcolor(14,8,23);
		display;
	end;
	with nom do begin
		init ('NO',swidth div 2 + 50,quiz.y2+20);
    SetTextOffset(-5,-4);
    set3D(on,off);
    setmcolor(15,7,23);
		display;
	end;
	if mouseok and checked then mouse.display;
	answer:=Yes;
	Ok:=false;
	abortB:=false;
	repeat
		getkeyevent(ev);
		with mouse do begin
			if mouseok and checked then update;
			if changed then begin
				if not displayed then display;
				if YesM.isin(x,y) then begin
					mouse.erase;
          with noM do begin
				    set3D(on,on);
    				setmcolor(15,7,23);
          end;
          with yesM do begin
				    set3D(on,on);
    				setmcolor(14,8,23);
          end;
					answer:=yes;
					if pressed[1] then
						OK := true;
					mouse.display;
				end else
 				if noM.isin(x,y) then begin
					mouse.erase;
          with yesM do begin
				    set3D(on,off);
    				setmcolor(15,7,23);
          end;
          with noM do begin
				    set3D(on,on);
    				setmcolor(14,8,23);
          end;
					answer:=no;
					if pressed[1] then
						OK := true;
					mouse.display;
				end;
				if pressed[2] then abortB := true;
			end;
		end;
		if ev.what = evkeydown then begin
			mouse.erase;
			case ev.keycode of
				kbLeft,kbRight,kbTab:
					if YesM.is3Dinverse then begin
	          with yesM do begin
					    set3D(on,off);
    					setmcolor(15,7,23);
      	    end;
        	  with noM do begin
				  	  set3D(on,on);
    					setmcolor(14,8,23);
          	end;
						answer:=no;
					end else begin
	          with noM do begin
					    set3D(on,off);
    					setmcolor(15,7,23);
      	    end;
        	  with yesM do begin
				  	  set3D(on,on);
    					setmcolor(14,8,23);
          	end;
						answer:=yes;
					end;
				kbEnter:ok:=true;
				kbEsc:begin
						answer:=abort;
						abortB:=true;
					end;
			end;
			YesM.display;
			Nom.display;
		end;
	until Ok or AbortB;
	if Ok then begin
		if answer = yes then Getyesno:=true else getyesno := False;
	end;
	quiz.bye;
	YesM.bye;
	Nom.bye;
	mouse.erase;
end;

function getstr(x,y:integer;msgstr:string;var st1:string):boolean;
{ get string from user using MSGBOX }
var
	st:string;
	out:inputbox;

begin
  getstr := true;
	st:=st1;
	with out do begin
		init(msgstr,st,x,y);
		setmcolor(15,0,7);
		setbox(on,off);
		set3D(on,on);
		set3Dmode(inside);
    setallselection;
		display;
	end;
	repeat
		getkeyevent(ev);
		if ev.what <> evnothing then
			out.sendkey(ev);
	until (ev.charcode in[#13,#27]);
	if ev.charcode = #13 then st1:=out.get else begin
    getstr := false;
		st1 := st;
  end;
	out.bye;
end;


end.
