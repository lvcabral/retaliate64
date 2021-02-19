;===============================================================================
;  gameWaves.asm - Alien Waves data
;
;  Copyright (C) 2018-2020 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
; Constants

PRB                = AlienProbe
MNE                = AlienMine
SHO                = AlienShooter
ORB                = AlienOrb

MaxWaves           = 18
AsteroidsWave1     = MaxWaves-2
AsteroidsWave2     = MaxWaves-1

AliensXMoveMax     = 210
OrbsXMoveMax       = 40

if NUMOFWAVES = 0
AliensStageWaves   = 6             ; Number of waves to change stages
else
AliensStageWaves   = NUMOFWAVES
endif
if NUMOFSTAGES = 0
LastStageCnt       = 6             ; Number of stages per game
else
LastStageCnt       = NUMOFSTAGES
endif

;===============================================================================
; Page Zero

wavesAliensLow     = $10           ; pointer to wave aliens type array
wavesAliensHigh    = $11
wavesFormationLow  = $12           ; pointer to wave formation array
wavesFormationHigh = $13
asteroidsDelay     = $14
asteroidsXMove     = $15

;===============================================================================
; Variables and Tables

wavesActive           byte False
wavesIndex            byte $00
saveWaveTime          byte $00

startWaveArray        byte $00, $0C, $05, $0C, $00, $05, $00, $05, $0C, $00
                      byte $05, $00, $0C, $05, $0C, $00, $05, $0C

wavesTimeArray        byte $25, $10, $05, $10, $05, $15, $20, $20, $20, $15
                      byte $15, $20, $25, $25, $15, $15, $20, $25

wavesBomberArray      byte $00, $07, $00, $00, $00, $00, $18, $00, $00, $11
                      byte $11, $16, $00, $00, $00, $11, $00, $00

wavesAliensArray      byte SHO, PRB, PRB, PRB, PRB, SHO, PRB, PRB, MNE, PRB, PRB ; 00 - Invaders Wave
                      byte SHO, SHO, SHO, SHO, SHO, SHO, MNE, PRB, MNE, PRB, MNE ; 01 * All Shooters V
                      byte MNE, MNE, MNE, MNE, MNE, MNE, PRB, PRB, ORB, PRB, PRB ; 02 - All Reds 1
                      byte ORB, PRB, PRB, PRB, PRB, ORB, MNE, MNE, MNE, MNE, MNE ; 03 - Pyramid
                      byte MNE, MNE, MNE, MNE, MNE, MNE, PRB, ORB, PRB, ORB, PRB ; 04 - All Reds 2
                      byte MNE, MNE, SHO, SHO, MNE, MNE, PRB, PRB, MNE, PRB, PRB ; 05 - Diamond
                      byte SHO, MNE, PRB, MNE, PRB, MNE, ORB, MNE, PRB, MNE, ORB ; 06 * Left Stair
                      byte PRB, MNE, PRB, MNE, PRB, SHO, MNE, ORB, MNE, ORB, MNE ; 07 - Right Stair
                      byte MNE, MNE, MNE, MNE, MNE, MNE, ORB, ORB, SHO, ORB, ORB ; 08 - Pyramid with Shooter
                      byte SHO, SHO, SHO, SHO, SHO, SHO, MNE, PRB, MNE, PRB, MNE ; 09 * All Shooters M
                      byte SHO, ORB, MNE, MNE, ORB, SHO, MNE, ORB, ORB, ORB, MNE ; 0A * Zig Zag
                      byte MNE, PRB, MNE, MNE, PRB, MNE, PRB, SHO, SHO, SHO, PRB ; 0B * Three Shooters
                      byte PRB, MNE, MNE, MNE, MNE, PRB, SHO, PRB, PRB, PRB, SHO ; 0C - Flat U
                      byte SHO, SHO, SHO, SHO, SHO, SHO, SHO, SHO, SHO, SHO, SHO ; 0D - Double Shooters
                      byte SHO, PRB, MNE, MNE, PRB, SHO, MNE, PRB, SHO, PRB, MNE ; 0E - Big V with Shooters
                      byte MNE, MNE, MNE, MNE, MNE, MNE, PRB, PRB, SHO, PRB, PRB ; 0F * Wave with shooter (hard)
                      byte MNE, ORB, PRB, MNE, ORB, PRB, MNE, ORB, PRB, MNE, MNE ; A1 - Asteroids Field 1
                      byte ORB, MNE, ORB, ORB, ORB, ORB, MNE, ORB, MNE, ORB, MNE ; A2 - Asteroids Field 2
                      ;     0    1    2    3    4    5    6    7    8    9    A
