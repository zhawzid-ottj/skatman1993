
UNIT SKATUNIT;

 (*ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ*)
                                  INTERFACE
 (*ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ*)

uses CRT,DOS,tools,gag,pdmenu;

const maxtab=1000;

      type s20=string[20];
      namentyp = array[1..4] of s20;
      modustyp = array[1..4] of s80;
      punktetyp= array[1..4] of integer;            (* Gesamtpunkte     *)
      pufeldtyp= array[1..4,1..1000] of integer;     (* Punktearray      *)
      pupostyp = array[1..4] of integer;            (* Position im Feld *)
      gctyp = array[1..4] of BOOLEAN;               (* Spieler schon GRAND ? *)


type disk=RECORD
          gc:gctyp;
         pup:pupostyp;
         puf:pufeldtyp;
       namen:namentyp;
      punkte:punktetyp;
      spieler,sz,modus,rac,merker,mode,addi,du1,du2,du3,du3a,du3b,du3c:byte;
      du4,du5,du6:word;
      ramsch,doppelt,rageb,pull,choose,du10,du11:boolean;
end;


      const Grand=24;
            GrandOuvert=36;
            Null=23;
            NullHand=35;
            NullOuvert=46;
            NullOuvertHand=59;

            ver='V1.00';
            del=600;


procedure line;
procedure doubleline;
function  aoderb(a,b:char;s1,s2:s20):BOOLEAN;
function  a2oderb2(a,b:char;s1,s2:s20):byte;
function  jaodernein:BOOLEAN;
function  getplayer(s:s80;var namen:namentyp;spieler:byte):byte;
procedure swapint(var i1,i2:integer);
function  neuspiel(var d:disk):byte;
procedure korrektur(var d:disk);
procedure tausch(var d:disk);
procedure tabelle(var d:disk;druck:boolean;var datei:s80);
function  sichern(var d:disk):boolean;
function  laden(var d:disk):BOOLEAN;
function  stringwin(ypos,x1,y1,x2,y2:byte;var s:s80;hilfs:s80):BOOLEAN;
function  intwin(ypos,x1,y1,x2,y2:byte;am,min,max:integer;tit,hilfs,error:s80):integer;
procedure spielerprint(var d:disk);
function  getmodus(mode,addi:byte):s80;
procedure intro(var d:disk;var cols:boolean);
function  askwin(ypos,x1,y1,x2,y2:byte;s1,s2,s3:s80;c1,c2:byte;a1,a2:char):boolean;
function  askwin2(ypos,x1,y1,x2,y2:byte;s1,s2,s3:s80;c1,c2:byte;a1,a2:char):byte;
function  Abrechnung(var am:word;var d:disk):boolean;
procedure attribs(sp:byte;s:s80;var d:disk;var mult,anzahl,trumpf,pu:integer;reiz:word);
procedure help(sf,st:s80);
procedure banner;
procedure clrscr;
procedure clears;
procedure clrlns;
procedure info;
procedure wintest(flag:boolean;sec:byte);
procedure shareware(fl:boolean;sec:byte);
procedure directory;
function  namewin(var d:disk):boolean;
procedure minit(var c:cont;var d:disk);            { Hauptmenue initialisieren }

 (*ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ*)
                               IMPLEMENTATION
 (*ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ*)

procedure minit(var c:cont;var d:disk);            { Hauptmenue initialisieren }
var s:s20;
begin
 menuinit(c);
 addmenu(1,0,'  @SPIEL!','N„chste Skatabrechnung starten',c);
 addmenu(2,0,' @Tabelle ','Abrechnungstabelle einsehen/ausgeben',c);
    additem(2,1,0,'  Tabelle auf @Bildschirm    ','"Ewige Tabelle" auf Bildschirm ausgeben',c);
    additem(2,2,0,'  Tabelle auf @Drucker/Datei ','Tabelle auf Drucker ausgeben oder in Datei exportieren',c);
 addmenu(3,0,'  @Prefs','Hier k”nnen die Voreinstellungen (Pr„ferenzen) eingestellt werden',c);
    additem(3,1,10,'  @Farbbetrieb ','Ist ein Farbmonitor angeschlossen ?',c);
    additem(3,2,10,'  Spieler @w„hlen','Soll der Alleinspieler aus Liste gew„hlt oder eingegeben werden ?',c);
    additem(3,3,10,'  @Ramschautomatik ','Soll bei verlorenem Contra (Re..) automatisch eine Ramsch/Bock-Runde starten ?',c);
    additem(3,4,10,'  Grand mal @2 im Ramsch ','Soll ein verlorener Grand im Ramsch doppelt gewertet werden ?',c);
    additem(3,5,10,'  @Geber-Regel im Ramsch ','Soll, wenn im Ramsch Grand gespielt wird, der jew. Geber nochmals geben ?',c);
    additem(3,6,255,' ','',c);
    str(d.merker,s);
    additem(3,7,0,'  R@amsch/Bock-Runden ('+s+')','Hier steht die Anzahl der noch verbleibenden Ramsch/Bock-Runden !',c);
    additem(3,8,0,'  Spieler@namen ','Hier k”nnen die jeweiligen Spielernamen (ID''s) „ndert werden',c);
    additem(3,9,255,' ','',c);
    additem(3,10,11,'  @Kompaktmodus','Schnellste Art und Weise, mit SKATMANAGER eine Skatabrechnung vorzunehmen',c);
    additem(3,11,11,'  Man@uelle Abrechnung','Abrechnung per Handeingabe der selbst errechneten erreichten Punkte',c);
    additem(3,12,11,'  @Mit/Ohne-Abrechnung','Abrechnung im Modus "Mit/Ohne Buben von links"',c);
    additem(3,13,11,'  M/O..@Spiel-Abrechnung','Abrechnung im Modus "Mit/Ohne.. Spiel"',c);

 addmenu(4,0,' @Manager ','Tausch, Korrektur, Speichern, Laden, Neu, usw. usf.',c);
    additem(4,1,0,'  Spieler@tausch    ','Spielerpositionen tauschen',c);
    additem(4,2,0,'  Spieler@korrektur ','Letztes Spiel korrigieren',c);
    additem(4,3,0,'  @Rollenverteilung ','Rollenverteilung gegen Uhrzeigersinn rotieren',c);
    if d.modus=1 then
        additem(4,4,255,' ','',c)
    else
        additem(4,4,0,'  Ramsch @beenden','Drcken Sie <RETURN>, wenn Sie die laufende Ramsch/Bock-Runde beenden wollen',c);
    additem(4,5,0,'  Spiel/Einstellungen @speichern ','Spielstand und Einstellungen nach Position 1 bis 9 speichern',c);
    additem(4,6,0,'  Spiel/Einstellungen @laden     ','Spielstand und Einstellungen von Position 1 bis 9 laden',c);
    additem(4,7,0,'  @Neues Spiel beginnen','Neues Spiel beginnen (Laufender Spielstand wird gel”scht)',c);
    additem(4,8,255,' ','',c);
    additem(4,9 ,  0,'  Pfennigsk@atabrechung  ','Sieger ermitteln und zu zahlende Betr„ge',c);
    additem(4,10,  0,'  @Hilfstext anzeigen    ','Dokumentation/Anleitung zum Programm und zur Bedienung',c);
    additem(4,11,  0,'  Programm@information   ','Informationen ber "SKATMANAGER '+ver+'" - dieses Programm',c);
 addmenu(5,0,'  @ENDE','SKATMANAGER '+ver+' beenden (Spielstand gespeichert ?)',c);
end;

function namewin(var d:disk):boolean;
var s:s80;
    flag,fl:boolean;
    co,j,i:byte;
    a:char;
    sa:array[1..4] of string[20];
