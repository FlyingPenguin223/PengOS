mov dx,SHELLARGS
mov bx,[CURDIR]
mov cx,0
mov cl,byte[bx]
cmp cx,0
je NOTFOUND
add bx,17
mov bx,[bx]
add bx,2

CHECKLOOP:
call CMPSTR
cmp ax,1
je MATCH

add bx,18
mov bx,[bx]
add bx,2
dec cx
cmp cx,0
je NOTFOUND
jmp CHECKLOOP

MATCH:
push bx
sub bx,2
cmp byte[bx],1 ;folder?
pop bx
je NOTFOUND

NOTFOUND: