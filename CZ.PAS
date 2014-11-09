Unit CZ;
{Instaluje do EXE souboru ‡e¨tinu. Program pot‚ pou‘¡v  vlastn¡ ‡esk‚ znaky
a ‡eskou klavesnici}
Interface
Uses DOS,Crt;

Type
  THeader=Record
            TEST:Array[1..4] of Char;
            EditorOEM:String[11];
            Version:Word;
            NameOfTab:String[21];
            Year:Word;
            Month:Byte;
            Day:Byte;
            Hour:Byte;
            Minute:Byte;
            Sec:Byte;
            H:Word;
            V:Word;
            NumberOfChars:Byte;
            Info:String[78];
          end;

Var
  CestinaOK:Boolean;
  ASCII,SCAN:Byte;

Procedure SetASCIITab(C:Byte);
Procedure LoadCZPage(PageNum:Byte);
Function ReadKey:Char;
Procedure GetKey;

Implementation
Var
  Head:THeader;
  ASCIITAB:Array[0..255,0..2] of Byte;

Function UpString(S:String):String;
Var
  I:Integer;
begin
  UpString:=S;
  For I:=1 to Length(S) do UpString[I]:=UpCase(S[I]);
end;


Procedure SetASCIITab(C:Byte);
begin
  if(CestinaOK) then
  asm
    MOV AH,11h
    MOV AL,3
    MOV BL,C
    INT 10h
  end;
end;


Procedure DefineAsciiTab;
Var
  A:Byte;
