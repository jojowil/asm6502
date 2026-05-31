*= $4000

;
; Converted BASIC program to 6502 Assembler
; 20 printchr$(147):rem poke646,5:poke53281,0:poke53280,0
; 30 a=int(rnd(0)*22):b=int(rnd(0)*39):c=int(rnd(0)*22-a)
; 40 print"{home}":ifa>0thenford=0toa:printtab(b);chr$(32):next
; 50 ifc>0thenford=0toc:printtab(b);chr$(int(rnd(0)*57+33)):next
; 60 ifc<0or(a+c)>20goto30
; 70 e=21-(a+c):ford=1toe:printtab(b);chr$(32):next:goto30
;

define linprt $bdcd ; print XA (LE) as int
define chrout $ffd2
define lowup  14    ; PETSCII for lower/upper
define upgra  142   ; PETSCII for upper/graphic

; line 20
main:
    jsr save    ; save colors
    lda #0      ; black
    sta 53281   ; set background
    sta 53280   ; set border
    lda #5      ; green
    sta 646     ; set text
    jsr clrscr  ; clear screen AFTER setting text color!
    jsr rseed   ; setup rand gen

; line 30
loop:
    jsr rnd     ; get rand num into A
    jsr mod22
    sta a       ; starting row
    sta c       ; make copy
    jsr rnd
    jsr mod39
    sta b       ; starting column
    jsr rnd
    jsr mod22
    sec
    sbc c       ; c=int(rnd(0)*22-a)
    sta c       ; column height

    ;lda a
    ;jsr printa
    ;lda b
    ;jsr printa
    ;lda c
    ;jsr printa
    ;lda #13
    ;jsr crlf
    ;jmp chkstp

; line 40 - move down using blanks to reduce clutter
topspc:
    ldx a
    ;cpx #0
    bmi pchrs
tspcloop:
    txa
    pha
    lda #32     ; spaces
    ldy b
    jsr putxy
    pla
    tax
    dex
    bne tspcloop

; line 50 - print chars in column
pchrs:
    ldx c
    ;cpx #1
    bmi range
pchrloop:
    txa
    pha
    pha
    jsr rnd
    jsr mod91
    sta ch
    ldy b
    pla
    tax
    lda ch
    jsr putxy
    pla
    tax
    dex
    bne pchrloop

; line 60 - check range of c
range:
    lda c
    ;cmp #0      ; c < 0?
    bmi loop
    clc
    adc a
    cmp #20     ; c > 20?
    bpl loop

; line 70 - print more blanks to reduce clutter
btmspc:
    lda a
    clc
    adc c
    sta e       ; e = (a+c)
    lda #21
    sec
    sbc e       ; 21-(a+c)
    sta e       ; store in e

    ldx e
bspcloop:
    txa
    pha
    lda #32     ; spaces
    ldy b
    jsr putxy
    pla
    tax
    dex
    bne bspcloop

chkstp:
    jsr $ffe4   ; check for char
    cmp #$03    ; run/stop?
    beq done    ; yes
    jmp loop

done:
    jsr rest    ; restore colors

exit:
    rts         ; BYE!

clrscr:
    lda #147
    jsr chrout
    rts

;
; multi-entrypoint routine for different mod calcs
; clobbers x
;
mod22:
    ldx #22
    bne stfb

mod39:
    ldx #39
    bne stfb

mod57:
    ldx #57
    bne stfb

mod91:
    ldx #91
    bne stfb

stfb:
    stx $fb

modfb:
    cmp $fb
    bcc mfbend
    sbc $fb
    clc
    bcc modfb   ; always clear, -1 byte vs jmp
mfbend:
    rts

; routine to save screen colors
save:
    lda 646
    sta txtcol
    ;jsr printa
    lda 53281
    sta scrcol
    ;jsr printa
    lda 53280
    sta bdrcol
    ;jsr printa
    rts

;
; routine to restore screen colors
;
rest:
    lda txtcol
    sta 646
    ;jsr printa
    lda scrcol
    sta 53281
    ;jsr printa
    lda bdrcol
    sta 53280
    ;jsr printa
    rts

printa:
    tax
    lda #0
    jsr linprt
    jsr crlf
    rts

crlf:
    lda #13
    jsr chrout
    rts

;
; routine to put a screen char in A at row X, col Y
; screen addr in $fc, $fd
;
putxy:
    sta ch
    stx row
    sty col     ; FIXME: may not need this
    ; put $0400 in zp (LE) TODO: calculate the real base
    sty $fc     ; col added to base mem
    lda #4
    sta $fd
    ; use row to add multiples of 40
xyloop:
    cpx #0
    beq stch
    lda #40
    clc
    adc $fc
    sta $fc
    lda #0
    adc $fd
    sta $fd
    dex
    jmp xyloop
stch:
    lda ch
    sta ($fc,x)  ; X is zero from loop above
    rts

;
; routine to create 8-bit PRNG
;
rseed:
    lda #$ff    ; Set maximum frequency
    sta $D40E   ; Voice 3 frequency low byte
    sta $D40F   ; Voice 3 frequency high byte
    lda #$80    ; Noise waveform bit
    sta $D412   ; Voice 3 control register
    rts

;
; routine to get random byte into A
;
rnd:
    lda $d41b   ; randomized noise byte from voice 3
    and #$7f
    rts

;
; variables
;
txtcol: dcb 0
bdrcol: dcb 0   ; saved border color
scrcol: dcb 0   ; saved screen color
a:      dcb 0   ; var a from BASIC
b:      dcb 0   ; var b from BASIC
c:      dcb 0   ; var c from BASIC
d:      dcb 0   ; var d from BASIC
e:      dcb 0   ; var e from BASIC
row:    dcb 0   ; row for screen code
col:    dcb 0   ; column for screen code
ch:     dcb 0   ; the screen code