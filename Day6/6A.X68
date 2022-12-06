*-----------------------------------------------------------
* Title      : AoC2022 #6A
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
    
    ; Process data - Find 4 consecutive different characters
    move.l #4,d5
    lea    input_data,a0    ; Start
    subi.l #3,d4            ; 4 - 1
.process:

    move.b (a0)+,d0         ; Can't move.l because of alternating alignment
    move.b (a0),d1
    move.b 1(a0),d2
    move.b 2(a0),d3
    
    ; First char, compare next 3
    cmp.b  d1,d0
    beq    .dup
    cmp.b  d2,d0
    beq    .dup
    cmp.b  d3,d0
    beq    .dup
    
    ; Second char, compare next 2
    cmp.b  d2,d1
    beq    .dup
    cmp.b  d3,d1
    beq    .dup
    
    ; Third char, compare next
    cmp.b  d3,d2
    beq    .dup
    
    bra    .found
.dup:

    addq.l #1,d5
    
    subq.l #1,d4
    bne    .process
    SIMHALT                 ; Never found :(
    
.found:

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
    DC.B   '6A_input.txt',0
str_error:
    DC.B   'Error :( See d0',0
input_data: DS.B 8192
buffer: DS.B 8192
    END    START


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
