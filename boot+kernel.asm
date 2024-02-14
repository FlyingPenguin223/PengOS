[bits 16]
[org 0x7c00]
[map all ./builds/map.map]
VERY_START:

mov ax,0

mov ds,ax
mov es,ax

mov bx,0x9000
mov ss,bx
mov sp,ax

call load_kernel

call KERNEL_START

jmp $

%include "include/disk.asm"

load_kernel:
mov bx, KERNEL_START ; bx -> destination
mov dh, 8             ; dh -> num sectors
call disk_load
ret

; padding
times 510 - ($-$$) db 0

; magic number
dw 0xaa55

KERNEL_START:

call CLEARSCREEN ;clear screen for epic intro

mov ah,01 ; clear cursor
mov cx,0x2000
int 0x10

mov ah,5  ;y
mov al,(40-9)  ;x
call MOVECURS

mov bx,WELCOMESTR
mov ax,[WELCOMESTRLEN]
call PRINT

mov ah,6
mov al,(40-14)
call MOVECURS

mov bx,WELCOMESTR2
mov ax,[WELCOMESTR2LEN]
call PRINT

mov ax,0
int 0x16 ;wait for keypress

mov ax,0
mov al,0x03 ;clear screen
int 0x10

call SHELL

jmp KERNEL_START ; incase of return

WELCOMESTR: db 'Welcome to PengOS!'
WELCOMESTRLEN: dw ($-WELCOMESTR)  ;18
WELCOMESTR2: db 'Press any key to continue...'
WELCOMESTR2LEN: dw ($-WELCOMESTR2)  ;28

;  SYSCALLS

%include "./include/print.asm" ;bx string ax length
%include "./include/movecurs.asm" ;ah y al x
%include "./include/getinput.asm"
%include "./include/newline.asm"
%include "./include/cmpstr.asm" ;bx is str1, dx is str2, ax return 1 true 0 false

CLEARSCREEN:
pusha
mov ax,0
mov al,0x03
int 0x10
popa
ret

ENV: db word BINFOLDER

BINFOLDER: db 9
db 3,'bin'
times 16-4 db 0
dw word BINTABLE0

BINTABLE0:
db 1,0
db 2,'..'
times 16-3 db 0
dw word FILES
dw word BINTABLE1

BINTABLE1:
db 0,1
db 5,'shell'
times 16-6 db 0
dw word SHELLBIN
dw word BINTABLE2

BINTABLE2:
db 0,1
db 2,'ls'
times 16-3 db 0
dw word LSBIN
dw word BINTABLE3

BINTABLE3:
db 0,1
db 3,'cls'
times 16-4 db 0
dw word CLSBIN
dw word BINTABLE4

BINTABLE4:
db 0,1
db 2,'cd'
times 16-3 db 0
dw word CDBIN
dw word BINTABLE5

BINTABLE5:
db 0,1
db 4,'echo'
times 16-5 db 0
dw word ECHOBIN
dw word BINTABLE6

BINTABLE6:
db 0,1
db 3,'cat'
times 16-4 db 0
dw word CATBIN
dw word BINTABLE7

BINTABLE7:
db 0,1
db 5,'touch'
times 16-6 db 0
dw word TOUCHBIN
dw word BINTABLE8

BINTABLE8:
db 0,1
db 2,'ed'
times 16-3 db 0
dw word EDBIN
dw word BINTABLE9

BINTABLE9:
db 0,1
db 5,'mkdir'
times 16-6 db 0
dw word MKDIRBIN
dw 0x0000

SHELLBIN:
dw LSBIN-$ ;length
%include "./builtin/shell.asm"

LSBIN:
dw CDBIN-$
%include "./builtin/ls.asm"

CDBIN:
dw CLSBIN-$
%include "./builtin/cd.asm"

CLSBIN:
dw ECHOBIN-$
%include "./builtin/cls.asm"

ECHOBIN:
dw CATBIN-$
%include "./builtin/echo.asm"

CATBIN:
dw TOUCHBIN-$
%include "./builtin/cat.asm"

TOUCHBIN:
dw EDBIN-$
%include "./builtin/touch.asm"

EDBIN:
dw MKDIRBIN-$
%include "./builtin/ed.asm"

MKDIRBIN:
dw CURDIR-$
%include "./builtin/mkdir.asm"

CURDIR: dw word FILES ;start at root dir

FREESPACE: dw word FREESPACESTART ;where to write new files to

STDIN: times 256 db 0

FILES: db 2
db 4,'root'
times 16-5 db 0
dw ROOTABLE0

ROOTABLE0:
db 1,0
db 2,'..' ; cd .. from root goes back to root :)
times 16-3 db 0
dw word FILES
dw word ROOTTABLE1

ROOTTABLE1:
db 1,0
db 3,'bin'
times 16-4 db 0
dw BINFOLDER
dw 0x0000

;FILETABLE LAYOUT:
;first byte: file count in directory
;next 16 BYTES: directory name (length first byte)
;each subsequent group of 20 bytes:
;  first 2 bytes: filetype and permissions
;       first byte: 1 for folder, 0 for not
;       second byte: 1 for executable 0 for not
;   next 16 bytes: file/folder name (length first byte)
;   next 2 bytes: adress to thing

;by default allocate files 10 names off
; files begin with a word of their length

FREESPACESTART:
times 10000 db 0 ;to avoid sector errors, and still load all the code in qemu