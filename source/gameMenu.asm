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
MenuInfo     = 160

ScreenTime   = 9
MessageTime  = 2
GameOverTime = 5

LevelEasy    = 0
LevelNormal  = 1
LevelHard    = 2

ColorCursor  = 92

; PETSCII Key Codes
KEY_BACK     = $5F
KEY_RETURN   = $0D
KEY_DEL      = $14
KEY_CLR      = $93
KEY_HOME     = $13
KEY_INST     = $94
KEY_SPACE    = $20
KEY_M        = $4D
KEY_S        = $53
KEY_F1       = $85
KEY_F2       = $89
KEY_F3       = $86
KEY_F4       = $8A
KEY_F5       = $87
KEY_F6       = $8B
KEY_F7       = $88
KEY_F8       = $8C
KEY_DOWN     = $11
KEY_UP       = $91
KEY_RIGHT    = $1D
KEY_LEFT     = $9D

;===============================================================================
; Variables

Operator Calc

; 5 screens x 14 rows x 40 characters
MAPCOLORRAM = MAPRAM + (5 * 15 * 40)

; increments are 5 screens x 40 characters per row (200)
MapRAMRowStartLow
        byte <MAPRAM,      <MAPRAM+200,  <MAPRAM+400,  <MAPRAM+600
        byte <MAPRAM+800,  <MAPRAM+1000, <MAPRAM+1200, <MAPRAM+1400
        byte <MAPRAM+1600, <MAPRAM+1800, <MAPRAM+2000, <MAPRAM+2200
        byte <MAPRAM+2400, <MAPRAM+2600, <MAPRAM+2800
MapRAMRowStartHigh
        byte >MAPRAM,      >MAPRAM+200,  >MAPRAM+400,  >MAPRAM+600
        byte >MAPRAM+800,  >MAPRAM+1000, >MAPRAM+1200, >MAPRAM+1400
        byte >MAPRAM+1600, >MAPRAM+1800, >MAPRAM+2000, >MAPRAM+2200
        byte >MAPRAM+2400, >MAPRAM+2600, >MAPRAM+2800

MapRAMCOLRowStartLow
        byte <MAPCOLORRAM,      <MAPCOLORRAM+200,  <MAPCOLORRAM+400
        byte <MAPCOLORRAM+600,  <MAPCOLORRAM+800,  <MAPCOLORRAM+1000
        byte <MAPCOLORRAM+1200, <MAPCOLORRAM+1400, <MAPCOLORRAM+1600
        byte <MAPCOLORRAM+1800, <MAPCOLORRAM+2000, <MAPCOLORRAM+2200
        byte <MAPCOLORRAM+2400, <MAPCOLORRAM+2600, <MAPCOLORRAM+2800
MapRAMCOLRowStartHigh
        byte >MAPCOLORRAM,      >MAPCOLORRAM+200,  >MAPCOLORRAM+400
        byte >MAPCOLORRAM+600,  >MAPCOLORRAM+800,  >MAPCOLORRAM+1000
        byte >MAPCOLORRAM+1200, >MAPCOLORRAM+1400, >MAPCOLORRAM+1600
        byte >MAPCOLORRAM+1800, >MAPCOLORRAM+2000, >MAPCOLORRAM+2200
        byte >MAPCOLORRAM+2400, >MAPCOLORRAM+2600, >MAPCOLORRAM+2800

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
logoFlag        byte   0

levelNum        byte LevelNormal
levelEasyText   text 'easy  '
                byte 0
levelNormalText text 'normal'
                byte 0
levelHardText   text 'hard  '
                byte 0
levelPosX       byte 18
levelPosY       byte 21

msgPosX         byte 1
msgPosY         byte 21
menuSaveOK      text '    high score and settings saved     '
                byte 0
menuSaveError   text ' error saving high score and settings '
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
modelNamePosY   byte 17

musicPosX       byte 18
musicPosY       byte 19
sfxOn           byte $52, $53
                byte 0
sfxOff          text $51, $20
                byte 0
sfxPosX         byte 28
sfxPosY         byte 19

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

        jsr gameMenuLogoSetup
        jsr gameMenuLogoUpdate

        LIBSPRITE_ENABLE_AV logoSprite, True

        ; loop for each frame
        inc logoFrame
        inx
        cpx #7
        bne gMSLLoop

        rts

;===============================================================================
gameMenuShowHangar
        ldx #0
        stx logoSprite
        lda #30
        sta logoFrame

