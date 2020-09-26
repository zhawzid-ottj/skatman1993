
(*                                                                         *)
(*    TOOLS Unit fÅr verschiedene Zwecke...                                *)
(*                                                                         *)
(*    Copyright (C) 1993 by                 J a k o b   O t t              *)
(*              Alle Rechte vorbehalten.                                   *)
(*                                                                         *)
(*    Diese Unit enthÑlt viele wichtige Unterroutinen und Funktionen.      *)
(*                                                                         *)

{$M $4000,$0,$80000 }   { 16K stack, no heap }

UNIT tools;

(**************************************************************************)
                                INTERFACE
(**************************************************************************)


uses CRT,DOS;

type s80=string[80];
type s160=string[160];
TYPE FS=s80;
TYPE allowcode=SET OF CHAR;
TYPE inparmtype=RECORD
     x,y,l : byte;              (* X-Pos,Y-Pos,LÑnge            *)
     MODE  : byte;              (* M=0..ohne Rahmen; M=1..mit   *)
     s,tit,help : s80;          (* Feldstring, Feldtitel, Onlinehelp *)
     c1,c2 : byte;              (* Vorder- und Hintergrundfarbe *)
     cx    : byte;              (* Cursorposition               *)
     allow : allowcode;         (* Tabelle mit erlaubten Tasten *)
     ta:byte;
END;

const space='                                                                               ';
const maxparm=15;

type inarraytype=array[0..maxparm] of inparmtype;

VAR     INPARM  : inarraytype;      (* Globales Parameter-Struktur-Array *)
VAR     LAST    : byte;



  TYPE
    bildschirm = ARRAY [1..25, 1..80] OF
                   RECORD
                     ch : CHAR;  attr : BYTE;
                   END;
  VAR
    scr : ^bildschirm;
    wa   : array[1..4] of record
                xa,ya,xb,yb,cx,cy,ta:byte;
           end;

var cols:BOOLEAN;
    tat:byte;

type
     bildtyp     = ^word;
     btyp        = array[1..4000] of char;
     setoftype   = set of char;

     type
       bildzeiger = ^word;
     const
       scrseg: word = $B800;
     var
       basis : bildzeiger;

     const
       VStdCursor=$0509;
       VAltCursor=$0009;
       VDosCursor=$0609;
       VNoCursor =$1000;
     const
       HStdCursor=$0505;
       HAltCursor=$0109;
       HNoCursor =$0100;


     VAR
       Regs: registers;
       rb  : registers;

         bild     : btyp absolute $b800:0000;

     const p_init     = #27'@'#27'p0'#18#10#13;   { Drucker: ESC-Sequenzen }
           p_lq       = #27+'x'#1;
           p_draft    = #27+'x'#0;
           p_smallon  = #27#15;
           p_smalloff = #18;
           p_faton    = #27#69;
           p_fatoff   = #27#70;
           p_standard = #27+'t0';
           p_ibm      = #27+'t1';
           p_kursivon = #27#4;
           p_kursivoff= #27#5;

     var cx,cy:byte;



