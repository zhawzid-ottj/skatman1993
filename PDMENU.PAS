
   (*                PULLDOWNMENU (C) 1992/93 by JAKOB OTT              *)
   (*                ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ              *)
   (*                                                                   *)
   (*  All rights reserved. No right to me..? My Rough Slayers to You!  *)
   (*                                                                   *)

unit pdmenu;

     INTERFACE

uses crt,dos,tools;

type menu=RECORD
     mens:string[32];
     hot,
     flag:byte;
     maxle:integer;
     com:string[80];
     tog,togdat,exclus:boolean;
end;

     s802        = string[80];
     cont        = array[0..10,0..19] of menu;
     mest        = string[50];
     bildtyp     = ^word;
     btyp        = array[1..4000] of char;

const
  scrseg:word = $b800;

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
    bild     : btyp absolute $b800:0000;


(**************************************************************************)


function  GetCursor:word;
PROCEDURE SetCursor(mode: word);
procedure sscr;
procedure bgr(a:char);

procedure menuinit(var c:cont);
procedure additem(c1,c2,tipe:byte;txt:mest;comment:s802;var c:cont);
procedure addmenu(c1,tipe:byte;txt:mest;com:s802;var c:cont);
function  actmenu(p1,p2:byte;var c:cont):byte;

(**************************************************************************)

IMPLEMENTATION


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


var
    basis    : bildtyp;

function kompo(offset:word):bildtyp;
begin
  kompo:=ptr(scrseg,offset);
end;

procedure sscr;
begin
  basis:=ptr(scrseg,0);
  move(basis^,kompo($1000)^,4096);
end;

procedure restorelines;
begin
  move(kompo($1000)^,basis^,4096);
end;


procedure restorerest(lines:byte);
begin
  move(kompo($11e0)^,kompo($01e0)^,160*(lines+3));
end;

procedure bgr(a:char);
var i:integer;
begin
   i:=1;
   repeat
      bild[i]:=a;
      i:=i+2
   until i=4001;
end;


procedure menuinit(var c:cont);
var i,j:integer;
begin
     for i:=0 to 10 do begin
         for j:=0 to 19 do begin
             with c[i,j] do begin
                  mens:='';
                  maxle:=-1;
                  hot :=0;
                  flag:=0;
                  tog:=FALSE;
                  togdat:=FALSE;
             end;
         end;
     end;
end;

procedure additem(c1,c2,tipe:byte;txt:mest;comment:s802;var c:cont);
const ss='                                                  ';
var i,ps,lgt:byte;
begin
   with c[c1,c2] do begin
        inc(c[c1,0].maxle);
        mens:=txt;
        flag:=tipe;
        ps:=pos('@',mens);
        if ps<>0 then begin
           hot:=ps;
           mens:=copy(txt,1,ps-1)+copy(txt,ps+1,256);
        end;
       com:=comment;
       exclus:=FALSE;
       if tipe>=10 then begin
          tog:=true;
          togdat:=(tipe-10=0);
          exclus:=FALSE;
          if tipe=11 then exclus:=TRUE
       end;
   end;

   i:=0;
   lgt:=0;
   if c2>0 then begin
      repeat
         inc(i);
         if (length(c[c1,i].mens)+3)>lgt then lgt:=length(c[c1,i].mens)+3;
      until i>=c[c1,0].maxle;
         if c[c1,0].maxle>0 then for i:=1 to c[c1,0].maxle do
            c[c1,i].mens:=copy(c[c1,i].mens+ss,1,lgt);
      end;
end;

procedure addmenu(c1,tipe:byte;txt:mest;com:s802;var c:cont);
var s:s80;
begin
    additem(c1,0,tipe,txt,com,c);
    c[0,0].flag:=0;
    c[c1,0].flag:=1;
end;

procedure itprint(teil:boolean;i,ii,dis,j,c1,c2,c3:byte;var c:cont);
var xrel,dx,ps:byte;
    s:string[50];
    const sl='ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ';

