MOVECURS: 
pusha
mov dx,ax
mov ah,02
mov bx,0
int 0x10
popa
ret