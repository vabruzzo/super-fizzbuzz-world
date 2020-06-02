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
;     #$00 = small
;     #$01 = big
;     #$02 = cape
;     #$03 = fire
; coin count address:
!CoinCount = $0DBF

ORG $008F25             ; the SMW RAM address to insert our code
autoclean JSL FizzBuzz  ; jump to FizzBuzz
NOP                     ; the JSL we insert is 4 bytes long but the code we overwrite is 6
NOP                     ; add 2 1 byte no-ops to fill that empty space

freecode                ; tell assembler to place remaining code in free space in ROM

FizzBuzz:
INC !CoinCount          ; add 1 to coin count, we overwrote this instruction during our insertion so we run it here
LDA !CoinCount          ; load coin count into A
PHX                     ; push X onto stack so we can retrieve it later
LDX #$0F                ; load 15 into X
STX $00                 ; store X in scratch RAM
JSR Mod                 ; jump to Mod15, compute A mod 15
BNE TestMod5            ; if last operation != 0 branch to TestMod5
LDA #$03                ; load value 3 into A
STA !PowerUpStatus      ; store the value of A into power-up status address
BRA Return              ; branch to Return
TestMod5:
LDA !CoinCount          ; load coin count back into A
LDX #$05                ; load 5 into X
STX $00                 ; store X in scratch RAM
JSR Mod                 ; jump to Mod5, compute A mod 5
BNE TestMod3            ; if last operation != 0 branch to TestMod3
LDA #$02                ; load value 2 into A
STA !PowerUpStatus      ; store the value of A into power-up status address
BRA Return              ; branch to Return
TestMod3:
LDA !CoinCount          ; load coin count back into A
LDX #$03                ; load 3 into X
STX $00                 ; store X in scratch RAM
JSR Mod                 ; jump to Mod3, compute A mod 3
BNE SetSmall            ; if last operation != 0 branch to SetSmall
LDA #$01                ; load value 1 into A
STA !PowerUpStatus      ; store the value of A into power-up status address
BRA Return              ; branch to Return
SetSmall:
STZ !PowerUpStatus      ; store the value 0 into power-up status address
Return:
PLX                     ; pull X from stack and load into X
LDA !CoinCount          ; load coin count back into A, as it was when we inserted our code
RTL                     ; return to where we inserted our initial jump to FizzBuzz

Mod:                    ; loops until A - X < 0 and carry flag is cleared
SEC                     ; set the carry flag
SBC $00                 ; subtract X from A, initially the coin count
BCS Mod                 ; if carry flag is set, go back to Mod15, otherwise proceed
ADC $00                 ; add X back to A
RTS                     ; return to where we jumped from
