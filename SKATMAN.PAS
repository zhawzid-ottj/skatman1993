{$M $f000,$0,$80000 }   { 16K stack, no heap }

(*                                                        *)
(*                                                        *)
(*    Kleiner ? SKAT-Manager Version 1.00b by Jakob Ott   *)
(*                                                        *)
(*                   (C) Juli 1993                        *)


uses crt,dos,skatunit,tools,pdmenu;


              (*    ------------Hauptprogramm------------   *)

function choosewin(var d:disk;var reiz:word):byte;
var i,j,xp:byte;
    s:s80;
    fl:boolean;
    spi:array[1..3] of byte;
    code:word;
    a:char;
begin
   with d do begin
      winopen(2,23,15,57,22,1,1,80,25,white,cyan,'Spieler mit '+#24+#25+' und <CR> wÑhlen');
      maskreset(LAST);
      j:=0;
      for i:=1 to spieler do begin
          if (spieler=3) or (i<>sz) then begin
             inc(j); spi[j]:=i;
             str(punkte[i],s);
             s:='Spieler '+namen[i]+' mit '+s+' Punkten.';
             newmask(LAST,3,j+1,30,4,namen[i],'',s,yellow,blue,[]);
          end else begin
              if spieler=4 then begin
                 gotoxy(1,7);
                 s:='   ( '+namen[i]+' ist Geber )';
                 gotoxy(34-length(s),7);
                 cwrite(s,lightcyan);
              end;
          end;
      end;
      s:='';
      newmask(LAST,20,5,6,0,s, 'Reizwert','Hier kann der Reizwert eingetragen werden (Reizwertkontrolle)',
      white,blue,['0'..'9']);
      fc(white);
      rahmen(25,16,56,21,1,'');
      xp:=4;
      code:=0;
      repeat
         maskinit(last);
         fl:=maskinput(LAST,xp);
         if fl=True then begin
            if inparm[4].s>'' then val(inparm[4].s,reiz,code)
            else begin
                 reiz:=0;
                 code:=0;
            end;
            if (not((reiz in [null,nullouvert,nullouverthand]) or
            (reiz mod  9=0) or (reiz mod 10=0) or
            (reiz mod 11=0) or (reiz mod 12=0)) or
            (reiz<18)) and (reiz<>0) then begin
                      ssline('UngÅltiger Reizwert ! Bitte korrigieren...',white+blink,red);
                      baba;
                      a:=wait5('',false);
                      code:=1;
                      xp:=4;
            end;
            if (inparm[0].cx=4) and (reiz=0) then fl:=FALSE;
         end;
      until (fl=false) or ((inparm[0].cx<4) and (code=0));
   end;
   winclose(2);
   if fl=FALSE then choosewin:=0 else
      choosewin:=spi[inparm[0].cx];
end;



 var spieler,sz,sq,sr,tx,fcol,hcol,wy,cux,cuy:byte;

     sp:integer;
     d,d2:disk;

     c:cont;

     moduss:modustyp;
     m2,m3,i,j,mult,trumpf,anzahl,pu,ra:integer;
     a,b:char;
     olds,s:s80;
     datei,st:s80;
     farb,flag,test,fl,bo:boolean;
     code,spt:byte;
     ccuu,p,f,cod,am,vcols,reiz:word;
     Karten:array[1..6] of s20;
begin
     m2:=-1;
     m3:=-1;
     code:=1;

        (*      Initialisierungsteil    *)

        hcol:=BLACK;
        fcol:=lightgray;

     karten[1]:='KARO';
     karten[2]:='HERZ';
     karten[3]:='PIK';
     karten[4]:='KREUZ';
     karten[5]:='GRAND';
     karten[6]:='GRAND-OUVERT';


     moduss[1]:='EIN NORMALES SKATSPIEL ';
     moduss[2]:='R A M S C H ';
     moduss[3]:='B O C K ';

     tx:=textattr;
     ccuu:=getcursor;
     intro(d,cols);
     am:=1;
     sp:=0;
     datei:='';

                       (*       -------- Hauptteil -------       *)

     flag:=TRUE;
     repeat
        with d do begin
           if mode=1 then begin
                merker:=0; { Real --> kein Ramsch }
                modus:=1;
             end;
             scol(lightgray,black);
             if sp>=0 then begin
                clrscr;
                writeln;
                capwrite(' SKATMANAGER {'+ver+'}   >> Gespielt wird : ',lightcyan,lightgray);
                if modus>1 then begin
                   sound(1000+modus*1000);
                   delay(40);
                   nosound;
                   fc(lightred);
                   write(rac-1,'. ');
                end else begin
                    sound(600);
                    delay(20);
                    nosound;
                end;
                cwriteln(moduss[modus],white);
                fc(lightgray);
                doubleline;
                writeln;
                if modus=2 then begin
                   cwrite ('     Einen GRAND-HAND kînnen noch spielen : ',white);
                   cux:=wherex;
                   for i:=1 to spieler do
                       if gc[i]=FALSE then cwrite(namen[i]+', ',yellow);
                   if wherex=cux then begin
                      gotoxy(1,wherey);clreol;
                   end;
                   writeln;
                end;
                if merker>0 then begin
                   scol(lightmagenta,hcol);
                     write('     Noch zu spielende Ramsch/Bock-Runden : ');
                     fc(white);
                   writeln(merker);
                   unscol;
                end;
                writeln;
                spielerprint(d);
                writeln;
                cwrite('> '+namen[sz]+' ist Geber. ',white);
                cwrite('- '+namen[((sz) mod spieler)+1]+' hîrt. ',lightcyan);
                cwrite('- '+namen[((sz+1) mod spieler)+1]+' sagt. ',lightgreen);
                writeln;
                scol(lightblue,blue);
                gotoxy(1,13);
                banner;
                unscol;
                sp:=-1;
             end;
             s:='';
             if choose=FALSE then begin
                repeat
                  if sp>0 then sp:=0;
                  ra:=random(200)+1;
                  bo:=stringwin(16,1,1,80,25,s,' Bitte Alleinspieler identifizieren, optional Reizwert durch Komma getrennt.');
                  gotoxy(1,23);
                  clreol;
                  reiz:=0;
                  fl:=TRUE;
                  if pos(',',s)<>0 then begin
                     val(copy(s,pos(',',s)+1,20),reiz,cod);
                     if not((reiz in [null,nullouvert,nullouverthand]) or
                     (reiz mod  9=0) or (reiz mod 10=0) or
                     (reiz mod 11=0) or (reiz mod 12=0)) or
                     (reiz<18) then begin
                        clreol;
                        cwrite('                       UngÅltige Angabe des Reizwertes !',yellow+blink);
                        fl:=FALSE;
                        sp:=0;
                     end else
                        s:=copy(s,1,pos(',',s)-1);
                  end;
                  if (s>'') and (fl=TRUE) then sp:=getplayer(s,namen,spieler);
                  if sp>127 then begin
                     if sp>128 then begin
                        fl:=askwin(16,1,1,80,25,' Soll da wohl '+namen[sp and 127]+' spielen oder was ? ',
                        'Wer ist "'+s+'" ?',
                        '"J" oder "N"  (oder RETURN=J/ESC=N)',lightcyan,blue,'J','N');
                        if fl=TRUE then begin
                           sp:=sp and 127;
                        end
                        else sp:=0;
                     end
                     else begin
                        cwrite('                 Wer soll denn da wohl spielen, ahem..ahem ?',lightmagenta+blink);
                        sp:=0;
                     end;
                  end;
                  if (spieler=4) and (sp=sz) then begin
                     clreol;
                     cwrite('      Bei 4 Spielern setzt der Geber aus und kann deshalb NICHT spielen !!!',red+blink);
                     if sp>0 then sp:=0;
                  end;
                until (sp>0) or (s='');
             end else begin
                 spt:=choosewin(d,reiz);
                 if spt>0 then sp:=spt;
                 if sp<=0 then s:='' else s:=' ';
             end;
             gotoxy(1,21);
             if s>'' then begin
                olds:='';
                d2:=d;
                scol(lightgray,black);
                clrscr;
                writeln;
                cwrite(' SKATMANAGER '+ver+' - ',white);
                if (mode=0) then cwrite('Kompakt-',white);
                cwriteln('Abrechnung',white);
                doubleline;
                writeln;
                cwriteln('> '+namen[sz]+' ist Geber.',white);
                cwrite  ('> '+namen[((sz) mod spieler)+1]+' hîrt und ist vorn.',lightcyan);
                gotoxy(40,wherey);capwriteln(' {-->} Es spielt {'+namen[sp],yellow,green);
                    cwrite('> '+namen[((sz+1) mod spieler)+1]+' sagt.',lightgreen);
                gotoxy(40,wherey);
                if reiz>0 then write(' --> Reizwert : ',reiz);
                writeln;
                s:=' SM'+ver;
                repeat
                   if s<>' SM'+ver then clrlns;
                   s:=olds;
                   flag:=TRUE;
                   scol(lightgray,black);
                   sq:=0;
                   pu:=0;
                   trumpf:=0;
                   anzahl:=0;
                   d:=d2;
                   if (mode=0) and (modus<>2) then begin
                      scol(lightgray,black);
                      writeln;
                      cwriteln(' Mîgliche Attribute:',white);
                      writeln('---');
                      capwriteln(' (~N)ull=23; (~N)ull(~H)and=35; (~N)ull(~O)uvert=46; (~N)ull(~O)uvert(~H)and=59'
                      ,white,green);
                      capwrite(' (~G)rand=',white,cyan);
                      fc(cyan);
                      write(grand);
                      capwrite('; (~G)rand(~O)uvert=',white,cyan);
                      writeln(grandouvert);
                      capwriteln(' (~1)=Kreuz - (~4)=Karo als Trumpffarbe',white,cyan);
                      writeln;
                      capwriteln(' Das Zeichen (~-) und (~1) - (~5) als Anzahl der Buben',white,cyan);
                      writeln;
                      capwriteln(' (~S)chneider, Sch(~w)arz, (~H)and, (~O)uvert, (~A)ngesagt, (~#48=48 Punkte)',white,cyan);
                      capwriteln(' (~U)eberreizt, (~V)erloren, (~C)ontra, (~R)e, (~B)ock      (~*=RAMSCH)',white,cyan);
                      writeln('---');
                      writeln;
                      capwrite(' Bitte {gÅltigen} Abrechnungscode eingeben : ',lightmagenta,magenta);
                      cux:=wherex;cuy:=wherey;
                      s:=olds;
                      repeat
                         gotoxy(cux,cuy);
                         s:=newinput(s,16,'Bitte SKAT-Abrechnungscode eingeben',white,blue,[]);
                         writeln;
                         s:=cutspace(doup(s));
                         if (s>'') and (s[1]='#') then begin
                            flag:=TRUE;
                            val(copy(s,2,15),pu,cod);
                            if cod<>0 then begin
                               pu:=0;
                               flag:=false;
                               capwrite(' {-->} UngÅltige numerische Angabe der Punkte, Umwandlungsfehler !'
                               ,lightred,red)
                            end else begin
                                anzahl:=0;
                                if pu=0 then begin
                                   s:='';
                                   anzahl:=1;
                                end;
                                clrlns;
                            end;
                         end else begin
                             pu:=0;
                             trumpf:=0;
                             anzahl:=0;
                             mult:=0;
                             if pos('G',s)<>0 then   trumpf:=GRAND;
                             if pos('N',s)<>0 then   pu:=NULL;
                             p:=0;
                             f:=0;
                             for i:=1 to length(s) do begin
                                 if s[i] in ['1'..'5'] then
                                    if (s[i]<>'5') and ((i=1) or (s[i-1]<>'-')) then
                                       f:=i
                                     else
                                       p:=i;
                             end;
                             if p>0 then val(s[p],anzahl,cod);
                             inc(anzahl);
                             if f>0 then trumpf:=3-(ord(s[f])-ord('1'))+9;
                             flag:=FALSE;
                             writeln;
                             if (pu<>0) and (trumpf<>0) then
                                capwrite(' {--> Nullspiel} und {Grand}/{Farbspiel} {gleichzeitig}, oder was ~?'
                                ,lightred,red) else
                             if (pu<>0) and (anzahl>1) then
                                capwrite(' {--> Null}spiel mit/ohne {Buben} is'' leider vîlliger QUATSCH ~! '
                                ,lightred,red) else
                             if (pos('G',s)<>0) and (trumpf<Grand) then
                                capwrite(' {-->} Wer spielt hier {Farbe und Grand gleichzeitig ?'
                                ,lightred,red) else
                             if (trumpf=0) and (anzahl>1) then
                                capwrite(' {-->} Buben {ohne} korrekte Trumpffarbe oder einem Grand {gibt''s ja wohl nicht ! '
                                ,lightred,red) else
                             if (trumpf<>0) and (anzahl=1) then
                                capwrite(' {-->} Nicht mîglich, {Farbe/Grand ohne} korrekt angezeigte {Buben ! '
                                ,lightred,red) else
                             if (s<>'') and (trumpf+anzahl=1) and (pu=0) then
                                capwrite(' {-->} Soll das {irgend eine Wertung} sein ~? '
                                ,lightred,red) else
                             if (pos('A',s)<>0) and ((pos('W',s)=0) and (pos('A',s)=0)) then
                                capwrite(' {--> Was} soll denn da bitteschîn {angesagt} werden ~? '
                                ,lightred,red) else
                                               flag:=TRUE;
                         end;
                         clreol;
                      until flag=TRUE;
                      olds:=s;
                      flag:=FALSE;
                   end;
                   if (mode>1) or ((modus=2) and (mode<>1)) then begin
                      writeln;
                      capwriteln(' > Abrechnung erfolgt in {'+getmodus(mode,addi),lightcyan,cyan);
                      line;
                         if not ((modus=2) and (gc[sp]=TRUE)) then begin
                         sline('Bitte mit "J" oder "N" oder RETURN=J und ESC=N antworten',black);
                         case modus of
                              1: capwrite(' {Farbspiel}, {Grand}=24, {GrandOuvert}=36 (~J/~N) ? ',white,cyan);
                              2: capwrite(' Wird ein {GRAND-HAND} gespielt (~J/~N) ? ',lightred,red);
                              3: capwrite(' Ist der {BOCK} ein {Farbspiel}, {Grand}=24, {GrandOuvert}=36 (~J/~N) ? '
                                            ,white,magenta);
                         end;
                         farb:=jaodernein;
                         if farb=true then begin
                            cwriteln('---',white);
                            sline('Bitte entsprechende Wertung wÑhlen',black);
                            if modus<>2 then
                                 capwrite(' Trumpf (~1=Kreuz-~4=Karo, (~G)rand=24, Grand(~O)uvert=36)  ? ',white,cyan)
                            else capwrite('                     (~G)rand=24 oder Grand(~O)uvert=36   ? ',white,cyan);
                            repeat
                                  trumpf:=0;
                                  a:=upcase(readkey);
                                  if (modus<>2) and (a in ['1'..'4']) then
                                     trumpf:=3-(ord(a)-ord('1'))+9;
                                  if a='G' then trumpf:=13;
                                  if a='O' then trumpf:=14;
                            until trumpf in [9..14];
                            writeln(karten[trumpf-8]);
                            if trumpf=13 then trumpf:=GRAND;
                            if trumpf=14 then trumpf:=GRANDOUVERT;
                            flag:=FALSE;
                         end else
                         begin
                            if modus<>2 then begin
                               writeln;
                               sline('Bitte entsprechendes Nullspiel wÑhlen',black);
                               capwrite  (' (~N)ull=23, Null(~H)and=35, Null(~O)uvert, NullOuvertH(~A)nd=59, (~R)eal ? '
                                         ,white,magenta);
                               repeat
                                     a:=upcase(readkey);
                               until a in ['N','H','O','R','A'];
                               writeln(a);
                               flag:=FALSE;
                               pu:=0;
                               case a of
                                    'N': pu:=NULL;
                                    'H': pu:=NULLHAND;
                                    'O': pu:=NULLOUVERT;
                                    'A': pu:=NULLOUVERTHAND;
                                    'R': flag:=TRUE;
                               end;
                               anzahl:=1;
                            end else flag:=TRUE;  (* Wenn Ramsch, Handeing. *)
                         end;
                         if flag=FALSE then begin
                            if pu=0 then begin
                               case addi of
                                 0: capwrite('         Spiel                   (~2-~5/~7)                ? ',white,cyan);
                                 1: capwrite('       Mit/Ohne                  (~1-~4/~6)                ? ',white,cyan);
                               end;
                               anzahl:=0;
                               repeat
                                  a:=readkey;
                                  if a in ['1'..'7'] then anzahl:=ord(a)-ord('1')+1;
                                  if (anzahl=1) and (mode=2) and (addi=0) then anzahl:=0;
                                  if (anzahl=7) and (mode=2) and (addi=1) then anzahl:=0;
                               until anzahl in [1..7];
                               fc(white);
                               writeln(anzahl);
                               anzahl:=anzahl+addi;
                            end;
                            cwriteln('---',white);
                            if pu=0 then
                            capwriteln(' (~S)chneider, Sch(~w)arz, (~H)and, (~O)uvert, (~A)ngesagt, (~U)eberreizt,   '
                                         ,white,cyan)
                            else begin
                                capwrite(' (~U)eberreizt, ',white,cyan);
                                if pu<nullouvert then capwrite(' (~O)uvert, ',white,magenta);
                                if (pu=nullouvert) or (pu=Null) then capwrite(' (~H)and, ',white,magenta);
                                writeln;
                            end;
                            capwrite  (' (~V)erloren, (~C)ontra, (~R)e, (~B)ock.  (~*=RAMSCH)      ? ',white,cyan);
                            s:=newinput(olds,10,'Bitte (kombinierte) Skatabrechnungsattribute eingeben',white,blue,[]);
                            writeln;
                            s:=cutspace(doup(s));
                            olds:=s;

                            flag:=false;
                         end;
                      end;
                   end;
                   clrlns;
   { Attribute...}
                   if (mode<>1) and (anzahl>0) and (flag=FALSE) then
                      attribs(sp,s,d,mult,anzahl,trumpf,pu,reiz);


                   if flag=TRUE then begin
                      pu:=0;
                      if (modus=2) and (mode<>1) then begin  { Ramschfall }
                         writeln;
                         line;
                         if gc[sp]=TRUE then
                            capwriteln(' {Ramschabrechnung.} Spieler {'+namen[sp]+'} kann keinen GRAND-HAND mehr spielen.'
                            ,lightcyan,cyan)
                         else
                            capwriteln(' {Ramschabrechnung.} Spieler {'+namen[sp]+'} verliert oder spielt Durchmarsch.'
                            ,lightcyan,cyan);
                         line;
                         sline('Bitte mit "J" oder "N" oder RETURN=J und ESC=N antworten',black);
                         cwrite(' Wurde ein DURCHMARSCH=120 gespielt ? ',lightred);
                         if jaodernein=TRUE then pu:=120;
                      end;
                      if pu=0 then begin  { Handeingabe }
                         line;
                         if ((modus<>2) or (mode=1)) then
                            cwrite  (' Bitte Punkte fÅr Spieler '+namen[sp]+' eingeben : ',cyan)
                         else
                            capwrite  (' Bitte {NASSE} fÅr Spieler {'+namen[sp]+'} eingeben : ',lightred,cyan);

              pu:=intinput(0,-8000,4000,'Bitte erreichte Punkte (o. Nasse) eingeben',
                           'Eingabefehler. Bitte MôGLICHE Punktzahl eingeben',black,lightgray);
                          writeln;
                         if (modus=2) and (mode<>1) then pu:=-abs(pu);
                      end;
                   end;
                   line;
                   cwrite(' Folgerichtig bekommt Spieler '+namen[sp],cyan);
                   fc(white); write(' ',pu);
                   cwrite(' Punkte.',cyan);
                   if pu=0 then begin
                      writeln;
                      writeln;
                      cwriteln('      *** Spiel wird nicht gezÑhlt und nicht gewertet ***',lightred+blink);
                   end;
                   if pu<0 then begin
                      fc(lightred+blink);
                      writeln(' (Abzug)')
                   end;
                   if pu>0 then begin
                      fc(lightgreen);
                      writeln(' (Plus)');
                   end;
                   writeln;
                   fc(red);
                   sline('Bitte mit "J" oder "N" oder RETURN=J und ESC=N antworten',black);
                   capwrite(' --> Ist alles {korrekt} (~J/~N) ? ',lightred,red);
                 until jaodernein=TRUE;
                scol(lightgray,black);
                if pu<>0 then begin             { Eintr. erreichte Punkte }
                   punkte[sp]:=punkte[sp]+pu;
                   if pup[sp]=maxtab then begin
                      if maxtab<1000 then shareware(true,5);
                      for i:=1 to maxtab do
                          puf[sp,i]:=puf[sp,i+1]
                   end else
                       inc(pup[sp]);                { ..in Tabelle eintragen }
                   puf[sp,pup[sp]]:=punkte[sp];
                   if (not ((modus=2) and (flag=FALSE))) or (rageb=FALSE) then begin
                      inc(sz);                         { Geber+1 }
                      if sz>spieler then sz:=1;        { "um die Ecke" }
                   end;
                   if not ((modus=2) and (flag=FALSE)) then begin
                      if rac>0 then inc(rac);          { Ramsch/BockzÑhler }
                      if rac=5 then begin              { Ramsch/Bock 'rum ? }
                         if modus=3 then begin         { Bock durch ? }
                            modus:=1;
                            rac:=0;
                         end else begin                { Ramsch durch ? }
                             if modus=2 then begin
                                modus:=3;
                                rac:=2;
                             end;
                         end;
                      end;
                   end else if (modus=2) and (rac>0) then gc[sp]:=TRUE;
                   if (modus=2) and (rac=0) then begin
                      rac:=2;
                      inc(sz);
                      if sz>spieler then sz:=1;
                   end;
                end;
             end;
             repeat
                cod:=code;

                if (m2<>modus) or (m3<>merker) then minit(c,d);
                m2:=modus;
                m3:=merker;
                flag:=TRUE;
                c[3,1].togdat:=cols;
                c[3,2].togdat:=choose;
                c[3,3].togdat:=ramsch;        { Ramschautomatik }
                c[3,4].togdat:=doppelt;       { Grand-Ramsch-doppelt }
                c[3,5].togdat:=rageb;         { Geber-Regel }
                c[3,10].togdat:=(mode=0);      { Real }
                c[3,11].togdat:=(mode=1);     { Kompakt }
                c[3,12].togdat:=((mode=2) and (addi=1)); { Mit.. }
                c[3,13].togdat:=((mode=2) and (addi=0)); { Spiel.. }

                code:=actmenu((code div 20)+1,code mod 20,c);   {PulldownmenÅ aufrufen }

                cols:=c[3,1].togdat;
                choose:= c[3,2].togdat; { Ramscha. }
                ramsch:= c[3,3].togdat; { Ramscha. }
                doppelt:=c[3,4].togdat; { Gr-Ra-doppelt }
                rageb:=  c[3,5].togdat; { Geberregel }

                if c[3,10].togdat=TRUE then begin      { Handeingabe }
                   mode:=0;addi:=1;
                end;
                if c[3,11].togdat=TRUE then begin     { Kompaktmodus }
                   mode:=1;addi:=1;
                end;
                if c[3,12].togdat=TRUE then begin     { Mit... }
                   mode:=2;
                   addi:=1;
                end;
                if c[3,13].togdat=TRUE then begin     { Spiel... }
                   mode:=2;
                   addi:=0;
                end;
                a:=#0;
                case code of
                       1: a:=#13;
                      21: begin               { Bildschirmtabelle }
                        tabelle(d,FALSE,datei);
                        code:=1;
                      end;
                      22: tabelle(d,TRUE,datei);      { Tabelle -> Extern }
                      47: begin               { RAMSCH/BOCK-Runden-Fenster }
                          i:=merker;
                          merker:=intwin(16,1,1,80,25,merker,0,1000,' Ramsch/Bock-Runden : ',
                          'Hier kînnen Sie die Anzahl der verbleibenden Ramsch/Bock-Runden Ñndern',
                          'Bitte Anzahl der Ramsch/Bock-Runden zwischen 0 und 1000 eingeben');
                          a:=#0;
                          if i<>merker then begin
                             a:=#13;
                             code:=1;
                             sp:=1;
                          end;
                      end;
                      48: begin               { Spielernamenfenster }
                          fl:=namewin(d);
                          a:=#0;
                          if fl=FALSE then begin
                             code:=1;
                             a:=#13;
                             sp:=1;
                          end;
                      end;
                      61: tausch(d);          { Spielertausch }
                      62: korrektur(d);
                      63: begin               { Geber - 1 }
                              dec(sz);
                              if sz=0 then sz:=spieler;
                              code:=1;
                              a:=#13;
                              sp:=1;
                      end;
                      64: begin               { Ramsch beenden }
                             modus:=1;
                             rac:=0;
                             for i:=1 to spieler do gc[spieler]:=FALSE;
                             waitinfo(1,1,80,24,' ˇ--=*> Laufende Ramsch/Bock-Runde beendet <*=--',white+blink,red);
                             a:=#13;
                             code:=1;
                             sp:=1;
                      end;
                      65: begin
                          test:=sichern(d);      { Spiels./Eins. speichern }
                          if test=true then code:=1;
                      end;
                      66: begin
                          test:=LADEN(d);        { Spiels./Eins. laden }
                          if test=true then code:=21;
                      end;
                      67: begin
                          i:=neuspiel(d);        { Neues Spiel beginnen }
                          if i<>0 then begin
                             a:=#13;
                             code:=1;
                             sp:=1;
                          end else a:=#0;
                      end;
                      69: begin
                          test:=abrechnung(am,d);      { Pfennigskatabrechnung }
                          if test=TRUE then code:=1;
                      end;
                      70: help('SKATMAN.DOK',''); { Hilfefunktion }
                      71: info;                  { Programminformation }
                      81: begin                 { PROGRAMMENDE }
                           a:=#27;
                           code:=1;
                      end;
                      0: begin
                          a:=#13;
                          code:=1;
                      end;
                end;
                if a<>#13 then sp:=0;
                if code=0 then code:=cod;
                if a=#27 then begin
                   flag:=not(askwin(12,1,1,80,25,' Wollen Sie SKATMANAGER '+ver+' wirklich verlassen (J/N) ? ',
                   'Ist der Spielstand gespeichert ???',
                   '"J" oder "N"  (oder RETURN=J/ESC=N)',yellow,cyan,'J','N'));
                   if flag=TRUE then begin
                      a:=#0;
                      gotoxy(1,1);
                   end;
                end;
                if (merker>0) and (modus=1) then begin { Noch'n' Ramsch ? }
                   dec(merker);
                   for i:=1 to spieler do gc[i]:=FALSE;
                   modus:=2;
                   rac:=2;
                end;
                if a='!' then flag:=FALSE;
             until a in[#1,'G','!',#27,#13];
        end;
     until flag=FALSE;
     window(1,1,80,25);
     textattr:=255;
     clears;
     clrscr;

     setcursor(vnocursor);
     window(1,1,80,13);
     col(white,blue);
     CRT.clrscr;
     writeln;
     capwriteln('    Skatmanager '+ver+' by Jakob Ott (C) 1993 (SHAREWAREVERSION) - {ENDE}',lightred+blink,cyan);
     line;
     writeln;
     fc(yellow);
     writeln(' Lassen Sie sich REGISTRIEREN durch Einsendung von DM 20.- an :');
     writeln;
     fc(white);
     gotoxy(19,wherey);writeln('Jakob Ott');
     fc(lightgray);
     gotoxy(19,wherey);writeln('Hohe Stra·e 58');
     gotoxy(19,wherey);writeln('89518 Heidenheim a.d. Brenz');
     gotoxy(19,wherey);writeln('Tel.: 07321/49824');
     writeln;
     fc(lightcyan);
     writeln(' ...und tschÅss !');
     window(1,1,80,25);
     gotoxy(1,15);
     textattr:=TX;
     swrite(' Have a nice DOS...',50);
     setcursor(ccuu);
     writeln;
end.






