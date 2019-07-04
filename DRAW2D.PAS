unit Draw2D;

INTERFACE

const
  MaxX= 319;
  MaxY= 199;

type
  TImage= record
    x1, y1: integer;
    dx, dy: word;
    Trans: byte;
    Able: boolean;
    BitMap: pointer;
    Size: word;
  end;

  TPalette= record
    R, G, B: byte;
  end;

  TPaleta= array[0..255] of TPalette;

{ otvorenie graf. mode }
procedure OpenVGA;
procedure CloseVGA;

{ nastavenie, zistenie farby }
procedure SetColor(f: byte);
function GetColor: byte;
procedure SetPal(R, G, B: byte; var p: TPalette);
procedure GetPal(f: byte; var p: TPalette);
procedure SetRGB(f: byte; p: TPalette);
procedure GetRGB(f: byte; var p: TPalette);

{ kreslenie }
procedure PutPixel(x, y: integer; f: byte);
function GetPixel(x, y: integer): byte;
procedure Line(x1, y1, x2, y2: integer);
procedure Circle(xs, ys, r: integer);
procedure HorizLine(x1, x2, y: integer);
procedure VertLine(x, y1, y2: integer);
procedure RectAngle(x1, y1, x2, y2: integer);
procedure Bar(x1, y1, x2, y2: integer);

procedure Polygon3(x1, y1, x2, y2, x3, y3: integer);

{ uchovanie obsahu obrazovky }
procedure ImageSize(var Image: TImage);
procedure PutImage(var Image: TImage);
procedure PutImage_Trans(var Image: TImage);
procedure GetImage(var Image: TImage);

{ prekreslovanie obrazovky }
procedure Refresh;
procedure ClearVirtual;

(*procedure FillMem(s, o: word; f: byte; c: word);
procedure CopyMem(_ss, _so, _ds, _do, c: word);*)

procedure WaitForRetrace;

var
  Opened: boolean;
  Farba: byte;
  Paleta: TPaleta;
  VGAerror: byte;
  vs: word; { segment virtualnej obrazovky - !!! nemenit !!! }
  refreshrate: word;

IMPLEMENTATION

uses DOS;

(*{$F+}
  procedure InitAsm(s: word); external;
  procedure TPutPixel(x, y: word; f: byte); external;
  function TGetPixel(x, y: word): byte; external;
  procedure THorizLine(x1, x2, y: word; f: byte); external;
  procedure TVertLine(x, y1, y2: word; f: byte); external;
  procedure TBar(x1, y1, x2, y2: word; f: byte); external;
  procedure FillMem(s, o: word; f: byte; c: word); external;
  procedure CopyMem(_ss, _so, _ds, _do, c: word); external;
  procedure TWaitForRetrace; external;
  {$L vga.obj}
{$F-}*)

type
  PVirtualVGA= ^TVirtualVGA;
  TVirtualVGA= array[0..199, 0..319] of byte;

var
  VirtualVGA: PVirtualVGA; { virtualna obrazovka }
  nrr, cas: word;

procedure OpenVGA;
var c, r, g, b: byte;
begin
  asm
    mov ax, 13h
    int 10h
  end;
  New(VirtualVGA);
  vs:= Seg(VirtualVGA^);
{  InitAsm(vs);}
  Farba:= 0;
  ClearVirtual;
  Farba:= 15;
  Opened:= true;
  VGAerror:= 0;
end;

procedure CloseVGA;
begin
  if not Opened then Exit;
  if VirtualVGA <> nil then
    Dispose(VirtualVGA);
  asm
    mov ax, 3
    int 10h
  end;
  VGAerror:= 255;
  Opened:= false;
end;

procedure SetColor(f: byte);
begin
  Farba:= f;
end;

function GetColor: byte;
begin
  GetColor:= Farba;
end;

procedure SetPal(R, G, B: byte; var p: TPalette);
begin
  p. R:= R;
  p. G:= G;
  p. B:= B;
end;

procedure GetPal(f: byte; var p: TPalette);
begin
  p. R:= Paleta[f]. R;
  p. G:= Paleta[f]. G;
  p. B:= Paleta[f]. B;
end;

procedure SetRGB(f: byte; p: TPalette);
begin
  Port[$3C8]:= f;
  Port[$3C9]:= p. R;
  Port[$3C9]:= p. G;
  Port[$3C9]:= p. B;
  Paleta[f]. R:= p. R;
  Paleta[f]. G:= p. G;
  Paleta[f]. B:= p. B;
end;

procedure GetRGB(f: byte; var p: TPalette);
begin
  Port[$3C7]:= f;
  p. R:= Port[$3C9];
  p. G:= Port[$3C9];
  p. B:= Port[$3C9];
