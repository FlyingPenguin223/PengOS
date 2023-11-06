pusha
jmp CDSTART

CDNOTFOUNDSTR: db 'Not found :('
CDNOTFOUNDSTRLEN: dw ($-CDNOTFOUNDSTR)

CDSTART:
mov dx,SHELLARGS
mov bx,[CURDIR]
mov cx,0
mov cl,byte[bx]
add bx,17
mov bx,[bx]
add bx,2

CDLOOP:
call CMPSTR
cmp ax,1
je CDMATCH

add bx,18
mov bx,[bx]
add bx,2
dec cx
cmp cx,0
je CDNOTFOUND

jmp CDLOOP


CDMATCH:
sub bx,2
cmp byte[bx],1
jne CDNOTFOUND

add bx,18
mov ax,[bx]
mov bx,CURDIR
mov [bx],ax
jmp CDEND

CDNOTFOUND:
mov bx,CDNOTFOUNDSTR
mov ax,[CDNOTFOUNDSTRLEN]
call PRINT
call NEWLINE

CDEND:
popa
ret