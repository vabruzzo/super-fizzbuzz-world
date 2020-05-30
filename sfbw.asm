; Super FizzBuzz World

; $7E0019 - player powerup status, #$00 = small, #$01 = big, #$02 = cape, #$03 = fire
; $7E0DBF - current player coin count

ORG $000000               ; address to insert code, coin counter
autoclean JSL FizzBuzz    ; jump to custom code

freecode                  ; tells assembler to place our code in free space in ROM

FizzBuzz:
LDA $7E0DBF
JSR Modulus3
BEQ SetBigMario
LDA $7E0DBF
JSR Modulus5
BEQ SetCapeMario
LDA $7E0DBF
JSR Modulus15
BEQ SetFireMario
RTL

SetBigMario:
LDX #$01
STX $7E0019

SetCapeMario:
LDX #$02
STX $7E0019

SetFireMario:
LDX #$03
STX $7E0019

Modulus3:
SEC
SBC #03
BCS Modulus3
ADC #03
RTS

Modulus5:
SEC
SBC #05
BCS Modulus3
ADC #05
RTS

Modulus5:
SEC
SBC #0E
BCS Modulus3
ADC #0E
RTS