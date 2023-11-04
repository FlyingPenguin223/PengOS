NEWLINE:
pusha
mov bx,0
mov ah,0x03
int 0x10
inc dh
mov dl,0
mov ah,0x02
int 0x10
popa
ret