wavesFormationEasy    byte 150,  75, 105, 105,  75, 254,   2,  15,  45,  15,   2 ; 00 - Invaders Wave
                      byte 195, 195, 195, 195, 195, 195,   8,  53,  98,  53,   8 ; 01 - All Shooters V
                      byte 225, 228, 231, 231, 228, 225, 180, 183, 186, 183, 180 ; 02 - All Reds 1
                      byte 250, 160,  70,  70, 160, 250, 205, 115,  25, 115, 205 ; 03 - Pyramid
                      byte 186, 183, 180, 180, 183, 186, 231, 228, 225, 228, 231 ; 04 - All Reds 2
                      byte  75, 150, 254, 225, 150,  75,   8,   8, 195,   8,   8 ; 05 - Diamond
                      byte 254, 135, 120, 105,  90,  75,  90,  75,  60,  45,  30 ; 06 - Left Stair
                      byte  75,  90, 105, 120, 135, 254,  30,  45,  60,  75,  90 ; 07 - Right Stair
                      byte 250, 160,  70,  70, 160, 250, 205, 115,  25, 115, 205 ; 08 - Pyramid with Shooter
                      byte 150, 150, 150, 150, 150, 150,  90,   8,  60,   8,  90 ; 09 - All Shooters M
                      byte 254, 120, 150, 120, 150, 254,  30,  60,   8,  30,  60 ; 0A - Zig Zag
                      byte 250, 100, 138, 138, 100, 250, 175,  25,  25,  25, 175 ; 0B - Three Shooters
                      byte 120, 165, 254, 254, 165, 120, 120, 210, 210, 210, 120 ; 0C - Flat U
                      byte 250, 250, 250, 250, 250, 250, 150,   8,  75,   8, 150 ; 0D - Double Shooters
                      byte  80, 170, 170, 170, 170,  80, 125, 125, 215, 125, 125 ; 0E - Big V with Shooters
                      byte 210, 135, 210, 210, 135, 210, 173, 173, 250, 173, 173 ; 0F - Wave with shooter
                      byte  23, 105,  75, 128,  45, 255, 191, 143, 221, 165,  86 ; A1 - Asteroids Field 1
                      byte 135, 210, 116, 188, 225,  23, 101, 255,  75, 165, 120 ; A2 - Asteroids Field 2
                      ;     0    1    2    3    4    5    6    7    8    9    A
wavesFormationNormal  byte 100,  50,  70,  70,  50, 200,   1,  10,  30,  10,   1 ; 00 - Invaders Wave
                      byte 130, 130, 130, 130, 130, 130,   5,  35,  65,  35,   5 ; 01 - All Shooters V
                      byte 250, 252, 254, 254, 252, 250, 220, 222, 224, 222, 220 ; 02 - All Reds 1
                      byte 200, 140,  80,  80, 140, 200, 170, 110,  50, 110, 170 ; 03 - Pyramid
                      byte 224, 222, 220, 220, 222, 224, 254, 252, 250, 252, 254 ; 04 - All Reds 2
                      byte  50, 100, 200, 150, 100,  50,   5,   5, 130,   5,   5 ; 05 - Diamond
                      byte 200,  90,  80,  70,  60,  50,  60,  50,  40,  30,  20 ; 06 - Left Stair
                      byte  50,  60,  70,  80,  90, 200,  20,  30,  40,  50,  60 ; 07 - Right Stair
                      byte 200, 140,  80,  80, 140, 200, 170, 110,  50, 110, 170 ; 08 - Pyramid with Shooter
                      byte 100, 100, 100, 100, 100, 100,  65,   5,  35,   5,  65 ; 09 - All Shooters M
                      byte 200,  80, 100,  80, 100, 200,  20,  40,   5,  20,  40 ; 0A - Zig Zag
                      byte 200, 100, 125, 125, 100, 200, 150,  50,  50,  50, 150 ; 0B - Three Shooters
                      byte  80, 110, 170, 170, 110,  80,  80, 140, 140, 140,  80 ; 0C - Flat U
                      byte 200, 200, 200, 200, 200, 200, 100,   5,  50,   5, 100 ; 0D - Double Shooters
                      byte 120, 180, 180, 180, 180, 120, 150, 150, 210, 150, 150 ; 0E - Big V with Shooters
                      byte 140,  90, 140, 140,  90, 140, 115, 115, 165, 115, 115 ; 0F - Wave with shooter
                      byte  15,  70,  50,  85,  30, 170, 127,  95, 147, 110,  57 ; A1 - Asteroids Field 1
                      byte  90, 140,  77, 125, 150,  15,  67, 177,  50, 110,  80 ; A2 - Asteroids Field 2
                      ;     0    1    2    3    4    5    6    7    8    9    A
