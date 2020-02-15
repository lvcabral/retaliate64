;===============================================================================
;  gameWaves.asm - Alien Waves data
;
;  Copyright (C) 2018 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
; Constants

WavesMax           = 20         ; # of waves defined

;===============================================================================
; Page Zero

wavesFormationLow  = $10        ; pointer to wave formation
wavesFormationHigh = $11

;===============================================================================
; Variables and Tables

* = $A000

wavesActive           byte   0

wavesIndexArray       byte  AliensMax*$00, AliensMax*$01, AliensMax*$02
                      byte  AliensMax*$03, AliensMax*$04, AliensMax*$05
                      byte  AliensMax*$06, AliensMax*$07, AliensMax*$08
                      byte  AliensMax*$09, AliensMax*$0A, AliensMax*$0B
                      byte  AliensMax*$0C, AliensMax*$0D, AliensMax*$0E
                      byte  AliensMax*$0F, AliensMax*$10, AliensMax*$11
                      byte  AliensMax*$12, AliensMax*$13
wavesIndex            byte   0

wavesTimeArray        byte  25,  25,   5,  10,   5,  15,  20,  20,  20,  10
                      byte  15,  20,  25,  10,  15,  15,  15,  10,  15,  20
wavesTimeIndex        byte   0

wavesFrameArray       byte   6,   5,   5,   5,   5,   6,   5,   5,   5,   5,   5 ; Start Wave
                      byte   6,   6,   6,   6,   6,   6,   5,   5,   5,   5,   5 ; All Shooters V
                      byte   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5 ; All Reds 1
                      byte   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5 ; Pyramid
                      byte   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5 ; All Reds 2
                      byte   5,   5,   6,   6,   5,   5,   5,   5,   5,   5,   5 ; Diamond
                      byte   6,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5 ; Left Stair
                      byte   5,   5,   5,   5,   5,   6,   5,   5,   5,   5,   5 ; Right Stair
                      byte   5,   5,   5,   5,   5,   5,   5,   5,   6,   5,   5 ; Pyramid with Shooter
                      byte   6,   6,   6,   6,   6,   6,   5,   5,   5,   5,   5 ; All Shooters M
                      byte   6,   5,   5,   5,   5,   6,   5,   5,   5,   5,   5 ; Zig Zag
                      byte   5,   5,   5,   5,   5,   5,   5,   6,   6,   6,   5 ; Three Shooters
                      byte   5,   5,   5,   5,   5,   5,   6,   5,   5,   5,   6 ; Flat U
                      byte   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5 ; Big V
                      byte   6,   5,   5,   5,   5,   6,   5,   5,   6,   5,   5 ; Big V with Shooters
                      byte   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5 ; Scattered 1
                      byte   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5 ; Scattered 2
                      byte   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5 ; Wave
                      byte   5,   5,   5,   5,   5,   5,   5,   5,   6,   5,   5 ; Wave with shooter
                      byte   6,   6,   6,   6,   6,   6,   6,   6,   6,   6,   6 ; All Shooters Double

wavesFormationEasy    byte 150,  75, 105, 105,  75, 254,   2,  15,  45,  15,   2 ; Start Wave
                      byte 195, 195, 195, 195, 195, 195,   8,  53,  98,  53,   8 ; All Shooters V
                      byte 225, 228, 231, 231, 228, 225, 180, 183, 186, 183, 180 ; All Reds 1
                      byte 250, 160,  70,  70, 160, 250, 205, 115,  25, 115, 205 ; Pyramid
                      byte 186, 183, 180, 180, 183, 186, 231, 228, 225, 228, 231 ; All Reds 2
                      byte  75, 150, 254, 225, 150,  75,   8,   8, 195,   8,   8 ; Diamond
                      byte 254, 135, 120, 105,  90,  75,  90,  75,  60,  45,  30 ; Left Stair
                      byte  75,  90, 105, 120, 135, 254,  30,  45,  60,  75,  90 ; Right Stair
                      byte 250, 160,  70,  70, 160, 250, 205, 115,  25, 115, 205 ; Pyramid with Shooter
                      byte 150, 150, 150, 150, 150, 150,  90,   8,  45,   8,  90 ; All Shooters M
                      byte 254, 120, 150, 120, 150, 254,  30,  60,   8,  30,  60 ; Zig Zag
                      byte 250, 100, 138, 138, 100, 250, 175,  25,  25,  25, 175 ; Three Shooters
                      byte 120, 165, 254, 254, 165, 120, 120, 210, 210, 210, 120 ; Flat U
                      byte  80, 170, 170, 170, 170,  80, 125, 125, 215, 125, 125 ; Big V
                      byte  80, 170, 170, 170, 170,  80, 125, 125, 215, 125, 125 ; Big V with Shooters
                      byte  30, 120,  75, 120,  30, 254, 210, 165, 210, 165,  75 ; Scattered 1
                      byte 165, 210, 120, 165, 210,  75,  75, 254,  75,  30, 120 ; Scattered 2
                      byte 210, 165, 210, 210, 165, 210, 188, 188, 240, 188, 188 ; Wave
                      byte 210, 165, 210, 210, 165, 210, 188, 188, 233, 188, 188 ; Wave with shooter
                      byte 250, 250, 250, 250, 250, 250, 150,   8,  75,   8, 150 ; All Shooters Double

