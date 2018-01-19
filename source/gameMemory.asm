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
                ; $03-$8F   Reserved for BASIC
                ; using $73-$8A CHRGET as BASIC not used for our game
ZeroPageParam1  = $73
ZeroPageParam2  = $74
ZeroPageParam3  = $75
ZeroPageParam4  = $76
ZeroPageParam5  = $77
ZeroPageParam6  = $78
ZeroPageParam7  = $79
ZeroPageParam8  = $7A
ZeroPageParam9  = $7B
ZeroPageTemp1   = $80
ZeroPageTemp2   = $81
                ; $90-$FA   Reserved for Kernal
ZeroPageLow     = $FB
ZeroPageHigh    = $FC
ZeroPageLow2    = $FD
ZeroPageHigh2   = $FE
                ; $FF       Reserved for Kernal

;===============================================================================
; $0100-$01FF  STACK (256 bytes)


;===============================================================================
; $0200-$9FFF  RAM (40K)

; $0801
; gameMain.asm is placed here by using the *=$0801 directive 

* = $0900
MAPRAM
        ; Menu screens
        ; Export List: 1-4(9),1-4(10),1-4(11),1-4(12),1-4(13),1-4(14),1-4(15),1-4(16),1-4(17),1-4(18),1-4(19),1-4(20),1-4(22),1-4(24)
        incbin screens.bin

* = $2000
        ; Splash screen bitmap
        incbin splash.bin

; $4711
; Rest of game code (from gameFlow.asm) is placed here,
; after the splash, to avoid 8K limit

SCREENRAM       = $8400
SPRITE0         = $87F8

;===============================================================================
; $A000-$BFFF  BASIC ROM (8K)

; 128 decimal * 64(sprite size) = 8192 (hex $2000) 
; VIC II is looking at $8000 adding $2000 we have $A000
SPRITERAM       = 128
* = $A000
        incbin sprites.bin
; The character set ($D018) is pointing to 10 decimal (%xxxx101x)
; So charmem is at $2800 plus bank start $8000 we have $A800
* = $A800
        ; letters and numbers from the font "Teggst shower 5"
        ; http://kofler.dot.at/c64/download/teggst_shower_5.zip
        incbin characters.bin
 
;===============================================================================
; $C000-$CFFF  RAM (4K)

;===============================================================================
; $D000-$DFFF  IO (4K)

; These are some of the C64 registers that are mapped into
; IO memory space
; Names taken from 'Mapping the Commodore 64' book

SP0X            = $D000
SP0Y            = $D001
MSIGX           = $D010
RASTER          = $D012
SPENA           = $D015
SCROLX          = $D016
VMCSB           = $D018
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

; Kernal Subroutines
SCNKEY          = $FF9F
GETIN           = $FFE4
CLOSE           = $FFC3
OPEN            = $FFC0
SETNAM          = $FFBD
SETLFS          = $FFBA
CLRCHN          = $FFCC
LOAD            = $FFD5
SAVE            = $FFD8

; PETSCII Key Codes
KEY_RETURN      = $0D
KEY_DEL         = $14
KEY_CLR         = $93
KEY_HOME        = $13
KEY_INST        = $94
KEY_SPACE       = $20
KEY_F1          = $85
KEY_F2          = $89
KEY_F3          = $86
KEY_F4          = $8A
KEY_F5          = $87
KEY_F6          = $8B
KEY_F7          = $88
KEY_F8          = $8C
KEY_DOWN        = $11
KEY_UP          = $91
KEY_RIGHT       = $1D
KEY_LEFT        = $9D

;===============================================================================
; $E000-$FFFF  KERNAL ROM (8K) 


;===============================================================================