begin
  For A:=0 to 255 do ASCIITAB[A,0]:=A;
  For A:=0 to 255 do ASCIITAB[A,1]:=A;
  For A:=0 to 255 do ASCIITAB[A,2]:=A;

  ASCIITAB[33,0]:=ord('1');
  ASCIITAB[64,0]:=ord('2');
  ASCIITAB[35,0]:=ord('3');
  ASCIITAB[36,0]:=ord('4');
  ASCIITAB[37,0]:=ord('5');
  ASCIITAB[94,0]:=ord('6');
  ASCIITAB[38,0]:=ord('7');
  ASCIITAB[42,0]:=ord('8');
  ASCIITAB[40,0]:=ord('9');
  ASCIITAB[41,0]:=ord('0');
  ASCIITAB[48,0]:=130;     {0}
  ASCIITAB[49,0]:=ord('+');{1}
  ASCIITAB[50,0]:=136;     {2}
  ASCIITAB[51,0]:=168;     {3}
  ASCIITAB[52,0]:=135;     {4}
  ASCIITAB[53,0]:=169;     {5}
  ASCIITAB[54,0]:=145;     {6}
  ASCIITAB[55,0]:=152;     {7}
  ASCIITAB[56,0]:=160;     {8}
  ASCIITAB[57,0]:=161;     {9}
  {ASCIITAB[95,0]:=ord('%');
  ASCIITAB[45,0]:=ord('=');
  ASCIITAB[91,0]:=163;
  ASCIITAB[123,0]:=ord('/');
  ASCIITAB[93,0]:=ord(')');
  ASCIITAB[125,0]:=ord('(');
  ASCIITAB[59,0]:=150;
  ASCIITAB[58,0]:=ord('"');
  ASCIITAB[96,0]:=ord('"');
  ASCIITAB[126,0]:=ord(';');
  ASCIITAB[34,0]:=ord('!');
  ASCIITAB[39,0]:=173;
  ASCIITAB[60,0]:=ord('?');
  ASCIITAB[62,0]:=ord(':');
  ASCIITAB[47,0]:=ord('-');
  ASCIITAB[63,0]:=ord('_');}

  ASCIITAB[97,1]:=132; {a} {^}
  ASCIITAB[99,1]:=135; {c}
  ASCIITAB[100,1]:=131;{d}
  ASCIITAB[101,1]:=136;{e}
  ASCIITAB[108,1]:=140;{l}
  ASCIITAB[110,1]:=164;{n}
  ASCIITAB[111,1]:=147;{o}
  ASCIITAB[114,1]:=169;{r}
  ASCIITAB[115,1]:=168;{s}
  ASCIITAB[116,1]:=159;{t}
  ASCIITAB[117,1]:=150;{u}
  ASCIITAB[122,1]:=145;{z}

  ASCIITAB[65,1]:=142;{A} {^}
  ASCIITAB[67,1]:=128;{C}
  ASCIITAB[68,1]:=133;{D}
  ASCIITAB[69,1]:=137;{E}
  ASCIITAB[76,1]:=156;{L}
  ASCIITAB[78,1]:=165;{N}
  ASCIITAB[79,1]:=167;{O}
  ASCIITAB[82,1]:=158;{R}
  ASCIITAB[83,1]:=155;{S}
  ASCIITAB[84,1]:=134;{T}
  ASCIITAB[85,1]:=166;{U}
  ASCIITAB[90,1]:=146;{Z}

  ASCIITAB[97,2]:=160; {a}{'}
  ASCIITAB[101,2]:=130;{e}
  ASCIITAB[105,2]:=161;{i}
  ASCIITAB[108,2]:=141;{l}
  ASCIITAB[111,2]:=162;{o}
  ASCIITAB[114,2]:=170;{r}
  ASCIITAB[115,2]:=172;{s}
  ASCIITAB[117,2]:=163;{u}
  ASCIITAB[121,2]:=152;{y}

  ASCIITAB[65,2]:=143;{A} {'}
  ASCIITAB[69,2]:=144;{E}
  ASCIITAB[73,2]:=139;{I}
  ASCIITAB[76,2]:=138;{L}
  ASCIITAB[79,2]:=149;{O}
  ASCIITAB[82,2]:=171;{R}
  ASCIITAB[83,2]:=173;{S}
  ASCIITAB[85,2]:=151;{U}
  ASCIITAB[89,2]:=157;{Y}
end;




Function ReadKey:Char;
begin
  Asm
    MOV AH,10h
    INT 16h
    MOV ASCII,AL
    MOV SCAN,AH
  end;
  If CestinaOK then
  begin
    If (Scan=13)and(Ascii=61)and(Mem[0:$417] and 16=16)then
    begin
      asm
      MOV AH,10h
      INT 16h
      MOV ASCII,AL
      MOV SCAN,AH
      end;
      If (Mem[0:$417]and 16=16)then Ascii:=ASCIITAB[ASCII,2];
    end;
    If (Scan=13)and(Ascii=43)and(Mem[0:$417] and 16=16) then
    begin
      asm
      MOV AH,10h
      INT 16h
      MOV ASCII,AL
      MOV SCAN,AH
      end;
      If (Mem[0:$417]and 16=16) then Ascii:=ASCIITAB[ASCII,1];
    end;
    If (Scan<>55)and((Scan<71)or(Scan>83)) then
    If Mem[0:$417]and 16=16 then Ascii:=ASCIITAB[ASCII,0];
  end;
  ReadKey:=chr(Ascii);
end;




Procedure GetKey;
begin
  If CestinaOK then ReadKey
  else
  begin
    asm
    MOV AH,10h
    INT 16h
    MOV ASCII,AL
    MOV SCAN,AH
    end;
  end;
end;


Procedure LoadCZPage(PageNum:Byte);
  Procedure GotoXY(X,Y:Byte);Assembler;
  Asm
    MOV AH,2
    MOV BH,0
    MOV DL,X
    MOV DH,Y
    INT 10h
  end;

Var
  FontPtr:Pointer;
  R:Registers;
  FSize:LongInt;
  Bytes:Integer;
  Attrib,W:Word;
  F,Source:File;
  T:Array[0..3] of Char;
  S:String[2];
  P: PathStr;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
  B:Byte;
  Buffer:Array[0..4240] of Char;
  X,Y:Byte;

begin
  TextColor(7);TextBackground(0);
  Asm
  MOV AH,5
  MOV AL,0
  INT 10h
  end;
  CestinaOK:=False;
  DefineAsciiTab;
  Assign(F,ParamStr(0));
  GetFAttr(F,Attrib);
  SetFAttr(F,0);
  {$I-}Reset(F,1);{$I+}
  If IOResult<>0 then
  begin
    Writeln('Soubor ',ParamStr(0),' neexistuje !');
    Halt(1);
  end;
  FSize:=FileSize(F);
  Seek(F,FSize-2);
  BlockRead(F,W,2);{-OFFSET}

  If W=0 then W:=4098;
  Seek(F,FSize-(W-4096)-2);{141}
  BlockRead(F,T,4);
  If (T[0]+T[1]+T[2]+T[3]<>'FONT')and(T[0]+T[1]+T[2]<>'OFF')then
  begin
    ClrScr;
    For B:=0 to 25 do Write(#10);
    GotoXY(1,24);Write('Copyright (c) 1998  Tomas Hujer');
    GotoXY(1,1);
    Writeln(#10#13'Install CZ fonts: ');
    Writeln('-------------------');
    P:=ParamStr(0);
    FSplit(P,D,N,E);
    Writeln(#10#13'Soubor ',N+E,' v sobe nema cestinu. Tato rutina ji muze do souboru pridat.');
    P:=FSearch('CZ.FL','.;..;\;C:\SKLAD;'+GetEnv('PATH'));
    If P='' then
    begin
      Writeln(#10'Soubor s cestinou CZ.FL nenalezen.'#10);
      Writeln('Tento soubor je nutny pro spravnou funkci tohoto programu. Pokud soubor'#10#13,
      'nemate, muze zadat "-" a program jiz po vas nebude soubor dale pozadovat,'#10#13,
      'ovsem muze se stat, ze misto nekterych znaku bude zobrazen nesmyslny balast.'#10#13,
      'Nektere rezidentni programy pro podporu ceskeho prostredi by mohly tuto rutinu'#10#13,
      'az na nektere znaky nahradit (napr. KEV).'#10#13,
      'Instalaci muzete prozatim obejit kdyz nic nenapisete a stisknete ENTER'#10#13,
      'pokud cestinu nechcete, napiste "-" a nebudete jiz dotazovani.');
      Repeat
        Write(#10'Zadej umisteni souboru (napr. C:\FONTY\CZ.FL):');
        Readln(P);
        Asm
          MOV AH,03
          MOV BH,0
          INT 10h
          MOV Y,DH
          MOV X,DL
        end;
        GotoXY(1,24);Write('                               ');GotoXY(X,Y);
        If P='' then
        begin
          For B:=0 to 25 do Write(#10);Writeln;
          SetFAttr(F,Attrib);
          Exit;
        end;
        If UpString(P)=UpString(N+E) then
        begin
          Writeln('Soubor ',N+E,' neobsahuje cestinu !!!');P:='';Continue;
        end;
        If P='-' then
        begin
          Seek(F,FileSize(F));
          BUFFER[0]:='O';BUFFER[1]:='F';BUFFER[2]:='F';
          {$I-}
          BlockWrite(F,Buffer,141);
          W:=FileSize(Source)-sizeof(BUFFER);
          Writeln('Cestina OFF, offset: ',W,'.'); Halt(1);
          BlockWrite(F,W,2);{-OFFSET}
          {$I+}

          If IOResult=0 then CestinaOK:=False;
          {$I-}Close(F);{$I+}
          If IOResult<>0 then Writeln('Chyba pri zavirani souboru ',ParamStr(0),' !!!');
          SetFAttr(F,Attrib);
          Exit;
        end;
        Assign(Source,P);
        {$I-}
        Reset(Source,1);
        {$I+}
        B:=IOResult;
        If B=0 then
          If FileSize(Source)<>4237 then
          begin
            Writeln('Soubor je poskozeny nebo nema spravny format !!!');
            P:=#0;B:=255;
            Continue;
          end;
        If B<>0 then Writeln('Soubor nenalezen.');
      until B=0;
      {$I-}
      BlockRead(Source,Buffer,FileSize(Source));
      {$I+}
      If IOResult<>0 then
      begin
        Writeln('Chyba pri cteni.');
        Writeln('Ignorovat/Konec (I/) ? ');
        SetFAttr(F,Attrib);
        If UpCase(ReadKey)<>'I' then Halt(1);
      end;
      If Buffer[4096+0]+Buffer[4096+1]+Buffer[4096+2]+Buffer[4096+3]<>'FONT' then
      begin
        FSplit(P,D,N,E);
        Writeln(#10#13'Nekompaktibilni tabulka znaku v souboru ',N+E);
        Writeln('Ignorovat/Konec (I/) ? ');
        SetFAttr(F,Attrib);
        If UpCase(ReadKey)<>'I' then Halt(1);
      end;
      Seek(F,FileSize(F));
      Writeln;
      Writeln('Chcete cestinu zkopirovat do souboru (A/) ?');
      Asm
      MOV AH,10h
      INT 16h
      MOV ASCII,AL
      MOV SCAN,AH
      end;
      If UpCase(chr(ASCII))='A' then
      begin
        {$I-}
        BlockWrite(F,Buffer,FileSize(Source));
        W:=FileSize(Source);
        BlockWrite(F,W,2);{-OFFSET}
        {$I+}

        If IOResult=0 then CestinaOK:=True;
      end;
    end
    else
    begin
      P:=FExpand(P);
      Writeln(#10#13'Nalezen soubor s cestinou:'#10#13,P);
      Writeln(#10#13'Po pridani cestiny do souboru se vzdy pri spusteni tohoto programu'#10#13,
      'automaticky nainstaluje nova sada znaku s ceskou diakritikou (carky, hacky).'#10#13,
      'Tato sada se zkopiruje na konec spustitelneho souboru, takze dale se jiz'#10#13,
      'bude nacitat odtud. Proto program uz nebude potrebovat zadne externi soubory'#10#13,
      's cestinou.'#10#13,
      'Tato rutina take vzdy zapne ceskou klavesnici, takze pokud pouzivate nejake ty'#10#13,
      'rezidentni programy pro podporu CZ klavesnice muzete je klidne vypnout program'#10#13,
      'si vystaci sam. Mezi US a CZ klavesnici se prepina klavesou ScrollLock (ON=CZ).'#13);
      Writeln(#10'Chcete cestinu zkopirovat do souboru (A/) ?');
      Asm
      MOV AH,10h
      INT 16h
      MOV ASCII,AL
      MOV SCAN,AH
      end;
      If UpCase(chr(ASCII))='A' then
      begin
        Assign(Source,P);
        Reset(Source,1);
        {$I-}BlockRead(Source,Buffer,{FileSize(Source)}4096+141,Bytes);{$I+}
        If IOResult<>0 then
        begin
          If Bytes=0 then
          begin
            Writeln('Soubor s tabulkou je prazdny !');
            Halt(1);
          end;
        end;
        If Buffer[4096+0]+Buffer[4096+1]+Buffer[4096+2]+Buffer[4096+3]<>'FONT' then
        begin
          FSplit(P,D,N,E);
          Writeln(#10#13'Nekompaktibilni tabulka znaku v souboru ',N+E);
          Writeln('Ignorovat/Konec (I/) ? ');
          If UpCase(ReadKey)<>'I' then Halt(1);
        end;
        Seek(F,FileSize(F));
        {$I-}
        BlockWrite(F,Buffer,FileSize(Source));
        W:=FileSize(Source);
        BlockWrite(F,W,2);{-OFFSET}
        {$I+}

        If IOResult=0 then CestinaOK:=True;
      end;
    end;
    GotoXY(1,24);For B:=0 to 25 do Write(#10);GotoXY(1,2);
  end;
  If (CestinaOK)or(T[0]+T[1]+T[2]+T[3]='FONT')then
  begin
    FSize:=4096;
    If FSize>MaxAvail then
    begin
      Writeln('Nedostatek pameti pro spusteni.');Halt(1);
    end
    else
    begin
      GetMem(FontPtr,4096);
      {$I-}
      Seek(F,(FileSize(F)-2));
      BlockRead(F,W,2);{-OFFSET}

      Seek(F,FileSize(F)-W-2);
      BlockRead(F,FontPtr^,4096);
      BlockRead(F,Head,141,Bytes);
      {FSize:=FileSize(F);}
      If Head.TEST<>'FONT' then
      {If (FSize<>4237)and(FSize<>4096) then}
      begin
        Writeln('Nekompaktibilni tabulka znaku v souboru '+ParamStr(0)+' !');
        Writeln('Ignorovat/Konec (I/) ? ');
        If UpCase(ReadKey)<>'I' then Halt(1);
      end;
      {$I+}
      If IOResult=0 then CestinaOK:=True else CestinaOK:=False;
      R.AH:=$11;
      R.AL:=$10;
      R.BL:=(PageNum and $0F);
      R.BH:=16;
      R.CX:=4096 div 16;
      R.DX:=0;
      R.ES:=SEG(FontPtr^);
      R.BP:=OFS(FontPtr^);
      INTR($10,R);
      FreeMem(FontPtr,4096);
    end;
  end;
  {$I-}
  Close(F);
  SetFAttr(F,Attrib);
  {$I+}
  If IOResult<>0 then
  begin
    Writeln('Chyba pri zavirani souboru !');
  end;
end;

end.