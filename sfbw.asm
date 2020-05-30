; Super FizzBuzz World

; $7E0019 - player powerup status, #$00 = small, #$01 = big, #$02 = cape, #$03 = fire
; $7E0DBF - current player coin count

ORG $008F25               ; SWM RAM address to insert our code (increase coins by 1 subroutine)
autoclean JSL FizzBuzz    ; jump to custom code
NOP                       ; no-ops to take up some empty space caused by our hijack, i.e.,
NOP                       ; the code we hijack is 6 bytes, the JSL we inject is 4, so we add 2 bytes

freecode                  ; tells assembler to place remaining code in free space in ROM

FizzBuzz:
INC $0DBF                 ; we overwrote this code so we do it here, it adds 1 to coin count
LDA $7E0DBF               ; load coin count into A register
LDX #$00                  ; load 0 into X register
STX $19                   ; store value of X register (0) to powerup status to default to small
JSR Modulus3              ; jump to Modulus3 subroutine down below
BNE CheckModulus5         ; if coin count mod 3 was not 0, skip to next check, otherwise set to big
LDX #$01                  ; load 01 into X register
STX $19                   ; store the value of X register (01) into powerup status to set big
CheckModulus5:
LDA $7E0DBF               ; load coin count back into A since Modulus3 subroutine overwrote it
JSR Modulus5              ; jump to Modulus5
BNE CheckModulus15        ; if coin count mod 5 was not 0, skip to next check, otherwise set to cape
LDX #$02                  ; load 02 into X register
STX $19                   ; store the value of X register (02) into powerup status to set cape
CheckModulus15:
LDA $7E0DBF               ; load coin count back into A
JSR Modulus15             ; jump to Modulus15
BNE Return                ; if coin count mod 15 was not 0, skip to return, otherwise set to fire
LDX #$03                  ; load 03 into X register
STX $19                   ; store the value of X register (03) into powerup status to set fire
Return:
LDA $7E0DBF               ; load the coin count back into A so the code we hijacked can continue
RTL                       ; return to where we hijacked the code

Modulus3:
SEC                       ; set the carry flag
SBC #$03                  ; subtract 3 from the A register, i.e. the coin count
BCS Modulus3              ; if carry flag is set, go back to Modulus3, otherwise proceed
ADC #$03                  ; add 3 back to A
RTS                       ; return to where we left off above

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
