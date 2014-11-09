Program FontEdit;
Uses Crt,Dos,THApp,THOpen,THString,THMouse,CZ,THInfo,THGS;
Const
  OEM='Font editor';
  Ver='5.6';

  {
  00..03  4   Indentifikace souboru 'FONT'
  04..14  11  OEM editoru
  15..16  2   Verze editoru '01.02'
  17..37  21  Nazev znakove sady 'Cestina KeybCZ01'
  38..44  7   Date+Time posledni upravy znakove sady   '06 10 1998 12 00 00'
  45..46  2   Horizontalni rozliseni znaku
  47..48  2   Vertikalni rozliseni znaku
  49..49  1   Pocet znaku v znakove sade '256'
  50..127 78  OEM Tvurce 'Tomas Hujer Lucni 1292 Smrzovka 468 51 Tel.0428 372 129'
  }


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
  Head:THeader;
  FileInfo:Array[0..140] of Byte absolute Head;
  X,Y,xf,yf:Word;
  I,Code:Integer;
  B:Byte;
  Font:Array[1..128] of Byte;
  FontOK:Array[0..15] of Byte;
  V:Char;
  CisloFontu:Byte;

  L:LongInt;

  Reg:Registers;
  FontPtr:Pointer;
  FSize:Word;
  Adr,Soubor:String;
  D: DirStr;
  N: NameStr;
  E: ExtStr;

  OldInt:Pointer;



Function ScrollLock:Boolean;
Var
  Lock:Byte;
begin
  Lock:=Mem[0:$417];
  If Lock and 16=16 then ScrollLock:=True else ScrollLock:=False;
end;



