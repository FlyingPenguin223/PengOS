;allocate 512 bytes for a file, first word is length

mov bx,[CURDIR]
mov cx,0
mov cl,byte[bx]
inc byte[bx] ;increment file count
cmp cx,0
je TOUCHEMPTYFOLDER
add bx,17
mov bx,[bx] ;points to first byte of first filetable entry

TOUCHGETFILETABLELOOP:
dec cx
add bx,20

cmp cx,0
je TOUCHGOTFILETABLE ;dont jmp 0x0000

mov bx,[bx]
jmp TOUCHGETFILETABLELOOP

TOUCHEMPTYFOLDER:
add bx,17

TOUCHGOTFILETABLE:

mov dx,[FREESPACE] ;keep dx same
mov [bx],dx
mov bx,FREESPACE
mov ax,[bx]
add ax,534 ;add to freespace variable (512+22, filespace+filetable entry)
add [bx],ax

mov bx,dx ; bx points to start of allocated space
mov byte[bx],0
inc bx
mov byte[bx],0
inc bx ; assigned properties, write name now
mov cx,0

mov dx,bx
mov bx,SHELLARGS

TOUCHWRITENAMELOOP:

mov al,byte[bx] ;ah not zero probably, but doesnt matter since not using ax
push bx
mov bx,dx
mov byte[bx],al
pop bx
inc bx
inc dx   ;none of this accounts for the args unused space which may be filled with leftovers
inc cx   ; but since theres a length byte that isnt gonna be shown, but its still there
cmp cx,16  ;may consider fixing sometime. if one adds a file with longer length than 16, its
je TOUCHWRITENAMEEND ;unreachable, since the length will be written as the length of the arg
                        ;but the name will be shorter
jmp TOUCHWRITENAMELOOP 

TOUCHWRITENAMEEND: ; dx points to byte after filename, put file ptr and then 0x0000
mov bx,dx
mov ax,bx
add ax,4 ;pointer to after filetable entry
mov word[bx],ax
add bx,2
mov word[bx],0x0000 ;ptr to next filetable entry (doesnt exist atm)
add bx,2
mov word[bx],0x0000 ;file length, done with new file

; FREESPACE contains pointer to start of free area
; create a new filetable entry from curdir, by setting the previous filetable entry's continue address and
; incrementing file count. assign name and properties (not a folder, not executable)
; add 512 to freespace, and go to the location of the file and set the first word to zero for length

ret