wavesFormationHard    byte  75,  38,  53,  53,  38, 150,   1,   8,  23,   8,   1 ; 00 - Invaders Wave
                      byte  98,  98,  98,  98,  98,  98,   4,  26,  49,  26,   4 ; 01 - All Shooters V
                      byte 188, 189, 191, 191, 189, 188, 165, 167, 168, 167, 165 ; 02 - All Reds 1
                      byte 150, 105,  60,  60, 105, 150, 128,  83,  38,  83, 128 ; 03 - Pyramid
                      byte 168, 167, 165, 165, 167, 168, 191, 189, 188, 189, 191 ; 04 - All Reds 2
                      byte  38,  75, 150, 113,  75,  38,   4,   4,  98,   4,   4 ; 05 - Diamond
                      byte 150,  68,  60,  53,  45,  38,  45,  38,  30,  23,  15 ; 06 - Left Stair
                      byte  38,  45,  53,  60,  68, 150,  15,  23,  30,  38,  45 ; 07 - Right Stair
                      byte 150, 105,  60,  60, 105, 150, 128,  83,  38,  83, 128 ; 08 - Pyramid with Shooter
                      byte  75,  75,  75,  75,  75,  75,  55,   4,  23,   4,  55 ; 09 - All Shooters M
                      byte 150,  60,  75,  60,  75, 150,  15,  30,   4,  15,  30 ; 0A - Zig Zag
                      byte 150,  75,  94,  94,  75, 150, 113,  38,  38,  38, 113 ; 0B - Three Shooters
                      byte  60,  83, 128, 128,  83,  60,  60, 105, 105, 105,  60 ; 0C - Flat U
                      byte 150, 150, 150, 150, 150, 150,  75,   4,  38,   4,  75 ; 0D - Double Shooters
                      byte  90, 135, 135, 135, 135, 90, 113, 113,  158, 113, 113 ; 0E - Big V with Shooters
                      byte 105,  68, 105, 105,  68, 105,  86,  86, 124,  86,  86 ; 0F - Wave with shooter
                      byte  11,  53,  38,  64,  23, 128,  95,  71, 110,  83,  43 ; A1 - Asteroids Field 1
                      byte  68, 105,  58,  94, 113,  11,  50, 133,  38,  83,  60 ; A2 - Asteroids Field 2
                      ;     0    1    2    3    4    5    6    7    8    9    A
wavesFormationExtreme byte  60,  30,  42,  42,  30, 120,   1,   6,  18,   6,   1 ; 00 - Invaders Wave
                      byte  78,  78,  78,  78,  78,  78,   3,  21,  39,  21,   3 ; 01 - All Shooters V
                      byte 150, 151, 152, 152, 151, 150, 132, 133, 134, 133, 132 ; 02 - All Reds 1
                      byte 120,  84,  48,  48,  84, 120, 102,  66,  30,  66, 102 ; 03 - Pyramid
                      byte 134, 133, 132, 132, 133, 134, 152, 151, 150, 151, 152 ; 04 - All Reds 2
                      byte  30,  60, 120,  90,  60,  30,   3,   3,  78,   3,   3 ; 05 - Diamond
                      byte 120,  54,  48,  42,  36,  30,  36,  30,  24,  18,  12 ; 06 - Left Stair
                      byte  30,  36,  42,  48,  54, 120,  12,  18,  24,  30,  36 ; 07 - Right Stair
                      byte 120,  84,  48,  48,  84, 120, 102,  66,  30,  66, 102 ; 08 - Pyramid with Shooter
                      byte  60,  60,  60,  60,  60,  60,  36,   3,  15,   3,  36 ; 09 - All Shooters M
                      byte 120,  48,  60,  48,  60, 120,  12,  24,   3,  12,  24 ; 0A - Zig Zag
                      byte 120,  60,  75,  75,  60, 120,  90,  30,  30,  30,  90 ; 0B - Three Shooters
                      byte  48,  66, 102, 102,  66,  48,  48,  84,  84,  84,  48 ; 0C - Flat U
                      byte 120, 120, 120, 120, 120, 120,  60,   3,  39,   3,  60 ; 0D - Double Shooters
                      byte  72, 108, 108, 108, 108,  72,  90,  90, 126,  90,  90 ; 0E - Big V with Shooters
                      byte  84,  54,  84,  84,  54,  84,  69,  69,  99,  69,  69 ; 0F - Wave with shooter
                      byte   9,  42,  30,  51,  18, 102,  76,  57,  88,  66,  34 ; A1 - Asteroids Field 1
                      byte  54,  84,  46,  75,  90,   9,  40, 106,  30,  66,  48 ; A2 - Asteroids Field 2

