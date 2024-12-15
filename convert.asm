*= $4000

define linprt $bdcd   ; print XA (LE) as int
define chrout $ffd2

        lda #147        ; clear the screen
        jsr chrout

; convert decimal string
one:    ldx #0
p1:     lda ns1,x       ; get a char
        beq print1      ; end of string?

        ; multiply by 10; copy value
        lda num1
        sta tmp
        lda num1+1
        sta tmp+1
        ; add 9 more times
        ldy #9
more:   clc
        lda tmp
        adc num1
        sta num1
        lda tmp+1
        adc num1+1
        sta num1+1
        dey
        bne more        ; finish the adds

        lda ns1,x       ; add new digit
        sec
        sbc #$30        ; subtract '0'
        clc
        adc num1
        sta num1
        lda #0
        adc num1+1
        sta num1+1
        inx
        jmp p1

print1: ldx num1
        lda num1+1
        jsr linprt      ; print the number
        lda #13         ; CR
        jsr chrout

; convert binary string
two:    ldx #0
p2:     lda ns2,x
        beq print2
        ; subtract the '0' from the digit
        sec
        sbc #$30
        ; multiply by 2
        asl num2
        rol num2+1
        ; add the new digit
        clc
        adc num2
        sta num2
        lda #0
        adc num2+1
        sta num2+1
        inx
        jmp p2

print2: ldx num2
        lda num2+1
        jsr linprt
        lda #13         ; CR
        jsr chrout

add:    clc
        lda num1
        adc num2
        sta sum
        lda num1+1
        adc num2+1
        sta sum+1

print3: ldx sum
        lda sum+1
        jsr linprt
        lda #13         ; CR
        jsr chrout

        ; and we're done!
end:    rts

; data area

ns1:    txt "4302"
        dcb 0
ns2:    txt "10101101"
        dcb 0

num1:   dcw 0
num2:   dcw 0
tmp:    dcw 0
sum:    dcw 0