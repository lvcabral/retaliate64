;===============================================================================
;  gameFlow.asm - Game Flow Control
;
;  Copyright (C) 2017-2021 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
; Constants

FlowStateMenu   = 0
FlowStateAlive  = 1
FlowStateDying  = 2
FlowStateHangar = 3

FlowMenuPages   = 5
FramesMax       = 10

JoyStickDelay   = 10

GaugeX          = 1
GaugeBarX       = 5
StatusY         = 24

StartGame       = 0
OpenHangar      = 1

GameOverDelay   = $20

CyclesPAL       = $50   ; Cycle constants used in Decimal Mode
CyclesNTSC      = $60

HangarMenuStart = #5
HangarMenuExit  = #7
HangarMenuShip  = #8

;===============================================================================
; Page Zero

timer1          = $0A
timer2          = $0B
cycles          = $0C
frame           = $0D
speedTableLow   = $0E
speedTableHigh  = $0F

;===============================================================================
; Variables

score3          byte 0
score2          byte 0
score1          byte 0

hiscore3        byte 0
hiscore2        byte 0
hiscore1        byte 0
statsHiScore    byte 0

flowGaugeChrX   byte 0
energy          byte 0
lastEnergy      byte 0
flowGaugeCnt    byte 0
flowGaugeClr    byte 0

bullets         byte 0
bullets1        byte 0
bullets2        byte 0

bombs           byte 0
bombs1          byte 0
bombs2          byte 0

aliens1         byte 0
aliens2         byte 0

flowJoystick    byte 0

flowGaugeFull   text '100%'
                byte 0
flowGaugeTxt    byte $31, $00
flowGaugePct    byte $25, $00
flowGaugeSpc    byte SpaceCharacter, $00
flowGaugeChr    byte BarCharacter, $00
flowGaugeBar    dcb 15, BarCharacter
                byte 0
flowPaused      byte 0
flowState       byte FlowStateMenu
flowLevel       byte LevelNormal
flowMenuArray   byte MenuStory, MenuEnemies, MenuInfo, MenuHonor, MenuCredits
flowMenuTimes   byte $20, $15, $15, $15, $15
flowMenuIndex   byte 0
flowStageCnt    byte 0
flowStageIndex  byte 0

;===============================================================================
; Jump Tables

gameFlowJumpTableLow
        byte <gameFlowUpdateMenu
        byte <gameFlowUpdateAlive
        byte <gameFlowUpdateDying
        byte <gameFlowUpdateHangar

gameFlowJumpTableHigh
        byte >gameFlowUpdateMenu
        byte >gameFlowUpdateAlive
        byte >gameFlowUpdateDying
        byte >gameFlowUpdateHangar

;===============================================================================
; Macros/Subroutines

gameFlowInit
        LIBSCREEN_DRAWTEXT_AAAV #ScoreX, #ScoreY, flowScoreText, White
        jsr gameFlowScoreDisplay

        LIBSCREEN_DRAWTEXT_AAAV #HiScoreX, #ScoreY, flowHiScoreText, White
        jmp gameFlowHiScoreDisplay

;===============================================================================

gameFlowUpdate
        ; get the current state
        ldy flowState

        ; write the subroutine address to a zeropage location
        lda gameFlowJumpTableLow,Y
        sta ZeroPageLow
        lda gameFlowJumpTableHigh,Y
        sta ZeroPageHigh

        ; jump to the subroutine the zeropage location points to
        jmp (ZeroPageLow)

;===============================================================================

gameFlowUpdateMenu
        lda menuDisplayed
        bne gFUMCheckFire
        ldy #0
        jmp gFUMShowMenu

gFUMCheckFire
        LIBINPUT_GETFIREPRESSED
        beq gFUMSelect
        lda flowJoystick
        bne gFUMDecJoystick
        lda #JoyStickDelay
        sta flowJoystick

