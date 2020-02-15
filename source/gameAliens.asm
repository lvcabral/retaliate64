;===============================================================================
;  gameAliens.asm - Aliens control module
;
;  Copyright (C) 2017,2018 Marcelo Lv Cabral - <https://lvcabral.com>
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
AliensExplode         = 12      ; first frame # of the explosion animation
AlienRed              = 5       ; Red alien frame #
AlienShooter          = 6       ; Shooter alien frame #

;===============================================================================
; Page Zero

aliensActive          = $20
aliensStep            = $21
aliensFrame           = $22
aliensSprite          = $23
aliensIndex           = $24
aliensFire            = $25
aliensY               = $26

;===============================================================================
; Variables

aliensCount           byte   0
aliensCountRed        byte   0
aliensColor           byte   0
aliensActiveArray     dcb   AliensMax, 0
aliensFrameArray      dcb   AliensMax, 0
aliensXHighArray      dcb   AliensMax, 0
aliensXHigh           byte   0
aliensXLowArray       dcb   AliensMax, 0
aliensXLow            byte   0
aliensXArray          byte  28,  52,  75,  98, 121, 144,  40,  64,  87, 110, 133
aliensX               byte   0
aliensYArray          dcb   AliensMax, AliensYStart
aliensXCharArray      dcb   AliensMax, 0
aliensXChar           byte   0
aliensYCharArray      dcb   AliensMax, 0
aliensYChar           byte   0
aliensXOffsetArray    dcb   AliensMax, 0
aliensXOffset         byte   0
aliensYFireArray      byte  60,  60,  63,  63,  60,  60,  90,  90,  93,  90,  90
aliensFireArray       dcb   AliensMax, 0
aliensFirePattern     byte  12,  12,  90,  90,  12,  12,  12,  90, 200, 200
                      byte  12,  12,  12,  12,  90, 200,  90,  90,  90, 200
                      byte  12,  90,  90,  90,  90, 200,  90, 200,  90, 200
                      byte  12,  12,  12,  12,  12,  12,  12,  12,  12,  90
                      byte  90,  12,  12,  12,  12,  12, 200,  90,  90, 200
                      byte  12,  12,  90,  12,  12,  90,  12,  12,  12, 200
                      byte  90,  12,  12,  12,  12,  12, 200,  90,  90, 200
                      byte  12,  12,  12,  12,  12,  12,  12,  12,  12,  90
                      byte  12,  12,  12,  12,  90, 200,  90,  90,  90, 200
                      byte  90,  12,  12,  12,  12,  12, 200,  90,  90, 200
aliensFireIndexArray  byte  13
                      dcb   AliensMax-1, 0
aliensFireIndex       byte   0
aliensRespawnArray    dcb   AliensMax, 0
aliensRespawn         byte   0
aliensPriority        byte   0
aliensCollision       byte   0
aliensScore           byte   0
aliensSpeedArray      byte   2, 3, 4, 5
aliensSpeed           byte   0
rndSeed               byte   1

;==============================================================================
; Macros/Subroutines

gameAliensInit
        ; Calculate Aliens X high/low position tables
        ldx #0

gAILoop
        lda aliensXArray,X
        sta aliensX

        LIBMATH_ADD16BIT_VAVAAA 0, aliensX, 0, aliensX, aliensXHigh, aliensXLow

        lda aliensXHigh
        sta aliensXHighArray,X
        lda aliensXLow
        sta aliensXLowArray,X

        ; loop for each alien
        inx
        cpx #AliensMax
        bcc gAILoop
        rts

;==============================================================================

gameAliensReset
        lda #0
        sta wavesIndex
        sta wavesTimeIndex
        jsr gameAliensWaveReset
        rts

;==============================================================================

gameAliensWaveReset
        ldx #0
        stx aliensSprite
        stx aliensStep
        stx aliensCollision
        stx aliensCount
        stx aliensCountRed
gARLoop
        inc aliensSprite ; x+1

        lda #False
        sta aliensActive

        lda aliensXHighArray,X
        sta aliensXHigh

        lda aliensXLowArray,X
        sta aliensXLow

        lda #AliensYStart
        sta aliensY

        ldy wavesIndex
        inc wavesIndex

        lda (wavesFormationLow),Y
        sta aliensRespawn

        lda wavesFrameArray,Y
        sta aliensFrame
        beq gARNone
        cmp #AlienRed
        beq gARRed
        lda #Green
        jmp gARSetSprite

