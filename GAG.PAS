
   (*                Datenbank.. (C) 1992/93 by JAKOB OTT               *)
   (*                ออออออออออออออออออออออออออออออออออออ               *)
   (*                                                                   *)
   (*  All rights reserved. No right to me..? My Rough Slayers to You!  *)
   (*                                                                   *)


unit gag;

INTERFACE

uses crt,tools;

const max = 50;

type bildtyp=array[1..4000] of char;

procedure bfill(a:char;mode:boolean);
procedure farb;
procedure dogag;

IMPLEMENTATION

var  bild : bildtyp absolute $b800:0000;

(*-------------------------------------------------------------------------*)

const f:set of char=[' ','þ','๙','๚'];


procedure bfill(a:char;mode:boolean);
          var i:integer;
          begin
               if mode=TRUE then i:=1 else i:=0;
               i:=i+random(40)*2;
               repeat
               if ((mode=FALSE) or (bild[i] in f)) then bild[i]:=a;
               i:=i+random(40)*2;
          until i>(4095-256);
end;
procedure farb;
var i:integer;
begin
      i:=random(1928)*2+2;
      if (bild[i-1] in f) then bild[i]:=chr(random(13)+2);
end;


procedure dogag;

var a:char;
    i,j:byte;
    k:integer;
    x,y:byte;
begin
savescr(1);
x:=wherex;
y:=wherey;
i:=5;
repeat
farb;bfill('þ',TRUE);
farb;bfill('๙',TRUE);
farb;bfill('๚',TRUE);
farb;bfill(' ',TRUE);
until keypressed;
a:=CRT.readkey;
restorescr(1);
gotoxy(x,y);
end;


begin
end.


