;===============================================================================
;  gameFlow.asm - Game Flow Control
;
;  Copyright (C) 2017,2018 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
; Constants

FlowStateMenu   = 0
FlowStateAlive  = 1
FlowStateDying  = 2
JoyStickDelay   = 10
BarCharacter    = $50
OneCharacter    = $31

;===============================================================================
; Page Zero

time1           = $0B
time2           = $0C

;===============================================================================
; Variables

flowScoreX      byte 7
flowScoreNumX   byte 0
flowScoreY      byte 0
score1          byte 0
score2          byte 0
score3          byte 0

flowHiScoreX    byte 24
flowHiScoreNumX byte 0
flowHiScoreY    byte 0
hiscore1        byte 0
hiscore2        byte 0
hiscore3        byte 0
statsHiScore    byte 0

flowGaugeX      byte 1
flowGaugeOneX   byte 2
flowGaugeBarX   byte 5
flowGaugeChrX   byte 0
flowGaugeY      byte 24
energy          byte 0
lastEnergy      byte 0
flowGaugeCnt    byte 0
flowGaugeClr    byte 0

flowAmmoX       byte 32
flowAmmoNumX    byte 0
flowAmmoY       byte 24
bullets         byte 0
bullets1        byte 0
bullets2        byte 0
aliens1         byte 0
aliens2         byte 0

flowJoystick    byte 0

flowScoreText   text 'score:'
                byte 0
flowHiScoreText text 'hi:'
                byte 0
flowAmmoText    text 'ammo:'
                byte 0
flowAmmoClear   dcb 8, SpaceCharacter
                byte 0
flowGaugeFull   text '100%'
                byte 0
flowGaugeTxt    byte $31, $00
flowGaugePct    byte $25, $00
flowGaugeSpc    byte SpaceCharacter, $00
flowGaugeChr    byte BarCharacter, $00
flowGaugeBar    dcb 15, BarCharacter
                byte 0
flowGaugeClear  dcb 19, SpaceCharacter
                byte 0
flowPaused      byte 0
flowState       byte FlowStateMenu
flowDone        byte 1

;===============================================================================
; Jump Tables

gameFlowJumpTableLow
        byte <gameFlowUpdateMenu
        byte <gameFlowUpdateAlive
        byte <gameFlowUpdateDying

gameFlowJumpTableHigh
        byte >gameFlowUpdateMenu
        byte >gameFlowUpdateAlive
        byte >gameFlowUpdateDying

;===============================================================================
; Macros/Subroutines

gameFlowInit
        LIBSCREEN_DRAWTEXT_AAAV flowScoreX, flowScoreY, flowScoreText, White
        jsr gameFlowScoreDisplay

        LIBSCREEN_DRAWTEXT_AAAV flowHiScoreX, flowHiScoreY, flowHiScoreText, White
        jsr gameFlowHiScoreDisplay

        rts

;===============================================================================
gameFlowUpdateMenu
        lda menuDisplayed
        bne gFUMCheckFire
        jsr gameMenuShowLogo
        jsr gameMenuShowText

gFUMCheckFire
        LIBINPUT_GETFIREPRESSED
        beq gFUMStartGame
        lda screenColumn
        cmp #MenuStory
        beq gFUMStoryKeys
        cmp #MenuHangar
        beq gFUMHangarKeys
        jmp gFUMDecScreenTimer

gFUMStoryKeys
        jsr SCNKEY
        jsr GETIN
        cmp #KEY_F1
        beq gFUMShowInfo
        cmp #KEY_F3
        beq gFUMShowHangar
        cmp #KEY_F5
        beq gFUMShowCredits
        jmp gFUMEnd

gFUMStartGame
        jmp gameFlowStartGame

gFUMShowHangar
        lda #MenuHangar
        sta screenColumn
        jsr gameMenuShowHangar
        jsr gameMenuShowText
        jsr gameMenuLevelDisplay
        jsr gameMenuMusicDisplay
        jsr gameMenuSfxDisplay
        jsr gameMenuModelReset
        jmp gFHModelDisplay

gFUMDecScreenTimer
        jsr gameFlowDecreaseTime
        lda time2
        beq gFUMShowStory
        jmp gFUMEnd

gFUMShowStory
        lda #MenuStory
        sta screenColumn
        jsr gameMenuShowLogo
        jmp gameMenuShowText

gFUMShowInfo
        jsr gameFlowResetScreenTime
        lda #MenuInfo
        sta screenColumn
        jmp gameMenuShowText

gFUMHangarKeys
        jmp gameFlowHangar

gFUMShowCredits
        jsr gameFlowResetScreenTime
        lda #MenuCredits
        sta screenColumn
        jsr gameMenuShowText

