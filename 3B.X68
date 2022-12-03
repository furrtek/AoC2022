*-----------------------------------------------------------
* Title      : AoC2022 #3B
* Written by : furrtek
*-----------------------------------------------------------

    ORG    $1000
START:
    move.l #51,d0           ; Open file
    lea    filename,a1
    trap   #15
    tst.w  d0
    bne    file_error
    ; Preserve d1 for file handle !
    
    move.l #0,d4            ; File read position tracker
    move.l d4,d5            ; Accumulator
    
.read_lines:

    move.l #3,d7            ; Read groups of 3 lines
    lea    line_buffer,a1
.read_line:
    move.l #53,d0           ; Read 64 bytes from file
    move.l #64,d2
    trap   #15
    cmp.w  #1,d0
    bhi    file_error
    cmp.b  #1,d0
    beq    .read_done       ; Nothing left to read

    ; Find line length
    move.l a1,a2
    move.l #0,d3
.next_char:
    cmp.b  #10,(a2)
    beq    .eol
    addq.l #1,a2
    addq.b #1,d3
    bra    .next_char
.eol:
    move.b #0,(a2)          ; Null-terminate     
    
    add.l  d3,d4
    add.l  #1,d4
    move.l d4,d2
    move.l #55,d0           ; Set file read position
    trap   #15

    lea    64(a1),a1        ; a1 += 64 
   
    subq.b #1,d7
    bne    .read_line
    
    lea    line_buffer,a1   ; First line start
    move.l #0,d2
    
    ; Scan first
.scan1:
    move.b (a1)+,d2
    ; Scan second
    lea    line_buffer+64,a2    ; Second line start
.scan2:
    tst.b  (a2)
    beq    .scan1           ; EOS, char not found
    cmp.b  (a2)+,d2
    beq    .found2
    bra    .scan2
.found2:
    lea    line_buffer+128,a2   ; Third line start
.scan3:
    tst.b  (a2)
    beq    .scan1           ; EOS, char not found
    cmp.b  (a2)+,d2
    beq    .found3
    bra    .scan3
.found3:
    
    ; Convert ASCII to "priority"
    cmp.b  #'a',d2
    bhi    .lowercase
    sub.b  #'A'-27,d2
    bra    .done
.lowercase:
    sub.b  #'a'-1,d2
.done:
    add.l  d2,d5
    
    bra    .read_lines
    
.read_done:
    move.l #56,d0           ; Close file
    trap   #15
        
    move.l d5,d1    
    move.l #15,d0           ; Display
    move.l #10,d2
    trap   #15
    SIMHALT
    
file_error:
    lea    str_error,a1     ; Print cstring
    move.l #13,d0
    trap   #15
    SIMHALT

filename:
    DC.B   '3A_input.txt',0
str_error:
    DC.B   'Error :( See d0',0
    
line_buffer: DS.B 256
    END    START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