begin
    with c[i,ii] do begin
       if flag<>255 then begin
          if tog=false then xrel:=0 else xrel:=4;
          gotoxy(dis,wherey);
          if flag<>128 then
             col(c1,c2)
          else
             col(white,lightgray);
          if teil=FALSE then write(#16) else write('³');
          write(copy(mens,1,length(mens)-xrel));
          if tog=TRUE then begin
             if togdat=TRUE then begin
                if exclus=FALSE then cwrite(' [û]',white)
                else cwrite(' [X]',white)
             end else begin
                if teil=TRUE then cwrite(' [ ]',black)
                else cwrite(' [ ]',lightgray);
             end;
          end;
          if teil=FALSE then write(#17) else write('³');
          if flag<>128 then
             col(c3,c2);
          ps:=hot;
          if ps<>0 then begin
                  gotoxy(dis+ps,wherey);
                  if cols=true then write(mens[ps])
                  else cwrite(mens[ps],white);
                  gotoxy(dis+j,wherey);
          end
       end else begin
          s:='Ã'+sl;
          s[0]:=chr(j-1);
          s:=s+'´';
          gotoxy(dis,wherey);
          col(c1,c2);
          write(s);
       end;
    end;
end;


procedure menuup(j,jc,count:byte);
var i:byte;
begin
     restorerest(count);
     gotoxy(jc+1,3);
     col(YELLOW,BLUE);
     write('ÍÍÍÍÍ');
end;


function menusel(p1,pmax,jc,j,count:byte;var c:cont):byte;
var i,ii,ix,jj,ms:byte;
    a1,a2:char;
    flag1,flag2,togtest:boolean;
    s:s80;
begin
flag1:=TRUE;

ii:=c[p1,0].flag;
repeat
      with c[p1,ii] do begin
         if (flag1=TRUE) or (togdat<>togtest) then begin
            gotoxy(1,4+ii);
            itprint(false,p1,ii,jc,j,WHITE,BLACK,red,c);
            sline(c[p1,ii].com,black);
         end;
         togtest:=togdat;
         dateinfo(58,2,white,blue);
         a1:=crt.readkey;
         flag1:=FALSE;
         jj:=ii;
         if a1=#0 then begin
            ms:=0;
            a2:=crt.readkey;
            case a2 of
               #80: if ii<count then begin
                       repeat
                          inc(ii);
                       until ((c[p1,ii].flag<128) or (ii=1));
                       flag1:=TRUE;
                    end;
               #72:
                    if ii>0     then begin
                       repeat
                          dec(ii);
                       until ((c[p1,ii].flag<128) or (ii=1));
                       flag1:=TRUE;
                    end;
               #73: begin if ii>1 then begin
                             ii:=1; flag1:=true; end;
                     end;
               #81: begin if ii<count then begin
                             ii:=count; flag1:=true; end;
                    end;
               #75: begin  ms:=254; end;
               #77: begin  ms:=255; end;
            end;
          end
          else begin
             for i:=1 to count do begin
                 if (upcase(c[p1,i].mens[c[p1,i].hot])=upcase(a1)) and (a1<>#32) then begin
                    a1:=#13;
                    ii:=i;
                    menusel:=ii;
                    flag1:=true;
                 end;
             end;
         end;
         if (a1=#13) or ((a1=#32) and (tog=TRUE)) then begin
            with c[p1,ii] do begin
               menusel:=ii;
               if tog=TRUE then begin
                  if exclus=TRUE then begin
                     ix:=0;
                     repeat
                        inc(ix);
                        if (ix<>ii) and (c[p1,ix].exclus=TRUE) then begin
                           c[p1,ix].togdat:=FALSE;
                           gotoxy(1,ix+4);
                           itprint(true,p1,ix,jc,j,black,lightgray,red,c);
                        end;
                     until ix=COUNT;
                     togdat:=TRUE;
                     gotoxy(1,ii+4);
                  end else
                      togdat:= not togdat;
                 a1:=#1;
               end;
            end;
         end;
         if ii<1 then a1:=#27;
         if (flag1=TRUE) then begin
            gotoxy(1,4+jj);
            itprint(true,p1,jj,jc,j,black,lightgray,red,c);
         end;
      end;
  until (((a1=#27) or (a1=#13)) or (ms>253));
  if ms>253 then menusel:=ms;
  if a1=#27 then menusel:=253;
  if ii>=1 then
      c[p1,0].flag:=ii
   else c[p1,0].flag:=1;
end;

function menudown(p1,pmax,jc:byte;var p2:byte;var c:cont):integer;
const r1:array[1..3] of char=('Ú','Ä','¿');
const r2:array[1..3] of char=('³',' ','³');
const r3:array[1..3] of char=('À','Ä','Ù');
var i,j,cp,md:integer;
    lgt,item,jcc:byte;
    cc1,cc2:char;
    s:string[80];
begin
   i:=0;
   lgt:=0;
   repeat
     inc(i);
     if length(c[p1,i].mens)>lgt then lgt:=length(c[p1,i].mens);
   until ((c[p1,i].mens='') or (i=19));
   with c[p1,0] do begin
   if maxle>1 then begin
         j:=lgt+2;
         jcc:=jc;
         if jc+j>80 then jc:=80-j-2;
         col(BLACK,LIGHTGRAY);
         gotoxy(jc,4);write(r1[1]);for i:=1 to j-2 do write(r1[2]);write(r1[3]);
          col(YELLOW,BLUE);
          gotoxy(jcc+2,3);write('¸ Õ');
          col(BLACK,LIGHTGRAY);
          gotoxy(jcc+2,4);write('Ù À');
         for i:=1 to maxle do begin
             gotoxy(1,i+4);
             itprint(true,p1,i,jc,j,black,lightgray,red,c);
             col(darkgray,black);
             write(bild[160*(wherey-1)+2*(wherex-1)+1]);
         end;
         col(black,lightgray);
         gotoxy(jc,maxle+5);write(r3[1]);for i:=1 to j-2 do write(r3[2]);
         write(r3[3]);
         cp:=160*(wherey-1)+2*(wherex-1)+1;
         col(darkgray,black);
         write(bild[cp]);
         gotoxy(jc+1,maxle+6);
         for i:=1 to j do begin
             bild[160*(wherey-1)+2*(wherex-1+i)]:=#8
         end;
         md:=menusel(p1,pmax,jc,j,maxle,c);
         menudown:=md;
         menuup(j,jcc,maxle);
         p2:=md;
      end else begin
          menudown:=-1;
      end;
   end;
end;




function actmenu(p1,p2:byte;var c:cont):byte;
const t :array[1..3] of char=('Ñ','³','Ï');
const tl:array[1..3] of char=('Õ','³','Ô');
const tr:array[1..3] of char=('¸','³','¾');
var s:mest;
    ii,f,pb,p0:byte;
    h,a1,a2,a3,a4:char;
    cx,cy,mx,my:byte;
    l:string[80];
    m,n:string[80];
    code,i,j,k,jc:integer;
    count,co2,lgt,dis,dx,ps:byte;
    cur:word;
    flag1,flag2:boolean;
const ss='                                                                              ';
begin
   cx:=WHEREX;cy:=WHEREY;
   sscr;
   cur:=GETCURSOR;
   setcursor(Vnocursor);
   col(YELLOW,BLUE);
   FillChar(l, 79, 'Í');
   l[0]:=#78;
   gotoxy(2,1);write(l);
   gotoxy(2,3);write(l);
   FillChar(l, 79, 'ú');
   l[0]:=#78;
   col(LIGHTBLUE,BLUE);
   gotoxy(2,2);write(l);
   col(YELLOW,BLUE);
   gotoxy(2,2);
   i:=0;
   lgt:=0;
   co2:=0;
   c[p1,0].flag:=p2;
   repeat
     inc(i);
     if length(c[i,0].mens)>=lgt then
        lgt:=length(c[i,0].mens);
     count:=i-1;
   until ((c[i,0].mens='') or (i=16));
   if c[0,0].flag=0 then begin
      for i:=1 to count do
          c[i,0].mens:=copy(c[i,0].mens+ss,1,lgt+1);
      c[0,0].flag:=lgt;
   end
   else lgt:=c[0,0].flag;
   j:=lgt+2;
   dis:=1;
   for k:=1 to 3 do begin
       gotoxy(dis,k);
       write(tl[k]:1);
       gotoxy(80,k);
       write(tr[k]:1);
   end;
   for i:=1 to count do begin
       for k:=1 to 3 do begin
           if k=2 then begin
              gotoxy(1,2);itprint(true,i,0,dis,j,yellow,blue,white,c);
              col(YELLOW,BLUE);
           end;
       gotoxy(dis+j,k);
       write(t[k]:1);
       end;
       dis:=dis+j;
       gotoxy(dis,k);
       write(t[k]:1);
   end;
   FillChar(l, 79, 'Í');
   l[0]:=#78;
   FillChar(m, 79,#31);
   l[0]:=#78;
   FillChar(n, 79,#30);
   l[0]:=#78;
   flag2:=TRUE;
   flag1:=FALSE;
   if p2>0 then flag1:=TRUE;
   ii:=161;
   p0:=0;
   repeat
      pb:=p1;
      jc:=0;
      jc:=1+(p1-1)*j;
      if (((flag1 or flag2)=FALSE) and (ii>=160)) then
         ii:=0;
      if (flag1=TRUE) and (c[p1,0].maxle>0) then begin
         repeat
             code:=menudown(p1,count,jc+1,p2,c);

             if code=254 then begin
                                if p1>1 then     begin dec(p1);   pb:=p1;    end
                                else             begin p1:=count; pb:=count; end;
                              end;
             if code=255 then begin
                                if p1<count then begin inc(p1);   pb:=p1; end
                                else             begin p1:=1;     pb:=1;     end;
                              end;
             jc:=1+(p1-1)*j;
         until ((code>0) and (code<254)) or (code=-1);
      end else code:=0;
      if (code<=0) or (code=253) then begin
         flag1:= FALSE;
         flag2:=TRUE;
         if flag2=TRUE then begin
             sline(c[p1,0].com,black);
             col(BLACK,LIGHTGRAY);
             for k:=1 to 3 do begin
                 gotoxy(jc,k);write(tl[k]);
                 gotoxy(jc+j,k);write(tr[k]);
             end;
             gotoxy(1+jc,1);write(copy(l,1,j-1));
             gotoxy(1+jc,3);write(copy(l,1,j-1));
             gotoxy(1,2);itprint(true,p1,0,jc,j,black,lightgray,red,c);
             flag2:=FALSE;
         end;
         dateinfo(58,2,white,blue);
         a1:=crt.readkey;
         if a1=#13 then begin
            if c[p1,0].maxle=0 then code:=(p1-1)*20+1 else
            begin
               if ((c[p1,0].maxle>0) and ((c[p1,1].mens<>'') or (c[p1,0].flag>0))) then
               begin {c[p1,0].flag:=1;} flag1:=TRUE; flag2:=TRUE; end;
            end;
         end;
         if a1=#27 then code:=255;
         if a1=#0 then begin
            a2:=crt.readkey;
                case a2 of
                   #77: if p1<count then begin inc(p1); flag2:=TRUE; end
                        else             begin p1:=1;   flag2:=TRUE; end;
                   #75: if p1>1     then begin dec(p1);   flag2:=TRUE; end
                        else             begin p1:=count; flag2:=TRUE; end;
                   #80: if ((c[p1,0].maxle>0) and ((c[p1,1].mens<>'') or (c[p1,0].flag>0))) then
                        begin c[p1,0].flag:=1; flag1:=TRUE; flag2:=TRUE; end;
                end;
         end
         else begin
                for i:=1 to count do begin
                    if upcase(c[i,0].mens[c[i,0].hot])=upcase(a1) then begin
                       p1:=i;
                       if c[p1,0].maxle=0 then code:=(p1-1)*20+1
                    end;
                end;
                flag1:=TRUE;
         end;
         if (p0<>p1) or (flag1=TRUE) then flag2:=TRUE;
         if flag2=TRUE then begin
            col(YELLOW,BLUE);
            for k:=1 to 3 do begin
                gotoxy(jc+j,k);write(t[k]);
                gotoxy(jc,k);
                if pb>1 then write(t[k])
                else
                   write(tl[k])
            end;
            gotoxy(1+jc,1);write(copy(l,1,j-1));
            gotoxy(1+jc,3);write(copy(l,1,j-1));
            gotoxy(1,2);itprint(true,pb,0,jc,j,yellow,blue,white,c);
         end;
      end;
      p0:=p1;
   until ((code>0) and (code<>253));
   if ((code>0) and (code<253)) then
      code:=(p1-1)*20+(code mod 20)
   else
      code:=0;
   if (code mod 20)>0 then c[p1,0].flag:=code mod 20;
   actmenu:=code;
   gotoxy(cx,cy);
   setcursor(cur);
   restorelines;
end;


begin
end.