end;

procedure PutPixel(x, y: integer; f: byte);
begin
  if Opened then
  if (x >= 0) and (y >= 0) and (x <= 319) and (y <= 199) then
  asm
    push bp
    mov ax, y
    mov bx, ax
    shl ax, 2  {}
    add ax, bx { ako * 320 }
    shl ax, 6  {}
    add ax, x
    mov di, ax
    mov ax, vs
    mov es, ax
    mov al, f
    stosb
    pop bp
  end;
end;

function GetPixel(x, y: integer): byte;
var p: byte;
begin
  GetPixel:= 0;
  if Opened then
  if (x >= 0) and (y >= 0) and (x <= 319) and (y <= 199) then
  begin
    asm
      push bp
      push ds
      mov ax, y
      mov bx, ax
      shl ax, 2  {}
      add ax, bx { ako * 320 }
      shl ax, 6  {}
      add ax, x
      mov si, ax
      mov ax, vs
      mov ds, ax
      lodsb
      mov p, al
      pop ds
      pop bp
    end;
    GetPixel:= p;
  end;
end;

function Priemer(x1, x2: byte): byte;
var p: byte;
begin
  p:= x1 + x2;
  p:= p shr 2;
  Priemer:= p;
end;

procedure Line(x1, y1, x2, y2: integer);
var k1, k2, p, x, y, a, b: integer;
begin
  if (x1 > x2) then
  begin
    a:= x2;
   x2:= x1;
   x1:= a;
    a:= y2;
   y2:= y1;
   y1:= a;
  end;
  if (x2 - x1) > (abs(y2 - y1)) then
  begin
    k1:= abs(2 * (y2 - y1));
    k2:= 2 * (abs(y2 - y1) - (x2 - x1));
    p:= 2 * (abs(y2 - y1)) - (x2 - x1);
    x:= x1;
    y:= y1;
    PutPixel(x, y, Farba);
    if y1 < y2 then
    begin
      while x <= x2 do
      begin
        inc(x);
        if p >= 0 then
        begin
          inc(y);
          inc(p, k2);
        end else inc(p, k1);
        PutPixel(x, y, Farba);
      end;
    end else
    begin
      while x <= x2 do
      begin
        inc(x);
        if p >= 0 then
        begin
          dec(y);
          inc(p, k2);
          end else inc(p, k1);
          PutPixel(x, y, Farba);
        end;
      end;
    end else begin
    if (y1 > y2) then
    begin
      a:= x2;
     x2:= x1;
     x1:= a;
      a:= y2;
     y2:= y1;
     y1:= a;
    end;
    k1:= abs(2 * (x2 - x1));
    k2:= 2 * (abs(x2 - x1) - (y2 - y1));
    p:= 2 * (abs(x2 - x1)) - (y2 - y1);
    x:= x1;
    y:= y1;
    PutPixel(x, y, Farba);
    if x1 < x2 then
    begin
      while y <= y2 do
      begin
        inc(y);
        if p <= 0 then
        begin
          inc(x);
          dec(p, k2);
        end else dec(p, k1);
        PutPixel(x, y, Farba);
      end;
    end else begin
    while y <= y2 do
    begin
      inc(y);
      if p <= 0 then
      begin
        dec(x);
        dec(p, k2);
        end else dec(p, k1);
        PutPixel(x, y, Farba);
      end;
    end;
  end;
end;

procedure Circle(xs, ys, r: integer);
var dvex, dvey, p, x, y: integer;
begin
  dvex:= 3;
  dvey:= 2 * r -2;
  p:= 1 - r;
  x:= 0;
  y:= r;
  while x <= y do
  begin
    PutPixel(-y + xs, x + ys, Farba); {1}
    PutPixel(-y + xs, -x + ys, Farba); {2}
    PutPixel(-x + xs, -y + ys, Farba); {3}
    PutPixel(x + xs, -y + ys, Farba); {4}
    PutPixel(y + xs, x + ys, Farba); {5}
    PutPixel(y + xs, -x +ys, Farba); {6}
    PutPixel(x + xs, y + ys, Farba); {7}
    PutPixel(-x + xs, y + ys, Farba); {8}
    if p >= 0 then begin
      dec(p, dvey);
      dec(dvey, 2);
      dec(y);
    end;
    inc(p, dvex);
    inc(dvex, 2);
    inc(x);
  end;
end;

procedure HorizLine(x1, x2, y: integer);
begin
  if Opened then
  if (x1 <= x2) then
  if (x1 <= 319) then
  if (x2 >= 0) then
  begin
    if x1 < 0 then x1:= 0;
    if x2 > 319 then x2:= 319;
    asm
      push bp
      mov ax, y
      mov bx, 320
      mul bx
      add ax, x1
      mov di, ax
      mov cx, x2
      mov bx, x1
      sub cx, bx
      inc cx
      mov ax, vs
      mov es, ax
      mov al, Farba
      rep stosb
      pop bp
    end;
  end;
