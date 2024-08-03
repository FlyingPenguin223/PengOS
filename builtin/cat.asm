jmp CATSTART

CATNOTFOUNDSTR: db 'File not found :('
CATNOTFOUNDSTRLEN: dw ($-CATNOTFOUNDSTR)

CATSTART:
mov dx,SHELLARGS
mov bx,[CURDIR]
mov cx,0
mov cl,byte[bx]
cmp cx,0
je CATNOTFOUND
add bx,17
mov bx,[bx]
add bx,2

CATLOOP:
call CMPSTR
cmp ax,1
je CATMATCH

add bx,18
mov bx,[bx]
add bx,2
dec cx
cmp cx,0
je CATNOTFOUND
jmp CATLOOP

CATMATCH:
push bx
sub bx,2
cmp byte[bx],1 ;folder?
pop bx
je CATNOTFOUND

add bx,16
mov bx,[bx] ;copies the pointer in the filetable to bx
mov ax,[bx]
add bx,2

;mov ax,5

call PRINT
jmp CATEND

CATNOTFOUND:
mov bx,CATNOTFOUNDSTR
mov ax,[CATNOTFOUNDSTRLEN]
call PRINT

CATEND:
call NEWLINE
ret