begin
   with d do begin
      for i:=1 to spieler do sa[i]:=namen[i];
      winopen(2,28,15,53,18+spieler-3,1,1,80,25,black,lightgray,'Spielernamen');
      maskreset(LAST);
      s:='<F2> oder <ESC> = Spielernamen bernehmen';
      newmask(LAST,13,1,12,0,namen[1],'Spieler 1',s,white,blue,[]);
      newmask(LAST,13,2,12,0,namen[2],'Spieler 2',s,white,blue,[]);
      newmask(LAST,13,3,12,0,namen[3],'Spieler 3',s,white,blue,[]);
      if spieler=4 then
         newmask(LAST,13,4,12,0,namen[4],'Spieler 4',s,white,blue,[]);
      co:=1;
      repeat
         maskinit(LAST);
         fl:=maskinput(LAST,co);
         namen[1]:=cutspace(doup(inparm[1].s));
         namen[2]:=cutspace(doup(inparm[2].s));
         namen[3]:=cutspace(doup(inparm[3].s));
         if spieler=4 then namen[4]:=cutspace(doup(inparm[4].s));
         flag:=TRUE;
         for i:=1 to spieler do begin
             if flag=TRUE then begin
                if namen[i]='' then begin
                   co:=i;
                   sline('Mindestens ein Zeichen fr die Identifizierung eingeben',white+blink);
                   flag:=FALSE;
                end else
                if i>1 then begin
                   flag:=TRUE;
                   for j:=1 to i-1 do
                       if namen[i]=namen[j] then flag:=FALSE;
                   if flag=FALSE then begin
                      co:=i;
                      namen[i]:='';
                      sline('Doppelte Namensgebung ist unzul„ssig',white+blink);
                   end;
                end;
            end;
         end;
         if flag=FALSE then a:=wait5('',false) else writeln;
      until flag=TRUE;
      winclose(2);
      namewin:=TRUE;
      for i:=1 to spieler do if namen[i]<>sa[i] then namewin:=FALSE;
   end;
end;

procedure directory;
var d:disk;
    pd:longint;
    ud:DateTime;
    f:file of disk;
    s:s80;
    i,j,k,l:integer;
    fl,wx,wy:byte;
