;===============================================================================
;  gameMemory.asm - Game Memory Map
;
;  Copyright (C) 2017-2021 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
; $00-$FF  PAGE ZERO (256 bytes)
 
                ; $00-$01   Reserved for IO
                ; $02-$09   Used on libMultiplex.asm
                ; $0A-$0F   Used on gameFlow.asm
                ; $10-$15   Used on gameWaves.asm
                ; $16-$18   Used on libMultiplex.asm
                ; $19-$1A   Used on gamePlayer.asm
                ; $1D-$2F   Used on gameAliens.asm
                ; $30-$3F   Used on gamePlayer.asm
                ; $40-$61   Used on libMultiplex.asm
                ; $72-$7D   Temporary variables for libraries
ZeroPageTemp    = $72
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
                ; $8D       Used on libMultiplex.asm
                ; $8E       Used on libMusic.asm
                ; $90-$FA   Reserved for Kernal
                ; $E0-$E8   Used on gameStars.asm
                ; $EA-$EF   Used on gameBomber.asm
ZeroPageLow     = $FB
ZeroPageHigh    = $FC
ZeroPageLow2    = $FD
ZeroPageHigh2   = $FE
                ; $FF       Reserved for Kernal

;===============================================================================
; $0100-$01FF  STACK (256 bytes)

;===============================================================================
; $0200-$9FFF  RAM (40K)
; #0340-$034A  Data File - gameData.asm

; $0801-$47FF
; Game code is placed here by using the *=$0801 directive on gameMain.asm

; Custom Character Set
; letters and numbers from the font "Teggst shower 5"
; http://kofler.dot.at/c64/download/teggst_shower_5.zip
; Hi-resolution graphics for the menu borders by Trevor Storey
CHARSETPOSGAME  = 4
CHARSETRAM      = $5000
* = $5000
        incbin "characters.cst",0,230

; Screen RAM and Sprites
SCREENRAM       = $5800
SPRITE0         = SCREENRAM + $03F8

; 112 decimal * 64(sprite size) = 7168 (hex $1C00)
; VIC II is looking at $4000 adding $1C00 we have $5C00
SPRITERAM       = 112
* = $5C00
        incbin "sprites.spt",1,81,true

;===============================================================================
; $8000-$8FFF  Menu screens placed here - defined on the res*.asm files

;===============================================================================
; $A000-$BFFF  BASIC ROM (8K) - Disabled for this game
; Game Text and Aliens Wave data are also placed here - defined on gameWaves.asm

;===============================================================================
; $C000-$CFFF  RAM (4K)

; SFX
CollectVoice    = $02
ExplosionVoice  = $01
FiringVoice     = $01

; SID music
SIDINIT         = $C000
SIDPLAY         = SIDINIT + 3
SIDGAMELOOP     = $00   ; Id of the song (inside the SID file)

* = $C000
        incbin "..\assets\music.sid", $7E

;===============================================================================
; $D000-$DFFF  IO (4K)

;===============================================================================
; $E000-$FFFF  KERNAL ROM + Free RAM (8K)