gFUMEnd
        rts

;===============================================================================
gameFlowHangar
        lda messageFlag
        bne gFHDecMsgTimer
        lda flowJoystick
        bne gFHCheckKeys
        lda #JoyStickDelay
        sta flowJoystick
        jmp gFHJoyLeft

gFHDecMsgTimer
        jsr gameFlowDecreaseTime
        lda time2
        beq gFHRestoreMenu
        jmp gFHEnd

gFHRestoreMenu
        jsr gameMenuRestore
        jmp gameMenuLevelDisplay

gFHJoyLeft
        LIBINPUT_GETHELD GameportLeftMask
        bne gFHJoyRight
        jmp gFHPrevModel

gFHJoyRight
        LIBINPUT_GETHELD GameportRightMask
        bne gFHJoyDown
        jmp gFHNextModel

gFHJoyDown
        LIBINPUT_GETHELD GameportDownMask
        bne gFHHideShield
        jsr gameMenuShieldDisplay
        jmp gFHCheckKeys

gFHHideShield
        jmp gameMenuShielHide

gFHCheckKeys
        dec flowJoystick
        ; Hangar Menu Key handling
        jsr SCNKEY
        jsr GETIN
        cmp #KEY_LEFT
        beq gFHPrevModel
        cmp #KEY_RIGHT
        beq gFHNextModel
        cmp #KEY_DOWN
        beq gFHPrevModel
        cmp #KEY_UP
        beq gFHNextModel
        cmp #KEY_F1
        beq gFHShipColor
        cmp #KEY_F3
        beq gFHShieldColor
        cmp #KEY_F5
        beq gFHLevel
        cmp #KEY_M
        beq gFHMusicSwitch
        cmp #KEY_S
        beq gFHSfxSwitch
        cmp #KEY_F7
        beq gFHSaveData
        cmp #KEY_BACK
        bne gFHEnd
        jmp gFUMShowStory

gFHPrevModel
        jsr gameMenuModelPrevious
        jmp gFHModelDisplay

gFHNextModel
        jsr gameMenuModelNext
        jmp gFHModelDisplay

gFHShipColor
        jsr gameMenuShipColorNext
        jmp gFHModelDisplay

gFHShieldColor
        jsr gameMenuShieldColorNext
        jmp gameMenuColorDisplay

gFHLevel
        jsr gameMenuLevelChange
        jmp gameMenuLevelDisplay

gFHMusicSwitch
        jsr gameMenuMusicSwitch
        jmp gameMenuMusicDisplay

gFHSfxSwitch
        jsr gameMenuSfxSwitch
        jmp gameMenuSfxDisplay

gFHSaveData
        jsr gameMenuSavingDisplay
        jsr gameDataSave
        jsr gameMenuSavedDisplay
        jmp gameFlowResetMsgTime

gFHModelDisplay
        jsr gameMenuColorDisplay
        jsr gameMenuModelDisplay

gFHEnd
        rts

;===============================================================================
gameFlowStartGame

        ; set screen
        jsr gameMenuClearText
        jsr gameStarsScreen
        jsr gameFlowInit
        jsr gameFlowShowGameStatus

        ; set difficulty level
        ldx levelNum
        lda bulletSpeedArray,X
        sta bulletSpeed
        lda shieldSpeedArray,X
        sta shieldSpeed
        lda aliensSpeedArray,X
        sta aliensSpeed
        lda wavesTableLow,X
        sta wavesFormationLow
        lda wavesTableHigh,X
        sta wavesFormationHigh

        ; reset
        lda #MenuGameOver
        sta screenColumn
        lda #False
        sta flowPaused

        jsr gameFlowResetScore
        jsr gameFlowResetBullets
        jsr gameAliensReset
        jsr gamePlayerReset
        jsr libMusicInit

        ; change state
        lda #FlowStateAlive
        sta flowState

        rts

;===============================================================================
gameFlowShowGameStatus
        jsr gameflowShieldGaugeFull

        LIBSCREEN_DRAWTEXT_AAAV flowAmmoX, flowAmmoY, flowAmmoText, White
        jsr gameflowBulletsDisplay

        rts

;===============================================================================
gameFlowUpdateAlive
        jsr SCNKEY
        jsr GETIN
        cmp #0
        beq gFUAReturn
        cmp #KEY_SPACE
        beq gFUAPause
        cmp #KEY_M
        beq gFUAMusic
        cmp #KEY_S
        jsr gameMenuSfxSwitch
        beq gFUAReturn
        jmp gFUADisable
gFUAPause
        lda flowPaused
        beq gFUAPlay
        inc flowPaused
        jmp gFUAReturn
gFUAPlay
        dec flowPaused
        jmp gFUADisable
