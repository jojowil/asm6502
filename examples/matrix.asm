*= $4000

;
; Convered BASIC program to 6502 Assembler
; 20 printchr$(147):poke646,5:poke53281,0:poke53280,0
; 30 a=int(rnd(0)*22):b=int(rnd(0)*39):c=int(rnd(0)*22-a)
; 40 print"{home}":ford=1toa:printtab(b);chr$(32):next
; 50 ford=0toc:printtab(b);chr$(int(rnd(0)*57+33)):next
; 60 ifc<0or(a+c)>20goto30
; 70 e=21-(a+c):ford=1toe:printtab(b);chr$(32):next:goto30
;

define linprt $bdcd   ; print XA (LE) as int
define chrout $ffd2

main:   jsr clrscr  ; clear screen
        jsr save    ; save colors
        lda #0      ; black
        sta 53281   ; set background
        sta 53280   ; set border
        lda #5      ; green
        sta 646     ; set text
        jsr rseed   ; setup rnd gen

        jsr mod39

loop:   jsr rnd     ; get rnd num
        jsr modfb
        tax         ; low order
        lda #0      ; high order zero for LE
        jsr linprt  ; print int
        lda #13     ; CR
        jsr chrout  ; print
        jsr $ffe4   ; check for char
        cmp #$03    ; run/stop?
        beq done    ; yes
        jmp loop

done:   jsr rest    ; restore colors

exit:   rts         ; BYE!

clrscr: lda #147
        jsr chrout
        rts

mod22:  lda #22
        bne stfb
mod39:  lda #39
        bne stfb
mod57:  lda #57
        bne stfb
stfb:   sta $fb
modfb:  cmp $fb
        bcc mfbend
        sbc $fb
        clc
        bcc modfb   ; always clear, -1 byte vs jmp
mfbend: rts

save:   lda 646
        sta txtcol
        lda 53281
        sta scrcol
        lda 53280
        sta bdrcol
        rts

rest:   lda txtcol
        sta 646
        lda scrcol
        sta 53281
        lda bdrcol
        sta 53280
        rts

wait:   jsr $ffe4   ; check for char
        cmp #$03    ; run/stop?
        bne wait    ; no
        rts         ; yes!

rseed:  lda #$ff    ; Set maximum frequency
        sta $D40E   ; Voice 3 frequency low byte
        sta $D40F   ; Voice 3 frequency high byte
        lda #$80    ; Noise waveform bit
        sta $D412   ; Voice 3 control register
        rts

rnd:    lda $d41b
        rts

txtcol: dcb 0
bdrcol: dcb 0
scrcol: dcb 0