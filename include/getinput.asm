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

cmp ax,0x0E08
je GETINPUTBACKSPACE

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

GETINPUTBACKSPACE:
push bx
mov bx,STDIN
cmp byte[bx],0
pop bx
je GETINPUTLOOP

dec bx
mov byte[bx],0
int 0x10
push ax
mov al,32
int 0x10
pop ax
int 0x10
push bx
mov bx,STDIN
dec byte[bx]
pop bx
jmp GETINPUTLOOP

GETINPUTEND:
call NEWLINE
popa
ret