;===============================================================================
;  gameMemory.asm - Game Memory Map
;
;  Copyright (C) 2017,2018 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
; $00-$FF  PAGE ZERO (256 bytes)
 
                ; $00-$01   Reserved for IO
ZeroPageTemp    = $02
                ; $03-$8F   Reserved for BASIC  (disabled)
                ; $03-$08   Used on libMultiplex.asm
                ; $09-$0A   Used on libSprite.asm
                ; $0B-$0C   Used on gameFlow.asm
                ; $10-$11   Used on gameWaves.asm
                ; $20-$26   Used on gameAliens.asm
                ; $31-$36   Used on gamePlayer.asm
                ; $40-$51   Used on libMultiplex.asm
                ; $73-$7D   Temporary variables for libraries
ZeroPageParam1  = $73
ZeroPageParam2  = $74
ZeroPageParam3  = $75
ZeroPageParam4  = $76
ZeroPageParam5  = $77
ZeroPageParam6  = $78
ZeroPageParam7  = $79
ZeroPageParam8  = $7A
ZeroPageParam9  = $7B
ZeroPageTemp1   = $7C
ZeroPageTemp2   = $7D
                ; $7E-$8C   Used on gameBullets.asm
                ; $90-$FA   Reserved for Kernal
                ; $E0-$E5   Used on gameStars.asm
                ; $EE       Used on gameStars.asm
                ; $F8-$F9   Used on gameStars.asm
ZeroPageLow     = $FB
ZeroPageHigh    = $FC
ZeroPageLow2    = $FD
ZeroPageHigh2   = $FE
                ; $FF       Reserved for Kernal

;===============================================================================
; $0100-$01FF  STACK (256 bytes)

MODE            = $0291
CINVLOW         = $0314
CINVHIGH        = $0315
ISTOP           = $0328

;===============================================================================
; $0200-$9FFF  RAM (40K)

; $0801
; Game code is placed here by using the *=$0801 directive on gameMain.asm

; Splash screen bitmap
* = $4000
        incbin "splash.kla",2

SCREENRAM       = $6800
SPRITE0         = $6BF8

; 176 decimal * 64(sprite size) = 11264 (hex $2C00)
; VIC II is looking at $4000 adding $2C00 we have $6C00
SPRITERAM       = 176
* = $6C00
        incbin "sprites.spt",1,35,true

; The character set ($D018) pointing to 14 decimal (%xxxx101x)
; So charmem is at $3800 adding bank start $4000 we have $7800
CHARSETPOS      = 14
CHARSETRAM      = $7800
* = $7800
        ; letters and numbers from the font "Teggst shower 5"
        ; http://kofler.dot.at/c64/download/teggst_shower_5.zip
        incbin "characters.cst",0,168

; Menu screens
* = $8000
MAPRAM
        ; Export List: 1-5(9),1-5(10),1-5(11),1-5(12),1-5(13),1-5(14),1-5(15),1-5(16),1-5(17),1-5(18),1-5(19),1-5(20),1-5(21),1-5(22),1-5(24)
        incbin "screens.bin"

; Stars field cache
CACHERAM       = $9800
CLRCHRAM       = $9C00

;===============================================================================
; $A000-$BFFF  BASIC ROM (8K) - Disabled for this game
; Aliens Wave data is placed here by using *=$A000 directive on gameWaves.asm

;===============================================================================
; $C000-$CFFF  RAM (4K)

; SFX
SoundVoice = $01

; SID music
SIDINIT = $C000
SIDPLAY = $C003
SIDSONG = $00   ; Id of the song (inside the SID file)

* = $C000
SIDLOAD
        incbin "music.sid", $7E

;===============================================================================
; $D000-$DFFF  IO (4K)

; These are some of the C64 registers that are mapped into
; IO memory space
; Names taken from 'Mapping the Commodore 64' book

SP0X            = $D000
SP0Y            = $D001
MSIGX           = $D010
SCROLY          = $D011
RASTER          = $D012
SPENA           = $D015
SCROLX          = $D016
VMCSB           = $D018
IRQFLAG         = $D019
IRQCTRL         = $D01A
SPBGPR          = $D01B
SPMC            = $D01C
SPSPCL          = $D01E
EXTCOL          = $D020
BGCOL0          = $D021
BGCOL1          = $D022
BGCOL2          = $D023
BGCOL3          = $D024
SPMC0           = $D025
SPMC1           = $D026
SP0COL          = $D027
FRELO1          = $D400 ;(54272)
FREHI1          = $D401 ;(54273)
PWLO1           = $D402 ;(54274)
PWHI1           = $D403 ;(54275)
VCREG1          = $D404 ;(54276)
ATDCY1          = $D405 ;(54277)
SUREL1          = $D406 ;(54278)
FRELO2          = $D407 ;(54279)
FREHI2          = $D408 ;(54280)
PWLO2           = $D409 ;(54281)
PWHI2           = $D40A ;(54282)
VCREG2          = $D40B ;(54283)
ATDCY2          = $D40C ;(54284)
SUREL2          = $D40D ;(54285)
FRELO3          = $D40E ;(54286)
FREHI3          = $D40F ;(54287)
PWLO3           = $D410 ;(54288)
PWHI3           = $D411 ;(54289)
VCREG3          = $D412 ;(54290)
ATDCY3          = $D413 ;(54291)
SUREL3          = $D414 ;(54292)
SIGVOL          = $D418 ;(54296)      
COLORRAM        = $D800
CIAPRA          = $DC00
CIAPRB          = $DC01
CIAICR          = $DC0D
CI2PRA          = $DD00
CI2ICR          = $DD0D

;===============================================================================
; $E000-$FFFF  KERNAL ROM (8K)

; Kernal Subroutines
IRQCONTINUE     = $EA81
IRQFINISH       = $EA31
SCNKEY          = $FF9F
GETIN           = $FFE4
CLOSE           = $FFC3
OPEN            = $FFC0
SETNAM          = $FFBD
SETLFS          = $FFBA
CLRCHN          = $FFCC
CHROUT          = $FFD2
LOAD            = $FFD5
SAVE            = $FFD8
RDTIM           = $FFDE

;===============================================================================