wavesFormationNormal  byte 100,  50,  70,  70,  50, 200,   1,  10,  30,  10,   1 ; Start Wave
                      byte 130, 130, 130, 130, 130, 130,   5,  35,  65,  35,   5 ; All Shooters V
                      byte 250, 252, 254, 254, 252, 250, 220, 222, 224, 222, 220 ; All Reds 1
                      byte 200, 140,  80,  80, 140, 200, 170, 110,  50, 110, 170 ; Pyramid
                      byte 224, 222, 220, 220, 222, 224, 254, 252, 250, 252, 254 ; All Reds 2
                      byte  50, 100, 200, 150, 100,  50,   5,   5, 130,   5,   5 ; Diamond
                      byte 200,  90,  80,  70,  60,  50,  60,  50,  40,  30,  20 ; Left Stair
                      byte  50,  60,  70,  80,  90, 200,  20,  30,  40,  50,  60 ; Right Stair
                      byte 200, 140,  80,  80, 140, 200, 170, 110,  50, 110, 170 ; Pyramid with Shooter
                      byte 100, 100, 100, 100, 100, 100,  60,   5,  30,   5,  60 ; All Shooters M
                      byte 200,  80, 100,  80, 100, 200,  20,  40,   5,  20,  40 ; Zig Zag
                      byte 200, 100, 125, 125, 100, 200, 150,  50,  50,  50, 150 ; Three Shooters
                      byte  80, 110, 170, 170, 110,  80,  80, 140, 140, 140,  80 ; Flat U
                      byte 120, 180, 180, 180, 180, 120, 150, 150, 210, 150, 150 ; Big V
                      byte 120, 180, 180, 180, 180, 120, 150, 150, 210, 150, 150 ; Big V with Shooters
                      byte  20,  80,  50,  80,  20, 170, 140, 110, 140, 110,  50 ; Scattered 1
                      byte 110, 140,  80, 110, 140,  50,  50, 170,  50,  20,  80 ; Scattered 2
                      byte 140, 110, 140, 140, 110, 140, 125, 125, 160, 125, 125 ; Wave
                      byte 140, 110, 140, 140, 110, 140, 125, 125, 155, 125, 125 ; Wave with shooter
                      byte 200, 200, 200, 200, 200, 200, 100,   5,  50,   5, 100 ; All Shooters Double

wavesFormationHard    byte  75,  38,  53,  53,  38, 150,   1,   8,  23,   8,   1 ; Start Wave
                      byte  98,  98,  98,  98,  98,  98,   4,  26,  49,  26,   4 ; All Shooters V
                      byte 188, 189, 191, 191, 189, 188, 165, 167, 168, 167, 165 ; All Reds 1
                      byte 150, 105,  60,  60, 105, 150, 128,  83,  38,  83, 128 ; Pyramid
                      byte 168, 167, 165, 165, 167, 168, 191, 189, 188, 189, 191 ; All Reds 2
                      byte  38,  75, 150, 113,  75,  38,   4,   4,  98,   4,   4 ; Diamond
                      byte 150,  68,  60,  53,  45,  38,  45,  38,  30,  23,  15 ; Left Stair
                      byte  38,  45,  53,  60,  68, 150,  15,  23,  30,  38,  45 ; Right Stair
                      byte 150, 105,  60,  60, 105, 150, 128,  83,  38,  83, 128 ; Pyramid with Shooter
                      byte  75,  75,  75,  75,  75,  75,  45,   4,  23,   4,  45 ; All Shooters M
                      byte 150,  60,  75,  60,  75, 150,  15,  30,   4,  15,  30 ; Zig Zag
                      byte 150,  75,  94,  94,  75, 150, 113,  38,  38,  38, 113 ; Three Shooters
                      byte  60,  83, 128, 128,  83,  60,  60, 105, 105, 105,  60 ; Flat U
                      byte  90, 135, 135, 135, 135, 90, 113, 113,  158, 113, 113 ; Big V
                      byte  90, 135, 135, 135, 135, 90, 113, 113,  158, 113, 113 ; Big V with Shooters
                      byte  15,  60,  38,  60,  15, 128, 105,  83, 105,  83,  38 ; Scattered 1
                      byte  83, 105,  60,  83, 105,  38,  38, 128,  38,  15,  60 ; Scattered 2
                      byte 105,  83, 105, 105,  83, 105,  94,  94, 120,  94,  94 ; Wave
                      byte 105,  83, 105, 105,  83, 105,  94,  94, 116,  94,  94 ; Wave with shooter
                      byte 150, 150, 150, 150, 150, 150,  75,   4,  38,   4,  75 ; All Shooters Double