wavesLevelTable       byte LevelEasy*MaxWaves, LevelNormal*MaxWaves
                      byte LevelHard*MaxWaves, LevelExtreme*MaxWaves
wavesLevelIndex       byte 0

asteroidsSpeedX       byte  0,    1,    1,    0,    0,    0
                      byte     0,   -1,   -1,    1,   -1

Operator Calc
; (MaxWaves-1)*MaxAliens -> (18 - 1) * 11 = 187
wavesAliensArrayLow
repeat 0, 187, 11, idx
                      byte <wavesAliensArray+idx
endrepeat

wavesAliensArrayHigh
repeat 0, 187, 11, idx
                      byte >wavesAliensArray+idx
endrepeat

wavesTableLow
repeat 0, 187, 11, idx
                      byte <wavesFormationEasy+idx
endrepeat
repeat 0, 187, 11, idx
                      byte <wavesFormationNormal+idx
endrepeat
repeat 0, 187, 11, idx
                      byte <wavesFormationHard+idx
endrepeat
repeat 0, 187, 11, idx
                      byte <wavesFormationExtreme+idx
endrepeat

wavesTableHigh
repeat 0, 187, 11, idx
                      byte >wavesFormationEasy+idx
endrepeat
repeat 0, 187, 11, idx
                      byte >wavesFormationNormal+idx
endrepeat
repeat 0, 187, 11, idx
                      byte >wavesFormationHard+idx
endrepeat
repeat 0, 187, 11, idx
                      byte >wavesFormationExtreme+idx
endrepeat
Operator HiLo

wavesRndTable         byte $0F,$0C,$06,$00,$0B,$07,$04,$08,$01,$03,$02,$09,$0D,$05,$0A,$0E
                      byte $07,$08,$0C,$05,$0D,$0E,$0A,$0F,$04,$06,$03,$0B,$01,$02,$10,$09
                      byte $06,$0B,$05,$0F,$07,$0D,$0C,$02,$11,$10,$04,$08,$0A,$0E,$09,$03
                      byte $11,$03,$09,$0E,$00,$0A,$07,$06,$0B,$10,$05,$0F,$0C,$04,$08,$0D
                      byte $04,$08,$0E,$10,$0C,$0B,$00,$0A,$0F,$0D,$07,$09,$06,$05,$11,$01
                      byte $02,$01,$09,$11,$08,$0B,$0C,$0F,$07,$0A,$10,$00,$05,$0E,$0D,$06
                      byte $00,$07,$0D,$02,$11,$08,$10,$09,$0B,$0E,$03,$0A,$0C,$0F,$01,$06
                      byte $07,$04,$03,$0F,$10,$0D,$08,$0E,$01,$0B,$0C,$09,$0A,$00,$11,$02
                      byte $0A,$01,$02,$00,$0C,$0E,$08,$0D,$11,$03,$0F,$10,$05,$0B,$09,$04
                      byte $00,$11,$10,$05,$0A,$0D,$0F,$02,$06,$09,$04,$03,$0B,$0E,$0C,$01
                      byte $0E,$0C,$00,$01,$0A,$0D,$10,$07,$04,$0B,$11,$02,$06,$03,$05,$0F
                      byte $07,$03,$0E,$10,$0B,$01,$00,$0D,$04,$08,$11,$0F,$02,$05,$06,$0C
                      byte $06,$08,$02,$10,$03,$07,$0E,$0C,$09,$0D,$00,$01,$0F,$11,$04,$05
                      byte $04,$05,$09,$02,$11,$0E,$0F,$0D,$10,$03,$00,$0A,$07,$08,$01,$06
                      byte $03,$11,$01,$10,$00,$08,$07,$0E,$06,$05,$0B,$04,$0F,$02,$09,$0A
                      byte $08,$0C,$0B,$0F,$05,$03,$07,$11,$06,$04,$10,$00,$0A,$01,$02,$09

