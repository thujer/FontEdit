Program Font2FontLibrary;
Uses Dos,Crt;
Var
  S,D :File of Byte;
  P :Longint;
  Ascii:Byte;
  I:Integer;
  Ch:Char;
  Soubor:String;

Procedure WriteROMFonts;
Var
  X:Word;
  I:Integer;
  P:Pointer;
  O:Integer;
  S:LongInt;
begin
  GetIntVec($43,P);
  For Ascii:=0 to 255 do
  begin
    x:=Ascii*16;
    For I:=0 to 15 do
    begin
      O:=Ofs(P^)+I+x+5936;
      S:=Seg(P^);
      Write(D,Mem[S:O]);
    end;
    GotoXY(2,WhereY);Write('FONT ASCII: ',Ascii,'  ');
  end;
  GotoXY(2,WhereY);Write('                        ');
end;


begin
  If ParamStr(1)='/?' then
  begin
    Writeln('Help');
    Halt;
  end;

  If (Copy(ParamStr(1),1,1)='/')or(ParamCount=0)or(ParamCount>2) then
  begin
    Writeln;
    Writeln('Syntaxe:');
    Writeln;
    Writeln('  FNT2FL.EXE [Soubor fontu] [Soubor s tabulkou fontu]');
    Writeln('Ulozi urcity znak ze Souboru fontu do Tabulky fontu.');
    Writeln;
    Writeln;
    Writeln('  FNT2FL.EXE [Novy soubor s tabulkou fontu]');
    Writeln('Vytvori implicitni tabulku fontu.');
    Writeln;
    Writeln;
    Writeln('  FNT2FL.EXE /?');
    Writeln('Help');
    Writeln;
    Writeln;
    Writeln('Napr.:  FNT2FL.EXE MOJECZ.FL');
    Writeln('        FNT2FL.EXE 00001.FNT MOJECZ.FL');
    Writeln;
    Writeln;
    Writeln('Copyright (C) 1998  Tomas Hujer');
    Writeln;
    Halt(0);
  end;

  If ParamCount=2 then
  begin
    Assign(S,ParamStr(1));
    Assign(D,ParamStr(2));
    {$I-}
    Reset(S);
    {$I+}
    If IOResult<>0 then
    begin
      Writeln('Zdrojovy soubor neexituje !');
      Halt(1);
    end;
    {$I-}
    Reset(D);
    {$I+}
    If IOResult<>0 then
    begin
      {$I-}
      Rewrite(D);
      {$I+}
      If IOResult<>0 then
      begin
        Writeln('Nelze zalozit soubor ',ParamStr(2),' !');
        Halt(1);
      end;
      WriteROMFonts;
    end;

    Read(S,Ascii);
    P:=Ascii*16;
    Seek(D,P);
    Writeln(#13'Pozice znaku v ASCII: ',FilePos(D) div 16);
    If FileSize(S)<17 then
    begin
      Writeln('Vadny soubor fontu !');
      Halt(1);
    end;
    For I:=0 to 15 do
    begin
      {$I-}
      Read(S,Ascii);
      {$I+}
      If IOResult<>0 then
      begin
        Writeln('Vadny soubor fontu !');
        Halt(1);
      end;
      Write(D,Ascii);
    end;
    Close(S);
    Close(D);
    Writeln(#10#13'Copyright (C) 1998  Tomas Hujer');
    Halt(0);
  end;

  If ParamCount=1 then
  begin
    Soubor:=ParamStr(1);
    For I:=0 to Length(Soubor) do Soubor[I]:=UpCase(Soubor[I]);
    If Pos('.',Soubor)=0 then Soubor:=Soubor+'.FL';
    Assign(D,Soubor);
    {$I-}
    Reset(D);
    {$I+}
    If IOResult=0 then
    begin
      Writeln(#10#13'Soubor jiz existuje. Chcete jej prepsat (A/)? ');
      Ch:=UpCase(ReadKey);
      If Ch='A' then Rewrite(D);
      If Ch<>'A' then
      begin
        Close(D);
        Halt(0);
      end;
    end
    else
    begin
      {$I-}
      Rewrite(D);
      {$I+}
      If IOResult<>0 then
      begin
        Writeln('Nelze zalozit soubor ',Soubor,' !');
        Halt(1);
      end;
    end;
    WriteROMFonts;
    {$I-}
    Close(D);
    {$I+}
    If IOResult=0 then
    begin
      Writeln(#10#13'Implicitni tabulka znaku byla zapsana do souboru: ',Soubor);
      Writeln(#10#13'Copyright (C) 1998  Tomas Hujer');
    end
    else
    begin
      Writeln('Nelze zavrit soubor ',Soubor,' !');
      Halt(1);
    end;
  end;
end.