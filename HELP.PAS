{$M $f000,$0,$80000 }   { 16K stack, no heap }

uses crt,tools;

procedure help(sf,st:s80);
const line='컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴';
var a,b:char;
    f:file;
    f1:file of char;
    s,s1,s2:s80;
    sa:array[1..25] of s80;
    i,ii,i2,j,k,l:integer;
    flag,fl,fl2:boolean;
    size:word;
    buf: array[0..32768] of char;
    idx: array[1..2000] of word;
    numread:word;
begin
    numread:=0;
    size:=0;
    col(black,lightgray);
    crt.clrscr;
    if fileexists(sf) then begin
       setcursor(vstdcursor);
       sline('"'+sf+'" - Hilfstext wird geladen...',black+blink);
       assign(f,sf);
       reset(f,1);
       size:=filesize(f);
       writeln;
       write(' Gr붳e des Hilfstextes : ',size,' Bytes.');
       writeln;
       if a<>#27 then begin
          write(' Lese Datei...');
          blockread(f,buf,size,numread);
          writeln(' Gelesen : ',numread,' Bytes.');
       end;
       close(f);
    end;
    delstat(black);
    if ((SIZE<>0) and (size<32768)) AND (numread=size) then fl:=TRUE else
       fl:=FALSE;
    if fl=FALSE then begin
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
                   write(' ',i,' Bytes 켐> ',j,' Zeilen');
                   clreol;
                end;
                idx[j]:=i+2;
             end;
       until (i=size);
       gotoxy(1,wherey);
       write(' ',i,' Bytes 켐> ',j,' Zeilen');
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
                   wrtxy(1,25,' Seite N� '+st+' ');
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
             if (fl=true) or ((i mod 24)=0) then begin
                i:=i2+24;
                setcursor(valtcursor);
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


var cu:byte;
    s:s80;
begin
s:=paramstr(1);
if s='' then s:='SKATMAN.DOK';
cu:=getcursor;
help(s,'');
setcursor(cu);
end.