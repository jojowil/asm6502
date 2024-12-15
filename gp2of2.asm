*= $3000

define chrout $ffd2
; zp FB-FE are safe for use
define zpa $fb

; setup (ZP),Y
        lda #<out1
        sta zpa
        lda #>out1
        sta zpa+1

        ldy #0
loop1:  lda (zpa),y
        beq done1
        jsr chrout
        iny
        jmp loop1
done1:  ldx #$00
loop2:  lda out2,x
        beq done2
        jsr chrout
        inx
        jmp loop2

; end program
done2:  rts

;
; data for message
;

out1:   dcb $20, $20, $20, $20, $D5, $C4, $C4, $C4, $C4, $C4, $C4, $C4
        dcb $C4, $C4, $C4, $C4, $C4, $C4, $C4, $C4, $C4, $C9, $0D ,$20
        dcb $20, $20, $20, $C7, $43, $4F, $4E, $47, $52, $41, $54, $55
        dcb $4C, $41, $54, $49, $4F, $4E, $53 ,$21, $C8, $0D, $00
out2:   dcb $20, $20, $20, $20, $C7, $20, $20, $20, $59, $4F, $55, $20
        dcb $44, $49, $44, $20, $49, $54, $21, $20, $20, $C8, $0D, $20
        dcb $20, $20, $20, $CA, $C6, $C6, $C6, $C6, $C6, $C6, $C6, $C6
        DCB $C6, $C6, $C6, $C6, $C6, $C6, $C6, $C6, $CB, $0D, $00