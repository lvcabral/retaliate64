;===============================================================================
;  gameMain.asm - Main Game Loop
;
;  Copyright (C) 2017-2021 Marcelo Lv Cabral - <https://lvcabral.com>
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
        mva #$36, R6510

        ; Disable shift + C= keys
        mva #$80, MODE

        ; Disable run/stop + restore keys
        mva #$FC, ISTOP

        ; Save VIC II mode (NTSC/PAL)
L1      lda RASTER
L2      cmp RASTER
        beq L2
        bmi L1
        cmp #$20
        bcc gARNTSC
        mva #1, vicMode
        lda #CyclesPAL
        jmp gARSetCycles

gARNTSC
        mva #0, vicMode
        lda #CyclesNTSC

gARSetCycles
        sta cycles
        ; Load game data from disk
        jsr gameDataLoad

        ; Fill 1000 bytes (40x25) of screen memory
        jsr gameMenuClearScreen

        ; Move VIC II to see 2nd memory bank ($4000-$7FFF)
        lda CI2PRA
        and #%11111100
        ora #%00000010
        sta CI2PRA

        ; Screen Memory @ $1800 and Charset @ $1000
        mva #%01100100, VMCSB

        ; Set border and background colors
        LIBSCREEN_SETCOLORS Black, Black, Yellow, DarkGray, Black

        ; Set sprite multicolors
        LIBSPRITE_SETMULTICOLORS_VV Blue, White
        
        ; Initialize SID registers
        jsr libSoundInit

        ; Initialize Sprite Multiplexer
        jsr libMultiplexInit

        ; Initialize the game
        jsr gamePlayerInit
        jsr gameAliensInit
        jsr gameFlowInit
        jsr gameStarsInit
        jsr gameStarsCache

;===============================================================================
; Main Game Loop

gMLoop
        lda flowPaused
        bne gMFlow

        lda playerActive
        bne gMActive
        jsr libInputUpdate
        jsr libMultiplexUpdateAnims
        jmp gMStars

gMActive
        ; Update Music
        jsr libMusicMixedUpdate
        ; Update libraries
        jsr libInputUpdate
        jsr libMultiplexUpdateAnims

        ; Update the game
        lda playerFlyUp
        beq gMAliens

gMPlayerFlyUp
        ;inc EXTCOL
        jsr gamePlayerUpdate
        jsr gameStarsWarp
        jmp gMSound

gMAliens
        ;inc EXTCOL
        jsr gameAliensUpdate
        jsr gameBomberUpdate
        jsr gameBombsUpdate
        ;inc EXTCOL
        jsr gamePlayerUpdate
        ;inc EXTCOL
        jsr gameBulletsUpdate

gMStars
        ;inc EXTCOL
        jsr gameStarsUpdate

gMSound
        lda soundDisabled
        bne gMFlow
        ;inc EXTCOL
        jsr libSoundUpdate

gMFlow
        ;inc EXTCOL
        jsr gameFlowUpdate
        ; End code timer reset border color
        ;lda #0
        ;sta EXTCOL

        ;Sort sprites, build sprite IRQ lists and set the update flag
        jsr libMultiplexSortSprites
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
        jsr gamePlayerSpriteSwap

gMEndLoop
        jmp gMLoop