procedure Invers;
procedure Hell;
procedure Normal;
procedure wrtxy(xx, yy : BYTE; s : s80);
procedure Rahmen(x1, y1, x2, y2, art : INTEGER;titel : s80);
procedure swrite(s:s80;d:byte);
procedure swriteln(s:s80;d:byte);
procedure col(c1,c2:byte);                             { Textfarben  }
procedure sline(s:string;c1:byte);
procedure ssline(s:string;c1,c2:byte);
function  FileExists(FileName: string) :BOOLEAN;       { Existiert Datei? }
function  DirExists(dn:s80):BOOLEAN;                   { Existiert Pfad?  }
procedure winopen(nr,x1,y1,x2,y2,xx1,yy1,xx2,yy2,cf,cb:byte;title:s80);
procedure winclose(nr:byte);                           { Screen schliessen }
procedure infowin(ypos,x1,y1,x2,y2:byte;s,title:s80;cf,cb:byte);
procedure infoclose;
procedure waitinfo(x1,y1,x2,y2:byte;s:s80;c1,c2:byte);
function  cutspace(sss:s80):s80;       { Spaces vorn u. hinten abschneiden }
procedure center(st:s80;l,b,c1,c2:byte);        { Zeile zentriert ausgeben }
function  datumheute:s80;   { Akt. Datum als "tt.mm.jjj" in string zurÅck }
function  Zeitjetzt:s80;    { Akt. Zeit  als "hh:mm:ss"  in string zurÅck }
function  doup(var s:s80):s80;              { String "upcase" machen }
function  checkprin:s80;                     { Drucker Åberwachen }
function  print(var pr:boolean;var fd:text;s:s80):boolean; { String drucken }
function  janein:BOOLEAN;
function  taste(se:setoftype):char;
function  GetCursor:word;
PROCEDURE SetCursor(mode: word);
procedure savescr(nr:byte);      {    nr = 1..3    }
procedure restorescr(nr:byte);   {    nr = 1..3    }
PROCEDURE NEWMASK(VAR last:byte;ix,iy,il,imode:byte;is,itit,ihelp:fs;ic1,ic2:byte;iallow:allowcode);
PROCEDURE MASKRESET(VAR LAST:byte);
PROCEDURE MASKINIT(LAST:byte);
FUNCTION  MASKINPUT(LAST,POS:byte):BOOLEAN;
function  newinput(s:s80;l:byte;help:fs;c1,c2:byte;iallow:allowcode):s80;
function  intinput(am,min,max:integer;help,error:fs;c1,c2:byte):integer;
function  wait5(s:s80;t:boolean):char;
procedure delstat(c:byte);
function  readkey:CHAR;
procedure scroll(dir:boolean;x1,y1,x2,y2:byte);
procedure fc(c:byte);
procedure bc(c:byte);
procedure scol(c1,c2:byte);
procedure unscol;
procedure capwrite(s:s160;c1,c2:byte);
procedure capwriteln(s:s160;c1,c2:byte);
procedure cwrite(s:s80;c:byte);
procedure cwriteln(s:s80;c:byte);
procedure timeinfo(x,y,c1,c2:byte);
procedure dateinfo(x,y,c1,c2:byte);
procedure baba;


(**************************************************************************)
                               IMPLEMENTATION
(**************************************************************************)

procedure timeinfo(x,y,c1,c2:byte);
var s:s80;
begin
         scol(c1,c2);
         s:='';
         while not keypressed do begin
               if zeitjetzt<>s then begin
                  s:=zeitjetzt;
                  wrtxy(x,y,s);
               end;
         end;
         unscol;
end;

procedure dateinfo(x,y,c1,c2:byte);
var s1,s2:s80;
begin
         scol(c1,c2);
         s1:='';
         s2:='';
         while not keypressed do begin
               if zeitjetzt<>s1 then begin
                  s1:=zeitjetzt;
                  wrtxy(x+10,y,' - '+s1);
                  if datumheute<>s2 then begin
                     s2:=datumheute;
                     wrtxy(x,y,s2);
                  end;
               end;
         end;
         unscol;
end;



  PROCEDURE Invers; BEGIN textattr := 112; END;
  PROCEDURE Hell;   BEGIN textattr := 15;  END;
  PROCEDURE Normal; BEGIN textattr := 7;   END;

PROCEDURE Rahmen(x1, y1, x2, y2, art : INTEGER;titel : s80);
VAR
  i,t : BYTE;  k : STRING[6];
BEGIN
  CASE art of
    1: k := '⁄ø¿Ÿƒ≥';
    2: k := '…ª»ºÕ∫';
  END;
  t:=textattr;
  fc(black);
  Wrtxy(x1, y1, k[1]);
  FOR i := x1 + 1 TO x2 - 1 DO Wrtxy(i, y1, k[5]);
  Wrtxy(x2, y1, k[2]);  Wrtxy(x1, y2, k[3]);
  FOR i := x1 + 1 TO x2 - 1 DO Wrtxy(i, y2, k[5]);
  Wrtxy(x2, y2, k[4]);
  FOR i := y1 + 1 TO y2 - 1 DO BEGIN
    Wrtxy(x1, i, k[6]);  Wrtxy(x2, i, k[6]);
  END;
  IF (titel <> '') AND (Length(titel) < x2 -x1) THEN
    Wrtxy(x1 + ((x2-x1-Length(titel)) DIV 2)+1,y1,titel);
  textattr:=t;
