define chrout $ffd2
define from $f9     ; $f9-$fa
define to   $fb     ; $fb-$fc
define size $fd     ; $fd-$fe

; $f7-$fa available (RS-232 I/O buffer)
; $fb-$fe FREE (Official)

; The relocation code is simple. Use a BASIC preamble with
; a simple (dest,size) relocatioon table. Move the blocks
; into place and exit.
; This is only used when there is more than one asm block.
; Multiple blocks could cause very large swaths of empty
; space leading to overwrites and a bloated PRG.

* = $0801

preamble:
    dcb     10, 8 , 0, 0, 158, 50, 48, 54, 49, 0, 0, 0    ; 0 sys2061

main:
    jmp relocate

; The table holds the destination address and the length
; of the code block. All the blocks are one after another.
; No additional data is needed given the simplicity of the
; C64 memory model.

asmtblsz:
    dsb 1               ; table size
asmtable:
    dsb 72              ; from, to, size. Max of 12 blocks.

relocate:
    ldy asmtblsz
    beq end             ; may not be needed
    ldx #$ff
next:
    inx
    lda asmtable, x
    sta from
    inx
    lda asmtable, x
    sta from+1

    inx
    lda asmtable, x
    sta to
    inx
    lda asmtable, x
    sta to+1

    inx
    lda asmtable, x
    sta size
    inx
    lda asmtable, x
    sta size+1

    jsr moveup
    dey
    bne next

end:
    rts

;===============

; Move memory up (adapted from https://6502.org/source/general/memory_move.html)
; Preserves all registers
; from = source start address
;   to = destination start address
; size = number of bytes to move
;
; The size can be viewed as the number of full pages (size+1)
; and a partial page (size). That's what makes this code elegant.
;
moveup:
    pha
    tya
    pha
    txa
    pha

    ; x is page number
    ldx size+1      ; the last bytes must be moved first
    clc             ; start at the final pages of FROM and TO
    txa
    adc from+1
    sta from+1
    clc
    txa
    adc to+1
    sta to+1
    inx             ; allows the use of BNE after the DEX below
    ldy size        ; low byte is a one time size.
    beq mu3
    dey             ; move bytes in the last page first
    beq mu2
mu1:
    lda (from),y
    sta (to),y
    dey
    bne mu1
mu2:
    lda (from),y    ; handle Y = 0 separately
    sta (to),y
mu3:
    dey             ; wraps back to $ff - full page
    dec from+1      ; move the next page (if any)
    dec to+1
    dex             ; decrease pages remaining
    bne mu1

    pla
    tax
    pla
    tay
    pla
    rts

;===============

after: