Unit THString;
Interface
Var
  Vstup:String;


Function  UpString(S:String):String;
Function HexByte(B:Word):String;
Function HexWord(B:Word):String;
Function LeadingZero(w : Word) : String;
Procedure InputLine(x,y,Delka:Byte;old:String);
Procedure InputTextLine(x,y,Delka:Byte;old:String);
Procedure InputNumLine(x,y,Delka:Byte;Old:Integer);
Function InputHexWordLine(x,y,Delka:Byte;Old:Word):Word;
Function InputHexByteLine(x,y:Byte;Old:Byte):Byte;
Function IntToStr(I:Longint):String;

Implementation
Uses Crt,Dos,THApp,CZ;



Procedure GotoXY(x,y:Byte);
Var
  B:Byte;
begin
  B:=MEM[0:$462];
  Asm
  MOV AH,2
  MOV BH,B
  MOV DL,X
  MOV DH,Y
  INT 10h
  end;
end;



Function HexByte(B:Word):String;
  Function Hex(B:Word):Char;
  begin
    If B< $A then Hex:=Char(B+Byte('0')) else Hex:=Char(B+(Byte('A') - $A));
  end;
begin
  HexByte:=Hex(B shr 4) + Hex(B and $F)
end;


Function HexWord(B:Word):String;
begin
  HexWord:=HexByte(Hi(B))+HexByte(Lo(B));
end;


Function UpString(S:String):String;
Var
  I:Integer;
  SUp:String;
begin
  SUp:=S;
  For I:=1 to Length(S) do
  begin
    SUp[I]:=UpCase(S[I]);
  end;
  UpString:=SUp;
end;



Function LeadingZero(w : Word) : String;
var
  s : String;
begin
  Str(w:0,s);
  if Length(s) = 1 then
    s := '0' + s;
  LeadingZero := s;
end;





Procedure InputLine(x,y,Delka:Byte;old:String);
Var
  p:String;
  fill,Poz:Integer;
  V:Char;