END;


procedure Wrtxy(xx, yy : BYTE; s : s80);
var
  i : BYTE;
begin
  Dec(xx);
  for i := 1 to Length(s) do begin
    scr^[yy,xx+i].ch := s[i];
    scr^[yy,xx+i].attr := textattr;
  end;
end;

procedure swrite(s:s80;d:byte);
var i,t:byte;
    a:char;
begin
     t:=TEXTATTR;
     write(' ');
     for i:=1 to length(s) do begin
         textattr:=t;
         gotoxy(wherex-1,wherey);
         write(s[i]);
         textattr:=textattr or 240;
         write('±');
         if (not keypressed) and (i mod 5=0) then
            begin sound(200); delay(1); nosound;
         end;
         if not keypressed then delay(d);
     end;
     textattr:=t;
     gotoxy(wherex-1,wherey);
     write(' ');
     gotoxy(wherex-1,wherey);
end;
procedure swriteln(s:s80;d:byte);
begin
    swrite(s,d);
    sound(2000);delay(10);nosound;
    writeln;
end;

function GetCursor:word;
  Begin
    Regs.AH:= $03;
    intr($10, Regs);
    GetCursor:= Regs.CX
  end;

PROCEDURE SetCursor(mode: word);
  Begin
    Regs.AH:= $01;
    Regs.BH:= $00;
    Regs.CX:= mode;
    intr($10, Regs);
  end;


const max = 50;

procedure sline(s:string;c1:byte);
begin
     ssline(s,c1,lightgray);
end;

procedure ssline(s:string;c1,c2:byte);
    var i,j:integer;
begin
   i:=0;
   j:=80-(length(s)+2);
   repeat
      bild[3841+i]:='Ø';
      bild[3841+i+1]:=#112;
      bild[3999-i]:='Æ';
      bild[4001-i-1]:=#112;
      i:=i+2
   until i>=j;
   center('> '+s+' <',25,80,c1,c2);
end;