gFUAMusic
        jsr gameMenuMusicSwitch
        beq gFUAReturn
gFUADisable
        jsr libSoundInit
gFUAReturn
        rts

;===============================================================================
gameFlowUpdateDying
        LIBSPRITE_ISANIMPLAYING_A playerSprite
        bne gFUDEnd

        jsr libMultiplexReset
        jsr gameFlowClearStatusLine
        jsr gameFlowResetGameOverTime

        ; change state
        lda #FlowStateMenu
        sta flowState
        jsr gameMenuShowText
        jsr gameMenuShowStats
gFUDEnd
        rts

;===============================================================================
gameFlowClearStatusLine

        LIBSCREEN_DRAWTEXT_AAAV flowGaugeX, flowGaugeY, flowGaugeClear, White
        LIBSCREEN_DRAWTEXT_AAAV flowAmmoX, flowAmmoY, flowAmmoClear, White

        rts

;===============================================================================
gameFlowUpdate

        ; get the current state
        ldy flowState 

        ; write the subroutine address to a zeropage location
        lda gameFlowJumpTableLow,y
        sta ZeroPageLow
        lda gameFlowJumpTableHigh,y
        sta ZeroPageHigh

        ; jump to the subroutine the zeropage location points to
        jmp (ZeroPageLow)

;===============================================================================
gameFlowIncreaseScore
        
        sed             ;set decimal mode
        clc
        lda aliensScore ;points scored
        adc score1      ;ones and tens
        sta score1
        lda score2      ;hundreds and thousands
        adc #00
        sta score2
        lda score3      ;ten-thousands and hundred-thousands
        adc #00
        sta score3
        clc
        lda #1          ;alien destroyed
        adc aliens1     ;ones and tens
        sta aliens1
        lda aliens2     ;hundreds and thousands
        adc #00
        sta aliens2
        cld             ;clear decimal mode

        jsr gameFlowScoreDisplay

        rts

;===============================================================================
gameFlowResetScore
        
        lda #0
        sta score1
        sta score2
        sta score3
        sta statsHiScore

        jsr gameFlowScoreDisplay 

        rts

;===============================================================================
gameFlowResetScreenTime

        lda #$60
        sta time1

        lda #ScreenTime
        sta time2
        rts

;===============================================================================
gameFlowResetGameOverTime

        lda #$60
        sta time1

        lda #GameOverTime
        sta time2
        rts

;===============================================================================
gameFlowResetMsgTime

        lda #$60
        sta time1

        lda #MessageTime
        sta time2
        rts

;===============================================================================
gameFlowDecreaseTime

        lda time2
        beq gFDTDone

        sed             ;set decimal mode
        sec             ; sec is the same as clear borrow
        lda time1       ; Get first number
        sbc #1          ; Subtract 1
        sta time1       ; Store in first number
        lda time2       ; Get 2nd first number
        sbc #0          ; Subtract borrow
        sta time2       ; Store 2nd number
        cld              ;clear decimal mode

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
        lda #1          ;1 bullet added
        adc bullets
        sta bullets
        clc
        lda #1          ;add to statistics
        adc bullets1    ;ones and tens
        sta bullets1
        lda bullets2    ;hundreds and thousands
        adc #00
        sta bullets2
        cld             ;clear decimal mode

        jsr gameflowBulletsDisplay

gFABDone
        rts

;===============================================================================
gameFlowUseBullet
        
        sed             ;set decimal mode
        sec
        lda bullets
        sbc #1          ;1 bullet used
        sta bullets
        cld             ;clear decimal mode

        jsr gameflowBulletsDisplay

        rts

;===============================================================================
gameFlowUpdateGauge
        
        sed             ;set decimal mode
        clc
        lda #0
        adc shieldEnergy
        sta energy
        cld             ;clear decimal mode
        lda shieldEnergy
        cmp lastEnergy
        beq gFUGDone
        bcs gFUGHigher
        sta lastEnergy
        jsr gameflowShieldGaugeDecrease
        jmp gFUGDone
gFUGHigher
        sta lastEnergy
        beq gFUGDone
        jsr gameflowShieldGaugeIncrease
gFUGDone
        rts

;===============================================================================
gameFlowResetBullets

        lda #0
        sta bullets
        sta bullets1
        sta bullets2
        sta aliens1
        sta aliens2

        jsr gameflowBulletsDisplay
        jsr gameBulletsReset

        rts

;===============================================================================
gameFlowPlayerDied

        jsr gameBulletsReset ; stops in flight bullets from scoring
        jsr gameFlowUpdateHiScore
        jsr gameflowBulletsDisplay

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

        lda score1
        sta hiscore1
        lda score2
        sta hiscore2
        lda score3
        sta hiscore3
        
        lda #True
        sta statsHiScore

        jsr gameFlowHiScoreDisplay

