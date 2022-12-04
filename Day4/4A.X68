*-----------------------------------------------------------
* Title      : AoC2022 #4A
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

    jsr    parse_num
    move.b d0,(a0)+
    jsr    parse_num
    move.b d0,(a0)+
    jsr    parse_num
    move.b d0,(a0)+
    jsr    parse_num
    move.b d0,(a0)+
    
    addi.l #1,d6

    sub.l  #line_buffer,a1  ; Line length
    
    add.l  a1,d4
    move.l d4,d2
    move.l #55,d0           ; Set file read position
    trap   #15
    
    bra    .read_line
.read_done:
    move.l #56,d0           ; Close file
    trap   #15
    
    ; Process data
    lea    input_data,a0
.process:
    move.b (a0)+,d1         ; Pair A start
    move.b (a0)+,d2         ; Pair A end
    move.b (a0)+,d3         ; Pair B start
    move.b (a0)+,d4         ; Pair B end
    ; Does pair A contain pair B ?
    cmp.b  d3,d1
    bhi    .noA
    cmp.b  d4,d2
    blo    .noA
    bra    .yes
.noA:
    ; Does pair B contain pair A ?
    cmp.b  d1,d3
    bhi    .noB
    cmp.b  d2,d4
    blo    .noB
.yes:
    addi.l #1,d5
.noB:

    subq.l #1,d6
    bne    .process

    move.l d5,d1    
    move.l #15,d0           ; Display
    move.l #10,d2
    trap   #15
    SIMHALT
    
; Parse ASCII decimal number from (a1) until invalid char, result in d0.l
parse_num:
    movem.l d1-d2,-(a7)
    move.l #0,d0            ; Value accumulator
    move.l d0,d1
.parse_loop:
    move.b (a1)+,d1
    cmp.b  #'0',d1
    blo    .num_done
    cmp.b  #'9',d1
    bhi    .num_done

    lsl.l  #1,d0            ; *10
    move.l d0,d2
    lsl.l  #2,d0
    add.l  d2,d0

    subi.b #'0',d1
    add.l  d1,d0
    bra    .parse_loop
.num_done:
    movem.l (a7)+,d1-d2
    rts
    
file_error:
    lea    str_error,a1     ; Print cstring
    move.l #13,d0
    trap   #15
    SIMHALT

filename:
    DC.B   '4A_input.txt',0
str_error:
    DC.B   'Error :( See d0',0
    
line_buffer: DS.B 25
input_data: DS.B 8192
    END    START





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