gFUMJoyLeft
        LIBINPUT_GETHELD GameportLeftMask
        bne gFUMJoyRight
        lda menuOption
        beq gFUMDecScreenTimer
        dec menuOption
        jsr gameMenuCursorDisplay
        jmp gFUMDecScreenTimer

gFUMJoyRight
        LIBINPUT_GETHELD GameportRightMask
        bne gFUMJoyUp
        lda menuOption
        bne gFUMDecScreenTimer
        inc menuOption
        jsr gameMenuCursorDisplay
        jmp gFUMDecScreenTimer

gFUMJoyUp
        LIBINPUT_GETHELD GameportUpMask
        bne gFUMDecScreenTimer
        jmp gFUMNextMenu

gFUMSelect
        lda menuOption
        cmp #StartGame
        bne gFUMShowHangar
        jmp gameFlowStartGame

gFUMShowHangar
        mva #MenuHangar, screenColumn
        mva #FlowStateHangar, flowState
        jsr gameMenuShowText
        jsr gameMenuShowHangar
        ; Reset menu cursor
        ldy #0
        sty hangarOption
        mva #White, cursorColor
        mva #MenuCursor, cursorChar
        jsr gameFlowHangarCursor
        jsr gameMenuLevelDisplay
        jsr gameMenuMusicDisplay
        jsr gameMenuSfxDisplay
        jsr gameMenuModelReset
        jmp gFHModelDisplay

gFUMDecJoystick
        dec flowJoystick

gFUMDecScreenTimer
        jsr gameFlowDecreaseTime
        beq gFUMNextMenu
        rts

gFUMNextMenu
        ldy flowMenuIndex
        iny
        cpy #FlowMenuPages
        bcc gFUMShowMenu
        ldy #0

gFUMShowMenu
        sty flowMenuIndex
        lda flowMenuArray,Y
        sta screenColumn
        jsr gameFlowResetScreenTime
        jsr gameMenuShowText
        jsr gameMenuShowBorder
        jsr gameMenuShowLogo
        jmp gameMenuCursorDisplay

;===============================================================================

gameFlowUpdateHangar
        LIBINPUT_GETFIREPRESSED
        bne gFUHCheckMessage
        jmp gFUHSelect

gFUHCheckMessage
        lda messageFlag
        beq gFUHCheckJoystick
        jsr gameFlowDecreaseTime
        bne gFHReturn
        jmp gameMenuRestore

gFUHCheckJoystick
        lda flowJoystick
        beq gFHResetJoystick
        jmp gFHEnd

gFHResetJoystick
        mva #JoyStickDelay, flowJoystick
        jmp gFHJoyLeft

gFHJoyLeft
        LIBINPUT_GETHELD GameportLeftMask
        bne gFHJoyRight
        ldy hangarOption
        cpy #HangarMenuStart+1
        bcc gFHJoyRight
        cpy #HangarMenuShip
        bcc gFHCPrev
        mva #0, hangarOption
        jmp gameFlowHangarMenu

gFHJoyRight
        LIBINPUT_GETHELD GameportRightMask
        bne gFHJoyUp
        ldy hangarOption
        cpy #HangarMenuExit
        bcs gFHJoyUp
        cpy #HangarMenuStart
        bcs gFHCNext
        mva #HangarMenuShip, hangarOption
        jmp gameFlowHangarMenu

gFHJoyUp
        LIBINPUT_GETHELD GameportUpMask
        bne gFHJoyDown
        ldy hangarOption
        beq gFHJoyDown
        cpy #HangarMenuStart+1
        bcc gFHCPrev
        cpy #HangarMenuExit
        beq gFHCNext

gFHJoyDown
        LIBINPUT_GETHELD GameportDownMask
        bne gFHReturn
        ldy hangarOption
        cpy #HangarMenuStart
        bcc gFHCNext
        cpy #HangarMenuShip
        beq gFHCPrev

gFHReturn
        jmp gFHEnd