gFUHNotHi
        rts

;===============================================================================
gameFlowScoreDisplay

        LIBMATH_ADD8BIT_AVA flowScoreX, 6, flowScoreNumX
        LIBSCREEN_DRAWDECIMAL_AAAV flowScoreNumX, flowScoreY, score3, White

        LIBMATH_ADD8BIT_AVA flowScoreX, 8, flowScoreNumX
        LIBSCREEN_DRAWDECIMAL_AAAV flowScoreNumX, flowScoreY, score2, White

        LIBMATH_ADD8BIT_AVA flowScoreX, 10, flowScoreNumX
        LIBSCREEN_DRAWDECIMAL_AAAV flowScoreNumX, flowScoreY, score1, White

        rts

;===============================================================================
gameFlowHiScoreDisplay

        LIBMATH_ADD8BIT_AVA flowHiScoreX, 3, flowHiScoreNumX
        LIBSCREEN_DRAWDECIMAL_AAAV flowHiScoreNumX, flowHiScoreY, hiscore3, White

        LIBMATH_ADD8BIT_AVA flowHiScoreX, 5, flowHiScoreNumX
        LIBSCREEN_DRAWDECIMAL_AAAV flowHiScoreNumX, flowHiScoreY, hiscore2, White

        LIBMATH_ADD8BIT_AVA flowHiScoreX, 7, flowHiScoreNumX
        LIBSCREEN_DRAWDECIMAL_AAAV flowHiScoreNumX, flowHiScoreY, hiscore1, White

        rts

;===============================================================================
gameflowBulletsDisplay

        LIBMATH_ADD8BIT_AVA flowAmmoX, 5, flowAmmoNumX
        LIBSCREEN_DRAWDECIMAL_AAAV flowAmmoNumX, flowAmmoY, bullets, White

        rts

;===============================================================================
gameflowShieldGaugeFull
        LIBSCREEN_DRAWTEXT_AAAV flowGaugeX, flowGaugeY, flowGaugeFull, White
        LIBSCREEN_DRAWTEXT_AAAA flowGaugeBarX, flowGaugeY, flowGaugeBar, shieldColor
        rts

;===============================================================================
gameflowShieldGaugeDecrease
        lda shieldEnergy
        cmp #ShieldMaxEnergy
        bcs gFSGDGauge
        LIBSCREEN_DRAWTEXT_AAA flowGaugeX, flowGaugeY, flowGaugeSpc

gFSGDGauge
        LIBSCREEN_DRAWDECIMAL_AAA flowGaugeOneX, flowGaugeY, energy

        lda shieldEnergy
        jsr libMathDivideByTen
        clc
        adc flowGaugeBarX
        sta flowGaugeChrX

        LIBSCREEN_DRAWTEXT_AAA flowGaugeChrX, flowGaugeY, flowGaugeSpc

        ldy shieldEnergy
        cpy #50
        bcs gFSGDReturn

        jsr gameflowSelectGaugeColor
        LIBSCREEN_COLORTEXT_AAAV flowGaugeBarX, flowGaugeY, flowGaugeClr, 4

gFSGDReturn
        rts

;===============================================================================
gameflowShieldGaugeIncrease
        lda shieldEnergy
        cmp #ShieldMaxEnergy
        bcc gFSGINoHundred

        lda #OneCharacter
        jmp gFSGIGauge

gFSGINoHundred
        lda #SpaceCharacter

gFSGIGauge
        sta flowGaugeTxt
        LIBSCREEN_DRAWTEXT_AAA flowGaugeX, flowGaugeY, flowGaugeTxt
        LIBSCREEN_DRAWDECIMAL_AAA flowGaugeOneX, flowGaugeY, energy

        lda shieldEnergy
        jsr libMathDivideByTen
        beq gFSGIReturn
        clc
        adc flowGaugeBarX
        sta flowGaugeChrX
        dec flowGaugeChrX

        LIBSCREEN_DRAWTEXT_AAAA flowGaugeChrX, flowGaugeY, flowGaugeChr, shieldColor

        ldy shieldEnergy
        cpy #50
        bcs gFSGIReturn

        jsr gameflowSelectGaugeColor
        LIBSCREEN_COLORTEXT_AAAV flowGaugeBarX, flowGaugeY, flowGaugeClr, 4

gFSGIReturn
        rts

;===============================================================================
gameflowSelectGaugeColor
        cpy #45         ; if shield is critically low change color to red
        bcc gFSGCRed
        lda shieldColor
        sta flowGaugeClr
        jmp gFSGCDone

gFSGCRed
        lda #Red
        sta flowGaugeClr

gFSGCDone
        rts

