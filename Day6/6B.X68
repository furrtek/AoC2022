*-----------------------------------------------------------
* Title      : AoC2022 #6B
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
    
    move.l #0,d4            ; File size counter
    lea    input_data,a1
    
.read_file:
    move.l #53,d0           ; Read entire file 1024 bytes or less at a time
    move.l #1024,d2
    trap   #15
    cmp.w  #1,d0
    bhi    file_error
    cmp.b  #1,d0
    beq    .read_done       ; Nothing left to read
    add.l  d2,d4
    cmp.w  #1024,d2
    blo    .read_done       ; Incomplete read, must be the last one
    lea    1024(a1),a1
    bra    .read_file
.read_done:
    move.l #56,d0           ; Close file
    trap   #15
    
    ; Process data - Find SIZE consecutive different characters
    ; Slow but couldn't think of anything clever :(
    move.l #SIZE,d1
    sub.l  #SIZE-1,d4       ; Search up to (file size - SIZE)
    lea    input_data,a0
.process:
    
    move.l a0,a1
    move.b #SIZE-1,d2       ; Compare range
.compare_out:
    move.b d2,d3
    move.b (a1)+,d0         ; Ref
    move.l a1,a3            ; Start comparing just after Ref
.compare_in:
    cmp.b  (a3)+,d0
    beq    .dup
    subq.b #1,d3
    bne    .compare_in
    subq.b #1,d2            ; Dec compare range
    bne    .compare_out
    
    bra    .found
    
.dup:
    addq.l #1,a0
    addq.l #1,d1
    
    subq.l #1,d4
    bne    .process
    SIMHALT                 ; Never found :(
    
.found:

    move.l #15,d0           ; Display
    move.l #10,d2
    trap   #15
    SIMHALT
    
file_error:
    lea    str_error,a1     ; Print cstring
    move.l #13,d0
    trap   #15
    SIMHALT

SIZE    EQU 14
filename:
    DC.B   '6A_input.txt',0
str_error:
    DC.B   'Error :( See d0',0
input_data: DS.B 8192
    END    START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
