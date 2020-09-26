program SkatdatDirecotry;

uses crt,dos,minitool;


type  s20=string[20];
      namentyp = array[1..4] of s20;
      modustyp = array[1..4] of s80;
      punktetyp= array[1..4] of integer;            (* Gesamtpunkte     *)
      pufeldtyp= array[1..4,1..1000] of integer;     (* Punktearray      *)
      pupostyp = array[1..4] of integer;            (* Position im Feld *)
      gctyp = array[1..4] of BOOLEAN;               (* Spieler schon GRAND ? *)


      disk=RECORD
         gc:gctyp;
         pup:pupostyp;
         puf:pufeldtyp;
         namen:namentyp;
         punkte:punktetyp;
         spieler,sz,modus,rac,merker,mode,addi,du1,du2,du3,du3a,du3b,du3c:byte;
         du4,du5,du6:word;
         ramsch,doppelt,rageb,pull,choose,du10,du11:boolean;
      end;


type TDateTime=Record
     year,month,day,hour,min,sec:word;
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



var a:char;
begin
   col(lightgray,black);
   writeln;
   directory;
end.