gFHCPrev
        dec hangarOption
        jmp gameFlowHangarMenu

gFHCNext
        inc hangarOption
        jmp gameFlowHangarMenu

gFUHSelect
        lda hangarOption
        beq gFHShipColor
        cmp #1
        beq gFHShieldColor
        cmp #2
        beq gFHMusicSwitch
        cmp #3
        beq gFHSfxSwitch
        cmp #4
        beq gFHLevel
        cmp #6
        beq gFHSaveData
        cmp #HangarMenuExit
        beq gFHExitHangar
        cmp #HangarMenuShip
        beq gFHNextModel
        cmp #HangarMenuStart
        bne gFHEnd
        jmp gameFlowStartGame

gFHShipColor
        jsr gameMenuShipColorNext
        jmp gFHModelDisplay

gFHShieldColor
        jsr gameMenuShieldColorNext
        jsr gameMenuShieldDisplay
        jmp gameMenuColorDisplay

gFHMusicSwitch
        jmp gameMenuMusicSwitch

gFHSfxSwitch
        jmp gameMenuSfxSwitch

gFHLevel
        jmp gameMenuLevelChange

gFHSaveData
        jsr gameMenuSavingDisplay
        jsr gameDataSave
        jsr gameMenuSavedDisplay
        jmp gameFlowResetMsgTime

gFHExitHangar
        ; change state
        jsr libMultiplexReset
        mva #FlowStateMenu, flowState
        ldy #0
        sty messageFlag
        jmp gFUMShowMenu

gFHNextModel
        jsr gameMenuModelNext

gFHModelDisplay
        jsr gameMenuColorDisplay
        jmp gameMenuModelDisplay

gFHEnd
        dec flowJoystick
        rts

;===============================================================================

gameFlowHangarMenu
        mva #LightBlue, cursorColor
        mva #SpaceCharacter, cursorChar
        jsr gameFlowHangarCursor
        mva #White, cursorColor
        mva #MenuCursor, cursorChar
        ldy hangarOption
        jsr gameFlowHangarCursor
        lda hangarOption
        cmp #1
        bne gFHMHideShield
        jmp gameMenuShieldDisplay

gFHMHideShield
        jmp gameMenuShieldHide

;===============================================================================

gameFlowHangarCursor
        lda hangarXArray,Y
        sta cursorX
        lda hangarYArray,Y
        sta cursorY
        lda hangarSizeArray,Y
        sta cursorSize
        jmp gameMenuCursorPaint

;===============================================================================

gameFlowStartGame
        ; set screen
        jsr libMultiplexReset
        jsr gameMenuClearText
        jsr gameStarsScreen
        jsr gameFlowInit
        jsr gameFlowShowGameStatus
        lda rndSeed
        beq gFSGSeed
        ; Get next Bomb Type
        inc bombTypeRndIndex
        lda bombTypeRndIndex
        jmp gFSGCheckBombArray

gFSGSeed
        ; Generate Random Seed
        sei
        lda TIME2
        cli
        cmp #0
        beq gFSGSeed
        clc
        adc timer1
        sta rndSeed
        ; Use seed to set first bomb type
        tax
        lda wavesRndTable,X
        sta bombTypeRndIndex

gFSGCheckBombArray
        cmp #BombRndArrayMax
        bcc gFSGSetupGame
        mva #0, bombTypeRndIndex

gFSGSetupGame
if SHOWRNDSEED = 1
        LIBSCREEN_DRAWHEX_AAAV #00, #0, rndSeed, DarkGray
