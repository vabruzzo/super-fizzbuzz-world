; Super FizzBuzz World

; $7E0019 - player powerup status, #$00 = small, #$01 = big, #$02 = cape, #$03 = fire
; $7E0DBF - current player coin count

ORG $008F25               ; SWM RAM address to insert our code (increase coins by 1 subroutine)
autoclean JSL FizzBuzz    ; jump to custom code
NOP                       ; no-ops to take up some empty space caused by our hijack
NOP                       ; the code we hijack is 6 bytes, the JSL we inject is 4, so we add 2 bytes

freecode                  ; tells assembler to place our code in free space in ROM

FizzBuzz:
INC $0DBF               ; we hijacked this code so we do it here, it adds 1 to coin count
LDA $7E0DBF               ; load coin count into A
LDX #$00                  ; load 01 into X register
STX $19
JSR Modulus3              ; jump to Modulus3 subroutine down below
BNE CheckModulus5           ; if Modulus3 set A to 0, set status to big
LDX #$01                  ; load 01 into X register
STX $19                   ; store the value of X register (01) into powerup status address
CheckModulus5:
LDA $7E0DBF               ; load coin count back into A since Modulus3 subroutine overwrote it
JSR Modulus5              ; jump to Modulus5
BNE CheckModulus15          ; if 0, set status to cape
LDX #$02
STX $19
CheckModulus15:
LDA $7E0DBF               ; load coin count back into A
JSR Modulus15
BNE Return
LDX #$03
STX $19
Return:
LDA $7E0DBF               ; load the coin count back into A since we hijacked this
RTL                       ; return to where we hijacked the code

Modulus3:
SEC
SBC #$03
BCS Modulus3
ADC #$03
RTS

Modulus5:
SEC
SBC #$05
BCS Modulus5
ADC #$05
RTS

Modulus15:
SEC
SBC #$0F
BCS Modulus15
ADC #$0F
RTS
