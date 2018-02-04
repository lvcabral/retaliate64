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

        ; Turn off CIAs Timer interrupts ($7F = %01111111)
        ldy #$7F
        sty $DC0D
        sty $DD0D
        ; Cancel all CIA-IRQs in queue/unprocessed
        lda $DC0D
        lda $DD0D

        ; Disable BASIC ROM
        lda #$36
        sta $01

        ; Disable shift + C= keys
        lda $80
        sta $0291

        ; Disable run/stop + restore keys
        lda #$FC 
        sta $0328

        ; Save VIC II mode (NTSC/PAL)
        lda $02A6
        sta vicMode

        ; Load game data from disk
        jsr gameDataLoad

        ; Move VIC II to see 2nd memory bank ($4000-$7FFF)
        lda $DD00
        and #%11111100
        ora #%00000010
        sta $DD00

        ; Show Splash Bitmap
        jsr startSplash

        ; Set border and background colors
        ; The last 3 parameters are not used yet
        LIBSCREEN_SETCOLORS Black, Black, Black, Black, Black

        ; Fill 1000 bytes (40x25) of screen memory 
        LIBSCREEN_SET1000 SCREENRAM, SpaceCharacter

        ; Fill 1000 bytes (40x25) of color memory
        LIBSCREEN_SET1000 COLORRAM, White

        ; Set sprite multicolors
        LIBSPRITE_SETMULTICOLORS_VV LightBlue, White
        
        ; Set the memory location of the custom character set
        LIBSCREEN_SETCHARMEMORY CHARSETPOS

        ; Initialize SID registers
        jsr libSoundInit

        ; Initialize the game
        jsr gamePlayerInit
        jsr gameFlowInit
;===============================================================================
; Update

gMLoop
        ; Wait for scanline 255
        LIBSCREEN_WAIT_V 255

        ; Start code timer change border color
        ;inc EXTCOL
        lda flowPaused
        bne gMFlow

        ; Update the library
        jsr libInputUpdate
        jsr libSpritesUpdate

        ; Update the game
        lda playerActive
        beq gMSound

        ;inc EXTCOL
        jsr gameAliensUpdate
        ;inc EXTCOL
        jsr gamePlayerUpdate
        ;inc EXTCOL
        jsr gameBulletsUpdate

gMSound
        lda soundDisabled
        bne gMMusic
        ;inc EXTCOL
        jsr libSoundUpdate

gMMusic
        lda sidDisabled
        bne gMStars
        jsr libMusicUpdate
gMStars
        ;inc EXTCOL
        jsr gameStarsUpdate
gMFlow
        ;inc EXTCOL
        jsr gameFlowUpdate

        ; End code timer reset border color
        ;lda #0
        ;sta EXTCOL

        ; Loop back to the start of the game loop
        jmp gMLoop
