jmp EDITSTART

EDITNOTFOUNDSTR: db 'file not found :('
EDITNOTFOUNDSTRLEN: dw $-EDITNOTFOUNDSTR 

EDITSTART:
mov dx,SHELLARGS
mov bx,[CURDIR]
mov cx,0
mov cl,byte[bx]
cmp cx,0
je EDITNOTFOUND
add bx,17
mov bx,[bx]
add bx,2

EDITCHECKLOOP:
call CMPSTR
cmp ax,1
je EDITMATCH

add bx,18
mov bx,[bx]
add bx,2
dec cx
cmp cx,0
je EDITNOTFOUND
jmp EDITCHECKLOOP

EDITMATCH:
push bx
sub bx,2
cmp byte[bx],1 ;folder?
pop bx
je EDITNOTFOUND

call CLEARSCREEN
jmp EDITBEGIN

EDITNOTFOUND:
mov bx,EDITNOTFOUNDSTR
mov ax,[EDITNOTFOUNDSTRLEN]
call PRINT
call NEWLINE
jmp EDITEND

EDITHUDSTR: db 'editing file: "'
EDITHUDSTRLEN: dw $-EDITHUDSTR
EDITFILENAME: times 16 db 0

EDITPRINTHUDSTR:
pusha
mov bx, EDITHUDSTR
mov ax, [EDITHUDSTRLEN]
call PRINT
mov bx,EDITFILENAME
mov ax,0
mov al, byte [bx]
inc bx
call PRINT
mov ah,0x0e
mov al,'"'
int 0x10
popa
ret

EDITBEGIN:
mov cx,0
mov cl,byte[bx]
mov dx,EDITFILENAME
push bx

EDITWRITEFILENAMELOOP:
mov al,byte[bx]
push bx
mov bx,dx
mov byte[bx],al
pop bx
inc dx
inc bx
dec cx
cmp cx,0xFFFF ;underflow, cmp cx,0 misses last char
je EDITLOOPSTART
jmp EDITWRITEFILENAMELOOP

EDITCURSX: db 0
EDITCURSY: db 0
EDITCURSPOS: db 0
EDITFILELEN: dw 0
EDITFILEPTR: dw 0

EDITLOOPSTART:
mov bx,EDITCURSX
mov word[bx],0
mov bx,EDITCURSPOS
mov word[bx],0
pop bx
add bx,16
mov bx,[bx] ; bx now points to file contents
mov dx, word[bx]
push bx
mov bx, EDITFILELEN
mov word [bx], dx
pop bx
mov dx,bx
mov bx,EDITFILEPTR
mov word[bx],dx

EDITLOOP:
call CLEARSCREEN
mov ah,24
mov al,0
call MOVECURS
call EDITPRINTHUDSTR
mov ax,0
call MOVECURS

mov bx,word[EDITFILEPTR]
mov ax,word[bx]
add bx,2
call PRINT

mov ah,byte[EDITCURSY]
mov al,byte[EDITCURSX]
call MOVECURS

mov ah,0
int 0x16
cmp ah,0x01 ; esc
je EDITEND

; here, detect if al is zero, if so, detect for arrow keys (otherwise do nothing, would be fn key)
; otherwise, write al to file at position
; and then jmp EDITRIGHT possibly - try and check for bugs

cmp al,0
je EDITFN

; if letter pressed, copy every character (starting at end of file) forward by one and then write
; and increment file length word

; if backspace, copy each character after cursor position backward and decrement file length word

cmp ax,0x0E08
je EDITBACKSPACE

push ax

mov ax,0
mov bx,EDITFILELEN
inc word[bx]
mov al,byte[bx] ; ax file length
mov bx,[EDITFILEPTR]
inc word[bx] ; file length word
add bx,ax ; bx points to last char in file (should add two??? but its broken)

mov cx,0
mov cl,byte[EDITCURSPOS]
EDITTYPELOOP:
mov dl,byte[bx]
mov byte[bx+1],dl
dec bx
dec ax

cmp ax,cx
je EDITTYPEEND
jmp EDITTYPELOOP

EDITTYPEEND:
mov ax,0
mov al,byte[EDITCURSPOS]
mov bx,[EDITFILEPTR]
add bx,2
add bx,ax
pop ax
cmp ax,0x1C0D ; enter
je EDITTYPEENTER
mov byte[bx],al
jmp EDITRIGHT

EDITTYPEENTER:
mov byte[bx],10
jmp EDITRIGHT

EDITBACKSPACE:
mov ax,0
mov al,byte[EDITCURSPOS]
cmp ax,0
je EDITLOOP ; dont do anything if at start of file
mov bx,EDITFILELEN
dec word[bx]
mov bx,[EDITFILEPTR]
dec word[bx]
add bx,1
add bx,ax

