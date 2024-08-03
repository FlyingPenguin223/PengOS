jmp RMSTART

RMFOLDERSTR: db 'empty folder first'
RMFOLDERSTRLEN: dw ($-RMFOLDERSTR)
RMNOTFOUNDSTR: db 'file not found :('
RMNOTFOUNDSTRLEN: dw ($-RMNOTFOUNDSTR)

RMSTART:
mov dx,SHELLARGS
mov bx,[CURDIR]
mov cx,0
mov cl,byte[bx]
cmp cx,0
je RMNOTFOUND
add bx,17
mov bx,[bx]
add bx,2

RMCHECKLOOP:
call CMPSTR
cmp ax,1
je RMMATCH

add bx,18
mov bx,[bx]
add bx,2
dec cx
cmp cx,0
je RMNOTFOUND
jmp RMCHECKLOOP

RMMATCH:
push bx
sub bx,2
cmp byte[bx],1 ;folder?
pop bx
je RMFOLDER
jmp RMREMOVE

RMFOLDER:
push bx
add bx,16
mov bx,[bx]
mov al,byte[bx] ;num files in folder
cmp al,1
pop bx ;previously was not here, idk why
je RMREMOVE ; this used to pop bx before going to rmremove, idk why
mov bx,RMFOLDERSTR
mov ax,[RMFOLDERSTRLEN]
call PRINT
call NEWLINE
jmp RMEND

RMNOTFOUND:
mov bx,RMNOTFOUNDSTR
mov ax,[RMNOTFOUNDSTRLEN]
call PRINT
call NEWLINE
jmp RMEND

RMREMOVE:
;if cx == 1 then this is last file in folder
;just decrement the files in folder, removing entry is useless atm since I dont do memory management (yet (not))
;otherwise file is in the middle
;make previous entry point to the next entry, and decrement files in folder

cmp cx,1
je RMDECREMENT

; set prev filetable entry to link to the next file
add bx,18 ;bx points to next file ptr, move this to prev filetable entry
mov dx,word[bx]

mov bx,[CURDIR]
mov ax,0
mov al,byte[bx]
sub ax,cx
mov cx,ax
inc cx
add bx,17
mov bx,[bx] ;check then decrement, cmp w/zero

RMFILELOOP:
cmp cx,2 ; 2 above
je RMWRITEMID

dec cx
add bx,20
mov bx,[bx]
jmp RMFILELOOP

RMWRITEMID:
add bx,20
mov [bx],dx

RMDECREMENT:
mov bx,[CURDIR]
dec byte [bx]

RMEND:
ret