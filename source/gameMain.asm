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

        ; Load game data from disk
        jsr gameDataLoad

        ; Show Splash
        jsr startSplash

        ; Move Screen data to 3rd memory bank
        lda $DD00
        and #%11111100
        ora #%00000001
        sta $DD00

        ; Turn off interrupts to stop LIBSCREEN_WAIT failing every so 
        ; often when the kernal interrupt syncs up with the scanline test
        sei

        ; Disable run/stop + restore keys
        lda #$FC 
        sta $0328

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
        LIBSCREEN_SETCHARMEMORY 10

        ; Initialize the library
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

        ; Update the library
        jsr libInputUpdate
        jsr libSpritesUpdate
        jsr libSoundUpdate

        ; Update the game
        jsr gameAliensUpdate
        jsr gamePlayerUpdate
        jsr gameBulletsUpdate
        jsr gameStarsUpdate
        jsr gameFlowUpdate

        ; End code timer reset border color
        ;dec EXTCOL

        ; Loop back to the start of the game loop
        jmp gMLoop

*=$4711 ;Move game code to load after the splash screen
