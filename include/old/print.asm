PRINT: ;cx as argument
pusha
mov bx,cx
PRINTLOOP:
mov al,[bx]
mov ah,0x0e
cmp al,0x00
je PRINTEND
int 0x10
inc bx
jmp PRINTLOOP

PRINTEND:
popa
ret