Unit THGS;
Interface

Procedure DestructScreenBuffer;
Procedure GetScreen;
Procedure SetScreen;
Procedure GetScreen2(Page:Byte);
Procedure SetScreen2(Page:Byte);


Implementation
Uses Crt;
type
  TScr=Array[0..4000] of Byte;
  TScr0=Array[0..4000] of byte;
  TScr1=Array[0..4000] of byte;
  TScr2=Array[0..4000] of byte;
  TScr3=Array[0..4000] of byte;
  TScr4=Array[0..4000] of byte;
  TScr5=Array[0..4000] of byte;


Var
  xWind,yWind,iii,I:Word;
  ScreenBuffer:^TScr;
  ScrB0:^TScr0;
  ScrB1:^TScr1;
  ScrB2:^TScr2;
  ScrB3:^TScr3;
  ScrB4:^TScr4;
  ScrB5:^TScr5;
  x,y,Segment:Word;
  B:Byte;


Procedure GetScreen;
Var
  B:Byte;
begin
  If MaxAvail < SizeOf(TScr) then Writeln('M lo pamˆti')
  else
  begin
    If ScreenBuffer=nil then New(ScreenBuffer);
    {Pri NewScr... ulozi vytvori vzdy novou promennou pro obrazovku.}

    For yWind:=0 to 24 do
    For xWind:=0 to 79 do
    begin
      iii:=(xWind*2)+(yWind*2*80);
      ScreenBuffer^[III]:=Mem[Segment:iii];
      ScreenBuffer^[III+1]:=Mem[Segment:iii+1];
    end;
  end;
end;


Procedure SetScreen;
begin
  For yWind:=24 downto 0 do
  For xWind:=79 downto 0 do
  begin
    iii:=(xWind*2)+(yWind*2*80);
    Mem[Segment:iii]:=ScreenBuffer^[III];
    Mem[Segment:iii+1]:=ScreenBuffer^[III+1];
  end;
end;

Procedure DestructScreenBuffer;
begin
  Dispose(ScreenBuffer);
end;




Procedure GetScreen2(Page:Byte);
begin
  Case Page of
  0: New(ScrB0);
  1: New(ScrB1);
  2: New(ScrB2);
  3: New(ScrB3);
  4: New(ScrB4);
  5: New(ScrB5);
  end;
  If (MaxAvail<25*80) then
  begin
    Writeln('M lo pamˆti');
    Halt;
  end
  else
  begin
    For y:=0 to 24 do
    For x:=0 to 79 do
    begin
      I:=(x*2)+(y*2*80);
      Case Page of
      0:begin ScrB0^[I]:=Mem[Segment:I];ScrB0^[I+1]:=Mem[Segment:I+1];end;
      1:begin ScrB1^[I]:=Mem[Segment:I];ScrB1^[I+1]:=Mem[Segment:I+1];end;
      2:begin ScrB2^[I]:=Mem[Segment:I];ScrB2^[I+1]:=Mem[Segment:I+1];end;
      3:begin ScrB3^[I]:=Mem[Segment:I];ScrB3^[I+1]:=Mem[Segment:I+1];end;
      4:begin ScrB4^[I]:=Mem[Segment:I];ScrB4^[I+1]:=Mem[Segment:I+1];end;
      5:begin ScrB5^[I]:=Mem[Segment:I];ScrB5^[I+1]:=Mem[Segment:I+1];end;
      end;
    end;
  end;
end;

Procedure SetScreen2(Page:Byte);
begin
  For y:=24 downto 0 do
  For x:=79 downto 0 do
  begin
    I:=(x*2)+(y*2*80);
    Case Page of
    0:begin Mem[Segment:I]:=ScrB0^[I];Mem[Segment:I+1]:=ScrB0^[I+1];end;
    1:begin Mem[Segment:I]:=ScrB1^[I];Mem[Segment:I+1]:=ScrB1^[I+1];end;
    2:begin Mem[Segment:I]:=ScrB2^[I];Mem[Segment:I+1]:=ScrB2^[I+1];end;
    3:begin Mem[Segment:I]:=ScrB3^[I];Mem[Segment:I+1]:=ScrB3^[I+1];end;
    4:begin Mem[Segment:I]:=ScrB4^[I];Mem[Segment:I+1]:=ScrB4^[I+1];end;
    5:begin Mem[Segment:I]:=ScrB5^[I];Mem[Segment:I+1]:=ScrB5^[I+1];end;
    end;
  end;
  Case Page of
  0:Dispose(ScrB0);
  1:Dispose(ScrB1);
  2:Dispose(ScrB2);
  3:Dispose(ScrB3);
  4:Dispose(ScrB4);
  5:Dispose(ScrB5);
  end;
end;





Begin
  asm
  MOV AH,0Fh
  INT 10h
  MOV B,AL
  end;
  If B<=3 then Segment:=$B800;
  If B=7 then Segment:=$B000;
end.