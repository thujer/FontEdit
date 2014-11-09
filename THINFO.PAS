Unit THINFO;
Interface

Procedure Info;

Implementation
Uses THApp,THMouse,Crt,THString,CZ,THGS;

Procedure Info;
Var
  B:Byte;
  W,W2:Word;
  L:LongInt;
begin
  MouseCursor(False);
  GetScreen;
  TextColor(0);TextBackground(7);
  Frame(23,6,58,18,129+64);
  Center(6,' INFO ');
  GotoXY(26,9);Write('Voln  pamˆt v haldˆ: ',MaxAvail,' B');
  Asm
    INT 12h
    MOV W,AX
  end;
  GotoXY(26,10);Write('Celkem konven‡n¡ pamˆti: ',W,' kB');

  Asm
    MOV AH,48h
    MOV BX,0FFFFh
    INT 21h
    MOV W,BX
  end;
  L:=W;
  L:=L*16 div 1024;
  GotoXY(26,11);Write('Voln  konven‡n¡ pamˆt: ',L,' kB');

  Asm
    MOV AH,42h
    INT 67h
    MOV W,DX
  end;
  GotoXY(26,12);Write('Celkem pamˆti EMS: ',W*16,' kB');
  Asm
    MOV AH,42h
    INT 67h
    MOV W,BX
  end;
  GotoXY(26,13);Write('Voln  pamˆt EMS: ',W*16,' kB');

  Asm
    MOV AH,46h
    INT 67h
    MOV B,AL
  end;
  GotoXY(26,14);
  Write('Verze ovlada‡e EMS: ',Copy(HexByte(B),1,1)+'.'+Copy(HexByte(B),2,1));

  Asm
    MOV AH,40h
    INT 67h
    MOV B,AL
  end;
  GotoXY(26,15);
  Write('Stav ovlada‡e EMS: ');
  If B=0 then Write('Ok') else Write('Chyba');

  Asm
    MOV AX,0
    INT 33h
    MOV W,AX
    MOV W2,BX
  end;
  GotoXY(26,16);Write('Ovlada‡ my¨i: ');
  If W=$FFFF then
  begin
    Write('Instalov n');
    GotoXY(26,17);Write('Po‡et tla‡¡tek my¨i: ',W2);
  end
  else Write('Nen¡ instalov n');


  Repeat
    GetKey;
  until (Scan=28)or(Scan=1);
  SetScreen;
end;

end.