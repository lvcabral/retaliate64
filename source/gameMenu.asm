;===============================================================================
;  gameMenu.asm - Game Main Menu
;
;  Copyright (C) 2017-2019 Marcelo Lv Cabral - <https://lvcabral.com>
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
MenuEnemies  = 200
MenuHonor    = 240

Logo1stFrame = 58
HangarFrame  = 65
LockedFrame  = 15

MedalSpot    = 28
MedalEasy    = MedalSpot+1
MedalNormal  = MedalSpot+2
MedalHard    = MedalSpot+3
MedalExtreme = MedalSpot+4

UnlockedSpr  = AliensMax+4
UnlockedSprX = 42
UnlockedSprY = 212

MessageTime  = 2
GameOverTime = 6

LevelEasy    = 0
LevelNormal  = 1
LevelHard    = 2
LevelExtreme = 3

LogoXPos     = 100
LogoYPos     = 77
HangarYPos   = 77
MedalYPos    = 195

ModelXPos    = 240
ModelYPos    = 140

ColorCursor  = 92
MenuCursor   = 94

StatsScoreX  = 27
StatsX       = 29
StatsScoreY  = 16
StatsBulletY = StatsScoreY+1
StatsBombY   = StatsScoreY+2
StatsAliensY = StatsScoreY+3

MaxColors    = 12

;===============================================================================
; Variables

Operator Calc

; 7 screens x 14 rows x 40 characters
MAPCOLORRAM = MAPRAM + (7 * 14 * 40)

; increments are 7 screens x 40 characters per row (280)
CCT1 = 7 * 40
CCT2 = CCT1 * 2
CCT3 = CCT1 * 3
CCT4 = CCT1 * 4
CCT5 = CCT1 * 5
CCT6 = CCT1 * 6
CCT7 = CCT1 * 7
CCT8 = CCT1 * 8
CCT9 = CCT1 * 9
CCTA = CCT1 * 10
CCTB = CCT1 * 11
CCTC = CCT1 * 12
CCTD = CCT1 * 13

MapRAMRowStartLow
        byte <MAPRAM,      <MAPRAM+CCT1, <MAPRAM+CCT2, <MAPRAM+CCT3
        byte <MAPRAM+CCT4, <MAPRAM+CCT5, <MAPRAM+CCT6, <MAPRAM+CCT7
        byte <MAPRAM+CCT8, <MAPRAM+CCT9, <MAPRAM+CCTA, <MAPRAM+CCTB
        byte <MAPRAM+CCTC, <MAPRAM+CCTD

MapRAMRowStartHigh
        byte >MAPRAM,      >MAPRAM+CCT1, >MAPRAM+CCT2, >MAPRAM+CCT3
        byte >MAPRAM+CCT4, >MAPRAM+CCT5, >MAPRAM+CCT6, >MAPRAM+CCT7
        byte >MAPRAM+CCT8, >MAPRAM+CCT9, >MAPRAM+CCTA, >MAPRAM+CCTB
        byte >MAPRAM+CCTC, >MAPRAM+CCTD

MapRAMCOLRowStartLow
        byte <MAPCOLORRAM,      <MAPCOLORRAM+CCT1, <MAPCOLORRAM+CCT2
        byte <MAPCOLORRAM+CCT3, <MAPCOLORRAM+CCT4, <MAPCOLORRAM+CCT5
        byte <MAPCOLORRAM+CCT6, <MAPCOLORRAM+CCT7, <MAPCOLORRAM+CCT8
        byte <MAPCOLORRAM+CCT9, <MAPCOLORRAM+CCTA, <MAPCOLORRAM+CCTB
        byte <MAPCOLORRAM+CCTC, <MAPCOLORRAM+CCTD

MapRAMCOLRowStartHigh
        byte >MAPCOLORRAM,      >MAPCOLORRAM+CCT1, >MAPCOLORRAM+CCT2
        byte >MAPCOLORRAM+CCT3, >MAPCOLORRAM+CCT4, >MAPCOLORRAM+CCT5
        byte >MAPCOLORRAM+CCT6, >MAPCOLORRAM+CCT7, >MAPCOLORRAM+CCT8
        byte >MAPCOLORRAM+CCT9, >MAPCOLORRAM+CCTA, >MAPCOLORRAM+CCTB
        byte >MAPCOLORRAM+CCTC, >MAPCOLORRAM+CCTD

Operator HiLo

