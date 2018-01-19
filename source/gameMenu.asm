;===============================================================================
;  gameMenu.asm - Game Main Menu
;
;  Copyright (C) 2017,2018 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
; Constants

MenuStory    = 0
MenuCredits  = 40
MenuHangar   = 80
MenuGameOver = 120
CreditsTime  = 9
MessageTime  = 2
GameOverTime = 5

LevelEasy    = 0
LevelNormal  = 1
LevelHard    = 2

;===============================================================================
; Variables

Operator Calc

MapRAMRowStartLow ; increments are 4 screens x 40 characters per row (160)
        byte <MAPRAM,       <MAPRAM+160,  <MAPRAM+320, <MAPRAM+480
        byte <MAPRAM+640,   <MAPRAM+800,  <MAPRAM+960, <MAPRAM+1120
        byte <MAPRAM+1280, <MAPRAM+1440, <MAPRAM+1600
        byte <MAPRAM+1760, <MAPRAM+1920, <MAPRAM+2080
MapRAMRowStartHigh
        byte >MAPRAM,       >MAPRAM+160,  >MAPRAM+320, >MAPRAM+480
        byte >MAPRAM+640,   >MAPRAM+800,  >MAPRAM+960, >MAPRAM+1120
        byte >MAPRAM+1280, >MAPRAM+1440, >MAPRAM+1600
        byte >MAPRAM+1760, >MAPRAM+1920, >MAPRAM+2080

MAPCOLORRAM = MAPRAM + (4 * 14 * 40)  ; 3 screens x 14 rows x 40 characters

MapRAMCOLRowStartLow ; increments are number of screens x 40 characters per row
        byte <MAPCOLORRAM,       <MAPCOLORRAM+160,  <MAPCOLORRAM+320, <MAPCOLORRAM+480
        byte <MAPCOLORRAM+640,   <MAPCOLORRAM+800,  <MAPCOLORRAM+960, <MAPCOLORRAM+1120
        byte <MAPCOLORRAM+1280, <MAPCOLORRAM+1440, <MAPCOLORRAM+1600
        byte <MAPCOLORRAM+1760, <MAPCOLORRAM+1920, <MAPCOLORRAM+2080
MapRAMCOLRowStartHigh
        byte >MAPCOLORRAM,       >MAPCOLORRAM+160,  >MAPCOLORRAM+320, >MAPCOLORRAM+480
        byte >MAPCOLORRAM+640,   >MAPCOLORRAM+800,  >MAPCOLORRAM+960, >MAPCOLORRAM+1120
        byte >MAPCOLORRAM+1280, >MAPCOLORRAM+1440, >MAPCOLORRAM+1600
        byte >MAPCOLORRAM+1760, >MAPCOLORRAM+1920, >MAPCOLORRAM+2080

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

levelNum        byte LevelNormal
levelEasyText   text 'easy  '
                byte 0
levelNormalText text 'normal'
                byte 0
levelHardText   text 'hard  '
                byte 0
levelPosX       byte 6
levelPosY       byte 21

msgPosX         byte 2
msgPosY         byte 21
menuSaveOK      text '   high score and settings saved    '
                byte 0
menuSaveError   text 'error saving high score and settings'
                byte 0
messageFlag     byte 0
menuColorArray  byte Red, LightRed, Orange, Yellow, LightGreen
                byte Green , Cyan, LightBlue, Blue, Purple, Brown
menuColorClear  byte '           '
                byte 0
menuColorX      byte 1
shipColorIndex  byte 0
shldColorIndex  byte 7
shipRow         byte 10
shipCol         byte 0
shieldRow       byte 17
shieldCol       byte 0

modelSprite     byte 0
modelNameOffset byte 0
modelNames      text '   old faithful    '
                byte 0
                text '  sturdy striker   '
                byte 0
                text ' dynamic destroyer '
                byte 0
                text '  arced assailant  '
                byte 0
                text 'ruthless retaliator'
                byte 0
modelXHigh      byte 0
modelXLow       byte 228
modelY          byte 147
modelNamePosX   byte 18
modelNamePosY   byte 18

sfxOn           text 'on '
                byte 0
sfxOff          text 'off'
                byte 0
sfxPosX         byte 23
sfxPosY         byte 21

