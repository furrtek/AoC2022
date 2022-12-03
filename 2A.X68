*-----------------------------------------------------------
* Title      : AoC2022 #2A
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

    move.b (a1),d0
    subi.b #'A',d0
    move.b d0,(a0)+

    lea    2(a1),a1
    
    move.b (a1),d0
    subi.b #'X',d0
    move.b d0,(a0)+
    
    addq.w #1,d6
    
    addi.l #4,d4            ; 3 chars + LF
    move.l d4,d2
    move.l #55,d0           ; Set file read position
    trap   #15
    
    bra    .read_line
    
.read_done:
    move.l #56,d0           ; Close file
    trap   #15
    
    ; Process input data
    lea    input_data,a0
    lea    lut_outcome,a1

    move.l #0,d4            ; Accumulator
    
.process:
    move.l #0,d0
    move.b (a0)+,d0         ; Opponent's choice
    move.b (a0)+,d1         ; Own choice
    
    add.b  d0,d0            ; d0 = (d0 << 2) | d1
    add.b  d0,d0
    or.b   d1,d0
    move.b (a1,d0),d0       ; d0 = lut_outcome[d0]
    move.b d0,d2
    add.b  d0,d0            ; d0 *= 3
    add.b  d2,d0
    add.b  d1,d0            ; Add (own choice + 1)
    addq.b #1,d0
    add.l  d0,d4
    
    subq.l #1,d6
    bne    .process
    
    move.l d4,d1    
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
    DC.B   '2A_input.txt',0
str_error:
    DC.B   'Error :( See d0',0
lut_outcome:
    DC.B   1    ; A X: Rock      vs Rock      Draw
    DC.B   2    ; A Y: Rock      vs Paper     Win
    DC.B   0    ; A Z: Rock      vs Scissors  Lose
    DC.B   0    ; Padding
    DC.B   0    ; B X: Paper     vs Rock      Lose
    DC.B   1    ; B Y: Paper     vs Paper     Draw
    DC.B   2    ; B Z: Paper     vs Scissors  Win
    DC.B   0    ; Padding
    DC.B   2    ; C X: Scissors  vs Rock      Win
    DC.B   0    ; C Y: Scissors  vs Paper     Lose
    DC.B   1    ; C Z: Scissors  vs Scissors  Draw
    DC.B   0    ; Padding
    
line_buffer: DS.B 256
input_data:  DS.L 4096
buffer:      DS.L 1024
    END    START



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
