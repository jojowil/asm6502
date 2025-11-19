*= $4000

define linprt $bdcd
define chrout $ffd2
define strout $ab1e

            ; clear the screen
            lda #147
            jsr chrout

            ; print num1 - use BASIC routine
            lda #<txt1
            ldy #>txt1
            jsr strout

            ldx #0
            ldx num1
            lda num1+1
            jsr printxa

            ; print num2 - use absolute indexed
            ldx #0
loop1:      lda txt2,x
            beq num
            jsr chrout
            inx
            bne loop1

num:        ldx num2
            lda num2+1
            jsr printxa

adding:     clc
            lda num2
            adc num1
            sta sum
            lda num2+1
            adc num1+1
            sta sum+1

            ; print the sum - use ZP indirect indexed
            lda #<txt3
            sta $fb
            lda #>txt3
            sta $fc
            ldy #0

loop2:      lda ($fb),y
            beq prtsum   ; stop on zero byte
            jsr chrout
            iny
            bne loop2

prtsum:     ldx sum
            lda sum+1

printxa:    jsr linprt

            lda #13
            jmp chrout  ; rts from call

            rts

; data!
; $3650
num1:       dcw $3650


; $1217
num2:       dcw $1217

; sum
sum:      dsb 2

txt1:       txt "first number: "
            dcb 0
txt2:       txt "second number: "
            dcb 0
txt3:       txt "sum: "
            dcb 0