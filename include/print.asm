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
call NEWLINE
inc cx
inc bx
jmp PRINTLOOP

PRINTEND:
popa
ret
