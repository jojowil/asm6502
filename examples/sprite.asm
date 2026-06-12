; ==============================================================================
; C64 Sprite 0 Basic Example
; ==============================================================================


* = $1000                           ; Assembly program execution entry point ($080e / 2061)

main:
    ; 1. Set the Sprite Pointer
    ; We will put our sprite data at memory block $2000.
    ; $2000 / 64 bytes per block = 128 ($80)
    lda #$80
    sta $07f8

    ; 2. Set Sprite 0 Color
    ; Color register for Sprite 0 is $D027 (53287). Let's make it White ($01).
    lda #$01
    sta $d027

    ; 3. Position the Sprite on Screen
    ; Coordinates: X=$D000 (53248), Y=$D001 (53249)
    lda #150                        ; X Coordinate
    sta $d000
    lda #150                        ; Y Coordinate
    sta $d001

    ; 4. Enable Sprite 0
    ; Register $D015 (53269) controls the visibility of all 8 sprites.
    ; Bit 0 sets Sprite 0. Binary %00000001 = Hex $01
    lda #$01
    sta $d015

loop:
    rts
    ;jmp loop                        ; Loop indefinitely to keep the program running


; ==============================================================================
; SPRITE DATA SEGMENT (Must be placed exactly at $2000 to match pointer #$20)
; ==============================================================================
* = $2000

sprite_data:
    ; A single-color sprite requires 64 bytes total (24x21 pixels = 63 bytes + 1 pad byte)
    ; $FF turns all 8 horizontal pixels in that block "ON"
    dcb $FF, $FF, $FF             ; Row 1
    dcb $FF, $FF, $FF             ; Row 2
    dcb $FF, $FF, $FF             ; Row 3
    dcb $FF, $FF, $FF             ; Row 4
    dcb $FF, $FF, $FF             ; Row 5
    dcb $FF, $FF, $FF             ; Row 6
    dcb $FF, $FF, $FF             ; Row 7
    dcb $FF, $FF, $FF             ; Row 8
    dcb $FF, $FF, $FF             ; Row 9
    dcb $FF, $FF, $FF             ; Row 10
    dcb $FF, $FF, $FF             ; Row 11
    dcb $FF, $FF, $FF             ; Row 12
    dcb $FF, $FF, $FF             ; Row 13
    dcb $FF, $FF, $FF             ; Row 14
    dcb $FF, $FF, $FF             ; Row 15
    dcb $FF, $FF, $FF             ; Row 16
    dcb $FF, $FF, $FF             ; Row 17
    dcb $FF, $FF, $FF             ; Row 18
    dcb $FF, $FF, $FF             ; Row 19
    dcb $FF, $FF, $FF             ; Row 20
    dcb $FF, $FF, $FF             ; Row 21
    dcb $00                       ; 64th padding byte (required by VIC-II)
