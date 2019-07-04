unit Draw3D;

INTERFACE

uses Draw2D;

type
  TPoint= array[0..2] of integer;
  TPlane= array[0..3] of byte;

var
{ stred vscr }
  sx, sy: integer;
{ svetlo }
  svx, svy, svz: real;
{ perspektiva }
  vz: integer;
{ objekt }
  poradie: array[1..255] of byte;
  hlbka: array[1..255] of integer;

procedure usporiadaj(pocet: byte);

procedure move(var p1, p2: TPoint; sx, sy, sz: integer);
procedure expand(var p1, p2: TPoint; k: real);
procedure rotateX(var p1, p2: TPoint; a: integer);
procedure rotateY(var p1, p2: TPoint; a: integer);
procedure rotateZ(var p1, p2: TPoint; a: integer);

function conv3dto2d(var nx, ny: integer; px, py, pz: integer): boolean;

procedure polygon4(p1, p2, p3, p4: TPoint);

(*procedure initKocka(a: byte; var b1, b2, b3, b4, b5, b6, b7, b8: TPoint;
                             var p1, p2, p3, p4, p5, p6: TPlane);*)

IMPLEMENTATION

procedure swapi(var a, b: integer);
var c: integer;
begin
  c:= a;
  a:= b;
  b:= c;
end;

procedure swapb(var a, b: byte);
var c: byte;
begin
  c:= a;
  a:= b;
  b:= c;
end;

procedure usporiadaj(pocet: byte);
var i, o: byte;
begin
  for i:= 1 to pocet do
  for o:= i to pocet do
  begin
    if hlbka[o] < hlbka[i] then
    begin
      swapi(hlbka[o], hlbka[i]);
      swapb(poradie[o], poradie[i])
    end;
  end;
end;

procedure move(var p1, p2: TPoint; sx, sy, sz: integer);
begin
  p2[0]:= p1[0] + sx;
  p2[1]:= p1[1] + sy;
  p2[2]:= p1[2] + sz;
end;

procedure expand(var p1, p2: TPoint; k: real);
begin
  p2[0]:= Round(p1[0] * k);
  p2[1]:= Round(p1[1] * k);
  p2[2]:= Round(p1[2] * k);
end;

procedure rotateX(var p1, p2: TPoint; a: integer);
var
  c, s: real;
begin
  s:= Sin ((a * Pi) / 180);
  c:= Cos ((a * Pi) / 180);
  p2[0]:= p1[0];
  p2[1]:= Round((p1[1] * c) - (p1[2] * s));
  p2[2]:= Round((p1[1] * s) + (p1[2] * c));
end;

procedure rotateY(var p1, p2: TPoint; a: integer);
var
  c, s: real;
begin
  s:= Sin ((a * Pi) / 180);
  c:= Cos ((a * Pi) / 180);
  p2[0]:= Round((p1[0] * c) + (p1[2] * s));
  p2[1]:= p1[1];
  p2[2]:= Round((- p1[0] * s) + (p1[2] * c));
end;

procedure rotateZ(var p1, p2: TPoint; a: integer);
var
  c, s: real;
begin
  s:= Sin ((a * Pi) / 180);
  c:= Cos ((a * Pi) / 180);
  p2[0]:= Round((p1[0] * c) - (p1[1] * s));
  p2[1]:= Round((p1[0] * s) + (p1[1] * c));
  p2[2]:= p1[2];
end;

function conv3dto2d(var nx, ny: integer; px, py, pz: integer): boolean;
var
  p, _x, _y: integer;
begin
  p:= vz - pz;
  if p < 0 then conv3dto2d:= false
    else conv3dto2d:= true;
  p:= Abs(p);
  if p = 0 then
  begin
    nx:= px;
    ny:= py;
    Exit;
  end;
  nx:= Round(px * vz / p);
  ny:= Round(py * vz / p);
{  asm
    mov ax, vz
    mov bx, pz
    sub ax, bx
    mov p, ax
    cmp ax, 0
    je @1
    jg @2
    neg ax
    mov p, ax
@2: mov ax, px
    mov bx, vz
    imul bx
    mov bx, p
    idiv bx
    mov _x, ax
    mov ax, py
    mov bx, vz
    imul bx
    mov bx, p
    idiv bx
    mov _y, ax
    jmp @done
@1: mov _x, nx
    mov _y, ny
@done:
  end;
  nx:= _x;
  ny:= _y;}
end;

function priamka(a1, a2, b1, b2, y: integer): integer;
var
  u1, u2: integer;
  x: longint;
