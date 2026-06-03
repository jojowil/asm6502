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
; Note that much of the logic has changed since we're not using
; BASIC style movement. We are dropping characters directly into
; screen memory which changes things considerably, especially
; the speed!
;
; Line numbers are provided in the code that loosely match the
; intent of the original code. Again, this changes a lot due
; to the nature of the differences in approaches to the logic.
;

define linprt $bdcd ; print XA (LE) as int
define chrout $ffd2
define lowup  14    ; PETSCII for lower/upper
define upgra  142   ; PETSCII for upper/graphic

;
; Notes on variables from the original source.
;
; a is the length of leading spaces.
; b is the column.
; c is the length of vertical text after a.
; ac is the start of trailing spaces until bottom.
; d & e were removed.

;
; Register safety
;
; Where possible register preservation is provided.
; You'll see a lot of TXA, PHA and PLA, TAX code that
; performs the preservation. We're not concerned about
; the speed here.

;
; Application speed;
;
; We've used spin loops to control the speed. There is a preset
; that's rather fast. The up and down arrows can be used to
; change the speed of the display. It ranges from 1 to 30
; internally. The start is about mid and is equivalent to the
; BASIC speed, which generally could not be made faster.
;

; line 20
main:
    jsr save    ; save colors and charset
    lda #0      ; black
    sta 53281   ; set background
    sta 53280   ; set border
    lda #5      ; green
    sta 646     ; set text
    jsr clrscr  ; clear screen AFTER setting text color!
    lda #14
    jsr chrout  ; set lower/upper charset
    jsr rseed   ; setup rand gen

; line 30
loop:
    jsr rnd     ; get rand num into A
    jsr moda
    cmp #0
    beq loop    ; no zeroes
    sta a       ; starting row
    lda #23
    sec
    sbc a
    sta $fb
    jsr rnd
    jsr modfb   ; rnd of 23-a
    cmp #0
    beq loop    ; no zeroes
    sta c       ; length of char column
    clc
    adc a
    sta ac      ; store a+c
    jsr rnd
    jsr modb
    sta b       ; starting column - can be 0

; line 40 - move down using blanks to reduce clutter
topspc:
    ldx #0
tspcloop:
    txa
    pha
    lda #32     ; spaces
    ldy b
    jsr putxy
    pla
    tax
    inx
    cpx a
    bne tspcloop

; line 50 - print chars in column
pchrs:
    ldx a
pchrloop:
    txa
    pha
    pha
    jsr rnd
    jsr modch
    sta ch
    ldy b
    pla
    tax
    lda ch
    jsr putxy
    pla
    tax
    inx
    cpx ac
    bne pchrloop

; line 60 - check range of c
range:
    ;lda ac
    ;cmp #0      ; c < 0?
    ;bmi loop
    ;clc
    ;adc a
    ;cmp #22     ; c > 22?
    ;bpl loop

; line 70 - print more blanks to reduce clutter
btmspc:
    ;lda a
    ;clc
    ;adc c
    ;sta e       ; e = (a+c)
    ;sta ac
    ;lda #22
    ;sec
    ;sbc e       ; 23-(a+c)
    ;sta e       ; store in e

    ldx ac      ; after top spaces and chars
bspcloop:
    txa
    pha
    lda #32     ; spaces
    ldy b
    jsr putxy
    pla
    tax
    inx
    cpx #23
    bpl bldone
    bne bspcloop

bldone:
    bit chdbg
    bpl chkkey
    jsr chdebug

chkkey:
    jsr $ffe4   ; check for char
    cmp #$03    ; run/stop? (esc in emulators)
    beq done    ; yes
    bit chdbg   ; print char debug and step?
    bpl nowait
    cmp #32
    bne chkkey
nowait:
    bit spdbg   ; print speed debug?
    bpl nospeed
    jsr prtspdbg
nospeed:
    cmp #17     ; down arrow to decrease spin
    bne nodown
    lda outer
    cmp #1
    beq nomore
    dec outer
    jmp nomore
nodown:
    cmp #145    ; up arrow to increase spin
    bne nomore
    lda outer
    cmp #30
    beq nomore
    inc outer
nomore:
    jmp loop

done:
    jsr rest    ; restore colors and charset

exit:
    rts         ; BYE!

;
; Routine to home cursor
;
home:
    pha
    lda #19
    jsr chrout
    pla
    rts

;
; Routine to clear the screen
;
clrscr:
    pha
    lda #147
    jsr chrout
    pla
    rts

;
; Debug speed spin loop
;
prtspdbg:
    pha
    jsr home
    jsr printspc
    lda outer
    jsr printa
    pla
    rts

;
; Debug statements to see vars
;
chdebug:
    pha
    jsr home
    jsr printspc
    jsr printspc
    jsr printspc
    jsr printspc
    jsr chrout
    lda a
    jsr printa
    lda b
    jsr printa
    lda c
    jsr printa
    lda ac
    jsr printa
    lda #13
    jsr crlf
    pla
    rts

;
; multi-entrypoint routine for different mod calcs
; clobbers x
;
moda:
    ldx #11
    bne stfb

modb:
    ldx #40
    bne stfb

modch:
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
    lda 53272
    and #2
    sta chset
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
    lda 53272
    ora chset
    sta 53272
    rts

;
; print value in A extended to XA (LE)
; clobbers A, X
;
printa:
    tax
    lda #0
    jsr linprt
    jsr crlf
    rts

;
; print CR-LF, preserves A
;
crlf:
    pha
    lda #13
    jsr chrout
    pla
    rts

;
; routine to put a screen char in A at row X, col Y
; screen addr in $fc, $fd
;
putxy:
    sta ch
    stx row
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
    jsr spin
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
    rts

;
; Spin loop to create delay - preserves A, X, Y
;
spin:
    pha
    txa
    pha
    tya
    pha
    ldy outer
    ldx #15
 spinloop:
    dex
    bne spinloop
    dey
    bne spinloop
    pla
    tay
    pla
    tax
    pla
    rts

;
; Print debug spaces - preserves X and A.
;
printspc:
    pha
    txa
    pha
    ldx #0
prtloop:
    lda spaces,x
    beq prdone
    jsr chrout
    inx
    jmp prtloop
prdone:
    pla
    tax
    pla
    rts

;
; variables
;
txtcol: dcb 0   ; saved text color
bdrcol: dcb 0   ; saved border color
scrcol: dcb 0   ; saved screen color
chset:  dcb 0   ; saved character set
a:      dcb 0   ; var a from BASIC
ac:     dcb 0   ; a+c
b:      dcb 0   ; var b from BASIC
c:      dcb 0   ; var c from BASIC
row:    dcb 0   ; row for screen code
ch:     dcb 0   ; the screen code
spaces: txt "    "
        dcb 13
        dcb 0
chdbg:  dcb 0   ; character debug (128 to debug)
spdbg:  dcb 0   ; speed debug (128 to debug)
outer:  dcb 15  ; outer loop value (1-30) for the spin loop