function janein:BOOLEAN;
var a:char;
begin
   repeat
          setcursor(Valtcursor);
          a:=upcase(readkey);
          setcursor(vnocursor);
   until a in [#13,#27,'J','N'];
   if a in[#13,'J'] then
      janein:=TRUE
   else janein:=FALSE;
end;

function taste(se:setoftype):char;
var a:char;
    ccu:word;
begin
   repeat
      if keypressed then a:=readkey;
   until not keypressed;
   ccu:=getcursor;
   repeat
          setcursor(Valtcursor);
          a:=upcase(readkey);
   until a in se;
   setcursor(ccu);
   taste:=a;
   if keypressed then a:=readkey;
end;

procedure col(c1,c2:byte);
begin
     fc(c1);
     bc(c2);
end;

function FileExists(FileName: string) :BOOLEAN;
      var f: text;
      begin
           {$I-}
           Assign(f, FileName);
           Reset(f);
           Close(f);
           {$I+}
           FileExists := (IOResult = 0) and
           (FileName <> '');
    end;  { FileExists }

function DirExists(dn:s80):BOOLEAN;
  var
  f: file;
  attr: Word;
  begin
       Assign(f, dn);
       GetFAttr(f, attr);
       DirExists:=FALSE;
       if (attr and Directory <> 0) or (dn='') then
          DirExists:=TRUE;
end;


procedure winopen(nr,x1,y1,x2,y2,xx1,yy1,xx2,yy2,cf,cb:byte;title:s80);
var i:integer;
    pp:integer;
          begin
          with wa[nr] do begin
               xa:=xx1;
               ya:=yy1;
               xb:=xx2;
               yb:=yy2;
               cx:=wherex;
               cy:=wherey;
               ta:=textattr;
          end;
          window(1,1,80,25);
          savescr(nr);
          cx:=WHEREX;
          cy:=WHEREY;
          col(darkgray,black);
          for i:=1 to (y2+1)-y1 do begin
              gotoxy(x2+2,i+y1);
              pp:=160*(wherey-1)+2*(wherex-1)+1;
              if bild[pp]<>#32 then
                 write(bild[pp])
              else write('∞');
          end;
          gotoxy(x1+1,y2+2);
          for i:=1 to x2-x1+2 do begin
              pp:=160*(wherey-1)+2*(wherex-1+i);
              bild[pp]:=#8;
              if bild[pp-1]=#32 then bild[pp-1]:=#176;
          end;
          col(cf,cb);
          rahmen(x1,y1,x2+1,y2+1,2,title);
          col(cf,cb);
          window(x1+1,y1+1,x2,y2);
          clrscr;
end;

procedure winclose(nr:byte);
          begin
          window(1,1,80,25);
          restorescr(nr);
          with wa[nr] do begin
               window(xa,ya,xb,yb);
               gotoxy(cx,cy);
               textattr:=ta;
          end;
          delay(100);
end;


procedure infowin(ypos,x1,y1,x2,y2:byte;s,title:s80;cf,cb:byte);
var x,l:byte;
    a:char;
begin
     l:=length(s)+2;
     x:=40-(length(s) div 2)-2;
     if x<1 then x:=1;
     if l>79 then l:=79;
     winopen(3,x,ypos,x+l,ypos+1,x1,y1,x2,y2,cf,cb,title);
     gotoxy(2,2);
     write(s);
end;

procedure infoclose;
begin
     winclose(3);
end;

procedure waitinfo(x1,y1,x2,y2:byte;s:s80;c1,c2:byte);
var a:char;
begin
     infowin(12,x1,y1,x2,y2,s,'INFO',c1,c2);
     a:=wait5('',false);
     infoclose;
end;

function cutspace(sss:s80):s80;    {Spaces vorn u. hinten abschneiden}
    var i,j,k:byte;
    begin
         if sss>'' then begin
            i:=1; j:=0; k:=0;
            repeat
                  if sss[i]<>' ' then j:=i;
                  inc(i);
            until ((j<>0) or (i>length(sss)));
            i:=length(sss);
            repeat
                  if sss[i]<>' ' then k:=i;
                  dec(i);
            until((k<>0) or (i<1));
            cutspace:=copy(sss,j,k);
       end else cutspace:='';
end;

procedure center(st:s80;l,b,c1,c2:byte);        {Zeile zentriert ausgeben}
          var cx,cy:byte;
              t:byte;
          begin
          t:=textattr;
          col(c1,c2);
          wrtxy((b div 2)-(length(st) div 2)+1,l,st);
          textattr:=t;
end;


function print(var pr:boolean;var fd:text;s:s80):boolean;
var err,err2:s80;
    a:char;
    res:WORD;
begin
  a:=#0; err2:='';
  err:='OK';
  repeat
    print:=TRUE;
    if pr=TRUE then
       err:=checkprin;
    if (pr=FALSE) or (err='OK') then begin
       {$I-}
       writeln(fd,s);
       {$I+}
       res:=IOResult;
    end;
    if (res<>0) and (err='OK') then err:='ZielgerÑt/-datei spricht nicht an.';
    if (err<>'OK') then begin
       print:=FALSE;
       if err<>err2 then sline(err+' <ESC>=Abbruch.',black);
       err2:=err;
       if keypressed then a:=crt.READKEY;
    end;
    until (pr=FALSE) or (err='OK') or (a=#27);
    if a=#27 then pr:=FALSE;
end;


function checkprin:s80;
var reg:registers;
begin
     checkprin:='OK';
     reg.dx:=0;
     reg.ax:=$0200;
     intr($17,reg);
     if (reg.ah and 16)=00 then checkprin:='Drucker ist AUS oder OFFLINE. Bitte korrigieren.';
     if (reg.ah and 32)=32 then checkprin:='Kein Papier mehr. Bitte neues Papier einlegen.';
     if (reg.ah and 128)=0 then checkprin:='Drucker ist im Moment beschÑftigt.';
     if (reg.ah and 1)=1 then checkprin:='Drucker reagiert nicht (ZeitÅberlauf)';
end;

function doup(var s:s80):s80;
var i:byte;
begin
     for i:=1 to length(s) do
         if not(s[i] in ['Ñ','î','Å']) then
            s[i]:=upcase(s[i])
         else case s[i] of
                 'Ñ': s[i]:='é';
                 'î': s[i]:='ô';
                 'Å': s[i]:='ö';
              end;
         doup:=s;
end;

function datumheute:s80;
var s1,s2:s80;
    y,m,d,dow:word;
begin
  GetDate(y,m,d,dow);
  str(d,s1);
  s2:=copy('0'+s1,length(s1),2)+'.';
  str(m,s1);
  s2:=s2+copy('0'+s1,length(s1),2)+'.';
  str(y,s1);
  s2:=s2+s1;
  datumheute:=s2;
end;


function Zeitjetzt:s80;
var s1,s2:s80;
    h,m,s,dow:word;
begin
  Gettime(h,m,s,dow);
  str(h,s1);
  s2:=copy('0'+s1,length(s1),2)+':';
  str(m,s1);
  s2:=s2+copy('0'+s1,length(s1),2)+':';
  str(s,s1);
  s2:=s2+copy('0'+s1,length(s1),2);
  Zeitjetzt:=s2;
end;

function kompo(nr:byte):bildzeiger;
var
  offset: word;
begin
  offset:=nr * $1000;
  kompo:=ptr(scrseg,offset);
end;

procedure savescr(nr:byte);
begin
  move(basis^,kompo(nr)^,4096);
end;

procedure restorescr(nr:byte);
begin
  move(kompo(nr)^,basis^,4096);
end;

PROCEDURE NEWMASK(VAR last:byte;ix,iy,il,imode:byte;is,itit,ihelp:fs;ic1,ic2:byte;iallow:allowcode);
          const defcode=([' '..'~',#128..#175,#224..#254]);
          begin
          inc(LAST);
          with inparm[LAST] do begin
               ta:=textattr;
               x:=ix;
               y:=iy;
               l:=il+1;
               mode:=imode;
               s:=is;
               tit:=itit;
               help:=ihelp;
               c1:=ic1;
               c2:=ic2;
               cx:=1;
               if iallow=[] then iallow:=defcode;
               allow:=iallow;
          end;
END;

PROCEDURE MASKRESET(VAR LAST:byte);
          begin
               LAST:=0;
          end;

PROCEDURE FRAME(POS,M:byte);
          var lo,ro,lu,ru,b,h,lp,rp,bc  : char;
                               ksp,spa,lin  : fs;
                               mer,t    : byte;
                               star     : s80;
          begin
               fillchar(star,81,'*');
               star[0]:=#80;
               t:=textattr;
               BC:='˙';
               if m=0 then begin lo:='⁄'; ro:='ø'; lu:='¿'; ru:='Ÿ';
                                  b:='ƒ'; h:='≥';  lp:='˘'; rp:='˘'    end;
               if m=1 then begin lo:='…'; ro:='ª'; lu:='»'; ru:='º';
                                  b:='Õ'; h:='∫'; ;lp:=#16; rp:=#17    end;
               fillchar(spa,80,bc);
               fillchar(ksp,80,' ');
               fillchar(lin,80,b);
               with INPARM[POS] do begin
                    case m of
                       1: col(c1,c2);
                       else begin
                            if mode<>4 then textattr:=ta
                            else col(black,lightgray);
                       end;
                    end;

                    gotoxy(x,y);
                    if mode<=1 then write (s)
                    else if mode=2 then write(copy(star,1,length(s)))
                    else if (mode=3) or (mode=4) then begin
                         gotoxy(x,y);
                         write(copy(ksp,1,l-1));
                         gotoxy(x+(l div 2)-(length(s) div 2)-1,y);
                         write(s);
                    end;
                    if mode<3 then write(copy(spa,1,l-1-length(s)));
                    if (MODE=1) or (MODE=3) then begin
                       gotoxy(x-1,y-1);
                       write(lo,copy(lin,1,l-1),ro);
                       if tit>'' then gotoxy(x+(L DIV 2)-((length(tit)+5) DIV 2),y-1);
                       write(lp,' ',tit,' ',rp);
                       gotoxy(x-1,y+1);write(lu,copy(lin,1,l-1),ru);
                       gotoxy(x+L-1,y); write(h);
                       gotoxy(x-1,y); write(h);
                    END;
                    if (mode=0) or (mode=2) then begin
                       if tit>'' then begin
                          if m=1 then
                             col(c1,c2)
                          else
                             textattr:=ta;
                          mer:=x-length(tit)-2;
                          gotoxy(mer,y);
                          write(tit+': ');
                       end;
                    end;
                    if m=1 then
                       sline(help,black);
                    textattr:=ta;
               END;

END;


PROCEDURE MASKINIT(LAST:byte);

          var       i   : byte;
begin
          for i:=1 to LAST do
                   FRAME(i,0);
END;


FUNCTION MASKINPUT(LAST,POS:BYTE):BOOLEAN;

var i,j,k,tattr,wx,wy : byte;
einf,maxx : byte;
      spa : fs;
      a,b : char;
      bc  : char;
      acu,scu,cu  : word;
      star:s80;

      sav : array[1..maxparm] of INPARMTYPE;

const defcode=([' '..'~',#128..#175,#228..#254]);

BEGIN
     wx:=wherex;
     wy:=wherey;
     tattr:=textattr;
     fillchar(star,81,'*');
     star[0]:=#80;
     for i:=1 to maxparm do
         SAV[i]:=INPARM[i];

     einf:=1;
     cu:=GetCursor;
     if LASTMODE =7 then begin acu:=HAltCursor; scu:=HStdCursor; end;
     if LASTMODE<>7 then begin acu:=VAltCursor; scu:=VStdCursor; end;
     SetCursor(scu);
     repeat
        FRAME(POS,1);
        with INPARM[POS] do begin
          bc:='˙';
          fillchar(spa,80,bc);
          col(c1,c2);
          gotoxy(x+cx-1,y);
          maxx:=length(s);
          repeat
            if mode<3 then begin
                 if einf=1 then setcursor(scu)
                 else setcursor(acu);
                 a:=CRT.readkey;
                 setcursor(vnocursor);
                 b:=#0;
                 if a=#0 then b:=CRT.readkey;
                    if a=#0 then begin
                       if ((b=#75)  and (cx>1)) then DEC(cx);
                       if ((b=#77)  and (cx<=maxx)) then INC(cx);
                       if (b=#115) or (b=#71) then cx:=1;
                       if (b=#116) or (b=#79) then cx:=maxx+1;
                       if (b=#6)   then begin
                          s:=''; cx:=1; maxx:=0; gotoxy(x,y);
                          write(copy(spa,1,l-1));
                       end;
                       if ((b=#83) AND (LENGTH(S)>=cx)) then begin
                          DELETE(s,cx,1);
                          if mode<>2 then write(copy(s,cx,l-cx),BC)
                          else
                             write(copy(star,cx,length(s)-cx+1),BC);
                          dec(maxx);
                       END;
                       if (b=#82) then begin
                          EINF:=1-EINF;
                          if einf=1 then SetCursor(scu)
                             else SetCursor(acu);
                       end;
                    END;
                 if ((a=#8) and (cx>1)) then begin
                    DELETE(s,cx-1,1);
                    gotoxy(wherex-1,wherey);
                    if mode<>2 then write(copy(s,cx-1,l-cx+1))
                    else
                       write(copy(star,cx-1,length(s)-cx+2));
                    if cx<=l then write(BC);
                    dec(cx);
                    dec(maxx);
                 END;
                 if  ((a IN allow)
                 and (cx<l)) then begin
                    if einf=1 then begin
                       INSERT(a,s,cx); inc(maxx);
                       s:=copy(s,1,l-1);
                       if mode<>2 then write(copy(s,cx,l-cx))
                       else
                          write(copy(star,cx,length(s)-cx+1));
                       maxx:=length(s);
                    end;
                    if einf=0 then begin
                       s:=copy(s,1,cx-1)+a+copy(s,cx+1,l-cx);
                       if mode<>2 then write(copy(s,cx,l-cx))
                       else
                          write(copy(star,cx,length(s)-cx+1));
                    end;
                    inc(cx);
                 end else begin
                 end;
                 gotoxy(x-1+cx,y);
                 if (pos=Last) and (a=#13) then begin
                    b:=#60;
                    a:=#0;
                 end;
               end else begin
                  setcursor(vnocursor);
                     a:=CRT.readkey;
                     b:=#0;
                     if a=#0 then b:=CRT.readkey;
                     if a=#0 then begin
                        if b=#75 then b:=#72;
                        if b=#77 then b:=#80;
                     end;
                     if a=#13 then begin
                        b:=#60;
                        a:=#0;
                     end;
            end;
          until ((a IN [#13,#27,#9]) or (b IN [#60,#15,#72,#80]));

          if (b<>#60) or (mode<3) then FRAME(POS,0);
          if ((a=#9)  or (a=#13) or (b=#80))  then INC(POS);
          if ((b=#15) or (b=#72))             then DEC(POS);
          if POS>LAST then POS:=1;
          if POS<1    then POS:=LAST;
          if a=#13 then INPARM[POS].cx:=1;
        END;
     until ((a=#27) or (b=#60));
     setcursor(cu);
     inparm[0]:=inparm[pos];
     inparm[0].cx:=pos;
     if a=#27 then begin
        (* for i:=1 to maxparm do INPARM[i]:=SAV[i]; *)
        MASKINPUT:=FALSE;
     end else
        MASKINPUT:=TRUE;
     textattr:=tattr;
     gotoxy(wx,wy);
  END;


function newinput(s:s80;l:byte;help:fs;c1,c2:byte;iallow:allowcode):s80;
var
    fl:BOOLEAN;
    sx,sy:byte;
begin
     maskreset(LAST);
     sx:=wherex;
     sy:=wherey;
     if sy=25 then begin
        writeln;
        writeln;
        dec(sy,2);
     end;
     newmask(LAST,sx,sy,l,0,s,'',help,c1,c2,iallow);
     maskinit(LAST);
     fl:=maskinput(LAST,1);
     if fl=true then newinput:=inparm[1].s
     else newinput:='';
     gotoxy(sx,sy);
end;

procedure baba;
var i:byte;
begin
    for i:=0 to 1 do begin
        sound(220-i*110);
        delay(150);
    end;
    nosound;
end;


function intinput(am,min,max:integer;help,error:fs;c1,c2:byte):integer;
var inte:longint;
    code:integer;
    i,sx,sy:byte;
    s:s80;
    a:char;
begin
     sx:=wherex;
     sy:=wherey;
     repeat
        gotoxy(sx,sy);
        s:='';
        {if am<>0 then} str(am,s);
        s:=newinput(s,6,help,black,lightgray,['0'..'9','-']);
        val(s,inte,code);
        if (inte<min) or (inte>max) then code:=1;
        if s='' then begin
           code:=0;
           inte:=0;
        end;
        if code<>0 then begin
           sline(error,black);
           baba;
           a:=wait5('',FALSE);
        end;
     until code=0;
     intinput:=inte;
end;



procedure delstat(c:byte);
var ttt:byte;
begin
     ttt:=textattr;
     bc(c);
     wrtxy(1,25,space+' ');
     textattr:=ttt;

end;


function readkey:CHAR;
begin
   while keypressed do
         readkey:=crt.readkey;
   setcursor(Valtcursor);
   readkey:=CRT.readkey;
   setcursor(Vnocursor);
end;

function wait5(s:s80;t:boolean):char;  { 5 Sekunden Pause }
var xx,xy,i:byte;
    da,db,dc,dd:word;
    a:char;
begin
    if t=TRUE then begin
       fc(LIGHTGRAY);
       write(s+' [ ');fc(white);
       write('5');fc(lightgray); write(' ]');
       fc(white);
       xx:=wherex-3;xy:=wherey;
       setcursor(vstdcursor);
    end;
    gettime(db,db,da,db);
    db:=(da+5);
    i:=0;
    repeat
       dd:=da;
       gettime(dc,dc,da,dc);
       if da<>dd then begin
          inc(i);
          if t=TRUE then begin
             gotoxy(xx,xy);write((5-i):1);
          end;
       end;
    until ((i=5) or (keypressed));
    if keypressed then wait5:=CRT.readkey
    else wait5:=#0;
    if t=TRUE then begin
       setcursor(vnocursor);
       gotoxy(1,xy-1);clreol;
       gotoxy(1,xy);clreol;
    end;
end;

procedure scroll(dir:boolean;x1,y1,x2,y2:byte);
var reg:registers;
begin
     if dir=TRUE then reg.ah:=06
     else reg.ah:=07;
     reg.cx:=y1*256+x1;
     reg.dx:=y2*256+x2;
     reg.al:=1;
     reg.bh:=textattr;
     intr($10,reg);
end;

procedure capwrite(s:s160;c1,c2:byte);
var i,t:byte;
    c3:byte;
begin
     t:=textattr;
     if c2<>255 then c3:=c2 else c3:=textattr and 8;
     i:=0;
     while i<length(s) do begin
         inc(i);
         if s[i]='{' then begin
            inc(i);
            c3:=c1;
         end;
         if s[i]='}' then begin
            inc(i);
            c3:=c2;
         end;
         if s[i]='~' then begin
            inc(i);
            fc(c1)
         end else
            fc(c3);
         if i<=length(s) then write(s[i]);
     end;
     textattr:=t;
end;

procedure capwriteln(s:s160;c1,c2:byte);
begin
     capwrite(s,c1,c2);
     writeln;
end;


procedure cwrite(s:s80;c:byte);
var t:byte;
begin
    t:=textattr;
    fc(c);
    write(s);
    textattr:=t;
end;

procedure cwriteln(s:s80;c:byte);
begin
     cwrite(s,c);
     writeln;
end;

procedure scol(c1,c2:byte);
begin
     tat:=textattr;
     fc(c1);
     bc(c2);
end;

procedure unscol;
begin
     textattr:=tat;
end;

procedure fc(c:byte);
begin
     if (cols=TRUE) or (c=black) then
        textcolor(c)
     else begin
        if c and 8=0 then begin
           if (c and 127) in [green,cyan,magenta,red,lightgray] then c:=lightgray;
           if (c and 127) in [blue,brown,darkgray] then c:=darkgray;
        end else begin
           if c in [lightblue,yellow] then c:=lightgray;
           if c<>darkgray then c:=white;
        end;
        textcolor(c)
     end;
end;

procedure bc(c:byte);
begin
     if cols=TRUE then
        textbackground(c)
     else
         begin
              if c in [lightgray,cyan] then textbackground(lightgray)
              else textbackground(black);
         end;
end;


begin
     regs.ah:=$0f;
     intr($10,regs);
     rb:=regs;
     regs.ah:=0;
     regs.al:=3;
     intr($10,regs);
     memw[$40:$4a]:=80;

{ AH = 0F - RETURN CURRENT VIDEO STATE

          ON EXIT :  AL = MODE CURRENTLY SET ( SEE AH = 0 )
                     AH = NUMBER OF CHARACTER COLUMNS ON SCREEN
                     BH = CURRENT ACTIVE DISPLAY PAGE
}


  IF Mem[$40:$49] = 7 THEN begin
                                Scr := Ptr($B000, 0);
                                scrseg:=$B000;
                           end
                      ELSE begin
                                Scr := Ptr($B800, 0);
                                scrseg:=$b800;
                           end;
  basis:=ptr(scrseg,$0000);
  cols:=TRUE;
end
.
