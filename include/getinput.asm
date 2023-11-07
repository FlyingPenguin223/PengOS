GETINPUT:
pusha
mov bx,STDIN
mov byte[bx],0
inc bx

GETINPUTLOOP:
mov ax,0
int 0x16
cmp ax,0x1C0D
je GETINPUTEND
cmp al,0
je GETINPUTLOOP

mov byte[bx],al
mov dx,bx
mov bx,STDIN
inc byte[bx]
mov bx,dx
inc bx

mov ah,0x0e
int 0x10

jmp GETINPUTLOOP

GETINPUTEND:
call NEWLINE
popa
ret