begin
     scol(lightgray,black);
     writeln;
     getdir(0,s);
     capwriteln(' Skat-Spielst„nde im Verzeichnis {'+s,lightcyan,cyan);
     line;
     for i:=1 to 9 do begin
         str(i,s);
         capwrite(' STAND {'+s+'} : ',lightcyan,cyan);
         s:='SKAT'+chr(i+48)+'.DAT';
         fl:=1;
         if fileexists(s) then begin
            fl:=0;
            {$I-}
            assign(f,s);
            reset(f);
            {$I+}
            if IoResult=0 then begin
               {$I-}
               read(f,d);
               {$I+}
               if (IoResult<>0) or (not eof(f)) then fl:=2;
               getftime(f,pd);
               unpacktime(pd,ud);
               close(f);
            end else fl:=1;
         end;
         fc(cyan);
         if fl=0 then begin
            with d do begin
                 cwrite(#16,white);write(' ',spieler,'er : ');
                 for j:=1 to spieler do begin
                     write(copy(namen[j],1,8));
                     if j<spieler then cwrite(', ',lightgray);
                 end;
                 while wherex<61 do write('.');
                 gotoxy(61,wherey);
                 fc(lightgray);
                 with ud do
                      write(' Datum: ',day:2,'.',month:2,'.',year:4);
            end;
         end;
        if fl=1 then cwrite(' ---',lightmagenta);
        if fl=2 then cwrite(' Ungltiges Dateiformat !',lightred);
        writeln;
      end;
      fc(lightgray);
      line;
      writeln;
      unscol;
end;

procedure wintest(flag:boolean;sec:byte);

   const maxs=100;

   var r,i,j,max,grenz:word;
       k,x,y,rx,ry,bx,by:integer;
       feld:array[1..3,1..maxs] of byte;
       a,ch:char;
       maxss:word;
       da,db,dc,dd:word;
       fl:boolean;
begin
     ch:=#255;
     x:=40;
     y:=12;
     rx:=1;
     ry:=1;

     for i:=1 to maxs do begin
         feld[1,i]:=0;
         feld[2,i]:=0;
         feld[3,i]:=0;
     end;
     i:=1;
     randomize;
     r:=9;
     grenz:=6;
     k:=201;
     j:=0;
     gettime(dc,dc,da,dc);
     maxss:=10;
     fl:=TRUE;
     repeat
        if (keypressed) and (j<=sec) then begin
           a:=crt.readkey;
           if a=#0 then a:=crt.readkey;
           sound(220);k:=0;
        end;
        if k=100 then sound(110);
        if k=200 then nosound;
        if k<200 then inc(k);
        dd:=da;
        gettime(dc,dc,da,dc);
        if dd<>da then inc(j);
        if (fl=TRUE) and (j>sec) and (flag=TRUE) then begin
           k:=0;sound(880);
           sline('Bitte beliebige Taste drcken, um fortzufahren',black+blink);
           fl:=FALSE;
        end;
        r:=random(max)+1;
        if (random(10)=0) and (i=1) then begin
           repeat
              if feld[3,i]<>ord(ch) then
                 bild[feld[1,i]*2+feld[2,i]*160]:=chr(feld[3,i]);
              inc(i);
           until i>maxss;
           i:=1;
           maxss:=random((maxs-10) div 10)*10+10;
           max:=random(10)+6;
           grenz:=(max+3) div 2;
           ch:=chr(random(7)+1);
           ch:=chr(ord(ch)*16+ord(ch));
        end;
        case r of
             1:  rx:=-rx;
             2:  ry:=-ry;
             (*3:  begin
                    rx:=-rx;
                    ry:=-ry;
                 end;*)
        end;
        if r>3 then x:=x+rx;
        if r>grenz then y:=y+ry;
        bx:=x;
        by:=y;
        if x<1 then x:=80;
        if x>80 then x:=1;
        if y<0 then y:=23;
        if y>23 then y:=0;
        feld[1,i]:=x;
        feld[2,i]:=y;
        feld[3,i]:=ord(bild[2*x+160*y]);
        inc(i);
        if i>maxss then i:=1;
        bild[2*x+160*y]:=ch;
        if feld[3,i] div 16<>feld[3,i] mod 16 then
           bild[feld[1,i]*2+feld[2,i]*160]:=chr(feld[3,i]);
     until (keypressed) and (i=1);
     repeat
        if feld[3,i]<>ord(ch) then
           bild[feld[1,i]*2+feld[2,i]*160]:=chr(feld[3,i]);
        inc(i);
     until i>maxss;
     if keypressed then begin
        a:=crt.readkey;
        if a=#0 then a:=crt.readkey;
     end;
     nosound;
end;

procedure shareware(fl:boolean;sec:byte);
begin
     sline(' SKATMANAGER-SHAREWARE INFORMATION. Bitte warten !',black);
     winopen(3,5,7,75,18,1,1,80,24,white,red,'SHAREWARE-FENSTER');
     writeln;
     cwriteln('        SKATMANAGER '+ver+' SHAREWARE - (C) 1993 by Jakob Ott',yellow);

     cwriteln('       ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ',white);
     writeln;
     cwriteln('           Skatabrechnungssystem programmiert von Jakob Ott.         ',lightmagenta);
     cwriteln('   Dieses Programm ist Shareware. Wenn Sie es regelm„áig benutzen,   ',lightmagenta);
     cwriteln('    wrde ich mich ber eine Anerkennung von DM 20.- sehr freuen.    ',lightmagenta);
     cwriteln('      Sie erhalten dann das komplette Programmpaket der neuesten     ',lightmagenta);
     cwriteln('  Version von SKATMANAGER ohne dieses Shareware-Informationsfenster  ',lightmagenta);
     cwriteln('        und maximal 3000 Tabelleneintr„gen pro Spieler.        DANKE.',lightmagenta);
     wintest(fl,sec);
     winclose(3);
     delstat(0);
end;

procedure help(sf,st:s80);
const line='ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ';
var a,b:char;
    f:file;
    f1:file of char;
    s,s1,s2:s80;
    sa:array[1..25] of s80;
    i,ii,i2,j,k,l:integer;
    flag,fl,fl2:boolean;
    size:word;
    buf: array[0..25000] of char;
    idx: array[1..1000] of word;
    numread:word;
begin
    numread:=0;
    size:=0;
    col(black,lightgray);
    crt.clrscr;
    if fileexists(sf) then begin
       setcursor(vstdcursor);
       sline('"'+sf+'" - Hilfstext wird geladen...',black);
       assign(f,sf);
       reset(f,1);
       size:=filesize(f);
       writeln;
       write(' Gr”áe des Hilfstextes : ',size,' Bytes.');
       writeln;
       if a<>#27 then begin
          write(' Lese Datei...');
          blockread(f,buf,size,numread);
          writeln(' Gelesen : ',numread,' Bytes.');
       end;
       close(f);
    end;
    if ((SIZE<>0) and (size<32768)) AND (numread=size) then fl:=TRUE else
       fl:=FALSE;
    if fl=FALSE then begin
       delstat(black);
       str(numread,s1);
       str(size,s2);
       col(lightgray,black);
       crt.clrscr;
       gotoxy(1,5);
       capwriteln(' {***} Fehler beim Lesen der Hilfsdatei - '+s1+' Bytes von '+s2+' Bytes gelesen. {***}',lightred+blink,red);
       writeln;
    end;
    if fl=TRUE then begin
       i:=0;
       j:=1;
       idx[1]:=0;
       fl:=FALSE;
       a:=#0;
       b:=#0;
       i2:=0;
       repeat
             inc(i);
             if (buf[i]=#13) and (buf[i+1]=#10) then begin
                inc(j);
                if j mod 25=0 then begin
                   gotoxy(1,wherey);
                   write(' ',i,' Bytes ÄÍ> ',j,' Zeilen');
                   clreol;
                end;
                idx[j]:=i+2;
             end;
       until (i=size);
       gotoxy(1,wherey);
       write(' ',i,' Bytes ÄÍ> ',j,' Zeilen');
       setcursor(vnocursor);
       i:=0;
       ii:=24;
       flag:=TRUE;
       sline('Hilfefunktion : <Bild'#24'>, <Bild'#25'>, <ESC> :  ',WHITE);gotoxy(48,25);
       col(black,lightgray);
       window(1,1,80,25);
       gotoxy(1,1);
       fl2:=TRUE;
       l:=0;
       while (flag=TRUE) do begin
             setcursor(vnocursor);
             if (fl2=TRUE) then begin
                inc(l);
                inc(i);
                if i<j then begin
                   sa[l]:='';
                   for k:=idx[i] to idx[i+1]-3 do
                       sa[l]:=sa[l]+buf[k];
                end;
                if (i mod 24=0) or (i=j) then begin
                   if i=j then for k:=l to 24 do sa[k]:='';
                   l:=0;
                   fl2:=FALSE;
                   gotoxy(1,1);
                   for k:=1 to 24 do begin
                       write(copy(sa[k],1,80));
                       if length(sa[k])<80 then begin
                          clreol;
                          if k<24 then writeln;
                       end;
                   end;
                   gotoxy(1,25);
                end;
                if (i mod 24=1) then begin
                   str(i div 24+1,st);
                   wrtxy(1,25,' Seite N§ '+st+' ');
                   gotoxy(1,25);
                end;
             end else inc(i,24);
             a:=#0;
             b:=#0;
             fl:=FALSE;
             if (keypressed) then begin
                a:=crt.readkey;
                if a=#0 then b:=crt.readkey;
                if (b in [#73,#81]) or (a in [#13,#27]) then fl:=true;
                l:=0;
             end;
             if (fl=true) or ((i mod 24)=0) or (i=j) then begin
                setcursor(valtcursor);
                i:=i2+24;
                ii:=i-24;
                if fl=false then a:=crt.readkey;
                if a=#0 then begin
                   if fl=false then b:=crt.readkey;
                   if (b=#73) and (i>=48) then begin
                      dec(i,24);
                   end;
                   if b=#81 then a:=#13
                end;
                if (a=#13) and (i<j) then begin
                   inc(i,24);
                end;
                if a=#27 then flag:=false;
                setcursor(vnocursor);
                if i>=24 then i:=i-24;
                fl2:=TRUE;
                i2:=i;
                col(black,lightgray);gotoxy(1,1);
             end;
       end;
       col(lightgray,black);
       for k:=1 to 24 do begin
           write(copy(sa[k],1,80));
           if length(sa[k])<80 then begin
              clreol;
              writeln;
           end;
       end;
       delstat(black);
       gotoxy(1,24);
    end;
end;



procedure info;
begin
     scol(darkgray,black);
     clrscr;
     crt.clrscr;
     fc(lightgray);
     center('SKATMANAGER '+ver+' by Jakob Ott - Programminformation',1,80,lightcyan,black);
     writeln;
     line;
     fc(white);
     BANNER;
     fc(lightmagenta);
     writeln;
     line;
     center('Skatabrechnungssystem programmiert von Jakob Ott.',14,80,lightmagenta,black);
     center('Dieses Programm ist Shareware. Wenn Sie es regelm„áig benutzen,',15,80,lightmagenta,black);
     center('wrde ich mich ber eine Anerkennung von DM 20.- sehr freuen. ',16,80,lightmagenta,black);
     center('Dies wrde das ohnehin m„áig funktionierende SHAREWARE-Prinzip',17,80,lightmagenta,black);
     center('am Leben erhalten, durch das Sie Gelegenheit haben, sich in viele',18,80,lightmagenta,black);
     center('ntzliche Programme einen Einblick zu verschaffen.',19,80,lightmagenta,black);
     gotoxy(1,20);
     line;
     center('Meine Adresse :  Jakob Ott, Hohe Straáe 58, 89518 Heidenheim',21,80,lightcyan,black);
     sline('Bitte beliebige Taste drcken...',white);
     dogag;
end;

procedure clrlns;
var i:byte;
begin
    for i:=24 downto 8 do begin
        gotoxy(1,i);clreol;
    end;
end;

procedure clears;
var i:byte;
begin
     for i:=1 to 25 do begin
         scroll(false,0,0,79,24);
         delay(3);
     end;
     gotoxy(1,1);
end;

procedure clrscr;
var i,j,k:word;
begin
     i:=0;
     repeat
           j:=0;
           repeat
             k:=j*160;
             bild[k+i-1]:=' ';
             bild[k+i]:=#7;

             bild[k+160-i+1]:=' ';
             bild[k+160-i+0]:=#7;

             bild[k+i+1]:='Ü';
             bild[k+i+2]:=#7;

             bild[k+160-i-1]:='ß';
             bild[k+160-i-2]:=#7;
             inc(j);
           until (j=25);
           inc(i,2);
           if not keypressed then delay(4);
     until (i=82);
     for j:=0 to 13 do begin
         bild[j*160+79]:=#32;
         bild[j*160+81]:=#32;
         bild[25*160-j*160+79]:=#32;
         bild[25*160-j*160+81]:=#32;
         delay(6);
     end;
     gotoxy(1,1);
end;

function Abrechnung(var am:word;var d:disk):boolean;
   var i,gew:longint;
       spi:byte;
       s:s80;
       gl:BOOLEAN;
begin
    with d do begin
       scol(lightgray,black);
       clrscr;
       writeln;
       cwriteln(' SKATMANAGER '+ver+' - Pfennigskatabrechnung',white);
       doubleline;
       writeln;
       cwrite(' Bitte Pfennigbetrag pro Punkt angeben (1-500) : ',lightred);
       am:=intinput(am,1,500,'Bitte Pfennigbetrag angeben, der pro Punkt gerechnet werden soll',
       'Eingabefehler. Bitte M™GLICHEN Pfennigbetrag eingeben',black,lightgray);
       writeln;
       if am>0 then begin
          line;
          writeln;
          spielerprint(d);
          writeln;
          spi:=1;
          gl:=FALSE;
          for i:=1 to spieler do begin
              if (i>1) and (punkte[i]=punkte[spi]) then gl:=TRUE;
              if punkte[i]>punkte[spi] then spi:=i;
          end;
          writeln;
          if gl=true then begin
             capwriteln(' In diesem Spiel gibt es {keinen} eindeutigen {Sieger} !',lightmagenta,magenta);
             writeln;
             cwriteln(' Es muá also mindestens ein Entscheidungsspiel erfolgen !',white);
          end else begin
               capwrite(' Sieger ist also Spieler {'+namen[spi]+'} mit ',lightcyan,cyan);
               fc(cyan);
               write(punkte[spi]);
               cwriteln(' Punkten.',cyan);
               fc(lightred);
               writeln;
               gew:=0;
               for i:=1 to spieler do begin
                   if i<>spi then begin
                      capwrite(' ~- Spieler {'+namen[i]+'}',white,lightgray);
                      gotoxy(20,wherey);
                      cwrite(' zahlt ',lightgray);
                      write(abs(punkte[spi]-punkte[i])/100*am:5:2,' DM');
                      capwriteln(' an Spieler {'+namen[spi]+'}.',white,lightgray);
                      gew:=gew+abs(punkte[spi])-punkte[i];
                   end;
               end;
               writeln;
               capwrite(' Spieler {'+namen[spi]+'} bekommt also ',lightcyan,cyan);
               fc(lightcyan);
               write(gew/100*am:5:2,' DM');
               cwriteln(' auf sein Gehaltskonto.',cyan);
          end;
          abrechnung:=TRUE;
       end else begin
            abrechnung:=FALSE;
            writeln;
            capwrite(' {***} Operation abgebrochen {***}',lightred+blink,red);
       end;
    end;
end;

procedure attribs(sp:byte;s:s80;var d:disk;var mult,anzahl,trumpf,pu:integer;reiz:word);
   var i:word;
       xc:byte;
       st:s80;
       rt:integer;
begin
   scol(lightgray,black);
   writeln;
   line;
   center('SKAT-MANAGER '+ver+' - ABRECHNUNGSERGEBNIS',wherey,80,yellow,black);
   writeln;
   line;
   if (s>'') or ((d.mode<>0) or (d.modus=2)) then begin
      with d do begin
         cwrite(' Spieler ',cyan);
         cwrite(namen[sp],white);
         if pu=0 then cwrite(' spielte ',cyan)
         else cwrite('.',cyan);
         fc(lightcyan);
         if pu=0 then begin
            cwrite('Mit/Ohne ',cyan);
            write(anzahl-1);
            cwrite(', Spiel ',cyan);
            write(anzahl);
            cwriteln('.',cyan);
         end else
         begin
            cwrite(' Es wurde ',cyan);
            if (pu<Nullouverthand) then begin
               if pos('H',s)<>0 then begin
                  if pos('O',s)<>0 then
                     pu:=nullouverthand
                  else begin
                     if pu=null then
                        pu:=nullhand;
                     if pu=nullouvert then
                        pu:=nullouverthand;
                  end;
               end else begin
                   if pos('O',s)<>0 then begin
                      if pu=null then
                         pu:=nullouvert;
                      if pu=nullhand then
                         pu:=nullouverthand;
                   end;
               end;
            end;
            if pu=NullOuvertHand then write('Null-Ouvert-Hand=',nullouverthand);
            if pu=NullOuvert     then write('Null-Ouvert=',nullouvert);
            if pu=NullHand       then write('Null-Hand=',nullhand);
            if pu=Null           then write('Null=',null);
            cwriteln(' gespielt. ',cyan);
         end;
         mult:=1;
         cwrite(' Attribute : ',lightgray);
         if pu=0 then begin
            xc:=wherex;
            if pos('S',s)<>0 then begin
               inc(anzahl);        { Schneider }
               fc(cyan);
               write('Schneider ',mult*anzahl);
            end;
            if pos('A',s)<>0 then begin
                  if pos('S',s)<>0 then begin        { Angesagt Schneider }
                     inc(anzahl);
                     fc(cyan);
                  end else begin
                     if pos('W',s)<>0 then begin        { Angesagt Schwarz }
                        anzahl:=anzahl+2;
                        fc(lightcyan);
                     end;
                  end;
                  if (pos('W',s)<>0) or (pos('S',s)<>0) then
                     write(' Angesagt ',mult*anzahl,', ');
            end else if pos('S',s)<>0 then write(', ');
            if pos('W',s)<>0 then begin  { Schwarz }
               anzahl:=anzahl+2;
               fc(lightcyan);
               write('Schwarz ');
               if (pos('S',s)<>0) and (pos('A',s)<>0) then
                  write('gespielt ');
               write(mult*anzahl,', ');
            end;
               fc(green);
            if (pos('H',s)<>0) or (modus=2) then begin
               inc(anzahl);          { Hand }
               write('Hand ',mult*anzahl,', ');
            end;
            if (pos('O',s)<>0) then begin
               if (trumpf<GRAND) then begin
                   inc(anzahl);    { Ouvert }
                   write('Ouvert ',mult*anzahl,', ');
               end else trumpf:=GRANDOUVERT;
            end;
         end;
         fc(lightmagenta);
         if pos('B',s)<>0 then begin       { Bock }
            mult:=mult*8;
            write('Contra-Re-Bock ',mult*anzahl,', ');
         end else
         if pos('R',s)<>0 then begin       { Re }
            mult:=mult*4;
            write('Contra-Re ',mult* anzahl,', ');
         end else
         if pos('C',s)<>0 then begin       { Contra }
            mult:=mult*2;
            write('Contra ',mult*anzahl,', ');
         end;
         fc(white);
         if modus=3 then begin             { Bockspiel? }
            mult:=mult*2;
            write('Bockspiel ',mult*anzahl,', ');
         end;
         fc(lightred);
         if reiz>0 then begin
            if pu=0 then
               rt:=mult*anzahl*trumpf { Farbwertung }
            else
               rt:=pu*mult*anzahl;                 { sonst. Wertung }
            if rt<reiz then begin
               s:=s+'U';
            end;
         end;

         if (pos('U',s)<>0) then begin
            mult:=mult*2;                  { šberreizt }
            write('šberreizt ',mult*anzahl,', ');
            if pos('V',s)=0 then s:=s+'V';
         end;
         if pos('V',s)<>0 then begin       { Verloren }
            if (modus<>2) or (doppelt=TRUE) then mult:=-mult*2 { 2fach bei Skat! }
            else mult:=-mult;                                  { 1fach bei Ramsch }
            write('Verloren ');
            write(mult*anzahl,', ');
         end;
         fc(lightgray);
         if wherex=xc then cwrite('Keine.  ',lightred) else begin
            gotoxy(wherex-2,wherey);
            write('.');
         end;
         clreol;
         if pu=0 then begin
            writeln;
            cwrite(' Spielwert : ',cyan);
            case trumpf of
                9: cwrite('KARO (9), ',white);
               10: cwrite('HERZ (10) ',white);
               11: cwrite('PIK (11) ',white);
               12: cwrite('KREUZ (12) ',white);
            end;
            if trumpf=GRAND       then write('GRAND (',grand,')');
            if trumpf=GRANDOUVERT then write('GRAND-OUVERT (',grandouvert,')');
         end;
         writeln;
         fc(lightgray);
         line;
         fc(lightgreen);
         cwrite(' --> ',lightgray+blink);
         if mult*anzahl<0 then fc(lightred);
         cwrite('Dies ergibt ',lightgray);
         write(mult*anzahl,' * ');
         if pu=0 then begin
            write(trumpf);
            pu:=mult*anzahl*trumpf { Farbwertung }
         end else begin
            write(pu);
            pu:=pu*mult*anzahl;                 { sonst. Wertung }
         end;
         cwrite(' = ',white);
         str(pu,st);
         wrtxy(wherex-1,wherey+1,copy('ğğğğğğğğğğğğğğ',1,length(st)+2));
         write(st);
         fc(lightgray);
         if (reiz>0) then begin
            if rt<reiz then begin
               capwrite('  ~* šBERREIZT ~* ',white,lightred);
               sound(1760);delay(40);nosound;delay(20);
               sound(1320);delay(40);nosound;delay(20);
               sound(880);delay(40);nosound;
            end;
            write(' (gereizt ',reiz,', gespielt ',rt,')');
         end;
         writeln;
         if ((pos('V',s)<>0) and (ramsch=TRUE) and
            ((pos('C',s)<>0) or
             (pos('R',s)<>0) or (pos('B',s)<>0)))  { Verl. + Contra ? }
             or (pos('*',s)<>0)
         then begin
              if modus=1 then begin               { Wird schon Ramsch/Bock gespielt ? }
                 modus:=2; rac:=0;
                 for i:=1 to spieler do gc[i]:=FALSE;
              end else
                 inc(merker);
         end;
      end;
   end;
   if pu=0 then begin
      writeln;
      cwrite(' Spieler '+d.namen[sp]+', der Kartenknstler, ',lightred);
      capwriteln('spielte berhaupt {nichts} !',white,yellow);
      writeln;
   end;
   unscol;
end;



procedure banner;
begin
       writeln;
       write('ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»');
       write('º ÚÄÄÄÄÄÄÄ¿ ÚÄÄÄ ³ ÚÙ  ÚÄÄÄ¿ ÄÄÂÄ ÄÂ¿   Ú¿ ÚÄÄÄ¿ Ú¿  ³ ÚÄÄÄ¿  ÚÄÄ¿  ÚÄÄÄ ÚÄÄ¿  º');
       write('º ³ B   ³ ³    ³ÚÙ   ³   ³   ³   ³À¿ ÚÙ³ ³   ³ ³À¿ ³ ³   ³ ÚÙ  À¿ ³    ³  À¿ º');
       write('º ³   ² B ³ ÀÄÄ¿ ÃÁ¿  ÄÅÄÄÄ´   ³   ³ ÀÂÙ ³ÄÅÄÄÄ´ ³ À¿³ÄÅÄÄÄ´ ³    Á ÃÄÄ  ³  ÚÙ º');
       write('º ³  ²±² Jack''s³ ³ À¿  ³   ³   ³   ³  ³  ³ ³   ³ ³  À´ ³   ³ ³ ÚÄÄ¿ ³    ÃÄÂÙ  º');
       write('º ³  ²   ³    ³ ³  À¿ ³   ³   ³   ³     ³ ³   ³ ³   ³ ³   ³ ³    ³ ³    ³ À¿  º');
       write('º ³ B  B ³ ÃÄÄÙ Á   ÀÄÁ   ³   Á   Á     Á Á   ³ Á     Á   ³ ÀÄÄÄÄÙ ÀÄÄÄ ³  Á  º');
       write('ÈÍÁÄÄÄÄÄÄÄÁÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍ¼');
end;


procedure intro(var d:disk;var cols:boolean);
var test:boolean;
    a:char;
    x:byte;
    i:byte;
begin
     setcursor(vnocursor);
     scol(black,lightgray);
     window(1,1,80,25);
     with d do begin
       clreol;
       banner;
       clreol;writeln;
       scol(lightgray,black);
       gotoxy(1,17);
       doubleline;
       writeln;
       gotoxy(20,wherey);
       capwriteln(' Der SKAT-MANAGER '+ver+' {SHAREWAREVERSION}',red+blink,lightgray);
       writeln;
       writeln(' ** Bitte lesen Sie vor der ersten Benutzung die Dokumentation "SKATMAN.DOK" **');
       sline('(C) ''93 by Jakob Ott. All rights reserved. This is shareware !',black);
       scol(black,lightgray);
       test:=true;
       writeln;
       test:=askwin(12,1,1,80,25,' (F)arb- oder (M)onochromdarstellung (F/M) ? ','',
       '"F" oder <CR> fr Farbe, "M" oder <ESC> fr Monochrom (Schwarz/Weiá)',
       black,lightgray,'F','M');
       if test=true then cols:=TRUE
          else cols:=FALSE;
       if cols=TRUE then begin
          gotoxy(1,1);
          col(yellow,green);
          clreol;
          banner;
          clreol;writeln;
          col(lightgray,black);
       end;
       repeat
           test:=askwin(12,1,1,80,25,' Gespeicherten Spielstand (L)aden oder (N)eues Spiel (L/N) : ',
           'SKATMANAGER '+ver,'"L" oder "N"  (oder RETURN=L/ESC=N)',black,cyan,'L','N');
           if test=FALSE then begin
              d.spieler:=0;
                  test:=TRUE;
                  spieler:=0;
                  x:=neuspiel(d);
                  if x=0 then test:=FALSE;
                  mode:=0;
                  addi:=0;
           end else begin
               test:=laden(d);
               if test=false then a:=wait5(' Bitte warten oder Taste drcken...',true);
           end;
       until test=TRUE;
     end;
end;



procedure spielerprint(var d:disk);
var i:byte;
begin
     with d do begin
          scol(white,black);
          for i:=1 to spieler do begin
              fc(white);
              write(namen[i]:20);
              cwrite(' ist Spieler ',cyan);
              fc(lightcyan);
              write(i);
              cwrite(' und hat ',cyan);
              fc(lightcyan);
              write(punkte[i]);
              cwriteln(' Punkte.',cyan);
          end;
          unscol;
     end;
end;

function neuspiel(var d:disk):byte;
var   i,j:integer;
      a:char;
      s:s80;
      spi,spie2,cux,cuy:byte;
      test,flag,fl:BOOLEAN;
begin
    with d do begin
       spie2:=spieler;
       spieler:=0;
       spi:=askwin2(12,1,1,80,25,' Bitte Anzahl der Spieler angeben (3/4) : ','Neues Spiel',
       '"3" oder "4"  (ESC=ABBRUCH)',white,cyan,'3','4');
       if spi=1 then spieler:=3;
       if spi=2 then spieler:=4;
       if spieler<>0 then begin
          writeln;
          CHOOSE:=TRUE;
          MODUS:=1;
          RAC:=0;
          MERKER:=0;
          RAMSCH:=TRUE;
          pull:=TRUE;
          doppelt:=FALSE;
          rageb:=TRUE;
          gotoxy(1,12);
          capwriteln('          {Spieler eingeben} (Gegen Uhrzeigersinn, erster Geber zuerst !)',lightcyan,cyan);
          writeln;
          for i:=1 to spieler do namen[i]:='';
          test:=namewin(d);
          sz:=1;     (* Hauptz„hler *)
          for i:=1 to spieler do begin
              gc[i]:=FALSE;
              punkte[i]:=0;
              pup[i]:=0;
              for j:=1 to maxtab do puf[i,j]:=0;
          end;
          test:=TRUE;
          neuspiel:=1;
       end else neuspiel:=0;
       unscol;
       if spieler=0 then spieler:=spie2;
    end;
end;

procedure korrektur(var d:disk);
var s:s80;
    sp:byte;
    pu,rel:integer;
    fl:BOOLEAN;
begin
     scol(lightgray,black);
     with d do begin
          clrscr;
          writeln;
          cwriteln(' SKATMANAGER '+ver+' - Korrekturfunktion',white);
          doubleline;
          writeln;
          center(' Bitte Namen oder Nummer des zu korrigierenden Spielers eingeben :',wherey,80,lightcyan,black);
          writeln;
          writeln;
          cwrite('                           --> ',cyan);

          s:=newinput('',20,'Bitte Namen oder Nummer eingeben',yellow,blue,[]);
          writeln;
          s:=cutspace(s);

          if s>'' then sp:=getplayer(s,namen,spieler) else
             sp:=128;
          if (sp and 128)=0 then begin
             line;
             fc(cyan);
             write(' Spieler '+namen[sp]+' hat ');
             fc(lightcyan); write  (punkte[sp]);
             fc(cyan);      writeln(' Punkte.');
             write  (' '+namen[sp]+' hatte im letzen Spiel ');
             fc(lightcyan);
             if pup[sp]>1 then rel:=punkte[sp]-puf[sp,pup[sp]-1]
             else rel:=punkte[sp];
             fc(lightcyan); write(rel);
             fc(cyan);
             if rel>=0 then writeln(' Punkte dazugewonnen.')
             else writeln(' Punkte verloren.');
             write(' Im Spiel davor hatte '+namen[sp]+' ');
             fc(lightcyan);write  (punkte[sp]-rel);
             fc(cyan);     writeln(' Punkte.');
             fc(lightgray);
             line;
             capwriteln(' Bitte die im letzen Spiel {erreichten}/{verlorenen}',lightcyan,cyan);
             cwrite    (' Punkte fr Spieler '+namen[sp]+' eingeben : ',cyan);
             pu:=intinput(0,-4000,2000,'Bitte erreichte Punkte eingeben',
                          'Eingabefehler. Bitte M™GLICHE erreichte Punktzahl eingeben',black,lightgray);
             writeln;
             fl:=TRUE;
             if pu=0 then begin
                line;
                sline('Bei "N" wird das letzte Spiel entfernt, bei "J" wird nichts ver„ndert',black);
                capwrite(' ~J=Spielstand unver„ndert lassen, ~N=Letztes Spiel entfernen (~J/~N) : ',lightcyan,cyan);
                fl:=not(janein);
                writeln;
                if fl=FALSE then begin
                   writeln;
                   cwriteln(' Der Spielstand von Spieler '+namen[sp]+' bleibt unver„ndert.',lightred);
                end;
             end;
             if fl=TRUE then begin
                punkte[sp]:=pu;
                if pup[sp]>1 then begin
                   if pu<>0 then begin
                      pu:=pu+puf[sp,pup[sp]-1];
                      punkte[sp]:=pu;
                      puf[sp,pup[sp]]:=pu;
                   end else begin
                      dec(pup[sp]);
                      punkte[sp]:=puf[sp,pup[sp]];
                   end;
                end else begin
                   if pu<>0 then begin
                      writeln;
                      capwriteln('~> Punkte werden als {erstes Spiel} eingetragen.',lightred,red);
                      pup[sp]:=1;
                      punkte[1]:=pu;
                      puf[sp,1]:=pu;
                   end else pup[sp]:=0;
                end;
                fc(lightgray);
                line;
                fc(cyan);
                write(' Spieler '+namen[sp]+' hat nun ');
                fc(lightcyan); write  (punkte[sp]);
                fc(cyan);      writeln(' Punkte.');
             end;
          end else begin
              writeln;
              capwrite(' {***} Operation abgebrochen {***}',lightred+blink,red);
              if s<>'' then cwriteln(' Dieser Spieler ist so nicht identifizierbar.',red)
              else writeln;
              writeln;
          end;
     end;
     unscol;
     writeln;
end;

function stringwin(ypos,x1,y1,x2,y2:byte;var s:s80;hilfs:s80):BOOLEAN;
var fl:boolean;
    a:char;
begin
   infowin(ypos,x1,y1,x2,y2,' Wer spielt ?                    ','Skatmanager '+ver,white,cyan);
   maskreset(LAST);
   inparm[1].s:='';
   newmask(LAST,15, 1,20,0,s,'',hilfs,lightcyan,blue,[]);
   maskinit(LAST);
   while keypressed do begin
         a:=CRT.readkey;
   end;
   fl:=maskinput(LAST,1);
   if fl=TRUE then
      s:=inparm[1].s
   else
      s:='';
   infoclose;
end;

function intwin(ypos,x1,y1,x2,y2:byte;am,min,max:integer;tit,hilfs,error:s80):integer;
var fl:boolean;
    a:char;
    s,s1:s80;
    am2:integer;
begin
   str(min,s1);
   s:='Zahl ('+s1;
   str(max,s1);
   s:=s+'-'+s1+')';
   infowin(ypos,x1,y1,x2,y2,tit+'      ',s,white,cyan);
   gotoxy(wherex-6,wherey);
   am:=intinput(am,min,max,hilfs,error,white,cyan);
   intwin:=am;
   infoclose;
end;




procedure line;
begin
     writeln(' ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
end;

procedure doubleline;
begin
     writeln(' ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ');
end;


function jaodernein:BOOLEAN;
begin
   jaodernein:=aoderb('J','N','JA','NEIN');
end;

function aoderb(a,b:char;s1,s2:s20):BOOLEAN;
var c:char;
begin
   repeat
          c:=upcase(readkey);
   until c in [#13,#27,a,b];
   if c in[#13,a] then begin
      aoderb:=TRUE;
      writeln(s1);
   end
   else begin
      aoderb:=FALSE;
      writeln(s2);
   end;
end;

function a2oderb2(a,b:char;s1,s2:s20):byte;
var c:char;
begin
   repeat
          c:=upcase(readkey);
   until c in [#27,a,b];
   if c=a then begin
      a2oderb2:=1;
      writeln(s1);
   end;
   if c=b then begin
      a2oderb2:=2;
      writeln(s2);
   end;
   if c=#27 then begin
      a2oderb2:=0;
      writeln('ABBRUCH');
   end;
end;



function getplayer(s:s80;var namen:namentyp;spieler:byte):byte;
   var i,ii,get:byte;
       t,code:integer;
       d:array[1..4] of byte;
begin
      s:=doup(s);
      get:=0;
      val(s,t,code);
      if (code=0) and (t>0) and (t<=spieler) then get:=t
      else begin
           for ii:=1 to spieler do begin
               if s=copy(namen[ii],1,length(s)) then begin
                  if get=0 then get:=ii
                  else
                      get:=get or 128;
                  end;
           end
      end;
      if get=0 then begin
         for ii:=1 to spieler do begin
             d[ii]:=0;
             for i:=1 to length(s) do begin
                 if i<length(namen[ii]) then
                    if s[i]=namen[ii][i] then inc(d[ii]);
             end;
         end;
         t:=0;
         for i:=1 to spieler do if d[i]>t then t:=i;
         get:=t or 128;
      end;
      getplayer:=get;
end;

function periphery(s:s80):boolean;
begin
     if (s='PRN') or
     ((copy(s,1,3)='LPT') and (s[4] in ['1'..'4'])) or
     ((copy(s,1,3)='COM') and (s[4] in ['1'..'4']))
        then
        periphery:=TRUE else periphery:=FALSE;
end;

procedure tabelle(var d:disk;druck:boolean;var datei:s80);
var y,i,j,max,s,u,v,q,ofs,rel:integer;
    beurt:array[1..4] of integer;
    st,ds:s80;
    fl,flag,err:boolean;
    a:char;
    fd:text;
begin
     err:=FALSE;
     flag:=TRUE;
     with d do begin
       scol(lightgray,black);
       clrscr;
       if druck=TRUE then begin
          if datei='' then datei:='PRN';
          writeln;
          cwriteln(' SKATMANAGER '+ver+' - Tabelle auf Drucker oder in Datei ausgeben',white);
          doubleline;
          writeln;
          write(' Bitte Ausgabeger„t angeben (PRN=Drucker) : ');
          st:=newinput(datei,30,'Ausgabeger„t angeben, kann auch Dateiname sein !',
                   white,magenta,[]);
          writeln;
          st:=cutspace(doup(st));
          if st='CON' then st:='';
          if st>'' then begin
             datei:=st;
             if (fileexists(datei)=TRUE) and (not periphery(datei)) then
                 druck:=askwin(12,1,1,80,25,' Ger„t/Datei existiert. Ausgabe starten ? (J/N) ? ','SKATMANAGER',
                 '"J" oder "N"  (oder RETURN=J/ESC=N)',yellow,red+blink,'J','N')
             else if periphery(datei)=TRUE then err:=TRUE;
             if druck=TRUE then begin
                {$I-}
                Assign(fd, datei);
                Rewrite(fd);
                Close(fd);
                {$I+}
                druck:=(IOResult=0);
             end;
             if druck=FALSE then begin
                writeln;
                a:=wait5(' Ausgabeger„t/Datei "'+datei+'" kann nicht verwendet werden...',true);
                fc(lightgray);
                crt.clrscr;
             end;
          end else begin
             druck:=FALSE;
             writeln;
             a:=wait5(' Tabelle wird nicht auf Ausgabeger„t ausgegeben...',true);
             fc(lightgray);
             crt.clrscr;
          end;
          if druck=TRUE then begin
             assign(fd,datei);
             rewrite(fd);
          end;
          if datei='PRN' then fl:=TRUE
          else fl:=FALSE;
       end;
       if druck=TRUE then begin
          crt.clrscr;
          ds:=' SKATMANAGER '+ver+' (C) 1993 by Jakob Ott. Abrechnungstabelle vom '+datumheute;
          druck:=print(err,fd,' '+ds);
          fillchar(ds,79,'-');
          ds[0]:=#78;
          druck:=print(err,fd,' '+ds);
       end;
       window(1,1,80,3);
       col(black,lightgray);
       crt.clrscr;
       wrtxy(2,2,'SKATMANAGER '+ver+' (C) 1993 by Jakob Ott. SHAREVERSION ! - Bitte registrieren !');
       col(lightgray,black);
       window(1,4,80,24);
       writeln;
       max:=0;
       ds:='';
       for i:=1 to spieler do begin
           if pup[i]>max then max:=pup[i];
           write(namen[i]:16,'   ');
           ds:=ds+copy(space,1,16-length(namen[i]))+namen[i]+'   ';
       end;
       if druck=TRUE then begin
          druck:=print(err,fd,ds);
          fillchar(ds,79,'-');
          ds[0]:=#78;
          druck:=print(err,fd,' '+ds);
       end;
       writeln;
       line;
       ofs:=3;
       for i:=1 to max do begin
           ds:='';
           for j:=1 to spieler do begin
               y:=max-pup[j];
               if i>y then begin
                  if i=max then fc(white);
                  write(puf[j,i-y]:9);
                  str(puf[j,i-y]:9,st);
                  ds:=ds+st;
                  if i-y>1 then rel:=puf[j,i-y]-puf[j,i-y-1]
                  else          rel:=puf[j,i-y];
                  write('  (');
                  ds:=ds+'  (';
                  if rel>0 then begin
                     cwrite('+',lightgreen);
                     ds:=ds+'+';
                     write(rel:4,') ');
                     str(rel:4,st);
                     ds:=ds+st+') ';
                  end else begin
                      cwrite('-',red);
                      ds:=ds+'-';
                      write(abs(rel):4,') ');
                      str(abs(rel):4,st);
                      ds:=ds+st+') ';
                  end;
               end
               else begin
                    write('                   ');
                   ds:=ds+'                   ';
               end;
           end;
           if druck=TRUE then druck:=print(err,fd,ds);
           writeln;
           fl:=TRUE;
           if ((i+ofs) mod 21=0) and (druck=FALSE) then begin
              capwrite(' >> {RETURN}/{ESC} << ',white,lightgray);
              if readkey=#27 then begin
                 i:=max;
                 fl:=FALSE;
              end;
              gotoxy(1,wherey);clreol;
           end;
       end;
       if fl=TRUE then begin
          if druck=TRUE then begin
             fillchar(ds,79,'-');
             ds[0]:=#78;
             druck:=print(err,fd,' '+ds);
          end;
          line;
          if ((i+ofs) mod 21>14) and (wherey>=20) and (druck=FALSE) then begin
             capwrite(' >> {RETURN}/{ESC} << ',white,lightgray);
             flag:=(readkey<>#27);
             gotoxy(1,wherey);clreol;
          end else
              flag:=TRUE;
          if flag=true then
             begin
                ds:='';
                unscol;
                scol(cyan,black);
                for i:=1 to spieler do begin
                    s:=0;
                    v:=0;
                    j:=0;
                    repeat
                        inc(j);
                        if j<=pup[i] then begin
                           if j>1 then begin
                              if puf[i,j]>puf[i,j-1] then inc(s)
                           end else if puf[i,j]>0 then inc(s);
                        end
                        else
                           v:=j-1;
                    until v>0;
                    u:=round(s/v*100);
                    write('   ',s:3,'/',v:3,' =',u:3,' %  ');
                    ds:=ds+'   ';
                    str(s:3,st);
                    ds:=ds+st;
                    str(v:3,st);
                    ds:=ds+'/'+st;
                    str(u:3,st);
                    ds:=ds+' ='+st+' %  ';
                    beurt[i]:=beurt[i]+u;
                end;
                if spieler=3 then begin
                   cwriteln('   (Spielquote)',lightgray);
                   ds:=ds+  '   (Spielquote)';
                end else writeln;
                if druck=TRUE then druck:=print(err,fd,ds);
                line;
                if druck=TRUE then begin
                   fillchar(ds,79,'-');
                   ds[0]:=#78;
                   druck:=print(err,fd,' '+ds);
                end;
                scol(lightcyan,black);
                ds:='';
                for i:=1 to spieler do begin
                    q:=punkte[i]*2;
                    if pup[i]>0 then q:=q div pup[i]
                    else q:=0;
                    write(q:12,' %     ');
                    str(q:12,st);
                    ds:=ds+st+' %     ';
                    beurt[i]:=q;
                end;
                if spieler=3 then begin
                   cwriteln('   (Beurteilung)',lightgray);
                   ds:=ds+  '   (Beurteilung)'
                end else writeln;
                if druck=TRUE then druck:=print(err,fd,ds);
                line;
                unscol;
                scol(yellow,black);
                for i:=1 to spieler do
                    write('('+namen[i]+')':16,'   ');
                unscol;
                writeln;
          end;
          fl:=FLAG;
       end;
       if fl=FALSE then capwriteln(' {***} Ausgabe abgebrochen {***}',lightred+blink,red);
       if druck=TRUE then
          close(fd);
     end;
     window(1,1,80,24);gotoxy(1,21);
(*     if wherey>21 then begin
        j:=abs(22-wherey);
        window(1,1,80,25);
        gotoxy(1,25);
        for i:=1 to j do writeln;
     end;
     gotoxy(1,21);
*)
end;

function sichern(var d:disk):boolean;

var i,j:integer;
    f:file of disk;
    a:char;
    s:s80;
    yy:byte;
    fl,fl2:boolean;
begin
     scol(lightgray,black);
     clrscr;
     writeln;
     capwriteln(' {SKATMANAGER '+ver+'} - {SICHERN} des Spielstands',white,lightgray);
     doubleline;
     writeln;
     directory;
     writeln;
     capwrite('          Bitte Spielstand-Nummer (~1-~9) angeben ({ESC}=Abbruch) : ',lightcyan,cyan);
     sline('Bitte Nummer des Spielstands angeben, unter dem GESICHERT werden soll',black);
     repeat
        a:=readkey;
     until a in ['1'..'9',#27];
     writeln(a);
     fl2:=FALSE;
     if a<>#27 then begin
        s:='SKAT'+a+'.DAT';
        fl:=TRUE;
        repeat
           {$I-}
           assign (f,s);
           rewrite(f);
           write(f,d);
           {$I+}
           if IOResult=0 then begin
              fl2:=TRUE;
              close(f);
              writeln;
              cwrite(' GESICHERT.',lightgreen);clreol;
              writeln;
           end else begin
               writeln;
               capwriteln(' {***} DER SPIELSTAND KONNTE {NICHT} GESICHERT WERDEN! {***}',lightred+blink,red);
               writeln;
               yy:=wherey;
               s:='C:\';
               repeat
                  writeln;
                  gotoxy(1,yy);
                  cwrite('Pfad angeben : ',lightcyan);
                  s:=newinput(s,60,'Spielstand wird nun als N§ '+a+' in anzugebenden Pfad gespeichert. (z.B. "C:\")',
                     black,lightgray,[]);
                  writeln;
                  s:=cutspace(doup(s));
                  if (s<>'') and (s[length(s)]<>'\') then s:=s+'\';
                  if (s<>'') and (not direxists(s)) then begin
                     writeln;
                     capwrite(' {***} Dieser Pfad "'+s+'" existiert nicht.',lightred,red);
                     clreol;writeln;clreol;
                  end;
               until (s='') or (direxists(s));
               if s='' then fl:=FALSE;
               s:=s+'SKAT'+a+'.DAT';
           end;
        until (fl=FALSE) or (fl2=TRUE);
        sichern:=TRUE;
     end else begin
         sichern:=FALSE;
         writeln;
         capwriteln(' {***} Operation abgebrochen {***}',lightred+blink,red);
         writeln;
     end;
     unscol;
end;

function laden(var d:disk):boolean;

var i,j:integer;
    d2:disk;
    f:file of disk;
    a:char;
begin
     scol(lightgray,black);
     clrscr;
     writeln;
     capwriteln(' {SKATMANAGER '+ver+'} - {LADEN} des Spielstands',white,lightgray);
     doubleline;
     directory;
     writeln;
     capwrite('          Bitte Spielstand-Nummer (~1-~9) angeben ({ESC}=Abbruch) : ',lightcyan,cyan);
     sline('Bitte Nummer des Spielstands angeben, der GELADEN werden soll',black);
     repeat
        a:=readkey;
     until a in ['1'..'9',#27];
     writeln(a);
     writeln;
     if a<>#27 then begin
        if fileexists('SKAT'+a+'.DAT') then begin
           assign (f,'SKAT'+a+'.DAT');
           {$I-}
           reset(f);
           read(f,d2);
           {$I+}
           if (IoResult=0) and (eof(f)) then begin
              laden:=TRUE;
              d:=d2;
           end else begin
              capwriteln(' {***} Dieser Spielstand hat ungltiges Dateiformat {***}',lightred+blink,red);
              laden:=FALSE;
           end;
           close(f);
        end else begin
           capwriteln(' {***} Unter dieser Nummer gibt es hier keinen Spielstand {***}',lightred+blink,red);
           laden:=FALSE;
        end;
     writeln;
     end else begin
        capwriteln(' {***} Operation abgebrochen {***}',lightred+blink,red);
        writeln;
        laden:=FALSE;
     end;
end;

procedure swapint(var i1,i2:integer);
var buf:integer;
begin
     buf:=i1;
     i1:=i2;
     i2:=buf;
end;

procedure tausch(var d:disk);

var
    bnamen:s80;
    b:boolean;
    i,j,t1,t2,buf:integer;
    s:s80;
begin
   with d do begin
     scol(lightgray,black);
     clrscr;
     writeln;
     capwriteln(' {SKATMANAGER  '+ver+'} - {TAUSCHEN} von Spielerpositionen',white,lightgray);
     doubleline;
     writeln;
     writeln;
     cwriteln('           Welche beiden Spieler sollen die Position tauschen ? ',cyan);
     line;
     t1:=0;
     t2:=0;
     repeat
       cwrite  ('     1. Spieler angeben : ',lightgray);
       t1:=128;

       s:=newinput('',20,'Bitte Namen oder Nummer des 1. zu tauschenden Spielers eingeben',black,cyan,[]);
       writeln;
       s:=cutspace(s);

       if s>'' then t1:=getplayer(s,namen,spieler);
       gotoxy(40,wherey-1);
       if (t1 and 128)=0 then begin
          writeln(' Spieler ',t1,' : '+namen[t1]);
       end else begin
           if s>'' then cwriteln(' Tut mir leid, den kenne ich nicht !',lightred);
           t1:=0;
       end;
     until (t1>0) or (s='');
     if s<>'' then begin
        repeat
          cwrite  ('     2. Spieler angeben : ',lightgray);
          s:=newinput('',20,'Bitte Namen oder Nummer des 2. zu tauschenden Spielers eingeben',black,cyan,[]);
          writeln;
          s:=cutspace(s);
          t2:=128;
          if s>'' then t2:=getplayer(s,namen,spieler);
          gotoxy(40,wherey-1);
          if (t2 and 128)=0 then begin
             writeln(' Spieler ',t2,' : '+namen[t2]);
          end else begin
              if s>'' then cwriteln(' Ist das ein Spitzname ?',lightmagenta);
              t2:=0;
          end;
     until (t2>0) or (s='');
     end;
     if s<>'' then begin
        writeln;
        cwriteln('                     Es tauschen '+namen[t1]+' und '+namen[t2]+'.',white);
        line;
        for i:=1 to maxtab do
            swapint(puf[t1,i],puf[t2,i]);
        s:=namen[t1];
        namen[t1]:=namen[t2];
        namen[t2]:=s;
        b:=gc[t1];
        gc[t1]:=gc[t2];
        gc[t2]:=b;
        swapint(punkte[t1],punkte[t2]);
        swapint(pup[t1],pup[t2]);
     end else begin
         writeln;
         writeln;
         capwriteln(' {***} Operation abgebrochen {***}',lightred+blink,red);
         writeln;
     end;
   end;
   unscol;
end;

function getmodus(mode,addi:byte):s80;
var  abstr:array[1..4] of s80;
begin
     abstr[1]:='Kompaktmodus';
     abstr[2]:='Realwerte (selber rechnen)';
     abstr[3]:='Spiel + Trumpf (Mit Buben links + 1)';
     abstr[4]:='Mit/Ohne + Trumpf (Mit Buben links)';
     if (mode=0) and (addi=1) then
        getmodus:=abstr[4]
     else
        getmodus:=abstr[mode+addi+1];
end;

function askwin(ypos,x1,y1,x2,y2:byte;s1,s2,s3:s80;c1,c2:byte;a1,a2:char):boolean;
begin
     infowin(ypos,x1,y1,x2,y2,s1,s2,c1,c2);
     sline(s3,black);
     askwin:=aoderb(a1,a2,'','');
     infoclose;
end;

function askwin2(ypos,x1,y1,x2,y2:byte;s1,s2,s3:s80;c1,c2:byte;a1,a2:char):byte;
begin
     infowin(ypos,x1,y1,x2,y2,s1,s2,c1,c2);
     sline(s3,black);
     askwin2:=a2oderb2(a1,a2,'','');
     infoclose;
end;


begin
end.