end;

procedure VertLine(x, y1, y2: integer);
begin
  if Opened then
  if (y1 <= y2) then
  if (y1 <= 199) then
  if (y2 >= 0) then
  begin
    if y2 > 199 then y2:= 199;
    if y1 < 0 then y1:= 0;
    asm
      push bp
      mov ax, y1
      mov bx, 320
      mul bx
      add ax, x
      mov di, ax
      mov cx, y2
      sub cx, y1
      inc cx
      mov ax, vs
      mov es, ax
      mov al, Farba
      sub di, 319
    @v1: add di, 319
      stosb
      loop @v1
      pop bp
    end;
  end;
end;

procedure RectAngle(x1, y1, x2, y2: integer);
var p: integer;
begin
  if (x1 <= x2) and (y1 <= y2) then
  if (x1 <= 319) and (y1 <= 199) then
  if (x2 >= 0) and (y2 >= 0) then
  begin
    if x2 > 319 then x2:= 319;
    if x1 < 0 then x1:= 0;
    if y2 > 199 then y2:= 199;
    if y1 < 0 then y1:= 0;
    for p:= y1 to y2 do
    begin
      PutPixel(x1, p, Farba);
      PutPixel(x2, p, Farba);
    end;
    for p:= x1 to x2 do
    begin
      PutPixel(p, y1, Farba);
      PutPixel(p, y2, Farba);
    end;
{    TVertLine(x1, y1, y2, Farba);
    TVertLine(x2, y1, y2, Farba);
    THorizLine(x1, x2, y1, Farba);
    THorizLine(x1, x2, y2, Farba);}
  end;
end;

procedure Bar(x1, y1, x2, y2: integer);
var pom: integer;
begin
  if (x1 <= x2) and (y1 <= y2) then
  if (x1 <= 319) and (y1 <= 199) then
  if (x2 >= 0) and (y1 >= 0) then
  begin
    if x2 > 319 then x2:= 319;
    if x1 < 0 then x1:= 0;
    if y2 > 199 then y2:= 199;
    if y1 < 0 then y1:= 0;
    asm
      push bp
      mov ax, y1
      mov bx, 320
      mul bx
      mov bx, x1
      add ax, bx
      inc ax
      mov di, ax      { v di je offset }
      mov cx, x2
      sub cx, bx
      inc cx
      mov pom, cx     { v pom je sirka }
      mov bx, 320
      sub bx, cx
      inc bx          { v bx je rozdiel }
      mov cx, y2
      sub cx, y1
      inc cx          { v cx je vyska }
      mov ax, vs
      mov es, ax      { v es je segment }
      mov al, Farba
      sub di, bx
 @b1: add di, bx
      dec di
      push cx
      mov cx, pom
      rep stosb
      pop cx
      loop @b1
      pop bp
    end;
  end;
end;

function Priamka(a1, a2, b1, b2, y: integer): integer;
var
  u1, u2: integer;
  x: longint;
begin
  u1:= b1 - a1;
  u2:= b2 - a2;
  x:= y - a2;
  if u2 = 0 then
  begin
    Priamka:= a1;
    Exit;
  end;
  x:= x * u1;
  x:= x div u2;
  x:= x + a1;
  Priamka:= x;
end;

procedure Polygon3(x1, y1, x2, y2, x3, y3: integer);
var
  ymin, ymax: integer;
  y, v1, v2, v: integer;
  prva: boolean;
begin
  { prvy bod }
  ymin:= y1;
  ymax:= y1;
  { druhy bod }
  if y2 < ymin then ymin:= y2;
  if ymax < y2 then ymax:= y2;
  { treti bod }
  if y3 < ymin then ymin:= y3;
  if ymax < y3 then ymax:= y3;

  for y:= ymin to ymax do
  begin
    prva:= false;
    { prva usecka }
    if (y1 <= y) and (y <= y2) or
       (y2 <= y) and (y <= y1) then
    begin
      v1:= Priamka(x1, y1, x2, y2, y);
      v2:= v1;
      prva:= true;
    end;
    { druha usecka }
    if (y2 <= y) and (y <= y3) or
       (y3 <= y) and (y <= y2) then
    if not Prva then
    begin
      v1:= Priamka(x2, y2, x3, y3, y);
      v2:= v1;
      prva:= true;
    end else
    begin
      v:= Priamka(x2, y2, x3, y3, y);
      if v < v1 then v1:= v;
      if v2 < v then v2:= v;
    end;
    { tretia usecka }
    if (y3 <= y) and (y <= y1) or
       (y1 <= y) and (y <= y3) then
    if not Prva then
    begin
      v1:= Priamka(x3, y3, x1, y1, y);
      v2:= v1;
      prva:= true;
    end else
    begin
      v:= Priamka(x3, y3, x1, y1, y);
      if v < v1 then v1:= v;
      if v2 < v then v2:= v;
    end;

    HorizLine(v1, v2, y);
  end;
