;===============================================================================
;  gameAliens.asm - Aliens control module
;
;  Copyright (C) 2017-2021 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
; Constants

AliensMax             = 11      ; how many aliens per wave
AliensFirePatternMax  = 100
AliensRespawnDelay    = 255
AliensYStart          = 15
AliensYDelay          = 1
AliensYPriorityTop    = 56
AliensYPriorityBottom = 224

AlienShooter          = 0
AlienMine             = 1
AlienOrb              = 2
AlienProbe            = 3
Asteroid              = 4

AlienBat              = 33
AlienSquid            = AlienBat+2
AlienPogo             = AlienBat+6
AlienClamp            = AlienBat+10
AlienHard             = 70
AlienDamaged          = AlienHard+5
AsteroidFrame         = 46

AsteroidsDelayMax     = 3

AsteroidColor         = MediumGray
AlienHardColor        = MediumGray
AlienDamagedColor     = LightGray

AnimaSpeed            = 7

KilledByShield        = $05
KilledByBullet        = $10
KilledByBomb          = $15 

;===============================================================================
; Page Zero

minesStage            = $1D
minesShow             = $1E
aliensWaves           = $1F
aliensActive          = $20
aliensCount           = $21
aliensStep            = $22
aliensType            = $23
aliensSprite          = $24
aliensIndex           = $25
aliensFire            = $26
aliensY               = $27
aliensSpeed           = $28
aliensRespawn         = $29
aliensFireIndex       = $2A
aliensXChar           = $2B
aliensYChar           = $2C
aliensXOffset         = $2D
aliensXHigh           = $2E
aliensXLow            = $2F

;===============================================================================
; Variables

aliensNonShooters     byte   0
aliensCountWaves      byte   0
aliensColor           byte   0
aliensActiveArray     dcb   AliensMax, 0
aliensTypeArray       dcb   AliensMax, 0
aliensXHighArray      dcb   AliensMax, 0
aliensXLowArray       dcb   AliensMax, 0
aliensXArray          byte  28,  52,  75,  98, 121, 144,  40,  64,  87, 110, 133
aliensX               byte   0
aliensYArray          dcb   AliensMax, AliensYStart
aliensXCharArray      dcb   AliensMax, 0
aliensYCharArray      dcb   AliensMax, 0
aliensXOffsetArray    dcb   AliensMax, 0
aliensXMoveIndexDef   byte 125, 120, 115,  20,  25,  25, 130,  80,  25,  35,  25
aliensXMoveIndexArray dcb   AliensMax, 0
aliensYFireArray      byte  60,  60,  63,  63,  60,  60,  90,  90,  93,  90,  90
aliensFireArray       dcb   AliensMax, 0
aliensFireIndexArray  byte  13
                      dcb   AliensMax-1, 0
aliensRespawnArray    dcb   AliensMax, 0
aliensPriority        byte   0
aliensCollision       byte   0
aliensScore           byte   0
alienFrameStart       byte   0
alienFrameEnd         byte   0
alienProbeStart       byte   0
alienProbeEnd         byte   0
alienProbeColor       byte   0
alienOrbColor         byte   0
alienShooterStart     byte   0
alienShooterEnd       byte   0
alienShooterColor     byte  Green

aliensHitsArray       dcb   AliensMax, 0
asteroidsStartArray   byte  AsteroidFrame, AsteroidFrame+4, AsteroidFrame+8
asteroidsEndArray     byte  AsteroidFrame+3, AsteroidFrame+7, AsteroidFrame+11

rndSeed               byte   0

;===============================================================================
; Jump Tables

ntscSpeedTableLow     byte  <ntscSpeedSlow, <ntscSpeedNormal
                      byte  <ntscSpeedFast, <ntscSpeedWarp
ntscSpeedTableHigh    byte  >ntscSpeedSlow, >ntscSpeedNormal
                      byte  >ntscSpeedFast, >ntscSpeedWarp

palSpeedTableLow      byte  <palSpeedSlow, <palSpeedNormal
                      byte  <palSpeedFast, <palSpeedWarp
palSpeedTableHigh     byte  >palSpeedSlow, >palSpeedNormal
                      byte  >palSpeedFast, >palSpeedWarp

;==============================================================================
; Macros/Subroutines

