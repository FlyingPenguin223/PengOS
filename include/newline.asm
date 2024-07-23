NEWLINE:
pusha
mov bx,0
mov ah,0x03
int 0x10
inc dh

cmp dh,25
jl NEWLINESETCURS

mov ah,0x06
mov al,1
mov bh,0b00000111
mov cx,0
mov dh,24
mov dl,79 ; coords of lower right
int 0x10

mov bh,0
mov dh,24
NEWLINESETCURS:
mov dl,0
mov ah,0x02
int 0x10
popa
ret