begin
   Vstup:=old;
   Poz:=Length(Old);
   GotoXY(x,y);For fill:=0 to Delka do Write(' ');
   GotoXY(x,y);Write(Old);
   TextCursor(True);
   Poz:=Length(Old);
   Repeat
     GotoXY(x+Poz,y);
     GetKey;
     If (Scan=82)and(Ascii=224)then Ascii:=0;
     If (Scan=75)and(Ascii=224)then
     begin If Poz>0 then Dec(Poz);Ascii:=0;end;
     If (Scan=77)and(Ascii=224)then
     begin If Poz<Length(Vstup) then Inc(Poz);Ascii:=0;end;
     If (Scan=83)and(Ascii=224)then
     begin Delete(Vstup,Poz+1,1);Ascii:=0;end;
     If ((Scan=71)or(Scan=73)or(Scan=72))and(Ascii=224)then
     begin Poz:=0;Ascii:=0;end;
     If ((Scan=79)or(Scan=81)or(Scan=80))and(Ascii=224)then
     begin Poz:=Length(Vstup);Ascii:=0;end;
     p:='';
     If ((Ascii>=46)and(Ascii<=57))or((Ascii>=65)and(Ascii<=122))or(Ascii=92)or
        (Ascii=58)or(Ascii=32)or((ASCII>=128)and(ASCII<=255))or
        (ASCII=ord('+'))or(ASCII=ord('-'))or(ASCII=ord('*'))or(ASCII=ord('{'))or
        (ASCII=ord('}'))or(ASCII=ord('+'))or(ASCII=ord('='))or(ASCII=ord(';'))or
        (ASCII=ord('?'))or(ASCII=ord('~'))or(ASCII=ord(','))or(ASCII=ord('<'))or
        (ASCII=ord('>'))or(ASCII=39)or(ASCII=34)and((Scan<>72)and(Scan<>80))then
     begin
       If Length(Vstup)<Delka then
       begin V:=Chr(Ascii);Poz:=Poz+1;end;
     end
     else V:=#0;
     If (Length(Vstup)>0)and(Scan=14)and(Poz>0) then
     begin Delete(Vstup,Poz,1);Dec(Poz);end;
     If (V<>#0)and(Length(Vstup)<Delka) then Insert(V,Vstup,Poz);
     For fill:=1 to (Delka-Length(Vstup)) do p:=p+' ';
     {TextBackground(1);}GotoXY(x,y);Write(Vstup+p);
   until (Scan=28)or(Scan=1);
   TextCursor(False);
end;




Procedure InputTextLine(x,y,Delka:Byte;old:String);
Var
  p:String;
  fill,Poz:Integer;
  V:Char;
begin
   Vstup:=old;
   Poz:=Length(Old);
   GotoXY(x,y);For fill:=0 to Delka do Write(' ');
   GotoXY(x,y);Write(Old);
   TextCursor(True);
   Poz:=Length(Old);
   Repeat
     TextColor(7);
     GotoXY(x+Poz,y);
     GetKey;
     If (Scan=82)and(Ascii=224)then Ascii:=0;
     If (Scan=75)and(Ascii=224)then
     begin If Poz>0 then Dec(Poz);Ascii:=0;end;
     If (Scan=77)and(Ascii=224)then
     begin If Poz<Length(Vstup) then Inc(Poz);Ascii:=0;end;
     If (Scan=83)and(Ascii=224)then
     begin Delete(Vstup,Poz+1,1);Ascii:=0;end;
     If ((Scan=71)or(Scan=73)or(Scan=72))and(Ascii=224)then
     begin Poz:=0;Ascii:=0;end;
     If ((Scan=79)or(Scan=81)or(Scan=80))and(Ascii=224)then
     begin Poz:=Length(Vstup);Ascii:=0;end;
     p:='';
     If ((Ascii>=48)and(Ascii<=58))or((Ascii>=65)and(Ascii<=122))or(Ascii=92)or
        (Ascii=58)or(Ascii=32)or((ASCII>=128)and(ASCII<=173))or(ASCII=46)or
        (ASCII=39)or(ASCII=34)or(ASCII=38)and((Scan<>72)and(Scan<>80))or
        (ASCII=ord('+'))or(ASCII=ord('-'))then
     begin
       If Length(Vstup)<Delka then
       begin V:=Chr(Ascii);Poz:=Poz+1;end;
     end
     else V:=#0;
     If (Length(Vstup)>0)and(Scan=14)and(Poz>0) then
     begin Delete(Vstup,Poz,1);Dec(Poz);end;
     If (V<>#0)and(Length(Vstup)<Delka) then Insert(V,Vstup,Poz);
     For fill:=1 to (Delka-Length(Vstup)) do p:=p+' ';
     TextColor(15);GotoXY(x,y);Write(Vstup+p);
   until (Scan=28)or(Scan=1)or(Scan=15);
   TextCursor(False);
end;




Procedure InputNumLine(x,y,Delka:Byte;Old:Integer);
Var
  p:String;
  Fill,Poz:Integer;
  V:Char;
begin
   Vstup:='';
   Poz:=0;
   GotoXY(x,y);For fill:=0 to Delka do Write(' ');
   Str(Old,Vstup);
   GotoXY(x,y);Write(Old);
   TextCursor(True);
   Poz:=Length(Vstup);
   Repeat
     GotoXY(x+Poz,y);
     GetKey;
     If (Scan=82)and(Ascii=224)then Ascii:=0;
     If (Scan=75)and(Ascii=224)then
     begin If Poz>0 then Dec(Poz);Ascii:=0;end;
     If (Scan=77)and(Ascii=224)then
     begin If Poz<Length(Vstup) then Inc(Poz);Ascii:=0;end;
     If (Scan=83)and(Ascii=224)then
     begin Delete(Vstup,Poz+1,1);Ascii:=0;end;
     If ((Scan=71)or(Scan=73)or(Scan=72))and(Ascii=224)then
     begin Poz:=0;Ascii:=0;end;
     If ((Scan=79)or(Scan=81)or(Scan=80))and(Ascii=224)then
     begin Poz:=Length(Vstup);Ascii:=0;end;
     p:='';
     If (Ascii>=48)and(Ascii<=57) then
     begin
       If Length(Vstup)<Delka then
       begin V:=Chr(Ascii);Poz:=Poz+1;end;
     end
     else V:=#0;
     If (Length(Vstup)>0)and(Scan=14)and(Poz>0) then
     begin Delete(Vstup,Poz,1);Dec(Poz);end;
     If (V<>#0)and(Length(Vstup)<Delka) then Insert(V,Vstup,Poz);
     For fill:=1 to (Delka-Length(Vstup)) do p:=p+' ';
     GotoXY(x,y);Write(Vstup+p);
   until (Scan=28)or(Scan=1)or(Scan=15);
   TextCursor(False);
end;




Function InputHexWordLine(x,y,Delka:Byte;Old:Word):Word;
Var
  p:String;
  Fill,Poz:Integer;
  V:Char;
  W:Word;
begin
   Vstup:='';
   Poz:=0;
   GotoXY(x,y);For fill:=0 to Delka do Write(' ');
   Str(Old,Vstup);
   GotoXY(x,y);Write(Old);
   TextCursor(True);
   Poz:=Length(Vstup);
   Repeat
     GotoXY(x+Poz,y);
     GetKey;
     If (Scan=82)and(Ascii=224)then Ascii:=0;
     If (Scan=75)and(Ascii=224)then
     begin If Poz>0 then Dec(Poz);Ascii:=0;end;
     If (Scan=77)and(Ascii=224)then
     begin If Poz<Length(Vstup) then Inc(Poz);Ascii:=0;end;
     If (Scan=83)and(Ascii=224)then
     begin Delete(Vstup,Poz+1,1);Ascii:=0;end;
     If ((Scan=71)or(Scan=73)or(Scan=72))and(Ascii=224)then
     begin Poz:=0;Ascii:=0;end;
     If ((Scan=79)or(Scan=81)or(Scan=80))and(Ascii=224)then
     begin Poz:=Length(Vstup);Ascii:=0;end;
     p:='';
     If ((Ascii>=48)and(Ascii<=57))or((Ascii>=65)and(Ascii<=70))or
        ((Ascii>=97)and(Ascii<=102)) then
     begin
       If Length(Vstup)<Delka then
       begin V:=Chr(Ascii);Poz:=Poz+1;end;
     end
     else V:=#0;
     If (Length(Vstup)>0)and(Scan=14)and(Poz>0) then
     begin Delete(Vstup,Poz,1);Dec(Poz);end;
     If (V<>#0)and(Length(Vstup)<Delka) then Insert(V,Vstup,Poz);
     For fill:=1 to (Delka-Length(Vstup)) do p:=p+' ';
     GotoXY(x,y);Write(Vstup+p);
   until (Scan=28)or(Scan=1)or(Scan=15);
   If (Scan=28)and(Vstup<>'') then
   begin
     W:=0;
     If Length(Vstup)>=1 then
     begin
       If UpCase(Vstup[ord(Vstup[0])])='1' then W:=W+1;
       If UpCase(Vstup[ord(Vstup[0])])='2' then W:=W+2;
       If UpCase(Vstup[ord(Vstup[0])])='3' then W:=W+3;
       If UpCase(Vstup[ord(Vstup[0])])='4' then W:=W+4;
       If UpCase(Vstup[ord(Vstup[0])])='5' then W:=W+5;
       If UpCase(Vstup[ord(Vstup[0])])='6' then W:=W+6;
       If UpCase(Vstup[ord(Vstup[0])])='7' then W:=W+7;
       If UpCase(Vstup[ord(Vstup[0])])='8' then W:=W+8;
       If UpCase(Vstup[ord(Vstup[0])])='9' then W:=W+9;
       If UpCase(Vstup[ord(Vstup[0])])='A' then W:=W+$A;
       If UpCase(Vstup[ord(Vstup[0])])='B' then W:=W+$B;
       If UpCase(Vstup[ord(Vstup[0])])='C' then W:=W+$C;
       If UpCase(Vstup[ord(Vstup[0])])='D' then W:=W+$D;
       If UpCase(Vstup[ord(Vstup[0])])='E' then W:=W+$E;
       If UpCase(Vstup[ord(Vstup[0])])='F' then W:=W+$F;
       If Length(Vstup)>=2 then
       begin
         If UpCase(Vstup[ord(Vstup[0])-1])='1' then W:=W+$10;
         If UpCase(Vstup[ord(Vstup[0])-1])='2' then W:=W+$20;
         If UpCase(Vstup[ord(Vstup[0])-1])='3' then W:=W+$30;
         If UpCase(Vstup[ord(Vstup[0])-1])='4' then W:=W+$40;
         If UpCase(Vstup[ord(Vstup[0])-1])='5' then W:=W+$50;
         If UpCase(Vstup[ord(Vstup[0])-1])='6' then W:=W+$60;
         If UpCase(Vstup[ord(Vstup[0])-1])='7' then W:=W+$70;
         If UpCase(Vstup[ord(Vstup[0])-1])='8' then W:=W+$80;
         If UpCase(Vstup[ord(Vstup[0])-1])='9' then W:=W+$90;
         If UpCase(Vstup[ord(Vstup[0])-1])='A' then W:=W+$A0;
         If UpCase(Vstup[ord(Vstup[0])-1])='B' then W:=W+$B0;
         If UpCase(Vstup[ord(Vstup[0])-1])='C' then W:=W+$C0;
         If UpCase(Vstup[ord(Vstup[0])-1])='D' then W:=W+$D0;
         If UpCase(Vstup[ord(Vstup[0])-1])='E' then W:=W+$E0;
         If UpCase(Vstup[ord(Vstup[0])-1])='F' then W:=W+$F0;
         If Length(Vstup)>=3 then
         begin
           If UpCase(Vstup[ord(Vstup[0])-2])='1' then W:=W+$100;
           If UpCase(Vstup[ord(Vstup[0])-2])='2' then W:=W+$200;
           If UpCase(Vstup[ord(Vstup[0])-2])='3' then W:=W+$300;
           If UpCase(Vstup[ord(Vstup[0])-2])='4' then W:=W+$400;
           If UpCase(Vstup[ord(Vstup[0])-2])='5' then W:=W+$500;
           If UpCase(Vstup[ord(Vstup[0])-2])='6' then W:=W+$600;
           If UpCase(Vstup[ord(Vstup[0])-2])='7' then W:=W+$700;
           If UpCase(Vstup[ord(Vstup[0])-2])='8' then W:=W+$800;
           If UpCase(Vstup[ord(Vstup[0])-2])='9' then W:=W+$900;
           If UpCase(Vstup[ord(Vstup[0])-2])='A' then W:=W+$A00;
           If UpCase(Vstup[ord(Vstup[0])-2])='B' then W:=W+$B00;
           If UpCase(Vstup[ord(Vstup[0])-2])='C' then W:=W+$C00;
           If UpCase(Vstup[ord(Vstup[0])-2])='D' then W:=W+$D00;
           If UpCase(Vstup[ord(Vstup[0])-2])='E' then W:=W+$E00;
           If UpCase(Vstup[ord(Vstup[0])-2])='F' then W:=W+$F00;
           If Length(Vstup)>=4 then
           begin
             If UpCase(Vstup[ord(Vstup[0])-3])='1' then W:=W+$1000;
             If UpCase(Vstup[ord(Vstup[0])-3])='2' then W:=W+$2000;
             If UpCase(Vstup[ord(Vstup[0])-3])='3' then W:=W+$3000;
             If UpCase(Vstup[ord(Vstup[0])-3])='4' then W:=W+$4000;
             If UpCase(Vstup[ord(Vstup[0])-3])='5' then W:=W+$5000;
             If UpCase(Vstup[ord(Vstup[0])-3])='6' then W:=W+$6000;
             If UpCase(Vstup[ord(Vstup[0])-3])='7' then W:=W+$7000;
             If UpCase(Vstup[ord(Vstup[0])-3])='8' then W:=W+$8000;
             If UpCase(Vstup[ord(Vstup[0])-3])='9' then W:=W+$9000;
             If UpCase(Vstup[ord(Vstup[0])-3])='A' then W:=W+$A000;
             If UpCase(Vstup[ord(Vstup[0])-3])='B' then W:=W+$B000;
             If UpCase(Vstup[ord(Vstup[0])-3])='C' then W:=W+$C000;
             If UpCase(Vstup[ord(Vstup[0])-3])='D' then W:=W+$D000;
             If UpCase(Vstup[ord(Vstup[0])-3])='E' then W:=W+$E000;
             If UpCase(Vstup[ord(Vstup[0])-3])='F' then W:=W+$F000;
           end;
         end;
       end;
     end;
     InputHexWordLine:=W;
   end;
   TextCursor(False);
end;



Function InputHexByteLine(x,y:Byte;Old:Byte):Byte;
Var
  p:String;
  Fill,Poz:Integer;
  V:Char;
  B:Byte;
begin
   Vstup:='';
   Poz:=0;
   GotoXY(x,y);For Fill:=0 to 2 do Write(' ');
   {Str(Old,Vstup);
   {GotoXY(x,y);Write(HexByte(Old));}
   TextCursor(True);
   Poz:=0;
   Repeat
     GotoXY(x+Poz,y);
     GetKey;
     If (Scan=82)and(Ascii=224)then Ascii:=0;
     If (Scan=75)and(Ascii=224)then
     begin If Poz>0 then Dec(Poz);Ascii:=0;end;
     If (Scan=77)and(Ascii=224)then
     begin If Poz<Length(Vstup) then Inc(Poz);Ascii:=0;end;
     If (Scan=83)and(Ascii=224)then
     begin Delete(Vstup,Poz+1,1);Ascii:=0;end;
     If ((Scan=71)or(Scan=73)or(Scan=72))and(Ascii=224)then
     begin Poz:=0;Ascii:=0;end;
     If ((Scan=79)or(Scan=81)or(Scan=80))and(Ascii=224)then
     begin Poz:=Length(Vstup);Ascii:=0;end;
     p:='';
     If ((Ascii>=48)and(Ascii<=57))or((Ascii>=65)and(Ascii<=70))or
        ((Ascii>=97)and(Ascii<=102)) then
     begin
       If Length(Vstup)<2 then
       begin V:=Chr(Ascii);Poz:=Poz+1;end;
     end
     else V:=#0;
     If (Length(Vstup)>0)and(Scan=14)and(Poz>0) then
     begin Delete(Vstup,Poz,1);Dec(Poz);end;
     If (V<>#0)and(Length(Vstup)<2) then Insert(V,Vstup,Poz);
     For Fill:=1 to (2-Length(Vstup)) do p:=p+' ';
     GotoXY(X,Y);Write(Vstup+p);
   until (Scan=28)or(Scan=1)or(Scan=15);
   If (Scan=28)and(Vstup<>'') then
   begin
     B:=0;
     If UpCase(Vstup[ord(Vstup[0])-1])='1' then B:=B+$10;
     If UpCase(Vstup[ord(Vstup[0])-1])='2' then B:=B+$20;
     If UpCase(Vstup[ord(Vstup[0])-1])='3' then B:=B+$30;
     If UpCase(Vstup[ord(Vstup[0])-1])='4' then B:=B+$40;
     If UpCase(Vstup[ord(Vstup[0])-1])='5' then B:=B+$50;
     If UpCase(Vstup[ord(Vstup[0])-1])='6' then B:=B+$60;
     If UpCase(Vstup[ord(Vstup[0])-1])='7' then B:=B+$70;
     If UpCase(Vstup[ord(Vstup[0])-1])='8' then B:=B+$80;
     If UpCase(Vstup[ord(Vstup[0])-1])='9' then B:=B+$90;
     If UpCase(Vstup[ord(Vstup[0])-1])='A' then B:=B+$A0;
     If UpCase(Vstup[ord(Vstup[0])-1])='B' then B:=B+$B0;
     If UpCase(Vstup[ord(Vstup[0])-1])='C' then B:=B+$C0;
     If UpCase(Vstup[ord(Vstup[0])-1])='D' then B:=B+$D0;
     If UpCase(Vstup[ord(Vstup[0])-1])='E' then B:=B+$E0;
     If UpCase(Vstup[ord(Vstup[0])-1])='F' then B:=B+$F0;


     If UpCase(Vstup[ord(Vstup[0])])='1' then B:=B+1;
     If UpCase(Vstup[ord(Vstup[0])])='2' then B:=B+2;
     If UpCase(Vstup[ord(Vstup[0])])='3' then B:=B+3;
     If UpCase(Vstup[ord(Vstup[0])])='4' then B:=B+4;
     If UpCase(Vstup[ord(Vstup[0])])='5' then B:=B+5;
     If UpCase(Vstup[ord(Vstup[0])])='6' then B:=B+6;
     If UpCase(Vstup[ord(Vstup[0])])='7' then B:=B+7;
     If UpCase(Vstup[ord(Vstup[0])])='8' then B:=B+8;
     If UpCase(Vstup[ord(Vstup[0])])='9' then B:=B+9;
     If UpCase(Vstup[ord(Vstup[0])])='A' then B:=B+$A;
     If UpCase(Vstup[ord(Vstup[0])])='B' then B:=B+$B;
     If UpCase(Vstup[ord(Vstup[0])])='C' then B:=B+$C;
     If UpCase(Vstup[ord(Vstup[0])])='D' then B:=B+$D;
     If UpCase(Vstup[ord(Vstup[0])])='E' then B:=B+$E;
     If UpCase(Vstup[ord(Vstup[0])])='F' then B:=B+$F;

     InputHexByteLine:=B;
   end
   else InputHexByteLine:=Old;
   TextCursor(False);
end;


Function IntToStr(I:Longint):String;
Var
  S:String[11];
begin
  Str(I,S);
  IntToStr:=S;
end;


Begin
end.