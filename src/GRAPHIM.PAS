{ $A-,B-,D-,E+,F+,G+,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,Y-}
program graphim;
uses initiali,usergr,set_gr,gr_main;

var application:user;
	st:string;
{                                     }
{           MAIN PROGRAM              }
{                                     }
begin
	init;
{ 	intro;}
	if newinterface then begin
  	gr_init;
    gr_run;
    gr_quit;
  end else begin
		application.init;
		application.dothemenu;
  end;
	goodbye;
end.