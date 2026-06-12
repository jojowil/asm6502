define chrout $ffd2

;===============

* = $3000

a3000:
    lda #$33
    jsr chrout      ; print '3'
    jmp a4000
    nop
    nop

;===============

* = $4000

a4000:
    lda #$34
    jsr chrout      ; print '4'
    jmp a5000

;===============

* = $5000

a5000:
    lda #$35
    jsr chrout      ; print '5'
    jmp ac000

;===============

* = $c000

ac000:
    lda #67
    jsr chrout      ; print 'C'
    lda #13
    jsr chrout      ; new line
    rts             ; done
