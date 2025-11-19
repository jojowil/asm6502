         *= $4000

define linprt $bdcd
define chrout $ffd2

         ldx num1
         lda num1+1
         jsr printxa
         ldx num2
         lda num2+1
         jsr printxa

adding:  clc
         lda num2
         adc num1
         sta sum
         lda num2+1
         adc num1+1
         sta sum+1

         ; this is printing the sum
prtsum:  ldx sum
         lda sum+1
printxa: jsr linprt

         lda #13
         jmp chrout  ; rts from call

         rts

num1:    dcw 3650
num2:    dcw 1217
sum:     dcw 0
