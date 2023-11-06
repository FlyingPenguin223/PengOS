pusha

mov bx,[CURDIR]
mov cx,0
mov cl,byte[bx]
inc byte[bx] ;increment file count
cmp cx,0
je MKDIREMPTYFOLDER
add bx,17
mov bx,[bx] ;points to first byte of first filetable entry

MKDIRGETFILETABLELOOP:
dec cx
add bx,20

cmp cx,0
je MKDIRGOTFILETABLE ;dont jmp 0x0000

mov bx,[bx]
jmp MKDIRGETFILETABLELOOP

MKDIREMPTYFOLDER:
add bx,17

MKDIRGOTFILETABLE: ;bx adress of final ptr in filetable
mov dx,[FREESPACE]
mov [bx],dx ;ptr to next entry in filetable
mov bx,FREESPACE
mov ax,[bx]
add ax,63 ;22+19+22 (filetable+folder declaration+ .. entry)
add [bx],ax

mov bx,dx
mov byte[bx],1
inc bx
mov byte[bx],0
inc bx ;written attributes

mov dx,bx
mov bx,SHELLARGS
mov cx,0

MKDIRNAMELOOP:
mov al,byte[bx]
push bx
mov bx,dx
mov byte[bx],al
pop bx

inc bx
inc dx
inc cx
cmp cx,16
je MKDIRNAMEWRITTEN
jmp MKDIRNAMELOOP

MKDIRNAMEWRITTEN:
mov bx,dx

mov ax,bx
add ax,4
mov word[bx],ax
add bx,2
mov word[bx],0x0000 ;filetable entry complete

add bx,2
mov byte[bx],1 ;filecount
inc bx

mov dx,bx
mov bx,SHELLARGS
mov cx,0

MKDIRWRITENAME2:
mov al,byte[bx]
push bx
mov bx,dx
mov byte[bx],al
pop bx

inc bx
inc dx
inc cx
cmp cx,16
je MKDIRNAME2WRITTEN
jmp MKDIRWRITENAME2

MKDIRNAME2WRITTEN:
mov bx,dx
mov ax,bx
add ax,2
mov word[bx],ax ;ptr to next entry in filetable, folder created but need ..

add bx,2
mov byte[bx],1
inc bx
mov byte[bx],0
inc bx
mov byte[bx],2
inc bx
mov word[bx],'..'
add bx,2
mov cx,0
MKDIRSMALLLOOP:
mov byte[bx],0
inc bx
inc cx
cmp cx,13
je MKDIRENDSMALLLOOP
jmp MKDIRSMALLLOOP

MKDIRENDSMALLLOOP:
mov ax,[CURDIR]
mov word[bx],ax ;prev directory ptr
add bx,2
mov word[bx],0x0000 ;ptr to next entry in filetable, done

popa
ret