program Test;

uses Crt, Draw2D, Draw3D, Pismo{, XMS};

{$define deca } { deca, deca2, cube, bar, tri, hiro }

const
{$ifdef deca}
  vpoly=1; { first poly to draw from }
  bodov=12; { number of points }
  polys=8; { number of planes }
  points:array[1..bodov] of TPoint=(
    (-20,-20, 30),( 20,-20, 30),( 40,-40,  0),( 20,-20,-30),
    (-20,-20,-30),(-40,-40,  0),(-20, 20, 30),( 20, 20, 30),
    ( 40, 40,  0),( 20, 20,-30),(-20, 20,-30),(-40, 40,  0));
  planes:array[1..polys] of TPlane=(
    (2,3,9,8),(10,9,3,4),(11,5,6,12),(7,12,6,1),
    (1,2,3,6),(6,3,4,5),(7,8,9,12),(12,9,10,11));
{$endif}

{$ifdef deca2}
  vpoly=6; { first poly to draw from }
  bodov=12; { number of points }
  polys=10; { number of planes }
  points:array[1..bodov] of TPoint=(
    (-15,-15, 30),( 15,-15, 30),( 40,-40,  0),( 15,-15,-30),
    (-15,-15,-30),(-40,-40,  0),(-15, 15, 30),( 15, 15, 30),
    ( 40, 40,  0),( 15, 15,-30),(-15, 15,-30),(-40, 40,  0));
  planes:array[1..polys] of TPlane=(
    (1,2,8,7),(2,3,9,8),(10,9,3,4),(11,10,4,5),(11,5,6,12),
    (7,12,6,1),(1,2,3,6),(6,3,4,5),(7,8,9,12),(12,9,10,11));
{$endif}

{$ifdef cube}
  s=45;
  vpoly=4;
  bodov=8;
  polys=6;
  points:array[1..bodov] of TPoint=(
    (-s,-s,-s),(-s,-s, s),( s,-s, s),( s,-s,-s),
    (-s, s,-s),(-s, s, s),( s, s, s),( s, s,-s));
  planes:array[1..polys] of TPlane=(
    (1,5,6,2),(1,4,8,5),(1,2,3,4),(5,6,7,8),(8,7,3,4),(2,3,7,6));
{$endif}

{$ifdef bar}
  vpoly=3;
  bodov=8;
  polys=6;
  points:array[1..bodov] of TPoint=(
    (-20,-40, 20),( 20,-40, 20),( 20,-40,-20),(-20,-40,-20),
    (-20, 40, 20),( 20, 40, 20),( 20, 40,-20),(-20, 40,-20));
  planes:array[1..polys] of TPlane=(
    (1,5,6,2),(1,4,8,5),(1,2,3,4),(5,6,7,8),(8,7,3,4),(2,3,7,6));
{$endif}

{$ifdef tri}
  vpoly=2;
  bodov=8;
  polys=6;
  points:array[1..bodov] of TPoint=(
    (-50,-50,-20),(-10,-10, 20),( 10,-10, 20),( 50,-50,-20),
    (-50, 50,-20),(-10, 10, 20),( 10, 10, 20),( 50, 50,-20));
  planes:array[1..polys] of TPlane=(
    (1,5,6,2),(1,4,8,5),(1,2,3,4),(5,6,7,8),(8,7,3,4),(2,3,7,6));
{$endif}

