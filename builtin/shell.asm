SHELL:
call CLEARSCREEN
pusha
jmp SHELLOOP

SHELLTEXT: db '$> '
SHELLTEXTLEN: dw ($-SHELLTEXT)

SHELLCOMMAND: times 32 db 0
SHELLARGS: times 64 db 0

SHELLNOTFOUNDSTR: db 'Command not found :('
SHELLNOTFOUNDSTRLEN: dw ($-SHELLNOTFOUNDSTR)

SHELLOOP:
mov ax,0
mov bx,[CURDIR]
inc bx
mov al,byte[bx]
inc bx
call PRINT

mov bx,SHELLTEXT
mov ax,word [SHELLTEXTLEN]
call PRINT

call GETINPUT

mov bx,STDIN+1
mov ax,0
mov al,byte [STDIN]
mov cx,0

SHELLARGSCHECK:

cmp byte[bx],32
je SHELLARGSWRITE

mov dl,byte[bx]
push bx
mov bx,SHELLCOMMAND+1
add bx,cx
mov byte[bx],dl
pop bx

dec ax

inc bx
inc cx
cmp ax,0
je SHELLNOARGS
cmp ax,0xFFFF ;underflow for zero length command
je SHELLNOARGS

jmp SHELLARGSCHECK

SHELLARGSWRITE:
push bx
mov bx,SHELLCOMMAND
mov byte[bx],cl
pop bx
inc bx ;bx points to args
dec ax
mov cx,0

SHELLARGSLOOP:

cmp ax,0
je SHELLRUNCOMMAND

mov dl,byte[bx]
push bx
mov bx,SHELLARGS+1
add bx,cx
mov byte[bx],dl
pop bx

inc bx
inc cx
dec ax

jmp SHELLARGSLOOP

SHELLNOARGS:
mov bx,SHELLCOMMAND
mov byte[bx],cl
mov cx,0

SHELLRUNCOMMAND:
mov bx,SHELLARGS
mov byte[bx],cl

mov dx,SHELLCOMMAND
mov bx,[ENV]
mov ax,0
mov al,byte[bx] ;ax file count
add bx,19
mov cx,0

SHELLCHECKLOOP:

push ax
call CMPSTR

cmp ax,1
je SHELLMATCH
pop ax

add bx,18
mov bx,[bx]
add bx,2

inc cx
cmp cx,ax
je SHELLNOTFOUND
jmp SHELLCHECKLOOP

SHELLMATCH:
push bx
sub bx,1
cmp byte[bx],1 ;   check if its executable
jne SHELLNOTFOUND
pop bx

add bx,16
mov bx,word [bx]
add bx,2

call bx

jmp SHELLOOP

SHELLNOTFOUND:
mov bx,SHELLNOTFOUNDSTR
mov ax,[SHELLNOTFOUNDSTRLEN]
call PRINT
call NEWLINE

jmp SHELLOOP