EDITBACKSPACELOOP:
mov dx,[EDITFILELEN]
cmp ax,dx
jg EDITLEFT ; does this (below) interfere with the length byte? doesnt appear to in practice but idk
mov dl,byte[bx+1] ; appears to go one extra time? idk but when editing files in bin, it appears to overwrite the lower byte of the next program's length with the upper byte which should be zero (endianness)
mov byte[bx],dl ; evidence: by deleting one char from rm, can still cat edit but it displays less
inc bx ; however making it run one less times causes it to not move the last char of a normal file back
inc ax ; I have the feeling that the file length words are too long by two, since I've seen weirdness with cat
jmp EDITBACKSPACELOOP ; Above is true! fixed as of 8/3/2024. didnt account for length of the word

EDITFN:
cmp ah,0x48
je EDITUP
cmp ah,0x50
je EDITDOWN
cmp ah,0x4B
je EDITLEFT
cmp ah,0x4D
je EDITRIGHT

EDITUP:
; go backward until second newline, or offset is zero.
; if offset is zero before first newline, then straight to setxy
; then go forward by xpos or until newline
; then set x,y from pos
mov cx,0
mov ax,0
EDITUPLOOP:
mov bx,EDITCURSPOS
cmp byte[bx],0
je EDITSETXY
dec byte[bx]

mov al,byte[bx]
mov bx,[EDITFILEPTR]
add bx,2
add bx,ax
cmp byte[bx],10
je EDITUPLOOP2
jmp EDITUPLOOP

EDITUPLOOP2: ; for second newline
mov bx,EDITCURSPOS
cmp byte[bx],0
je EDITUPFORWARDFROMSTART
dec byte[bx]

mov al,byte[bx]
mov bx,[EDITFILEPTR]
add bx,2
add bx,ax
cmp byte[bx],10
je EDITUPFORWARD
jmp EDITUPLOOP2

EDITUPFORWARDFROMSTART:
mov bx,EDITCURSPOS
dec byte[bx]

EDITUPFORWARD:
mov bx,EDITCURSX
mov al,byte[bx]
add cx,ax
inc cx ; cx counter

mov bx,EDITCURSPOS
mov al,byte[bx]
mov bx,[EDITFILEPTR]
add bx,2
add bx,ax

; bx points to newline in file
EDITUPFORWARDLOOP:
inc bx

push bx
mov bx,EDITCURSPOS
inc byte[bx]
pop bx

cmp byte[bx],10
je EDITSETXY

dec cx
cmp cx,0
je EDITSETXY
jmp EDITUPFORWARDLOOP

EDITDOWN:
; go forward until newline or eof then break
; then go forward by xpos or until newline/eof
; then set x,y from pos
mov dx,[EDITFILELEN]
mov bx,EDITCURSPOS
mov ax,0
EDITDOWNLOOP:
cmp dl,byte[bx]
je EDITSETXY ; straight to setxy if eof
mov al,byte[bx] ; al curspos
mov bx,[EDITFILEPTR]
add bx,2
add bx,ax
cmp byte[bx],10
je EDITDOWNFORWARD
mov bx,EDITCURSPOS
inc byte[bx]
jmp EDITDOWNLOOP

EDITDOWNFORWARD:
; have to loop through to account for newlines, ultimately add EDITCURSX + 1 to EDITCURSPOS if no breaks
push bx
mov bx,EDITCURSX
mov cx,0
mov cl,byte[bx]
pop bx
inc cx ; cx counter
; bx points to newline in file
EDITDOWNFORWARDLOOP:
inc bx

push bx
mov bx,EDITCURSPOS
inc byte[bx]
pop bx

cmp byte[bx],10
je EDITSETXY

push bx
mov bx,EDITCURSPOS
mov al,byte[bx]
pop bx
cmp dl,al ; dl unchanged
je EDITSETXY

dec cx
cmp cx,0
je EDITSETXY
jmp EDITDOWNFORWARDLOOP

EDITLEFT:
; decrement pos (unless 0)
; then set x,y from pos
mov bx,EDITCURSPOS
mov al,byte[bx]
cmp al,0
je EDITLEFTEOF
dec byte [bx]
EDITLEFTEOF:
jmp EDITSETXY

EDITRIGHT:
; increment pos (unless eof)
; then set x,y from pos
mov bx,EDITCURSPOS
mov ax,0
mov al,byte[bx]
mov dx,[EDITFILELEN]
cmp ax,dx
je EDITRIGHTEOF
inc byte [bx]
EDITRIGHTEOF:
jmp EDITSETXY

EDITSETXY:
;step through file pos times
; increment x every time
; if newline, increment y, set x to zero
mov dx,0 ;dl x dh y
mov cx,0
mov cl,byte [EDITCURSPOS]
mov bx,EDITCURSX
mov word[bx],0 ; both x and y
mov bx,[EDITFILEPTR]
add bx,1 ;after first increment
EDITSETXYLOOP:
inc bx
cmp cx,0
je EDITSETXYEND
dec cx

cmp byte[bx],10
je EDITSETXYNEWLINE

inc dl

jmp EDITSETXYLOOP

EDITSETXYNEWLINE:
mov dl,0
inc dh
jmp EDITSETXYLOOP

EDITSETXYEND:
mov bx,EDITCURSX
mov byte[bx], dl ; x
inc bx
mov byte[bx], dh ; y
jmp EDITLOOP ;bx already popped? <- no longer relevant

EDITEND:
call CLEARSCREEN
ret