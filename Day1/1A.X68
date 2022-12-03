*-----------------------------------------------------------
* Title      : AoC2022 #1A
* Written by : furrtek
*-----------------------------------------------------------

    ORG    $1000
START:
    move.l #51,d0           ; Open file
    lea    filename,a1
    trap   #15
    tst.w  d0
    bne    file_error
    
    move.l #0,d4            ; File read position tracker
    move.l d4,d6            ; Entry counter
    lea    input_data,a0
    
.read_line:
    move.l #53,d0           ; Read 16 bytes from file
    lea    line_buffer,a1
    move.l #16,d2
    trap   #15
    cmp.w  #1,d0
    bhi    file_error
    cmp.b  #1,d0
    beq    .read_done       ; Nothing left to read
    ; Preserve d1 for file handle !
    
    move.l #0,d0
    move.l d0,d3            ; Value accumulator
    move.l d0,d7            ; Value length counter
.parse_num:
    move.b (a1)+,d0
    cmp.b  #10,d0
    beq    .num_done
    
    lsl.l  #1,d3            ; *10
    move.l d3,d5
    lsl.l  #2,d3
    add.l  d5,d3

    subi.b #'0',d0
    add.l  d0,d3
    addi.b #1,d7
    bra    .parse_num
    
.num_done:
    tst.b  d7
    bne    .not_empty
    move.l #-1,d3
.not_empty:
    move.l d3,(a0)+
    addq.l #1,d6
    
    addq.b #1,d7
    add.l  d7,d4
    move.l d4,d2
    move.l #55,d0           ; Set file read position
    trap   #15
    
    bra    .read_line
    
.read_done:
    move.l #56,d0           ; Close file
    trap   #15
    
    ; Process input data
    lea    input_data,a0
    lea    buffer,a1
    move.l #0,d1            ; Accumulator
    move.l d1,d7            ; Group counter
.process:
    move.l (a0)+,d0
    cmp.l  #-1,d0
    bne    .value
    move.l d1,(a1)+
    move.l #0,d1
    addq.l #1,d7
    bra    .new
.value:
    add.l  d0,d1
.new:
    subq.l #1,d6
    bne    .process
    
    ; Find highest value
    lea    buffer,a1
    move.l #0,d1
.search:
    move.l (a1)+,d0
    cmp.l  d1,d0
    blo    .less
    move.l d0,d1
.less:
    subq.l #1,d7
    bne    .search
    
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
    DC.B   '1A_input.txt',0
str_error:
    DC.B   'Error :( See d0',0
line_buffer: DS.B 256
input_data:  DS.L 4096
buffer:      DS.L 1024
    END    START


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
