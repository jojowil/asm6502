
	*= $033c

start:      sei            ; turn off
            lda #$49
            sta $0314      ; store lobyte
            lda #$03
            sta $0315      ; store hibyte
            cli
            rts

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

            lda $dc08      ; restart clock
            lda $dc0b      ; load hours
            and #$80       ; keep hi bit
            bne pm
            lda #$01       ; load 'a'
            bne notpm
pm:         lda #$10        ; load 'p'
notpm:      sta $0427      ; end of box
            jmp $ea31