Procedure RefreshEditor;
begin
  MouseCursor(False);
  TextColor(8);TextBackground(1);
  I:=0;
  For yf:=0 to 15 do
  For xf:=0 to 7 do
  begin
    I:=I+1;
    begin
      If Font[I]=1 then TextColor(10) else TextColor(8);
      GotoXY(Xf*3+29,Yf+4);Write('±±±');
    end;
  end;
  MouseCursor(True);
  If Head.NameOfTab='' then Head.NameOfTab:='NoName'
  else
  begin
    If ord(Head.NameOfTab[0])>80 then Head.NameOfTab[0]:=#8;
    while Pos(#7,Head.NameOfTab)>0 do
    Head.NameOfTab[Pos(#7,Head.NameOfTab)]:=' ';
  end;
  TextBackground(0);TextColor(10);
  GotoXY(29,3);Write('                        ');
  Center(2,Head.NameOfTab);
end;



Procedure Refresh;
begin
  {ClrScr;
  InitDownMenu('',1);
  TextBackground(1);TextColor(15);
  TextCursor(False);
  TextBackground(1);Window(1,2,80,24);ClrScr;
  Window(1,1,80,25);}

  MouseCursor(False);
  InitStandardScreen('±',1,8,2);

  TextBackground(7);TextColor(0);
  Center(0,OEM);
  InitDownMenu('~?,F1~ Help  ~F2~ Save  ~F3~ Open  ~F5~ Imp  ~F6~ Exp  '+
               '~F9~ Init  ~Ctrl+I~ ROMImp  ~F10~ About',25);
  TextBackground(1);
  SetMouseSpeed(6,6);
  SetMouseRate(5,8,635,187);
  SetMousePos(1,1);
  RefreshEditor;
  TextBackground(0);TextColor(10);
  GotoXY(29,3);Write('                        ');
  Center(2,Head.NameOfTab);

  TextColor(0);TextBackground(7);
  Frame(60,19,78,22,136);
  GotoXY(62,20);Write('Mouse: ');
  GotoXY(62,21);Write('ASCII: ');

  MouseCursor(True);
  Repeat until Port[$60]>128;
  Scan:=0;TextColor(15);
  SetAsciiTab(10);
end;



Procedure ClearFont;
begin
  MouseCursor(False);
  WriteDownMessage('Clearing...');
  For I:=1 to 128 do
  begin
    Font[I]:=0;Sound(I*100+5000);Delay(1);
  end;
  NoSound;
  TextColor(8);
  RefreshEditor;
  For I:=0 to 15 do
  begin
    FontOK[I]:=0;
    Sound(15000-I*1000+5000);
    Delay(5);
  end;
  NoSound;
  Scan:=0;
  ClearDownMessage;
  MouseCursor(True);
end;




Procedure ReadyToSave;
begin
  I:=0;
  For y:=0 to 15 do
  begin
    B:=0;
    For x:=0 to 7 do
    begin
      I:=I+1;
      If (Font[I]=1)and(x=0) then B:=B+128;
      If (Font[I]=1)and(x=1) then B:=B+64;
      If (Font[I]=1)and(x=2) then B:=B+32;
      If (Font[I]=1)and(x=3) then B:=B+16;
      If (Font[I]=1)and(x=4) then B:=B+8;
      If (Font[I]=1)and(x=5) then B:=B+4;
      If (Font[I]=1)and(x=6) then B:=B+2;
      If (Font[I]=1)and(x=7) then B:=B+1;
    end;
    FontOK[y]:=B;
  end;
end;



Procedure LoadReady;
begin
  I:=0;
  For y:=0 to 15 do
  begin
    Inc(I);If FontOK[y]and 128=128 then Font[I]:=1;
    Inc(I);If FontOK[y]and 64=64 then Font[I]:=1;
    Inc(I);If FontOK[y]and 32=32 then Font[I]:=1;
    Inc(I);If FontOK[y]and 16=16 then Font[I]:=1;
    Inc(I);If FontOK[y]and 8=8 then Font[I]:=1;
    Inc(I);If FontOK[y]and 4=4 then Font[I]:=1;
    Inc(I);If FontOK[y]and 2=2 then Font[I]:=1;
    Inc(I);If FontOK[y]and 1=1 then Font[I]:=1;
  end;
end;



Procedure KeyHelp;
begin
  MouseCursor(False);
  GetScreen;
  TextColor(15);TextBackground(7);
  Frame(12,4,70,21,129+64);
  TextColor(15);
  Center(04,' HELP ');
  TextColor(4);GotoXY(15,06);Write('F1');
  TextColor(0);Write(' - Hlavn¡ n povˆda ');
  TextColor(4);GotoXY(15,07);Write('F2');
  TextColor(0);Write(' - Ulo‘it aktu ln¡ znak do souboru (Samostatnˆ)');
  TextColor(4);GotoXY(15,08);Write('F3');
  TextColor(0);Write(' - Na‡¡st samostatnˆ 1 znak ze souboru');
  TextColor(4);GotoXY(15,09);Write('F5');
  TextColor(0);Write(' - Importovat znak z tabulky znak– v souboru');
  TextColor(4);GotoXY(15,10);Write('F6');
  TextColor(0);Write(' - Exportovat znak do tabulky znak– v souboru');
  TextColor(4);GotoXY(15,11);Write('F8');
  TextColor(0);Write(' - Nastaven¡ implicitn¡ tabulky znak–');
  TextColor(4);GotoXY(15,12);Write('F9');
  TextColor(0);Write(' - Inicializace tabulky znak– ze souboru');
  TextColor(4);GotoXY(15,14);Write('Ctrl+I');
  TextColor(0);Write(' - Importovat znak z tabulky znaku v ROM');
  TextColor(4);GotoXY(15,15);Write('Ctrl+C');
  TextColor(0);Write(' - Vymazat kreslic¡ pole (Clear)');
  TextColor(4);GotoXY(15,16);Write('Ctrl+F');
  TextColor(0);Write(' - Nastavit ‡¡slo znaku v ASCII tabulce');
  TextColor(4);GotoXY(15,17);Write('Ctrl+R');
  TextColor(0);Write(' - Znovuvykreslen¡ obrazovky');
  TextColor(4);GotoXY(15,18);Write('Ctrl+N');
  TextColor(0);Write(' - Zkop¡rovat tabulku znaku z ROM do souboru');
  TextColor(4);GotoXY(15,19);Write('Alt+F');
  TextColor(0);Write(' - Informace o souboru s tab. znaku');
  TextColor(4);GotoXY(15,20);Write('Alt+S');
  TextColor(0);Write(' - Nastaven¡ informac¡ o souboru s tab.');
  TextColor(4);GotoXY(15,21);Write('SCRLCK');
  TextColor(0);Write(' - ON=Bez kontroly rozsahu. POZOR na p©ete‡en¡');
  GetKey;
  Repeat until Port[$60]>128;
  SetScreen;
  RefreshEditor;
  MouseCursor(True);
  Scan:=0;
end;



Procedure Help;
Type
  TBuffer=Array[0..4000] of Byte;
Var
  Buf:^TBuffer;
  F:File;
  Segment:Word;
begin
  MouseCursor(False);
  GetScreen;
  Repeat until Port[$60]<>59;
  Assign(F,Adr+'FONTEDIT.HLP');
  {$I-}Reset(F,1);{$I+}ErrorMessage;
  If IORes=0 then
  begin
    New(Buf);
    asm
    MOV AH,0Fh
    INT 10h
    MOV B,AL
    end;
    If B<=3 then Segment:=$B800;
    If B=7 then Segment:=$B000;
    {$I-}BlockRead(F,Buf^,4000);{$I+}ErrorMessage;
    {$I-}Close(F);{$I+}ErrorMessage;

    For y:=24 downto 0 do
    For x:=79 downto 0 do
    begin
      I:=(x*2)+(y*2*80);
      Mem[Segment:I]:=Buf^[I];
      Mem[Segment:I+1]:=Buf^[I+1];
    end;

    GetKey;
    TextCursor(False);
    Window(1,1,80,25);
    TextBackground(7);TextColor(0);
    Refresh;
    Dispose(Buf);
  end;
  Repeat until Port[$60]>128;
  SetScreen;
  KeyHelp;
  RefreshEditor;
end;



Procedure NastavFileInfo;
begin
  MouseCursor(False);
  GetScreen;
  Head.NameOfTab:=TextInput(21,'N zev znakov‚ sady',Head.NameOfTab);
  SetScreen;
  If Scan=1 then Exit;
  If Head.NameOfTab='' then Head.NameOfTab:='NoName';
  MouseCursor(True);
  TextBackground(0);TextColor(10);
  GotoXY(29,3);Write('                        ');
  Center(2,Head.NameOfTab);
  TextInput(71,'Ostatn¡ informace:',Head.Info);
  SetScreen;
  If Scan=28 then Head.Info:=Vstup;

  RefreshEditor;
  Repeat until Port[$60]>128;
  Scan:=0;
end;



Procedure VyplnFileInfo;
Var
  I:Byte;
  W,H,M,S,Sc,Rok,Mes,Den,Dt:Word;

begin
  Head.TEST:='FONT';{Signatrura}

  Head.EditorOEM:='FONTEDIT     ';

  Head.Version:=$0560;

  If Head.NameOfTab='' then Head.NameOfTab:='NoName'
  else
  begin
    If ord(Head.NameOfTab[0])>80 then Head.NameOfTab[0]:=#8;
    while Pos(#7,Head.NameOfTab)>0 do
    Head.NameOfTab[Pos(#7,Head.NameOfTab)]:=' ';
  end;


  {asm
    MOV AH,2Ch
    INT 21h
    MOV H,CH
    MOV M,CL
    MOV SC,DH
    MOV AH,2Ah
    INT 21h
    MOV ROK,CX
    MOV MES,DH
    MOV DEN,DL
  end;}
  GetDate(Rok,Mes,Den,Dt);
  GetTime(H,M,Sc,S);


  Head.Hour:=H;
  Head.Day:=Den;
  Head.Month:=Mes;
  Head.Year:=Rok;
  Head.Minute:=M;
  Head.Sec:=Sc;
  Head.H:=8;
  Head.V:=16;
  Head.NumberOfChars:=255;
end;



Procedure ZobrazFileInfo;
Var
  W:Word;
begin
  {
  00..03  4   Indentifikace souboru 'FONT'
  04..14  11  OEM editoru
  15..16  2   Verze editoru '01.02'
  17..37  21  Nazev znakove sady 'Cestina KeybCZ01'
  38..44  7   Date+Time posledni upravy znakove sady   '06 10 1998 12 00 00'
  45..46  2   Horizontalni rozliseni znaku
  47..48  2   Vertikalni rozliseni znaku
  49..49  1   Pocet znaku v znakove sade '256'
  50..127 78  OEM Tvurce 'Tomas Hujer Lucni 1292 Smrzovka 468 51 Tel.0428 372 129'
  }
  MouseCursor(False);
  GetScreen;
  TextBackground(1);
  ClrScr;
  InitDownMenu('',1);
  InitDownMenu('',25);
  Center(0,'File info:');
  TextColor(7);TextBackground(1);
  GotoXY(2,6);Write('Editor:');
  GotoXY(2,7);Write('Verze editoru:');
  GotoXY(2,8);Write('N zev znakov‚ sady:');
  GotoXY(2,9);Write('Datum ‡as posledn¡ £pravy:');
  GotoXY(2,10);Write('Horizontaln¡ rozli¨en¡ znaku:');
  GotoXY(2,11);Write('Vertikaln¡ rozli¨en¡ znaku:');
  GotoXY(2,12);Write('Po‡et znaku v znakov‚ sadˆ:');
  GotoXY(2,13);Write('Libovoln‚ informace:');
  TextColor(10);

  GotoXY(35,6);Write(Head.EditorOEM);
  GotoXY(35,7);Write(Hi(Head.Version),'.',HexByte(Lo(Head.Version)));
  GotoXY(35,8);Write(Head.NameOfTab);
  GotoXY(35,9);With Head do Write(LeadingZero(Hour),':',LeadingZero(Minute),
                                  ':',LeadingZero(Sec),'  ',Day,'.',Month,
                                  '. ',Year);
  GotoXY(35,10);Write(Head.H);
  GotoXY(35,11);Write(Head.V);
  GotoXY(35,12);Write(Head.NumberOfChars);
  GotoXY(1,15);Write(Head.Info);
  Repeat
    GetKey;
  until (Scan=28)or(Scan=1);
  SetScreen;
  RefreshEditor;
end;




Procedure SaveToFile;
Var
  F:File of Byte;
  Soubor:String;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  MouseCursor(False);
  GetScreen;
  {TextColor(0);TextBackground(7);
  SmallHelp(1,5,18,15,'Ulo‘¡ samostatnˆ'+
                      'jeden - aktualn¡'+
                      'znak z tabulky  '+
                      'do souboru.');}
  Repeat
    Scan:=0;Ascii:=0;
    Soubor:=ChooseFile('*.FNT');
    Soubor:=FExpand(Soubor);
    FSplit(Soubor,D,N,E);
    If E='' then E:='.FNT';
    Soubor:=FExpand(D+N+E);

    If Scan=28 then
    begin
      ReadyToSave;
      Assign(F,Soubor);
      {$I-}Reset(F);{$I+}
      If IOResult<>0 then
      begin
        {$I-}Rewrite(F);{$I+}ErrorMessage;
      end
      else
      begin
        OkMessage('Soubor ji‘ existuje, p©epsat ?');
        SetScreen;
        If (Scan=28)or(UpCase(chr(ASCII))='A') then
        begin
          {$I-}Rewrite(F);{$I+}ErrorMessage;
        end
        else
        begin
          {$I-}Close(F);{$I+}ErrorMessage;
          Exit;
          SetScreen;
        end;
      end;
      {$I-}
      Write(F,CisloFontu);
      For B:=0 to 15 do Write(F,FontOK[B]);
      {$I+}ErrorMessage;
      {$I-}Close(F);{$I+}ErrorMessage;
    end;
    Repeat until Port[$60]>128;
  until (Scan=255)or(Scan=1);
  Repeat until Port[$60]>128;
  Scan:=0;
  SetScreen;
  RefreshEditor;
end;



Procedure LoadFromFile;
Var
  F:File of Byte;
  Soubor:String;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  MouseCursor(False);
  GetScreen;
  {TextColor(0);TextBackground(7);
  SmallHelp(0,2,19,7,'Na‡te jeden znak'+
                      'ulo‘en˜ samo-   '+
                      'statnˆ v souboru');}

  Soubor:='';
  Repeat
    Scan:=0;Ascii:=0;
    TextColor(0);TextBackground(7);
    Soubor:=ChooseFile('*.FNT');
    Soubor:=FExpand(Soubor);
    FSplit(Soubor,D,N,E);
    If E='' then E:='.FNT';
    Soubor:=FExpand(D+N+E);
    If Scan=28 then
    begin
      For I:=1 to 128 do Font[I]:=0;
      Assign(F,Soubor);
      {$I-}Reset(F);{$I+}ErrorMessage;
      WriteDownMessage(' Na‡¡t m znak ze souboru ...');
      {$I-}
      Read(F,CisloFontu);
      For B:=0 to 15 do Read(F,FontOK[B]);
      {$I+}ErrorMessage;
      {$I-}Close(F);{$I+}ErrorMessage;
      ClearDownMessage;
    end;
    Repeat until Port[$60]>128;
  until (Scan=1)or(Scan=28);
  LoadReady;
  SetScreen;
  RefreshEditor;
  Scan:=0;
end;



Procedure PrepniASCIITab(C:Byte);
begin
  Asm
  MOV AH,11h
  MOV AL,3
  MOV BL,C
  INT 10h
  end;
end;



Procedure InstalujFont(TAB:Byte;Pocet:Word;OD:Byte);
begin
  REG.AH:=$11;
  REG.AL:=$10;
  REG.BL:=TAB;
  REG.BH:=16;
  REG.CX:=POCET;
  REG.DX:=OD;
  REG.ES:=SEG(FontPtr^);
  REG.BP:=OFS(FontPtr^);
  INTR($10,REG);
end;




Procedure InstallFont;
Procedure NactiFont;
Var
  F:File;
  Soubor:String;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
  W:Word;
begin
  MouseCursor(False);
  GetScreen;
  {TextColor(0);TextBackground(7);
  SmallHelp(1,5,18,15,'Na‡te celou ta- '+
                      'bulku znak– ze  '+
                      'souboru a pone- '+
                      'ch  ji v pamˆti '+
                      'jako nerezident-'+
                      'n¡.');}

  Repeat
    Soubor:=ChooseFile('*.FL');
    Soubor:=FExpand(Soubor);
    FSplit(Soubor,D,N,E);
    If E='' then E:='.FL';
    Soubor:=FExpand(D+N+E);

    If Scan=28 then
    begin
      GetScreen;
      WriteDownMessage('Inicializuji tabulku znak– ze souboru ...');
      Assign(F,Soubor);
      {$I-}Reset(F,1);{$I+}ErrorMessage;
      {$I-}FSize:=FileSize(F);{$I+}ErrorMessage;
      If (FSize<>4096)and(FSize<>4096+141)and(FSize<>4096+128) then
      begin
        TextColor(15);TextBackground(4);
        OkMessage('Soubor je po¨kozen˜ nebo nem  spr vn˜ form t !');
        GetKey;
        SetScreen;
      end;
      TextColor(0);TextBackground(7);
      {$I-}If FSize>=4096+141 then FSize:=FileSize(F)-141;{$I+}ErrorMessage;
      If MaxAvail<FSize then
      begin
        Sound(1000);Delay(50);NoSound;
        OkMessage('Nedostatek pamˆti pro tento soubor !');
        SetScreen;
      end
      else
      begin
        If FSize>=4096 then FSize:=4096;
        GetMem(FontPtr,FSize);
        {$I-}Seek(F,0);{$I+}ErrorMessage;
        {$I-}BlockRead(F,FontPtr^,FSize);{$I+}ErrorMessage;
        FreeMem(FontPtr,FSize);
        {$I-}BlockRead(F,FileInfo,141,I);{$I+}ErrorMessage;
        If Head.TEST<>'FONT' then
        begin
          OkMessage('Nekompaktibiln¡ tabulka znak– v souboru !');
          SetScreen;
        end;
      end;
      {$I-}Close(F);{$I+}ErrorMessage;
      ClearDownMessage;
    end;
    Repeat until Port[$60]>128;
  until (Scan=1)or(Scan=28);
  RefreshEditor;
end;


begin
  NactiFont;
  If Scan=28 then
  begin
    InstalujFont(10,FSize div 16,0);
    PrepniASCIITab(10);
  end;
  TextCursor(False);
  Scan:=0;
end;



Procedure MemImport;
Var
  P:Pointer;
  O:LongInt;
  S:LongInt;
  x:LongInt;
  Int43p,Buff:Pointer;
  F:File;

begin
  MouseCursor(False);
  GetScreen;
  {TextColor(0);TextBackground(7);
  SmallHelp(1,5,18,17,'Vybere p©¡slu¨- '+
                      'n˜ znak z pamˆ- '+
                      'ti ROM stiskem  '+
                      'p©¡slu¨n‚ kl ve-'+
                      'sy nebo zad n¡m '+
                      'jeho ASCII k¢du '+
                      '(Alt+..).       '+
                      '+/- (/*) m–‘ete '+
                      'lib. listovat   '+
                      'tabulkou znak–, '+
                      'Enter nebo Esc  '+
                      'potvrd¡ v˜bˆr.  ');}
  WriteDownMessage('ROM load. Press any key...');
  GetIntVec($43,P);
  X:=0;

  GetIntVec($43,P);
  Repeat
    For I:=1 to 128 do Font[I]:=0;
    For I:=0 to 15 do FontOK[I]:=0;

    If (B=43)and((x<4080)or(ScrollLock)) then x:=x+16;
    If (B=45)and((x>=16)or(ScrollLock)) then x:=x-16;
    If (B=42)and((x<4080)or(ScrollLock)) then x:=x+1;
    If (B=47)and((x>=16)or(ScrollLock)) then x:=x-1;

    If Ofs(P^)+I+x+5936<0 then
    begin
      x:=I+Ofs(P^)+5936;
    end;

    If Ofs(P^)+I+x+5936>65535 then
    begin
      x:=65535-Ofs(P^)-I-x-5936-16;
    end;


    GotoXY(1,24);TextColor(7);TextBackground(0);
    For I:=0 to 15 do
    begin
      O:=Ofs(P^)+I+x+5936;
      S:=Seg(P^);

      FontOK[I]:=Mem[S:O];
      Write(FontOK[I]:4,' ');
    end;
    TextColor(10);TextBackground(1);
    GotoXY(60,12);Write('ASCII: ',x div 16,'       ');
    LoadReady;
    RefreshEditor;

    GetKey;
    B:=ASCII;
    If (B<>43)and(B<>45)and(B<>47)and(B<>42)and(B<>13)and(B<>27) then x:=B*16;
  until (Scan=28)or(Scan=1);
  Repeat until Port[$60]>128;
  If Scan<>28 then
  begin
    For I:=1 to 128 do Font[I]:=0;
    LoadReady;
  end
  else
  If x div 16>255 then CisloFontu:=255 else CisloFontu:=x div 16;
  Scan:=0;Ascii:=0;
  TextBackground(1);TextColor(10);Center(2,Head.NameOfTab);
  ClearDownMessage;
  SetScreen;
  RefreshEditor;
end;



Procedure ImportFromFile;
Var
  P:Array[0..4095] of Byte;
  O,S:LongInt;
  Size:Word;
  Soubor:String;
  F:File;
  x:LongInt;
  D: DirStr;
  N: NameStr;
  E: ExtStr;

begin
  MouseCursor(False);
  GetScreen;
  {TextColor(0);TextBackground(7);
  SmallHelp(1,5,18,15,'Na‡te lib. znak '+
                      'z tabulky znak– '+
                      'v souboru.');}
  x:=0;
  Repeat
    Scan:=0;Ascii:=0;
    Soubor:=ChooseFile('*.FL');
    Soubor:=FExpand(Soubor);
    FSplit(Soubor,D,N,E);
    If E='' then E:='.FL';
    Soubor:=FExpand(D+N+E);

    If Scan=28 then
    begin
      For I:=1 to 128 do Font[I]:=0;
      Assign(F,Soubor);
      {$I-}Reset(F,1);{$I+}ErrorMessage;
      WriteDownMessage('Na‡¡t m tabulku znak– ze souboru ...');

      {$I-}Seek(F,0);{$I+}ErrorMessage;
      {$I-}BlockRead(F,P,4096);{$I+}ErrorMessage;

      {$I-}Seek(F,4096);{$I+}ErrorMessage;
      {$I-}BlockRead(F,HEAD,141);{$I+}ErrorMessage;

      If ord(Head.NameOfTab[0])>21 then HEAD.NameOfTab[0]:=#21;
      If ord(Head.EditorOEM[0])>11 then HEAD.EditorOEM[0]:=#11;

      If IORes<>0 then
      begin
        OkMessage(' Upozornˆn¡: Nepoda©ilo se na‡¡st hlavi‡ku souboru ! ');
        SetScreen;
      end;

      {$I-}Close(F);{$I+}ErrorMessage;

      If HEAD.TEST<>'FONT' then
      begin
        OkMessage('Upozornˆn¡: Nekompaktibiln¡ tabulka znak– v souboru !');
        SetScreen;
      end;
      TextBackground(0);TextColor(10);
      GotoXY(29,3);Write('                        ');
      Center(2,Head.NameOfTab);
      WriteDownMessage('Press any key...');
      TextBackground(1);
      Repeat
        For I:=1 to 128 do Font[I]:=0;
        For I:=0 to 15 do FontOK[I]:=0;

        If (B=43)and((x<4080)or(ScrollLock)) then x:=x+16;
        If (B=45)and((x>=16)or(ScrollLock)) then x:=x-16;
        If (B=42)and((x<4080)or(ScrollLock)) then x:=x+1;
        If (B=47)and((x>=16)or(ScrollLock)) then x:=x-1;

        GotoXY(1,24);TextColor(7);TextBackground(0);
        For I:=0 to 15 do
        begin
          {O:=I+x;}
          FontOK[I]:=P[I+X];
          Write(P[I+X]:4,' ');
        end;
        TextColor(10);TextBackground(1);
        GotoXY(60,12);Write('ASCII: ',x div 16,'     ');
        LoadReady;
        RefreshEditor;
        GetKey;
        B:=ASCII;
        If (B<>43)and(B<>45)and(B<>47)and(B<>42)and(B<>13)and(B<>27) then x:=B*16;
      until (Scan=28)or(Scan=1);
    end;
  until (Scan=1)or(Scan=28)or(B=13)or(B=27);
  If Scan<>28 then
  begin
    For I:=1 to 128 do Font[I]:=0;
    LoadReady;
  end
  else
  If x div 16>255 then CisloFontu:=255 else CisloFontu:=x div 16;
  Repeat until Port[$60]>128;
  Scan:=0;Ascii:=0;
  SetScreen;
  RefreshEditor;
end;



Procedure ExportToFile;
Var
  P:Array[0..4095] of Byte;
  O,S:LongInt;
  Size:Word;
  Soubor:String;
  F:File;
  D: DirStr;
  N: NameStr;
  E: ExtStr;


begin
  MouseCursor(False);
  GetScreen;
  {TextColor(0);TextBackground(7);
  SmallHelp(1,5,18,15,'Ulo‘¡ aktu ln¡  '+
                      'znak do tabulky '+
                      'znak– v souboru.');}
  VyplnFileInfo;
  Repeat
    Scan:=0;Ascii:=0;
    Soubor:=ChooseFile('*.FL');
    Soubor:=FExpand(Soubor);
    FSplit(Soubor,D,N,E);
    If E='' then E:='.FL';
    Soubor:=FExpand(D+N+E);

    If Scan=28 then
    begin
      ReadyToSave;
      Assign(F,Soubor);
      {$I-}Reset(F,1);{$I+}
      If IOResult<>0 then
      begin
        {$I-}Rewrite(F,1);{$I+}ErrorMessage;
      end
      else
      begin
        OkMessage('P©idat znak do souboru '+N+E+' ?');
        SetScreen;
        If (Scan<>28)and(UpCase(chr(ASCII))<>'A') then
        begin
          {$I-}Close(F);{$I+}ErrorMessage;
          Continue;
        end;
      end;
      WriteDownMessage('Uklad m znak do souboru ...');
      VyplnFileInfo;
      NastavFileInfo;

      I:=CisloFontu*16;
      {$I-}Seek(F,I);{$I+}ErrorMessage;
      {$I-}BlockWrite(F,FontOK,16);{$I+}ErrorMessage;

      {$I-}Seek(F,4096);{$I+}ErrorMessage;
      {$I-}BlockWrite(F,HEAD,141);{$I+}ErrorMessage;

      {$I-}Close(F);{$I+}ErrorMessage;
      RefreshEditor;
    end;
    Repeat until Port[$60]>128;
  until (Scan=255)or(Scan=1)or(Scan=28);
  Repeat until Port[$60]>128;
  Scan:=0;Ascii:=0;
  SetScreen;
end;



Procedure NewFontTab;
Var
  X:Word;
  I:Integer;
  P:Pointer;
  O:Integer;
  S:LongInt;
  F:File;
  Size:Word;
  Soubor:String;
  D: DirStr;
  N: NameStr;
  E: ExtStr;

begin
  MouseCursor(False);
  GetScreen;
  {TextColor(0);TextBackground(7);
  SmallHelp(1,5,18,15,'Ulo‘¡ origin ln¡'+
                      'ROM tabulku zna-'+
                      'k– do souboru.  '+
                      'Napi¨te n zev   '+
                      'souboru, do kte-'+
                      'r‚ho chcete ta- '+
                      'bulku ulo‘it.   '+
                      'Znaky v souboru '+
                      'lze pot‚ lib.   '+
                      'upravovat.');}

  Repeat
    Soubor:=ChooseFile('*.FL');
    Soubor:=FExpand(Soubor);
    FSplit(Soubor,D,N,E);
    If E='' then E:='.FL';
    Soubor:=FExpand(D+N+E);

    If Scan=28 then
    begin
      Assign(F,Soubor);
      {$I-}Reset(F,1);{$I+}
      If IOResult=0 then
      begin
        OkMessage(' Soubor ji‘ existuje. Chcete ho p©epsat ?');
        SetScreen;
        Ascii:=ord(UpCase(chr(Ascii)));
        If (Chr(Ascii)='A')or(Chr(Ascii)='Y')or(Scan=28) then
        begin
          {$I-}Rewrite(F,1);{$I+}ErrorMessage;
        end;
      end
      else
      begin
        {$I-}Rewrite(F,1);{$I+}ErrorMessage;
      end;
      VyplnFileInfo;
      NastavFileInfo;

      WriteDownMessage('Ukl d m tabulku znak– z ROM do souboru ...');


      GetIntVec($43,P);
      {For B:=0 to 255 do
      begin
        x:=B*16;}
        O:=Ofs(P^)+5936;
        S:=Seg(P^);

      Seek(F,0);
      {$I-}BlockWrite(F,Mem[S:O],4096);{$I+}ErrorMessage;

      {end;}

      Seek(F,4096);
      {$I-}BlockWrite(F,FileInfo,141);{$I+}ErrorMessage;
      ClearDownMessage;

      {$I-}Close(F);{$I+}ErrorMessage;
      RefreshEditor;
      Break;
    end;
  until (Scan=1)or(Scan=28);
  Repeat until Port[$60]>128;
  Scan:=0;Ascii:=0;
  SetScreen;
end;



Procedure InstallCustomFonts;
Var
  Reg:Registers;
  {FontPtr:Pointer;}
  FSize:LongInt;
  Soubor:String[80];

Procedure NactiFont;
Var
  F:File;
begin
  Soubor:=ParamStr(1);
  If Soubor='' then
  begin
    Writeln('Jako parametr mus¡ b˜t uveden soubor s tabulkou znak–.');
    Halt(0);
  end;
  Assign(F,Soubor);
  {$I-}Reset(F,1);{$I+}ErrorMessage;
  If IORes<>0 then Halt(1);
  FSize:=FileSize(F);
  If (FSize<>4237)and(FSize<>4224)and(FSize<>4096) then
  begin
    Writeln('Nekompaktibiln¡ tabulka znak– v souboru !');
    Write('Pokra‡ovat (A/) ? ');
    If UpCase(Readkey)<>'A' then Halt(1);
    Writeln;
  end;
  If FSize>4096 then FSize:=4096;
  If FSize+141>MaxAvail then
  begin
    Writeln('Nedostatek pamˆti pro tabulku.');Halt(1);
  end;
  GetMem(FontPtr,FSize);
  Seek(F,0);
  {$I-}BlockRead(F,FontPtr^,4096,I);{$I+}ErrorMessage;
  {$I-}Close(F);{$I+}ErrorMessage;
end;

{Procedure InstalujFont(TAB:Byte;Pocet:Word;OD:Byte);
begin
  REG.AH:=$11;
  REG.AL:=$10;
  REG.BL:=TAB;
  REG.BH:=16;
  REG.CX:=POCET;
  REG.DX:=OD;
  REG.ES:=SEG(FontPtr^);
  REG.BP:=OFS(FontPtr^);
  INTR($10,REG);
end;

Procedure PrepniASCIITab(C:Byte);
begin
  REG.AH:=$11;
  REG.AL:=3;
  REG.BL:=C;
  INTR($10,REG);
end;


{InstallCustomFonts;}
begin
  If Copy(ParamStr(1),1,1)='-' then
  begin
    PrepniASCIITab(0);
    Writeln('Nastavena implicitni sada znaku.');
    Writeln;
    Writeln('Copyright (C) 1998  Tomas Hujer');
    Halt(0);
  end;
  NactiFont;
  InstalujFont(10,FSize div 16,0);
  FreeMem(FontPtr,FSize);
  PrepniASCIITab(10);
  For I:=0 to ParamCount do If ParamStr(I)='/OFF' then Exit;
  Writeln('Nov  sada znak– byla £spˆ¨nˆ instalov na.');
  Writeln;
  Writeln('Copyright (C) 1998  Tom ¨ Hujer');
end;




Begin
  Cfg.Locks0:=Mem[0:$417];
  GetDir(0,Cfg.PuvAdr);
  Head.NameOfTab:='NoName';
  Mem[0:$417]:=Mem[0:$417] and (32+64+16);
  If Copy(ParamStr(1),1,1)='/' then
  begin
    Writeln(#13'Program umo‘¤uj¡c¡ vytvo©en¡ vlastn¡ sady znak–.');
    Writeln;
    Writeln('Syntaxe:  FONTEDIT.EXE [Soubor s tabulkou znak–]');
    Writeln('          FONTEDIT.EXE -');
    Writeln('          FONTEDIT.EXE /?');
    Writeln;
    Writeln('Bez parametru spust¡ editor znakov˜ch tabulek.');
    Writeln('Je-li jako parametr uveden soubor s tab. znaku, zavede tabulku do pamˆti.');
    Writeln(' - ...  Nastav¡ implicitn¡ tabulku znak–');
    Writeln;
    Writeln;
    Writeln('Copyright (C) 1998  Tomas Hujer');
    Writeln;
    TextCursor(True);
    Halt(0);
  end;
  If (Copy(ParamStr(1),1,1)<>'/')and(ParamCount>0)then
  begin
    TextCursor(True);
    InstallCustomFonts;
    Halt(0);
  end;
  If UpString(ParamStr(1))='OFF' then
  begin
    PrepniASCIITab(0);
    Halt(0);
  end;
  FSplit(FExpand(Paramstr(0)),D,N,E);
  Adr:=D;
  {InitStandardScreen('±',1,8,2);}

  LoadCZPage(10);
  Refresh;
  {Time(True);}
  SetAsciiTab(10);
  About(OEM,Ver);
  Head.NameOfTab:='';
  Repeat
    Scan:=0;
    MouseCursor(True);
    If Keypressed then
    If (Port[$60]<128)and(Port[$60]<>55)and(Port[$60]<>29)and(Port[$60]<>42)
       and(Port[$60]<>54)and(Port[$60]<>56)and(Port[$60]<>58)
       and(Port[$60]<>69)and(Port[$60]<>70) then GetKey;

    If (ASCII=18)and(SCAN=19) then Refresh;          {Ctrl+R}
    If (ASCII=14)and(SCAN=49) then NewFontTab;       {Ctrl+N}
    If (ASCII=3)and(SCAN=46) then ClearFont;         {Ctrl+C}
    If (ASCII=9)and(SCAN=23) then MemImport;         {Ctrl+I}
    If (ASCII=0)and(SCAN=33) then ZobrazFileInfo;    {Alt+F }
    If (ASCII=0)and(SCAN=31) then NastavFileInfo;    {Alt+S }
    If (ASCII=6)and(SCAN=33) then                    {Ctrl+F}
    begin
      MouseCursor(False);
      Repeat
        InputNumLine(69,20,3,CisloFontu);
        Val(Vstup,I,Code);
      until I<=255;
      If Scan=28 then CisloFontu:=I;
      Scan:=0;
      Repeat until Port[$60]>128;
      MouseCursor(True);
    end;

    If Scan=53 then KeyHelp;           {?}
    If Scan=59 then Help;              {F1}
    If Scan=60 then SaveToFile;        {F2}
    If Scan=61 then LoadFromFile;      {F3}
    If Scan=63 then ImportFromFile;    {F5}
    If Scan=64 then ExportToFile;      {F6}
    If Scan=66 then PrepniASCIITab(0); {F8}
    If Scan=67 then InstallFont;       {F9}
    If Scan=68 then About(OEM,Ver);    {F10}
    If (Scan=23)and(Ascii=0)then Info; {Alt+I}

    GetMousePos;Mx:=Mx div 8;My:=My div 8;

    TextColor(0);TextBackground(7);
    GotoXY(70,20);Write(Mx,'   ',My,'   ');
    GotoXY(70,21);Write(CisloFontu,'   ');


    I:=0;
    For yf:=0 to 15 do
    For xf:=0 to 7 do
    begin
      I:=I+1;
      If (MBDown(1))or(MBDown(2)) then
      If ((Mx div 8=Xf*3+28)and(My div 8=Yf+3))or
         ((Mx div 8=Xf*3+29)and(My div 8=Yf+3))or
         ((Mx div 8=Xf*3+30)and(My div 8=Yf+3))then
      begin
        MouseCursor(False);
        If MBDown(1) then Font[I]:=1;
        If MBDown(2) then Font[I]:=0;
        If Font[I]=1 then
        begin
          TextColor(10);TextBackground(1);
        end
        else
        begin
          TextColor(8);TextBackground(1);
        end;
        GotoXY(Xf*3+29,Yf+4);Write('±±±');
        MouseCursor(True);
      end;
    end;
  until (Scan=45)and(Ascii=0);
  {Time(False);}
  Repeat until Port[$60]>128;
  MouseCursor(False);
  ChDir(Cfg.PuvAdr);
  Done;
  Mem[0:$417]:=Mem[0:$417] and (32+64+16);
end.