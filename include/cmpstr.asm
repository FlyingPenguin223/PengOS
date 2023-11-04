CMPSTR: ;bx is str1, dx is str2, ax return 1 true 0 false
pusha
mov cx,0

CMPLOOP:
push bx
push dx
add bx,cx

mov ax,[bx]

mov bx,dx
add bx,cx
mov dx,[bx]

pop bx

cmp al,dl
pop dx
je CMPRELOOP

popa
mov ax,0
ret

CMPRELOOP:

push ax
mov ax,0
mov al,byte[bx]
cmp ax,cx
pop ax
je CMPEQUAL
inc cx
jmp CMPLOOP

CMPEQUAL:
popa
mov ax,1
ret