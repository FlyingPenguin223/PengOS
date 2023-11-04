pusha ;allocate 256 bytes for a file, first byte is if it continues, next word is length


; FREESPACE contains pointer to start of free area
; create a new filetable entry from curdir, by setting the previous filetable entry's continue address and
; incrementing file count. assign name and properties (not a folder, not executable)
; add 256 to freespace, and go to the location of the file and
; set the first byte for 0 for continuity, next word to zero for length, and next word 0 for
; continue adress.

popa
ret