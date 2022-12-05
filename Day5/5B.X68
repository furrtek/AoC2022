*-----------------------------------------------------------
* Title      : AoC2022 #5B
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
    move.l d4,d6            ; Entry counter
    lea    input_data,a0
    
.read_line:
    move.l #53,d0           ; Read 64 bytes from file
    lea    line_buffer,a1
    move.l #64,d2
    trap   #15
    cmp.w  #1,d0
    bhi    file_error
    cmp.b  #1,d0
    beq    .read_done       ; Nothing left to read

    lea    5(a1),a1         ; Skip "move "
    jsr    parse_num
    move.b d0,(a0)+         ; Number of crates to move
    lea    5(a1),a1         ; Skip "from "
    jsr    parse_num
    subq.b #1,d0
    move.b d0,(a0)+         ; Source stack
    lea    3(a1),a1         ; Skip "to "
    jsr    parse_num
    subq.b #1,d0
    move.b d0,(a0)+         ; Dest stack

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
    
    ; Load initial data in buffer, clear unused space
    lea    initial_data,a0
    lea    buffer+1,a1
    move.l #0,d1
    move.l d1,d4            ; Stack counter
.load:
    move.l #1,d2            ; Reset stack size (+1 to skip size byte)
    move.w #256,d7          ; Total dedicated bytes per stack
.copy:
    move.b (a0)+,d0
    beq    .clear
    move.b d0,(a1)+
    addq.b #1,d2
    subq.w #1,d7
    bra    .copy
.clear:
    move.b d1,(a1)+
    subq.w #1,d7
    bne    .clear
    move.b d2,-257(a1)      ; Store stack size at beginning of block
    addq.l #1,d4
    tst.b  (a0)
    bne    .load
    
    ; Process data
    lea    input_data,a0
.process:
    move.l #0,d0
    move.l d0,d7
    move.b (a0),d3          ; Number of crates to move
    
    move.b 1(a0),d0         ; Source stack number
    lsl.w  #8,d0            ; 256 bytes per stack
    addi.l #buffer,d0
    move.l d0,a1
    move.l d7,d0
    move.b (a1),d0          ; Get current size    
    sub.b  d3,(a1)          ; Update src size in advance (easier now)
    add.l  d0,a1            ; Go to end
        
    move.l d7,d0
    move.b 2(a0),d0         ; Destination stack number
    lsl.w  #8,d0            ; 256 bytes per stack
    addi.l #buffer,d0
    move.l d0,a2
    move.l d7,d0
    move.b (a2),d0          ; Get current size
    add.b  d3,(a2)          ; Update dest size in advance (easier now)
    add.l  d0,a2            ; Go to end

    sub.l  d3,a1
    
    ; a1 points to end of src - number of crates to move
    ; a2 points to end of dest
.move:
    move.b (a1)+,(a2)+      ; Forward copy
    subq.b #1,d3
    bne    .move

    lea 3(a0),a0            ; Next operation
    subq.l #1,d6
    bne    .process

    ; Display
    lea    buffer,a0
    move.l #0,d0
.disp:
    move.l a0,a1
    move.b (a1),d0          ; Get size
    add.l  d0,a1
    move.b -(a1),d1         ; Read last char
    move.l #6,d0            ; Display
    trap   #15
    
    lea    256(a0),a0       ; Next block
    subq.w #1,d4
    bne    .disp
    
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
    DC.B   '5A_input.txt',0
str_error:
    DC.B   'Error :( See d0',0
    ; Initial data copied here by hand because .|..
initial_data:
    DC.B   'NBDTVGZJ',0     ; Zero means end of stack
    DC.B   'SRMDWPF',0
    DC.B   'VCRSZ',0
    DC.B   'RTJZPHG',0
    DC.B   'TCJNDZQF',0
    DC.B   'NVPWGSFM',0
    DC.B   'GCVBPQ',0
    DC.B   'ZBPN',0
    DC.B   'WPJ',0,0        ; Double zero means end of data
line_buffer: DS.B 64
input_data: DS.B 8192
buffer: DS.B 8192           ; Stack blocks, max 255 crates per stack (first byte is current size + 1)
    END    START







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