stagesOffsetArray     byte   0,   3,   6,   9

stagesLevelArray      byte   0,   0,   0,   1,   1,   1,   2,   2,   2
                      byte   3,   3,   3,   3,   3,   3,   3

stagesShooterStart    byte AlienSquid,   AlienSquid,   AlienSquid,   AlienSquid,   AlienSquid,   AlienSquid,   AlienSquid
stagesShooterEnd      byte AlienSquid+3, AlienSquid+3, AlienSquid+3, AlienSquid+3, AlienSquid+3, AlienSquid+3, AlienSquid+3
stagesShooterColor    byte Green,        Green,        Green,        Green,        Green,        Green,        LightRed

stagesProbeStart      byte AlienBat,   AlienBat,   AlienBat,   AlienBat,   AlienBat,   AlienBat,   AlienBat
stagesProbeEnd        byte AlienBat+1, AlienBat+1, AlienBat+1, AlienBat+1, AlienBat+1, AlienBat+1, AlienBat+1
stagesProbeColor      byte LightRed,   Purple,     Red,        LightRed,   Purple,     Red,        Green

stagesOrbColor        byte Purple,     LightRed,    LightBlue,   Purple,      LightRed,    LightBlue,  Purple

aliensXMoveArray      byte    1,  1,  1,  1,  1,  1,  1,  1,  1,  1     ;right
                      byte    1,  1,  1,  1,  1,  1,  1,  1,  1,  1
                      byte    1,  1,  1,  1,  1,  1,  1,  1,  1,  1
                      byte    1,  1,  1,  1,  0,  1,  0,  0,  1,  0

                      byte    0,  0,  0,  0,  0,  0,  0,  0,  0,  0
                      byte    0,  0,  0,  0,  0,  0,  0,  0,  0,  0
                      byte    0,  0,  0,  0,  0,  0,  0,  0,  0,  0
                      byte    0,  0,  0,  0,  0,  0,  0,  0,  0,  0
                      byte    0,  0,  0,  0,  0,  0,  0,  0,  0,  0

                      byte   -1, -1, -1, -1, -1, -1, -1, -1, -1, -1     ;left
                      byte   -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
                      byte    0,  0,  0,  0,  0,  0,  0,  0,  0,  0
                      byte    0,  0,  0,  0,  0,  0,  0,  0,  0,  0
                      byte    0,  0,  0,  0,  0,  0,  0,  0,  0,  0
                      byte   -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
                      byte   -1, -1, -1, -1,  0, -1,  0,  0, -1,  0

                      byte    0,  0,  0,  0,  0,  0,  0,  0,  0,  0
                      byte    0,  0,  0,  0,  0,  0,  0,  0,  0,  0
                      byte    0,  0,  0,  0,  0,  0,  0,  0,  0,  0
                      byte    0,  0,  0,  0,  0,  0,  0,  0,  0,  0
                      byte    0,  0,  0,  0,  0,  0,  0,  0,  0,  0


orbsXMoveArray        byte    1,  1,  1,  1,  1,  1,  1,  1,  1,  1     ;right
                      byte    1,  1,  1,  1,  1,  1,  1,  1,  1,  1
                      byte   -1, -1, -1, -1, -1, -1, -1, -1, -1, -1     ;left
                      byte   -1, -1, -1, -1, -1, -1, -1, -1, -1, -1

ntscSpeedEasy         byte   0, 2, 0, 2, 0, 2, 0, 2, 0, 2
ntscSpeedNormal       byte   0, 3, 0, 3, 0, 3, 0, 3, 0, 3
ntscSpeedHard         byte   0, 4, 0, 4, 0, 4, 0, 4, 0, 4
ntscSpeedExtreme      byte   0, 5, 0, 5, 0, 5, 0, 5, 0, 5

palSpeedEasy          byte   0, 2, 0, 3, 0, 2, 0, 3, 0, 2
palSpeedNormal        byte   0, 3, 0, 4, 0, 3, 0, 4, 0, 4
palSpeedHard          byte   0, 4, 0, 5, 0, 5, 0, 5, 0, 5
palSpeedExtreme       byte   0, 6, 0, 6, 0, 6, 0, 6, 0, 6