gameAliensInit
        lda #0
        sta wavesIndex
        sta wavesActive
        sta aliensStep
        sta aliensCount
        sta minesShow
        rts

;==============================================================================

gameAliensReset
if NUMOFWAVES < 2
        ; Number of waves to change stages
        ldx levelNum
        lda stagesWavesArray,X
        sta aliensWaves
else
        mva #NUMOFWAVES, alienWaves
endif
        ; Calculate first stage with Mines based on Difficulty Level
        LIBMATH_SUB8BIT_VAA 3, levelNum, minesStage

        ; Get first Wave index
        ldx wavesIndex
if STARTWAVE = 0
        lda startWaveArray,X
else
        lda #STARTWAVE
endif
        sta wavesIndex
        jsr gANWConfigWave      ; expects A containing # of the wave
        ; Calculate Aliens X high/low position tables

        ldx #0
        stx asteroidsXMove
        stx asteroidsDelay
        stx minesShow
        stx aliensSprite

gARLoop
        inc aliensSprite
        lda aliensXArray,X
        sta aliensX

        LIBMATH_ADD16BIT_VAVAAA 0, aliensX, 0, aliensX, aliensXHigh, aliensXLow

        lda aliensXHigh
        sta aliensXHighArray,X
        lda aliensXLow
        sta aliensXLowArray,X

        LIBMPLEX_MULTICOLORENABLE_AV aliensSprite, True

        ; loop for each alien
        inx
        cpx #AliensMax
        bcc gARLoop
        ; the next routine must be gameAliensWaveReset (don't move)

;==============================================================================

gameAliensWaveReset
        lda aliensCountWaves
        cmp aliensWaves
        beq gAWRAsteroids
        bcs gAWRStageEnd
        lda flowStageCnt
        cmp #LastStageCnt
        beq gAWRLastStage
        jmp gAWRStart

gAWRStageEnd
        inc flowStageCnt
        inc flowStageIndex
        jmp gAWRNextStage

gAWRLastStage
        ; Last stage has only 1 wave
        lda aliensCountWaves
        bne gAWRGameOver
        jmp gAWRStart

gAWRGameOver
        inc flowStageCnt
        mva #GameEnd, playerFlyUp
        LIBMATH_SUB8BIT_AVA playerY, PlayerVerticalSpeed, playerY
        mva #FlyUpWaitTime, timer2
        jsr gameBulletsReset
        jsr gameBombsReset
        jmp gameFlowEndMessage

gAWRAsteroids
        mva #0, Frame
        mva #1, asteroidsDelay
        sta asteroidsXMove
        lda wavesIndex
        lsr A
        bcc gAWREven
        mva #AsteroidsWave1, wavesIndex
        jsr gANWConfigWave
        jmp gAWRStart

gAWREven
        mva #AsteroidsWave2, wavesIndex
        jsr gANWConfigWave
        jmp gAWRStart

gAWRNextStage
        lda #False
        sta asteroidsXMove
        sta asteroidsDelay
        mva #StageEnd, playerFlyUp
        LIBMATH_SUB8BIT_AVA playerY, PlayerVerticalSpeed, playerY
        jsr gameFlowSkillLevel
        jsr gameBulletsReset
        jsr gameBombsReset
        LIBSCREEN_DRAWTEXT_AAAV #StageEndX, #StageEndY, stageEndText, Cyan
        inc stageNumChar
        jsr gameFlowAlienSprites

gAWRStart
        ; Debug: Show Current Wave ID
if SHOWWAVEID = 1
        LIBSCREEN_DRAWHEX_AAAV #38, #0, wavesIndex, DarkGray
endif
        ldx #0
        stx aliensSprite
        stx aliensCollision
        stx aliensCount
        stx aliensNonShooters
        stx bomberTime
        lda fullMode
        beq gAWRLoop
        dec fullMode
        lda fullMode
        bne gAWRLoop
        jsr gameFlowBulletDisplay
;-------------------------------------------------------------------------------
gAWRLoop
        inc aliensSprite ; x+1
        mva #False, aliensActive
        lda aliensXHighArray,X
        sta aliensXHigh
        lda aliensXLowArray,X
        sta aliensXLow
        mva #AliensYStart, aliensY
        txy
        lda (wavesFormationLow),Y
        sta aliensRespawn
        lda (wavesAliensLow),Y
        ldy asteroidsXMove
        bne gAWRSetAsteroid
        jmp gAWRSetType

gAWRSetAsteroid
        ; Use asteroid formation as probe wave
        lda #Asteroid

gAWRSetType
        sta aliensType
        cmp #AlienShooter
        beq gAWSetXPosition
        inc aliensNonShooters
        cmp #Asteroid
        beq gAWAsteroids
        cmp #AlienOrb
        beq gAWSetOrb
if MINESFROMSTART  = 0
        ldy minesShow
        bne gAWRSetStep
        mva #AlienProbe, aliensType
endif
        jmp gAWRSetStep
        
gAWAsteroids
        lda #0

gAWRSetStep
        sta aliensHitsArray,X
        jmp gAWRSetSprite

gAWSetOrb
        sta aliensHitsArray,X

gAWSetXPosition
        lda aliensXMoveIndexDef,X
        sta aliensXMoveIndexArray,X

gAWRSetSprite
        ; save X register as it gets trashed
        stx aliensIndex

        LIBMPLEX_SETPOSITION_AAAA aliensSprite, aliensXHigh, aliensXLow, aliensY
        jsr gameAliensSetVariables
        lda aliensType
        sta aliensTypeArray,X
        ; loop for each alien
        inx
        cpx #AliensMax
        beq gAWActivateWave
        jmp gAWRLoop
;-------------------------------------------------------------------------------
gAWActivateWave
        mva #True, wavesActive
        ; reset wave timer
        mva cycles, timer1
        ldy wavesIndex
        lda wavesTimeArray,Y
        sta timer2
        lda wavesBomberArray,Y
        sta bomberTime
        beq gAWRCheck
        jsr gameBomberReset

gAWRCheck
        ; check if end of stage
        lda playerFlyUp
        beq gAWRNext
        mva timer2, saveWaveTime
        mva #FlyUpWaitTime, timer2
        mva bomberTime, saveBomberTime
        mva #0, bomberTime

gAWRNext
        ; get next wave
        inc aliensCountWaves
        jmp gameAliensNextWave

;==============================================================================

gameAliensUpdate
        ldx #0
        stx aliensSprite

gAULoop
        inc aliensSprite
        ldy aliensSprite
        jsr gameAliensGetVariables
        lda aliensActive
        beq gAUSkipThisAlien
        jsr gameAliensUpdatePosition
        jsr gameAliensUpdateFiring
        ; Don't check collisions every frame
        lda aliensStep
        bne gAUUpdated
        jsr gameAliensUpdateCollisions
        jmp gAUUpdated

gAUSkipThisAlien
        jsr gameAliensUpdateInactive
        lda aliensCount
        cmp #AliensMax
        beq gAUWaveReset

gAUUpdated
        jsr gameAliensSetVariables
        ; loop for each alien
        inx
        cpx #AliensMax
        bne gAULoop

gAUFinish
        mva #0, aliensCollision
        lda asteroidsXMove
        beq gAUReturn
        lda asteroidsDelay
        cmp #AsteroidsDelayMax
        bcc gAUNext
        mva #0, asteroidsDelay
        jmp gAUReturn

gAUNext
        inc asteroidsDelay

gAUReturn
        jsr gameFlowDecreaseTime
        beq gAUEndWave
        rts

gAUWaveReset
        ; reset the formation when wave ends and all aliens are deactivated
        jmp gameAliensWaveReset

gAUEndWave
        lda wavesActive
        beq gAUClearCount
        lda aliensCount
        cmp aliensNonShooters
        bcc gAUClearCount
        dec wavesActive

gAUClearCount
        mva #0, aliensCount
        rts

;==============================================================================

gameAliensGetVariables
        lda aliensActiveArray,X
        sta aliensActive
        lda aliensTypeArray,X
        sta aliensType
        lda sprxh,y
        sta aliensXHigh
        lda sprxl,y
        sta aliensXLow
        lda aliensYArray,X
        sta aliensY
        lda aliensRespawnArray,X
        sta aliensRespawn
        stx aliensIndex                 ; save X register as it gets trashed
        rts

;==============================================================================

gameAliensSetVariables
        ldx aliensIndex                 ; restore X register as it gets trashed
        lda aliensActive
        sta aliensActiveArray,X
        lda aliensRespawn
        sta aliensRespawnArray,X
        lda aliensY
        sta aliensYArray,X
        rts

;==============================================================================

gameAliensUpdatePosition
        lda aliensY
        ldy aliensStep
        bne gAUPIStart
        jmp gAUPIGetCharPos

gAUPIStart
        ldy aliensType
        cpy #AlienShooter
        beq gAUPIShooters
        cpy #AlienOrb
        beq gAUPIOrbs
        jmp gAUPIIncMove

gAUPIShooters
        ldy wavesActive
        beq gAUPIIncMove
        cmp aliensYFireArray,X          ; X must contain alien index
        bcc gAUPIIncMove
        jmp gAUPIFirePos

gAUPIOrbs
        clc
        adc aliensStep
        sta aliensY
        cmp #MAXSPRY
        bcs gAUPIMoveUp

        jsr gameAliensUpdatePriority
        jmp gAUPIMoveOrb

gAUPIIncMove
        clc
        adc aliensStep
        sta aliensY
        cmp #MAXSPRY
        bcs gAUPIMoveUp

        jsr gameAliensUpdatePriority
        jmp gAUPISetPosition

gAUPIMoveUp
        mva #AliensYStart, aliensY
        lda timer2
        beq gAUPIFinishWave

gAUPIResetSprite
        lda aliensType
        cmp #Asteroid
        beq gAUPIResetAsteroid
        cmp #AlienMine
        beq gAUPIResetMine
        cmp #AlienProbe
        bcc gAUPIRestoreX
        jmp gAUPISetVerticalPos

gAUPIResetMine
        sta aliensHitsArray,X
        LIBMPLEX_PLAYANIM_AVVVV aliensSprite, AlienHard, AlienHard+4, AnimaSpeed, True
        LIBMPLEX_SETCOLOR_AV aliensSprite, AlienHardColor
        jmp gAUPISetVerticalPos

gAUPIResetAsteroid
        ; set asteroid frame back to original
        LIBMPLEX_PLAYANIM_AVVVV aliensSprite, AsteroidFrame, AsteroidFrame+3, AnimaSpeed, True

        lda #0
        sta aliensHitsArray,X

gAUPIRestoreX
        lda aliensXArray,X              ; X must contain alien index
        sta aliensX
        LIBMATH_ADD16BIT_VAVAAA 0, aliensX, 0, aliensX, aliensXHigh, aliensXLow
        jmp gAUPISetHorizontalPos

gAUPIFinishWave
        mva #False, aliensActive        ; deactivate all aliens when wave ends

gAUPISetPosition
        lda asteroidsXMove
        beq gAUPISetVerticalPos
        lda asteroidsDelay
        bne gAUPISetVerticalPos
        ldx aliensIndex
        lda asteroidsSpeedX,X
        beq gAUPISetVerticalPos
        sta ZeroPageTemp

gAUPIMoveX
        LIBMATH_ADD16BIT8BITSIGN_AAAAA aliensXHigh, aliensXLow, ZeroPageTemp, aliensXHigh, aliensXLow

gAUPISetHorizontalPos
        LIBMPLEX_SETPOSITION_AAAA aliensSprite, aliensXHigh, aliensXLow, aliensY
        jmp gAUPISetCharPos

gAUPISetVerticalPos
        LIBMPLEX_SETVERTICALTPOS_AA aliensSprite, aliensY
        
gAUPISetCharPos
        LIBSCREEN_PIXELTOCHAR_AAVAVAAA aliensXHigh, aliensXLow, 12, aliensY, 40, aliensXChar, aliensXOffset, aliensYChar
        ldx aliensIndex
        sta aliensYCharArray,X ; A is loaded with aliensYChar from the macro
        lda aliensXChar
        sta aliensXCharArray,X
        lda aliensXOffset
        sta aliensXOffsetArray,X
        rts

gAUPIFirePos
        ; load shooter variables
        lda aliensYFireArray,X
        sta aliensY
        lda aliensFireArray,X
        sta aliensFire
        lda aliensFireIndexArray,X
        sta aliensFireIndex
        ; get X movement offset
        ldy aliensXMoveIndexArray,X
        iny
        cpy #AliensXMoveMax
        bcc gAUPIDontReset
        ; reset index
        ldy #0
        
gAUPIDontReset
        tya
        sta aliensXMoveIndexArray,X
        lda aliensXMoveArray,Y
        sta ZeroPageTemp
        jmp gAUPIMoveX

gAUPIMoveOrb
        ; get X movement offset
        ldy aliensXMoveIndexArray,X
        iny
        cpy #OrbsXMoveMax
        bcc gAUPIDontResetOrb
        ; reset index
        ldy #0

gAUPIDontResetOrb
        tya
        sta aliensXMoveIndexArray,X
        lda orbsXMoveArray,Y
        sta ZeroPageTemp
        jmp gAUPIMoveX

gAUPIGetCharPos
        ; load pre-calculated char based position
        ldx aliensIndex
        lda aliensXCharArray,X
        sta aliensXChar
        lda aliensYCharArray,X
        sta aliensYChar
        lda aliensXOffsetArray,X
        sta aliensXOffset
        rts

;==============================================================================

gameAliensUpdatePriority
        ; prevent aliens to cover text on screen, but stay over the stars
        ldy aliensY
        cpy #AliensYPriorityTop
        bcc gAUPRMoveUnder
        cpy #AliensYPriorityBottom
        bcc gAUPRMoveOver

gAUPRMoveUnder
        mva #True, aliensPriority
        jmp gAUPRDone 

gAUPRMoveOver
        mva #False, aliensPriority

gAUPRDone
        LIBMPLEX_SETPRIORITY_AA aliensSprite, aliensPriority
        rts

;==============================================================================

gameAliensUpdateFiring
        lda aliensType          ; skip red aliens and asteroids
        cmp #AlienShooter
        bne gAUFDontfire

        ldx aliensIndex
        lda aliensY             ; don't fire if alien is not on right position
        cmp aliensYFireArray,X
        bne gAUFDontfire

        lda bulletsActiveTotal
        cmp #BulletsAliens
        bcs gAUFDontfire

        inc aliensFire

        ldy aliensFireIndex
        lda aliensFirePattern,y
        cmp aliensFire
        bne gAUFSaveShooterVars

        mva #0, aliensFire
        ldy aliensFireIndex
        iny
        cpy #AliensFirePatternMax
        bcc gAUFFire
        ldy #0

gAUFFire
        sty aliensFireIndex
        GAMEBULLETS_FIRE_DOWN_AAA aliensXChar, aliensXOffset, aliensYChar
        ldx aliensIndex

gAUFSaveShooterVars
        lda aliensFire
        sta aliensFireArray,X
        lda aliensFireIndex
        sta aliensFireIndexArray,X

gAUFDontfire
        rts

;==============================================================================

gameAliensUpdateCollisions
        lda aliensCollision
        cmp aliensSprite
        bne gAUCCheckBullet
        jmp gAUCShield

gAUCCheckBullet
        GAMEBULLETS_COLLIDED_UP_AA aliensXChar, aliensYChar
        beq gAUCCheckBomb
        dec bulletsActiveUp
        lda aliensType
        cmp #AlienMine
        bcs gAUCCheckHits
        lda #KilledByBullet
        jmp gAUCKill

gAUCCheckBomb
        GAMEBOMB_COLLIDED_Up_AA aliensXChar, aliensYChar
        beq gAUCNoCollision
        lda #KilledByBomb
        jmp gAUCKill

gAUCNoCollision
        rts

gAUCCheckHits
        ldx aliensIndex
        ldy aliensHitsArray,X
        cpy #2
        bcc gAUCNextStep
        lda #0
        sta aliensFire
        lda #KilledByBullet
        jmp gAUCKill

gAUCNextStep
        iny
        cmp #Asteroid           ; A register still has alien type
        beq gAUCNextFrame
        tya
        sta aliensHitsArray,X
        LIBMPLEX_SETCOLOR_AV aliensSprite, AlienDamagedColor
        LIBMPLEX_PLAYANIM_AVVVV aliensSprite, AlienDamaged, AlienDamaged+4, AnimaSpeed, True
        rts

gAUCNextFrame
        tya
        sta aliensHitsArray,X
        lda asteroidsStartArray,Y
        sta ZeroPageTemp1
        lda asteroidsEndArray,Y
        sta ZeroPageTemp2
        LIBMPLEX_PLAYANIM_AAAVV aliensSprite, ZeroPageTemp1, ZeroPageTemp2, AnimaSpeed, True
        rts

gAUCShield
        lda #KilledByShield

gAUCKill
        sta aliensScore
        ; gameAliensKill must be the next routine (don't move)

;==============================================================================

gameAliensKill
        ; run explosion animation
        LIBMPLEX_PLAYANIM_AVVVV aliensSprite, StartExplode, FinishExplode, 2, False
        LIBMPLEX_SETCOLOR_AV     aliensSprite, Yellow

        ; play explosion sound
        LIBSOUND_PLAY_VAA ExplosionVoice, soundExplosionHigh, soundExplosionLow

        ; don't increase score when the player dies together
        lda playerWillDie
        bne gAKDone

        jsr gameFlowIncreaseScore

gAKDone
        mva #False, aliensActive
        rts

;==============================================================================

gameAliensUpdateInactive
        lda aliensY
        cmp #AliensYStart
        beq gAUICheckTime

        clc
        adc aliensStep
        sta aliensY
        cmp #MAXSPRY
        bcs gAMIMoveUp
        lda timer2
        bne gAUIVerify
        rts

gAMIMoveUp
        mva #AliensYStart, aliensY
        mva #AliensRespawnDelay-1, aliensRespawn

gAUICheckTime
        lda timer2
        bne gAUIVerify
        inc aliensCount
        rts

gAUIVerify
        inc aliensRespawn
        ldy aliensRespawn
        cpy #AliensRespawnDelay
        beq gAUIRespawn

gAUIDontRespawn
        rts

gAUIRespawn
        ldy aliensType
        lda aliensY
        cmp #AliensYStart
        bne gAUIDontRespawn
        cpy #AlienShooter
        beq gAUIShooter
        cpy #AlienProbe
        beq gAUIProbe
        cpy #AlienOrb
        beq gAUIOrb
        cpy #Asteroid
        beq gAUIAsteroid
        mva #AlienHard, alienFrameStart
        mva #AlienHard+4, alienFrameEnd
        lda #AlienHardColor
        jmp gAUISetSprite

gAUIShooter
        ; X must be unchanged on this routine
        lda aliensXMoveIndexDef,X
        sta aliensXMoveIndexArray,X
        mva alienShooterStart, alienFrameStart
        mva alienShooterEnd, alienFrameEnd
        lda alienShooterColor
        jmp gAUISetSprite

gAUIOrb
        ; X must be unchanged on this routine
        lda aliensXMoveIndexDef,X
        sta aliensXMoveIndexArray,X
        mva #AlienPogo, alienFrameStart
        mva #AlienPogo+3, alienFrameEnd
        lda alienOrbColor
        jmp gAUISetSprite

gAUIAsteroid
        mva #AsteroidFrame, alienFrameStart
        mva #AsteroidFrame+3, alienFrameEnd
        lda #AsteroidColor
        jmp gAUISetSprite

gAUIProbe
        mva alienProbeStart, alienFrameStart
        mva alienProbeEnd, alienFrameEnd
        lda alienProbeColor

gAUISetSprite
        LIBMPLEX_SETCOLOR_A aliensSprite
        LIBMPLEX_PLAYANIM_AAAVV aliensSprite, alienFrameStart, alienFrameEnd, AnimaSpeed, True
        mva #0, aliensRespawn
        inc aliensActive
        ldx aliensIndex
        jmp gAUPIResetSprite

;==============================================================================

gameAliensNextWave
if SEQUENTIALWAVES = 1
        inc wavesIndex
        lda wavesIndex
        cmp #MaxWaves
        bcc gANWConfigWave
        mva #0, wavesIndex
else
        inc rndSeed
        ldx rndSeed
        lda wavesRndTable,X
        sta wavesIndex
endif
gANWConfigWave
        tax
        lda wavesAliensArrayLow,X
        sta wavesAliensLow
        lda wavesAliensArrayHigh,X
        sta wavesAliensHigh

        LIBMATH_ADD8BIT_AAX wavesLevelIndex, wavesIndex
        lda wavesTableLow,X
        sta wavesFormationLow
        lda wavesTableHigh,X
        sta wavesFormationHigh

        lda flowStageCnt
        cmp minesStage  ; Only show Mines on later stages
        bcc gANWNoMine
        lda rndSeed
        and #3          ; only show Mines 25% of the time
        bne gANWNoMine
        lda #True
        jmp gANWReturn

gANWNoMine
        lda #False

gANWReturn
        sta minesShow

        rts