menuDisplayed   byte 0
menuTimer       byte 0
menuOption      byte 0
hangarOption    byte 0
hangarXArray    byte LogoXPos+24, LogoXPos+48, LogoXPos+72
                byte LogoXPos+96, LogoXPos+120
logoXArray      byte LogoXPos   , LogoXPos+24, LogoXPos+48, LogoXPos+72
                byte LogoXPos+96, LogoXPos+120, LogoXPos+144
logoXChar       byte 0
logoXOffset     byte 0
logoYOffset     byte 0
logoYChar       byte 0
medalArray      byte MedalEasy, MedalNormal, MedalHard, MedalExtreme
medalXArray     byte 100, 148, 196, 244
medalX          byte 0
medalColorArray byte Green, Cyan, LightRed, Yellow
medalUnlocked   byte 0
levelNum        byte LevelNormal
messageFlag     byte 0
menuColorArray  byte Red, LightRed, Orange, Yellow, LightGreen, Green, Cyan
                byte LightBlue, Purple, Brown, MediumGray, LightGray
menuColorClear  byte '            '
                byte 0
shipColorIndex  byte 6
shldColorIndex  byte 7
shipColorRow    byte 11
shipColorCol    byte MenuColorX
shieldColorRow  byte 14
shieldColorCol  byte MenuColorX
unlockFlags     byte 0
shipLockMask    byte %00000000, %00000001, %00000010, %00000100, %00001000
shipLockColors  byte Black, Green, Blue, Red, Purple
shipUnlocked    byte 0
medalLockMask   byte %00010000, %00100000, %01000000, %10000000
modelFrameIndex byte 0
modelNameOffset byte 0
sfxOn           byte $52, $53, $00
sfxOff          text $51, $20, $00
cursorX         byte 0
cursorY         byte 0
cursorColor     byte 0
cursorSize      byte 0
cursorChar      byte 0
enemiesY        byte 126, 126, 126, 126, 170, 170
enemiesXH       byte   0,   0,   0,   1,   0,   1
enemiesXL       byte  56, 137, 205,  28,  56,  33
enemiesFS       byte AlienBat, AlienPogo, AlienHard, AsteroidFrame, AlienSquid, AlienClamp
enemiesFE       byte AlienBat+1, AlienPogo+3, AlienHard+4, AsteroidFrame+3, AlienSquid+3, AlienClamp+2
enemiesCL       byte LightRed, LightBlue, AlienHardColor, AsteroidColor, Green, BomberColor
enemiesPC       byte LightRed, Purple, Red
enemiesIX       byte 0

;===============================================================================
; Macros/Subroutines

gameMenuShowLogo
        mva #Logo1stFrame, spriteFrame
        mva #LogoYPos, spriteY
        mva #True, spriteMulticolor
        mva #LightBlue, spriteColor
        ldx #0
        stx spriteId

gMSLLoop
        lda logoXArray,X
        sta spriteX

        jsr gameMenuLogoSetup

        ; loop for each frame
        inc spriteId
        inc spriteFrame
        inx
        cpx #7
        bcc gMSLLoop
        lda screenColumn
        cmp #MenuHonor
        beq gameMenuShowBoards
        cmp #MenuEnemies
        bne gMSLHide
        jmp gameMenuShowEnemies

gMSLHide
        lda #HideY
        sta spry,X
        inx
        cpx #MAXSPR
        bcc gMSLHide
        rts

;===============================================================================

gameMenuShowBoards
        ; Show HiScores Board
        ldx #0
        mva #21, ZeroPageParam1
        mva #10, ZeroPageParam2
        jsr gameMenuShowScore
        mva #21, ZeroPageParam1
        mva #11, ZeroPageParam2
        jsr gameMenuShowScore
        mva #21, ZeroPageParam1
        mva #12, ZeroPageParam2
        jsr gameMenuShowScore
        mva #21, ZeroPageParam1
        mva #13, ZeroPageParam2
        jsr gameMenuShowScore

        ; Show Medals Board
        mva #MedalYPos, spriteY
        mva #True, spriteMulticolor
        mva #8, spriteId
        ldx #0

gMSMLoop
        lda unlockFlags
        and medalLockMask,X
        bne gMSMUnlocked
        mva #MedalSpot, spriteFrame
        mva #DarkGray, spriteColor
        jmp gMSMSetSprite

gMSMUnlocked
        lda medalArray,X
        sta spriteFrame
        lda medalColorArray,X
        sta spriteColor

