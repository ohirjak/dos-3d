.model TPASCAL
.code
.386p

assume cs: code, ds: code

public InitAsm, THorizLine, TVertLine, TBar
public FillMem, CopyMem, TWaitForRetrace

InitAsm proc far
arg @@s: word

  push bp
  mov ax, [@@s]
  mov [vs], ax
  mov es, ax
  mov edi, 0
  mov eax, 0
  mov ecx, 16000
  rep stosd
  pop bp
  ret

InitAsm endp

THorizLine proc far
arg @@x1, @@x2, @@y: word, @@f: byte

  push bp
  mov ax, [@@y]
  mov bx, 320
  mul bx
  add ax, [@@x1]
  mov di, ax
  mov cx, [@@x2]
  sub cx, [@@x1]
  inc cx
  mov ax, [vs]
  mov es, ax
  mov al, [@@f]
  rep stosb
  pop bp
  ret

THorizLine endp

TVertLine proc far
arg @@x, @@y1, @@y2: word, @@f: byte

  push bp
  mov ax, [@@y1]
  mov bx, 320
  mul bx
  add ax, [@@x]
  mov di, ax
  mov cx, [@@y2]
  sub cx, [@@y1]
  inc cx
  mov ax, [vs]
  mov es, ax
  mov al, [@@f]
  sub di, 319
@v1: add di, 319
  stosb
  loop @v1
  pop bp
  ret

TVertLine endp

TBar proc far
arg @@x1, @@y1, @@x2, @@y2: word, @@f: byte

  push bp
  mov ax, [@@y1]
  mov bx, 320
  mul bx
  mov bx, [@@x1]
  add ax, bx
  inc ax
  mov di, ax      ; v di je offset
  mov cx, [@@x2]
  sub cx, bx
  inc cx
  mov [pom], cx   ; v pom je sirka
  mov bx, 320
  sub bx, cx
  inc bx          ; v bx je rozdiel
  mov cx, [@@y2]
  sub cx, [@@y1]
  inc cx          ; v cx je vyska
  mov ax, [vs]
  mov es, ax      ; v es je segment
  mov al, [@@f]
  sub di, bx
@b1: add di, bx
  dec di
  push cx
  mov cx, [pom]
  rep stosb
  pop cx
  loop @b1
  pop bp
  ret

pom dw (?)

TBar endp

FillMem proc far
arg @@s, @@o: word, @@f: byte, @@c: word

  push bp
  mov ax, [@@s]
  mov es, ax
  mov di, [@@o]
  mov al, [@@f]
  mov cx, [@@c]
  rep stosb
  pop bp
  ret

FillMem endp

CopyMem proc far
arg @@_ss, @@_so, @@_ds, @@_do, @@c: word

  push bp
  mov cx, [@@c]
  mov di, [@@_do]
  mov es, [@@_ds]
  mov si, [@@_so]
  mov ax, [@@_ss]
  push ds
  mov ds, ax
  rep movsb
  pop ds
  pop bp
  ret

CopyMem endp

TWaitForRetrace proc far

  push bp
;  cli
  mov dx, 3DAh
w1: in al, dx
  and al, 08h
  jnz w1
w2: in  al, dx
  and al, 08h
  jz w2
;  sti
  pop bp
  ret

TWaitForRetrace endp

vs dw (?)

end