{$ifdef hiro}
  vpoly=1;
  bodov=44;
  polys=13;
  points:array[1..bodov] of TPoint=(
    (-65,-25,  0),(-55,-25,  0),(-65, 25,  0),(-55, 25,  0), { H }
    (-35,-25,  0),(-25,-25,  0),(-35, 25,  0),(-25, 25,  0), { H }
    (-55, -5,  0),(-35, -5,  0),(-55,  5,  0),(-35,  5,  0), { H }
    (-15,-25,  0),( -5,-25,  0),(-15, 25,  0),( -5, 25,  0), { I }
    (  5,-25,  0),( 15,-25,  0),(  5, 25,  0),( 15, 25,  0), { R }
    ( 15,-15,  0),( 25,-15,  0),( 15, -5,  0),( 25, -5,  0), { R }
    ( 25,-25,  0),( 25,  5,  0),( 35,-15,  0),( 35, -5,  0), { R }
    ( 15,  5,  0),( 15, 15,  0),( 25, 25,  0),( 35, 25,  0), { R }
    ( 55,-25,  0),( 75,-25,  0),( 45,-15,  0),( 85,-15,  0), { O }
    ( 45, 15,  0),( 85, 15,  0),( 55, 25,  0),( 75, 25,  0), { O }
    ( 55,-15,  0),( 75,-15,  0),( 55, 15,  0),( 75, 15,  0));{ O }
  planes:array[1..polys] of TPlane=(
    ( 1, 2, 4, 3),( 5, 6, 8, 7),( 9,10,12,11),(13,14,16,15), { H I }
    (17,18,20,19),(18,25,27,21),(23,28,26,29),(22,27,28,24), { R }
    (26,32,31,29),(33,34,36,35),(37,38,40,39),(35,41,43,37), { R O }
    (42,36,38,44));                                          { O }
{$endif}

var
  points2: array[1..bodov] of TPoint;
  point: TPoint;
  i, o: byte;
  rx, ry, rz: integer;
  z: char;
  auto{, vretrace}: boolean;
  p: TPalette;

procedure VypisRychlost;
var s: string;
begin
  Str(refreshrate, s);
  VypisXYF(0, 0, 255, 'Refresh rate: ' + s);
end;

BEGIN
  OpenVGA;
  if not Opened then Halt;
  sx:= MaxX div 2;
  sy:= MaxY div 2;
  svx:= 0;
  svy:= 0;
  svz:= 250;
  vz:= 250;
  rx:= 0;
  ry:= 0;
  rz:= 0;
  auto:= true;
{  vretrace:= true;}
  for i:= 0 to 255 do
  begin
    p. r:= 0;
    p. g:= 15 * i div 255;
    p. b:= 63 * i div 255;
    SetRGB(i, p);
  end;
{  for i:= 1 to bodov do
    expand(points[i], points[i], 2);}
(*  InitKocka(100, points1[1], points1[2], points1[3], points1[4],
                points1[5], points1[6], points1[7], points1[8],
                planes[1], planes[2], planes[3], planes[4], planes[5], planes[6]);*)
  InitPismo;
  LoadPismo(2);
  repeat
    z:= #0;
    if KeyPressed then z:= ReadKey;
    if UpCase(z) = 'A' then auto:= not auto;
{    if UpCase(z) = 'V' then vretrace:= not vretrace;}
    if not auto then
    begin
      if z = #72 then Inc(rx, 5);
      if z = #80 then Dec(rx, 5);
      if z = #77 then Inc(ry, 5);
      if z = #75 then Dec(ry, 5);
    end else
    begin
      inc(rx, -2);
      inc(ry,  2);
      inc(rz, -2);
    end;
    if rx >= 360 then rx:= rx - 360;
    if rx < 0 then rx:= rx + 360;
    if ry >= 360 then ry:= ry - 360;
    if ry < 0 then rz:= rz + 360;
    if rz >= 360 then rz:= rz - 360;
    if rz < 0 then ry:= ry + 360;
    for i:= 1 to bodov do
    begin
      rotateX(points[i], points2[i], rx);
      rotateY(points2[i], point, ry);
      rotateZ(point, points2[i], rz);
    end;
    for i:= 1 to polys do begin
      hlbka[i]:= points2[planes[i, 0], 2] + points2[planes[i, 1], 2]
                 + points2[planes[i, 2], 2] + points2[planes[i, 3], 2];
      poradie[i]:= i;
    end;
    usporiadaj(polys);
    setColor(0);
    ClearVirtual;
    for i:= vpoly to polys do
      Polygon4(points2[planes[poradie[i], 0]], points2[planes[poradie[i], 1]],
               points2[planes[poradie[i], 2]], points2[planes[poradie[i], 3]]);
    WaitForRetrace;
    VypisRychlost;
    Refresh;
  until z= #27;
  DonePismo;
  CloseVGA;
END.