begin
  u1:= b1 - a1;
  u2:= b2 - a2;
  x:= y - a2;
  if u2 = 0 then
  begin
    priamka:= a1;
    Exit;
  end;
  x:= x * u1;
  x:= x div u2;
  x:= x + a1;
  priamka:= x;
end;

procedure findY(x1, y1, x2, y2, x3, y3, x4, y4: integer; var ymin, ymax: integer);
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
  { stvrty bod }
  if y4 < ymin then ymin:= y4;
  if ymax < y4 then ymax:= y4;
end;

procedure findX(x1, y1, x2, y2, x3, y3, x4, y4, y: integer; var v1, v2: integer);
var
  prva: boolean;
  v: integer;
begin
  prva:= false;
  { prva usecka }
  if (y1 <= y) and (y <= y2) or
     (y2 <= y) and (y <= y1) then
  begin
    v1:= priamka(x1, y1, x2, y2, y);
    v2:= v1;
    prva:= true;
  end;
  { druha usecka }
  if (y2 <= y) and (y <= y3) or
     (y3 <= y) and (y <= y2) then
  if not prva then
  begin
    v1:= priamka(x2, y2, x3, y3, y);
    v2:= v1;
    prva:= true;
  end else
  begin
    v:= priamka(x2, y2, x3, y3, y);
    if v < v1 then v1:= v;
    if v2 < v then v2:= v;
  end;
  { tretia usecka }
  if (y3 <= y) and (y <= y4) or
     (y4 <= y) and (y <= y3) then
  if not prva then
  begin
    v1:= priamka(x3, y3, x4, y4, y);
    v2:= v1;
    prva:= true;
  end else
  begin
    v:= priamka(x3, y3, x4, y4, y);
    if v < v1 then v1:= v;
    if v2 < v then v2:= v;
  end;
  { stvrta usecka }
  if (y4 <= y) and (y <= y1) or
     (y1 <= y) and (y <= y4) then
  if not prva then
  begin
    v1:= priamka(x4, y4, x1, y1, y);
    v2:= v1;
    prva:= true;
  end else
  begin
    v:= priamka(x4, y4, x1, y1, y);
    if v < v1 then v1:= v;
    if v2 < v then v2:= v;
  end;
end;

procedure polygon4(p1, p2, p3, p4: TPoint);
var
  x1, y1, x2, y2, x3, y3, x4, y4: integer;
  ymin, ymax, y: integer;
  v1, v2, v: integer;
  u1, u2, u3, r1, r2, r3, w1, w2, w3: real;
  c, m1, m2: real;
  nf: byte;
begin
  if not (conv3dto2d(x1, y1, p1[0], p1[1], p1[2]) and
          conv3dto2d(x2, y2, p2[0], p2[1], p2[2]) and
          conv3dto2d(x3, y3, p3[0], p3[1], p3[2]) and
          conv3dto2d(x4, y4, p4[0], p4[1], p4[2])) then
    Exit;
  u1:= p2[0] - p1[0];
  u2:= p2[1] - p1[1];
  u3:= p2[2] - p1[2];
  r1:= p4[0] - p1[0];
  r2:= p4[1] - p1[1];
  r3:= p4[2] - p1[2];
  w1:= u2 * r3 - r2 * u3;
  w2:= u3 * r1 - r3 * u1;
  w3:= u1 * r2 - r1 * u2;

  c:= w1 * svx + w2 * svy + w3 * svz;
  c:= abs(c);
  m1:= sqr(w1) + sqr(w2) + sqr(w3);
  m2:= sqr(svx) + sqr(svy) + sqr(svz);
  m1:= sqrt(m1);
  m2:= sqrt(m2);
  if (m1 = 0) or (m2 = 0) then
    c:= 0
  else c:= c / (m1 * m2);
  c:= sqrt(c);
  nf:= round(c * 255);
{  if nf = 0 then Exit;}

  findY(x1, y1, x2, y2, x3, y3, x4, y4, ymin, ymax);

  if ymin + sy < 0 then
  begin
    y:= -sy;
    if y > ymax then Exit;
  end else
    y:= ymin;

  repeat
    if y + sy > MaxY then Exit;
    findX(x1, y1, x2, y2, x3, y3, x4, y4, y, v1, v2);

    setColor(nf);
    HorizLine(v1 +sx, v2 +sx, y +sy);
    Inc(y);
  until y > ymax;
end;

BEGIN
  sx:= 160;
  sy:= 100;
  svx:= 0;
  svy:= 0;
  svz:= 250;
  vz:= 250;
END.