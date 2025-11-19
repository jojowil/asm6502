*= $5000

define linprt $bdcd
define chrout $ffd2
define strout $ab1e

        ; print num1 - use BASIC routine
        ldx mpr
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
        STA     TMP      ; clear address
        STA     RESULT   ; clear
        STA     RESULT+1 ; clear
        LDX     #8       ; x is a counter
MULT:   LSR     MPR      ; shift mpr right - pushing a bit into C
        BCC     NOADD    ; test carry bit
        LDA     RESULT   ; load A with low part of result
        CLC
        ADC     MPD      ; add mpd to res
        STA     RESULT   ; save result
        LDA     RESULT+1 ; add rest off shifted mpd
        ADC     TMP
        STA     RESULT+1
NOADD:  ASL     MPD      ; shift mpd left, ready for next "loop"
        ROL     TMP      ; save bit from mpd into temp
        DEX              ; decrement counter
        BNE     MULT     ; go again if counter 0

        ; print num2 - use BASIC routine
        ldx result
        lda result+1
        jsr linprt
        lda #13
        jsr chrout

        rts

tmp:    dsb 1
result: dsb 2
mpr:    dcb 150
mpd:    dcb 210