gMSMSetSprite
        lda medalXArray,X
        sta spriteX

        jsr gameMenuLogoSetup

        ; loop for each sprite
        inc spriteId
        inx
        cpx #4
        bcc gMSMLoop
        ldx spriteId

gMSMHide
        lda #HideY
        sta spry,X
        inx
        cpx #MAXSPR
        bcc gMSMHide
        rts

;===============================================================================

gameMenuShowEnemies
        mva #True, spriteMulticolor
        ldx #0

gMSALoop
        lda enemiesY,X
        sta spriteY
        lda enemiesXH,X
        sta ZeroPageTemp
        lda enemiesXL,X
        sta spriteX
        lda enemiesFS,X
        sta alienProbeStart
        lda enemiesFE,X
        sta alienProbeEnd
        lda enemiesCL,X
        sta spriteColor
        jsr gameMenuEnemySetup

        inc spriteId
        inx
        cpx #6
        bcc gMSALoop

        ; Destroyer (2 sprites)
        mva #BomberBack, spriteFrame
        mva #BomberColor, spriteColor
        mva #164, spriteX
        jsr gameMenuLogoSetup

        inc spriteId
        mva #BomberFront, spriteFrame
        LIBMATH_ADD8BIT_AVA spriteX, 24, spriteX
        jsr gameMenuLogoSetup

        ; Change probes and shooters
        inc enemiesIX
        ldx enemiesIX
        cpx #3
        bcc gMSANext
        ldx #0
        stx enemiesIX

gMSANext
        lda enemiesPC,X
        sta enemiesCL
        rts

;===============================================================================

gameMenuShowScore
        mva #0, ZeroPageTemp
gMSCLoop
        lda HISCORES,X
        sta ZeroPageTemp2
        LIBSCREEN_DRAWDECIMAL_AAA ZeroPageParam1, ZeroPageParam2, ZeroPageTemp2
        inc ZeroPageParam1
        inc ZeroPageParam1
        inx
        inc ZeroPageTemp
        lda ZeroPageTemp
        cmp #3
        bcc gMSCLoop
        rts

;===============================================================================

gameMenuCursorDisplay
        mva #23, cursorY
        lda menuOption
        cmp #StartGame
        beq gMCDFocusSG
        ; Focus Open Hangar
        mva #LightBlue, cursorColor
        mva #MenuStartX, cursorX
        mva #MenuStartLen, cursorSize
        mva #SpaceCharacter, cursorChar
        jsr gameMenuCursorPaint
        mva #White, cursorColor
        mva #MenuHangarX, cursorX
        mva #MenuHangarLen, cursorSize
        mva #MenuCursor, cursorChar
        jmp gameMenuCursorPaint

gMCDFocusSG
        ; Focus Start Game
        mva #White, cursorColor
        mva #MenuStartX, cursorX
        mva #MenuStartLen, cursorSize
        mva #MenuCursor, cursorChar
        jsr gameMenuCursorPaint
        mva #LightBlue, cursorColor
        mva #MenuHangarX, cursorX
        mva #MenuHangarLen, cursorSize
        mva #SpaceCharacter, cursorChar
        jmp gameMenuCursorPaint

;===============================================================================

gameMenuCursorPaint
        LIBSCREEN_SETCHARPOSITION_AA cursorX, cursorY
        LIBSCREEN_SETCHAR_A cursorChar
        inc cursorX
        LIBSCREEN_COLORTEXT_AAAA cursorX, cursorY, cursorColor, cursorSize
        rts

;===============================================================================

gameMenuShowHangar
        jsr libMultiplexReset
        LIBSCREEN_COPYTEXTROW_VAA 23, hangarOptsChr, hangarOptsClr
        mva #HangarFrame, spriteFrame
        mva #HangarYPos, spriteY
        mva #True, spriteMulticolor
        ldx #0
        stx spriteId

gMSHLoop
        inc spriteId ; x+1
        mva #LightBlue, spriteColor
        lda hangarXArray,X
        sta spriteX
        jsr gameMenuLogoSetup
        ; loop for each frame
        inc spriteFrame
        inx
        cpx #5
        bcc gMSHLoop
        inc spriteId
        mva spriteId, playerSprite
        mva #ModelYPos-1, shieldY
        rts

;===============================================================================

gameMenuLogoSetup
        LIBMPLEX_STOPANIM_A          spriteId
        LIBMPLEX_SETFRAME_AA         spriteId, spriteFrame
        mva #0, ZeroPageTemp
        jmp gameMenuSpriteSetup

;===============================================================================