endif
        ; load player ship configuration
        jsr gamePlayerLoadConfig
        ; set skill level
        ldx levelNum
        lda stagesOffsetArray,X
        sta flowStageIndex
        jsr gameFlowSkillLevel
        ; load player ship configuration
        jsr gamePlayerLoadConfig
        mva #OneCharacter, stageNumChar
        ; reset game
        lda #MenuGameOver
        sta screenColumn
        sta flowMenuIndex
        lda #0
        sta flowPaused
        sta menuOption
        sta flowStageCnt
        jsr gameFlowAlienSprites
        jsr gameFlowResetScore
        jsr gameFlowResetAmmo
        jsr gameBomberInit
        jsr gameAliensReset
        jsr gamePlayerReset
        ; change state
        mva #FlowStateAlive, flowState
        ; set SID state
        jmp libMusicInit

;===============================================================================

gameFlowSkillLevel
        ldy flowStageIndex
        ldx stagesLevelArray,Y
        stx flowLevel
        lda bulletSpeedArray,X
        sta bulletSpeed
        lda wavesLevelTable,X
        sta wavesLevelIndex
        mva #0, aliensCountWaves
        lda vicMode
        bne gFSLPal
        lda ntscSpeedTableLow,X
        sta speedTableLow
        lda ntscSpeedTableHigh,X
        sta speedTableHigh
        rts

gFSLPal
        lda palSpeedTableLow,X
        sta speedTableLow
        lda palSpeedTableHigh,X
        sta speedTableHigh
        rts

;===============================================================================

gameFlowAlienSprites
        ldx flowStageCnt
        lda stagesShooterStart,X
        sta alienShooterStart
        lda stagesShooterEnd,X
        sta alienShooterEnd
        lda stagesShooterColor,X
        sta alienShooterColor
        lda stagesProbeStart,X
        sta alienProbeStart
        lda stagesProbeEnd,X
        sta alienProbeEnd
        lda stagesProbeColor,X
        sta alienProbeColor
        lda stagesOrbColor,X
        sta alienOrbColor

        rts

;===============================================================================

gameFlowShowGameStatus
        jsr gameflowShieldGaugeFull
        LIBSCREEN_DRAWTEXT_AAAV #AmmoX, #StatusY, flowAmmoText, White
        jsr gameflowBulletDisplay
        jmp gameflowBombDisplay

;===============================================================================

gameFlowUpdateAlive
        lda flowPaused
        bne gFUAScanKey
        ldy frame
        lda (speedTableLow),Y
        sta aliensStep
        iny
        cpy #FramesMax
        beq gFPReset
        jmp gFPDone

gFPReset
        ldy #0

gFPDone
        sty frame

gFUAScanKey
        jsr libInputKeys
        bne gFUACheckKey
        rts

gFUACheckKey
        cmp #KEY_SPACE
        beq gFUAPause
        cmp #KEY_M
        beq gameFlowMuteSwitch
        rts

gFUAPause
        lda flowPaused
        bne gFUAPlay
        LIBSCREEN_DRAWTEXT_AAAV #PauseTextX, #PauseTextY, gamePauseText, Yellow
        inc flowPaused
        jmp libSoundInit

gFUAPlay
        GAMESTARS_COPYMAPROW_V PauseTextY
        dec flowPaused
        jmp libSoundInit

;===============================================================================

gameFlowMuteSwitch
        lda sidDisabled
        beq gFMSDisable
        mva #False, sidDisabled
        rts

gFMSDisable
        mva #True, sidDisabled
        jmp libSoundInit

;===============================================================================

gameFlowUpdateDying
        lda playerFlyUp
        beq gFUDExploding
        mva #GameOverDelay, timer1
        mva #1, timer2
        mva #0, playerFlyUp
        rts

gFUDExploding
        LIBMPLEX_ISANIMPLAYING_A #ExplodeSprite
        beq gFUDDelay
        mva #GameOverDelay, timer1
        mva #1, timer2
        rts

gFUDDelay
        lda timer2
        cmp #1
        bne gFUDDecrease
        jsr libMultiplexReset
        jsr gameMenuClearScreen

gFUDDecrease
        jsr gameFlowDecreaseTime
        beq gFUDMenu
        rts

