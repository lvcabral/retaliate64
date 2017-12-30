;===============================================================================
;  gameMemory.asm - Game Memory Map
;
;  Copyright (C) 2017,2018 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
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

* = $1000
MAPRAM
        ; Menu screens
        ; Export List: 1-2(9),1-2(10),1-2(11),1-2(12),1-2(13),1-2(14),1-2(15),1-2(17),1-2(18),1-2(19),1-2(20),1-2(22),1-2(24)
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

; 192 decimal * 64(sprite size) = 12288(hex $3000)
SPRITERAM       = 192
* = $B000
        incbin sprites.bin
* = $B800
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

;===============================================================================
; $E000-$FFFF  KERNAL ROM (8K) 


;===============================================================================
