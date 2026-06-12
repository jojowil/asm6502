; ==============================================================================
; COMMODORE 64 ASSEMBLER SPRITE EXAMPLE
; ==============================================================================

; --- VIC-II Register Constants ---
VIC_BASE      = $d000
SPRITE0_X     = VIC_BASE + $00  ; X coordinate for Sprite 0
SPRITE0_Y     = VIC_BASE + $01  ; Y coordinate for Sprite 0
SPRITE_MSB    = VIC_BASE + $10  ; Most Significant Bits for X coordinates
SPRITE_ENABLE = VIC_BASE + $15  ; Sprite enable register (1 bit per sprite)
SPRITE0_COLOR = VIC_BASE + $27  ; Color register for Sprite 0

; --- Screen Memory Pointer ---
SPRITE_PTR0   = $07f8           ; Sprite 0 pointer (Default Screen RAM $0400 + $03f8)

; --- Program Origin ---
* = $0801                       ; Standard BASIC Upstart stub area
                                ; (SYS 2064 to run from BASIC)
        .byte $0c, $08, $0a, $00, $9e, $20, $32, $30, $36, $34, $00, $00, $00

* = $0810                       ; Main code assembly location ($0810 / 2064)

init_sprite:
        ; 1. Set the Sprite Pointer
        ; We will put our sprite data at memory block $2000.
        ; $2000 / 64 bytes per block = 128 ($80)
        lda #$80
        sta SPRITE_PTR0

        ; 2. Define Sprite Coordinates
        ; Position X = 160, Position Y = 120 (Centered on standard screen)
        lda #160
        sta SPRITE0_X
        lda #120
        sta SPRITE0_Y

        ; Clear MSB (Most Significant Bit) for Sprite 0 X position.
        ; Required because C64 X-coordinates can exceed 255 (up to 320/504).
        lda #$00
        sta SPRITE_MSB

        ; 3. Set Sprite Color
        ; Assign Sprite 0 to be White (#$01)
        lda #$01
        sta SPRITE0_COLOR

        ; 4. Turn On the Sprite
        ; Set bit 0 of $D015 to enable Sprite 0
        lda #%00000001
        sta SPRITE_ENABLE

loop:
        jmp loop                ; Infinite loop to keep the program running


; ==============================================================================
; SPRITE DATA SELECTION BLOCK
; ==============================================================================
* = $2000                       ; Sprite data boundary matching our pointer ($80)

; 24x21 Pixels. Every row is 3 bytes wide. Total = 63 bytes + 1 padding byte.
; This pattern creates a 24x21 filled block with a cross symbol in the middle.
sprite_data:
        .byte $ff, $ff, $ff     ; Row 1  (Solid top boundary)
        .byte $80, $18, $01     ; Row 2
        .byte $80, $18, $01     ; Row 3
        .byte $80, $18, $01     ; Row 4
        .byte $80, $18, $01     ; Row 5
        .byte $80, $18, $01     ; Row 6
        .byte $80, $18, $01     ; Row 7
        .byte $80, $18, $01     ; Row 8
        .byte $8f, $ff, $f1     ; Row 9  (Horizontal crossbar)
        .byte $8f, $ff, $f1     ; Row 10 (Horizontal crossbar)
        .byte $80, $18, $01     ; Row 11
        .byte $80, $18, $01     ; Row 12
        .byte $80, $18, $01     ; Row 13
        .byte $80, $18, $01     ; Row 14
        .byte $80, $18, $01     ; Row 15
        .byte $80, $18, $01     ; Row 16
        .byte $80, $18, $01     ; Row 17
        .byte $80, $18, $01     ; Row 18
        .byte $80, $18, $01     ; Row 19
        .byte $80, $18, $01     ; Row 20
        .byte $ff, $ff, $ff     ; Row 21 (Solid bottom boundary)
        .byte $00               ; Extra 64th padding byte required per sprite block