gARRed
        inc aliensCountRed
        lda #LightRed

gARSetSprite
        sta aliensColor
        stx aliensIndex; save X register as it gets trashed

        LIBMPLEX_SETPOSITION_AAAA aliensSprite, aliensXHigh, aliensXLow, aliensY
        jsr gameAliensSetVariables

gARNone
        lda aliensFrame
        sta aliensFrameArray,X

gARNext
        ; loop for each alien
        inx
        cpx #AliensMax
        bne gARLoop

        ; activate wave
        lda #True
        sta wavesActive

        ; reset wave timer
        jsr gameAliensResetTime

        ; get next wave
        jsr gameAliensNextWave

gARDone
        rts

;===============================================================================

gameAliensResetTime
        lda #$60
        sta time1

        ldy wavesTimeIndex
        lda wavesTimeArray,Y
        sta time2

gARTDone
        rts

;==============================================================================

gameAliensUpdate
        lda playerActive
        beq gAUReturn

        ldx #0
        stx aliensSprite

gAULoop
        inc aliensSprite

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
        jsr gameAliensMoveInactive
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

        ; increment aliens step
        lda aliensStep
        beq gAUIncMove
        dec aliensStep
        jmp gAUFinish

gAUIncMove
        inc aliensStep

gAUFinish
        lda #0
        sta aliensCollision

        jsr gameFlowDecreaseTime
        beq gAUEndWave

        jmp gAUReturn

gAUWaveReset
        ; reset the formation when wave ends and all aliens are deactivated
        jsr gameAliensWaveReset

        jmp gAUReturn

gAUEndWave
        lda wavesActive
        beq gAUClearCount
        lda aliensCount
        cmp aliensCountRed
        bcc gAUClearCount
        dec wavesActive
gAUClearCount
        lda #0
        sta aliensCount

gAUReturn
        rts

;==============================================================================

gameAliensGetVariables
        lda aliensActiveArray,X
        sta aliensActive
        lda aliensFrameArray,X
        sta aliensFrame
        lda aliensXHighArray,X
        sta aliensXHigh
        lda aliensXLowArray,X
        sta aliensXLow
        lda aliensYArray,X
        sta aliensY
        lda aliensFireArray,X
        sta aliensFire
        lda aliensFireIndexArray,X
        sta aliensFireIndex
        lda aliensRespawnArray,X
        sta aliensRespawn

        stx aliensIndex; save X register as it gets trashed
        rts

;==============================================================================

gameAliensSetVariables
        ldx aliensIndex ; restore X register as it gets trashed

        lda aliensActive
        sta aliensActiveArray,X
        lda aliensFire
        sta aliensFireArray,X
        lda aliensFireIndex
        sta aliensFireIndexArray,X
        lda aliensRespawn
        sta aliensRespawnArray,X
        lda aliensY
        sta aliensYArray,X
        rts

;==============================================================================

gameAliensUpdatePosition
        lda aliensY

        ldy aliensStep
        beq gAUPICharPos

        ldy aliensFrame
        cpy #AlienRed
        bne gAUPIShooters
        
        jmp gAUPIIncMove

gAUPIShooters
        ldy wavesActive
        beq gAUPIIncMove
        cmp aliensYFireArray,X ; X still contains alien index
        bcs gAUPIFirePos
       
gAUPIIncMove
        clc
        adc aliensSpeed
        sta aliensY
        cmp #MAXSPRY
        bcs gAUPIMoveUp

        jsr gameAliensUpdatePriority
        jmp gAUPISetPosition

gAUPIMoveUp
        lda time2
        bne gAUPIContinue

        ; deactivate all aliens when wave ends
        lda #False
        sta aliensActive

gAUPIContinue
        lda #AliensYStart
        sta aliensY

gAUPISetPosition
        LIBMPLEX_SETVERTICALTPOS_AA aliensSprite, aliensY
        ; calculate the alien char positions
        LIBSCREEN_PIXELTOCHAR_AAVAVAAA aliensXHigh, aliensXLow, 12, aliensY, 40, aliensXChar, aliensXOffset, aliensYChar
        ldx aliensIndex
        sta aliensYCharArray,X ; A is loaded with aliensYChar from the macro
        lda aliensXChar
        sta aliensXCharArray,X
        lda aliensXOffset
        sta aliensXOffsetArray,X
        rts
gAUPIFirePos
        lda aliensYFireArray,X
        sta aliensY
