Unit THMouse;
Interface
Var
  Mx,My,NO_Push:Word;

Procedure InitMouse;
Function  MouseDriver :Boolean;
Function  NumberOfMouseButtons:Word;
Procedure MouseCursor(B:Boolean);
Procedure MouseTextCursor(SMaska,KMaska:Word);
Procedure MouseGraphCursor(HotSpotX, HotSpotY : integer; Tabulka : pointer);
Procedure GetMousePos;
Procedure SetMousePos(x,y:Word);
Function  MBDown(Button:Word):Boolean;
Function  MBUp(Button:Word):Word;
Procedure SetMouseRateX(Xmin,Xmax:Word);
Procedure SetMouseRateY(Ymin,Ymax:Word);
Procedure SetMouseRate(Xmin,Ymin,Xmax,Ymax:Word);
Procedure SetMouseSpeed(Xs,Ys:Word);

Implementation
Uses
  Dos,Crt;


Procedure InitMouse;Assembler;
{Inicializuje my¨}
Asm
  MOV AX,0
  INT 33h
end;


Function MouseDriver :Boolean;
{Zjisti zda je nainstalovan ovladac mysi}
Var
  B:Word;
begin
  Asm
  MOV AX,0
  INT 33h
  MOV B,AX
  end;
  If B=$0000 then MouseDriver:=False else MouseDriver:=True;
end;


Function NumberOfMouseButtons:Word;
{Zjist¡, kolik m  my¨ tla‡¡tek}
Var
  B:Word;
begin
  Asm
  MOV AX,11h
  INT 33h
  MOV B,BX
  end;
  NumberOfMouseButtons:=B;
end;


Procedure MouseCursor(B:Boolean);
{Zapne kurzor my¨i}
begin
  If B then
  Asm
    MOV AX,1
    INT 33h
  end
  else
  Asm
    MOV AX,2
    INT 33h
  end;
end;


Procedure MouseTextCursor(SMaska,KMaska:Word);Assembler;
{Nastavi textovy kurzor mysi. SMaska je ASCII kod masky obrazu, KMaska
je ASCII kod masky kurzoru}
Asm
  MOV AX,3Ah
  MOV BX,0
  MOV CX,SMaska
  MOV DX,KMaska
  INT 33h
end;


Procedure MouseGraphCursor(HotSpotX, HotSpotY : integer; Tabulka : pointer);
{Nastavi graficky kurzor mysi. HotSpotX, HotSpotY jsou souradnice bodu na
ktery se vztahuje citlivost mysi. Tabulka je ukazatel na bitmapu kurzoru.}
Var
  O,S:Word;
begin
  O:=Ofs(Tabulka^);
  S:=Seg(Tabulka^);
  Asm
  MOV AX,9
  MOV BX,HotSpotX;
  MOV CX,HotSpotY;
  MOV DX,O
  MOV ES,S
  INT 33h
  end;
end;


Procedure GetMousePos;
begin
  asm
    MOV AX,0003h
    INT 33h
    MOV MX,CX
    MOV MY,DX
  end;
  {MX:=MX div 8;
  MY:=MY div 8;}
end;


Procedure SetMousePos(x,y:Word);Assembler;
{Umisti kurzor mysi na obrazovku do bodu o souradnicich MysX, MysY}
asm
  MOV AX,0004h
  MOV CX,X
  MOV DX,Y
  INT 33h
end;


Function MBDown(Button:Word):Boolean;
{Zjistuje zda bylo stisknuto tlacitko, kde a kolikrat}
Var
  B:Word;
begin
  asm
  {MOV AX,0005h
  MOV BX,BUTTON
  INT 33h
  MOV B,AX
  MOV NO_Push,BX
  MOV Mx,CX
  MOV My,DX}
  MOV AX,3
  INT 33h
  MOV B,BX
  MOV Mx,CX
  MOV My,DX
  end;
  If B and Button>0 then MBDown:=True else MBDown:=False;
end;


Function MBUp(Button:Word):Word;
{Zjistuje zda bylo uvolneno tlacitko, kde a kolikrat}
Var
  B:Word;
begin
  asm
  MOV AX,0006h
  MOV BX,BUTTON
  INT 33h
  MOV B,AX
  MOV NO_Push,BX
  MOV Mx,CX
  MOV My,DX
  end;
  MBUp:=B;
end;


Procedure SetMouseRateX(Xmin,Xmax:Word);Assembler;
{Nastaven¡ horizont ln¡ho rozsahu sou©adnic}
Asm
  MOV AX,7
  MOV CX,Xmin
  MOV DX,Xmax
  INT 33h
end;


Procedure SetMouseRateY(Ymin,Ymax:Word);Assembler;
{Nastaven¡ vertikalniho rozsahu souradnic}
Asm
  MOV AX,8
  MOV CX,Ymin
  MOV dx,Ymax
  INT 33h
end;


Procedure SetMouseRate(Xmin,Ymin,Xmax,Ymax:Word);Assembler;
{Nastaven¡ horizont ln¡ho rozsahu sou©adnic}
Asm
  MOV AX,7
  MOV CX,Xmin
  MOV DX,Xmax
  INT 33h

  MOV AX,8
  MOV CX,Ymin
  MOV dx,Ymax
  INT 33h
end;



Procedure SetMouseSpeed(Xs,Ys:Word);Assembler;
Asm
  MOV AX,000Fh
  MOV CX,Xs
  MOV DX,Ys
  INT 33h
end;


end.