end;

procedure ImageSize(var Image: TImage);
var l: longint;
begin
  with Image do
  begin
    l:= (dx +1) * (dy +1);
    Inc(l, 4);
    if l < 65535 then
    begin
      Able:= true;
      Size:= l;
      GetMem(BitMap, Size);
    end else
      Able:= false;
  end;
end;

procedure PutImage(var Image: TImage);
var
  p, s, o, i: word;
  p_sirka, p_vyska, p_rozdiel: word;
  x1, y1, x, y: integer;
  dx, dy, px, py: word;
begin
  if not Image. Able then Exit;
  s:= Seg(Image. BitMap^);
  o:= Ofs(Image. BitMap^);
  x1:= Image. x1;
  y1:= Image. y1;
  dx:= Image. dx;
  dy:= Image. dy;
  y:= y1 -1;
  for py:= 0 to dy do
  begin
    Inc(y);
    p:= y * 320 + x1 -1;
    i:= py * (dx +1) -1;
    x:= x1 -1;
    for px:= 0 to dx do
    begin
      Inc(x);
      Inc(i);
      Inc(p);
      if (x >= 0) and (x <= 319) and (y >= 0) and (y <= 199) then
        Mem[vs: p]:= Mem[s: o +i];
    end;
  end;
end;

procedure PutImage_Trans(var Image: TImage);
var
  p, s, o, i: word;
  p_sirka, p_vyska, p_rozdiel: word;
  x1, y1, x, y: integer;
  dx, dy, px, py: word;
begin
  if not Image. Able then Exit;
  s:= Seg(Image. BitMap^);
  o:= Ofs(Image. BitMap^);
  x1:= Image. x1;
  y1:= Image. y1;
  dx:= Image. dx;
  dy:= Image. dy;
  y:= y1 -1;
  for py:= 0 to dy do
  begin
    Inc(y);
    p:= y * 320 + x1 -1;
    i:= py * (dx +1) -1;
    x:= x1 -1;
    for px:= 0 to dx do
    begin
      Inc(x);
      Inc(i);
      Inc(p);
      if (x >= 0) and (x <= 319) and (y >= 0) and (y <= 199) then
      if Mem[s: o +i] <> Image. Trans then
        Mem[vs: p]:= Mem[s: o +i];
    end;
  end;
end;

procedure GetImage(var Image: TImage);
var
  s, o, i, p: word;
  g_sirka, g_vyska, g_rozdiel: word;
  x1, y1, x, y: integer;
  dx, dy, px, py: word;
begin
  if not Image. Able then Exit;
  s:= Seg(Image. BitMap^);
  o:= Ofs(Image. BitMap^);
  x1:= Image. x1;
  y1:= Image. y1;
  dx:= Image. dx;
  dy:= Image. dy;
  y:= y1 -1;
  for py:= 0 to dy do
  begin
    Inc(y);
    p:= y * 320 + x1 -1;
    i:= py * (dx +1) -1;
    x:= x1 -1;
    for px:= 0 to dx do
    begin
      Inc(x);
      Inc(i);
      Inc(p);
      if (x >= 0) and (x <= 319) and (y >= 0) and (y <= 199) then
        Mem[s: o +i]:= Mem[vs: p]
      else Mem[s: o +i]:= 0;
    end;
  end;
end;

{ presun dat }

procedure Refresh;
var ncas, pom: word;
begin
  if Opened then
    Move(VirtualVGA^, Mem[$A000: 0], 64000);
  Inc(nrr);
  GetTime(pom, pom, ncas, pom);
  if ncas <> cas then
  begin
    refreshrate:= nrr;
    cas:= ncas;
    nrr:= 0;
  end;
end;

procedure ClearVirtual;
begin
  if Opened then
    FillChar(VirtualVGA^, 64000, Farba);
end;

procedure WaitForRetrace;
begin
{  TWaitForRetrace;}
  asm
    push bp
    mov dx, 3DAh
@w1: in al, dx
    and al, 08h
    jnz @w1
@w2: in  al, dx
    and al, 08h
    jz @w2
    pop bp
  end;
end;

BEGIN
  VGAerror:= 255;
  GetTime(nrr, nrr, cas, nrr);
  nrr:= 0;
END.