statsScoreX     byte 26
statsScoreY     byte 17
statsBulletX    byte 28
statsBulletY    byte 18
statsAliensX    byte 28
statsAliensY    byte 19
statsNumX       byte 0
statsMsgBad     text ' keep practicing, you will improve! '
                byte 0
statsMsgHigh    text '     new high score, great job!     '
                byte 0

;===============================================================================
; Macros/Subroutines

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
        LIBSCREEN_COPYMAPROW_VVA  7, 15, screenColumn
        LIBSCREEN_COPYMAPROW_VVA  8, 16, screenColumn
        LIBSCREEN_COPYMAPROW_VVA  9, 17, screenColumn
        LIBSCREEN_COPYMAPROW_VVA 10, 18, screenColumn
        LIBSCREEN_COPYMAPROW_VVA 11, 19, screenColumn
        LIBSCREEN_COPYMAPROW_VVA 12, 21, screenColumn
        LIBSCREEN_COPYMAPROW_VVA 13, 23, screenColumn

        ; screen colors
        LIBSCREEN_COPYMAPROWCOLOR_VVA  0,  8, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA  1,  9, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA  2, 10, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA  3, 11, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA  4, 12, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA  5, 13, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA  6, 14, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA  7, 15, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA  8, 16, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA  9, 17, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA 10, 18, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA 11, 19, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA 12, 21, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA 13, 23, screenColumn

        rts

;===============================================================================
gameMenuLevelChange

        lda levelNum
        cmp #LevelHard
        beq gMLCEasy
        inc levelNum

        jmp gMLCDone

gMLCEasy
        lda #LevelEasy
        sta levelNum
gMLCDone
        ldx levelNum
        lda bulletSpeedArray,X
        sta bulletSpeed
        lda shieldSpeedArray,X
        sta shieldSpeed
        lda aliensSpeedArray,X
        sta aliensSpeed
        rts

;===============================================================================
gameMenuLevelDisplay

        lda levelNum
        cmp #LevelHard
        beq gMCDHard
        cmp #LevelNormal
        beq gMCDNormal
        jmp gMCDEasy

gMCDHard
        LIBSCREEN_DRAWTEXT_AAAV levelPosX, levelPosY, levelHardText, LightRed
        jmp gMCDDone

gMCDNormal
        LIBSCREEN_DRAWTEXT_AAAV levelPosX, levelPosY, levelNormalText, LightBlue
        jmp gMCDDone

gMCDEasy
        LIBSCREEN_DRAWTEXT_AAAV levelPosX, levelPosY, levelEasyText, Cyan

gMCDDone
        rts

;===============================================================================
gameMenuShipColorNext

        inc shipColorIndex
        lda shipColorIndex
        cmp #11
        bcc gMSCNDone
        lda #0
        sta shipColorIndex
gMSCNDone
        rts

;===============================================================================
gameMenuColorDisplay
        lda shipColorIndex
        sta shipCol
        inc shipCol
        LIBSCREEN_DRAWTEXT_AAAV menuColorX, shipRow, menuColorClear, White
        LIBSCREEN_SETCHARPOSITION_AA shipCol, shipRow
        LIBSCREEN_SETCHAR_V 30

        lda shldColorIndex
        sta shieldCol
        inc shieldCol
        LIBSCREEN_DRAWTEXT_AAAV menuColorX, shieldRow, menuColorClear, White
        LIBSCREEN_SETCHARPOSITION_AA shieldCol, shieldRow
        LIBSCREEN_SETCHAR_V 30
        rts
;===============================================================================
gameMenuShieldColorNext

        inc shldColorIndex
        lda shldColorIndex
        cmp #11
        bcc gMSHNDone
        lda #0
        sta shldColorIndex
gMSHNDone
        rts

;===============================================================================
gameMenuModelPrevious

        lda playerFrameIndex
        bne gMMPDone
        lda #PlayerMaxModels
        sta playerFrameIndex
gMMPDone
        dec playerFrameIndex
        rts

;===============================================================================
gameMenuModelNext

        inc playerFrameIndex
        lda playerFrameIndex
        cmp #PlayerMaxModels
        bcc gMMNDone
        lda #0
        sta playerFrameIndex
gMMNDone
        rts

