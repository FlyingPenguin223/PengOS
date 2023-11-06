pusha
jmp EDSTART

EDSTARTSTR: db 'Welcome to this text editor! type "help" for a list of commands.'
EDSTARTSTRLEN: dw $-EDSTARTSTR
EDHELPSTR: db 'Commands:',10,'add - writes to the buffer',10,'w or write - writes buffer to file',10,'exit - exit the editor',10,'\n - write a newline',10
EDHELPSTRLEN: dw $-EDHELPSTR

EDNOTFOUNDSTR: db 'File not found :('
EDNOTFOUNDSTRLEN: dw $-EDNOTFOUNDSTR

EDNOTCOMMANDSTR: db 'Not a command :('
EDNOTCOMMANDSTRLEN: dw $-EDNOTCOMMANDSTR

EDCURFILE: dw 0x0000
EDBUFFER: times 64 db 0

EDCOMMANDS: ;6 bytes each
db 3,'add',0,0
db 1,'w',0,0,0,0
db 5,'write'
db 4,'exit',0
db 2,'\n',0,0,0
db 4,'help',0

EDSTART:
mov dx,SHELLARGS
mov bx,[CURDIR]
mov cx,0
mov cl,byte[bx]
cmp cx,0
je EDNOTFOUND
add bx,17
mov bx,[bx]
add bx,2

EDCHECKLOOP:
call CMPSTR
cmp ax,1
je EDMATCH

add bx,18
mov bx,[bx]
add bx,2
dec cx
cmp cx,0
je EDNOTFOUND
jmp EDCHECKLOOP

EDMATCH:
push bx
sub bx,2
cmp byte[bx],1 ;folder?
pop bx
je EDNOTFOUND

add bx,16
mov bx,[bx]
mov ax,bx
mov bx,EDCURFILE
mov word[EDCURFILE],ax

mov bx,EDSTARTSTR
mov ax,[EDSTARTSTRLEN]
call PRINT
call NEWLINE

EDLOOP:
call GETINPUT
mov dx,STDIN
mov bx,EDCOMMANDS
mov cx,0

EDCOMMANDLOOP:
call CMPSTR
cmp ax,1
je EDCOMMANDMATCH
inc cx
add bx,6
cmp cx,6
je EDNOTCOMMAND
jmp EDCOMMANDLOOP

EDNOTCOMMAND:
mov bx,EDNOTCOMMANDSTR
mov ax,[EDNOTCOMMANDSTRLEN]
call PRINT
call NEWLINE
jmp EDLOOP

EDCOMMANDMATCH:
cmp cx,0
je EDADD
cmp cx,1
je EDWRITE
cmp cx,2
je EDWRITE
cmp cx,3
je EDEND
cmp cx,4
je EDNEWLINE
cmp cx,5
je EDHELP

jmp EDLOOP ;shouldnt ever be here

EDADD:
call GETINPUT
mov cx,0
mov cl,byte[STDIN]
inc cx ;cx stdin length (including length byte (should be word))
mov bx,STDIN
mov dx,EDBUFFER
EDBUFFERWRITELOOP:
cmp cx,0
je EDADDEND
mov al,byte[bx]
push bx
mov bx,dx
mov byte[bx],al
pop bx

inc bx
inc dx
dec cx
jmp EDBUFFERWRITELOOP

EDADDEND:
jmp EDLOOP

EDWRITE:
mov bx,[EDCURFILE] ;adress of file
add bx,[bx]
add bx,2 ;points to end of file
mov dx,bx ;dx is file ptr
mov bx,EDBUFFER
mov cx,0
mov cl,byte[bx] ;cx counter
inc bx

EDWRITELOOP:
cmp cx,0
je EDWRITEEND
mov al,byte[bx]
push bx
mov bx,dx
mov byte[bx],al
pop bx
inc bx
inc dx
dec cx
jmp EDWRITELOOP

EDWRITEEND:
mov ax,0
mov al,byte[EDBUFFER]
mov bx,[EDCURFILE]
add [bx],ax ;increase file len

jmp EDLOOP

EDNEWLINE:
mov bx,[EDCURFILE]
add bx,[bx]
add bx,2
mov byte[bx],10
mov bx,[EDCURFILE]
inc word[bx]
jmp EDLOOP

EDHELP:
mov bx,EDHELPSTR
mov ax,[EDHELPSTRLEN]
call PRINT
jmp EDLOOP

EDNOTFOUND:
mov bx,EDNOTFOUNDSTR
mov ax,[EDNOTFOUNDSTRLEN]
call PRINT
call NEWLINE

EDEND:
popa
ret