gAUPICharPos
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
        lda #True
        sta aliensPriority
        jmp gAUPRDone 

gAUPRMoveOver
        lda #False
        sta aliensPriority

gAUPRDone
        LIBMPLEX_SETPRIORITY_AA aliensSprite, aliensPriority
        rts

;==============================================================================

gameAliensUpdateFiring
        lda aliensFrame         ; red aliens don't fire
        cmp #AlienRed
        beq gAUFDontfire

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
        bne gAUFDontfire

gAUFFire
        GAMEBULLETS_FIRE_DOWN_AAA aliensXChar, aliensXOffset, aliensYChar

        lda #0
        sta aliensFire

        ldy aliensFireIndex
        iny
        cpy #AliensFirePatternMax
        bcc gAUFGetNextDelay
        ldy #0

gAUFGetNextDelay
        sty aliensFireIndex

gAUFDontfire
        rts

;==============================================================================

gameAliensUpdateCollisions
        lda aliensCollision
        cmp aliensSprite
        beq gAUCShield

        GAMEBULLETS_COLLIDED_UP_AA aliensXChar, aliensYChar
        beq gAUCDone
        dec bulletsActiveUp
        lda #10 ;killed by bullet
        jmp gAUCKill

gAUCShield
        lda #5 ;killed by shield

gAUCKill
        sta aliensScore
        jsr gameAliensKill

gAUCDone
        rts

;==============================================================================

gameAliensKill
        ; run explosion animation
        LIBSPRITE_PLAYANIM_AVVVV aliensSprite, AliensExplode, FinishExplode, 1, False
        LIBMPLEX_SETCOLOR_AV     aliensSprite, Yellow

        ; play explosion sound
        LIBSOUND_PLAY_VAA SoundVoice, soundExplosionHigh, soundExplosionLow

        ; don't increase score when the player dies together
        lda playerWillDie
        bne gAKDone

        jsr gameFlowIncreaseScore

gAKDone
        lda #False
        sta aliensActive
        rts

;==============================================================================

gameAliensUpdateInactive
        lda time2
        beq gAUICheckWave
        jmp gAUIVerify

gAUICheckWave
        inc aliensCount
        jmp gAUIDontRespawn

gAUIVerify
        inc aliensRespawn
        ldy aliensRespawn
        cpy #AliensRespawnDelay
        beq gAUIRespawn
        jmp gAUIDontRespawn

gAUIRespawn
        ldy aliensFrame
        beq gAUIDontRespawn
        lda aliensY
        cmp #AliensYStart
        bne gAUIDontRespawn
        cpy #AlienRed
        beq gAUIRed
        lda #Green
        jmp gAUISetSprite

gAUIRed
        lda #LightRed

gAUISetSprite
        sta aliensColor

        lda #0
        sta aliensRespawn

        LIBSPRITE_STOPANIM_A aliensSprite
        LIBMPLEX_SETFRAME_AA aliensSprite, aliensFrame
        LIBMPLEX_SETCOLOR_AA aliensSprite, aliensColor
        inc aliensActive
        jmp gAUPISetPosition

gAUIDontRespawn
        rts

;==============================================================================

gameAliensMoveInactive
        lda aliensY
        cmp #AliensYStart
        beq gAMIReturn

        ldx aliensStep
        beq gAMIReturn
        clc
        adc aliensSpeed
        sta aliensY
        cmp #MAXSPRY
        bcs gAMIMoveUp
        jmp gAMIReturn

gAMIMoveUp
        lda #AliensYStart
        sta aliensY
        lda #AliensRespawnDelay-1
        sta aliensRespawn

gAMIReturn
        rts

;==============================================================================

gameAliensNextWave
;based on http://codebase64.org/doku.php?id=base:fast_8bit_ranged_random_numbers
        lda rndSeed
        beq doEor
        asl
        beq noEor ;if the input was $80, skip the EOR
        bcc noEor
doEor   eor #$4d
noEor   sta rndSeed
        tax
        lda wavesRndTable,X
        sta wavesTimeIndex
        tax
        lda wavesIndexArray,X
        sta wavesIndex
        rts

gameAliensNextWaveDebug
        inc wavesTimeIndex
        lda wavesTimeIndex
        cmp #WavesMax
        bcc getNext
        lda #0
        sta wavesTimeIndex
getNext
        tax
        lda wavesIndexArray,X
        sta wavesIndex
        rts