gFUDMenu
        jsr gameMenuClearText
        jsr gameFlowResetGameOverTime
        ; change state
        lda #FlowStateMenu
        sta flowState
        jsr gameMenuShowLogo
        jsr gameMenuShowText
        jsr gameMenuShowStats
        jsr gameMenuShowBorder
        jmp gameMenuCursorDisplay

;===============================================================================

gameFlowIncreaseScore
        sed             ;set decimal mode
        clc
        lda aliensScore ;points scored
        adc score1      ;ones and tens
        sta score1
        lda score2      ;hundreds and thousands
        adc #$00
        sta score2
        lda score3      ;ten-thousands and hundred-thousands
        adc #$00
        sta score3
        clc
        lda #$01        ;alien destroyed
        adc aliens1     ;ones and tens
        sta aliens1
        lda aliens2     ;hundreds and thousands
        adc #$00
        sta aliens2
        cld             ;clear decimal mode
        jmp gameFlowScoreDisplay

;===============================================================================

gameFlowResetScore
        lda #0
        sta score1
        sta score2
        sta score3
        sta statsHiScore
        sta medalUnlocked
        sta shipUnlocked
        jmp gameFlowScoreDisplay

;===============================================================================

gameFlowResetScreenTime
        mva cycles, timer1
        lda flowMenuTimes,Y
        sta timer2
        rts

;===============================================================================

gameFlowResetGameOverTime
        mva cycles, timer1
        mva #GameOverTime, timer2
        rts

;===============================================================================

gameFlowResetMsgTime
        mva cycles, timer1
        mva #MessageTime, timer2
        rts

;===============================================================================

gameFlowDecreaseTime
        lda timer2
        beq gFDTDone
        sed             ; set decimal mode
        sec             ; sec is the same as clear borrow
        lda timer1       ; Get first number
        sbc #$01        ; Subtract 1
        sta timer1       ; Store in first number
        lda timer2       ; Get 2nd first number
        sbc #$00        ; Subtract borrow
        sta timer2       ; Store 2nd number
        lda timer1
        cmp #$99
        bne gFDTContinue
        lda cycles      ; 60 NTSC / 50 PAL
        sta timer1
gFDTContinue
if SHOWTIMER = 1
        ; Debug routine to display timer
        LIBSCREEN_DRAWDECIMAL_AAAV #HiScoreX+3, #ScoreY, #$00, White
        LIBSCREEN_DRAWDECIMAL_AAAV #HiScoreX+5, #ScoreY, timer2, White
        LIBSCREEN_DRAWDECIMAL_AAAV #HiScoreX+7, #ScoreY, timer1, White
        lda timer2
endif
        cld             ; clear decimal mode

gFDTDone
        rts

;===============================================================================

gameFlowAddBullet
        ; Check if Ammo reached 99 (maximum)
        lda bullets
        cmp #$99
        beq gFABDone
        sed             ;set decimal mode
        clc
        lda #$01        ;1 bullet added
        adc bullets
        sta bullets
        clc
        lda #$01        ;add to statistics
        adc bullets1    ;ones and tens
        sta bullets1
        lda bullets2    ;hundreds and thousands
        adc #$00
        sta bullets2
        cld             ;clear decimal mode
        lda fullMode
        bne gFABDone
        jmp gameflowBulletDisplay

gFABDone
        rts

;===============================================================================

gameFlowUseBullet
        sed             ;set decimal mode
        sec
        lda bullets
        sbc #$01        ;1 bullet used
        sta bullets
        cld             ;clear decimal mode
        jmp gameflowBulletDisplay

;===============================================================================

gameFlowAddBomb
        ; Check if Ammo reached 99 (maximum)
        lda bombs
        cmp #$99
        beq gFBBDone
        sed             ;set decimal mode
        clc
        lda #$01        ;1 bullet added
        adc bombs
        sta bombs
        clc
        lda #$01        ;add to statistics
        adc bombs1      ;ones and tens
        sta bombs1
        lda bombs2      ;hundreds and thousands
        adc #$00
        sta bombs2
        cld             ;clear decimal mode
        jmp gameflowBombDisplay

