jmp LSSTART

LSSTR: db 'in ['
LSSTRLEN: dw ($-LSSTR)
LSSTR2: db'] folder:'
LSSTR2LEN: dw ($-LSSTR2)

LSSTART:
mov bx,LSSTR
mov ax,[LSSTRLEN]
call PRINT

mov bx,[CURDIR]
mov cx,0
mov cl,byte[bx] ;file count
inc bx
mov ax,0
mov al,byte[bx]
inc bx
call PRINT

mov bx,LSSTR2
mov ax,[LSSTR2LEN]
call PRINT
call NEWLINE

mov bx,[CURDIR]
add bx,17
mov bx,[bx]
add bx,2
mov ax,0

LSLOOP:
cmp cx,0
je LSEND

mov al,byte[bx]
inc bx
call PRINT
call NEWLINE

add bx,17
mov bx,[bx]
add bx,2
dec cx
jmp LSLOOP

LSEND:
ret