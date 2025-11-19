define CHROUT $FFD2

    *=3000

    ; print a byte as hex using BCD
    LDA #$A3
    PHA     ; save byte
    LSR     ; get hi nybble
    LSR
    LSR
    LSR
    JSR prtdigit
    PLA     ; restore byte
    AND #15 ; low nybble
    JSR prtdigit
    BRK

prtdigit:
    SED     ; using BCD!
    CLC
    ADC #$90    ; Produce &90-&99 or &00-&05
    ADC #$40    ; Produce &30-&39 or &41-&46
    CLD     ; done with BCD!
    JMP CHROUT  ; using RTS to return




define CHROUT $ffd2


    ; print a byte as hex using ASCII
    LDA #$a3
    PHA
    LSR
    LSR
    LSR
    LSR
    JSR prdigit
    PLA
    AND #15
    JSR prdigit
    BRK


prdigit:
    CMP #10
    BCC nofix   ; 0-9?
    ADC #6      ; nope, Convert ':' to 'A'
nofix:
    ADC #$30    ; ASCII '0'
    JMP CHROUT