aliensFirePattern     byte  13,  13,  91,  91,  13,  13,  13,  91, 177, 177
                      byte  13,  13,  13,  13,  91, 177,  91,  91,  91, 177
                      byte  13,  91,  41,  13,  91, 177,  91, 177,  91, 177
                      byte  13,  13,  13,  13,  13,  41,  13,  13,  13,  91
                      byte  91,  13,  13,  13,  13,  13, 177,  91,  91, 177
                      byte  13,  13,  91,  13,  13,  91,  13,  13,  13, 177
                      byte  91,  13,  13,  13,  13,  13, 177,  91,  91, 177
                      byte  13,  13,  13,  41,  41,  13,  13,  13,  13,  91
                      byte  13,  13,  13,  13,  91, 177,  91,  91,  91, 177
                      byte  91,  13,  13,  13,  13,  13, 177,  91,  91, 177

bomberXHighArray      byte   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
                      byte   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
                      byte   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
                      byte   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
                      byte   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
                      byte   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
                      byte   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
                      byte   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
                      byte   1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1
                      byte   1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1
                      byte   1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  0

bomberXLowArray       byte   0,  2,  4,  6,  8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30
                      byte  32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60, 62
                      byte  64, 66, 68, 70, 72, 74, 76, 78, 80, 82, 84, 86, 88, 90, 92, 94
                      byte  96, 98,100,102,104,106,108,110,112,114,116,118,120,122,124,126
                      byte 128,130,132,134,136,138,140,142,144,146,148,150,152,154,156,158
                      byte 160,162,164,166,168,170,172,174,176,178,180,182,184,186,188,190
                      byte 192,194,196,198,200,202,204,206,208,210,212,214,216,218,220,222
                      byte 224,226,228,230,232,234,236,238,240,242,244,246,248,250,252,254
                      byte   0,  2,  4,  6,  8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30
                      byte  32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60, 62
                      byte  64, 66, 68, 70, 72, 74, 76, 78, 80, 82, 84, 86, 88,255

bomberYArray          byte 100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100
                      byte 101,101,101,101,101,101,102,102,102,102,102,103,103,103,103,103
                      byte 104,104,104,104,105,105,105,106,106,106,107,107,107,108,108,108
                      byte 109,109,109,110,110,110,111,111,112,112,112,113,113,114,114,114
                      byte 115,115,116,116,117,117,117,118,118,119,119,120,120,121,121,122
                      byte 122,122,123,123,124,124,125,125,126,126,127,127,127,128,128,129
                      byte 129,130,130,131,131,132,132,132,133,133,134,134,135,135,135,136
                      byte 136,137,137,137,138,138,139,139,139,140,140,140,141,141,141,142
                      byte 142,142,143,143,143,144,144,144,145,145,145,145,146,146,146,146
                      byte 146,147,147,147,147,147,148,148,148,148,148,148,149,149,149,149
                      byte 149,149,149,149,149,149,149,149,149,149,149,150,150,255

bouncerYArray         byte $73,$74,$75,$76,$78,$79,$7A,$7A,$7B,$7C,$7C,$7D,$7D,$7D,$7D,$7C
                      byte $7C,$7B,$7B,$7A,$79,$78,$77,$75,$74,$73,$72,$70,$6F,$6E,$6D,$6C
                      byte $6B,$6A,$6A,$69,$69,$69,$69,$69,$69,$6A,$6A,$6B,$6C,$6D,$6E,$6F
                      byte $70,$71,$72,$74,$75,$76,$77,$78,$79,$7A,$7B,$7C,$7C,$7C,$7D,$7D
                      byte $7D,$7C,$7C,$7B,$7B,$7A,$79,$78,$77,$76,$74,$73,$72,$71,$70,$6E
                      byte $6D,$6C,$6B,$6B,$6A,$69,$69,$69,$69,$69,$69,$69,$6A,$6B,$6B,$6C
                      byte $6D,$6E,$70,$71,$72,$73,$75,$76,$77,$78,$79,$7A,$7B,$7B,$7C,$7C
                      byte $7D,$7D,$7D,$7C,$7C,$7C,$7B,$7A,$79,$78,$77,$76,$75,$74,$72,$71
                      byte $70,$6E,$6D,$6C,$6B,$6B,$6A,$69,$69,$69,$69,$69,$69,$69,$6A,$6B
                      byte $6B,$6C,$6D,$6E,$70,$71,$72,$73,$75,$76,$77,$78,$79,$7A,$7B,$7B
                      byte $7C,$7C,$7D,$7D,$7D,$7C,$7C,$7C,$7B,$7A,$79,$78,$77,$FF
