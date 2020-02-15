;===============================================================================
;  gameMain.asm - Main Game Loop
;
;  Copyright (C) 2017,2018 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
; BASIC Loader

*=$0801 ; 10 SYS (2064)

        byte $0E, $08, $0A, $00, $9E, $20, $28, $32
        byte $30, $36, $34, $29, $00, $00, $00

        ; Our code starts at $0810 (2064 decimal)
        ; after the 15 bytes for the BASIC loader

;===============================================================================
; Initialize

        ; Disable BASIC ROM
        lda #$36
        sta $01

        ; Disable shift + C= keys
        lda $80
        sta MODE

        ; Disable run/stop + restore keys
        lda #$FC 
        sta ISTOP

        ; Save VIC II mode (NTSC/PAL)
        lda $02A6
        sta vicMode

        ; Load game data from disk
        jsr gameDataLoad

        ; Move VIC II to see 2nd memory bank ($4000-$7FFF)
        lda CI2PRA
        and #%11111100
        ora #%00000010
        sta CI2PRA

        ; Show Splash Bitmap
        jsr startSplash

gARSeed ; Generate Random Seed
        jsr RDTIM
        cmp #0
        beq gARSeed
        sta rndSeed

        ; Set border and background colors
        LIBSCREEN_SETCOLORS Black, Black, Black, Black, Black

        ; Fill 1000 bytes (40x25) of screen memory 
        LIBSCREEN_SET1000 SCREENRAM, SpaceCharacter

        ; Set sprite multicolors
        LIBSPRITE_SETMULTICOLORS_VV LightBlue, White
        
        ; Set the memory location of the custom character set
        LIBSCREEN_SETCHARMEMORY CHARSETPOS

        ; Initialize SID registers
        jsr libSoundInit

        ; Initialize Sprite Multiplexer
        jsr libMultiplexInit

        ; Initialize the game
        jsr gameAliensInit
        jsr gameFlowInit
        jsr gameStarsInit
        jsr gameStarsCache

;===============================================================================
; Main Game Loop

gMLoop
        lda flowPaused
        bne gMFlow

        ; Start code timer change border color
        ;inc EXTCOL

        ; Update libraries
        jsr libInputUpdate
        jsr libSpritesUpdate

        ; Update the game
        lda playerActive
        beq gMSound

        lda sidDisabled
        bne gMGame
        ;inc EXTCOL
        jsr libMusicUpdate
gMGame
        ;inc EXTCOL
        jsr gameAliensUpdate
        ;inc EXTCOL
        jsr gamePlayerUpdate
        ;inc EXTCOL
        jsr gameBulletsUpdate

gMSound
        lda soundDisabled
        bne gMStars
        ;inc EXTCOL
        jsr libSoundUpdate

gMStars
        ;inc EXTCOL
        jsr gameStarsUpdate

gMFlow
        ;inc EXTCOL
        jsr gameFlowUpdate
        ; End code timer reset border color
        ;lda #0
        ;sta EXTCOL

        ;Sort sprites, build sprite IRQ lists and set the update flag
        jsr sortsprites
        ;Check if shield is under the player ship to swap
        lda shieldOrder
        cmp #$07
        bne gMNext
        lda playerOrder
        cmp #$08
        bne gMNext
        jmp gMSwap
gMNext
        lda shieldOrder
        cmp #$17
        bne gMEndLoop
        lda playerOrder
        cmp #$18
        bne gMEndLoop
gMSwap
        jsr libSpritesSwap
gMEndLoop
        jmp gMLoop
