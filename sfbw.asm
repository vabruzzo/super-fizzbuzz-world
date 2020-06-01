;Super FizzBuzz World, a Super Mario World ROM patch
;
;on each coin count increase
;  if coin count is divisible by 3 and 5
;    set power-up status to fire
;  else if coin count is divisible by 5
;    set power-up status to cape
;  else if coin count is divisible by 3
;    set power-up status to big
;  else
;    set power-up status to small
;
;constants:
;power-up status address:
!PowerUpStatus = $0019
;  possible values:
;    #$00 = small
;    #$01 = big
;    #$02 = cape
;    #$03 = fire
;coin count address:
!CoinCount = $0DBF

ORG $008F25             ;the SMW RAM address to insert our code
autoclean JSL FizzBuzz  ;jump to FizzBuzz
NOP                     ;the JSL we insert is 4 bytes long but the code we overwrite is 6
NOP                     ;add 2 1 byte no-ops to fill that empty space

freecode                ;tells assembler to place remaining code in free space in ROM

FizzBuzz:
INC !CoinCount          ;add 1 to coin count, we overwrote this instruction during our insertion so we run it here
LDA !CoinCount          ;load coin count into A
JSR Mod15               ;jump to Mod15
BNE TestMod5            ;if A (coin count) mod 15 != 0 branch to TestMod5
LDX #$03                ;load value 3 into X
STX !PowerUpStatus       ;store the value of X into power-up status address
BRA Return              ;branch to Return
TestMod5:
LDA !CoinCount          ;load coin count back into A since Mod15 overwrote it
JSR Mod5                ;jump to Mod5
BNE TestMod3            ;if A (coin count) mod 5 != 0 branch to TestMod3
LDX #$02                ;load value 2 into X
STX !PowerUpStatus       ;store the value of X into power-up status address
BRA Return              ;branch to Return
TestMod3:
LDA !CoinCount          ;load coin count back into A since Mod5 overwrote it
JSR Mod3                ;jump to Mod3
BNE SetSmall            ;if A (coin count) mod 3 != 0 branch to SetSmall
LDX #$01                ;load value 1 into X
STX !PowerUpStatus       ;store the value of X into power-up status address
BRA Return              ;branch to Return
SetSmall:
STZ !PowerUpStatus       ;store the value 0 into power-up status address
Return:
LDA !CoinCount          ;load the coin count back into A, as it was when we inserted our code
RTL                     ;return to where we inserted our initial jump to FizzBuzz

;FIXME refactor these 3 mod subroutines into 1 if possible
Mod15:                  ;loops until A - 15 < 0 and carry flag is cleared
SEC                     ;set the carry flag
SBC #$0F                ;subtract 15 from A, initially the coin count
BCS Mod15               ;if carry flag is set, go back to Mod15, otherwise proceed
ADC #$0F                ;add 15 back to A
RTS                     ;return to where we jumped from

Mod5:
SEC
SBC #$05
BCS Mod5
ADC #$05
RTS

Mod3:
SEC
SBC #$03
BCS Mod3
ADC #$03
RTS