;===============================================================================
gameMenuModelReset

        LIBSPRITE_STOPANIM_A          modelSprite
        LIBSPRITE_ENABLE_AV           modelSprite, True
        LIBSPRITE_MULTICOLORENABLE_AV modelSprite, True
        LIBSPRITE_SETPOSITION_AAAA modelSprite, modelXHigh, modelXLow, modelY

        rts

;===============================================================================
gameMenuModelDisplay

        ldx playerFrameIndex
        lda playerFrameArray,X
        sta playerFrame

        LIBSPRITE_SETFRAME_AA         modelSprite, playerFrame

        ldx shipColorIndex
        lda menuColorArray,X
        sta playerColor

        LIBSPRITE_SETCOLOR_AA         modelSprite, playerColor

        ; Multiply index by 20 to have the offset (each name has 20 bytes)
        lda playerFrameIndex
        jsr gameflowMultiplyByTen       ; * 10
        asl                             ; * 2
        sta modelNameOffset
        ; Draw the ship name with the offset
        LIBSCREEN_DRAWTEXT_AAAAV modelNamePosX, modelNamePosY, modelNames, modelNameOffset, White
        rts

;===============================================================================
gameMenuModelHide
        LIBSPRITE_ENABLE_AV     modelSprite, False
        rts

;===============================================================================
gameMenuSfxSwitch

        lda soundEffectsDisabled
        beq gMSSDisable

        lda #0
        jmp gMSSDone
gMSSDisable

        lda #1
gMSSDone

        sta soundEffectsDisabled
        jsr gameMenuSfxDisplay

        rts

;===============================================================================
gameMenuSfxDisplay

        lda soundEffectsDisabled
        bne gMSDDisabled

        LIBSCREEN_DRAWTEXT_AAAV sfxPosX, sfxPosY, sfxOn, LightGreen
        jmp gMSDDone
gMSDDisabled

        LIBSCREEN_DRAWTEXT_AAAV sfxPosX, sfxPosY, sfxOff, LightRed
gMSDDone
        rts

;===============================================================================
gameMenuSaveDisplay

        lda diskErrorFlag
        bne gMSVError
        LIBSCREEN_DRAWTEXT_AAAV msgPosX, msgPosY, menuSaveOK, LightGreen
        jmp gMSVDone

gMSVError
        LIBSCREEN_DRAWTEXT_AAAV msgPosX, msgPosY, menuSaveError, LightRed

gMSVDone
        lda #True
        sta messageFlag
        rts

;===============================================================================
gameMenuRestore

        LIBSCREEN_COPYMAPROW_VVA 12, 21, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA 12, 21, screenColumn

        lda #False
        sta messageFlag
        rts

;===============================================================================
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

;===============================================================================
gameMenuShowStats

        LIBSCREEN_DRAWDECIMAL_AAAV statsScoreX, statsScoreY, score3, White

        LIBMATH_ADD8BIT_AVA statsScoreX, 2, statsNumX
        LIBSCREEN_DRAWDECIMAL_AAAV statsNumX, statsScoreY, score2, White

        LIBMATH_ADD8BIT_AVA statsScoreX, 4, statsNumX
        LIBSCREEN_DRAWDECIMAL_AAAV statsNumX, statsScoreY, score1, White

        LIBSCREEN_DRAWDECIMAL_AAAV statsBulletX, statsBulletY, bullets2, White

        LIBMATH_ADD8BIT_AVA statsBulletX, 2, statsNumX
        LIBSCREEN_DRAWDECIMAL_AAAV statsNumX, statsBulletY, bullets1, White

        LIBSCREEN_DRAWDECIMAL_AAAV statsAliensX, statsAliensY, aliens2, White

        LIBMATH_ADD8BIT_AVA statsAliensX, 2, statsNumX
        LIBSCREEN_DRAWDECIMAL_AAAV statsNumX, statsAliensY, aliens1, White

        lda statsHiScore
        bne gMSTHigh
        lda aliens2
        bne gMSTDone
        lda aliens1
        cmp #20
        bcc gMSTBad
gMSTDone
        rts
gMSTBad
        LIBSCREEN_DRAWTEXT_AAAV msgPosX, msgPosY, statsMsgBad, Yellow
        rts
gMSTHigh
        LIBSCREEN_DRAWTEXT_AAAV msgPosX, msgPosY, statsMsgHigh, LightGreen
        rts