gFBBDone
        rts

;===============================================================================

gameFlowUseBomb
        sed             ;set decimal mode
        sec
        lda bombs
        sbc #$01        ;1 bomb used
        sta bombs
        cld             ;clear decimal mode
        jmp gameflowBombDisplay

;===============================================================================

gameFlowUpdateGauge
        sed             ;set decimal mode
        clc
        lda #$00
        adc shieldEnergy
        sta energy
        cld             ;clear decimal mode
        lda shieldEnergy
        cmp lastEnergy
        beq gFUGDone
        bcs gFUGHigher
        sta lastEnergy
        jsr gameflowShieldGaugeDecrease
        rts

gFUGHigher
        sta lastEnergy
        beq gFUGDone
        jmp gameflowShieldGaugeIncrease

gFUGDone
        rts

;===============================================================================

gameFlowResetAmmo
        lda #$00
        sta bullets
        sta bullets1
        sta bullets2
        sta bombs
        sta bombs1
        sta bombs2
        sta aliens1
        sta aliens2
        jsr gameflowBulletDisplay
        jsr gameflowBombDisplay
        jsr gameBulletsReset
        jmp gameBomberReset

;===============================================================================

gameFlowGameOver
        jsr gameBulletsReset ; stops in flight bullets from scoring
        jsr gameBombsReset
        jsr gameFlowUpdateHiScore
        jsr gameFlowUnlockShips
        jsr gameflowBulletDisplay
        jsr gameflowBombDisplay
        ; change state
        lda #FlowStateDying
        sta flowState
        rts

;===============================================================================

gameFlowUpdateHiScore
        ; Do not update if same score
        lda score1
        cmp hiscore1
        bne gFUCheckHi
        lda score2
        cmp hiscore2
        bne gFUCheckHi
        lda score3
        cmp hiscore3
        beq gFUHNotHi

gFUCheckHi
        ; http://6502.org/tutorials/decimal_mode.html#4.2
        ; a common technique for comparing multi-byte numbers
        lda score1
        cmp hiscore1
        lda score2
        sbc hiscore2
        lda score3
        sbc hiscore3
        bcc gFUHNotHi
        mva score1, hiscore1
        mva score2, hiscore2
        mva score3, hiscore3
        ldx levelNum
        ldy hiScoresOffset,X
        lda score3
        sta HISCORES,Y
        iny
        lda score2
        sta HISCORES,Y
        iny
        lda score1
        sta HISCORES,Y
        iny
        lda stageNumChar
        sta HISCORES,Y
        mva #True, statsHiScore
        jmp gameFlowHiScoreDisplay

gFUHNotHi
        rts

;===============================================================================

gameFlowUnlockShips
        lda score3
        bne gFUSUnlock
        lda score2
        cmp #10
        bcs gFUSUnlock
        rts

gFUSUnlock
        ldx levelNum
        inx                     ; align with ship lock mask array
        lda unlockFlags
        and shipLockMask,X
        bne gFUSDone            ; ship already unlocked
        inc shipUnlocked        ; set flag to display message
        lda unlockFlags
        ora shipLockMask,X
        sta unlockFlags

gFUSDone
        rts

;===============================================================================

gameFlowScoreDisplay
        LIBSCREEN_DRAWDECIMAL_AAAVV #ScoreValX, #ScoreY, score3, White, 3
        rts

;===============================================================================

gameFlowHiScoreDisplay
        LIBSCREEN_DRAWDECIMAL_AAAVV #HiScoreX+3, #ScoreY, hiscore3, White, 3
        rts

;===============================================================================