wavesFormationExtreme byte  60,  30,  42,  42,  30, 120,   1,   6,  18,   6,   1 ; Start Wave
                      byte  78,  78,  78,  78,  78,  78,   3,  21,  39,  21,   3 ; All Shooters V
                      byte 150, 151, 152, 152, 151, 150, 132, 133, 134, 133, 132 ; All Reds 1
                      byte 120,  84,  48,  48,  84, 120, 102,  66,  30,  66, 102 ; Pyramid
                      byte 134, 133, 132, 132, 133, 134, 152, 151, 150, 151, 152 ; All Reds 2
                      byte  30,  60, 120,  90,  60,  30,   3,   3,  78,   3,   3 ; Diamond
                      byte 120,  54,  48,  42,  36,  30,  36,  30,  24,  18,  12 ; Left Stair
                      byte  30,  36,  42,  48,  54, 120,  12,  18,  24,  30,  36 ; Right Stair
                      byte 120,  84,  48,  48,  84, 120, 102,  66,  30,  66, 102 ; Pyramid with Shooter
                      byte  60,  60,  60,  60,  60,  60,  36,   3,  18,   3,  36 ; All Shooters M
                      byte 120,  48,  60,  48,  60, 120,  12,  24,   3,  12,  24 ; Zig Zag
                      byte 120,  60,  75,  75,  60, 120,  90,  30,  30,  30,  90 ; Three Shooters
                      byte  48,  66, 102, 102,  66,  48,  48,  84,  84,  84,  48 ; Flat U
                      byte  72, 108, 108, 108, 108,  72,  90,  90, 126,  90,  90 ; Big V
                      byte  72, 108, 108, 108, 108,  72,  90,  90, 126,  90,  90 ; Big V with Shooters
                      byte  12,  48,  30,  48,  12, 102,  84,  66,  84,  66,  30 ; Scattered 1
                      byte  66,  84,  48,  66,  84,  30,  30, 102,  30,  12,  48 ; Scattered 2
                      byte  84,  66,  84,  84,  66,  84,  75,  75,  96,  75,  75 ; Wave
                      byte  84,  66,  84,  84,  66,  84,  75,  75,  93,  75,  75 ; Wave with shooter
                      byte 120, 120, 120, 120, 120, 120,  60,   3,  30,   3,  60 ; All Shooters Double

wavesTableLow         byte <wavesFormationEasy, <wavesFormationNormal
                      byte <wavesFormationHard, <wavesFormationExtreme
wavesTableHigh        byte >wavesFormationEasy, >wavesFormationNormal
                      byte >wavesFormationHard, >wavesFormationExtreme

wavesRndTable         byte $03,$00,$08,$07,$07,$04,$03,$11,$02,$12,$0D,$01,$00,$02,$06,$07
                      byte $10,$13,$00,$11,$06,$11,$0D,$07,$0E,$12,$08,$00,$05,$0D,$0A,$08
                      byte $04,$06,$0A,$03,$02,$0C,$03,$0B,$0B,$13,$08,$01,$0E,$11,$03,$0C
                      byte $02,$11,$09,$13,$0B,$12,$06,$02,$01,$07,$09,$02,$07,$03,$0C,$08
                      byte $0E,$0B,$05,$0B,$0B,$06,$08,$02,$13,$05,$11,$07,$05,$0E,$0C,$08
                      byte $11,$07,$0A,$01,$07,$01,$0A,$0C,$08,$02,$06,$12,$0A,$06,$0F,$0C
                      byte $0E,$04,$08,$04,$07,$11,$11,$08,$12,$0D,$12,$0C,$0B,$07,$04,$10
                      byte $0F,$02,$01,$03,$04,$05,$0D,$13,$02,$0C,$0C,$13,$0E,$10,$08,$11
                      byte $00,$03,$11,$08,$0A,$03,$09,$0D,$05,$0E,$00,$08,$10,$05,$10,$03
                      byte $09,$10,$13,$06,$04,$0B,$05,$11,$10,$00,$13,$0A,$0F,$00,$03,$0B
                      byte $09,$07,$01,$07,$12,$02,$02,$0F,$02,$11,$04,$04,$0F,$11,$05,$08
                      byte $10,$13,$0D,$06,$11,$06,$09,$0C,$0B,$0E,$10,$0E,$03,$07,$07,$02
                      byte $0A,$00,$12,$11,$07,$12,$07,$00,$02,$01,$07,$02,$01,$0A,$02,$10
                      byte $07,$08,$0F,$06,$11,$04,$12,$12,$0F,$07,$0F,$0D,$06,$03,$03,$0D
                      byte $0B,$0D,$0D,$0E,$01,$03,$01,$0C,$0A,$03,$07,$06,$06,$11,$0E,$04
                      byte $0D,$05,$08,$0E,$07,$02,$0E,$11,$03,$01,$11,$00,$02,$07,$05,$0D
