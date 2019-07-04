unit Mouse;

INTERFACE

procedure ResetMouse;
procedure Show;
procedure Hide;
procedure Query;
procedure MoveMouse(nx, ny: word);
function GetX: word;
function GetY: word;
function IsVisible: boolean;

var
  Inited: boolean;
  Buttons: word;
  Left, Middle, Right: boolean;

IMPLEMENTATION

var
  Visible: boolean;
  x, y: word;

procedure ResetMouse;
var p: word;
begin
  asm
    mov ax, 0
    int 33h
    mov p, ax
    mov Buttons, bx
  end;
  Inited:= p <> 0;
  Visible:= false;
  Left:= false; Middle:= false; Right:= false;
end;

procedure Show;
begin
  Visible:= true;
end;

procedure Hide;
begin
  Visible:= false;
end;

procedure Query;
var p: word;
begin
  if not Inited then Exit;
  asm
    mov ax, 3
    int 33h
    mov p, bx
    mov x, cx
    mov y, dx
  end;
  Left:= (p AND 1) <> 0;
  Right:= (p AND 2) <> 0;
  Middle:= (p AND 4) <> 0;
end;

procedure MoveMouse(nx, ny: word);
begin
  if not Inited then Exit;
  x:= nx; y:= ny;
  asm
    mov ax, 4
    mov cx, nx
    mov dx, ny
    int 33h
  end;
end;

function GetX: word;
begin
  GetX:= x;
end;

function GetY: word;
begin
  GetY:= y;
end;

function IsVisible: boolean;
begin
  IsVisible:= Visible;
end;

BEGIN
  Inited:= false;
END.