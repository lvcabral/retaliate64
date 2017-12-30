;===============================================================================
;  gameMenu.asm - Game Main Menu
;
;  Copyright (C) 2017,2018 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
;
;===============================================================================

; Constants
MenuStory   = 0
MenuCredits = 40
CreditsTime = 9

; Variables

Operator Calc

MapRAMRowStartLow ; increments are 3 screens x 40 characters per row (120)
        byte <MAPRAM,     <MAPRAM+80,  <MAPRAM+160
        byte <MAPRAM+240, <MAPRAM+320, <MAPRAM+400
        byte <MAPRAM+480, <MAPRAM+560, <MAPRAM+640
        byte <MAPRAM+720, <MAPRAM+800, <MAPRAM+880, <MAPRAM+960
MapRAMRowStartHigh
        byte >MAPRAM,     >MAPRAM+80,  >MAPRAM+160
        byte >MAPRAM+240, >MAPRAM+320, >MAPRAM+400
        byte >MAPRAM+480, >MAPRAM+560, >MAPRAM+640
        byte >MAPRAM+720, >MAPRAM+800, >MAPRAM+880, >MAPRAM+960

MAPCOLORRAM = MAPRAM + (2 * 13 * 40)  ; 2 screens x 13 rows x 40 characters

MapRAMCOLRowStartLow ; increments are number of screens x 40 characters per row
        byte <MAPCOLORRAM,     <MAPCOLORRAM+80,  <MAPCOLORRAM+160
        byte <MAPCOLORRAM+240, <MAPCOLORRAM+320, <MAPCOLORRAM+400
        byte <MAPCOLORRAM+480, <MAPCOLORRAM+560, <MAPCOLORRAM+640
        byte <MAPCOLORRAM+720, <MAPCOLORRAM+800, <MAPCOLORRAM+880, <MAPCOLORRAM+960
MapRAMCOLRowStartHigh
        byte >MAPCOLORRAM,     >MAPCOLORRAM+80,  >MAPCOLORRAM+160
        byte >MAPCOLORRAM+240, >MAPCOLORRAM+320, >MAPCOLORRAM+400
        byte >MAPCOLORRAM+480, >MAPCOLORRAM+560, >MAPCOLORRAM+640
        byte >MAPCOLORRAM+720, >MAPCOLORRAM+800, >MAPCOLORRAM+880, >MAPCOLORRAM+960

Operator HiLo

menuDisplayed   byte   0
menuTimer       byte   0

logoXHighArray  byte   0,   0,   0,   0,   0,   0,   0
logoXHigh       byte   0
logoXLowArray   byte 100, 124, 148, 172, 196, 220, 244
logoXLow        byte   0
logoYArray      byte  77,  77,  77,  77,  77,  77,  77
logoY           byte   0
logoXChar       byte   0
logoXOffset     byte   0
logoYOffset     byte   0
logoYChar       byte   0
logoSprite      byte   0
logoFrame       byte   0

;===============================================================================

gameMenuShowLogo

        ldx #0
        stx logoSprite
        lda #19
        sta logoFrame

gMSLLoop
        inc logoSprite ; x+1

        lda logoXHighArray,X
        sta logoXHigh
        lda logoXLowArray,X
        sta logoXLow
        lda logoYArray,X
        sta logoY

        LIBSPRITE_STOPANIM_A          logoSprite
        LIBSPRITE_ENABLE_AV           logoSprite, True
        LIBSPRITE_SETFRAME_AA         logoSprite, logoFrame
        LIBSPRITE_SETCOLOR_AV         logoSprite, LightBlue
        LIBSPRITE_MULTICOLORENABLE_AV logoSprite, True

        jsr gameMenuLogoUpdate

        ; loop for each frame
        inc logoFrame
        inx
        cpx #7
        bne gMSLLoop

        rts

;===============================================================================

gameMenuLogoUpdate

        LIBSPRITE_SETPRIORITY_AV      logoSprite, False
        LIBSPRITE_SETPOSITION_AAAA logoSprite, logoXHigh, logoXLow, logoY
        LIBSCREEN_PIXELTOCHAR_AAVAVAAAA logoXHigh, logoXLow, 12, logoY, 40, logoXChar, logoXOffset, logoYChar, logoYOffset

        rts

;===============================================================================

gameMenuShowText

        lda #True
        sta menuDisplayed

        ; screen text
        LIBSCREEN_COPYMAPROW_VVA  0,  8, screenColumn
        LIBSCREEN_COPYMAPROW_VVA  1,  9, screenColumn
        LIBSCREEN_COPYMAPROW_VVA  2, 10, screenColumn
        LIBSCREEN_COPYMAPROW_VVA  3, 11, screenColumn
        LIBSCREEN_COPYMAPROW_VVA  4, 12, screenColumn
        LIBSCREEN_COPYMAPROW_VVA  5, 13, screenColumn
        LIBSCREEN_COPYMAPROW_VVA  6, 14, screenColumn
        LIBSCREEN_COPYMAPROW_VVA  7, 16, screenColumn
        LIBSCREEN_COPYMAPROW_VVA  8, 17, screenColumn
        LIBSCREEN_COPYMAPROW_VVA  9, 18, screenColumn
        LIBSCREEN_COPYMAPROW_VVA 10, 19, screenColumn
        LIBSCREEN_COPYMAPROW_VVA 11, 21, screenColumn
        LIBSCREEN_COPYMAPROW_VVA 12, 23, screenColumn

        ; screen colors
        LIBSCREEN_COPYMAPROWCOLOR_VVA  0,  8, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA  1,  9, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA  2, 10, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA  3, 11, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA  4, 12, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA  5, 13, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA  6, 14, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA  7, 16, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA  8, 17, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA  9, 18, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA 10, 19, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA 11, 21, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA 12, 23, screenColumn

        lda screenColumn
        cmp #MenuCredits
        bcc gMSTCredits
        lda #MenuStory
        jmp gMSTEnd
gMSTCredits
        jsr gameFlowResetTime
        lda #MenuCredits
gMSTEnd
        sta screenColumn

        rts

gameMenuClearText

        lda #False
        sta menuDisplayed

        ; Fill 1000 bytes (40x25) of screen memory 
        LIBSCREEN_SET1000 SCREENRAM, SpaceCharacter

        LIBSCREEN_DRAWTEXT_AAAV flowScoreX, flowScoreY, flowScoreText, White
        jsr gameFlowScoreDisplay

        LIBSCREEN_DRAWTEXT_AAAV flowHiScoreX, flowHiScoreY, flowHiScoreText, White
        jsr gameFlowHiScoreDisplay

        rts