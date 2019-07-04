unit Pismo;

INTERFACE

uses Draw2D;

type
  PZnaky= ^TZnaky;
  TZnaky= array[0..255, 0..19, 0..9] of byte;

  TPismena=record
    Nazov: string[15];
    Vyska: byte;
    Znaky: PZnaky;
    Rozmery: array[0..255] of byte;
    Active: boolean;
  end;

procedure InitPismo;
procedure LoadPismo(tp: byte);
procedure Vypis(retazec: string);
procedure VypisXY(x, y: word; retazec: string);
procedure VypisXYF(x, y: word; f: byte; retazec: string);
function ZistiSirku(retazec: string): word;
procedure ChodXY(x, y: word);
procedure DonePismo;

var
  Znaky: TPismena;

IMPLEMENTATION

var
  Inited: boolean;
  pismox, pismoy: word;

procedure InitPismo;
begin
  New(Znaky. Znaky);
  with Znaky do
  begin
    FillChar(znaky^, SizeOf(znaky^), 0);
    FillChar(rozmery, SizeOf(rozmery), 0);
    Active:= false;
  end;
  Inited:= true;
end;

procedure LoadPismo(tp: byte);
var
  subor: text;
  s: string;
  z, i, p: word;
label 1;
begin
  if not Inited then Exit;
  Str(tp, s);
  Assign(subor, 'ufx' + s + '.chr');
  {$I-}
    Reset(subor);
  {$I+}
  if IOResult <> 0 then Exit;
{ cistenie pola}
  Znaky. Active:= false;
  with Znaky do
  begin
    FillChar(znaky^, SizeOf(znaky^), 0);
    FillChar(rozmery, SizeOf(rozmery), 0);
  end;
{ vynechavanie ; }
  Readln(subor, s);
  while (s[1] = ';') or (s = '') do
  begin
    if (s = '') and (Eof(subor)) then
    begin
      Close(Subor);
      Exit;
    end;
    Readln(subor ,s);
  end;
{ nazov pisma}
  Znaky. nazov:= s;
{ vynechavanie ; }
  Readln(subor, s);
  while (s[1] = ';') or (s = '') do
  begin
    if (s = '') and (Eof(subor)) then
    begin
      Close(Subor);
      Exit;
    end;
    Readln(subor ,s);
  end;
{ vyska pisma}
  Val(s, i, p);
  if p <> 0 then
  begin
    Close(Subor);
    Exit;
  end;
  Znaky. vyska:= i;
{ citanie znakov }
  repeat
    Readln(subor, s);
    if s= ';koniec' then GoTo 1;
  { vynechavanie ; }
    while (s[1]= ';') or (s= '') do
    begin
      if (s = '') and (Eof(subor)) then
      begin
        Close(Subor);
        Exit;
      end;
      Readln(subor, s);
    end;
  { znak #x }
    z:= Ord(s[1]);
  { vynechavanie ; }
    Readln(subor, s);
    while (s[1] = ';') or (s = '') do
    begin
      if (s = '') and (Eof(subor)) then
      begin
        Close(Subor);
        Exit;
      end;
      Readln(subor, s);
    end;
  { sirka pisma }
    Val(s, i, p);
    if p <> 0 then
    begin
      Close(Subor);
      Exit;
    end;
    Znaky. rozmery[z]:= i;
  { citanie do premennych }
    for p:= 0 to Znaky. vyska -1 do
    begin
      Readln(subor, s);
      while (s[1] = ';') or (s = '') do
      begin
        if (s = '') and (Eof(subor)) then
        begin
          Close(Subor);
          Exit;
        end;
        Readln(subor, s);
      end;
    { skuska, ci je s rovnake ako sirka }
      if Length(s) < Znaky. rozmery[z] then
      begin
        Close(Subor);
        Exit;
      end;
    { citanie => premenne }
      for i:= 1 to Znaky. rozmery[z] do
        if s[i]= '1' then
          Znaky. znaky^[z, p, i -1]:= 1
        else Znaky. znaky^[z, p, i -1]:= 0;
    end;
  until Eof(subor);
1:Close(subor);
  pismox:= 0;
  pismoy:= 0;
  Znaky. Active:= true;
end;

procedure Vypis(retazec: string);
var
  znak: byte;
  xpos, ypos, i: word;
  posx, posy: word;
begin
  if (not Znaky. Active) or (retazec = '') then Exit;
  if Znaky. Nazov = 'Male' then
  begin
    Znaky. rozmery[110]:= 5;
    Znaky. rozmery[111]:= 5;
  end;
  for i:= 1 to Length(retazec) do
  begin
    znak:= Ord(retazec[i]);
    if Znaky. rozmery[znak] = 0 then
      continue;
    for xpos:= 0 to Znaky. rozmery[znak] -1 do
    begin
      for ypos:= 0 to Znaky. vyska -1 do
      begin
        posx:= pismox + xpos;
        posy:= pismoy + ypos;
        if Znaky. znaky^[znak, ypos, xpos]= 1 then
          PutPixel(posx, posy, Farba);
      end;
    end;
    Inc(pismox, Znaky. rozmery[znak] +2);
  end;
end;

procedure VypisXY(x, y: word; retazec: string);
begin
  if not Znaky. Active then Exit;
  ChodXY(x, y);
  Vypis(retazec);
end;

procedure VypisXYF(x, y: word; f: byte; retazec: string);
begin
  if not Znaky. Active then Exit;
  ChodXY(x, y);
  Farba:= f;
  Vypis(retazec);
end;

function ZistiSirku(retazec: string): word;
var p, i: word;
begin
  if not Znaky. Active then Exit;
  if retazec= '' then
  begin
    ZistiSirku:= 0;
    Exit;
  end;
  p:= 0;
  for i:= 1 to Length(retazec) do
    Inc(p, Znaky. rozmery[Ord(retazec[i])] +2);
  Dec(p, 2);
  ZistiSirku:= p;
end;

procedure ChodXY(x, y: word);
begin
  if not Znaky. Active then Exit;
  pismox:= x;
  pismoy:= y;
end;

procedure DonePismo;
begin
  if Inited then
  begin
    Dispose(Znaky. Znaky);
    Znaky. Active:= false;
  end;
end;

BEGIN
  Inited:= false;
  Znaky. Active:= false;
END.