gameMenuEnemySetup
        LIBMPLEX_PLAYANIM_AAAVVV spriteId, alienProbeStart, alienProbeEnd, 9, 1, True
        ; next routine must be gameMenuSpriteSetup, don't move

;===============================================================================

gameMenuSpriteSetup
        LIBMPLEX_SETPRIORITY_AV      spriteId, False
        LIBMPLEX_MULTICOLORENABLE_AA spriteId, spriteMulticolor
        LIBMPLEX_SETCOLOR_AA         spriteId, spriteColor
        LIBMPLEX_SETPOSITION_AAAA    spriteId, ZeroPageTemp, spriteX, spriteY
        rts
;===============================================================================

gameMenuShowText
        jsr gameStarsScreen
        jsr gameFlowInit
        mva #True, menuDisplayed
        ; set screen offset
        LIBSCREEN_SETOFFSET_A screenColumn
        ; screen text
repeat 0, 13, idx
        LIBSCREEN_COPYMAPROW_VV idx, idx+8
endrepeat
        ; screen colors
repeat 0, 13, idx
        LIBSCREEN_COPYMAPROWCOLOR_VV idx, idx+8
endrepeat
        rts

;===============================================================================

gameMenuShowBorder
        LIBSCREEN_COPYTEXTROW_VAA 23, menuOptsChr, menuOptsClr
        rts

;===============================================================================

gameMenuLevelChange
        lda levelNum
        cmp #LevelExtreme
        beq gMLCEasy
        inc levelNum
        jmp gameMenuLevelDisplay

