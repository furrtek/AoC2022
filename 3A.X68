*-----------------------------------------------------------
* Title      : AoC2022 #3A
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
    
.read_line:
    move.l #53,d0           ; Read 64 bytes from file
    lea    line_buffer,a1
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
    btst.l #0,d3
    beq    .pass
    SIMHALT                 ; Line length should be even
.pass:       
    
    add.l  d3,d4
    add.l  #1,d4
    move.l d4,d2
    move.l #55,d0           ; Set file read position
    trap   #15    
    
    lsr.b  #1,d3
    sub.l  d3,a2            ; a2 now points to start of line's 2nd half
    
    move.l a2,a3            ; Save
    move.l #0,d2
    move.b d3,d7
    ; Scan first half
.scan1:
    move.b (a1)+,d2
    ; Scan second half
    move.l a3,a2            ; Restore
    move.b d3,d6
.scan2:
    cmp.b  (a2)+,d2
    beq    .found
    subq.b #1,d6
    bne    .scan2
    subq.b #1,d7
    bne    .scan1
    SIMHALT                 ; A match should always be found
.found:
    
    ; Convert ASCII to "priority"
    cmp.b  #'a',d2
    bhi    .lowercase
    sub.b  #'A'-27,d2
    bra    .done
.lowercase:
    sub.b  #'a'-1,d2
.done:
    add.l  d2,d5
    
    bra    .read_line
    
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
    
line_buffer: DS.B 25
    END    START




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
