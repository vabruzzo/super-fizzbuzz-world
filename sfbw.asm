; FizzBuzz Mario World, a Super Mario World ROM patch
;
; on each coin count increase
;   if coin count is divisible by 3 and 5
;     set power-up status to fire
;   else if coin count is divisible by 5
;     set power-up status to cape
;   else if coin count is divisible by 3
;     set power-up status to big
;   else
;     set power-up status to small
;
; constants:
; power-up status address:
!PowerUpStatus = $0019
;   possible values:
;     0 = small
;     1 = big
;     2 = cape
;     3 = fire
; coin count address:
!CoinCount = $0DBF

ORG $008F25             ; the SMW RAM address to insert our code
autoclean JSL FizzBuzz  ; jump to FizzBuzz
NOP                     ; the JSL we insert is 4 bytes long but the code we overwrite is 6
NOP                     ; add 2 1 byte no-ops to fill that empty space

freecode                ; tell assembler to place remaining code in free space in ROM

FizzBuzz:
INC !CoinCount          ; add 1 to coin count, we overwrote this instruction during our insertion so we run it here
LDA #$0F                ; load 15 into A
STA $00                 ; store A in scratch RAM
LDA !CoinCount          ; load coin count into A
JSR Mod                 ; jump to Mod, compute A mod value at $00 (15)
BNE TestMod5            ; if last operation != 0 branch to TestMod5
LDA #$03                ; load 3 into A
STA !PowerUpStatus      ; store A in power-up status address
BRA Return              ; branch to Return
TestMod5:
LDA #$05                ; load 5 into A
STA $00                 ; store A in scratch RAM
LDA !CoinCount          ; load coin count back into A
JSR Mod                 ; jump to Mod, compute A mod value at $00 (5)
BNE TestMod3            ; if last operation != 0 branch to TestMod3
LDA #$02                ; load 2 into A
STA !PowerUpStatus      ; store A in power-up status address
BRA Return              ; branch to Return
TestMod3:
LDA #$03                ; load 3 into A
STA $00                 ; store A in scratch RAM
LDA !CoinCount          ; load coin count back into A
JSR Mod                 ; jump to Mod, compute A mod value at $00 (3)
BNE SetSmall            ; if last operation != 0 branch to SetSmall
LDA #$01                ; load 1 into A
STA !PowerUpStatus      ; store A in power-up status address
BRA Return              ; branch to Return
SetSmall:
STZ !PowerUpStatus      ; store 0 in power-up status address
Return:
LDA !CoinCount          ; load coin count back into A, as it was when we inserted our code
RTL                     ; return to where we inserted our initial jump to FizzBuzz

Mod:                    ; loops until A - value at $00 < 0 and carry flag is cleared
SEC                     ; set the carry flag
SBC $00                 ; subtract value at $00 from A
BCS Mod                 ; if carry flag is set, go back to Mod, otherwise proceed
ADC $00                 ; add value at $00 back to A
RTS                     ; return to where we jumped from