gameFlowBulletDisplay
        LIBSCREEN_DRAWDECIMAL_AAAV #AmmoValX, #StatusY, bullets, White
        LIBSCREEN_SETCOLORPOSITION_AA #AmmoValX+2, #StatusY
        LIBSCREEN_SETCHAR_V BulletColor
        LIBSCREEN_SETCHARPOSITION_AA #AmmoValX+2, #StatusY
        LIBSCREEN_SETCHAR_V Bullet1stCharUp+3
        rts

;===============================================================================

gameFlowBombDisplay
        LIBSCREEN_DRAWDECIMAL_AAAV #AmmoValX+3, #StatusY, bombs, White
        LIBSCREEN_SETCOLORPOSITION_AA #AmmoValX+5, #StatusY
        LIBSCREEN_SETCHAR_V MissileColor
        LIBSCREEN_SETCHARPOSITION_AA #AmmoValX+5, #StatusY
        LIBSCREEN_SETCHAR_V MissileUpChr
        rts

;===============================================================================

gameFlowShieldGaugeFull
        LIBSCREEN_DRAWTEXT_AAAV #GaugeX, #StatusY, flowGaugeFull, White
        LIBSCREEN_DRAWTEXT_AAAA #GaugeBarX, #StatusY, flowGaugeBar, shieldColor
        rts

;===============================================================================

gameFlowShieldGaugeDecrease
        lda shieldEnergy
        cmp #ShieldMaxEnergy
        bcs gFSGDGauge
        LIBSCREEN_DRAWTEXT_AAA #GaugeX, #StatusY, flowGaugeSpc

gFSGDGauge
        LIBSCREEN_DRAWDECIMAL_AAA #GaugeX+1, #StatusY, energy

        lda shieldEnergy
        jsr libMathDivideByTen
        clc
        adc #GaugeBarX
        sta flowGaugeChrX

        LIBSCREEN_DRAWTEXT_AAA flowGaugeChrX, #StatusY, flowGaugeSpc

        ldy shieldEnergy
        cpy #50
        bcs gFSGDReturn

        jsr gameflowSelectGaugeColor
        LIBSCREEN_COLORTEXT_AAAV #GaugeBarX, #StatusY, flowGaugeClr, 4

gFSGDReturn
        rts

;===============================================================================

gameFlowShieldGaugeIncrease
        lda shieldEnergy
        cmp #ShieldMaxEnergy
        bcc gFSGINoHundred
        lda #OneCharacter
        jmp gFSGIGauge

gFSGINoHundred
        lda #SpaceCharacter

gFSGIGauge
        sta flowGaugeTxt
        LIBSCREEN_DRAWTEXT_AAA #GaugeX, #StatusY, flowGaugeTxt
        LIBSCREEN_DRAWDECIMAL_AAA #GaugeX+1, #StatusY, energy
        lda shieldEnergy
        jsr libMathDivideByTen
        beq gFSGIReturn
        clc
        adc #GaugeBarX
        sta flowGaugeChrX
        dec flowGaugeChrX

        LIBSCREEN_DRAWTEXT_AAAA flowGaugeChrX, #StatusY, flowGaugeChr, shieldColor

        ldy shieldEnergy
        cpy #50
        bcs gFSGIReturn
        jsr gameflowSelectGaugeColor
        LIBSCREEN_COLORTEXT_AAAV #GaugeBarX, #StatusY, flowGaugeClr, 4

gFSGIReturn
        rts

;===============================================================================

gameFlowSelectGaugeColor
        cpy #45         ; if shield is critically low change color to red
        bcc gFSGCRed
        mva shieldColor, flowGaugeClr
        rts

gFSGCRed
        mva #Red, flowGaugeClr
        rts

;===============================================================================

gameFlowEndMessage
        LIBSCREEN_DRAWTEXT_AAAV #GameEndX,  #GameEndY, gameEndText1, LightGreen
        LIBSCREEN_DRAWTEXT_AAAV #GameEndX, #GameEndY+2, gameEndText2, Cyan
        rts