gMLCEasy
        mva #LevelEasy, levelNum
        ; gameMenuLevelDisplay must be the next routine (don't move)

;===============================================================================

gameMenuLevelDisplay
        ldx levelNum
        jsr gameDataGetHiScore
        cpx #LevelExtreme
        beq gameMenuLevelShowExtreme
        cpx #LevelHard
        beq gameMenuLevelShowHard
        cpx #LevelNormal
        beq gMLDNormal
        jmp gameMenuLevelShowEasy

gMLDNormal
        jmp gameMenuLevelShowNormal

;===============================================================================

gameMenuLevelShowExtreme
        LIBSCREEN_DRAWTEXT_AAAV #LevelX, #LevelY, levelXtremeText, Purple
        jmp gameFlowHiScoreDisplay

gameMenuLevelShowHard
        LIBSCREEN_DRAWTEXT_AAAV #LevelX, #LevelY, levelHardText, LightRed
        jmp gameFlowHiScoreDisplay

gameMenuLevelShowNormal
        LIBSCREEN_DRAWTEXT_AAAV #LevelX, #LevelY, levelNormalText, LightBlue
        jmp gameFlowHiScoreDisplay

gameMenuLevelShowEasy
        LIBSCREEN_DRAWTEXT_AAAV #LevelX, #LevelY, levelEasyText, Green
        jmp gameFlowHiScoreDisplay

;===============================================================================

gameMenuShipColorNext
        inc shipColorIndex
        lda shipColorIndex
        cmp #MaxColors
        bcc gMSCNDone
        lda #0
        sta shipColorIndex

gMSCNDone
        rts

;===============================================================================

gameMenuColorDisplay
        mva shipColorIndex, shipColorCol
        LIBMATH_ADD8BIT_AVA shipColorCol,MenuColorX,shipColorCol
        LIBSCREEN_DRAWTEXT_AAA #MenuColorX, shipColorRow, menuColorClear
        LIBSCREEN_SETCHARPOSITION_AA shipColorCol, shipColorRow
        LIBSCREEN_SETCHAR_V ColorCursor

        mva shldColorIndex, shieldColorCol
        LIBMATH_ADD8BIT_AVA shieldColorCol,MenuColorX,shieldColorCol
        LIBSCREEN_DRAWTEXT_AAA #MenuColorX, shieldColorRow, menuColorClear
        LIBSCREEN_SETCHARPOSITION_AA shieldColorCol, shieldColorRow
        LIBSCREEN_SETCHAR_V ColorCursor
        rts
;===============================================================================

gameMenuShieldColorNext
        inc shldColorIndex
        lda shldColorIndex
        cmp #MaxColors
        bcc gMSHNDone
        mva #0, shldColorIndex

gMSHNDone
        rts

;===============================================================================

gameMenuModelNext
        inc modelFrameIndex
        lda modelFrameIndex
        cmp #PlayerMaxModels
        bcc gMMNDone
        mva #0, modelFrameIndex

gMMNDone
        rts

;===============================================================================

gameMenuModelReset
        LIBMPLEX_STOPANIM_A playerSprite
        LIBMPLEX_SETPOSITION_AAAA playerSprite, #0, #ModelXPos, #ModelYPos
        LIBMPLEX_SETVERTICALTPOS_AA #ShieldSprite, #HideY
        LIBMPLEX_MULTICOLORENABLE_AV spriteId, True
        ; expand ship and shield sprites
        lda #%01100000
        sta XXPAND
        sta YXPAND
        jmp gamePlayerSetupShield

;===============================================================================

gameMenuModelDisplay
        ldx modelFrameIndex
        beq gMMDUnlocked
        lda unlockFlags
        and shipLockMask,X
        bne gMMDUnlocked
        jmp gameMenuLockedDisplay

gMMDUnlocked
        stx playerFrameIndex
        lda playerFrameArray,X
        sta playerFrame

        ldx shipColorIndex
        lda menuColorArray,X
        sta playerColor

        LIBMPLEX_SETFRAME_AA playerSprite, playerFrame
        LIBMPLEX_SETCOLOR_AA playerSprite, playerColor
        ; Multiply index by 20 to have the offset (each name has 20 bytes)
        lda playerFrameIndex
        jsr libMathMultiplyByTen       ; * 10
        asl                            ; * 2
        sta modelNameOffset
        LIBSCREEN_DRAWTEXT_AAA     #ModelTitleX, #ModelTitleY, modelTitle
        LIBSCREEN_DRAWTEXTOFF_AAAA #ModelNameX, #ModelNameY, modelNamesLn1, modelNameOffset
        LIBSCREEN_DRAWTEXTOFF_AAAA #ModelNameX, #ModelNameY+1, modelNamesLn2, modelNameOffset
        rts

;===============================================================================

gameMenuLockedDisplay
        lda shipLockColors,X
        sta playerColor
        LIBMPLEX_SETFRAME_AA playerSprite, #LockedFrame
        LIBMPLEX_SETCOLOR_AA playerSprite, playerColor
        ; Multiply index by 20 to have the offset (each name has 20 bytes)
        lda modelFrameIndex
        jsr libMathMultiplyByTen       ; * 10
        asl                            ; * 2
        sta modelNameOffset
        LIBSCREEN_DRAWTEXT_AAA     #ModelTitleX, #ModelTitleY, lockedTitle
        LIBSCREEN_DRAWTEXTOFF_AAAA #ModelNameX, #ModelNameY, lockedNamesLn1, modelNameOffset
        LIBSCREEN_DRAWTEXTOFF_AAAA #ModelNameX, #ModelNameY+1, lockedNamesLn2, modelNameOffset
        rts

;===============================================================================

gameMenuShieldDisplay
        ldx shldColorIndex
        lda menuColorArray,X
        sta shieldColor
        LIBMPLEX_SETCOLOR_AA #ShieldSprite, shieldColor
        LIBMPLEX_SETPOSITION_AAAA #ShieldSprite, #0, #ModelXPos, shieldY
        mva #True, shieldActive
        rts

;===============================================================================

gameMenuShieldHide
        LIBMPLEX_SETVERTICALTPOS_AA #ShieldSprite, #HideY
        mva #False, shieldActive
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
        ; gameMenuSfxDisplay must be the next routine (don't move)

;===============================================================================

gameMenuSfxDisplay
        lda soundDisabled
        bne gMSDDisabled
        LIBSCREEN_DRAWTEXT_AAAV #SfxX, #SfxY, sfxOn, LightGreen
        rts

gMSDDisabled
        LIBSCREEN_DRAWTEXT_AAAV #SfxX, #SfxY, sfxOff, LightRed
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
        ; gameMenuMusicDisplay must be the next routine (don't move)

;===============================================================================

gameMenuMusicDisplay
        lda sidDisabled
        bne gMMDDisabled
        LIBSCREEN_DRAWTEXT_AAAV #MusicX, #MusicY, sfxOn, LightGreen
        rts

gMMDDisabled
        LIBSCREEN_DRAWTEXT_AAAV #MusicX, #MusicY, sfxOff, LightRed
        rts

;===============================================================================
gameMenuSavingDisplay
        LIBSCREEN_DRAWTEXT_AAAV #MsgHangarX, #MsgHangarY, menuSaving, Yellow
        rts

;===============================================================================

gameMenuSavedDisplay
        lda dataErrorFlag
        bne gMSVError
        LIBSCREEN_DRAWTEXT_AAAV #MsgHangarX, #MsgHangarY, menuSaveOK, LightGreen
        jmp gMSVDone

gMSVError
        LIBSCREEN_DRAWTEXT_AAAV #MsgHangarX, #MsgHangarY, menuSaveError, LightRed

gMSVDone
        lda #True
        sta messageFlag
        rts

;===============================================================================

gameMenuRestore
        GAMESTARS_COPYMAPROW_V 23
        LIBSCREEN_COPYTEXTROW_VAA 23, hangarOptsChr, hangarOptsClr
        lda #False
        sta messageFlag
        sta flowJoystick
        ldy hangarOption
        jmp gameFlowHangarMenu

;===============================================================================

gameMenuClearText
        mva #False, menuDisplayed

        jsr gameMenuClearScreen

        LIBSCREEN_DRAWTEXT_AAAV #ScoreX, #ScoreY, flowScoreText, White
        jsr gameFlowScoreDisplay

        LIBSCREEN_DRAWTEXT_AAAV #HiScoreX, #ScoreY, flowHiScoreText, White
        jmp gameFlowHiScoreDisplay

;===============================================================================
gameMenuClearScreen
        ; Fill 1000 bytes (40x25) of screen memory
        LIBSCREEN_SET1000 SCREENRAM, SpaceCharacter
        rts
;===============================================================================

gameMenuShowStats
        LIBSCREEN_DRAWDECIMAL_AAA #StatsScoreX, #StatsScoreY, score3
        LIBSCREEN_DRAWDECIMAL_AAA #StatsScoreX+2, #StatsScoreY, score2
        LIBSCREEN_DRAWDECIMAL_AAA #StatsScoreX+4, #StatsScoreY, score1

        LIBSCREEN_DRAWDECIMAL_AAA #StatsX, #StatsBulletY, bullets2
        LIBSCREEN_DRAWDECIMAL_AAA #StatsX+2, #StatsBulletY, bullets1

        LIBSCREEN_DRAWDECIMAL_AAA #StatsX, #StatsBombY, bombs2
        LIBSCREEN_DRAWDECIMAL_AAA #StatsX+2, #StatsBombY, bombs1

        LIBSCREEN_DRAWDECIMAL_AAA #StatsX, #StatsAliensY, aliens2
        LIBSCREEN_DRAWDECIMAL_AAA #StatsX+2, #StatsAliensY, aliens1

        lda medalUnlocked
        bne gMSTMedalUnlocked
        lda shipUnlocked
        bne gMSTShipUnlocked
        lda statsHiScore
        bne gMSTHigh
        lda aliens2
        bne gMSTDone
        lda aliens1
        cmp #$60        ;Value in HEX but the counter is handled as DEC
        bcc gMSTBad

gMSTDone
        rts

gMSTMedalUnlocked
        jmp gameMenuShowNewMedal

gMSTShipUnlocked
        jmp gameMenuShowNewShip

gMSTHigh
        LIBSCREEN_DRAWTEXT_AAAV #MsgPosX, #MsgPosY, statsMsgHigh, LightGreen
        ;Switch to MenuHonor to show the board
        mva #2, flowMenuIndex
        rts

gMSTBad
        LIBSCREEN_DRAWTEXT_AAAV #MsgPosX, #MsgPosY, statsMsgBad, Yellow
        rts

;===============================================================================

gameMenuShowNewMedal
        LIBSCREEN_DRAWTEXT_AAAV #MsgPosX, #MsgPosY, statsMsgMedal, LightGreen
        ldx levelNum
        lda medalArray,X
        sta spriteFrame
        lda medalColorArray,X
        sta spriteColor
        mva #UnlockedSprX, spriteX
        mva #UnlockedSprY, spriteY
        mva #UnlockedSpr, spriteId
        mva #True, spriteMulticolor
        ;Switch to MenuHonor to show the board
        mva #2, flowMenuIndex
        jmp gameMenuLogoSetup

;===============================================================================

gameMenuShowNewShip
        LIBSCREEN_DRAWTEXT_AAAV #MsgPosX, #MsgPosY, statsMsgShip, LightGreen
        ldx levelNum
        inx
        lda playerFrameArray,X
        sta spriteFrame
        mva playerColor, spriteColor
        mva #UnlockedSprX, spriteX
        mva #UnlockedSprY, spriteY
        mva #0, spriteId
        mva #True, spriteMulticolor
        jmp gameMenuLogoSetup
