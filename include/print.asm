PRINT: ;bx string ptr, ax length
pusha
mov dx,ax
mov cx,0
mov ah,0x0e
PRINTLOOP:
cmp cx,dx
je PRINTEND
mov al,byte[bx]
cmp al,10
je PRINTNEWLINE
int 0x10
inc cx
inc bx
jmp PRINTLOOP

PRINTNEWLINE:
pusha
mov bx,0
mov ah,0x03
int 0x10
inc dh
mov dl,0
mov ah,0x02
int 0x10
popa
inc cx
inc bx
jmp PRINTLOOP

PRINTEND:
popa
ret