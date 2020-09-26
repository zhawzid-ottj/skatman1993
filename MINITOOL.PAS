
(*                                                                         *)
(*    TOOLS Unit fr verschiedene Zwecke...                                *)
(*                                                                         *)
(*    Copyright (C) 1993 by                 J a k o b   O t t              *)
(*              Alle Rechte vorbehalten.                                   *)
(*                                                                         *)
(*    Diese Unit enth„lt viele wichtige Unterroutinen und Funktionen.      *)
(*                                                                         *)

{$M $4000,$0,$80000 }   { 16K stack, no heap }

UNIT minitool;

(**************************************************************************)
                                INTERFACE
(**************************************************************************)


uses CRT,DOS;

  TYPE
    bildschirm = ARRAY [1..25, 1..80] OF
                   RECORD
                     ch : CHAR;  attr : BYTE;
                   END;
  VAR
    scr : ^bildschirm;


type s80=string[80];
     s160=string[160];
const space='                                                                              ';

var cols:BOOLEAN;
    tat:byte;

procedure wrtxy(xx, yy : BYTE; s : s80);
procedure swrite(s:s80;d:byte);
procedure swriteln(s:s80;d:byte);
procedure col(c1,c2:byte);                             { Textfarben  }
function  FileExists(FileName: string) :BOOLEAN;       { Existiert Datei? }
function  DirExists(dn:s80):BOOLEAN;                   { Existiert Pfad?  }
function  cutspace(sss:s80):s80;       { Spaces vorn u. hinten abschneiden }
procedure center(st:s80;l,b,c1,c2:byte);        { Zeile zentriert ausgeben }
function  datumheute:s80;   { Akt. Datum als "tt.mm.jjj" in string zurck }
function  Zeitjetzt:s80;    { Akt. Zeit  als "hh:mm:ss"  in string zurck }
procedure delstat(c:byte);
procedure fc(c:byte);
procedure bc(c:byte);
procedure scol(c1,c2:byte);
procedure unscol;
procedure capwrite(s:s160;c1,c2:byte);
procedure capwriteln(s:s160;c1,c2:byte);
procedure cwrite(s:s80;c:byte);
procedure cwriteln(s:s80;c:byte);
procedure line;

(**************************************************************************)
                               IMPLEMENTATION
(**************************************************************************)

procedure line;
begin
     writeln(' ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
end;

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


const max = 50;

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

function doup(var s:s80):s80;
var i:byte;
begin
     for i:=1 to length(s) do
         if not(s[i] in ['„','”','']) then
            s[i]:=upcase(s[i])
         else case s[i] of
                 '„': s[i]:='';
                 '”': s[i]:='™';
                 '': s[i]:='š';
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

procedure delstat(c:byte);
var ttt:byte;
begin
     ttt:=textattr;
     bc(c);
     wrtxy(1,25,space+' ');
     textattr:=ttt;

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
  cols:=TRUE;
end.