gMSHLoop
        inc logoSprite ; x+1
        cpx #5
        bcc gMSHShow
        lda #False
        sta logoFlag
        jmp gMSHNext
gMSHShow
        lda #True
        sta logoFlag
        lda logoXHighArray,X+1
        sta logoXHigh
        lda logoXLowArray,X+1
        sta logoXLow
        lda logoYArray,X
        sta logoY

        jsr gameMenuLogoSetup
        jsr gameMenuLogoUpdate

gMSHNext
        LIBSPRITE_ENABLE_AA logoSprite, logoFlag
        ; loop for each frame
        inc logoFrame
        inx
        cpx #7
        bne gMSHLoop

        rts

;===============================================================================
gameMenuLogoSetup
        LIBSPRITE_STOPANIM_A          logoSprite
        LIBSPRITE_SETFRAME_AA         logoSprite, logoFrame
        LIBSPRITE_SETCOLOR_AV         logoSprite, LightBlue
        LIBSPRITE_MULTICOLORENABLE_AV logoSprite, True
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
repeat 0, 13, idx
        LIBSCREEN_COPYMAPROW_VVA  idx,  idx + 8, screenColumn
endrepeat
        LIBSCREEN_COPYMAPROW_VVA 14, 23, screenColumn

        ; screen colors
repeat 0, 13, idx
        LIBSCREEN_COPYMAPROWCOLOR_VVA  idx,  idx + 8, screenColumn
endrepeat
        LIBSCREEN_COPYMAPROWCOLOR_VVA 14, 23, screenColumn

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
        LIBSCREEN_SETCHAR_V ColorCursor

        lda shldColorIndex
        sta shieldCol
        inc shieldCol
        LIBSCREEN_DRAWTEXT_AAAV menuColorX, shieldRow, menuColorClear, White
        LIBSCREEN_SETCHARPOSITION_AA shieldCol, shieldRow
        LIBSCREEN_SETCHAR_V ColorCursor
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
        LIBSPRITE_STOPANIM_A          playerSprite
        LIBSPRITE_ENABLE_AV           playerSprite, True
        LIBSPRITE_MULTICOLORENABLE_AV playerSprite, True
        LIBSPRITE_SETPOSITION_AAAA playerSprite, modelXHigh, modelXLow, modelY
        LIBSPRITE_SETPOSITION_AAAA shieldSprite, modelXHigh, modelXLow, modelY
        jsr gamePlayerSetupShield
        rts

;===============================================================================
gameMenuModelDisplay
        jsr gamePlayerLoadConfig
        LIBSPRITE_SETFRAME_AA playerSprite, playerFrame
        LIBSPRITE_SETCOLOR_AA playerSprite, playerColor
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
        LIBSPRITE_ENABLE_AV playerSprite, False
        LIBSPRITE_ENABLE_AV shieldSprite, False
        rts

;===============================================================================
gameMenuShieldDisplay
        jsr gamePlayerLoadConfig
        LIBSPRITE_SETCOLOR_AA shieldSprite, shieldColor
        LIBSPRITE_ENABLE_AV   shieldSprite, True
        rts

;===============================================================================
gameMenuSfxSwitch
        lda soundDisabled
        beq gMSSDisable

        lda #0
        jmp gMSSDone

gMSSDisable
        lda #1

gMSSDone
        sta soundDisabled
        rts

;===============================================================================
gameMenuSfxDisplay
        lda soundDisabled
        bne gMSDDisabled

        LIBSCREEN_DRAWTEXT_AAAV sfxPosX, sfxPosY, sfxOn, LightGreen
        jmp gMSDDone

gMSDDisabled
        LIBSCREEN_DRAWTEXT_AAAV sfxPosX, sfxPosY, sfxOff, LightRed

gMSDDone
        rts

;===============================================================================
gameMenuMusicSwitch
        lda sidDisabled
        beq gMMSDisable

        lda #0
        jmp gMMSDone

gMMSDisable
        lda #1

gMMSDone
        sta sidDisabled
        rts

;===============================================================================
gameMenuMusicDisplay

        lda sidDisabled
        bne gMMDDisabled

        LIBSCREEN_DRAWTEXT_AAAV musicPosX, musicPosY, sfxOn, LightGreen
        jmp gMMDDone
gMMDDisabled

        LIBSCREEN_DRAWTEXT_AAAV musicPosX, musicPosY, sfxOff, LightRed
gMMDDone
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

        LIBSCREEN_COPYMAPROW_VVA 13, 21, screenColumn
        LIBSCREEN_COPYMAPROWCOLOR_VVA 13, 21, screenColumn

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
