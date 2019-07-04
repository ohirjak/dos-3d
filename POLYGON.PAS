program Poly;

uses VGA, Crt;

var
  p6: pointer;
  sys: word;
  x1, y1, x2, y2, x3, y3, x4, y4: word;

procedure Polygon(segm,x1,y1,x2,y2,x3,y3,x4,y4: word; c: byte);
{Draws a polygon with four edges with color c in a bank or on screen}
label pixels1,pixels2,pixels3,pixels4,clear,lines,drawit,nodraw
      ,skip1a,skip1b,skip2a,skip2b,skip3a,skip3b,skip4a,skip4b
      ,drawword,startfast,lastodd;
var x,y: array[1..5] of word;
    xs: word;
    dy: integer;
    dx: word;
    i,l: word;
    a,b: word;
    h1,v1: word;
    loopc: word;
begin
   x[1]:=x1; y[1]:=y1;
   x[2]:=x2; y[2]:=y2;
   x[3]:=x3; y[3]:=y3;
   x[4]:=x4; y[4]:=y4;
   x[5]:=x1; y[5]:=y1;
   {Clear the start-end-of-horizontal-line table}
   asm
      mov AX,[sys]
      mov ES,AX
      mov DI,0
      mov CX,200
   clear:
      mov word ptr ES:[DI],320       {min value at current line}
      mov word ptr ES:[DI+2],0       {max value at current line}
      add DI,4
      loop clear
   end;
   {Draw lines}
   for i:=1 to 4 do begin
      b:=0;
      if abs(y[i]-y[i+1])>0 then begin
         if y[i]<y[i+1] then begin
            if x[i]<x[i+1] then begin
               h1:=x[i];
               v1:=y[i];
               dx:=x[i+1]-h1;
               dy:=y[i+1]-v1;
               xs:=(dx shl 7) div dy;
               asm
                  mov AX,[sys]          {write min&max values in bank6}
                  mov ES,AX
                  mov DI,[v1]           {first line to fill}
                  shl DI,2              {4 bytes per line}
                  mov BX,[h1]           {get start-x for line}
                  shl BX,7              { *127 }
                  mov DX,[xs]           {x-displacement per line}
                  mov CX,[dy]
               pixels1:
                  mov SI,BX             {get x}
                  shr SI,7              {divide by 127}
                  cmp SI,ES:[DI]        {smaller than min at this line?}
                  jae skip1a
                  mov ES:[DI],SI        {replace min}
               skip1a:
                  cmp SI,ES:[DI+2]      {greater than max at this line?}
                  jbe skip1b
                  mov ES:[DI+2],SI      {replace max}
               skip1b:
                  add DI,4              {next line}
                  add BX,DX             {update x-coord}
                  loop pixels1          {next pixel}
               end;
            end else begin
               h1:=x[i+1];
               v1:=y[i+1];
               dx:=x[i]-h1;
               dy:=v1-y[i];
               xs:=(dx shl 7) div dy;
               asm
                  mov AX,[sys]          {write min&max values in bank6}
                  mov ES,AX
                  mov DI,[v1]           {first line to fill}
                  shl DI,2              {4 bytes per line}
                  mov BX,[h1]           {get start-x for line}
                  shl BX,7              { *127 }
                  mov DX,[xs]           {x-displacement per line}
                  mov CX,[dy]
               pixels2:
                  mov SI,BX             {get x}
                  shr SI,7              {divide by 127}
                  cmp SI,ES:[DI]        {smaller than min at this line?}
                  jae skip2a
                  mov ES:[DI],SI        {replace min}
               skip2a:
                  cmp SI,ES:[DI+2]      {greater than max at this line?}
                  jbe skip2b
                  mov ES:[DI+2],SI      {replace max}
               skip2b:
                  sub DI,4              {next line}
                  add BX,DX             {update x-coord}
                  loop pixels2          {next pixel}
               end;
            end
         end else begin
            if x[i]>x[i+1] then begin
               h1:=x[i+1];
               v1:=y[i+1];
               dx:=x[i]-h1;
               dy:=y[i]-v1;
               xs:=(dx shl 7) div dy;
               asm
                  mov AX,[sys]          {write min&max values in bank6}
                  mov ES,AX
                  mov DI,[v1]           {first line to fill}
                  shl DI,2              {4 bytes per line}
                  mov BX,[h1]           {get start-x for line}
                  shl BX,7              { *127 }
                  mov DX,[xs]           {x-displacement per line}
                  mov CX,[dy]
               pixels3:
                  mov SI,BX             {get x}
                  shr SI,7              {divide by 127}
                  cmp SI,ES:[DI]        {smaller than min at this line?}
                  jae skip3a
                  mov ES:[DI],SI        {replace min}
               skip3a:
                  cmp SI,ES:[DI+2]      {greater than max at this line?}
                  jbe skip3b
                  mov ES:[DI+2],SI      {replace max}
               skip3b:
                  add DI,4              {next line}
                  add BX,DX             {update x-coord}
                  loop pixels3          {next pixel}
               end;
            end else begin
               h1:=x[i];
               v1:=y[i];
               dx:=x[i+1]-h1;
               dy:=v1-y[i+1];
               xs:=(dx shl 7) div dy;
               asm
                  mov AX,[sys]          {write min&max values in bank6}
                  mov ES,AX
                  mov DI,[v1]           {first line to fill}
                  shl DI,2              {4 bytes per line}
                  mov BX,[h1]           {get start-x for line}
                  shl BX,7              { *127 }
                  mov DX,[xs]           {x-displacement per line}
                  mov CX,[dy]
               pixels4:
                  mov SI,BX             {get x}
                  shr SI,7              {divide by 127}
                  cmp SI,ES:[DI]        {smaller than min at this line?}
                  jae skip4a
                  mov ES:[DI],SI        {replace min}
               skip4a:
                  cmp SI,ES:[DI+2]      {greater than max at this line?}
                  jbe skip4b
                  mov ES:[DI+2],SI      {replace max}
               skip4b:
                  sub DI,4              {next line}
                  add BX,DX             {update x-coord}
                  loop pixels4          {next pixel}
               end;
            end;
         end;
      end;
   end;
   {determine highest and lowest y-coord}
   i:=0;        {highest}
   l:=200;      {lowest}
   for a:=1 to 4 do begin
      if y[a]<l then l:=y[a];
      if y[a]>i then i:=y[a];
   end;
   {Now draw the horizontal lines really fast using words}
   asm
      mov CX,[i]                     {last line to draw}
      mov DI,[l]                     {first line to draw}
      sub CX,DI                      {number of lines to draw}
      mov [loopc],CX
      mov AX,DI
      mov SI,DI                      {min-max table pointer}
      shl SI,2
      shl AX,6
      shl DI,8
      add DI,AX                      {DI=startline *320}
      mov ES,[segm]
      mov AL,[c]
      mov AH,AL
      push DS
      mov DS,[sys]                   {min-max table segment}
   lines:
      mov BX,DS:[SI]                 {startpos of current line}
      mov CX,DS:[SI+2]               {endpos of current line}
      inc CX
      sub CX,BX                      {length of current line}
   drawit:
      mov DX,BX                      {odd?}
      and DX,1
      jz  startfast                  {no:  start drawing words}
      mov ES:[DI+BX],AL              {yes: draw the odd pixel}
      inc BX                         {now it's even}
      dec CX                         {was this the last pixel?}
      jz  nodraw                     {then quit}
   startfast:
      mov DX,CX
      shr CX,1                       {how many words?}
      jz  lastodd                    {none}
   drawword:
      mov ES:[DI+BX],AX
      add BX,2
      loop drawword
   lastodd:
      and DX,1
      jz  nodraw
      mov ES:[DI+BX],AL
   nodraw:
      add SI,4                       {next min-max line}
      add DI,320                     {next screen-line}
      dec [loopc]
      jnz lines
      pop DS
   end;
end;

BEGIN
  OpenVGA;
  GetMem(p6, 32767);
  FillChar(p6^, 32767, 0);
  sys:= Seg(p6^);
  x1:= 50; y1:= 50;
  x2:= 250; y2:= 50;
  x3:= 319; y3:= 150;
  x4:= 0; y4:= 150;
  repeat
    Farba:= 0;
    ClearVirtual;
    Polygon(vs, x1, y1, x2, y2, x3, y3, x4, y4, 15);
    ReFresh;
    Delay(50);
  until KeyPressed;
  FreeMem(p6, 32767);
  Readln;
  CloseVGA;
END.