ECHO:

mov bx,SHELLARGS+1
mov ax,0
mov al,byte[SHELLARGS]
call PRINT
call NEWLINE

ret