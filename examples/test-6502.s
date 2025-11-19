.org $5000
.p02

.define linprt $bdcd
.define chrout $ffd2
.define strout $ab1e

        ; print num1 - use BASIC routine
 START:       ldx mpr
        lda #0
        jsr linprt
        lda #13
        jsr chrout

        ; print num2 - use BASIC routine
        ldx mpd
        lda #0
        jsr linprt
        lda #13
        jsr chrout

START:  LDA     #0       ; zero accumulator
        STA     tmp      ; clear address
        STA     result   ; clear
        STA     result+1 ; clear
        LDX     #8       ; x is a counter
MULT:   LSR     mpr      ; shift mpr right - pushing a bit into C
        BCC     NOADD    ; test carry bit
        LDA     result   ; load A with low part of result
        CLC
        ADC     mpd      ; add mpd to res
        STA     result   ; save result
        LDA     result+1 ; add rest off shifted mpd
        ADC     tmp
        STA     result+1
NOADD:  ASL     mpd      ; shift mpd left, ready for next "loop"
        ROL     tmp      ; save bit from mpd into temp
        DEX              ; decrement counter
        BNE     MULT     ; go again if counter 0

        ; print num2 - use BASIC routine
        ldx result
        lda result+1
        jsr linprt
        lda #13
        jsr chrout

        rts

tmp:    .byte 0
result: .word 0
mpr:    .byte 150
mpd:    .byte 210