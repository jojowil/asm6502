;********************************************************************
; Decimal number printing example
; by ccr/TNSP^PWP <ccr@tnsp.org>
;********************************************************************

k_print_chr = $ffd2
qzptmp = $fb ; zero page address used as temporary storage


;====================================================================

	orig = $1000
	.word orig
	* = orig

start:
	; Print a 16-bit value
	ldy #$00 ; HI
	lda #$f0 ; LO
	jsr lib_print_dec_16

	; Next line
	lda #13
	jsr k_print_chr

	rts


;====================================================================
; Prints a 8bit value in decimal
; A = value
lib_print_dec_8:
	sta qzptmp
	lda #0
	sta qzptmp+1

	; Set Y register, indexing the division table, to 2
	; as the max divisor for 8-bit value is 100
	ldy #2
	jmp qdivloop


;====================================================================
; Prints a 16bit value in decimal
; A = low byte of value
; Y = high byte
;====================================================================
lib_print_dec_16:
	; Store value to a temporary location
	sty qzptmp+1
	sta qzptmp

	; Set Y register, indexing the division table, to 0
	ldy #0

	; Division loop for each digit
qdivloop:

	; Setup self-modifying code
	lda qdivtab_hi, y
	sta qp_hi+1
	sta qd_hi+1

	lda qdivtab_lo, y
	sta qp_lo+1
	sta qd_lo+1

	ldx #0

qcheck:
	; Check if value is larger or equal than divisor
	lda qzptmp+1
qp_hi:	cmp #0
	bcc qsmaller
	bne qbigger

	lda qzptmp
qp_lo:	cmp #0
	bcc qsmaller

	; It is larger or equal, substract divisor from it
	sec
qbigger:
	lda qzptmp
qd_lo:	sbc #0
	sta qzptmp

	lda qzptmp+1
qd_hi:	sbc #0
	sta qzptmp+1

	; Increase X
	inx
	jmp qcheck

qsmaller:
	; Now we have the count of how many times the divisor "fit"
	; into the divident in X register, so we can print it
	sta qsav_a+1
	stx qsav_x+1
	sty qsav_y+1

	; Add '0' (=$30 PETSCII) to convert to PETSCII numeric digit
	; and call KERNAL routine to print it
	txa
	clc
	adc #$30
	jsr k_print_chr

qsav_a: lda #0
qsav_x: ldx #0
qsav_y: ldy #0

	; Then continue to next digit until we have gone through 5
	; which is the max for 16bit number
	iny
	cpy #5
	bcc qdivloop
	rts

; Tables for the divisor values: 10000 ($2710), 1000 ($03e8), 100, 10, 1
qdivtab_hi:	.byte $27, $03, $00, $00, $00
qdivtab_lo:	.byte $10, $e8, $64, $0a, $01
