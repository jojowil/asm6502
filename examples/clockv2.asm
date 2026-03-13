;
; tape buffer is 033c-03fb (828-1019) 192 bytes

	*= $033c

; dc08 - BCD 10ths of seconds (read to restart clock)
; dc09 - BCD seconds (bit7:0)
; dc0a - BCD minutes (bit7:0)
; dc0b - BCD hours   (bit7:0-AM, 1-PM)
; Writing hours stops the clock until dc08 read.

start:      sei            ; turn off
            lda #$49
            sta $0314      ; store lobyte
            lda #$03
            sta $0315      ; store hibyte
            cli
            rts

check:      lda $dc09
            cmp seconds    ; changed?
            beq end        ; nope
            sta seconds

clock:      lda #103       ; left border
            sta $0420      ; &
            lda #$00       ; load black
            sta $d820

            ldx #$06       ; rowsize-1
            lda #99	       ; bottom border
loop1:      sta $0449,x    ; &&&&&&&&
            dex
            bpl loop1      ; loop 7 times

            lda #$00       ; load black
            ldx #$06       ; rowsize-1
loop2:      sta $d821,x    ; @@@@@@@@
            sta $d849,x    ; @@@@@@@@
            dex
            bpl loop2      ; loop 8 times

            ldx #$00       ; start of window
            ldy #$02       ; numbytes-1
loop3:      lda $dc09,y    ; load tod,y
            and #$7f       ; strip hi bit
            pha            ; store it
            lsr
            lsr
            lsr            ; get to
            lsr            ; hi nybble
            ora #$30       ; go ascii
            sta $0421,x    ; inside box
            pla            ; get save value
            and #$0f       ; get lo nybble
            ora #$30       ; go ascii
            inx            ; bump box pointer
            sta $0421,x    ; inside box
            inx
            dey
            bpl loop3

            lda $dc0b      ; load hours
            and #$80       ; keep hi bit
            bne pm
            lda #$01       ; load 'a'
            bne notpm
pm:         lda #$10        ; load 'p'
notpm:      sta $0427      ; end of box

end:        lda $dc08
            jmp $ea31

seconds:    dsb 1