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

AliensMax = 6
AliensFirePatternMax = 50
AliensRespawnDelay = 255
AliensYStart = 30
AliensYDelay = 1
AliensYSpeed = 3
AliensYPriorityTop = 56
AliensYPriorityBottom = 224
AliensExplode = 12
AlienRed = 5
AlienShooter = 6
AlienFirePos = 70
WavesMax = 7
WaveIndexMax = 37 ; last index + 1

;===============================================================================
; Variables

aliensActiveArray       dcb    AliensMax, 1
aliensActive            byte   0
aliensCount             byte   0
aliensWaveIndex         byte   0
aliensWaveTimeIndex     byte   0
aliensWaveTimeArray     byte  25,  15,  25,   5,  25,  15, 25
aliensWaveArray         byte   6,   5,   5,   5,   5,   6
                        byte   6,   6,   6,   6,   6,   6
                        byte   5,   5,   6,   6,   5,   5
                        byte   5,   5,   5,   5,   5,   5
                        byte   6,   5,   5,   5,   5,   5
                        byte   6,   6,   6,   6,   6,   6
                        byte   6,   5,   5,   5,   5,   6
aliensFormationArray    byte 100,  50,  70,  70,  50, 200
                        byte 100, 100, 100, 100, 100, 100
                        byte  50, 100, 200, 150, 100,  50
                        byte  50,  50,  50,  50,  50,  50
                        byte 200,  90,  80,  70,  60,  50
                        byte 100, 100, 100, 100, 100, 100
                        byte 200,  80, 100,  80, 100, 200
aliensFrameArray        byte   6,   5,   5,   5,   5,   6
aliensFrame             byte   0
aliensColor             byte   0
aliensXHighArray        byte   0,   0,   0,   0,   0,   1
aliensXHigh             byte   0
aliensXLowArray         byte  55, 103, 150, 195, 242,  30
aliensXLow              byte   0
aliensYArray            byte  30,  30,  30,  30,  30,  30
aliensY                 byte   0
aliensYFire             byte   AlienFirePos
aliensXChar             byte   0
aliensXOffset           byte   0
aliensYOffset           byte   0
aliensYChar             byte   0
aliensFireArray         byte   0,   0,   0,   0,   0,   0
aliensFire              byte   0
aliensFirePattern       byte  12,  12,  90,  90,  12,  12,  12,  90, 200, 200
                        byte  12,  12,  12,  12,  90, 200,  90,  90,  90, 200
                        byte  12,  12,  12,  12,  12, 200,  90, 200,  90, 200
                        byte  90,  12,  12,  12,  12,  12, 200,  90,  90, 200
                        byte  12,  12,  90,  12,  12,  90,  12,  12,  12, 200
aliensFireIndexArray    byte  13,   0,   0,   0,   0,  0
aliensFireIndex         byte   0
aliensRespawnArray      byte   0,   0,   0,   0,   0,  0
aliensRespawn           byte   0
aliensTemp              byte   0
aliensCollisionNo       byte   0
aliensSprite            byte   0
aliensPriority          byte   0
aliensStep              byte   0
aliensCollision         byte   0
aliensScore             byte   0

;==============================================================================
; Macros/Subroutines

gameAliensReset

        lda #0
        sta aliensWaveIndex
        sta aliensWaveTimeIndex

        jsr gameAliensWaveReset
        rts

;==============================================================================
gameAliensWaveReset

        ldx #0
        stx aliensSprite
        stx aliensStep
        stx aliensCollision
        stx aliensCount

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

        ldy aliensWaveIndex
        inc aliensWaveIndex

        lda aliensFormationArray,Y
        sta aliensRespawn

        lda aliensWaveArray,Y
        sta aliensFrame
        cmp #AlienRed
        beq gARRed
        lda #Green
        jmp gARSetSprite

gARRed
        lda #LightRed

gARSetSprite
        sta aliensColor
        stx aliensTemp; save X register as it gets trashed

        jsr gameAliensSetupSprite
        jsr gameAliensSetVariables

        lda aliensFrame
        sta aliensFrameArray,X

        ; loop for each alien
        inx
        cpx #AliensMax
        bne gARLoop

        lda #AlienFirePos
        sta aliensYFire

        ; reset wave timer
        jsr gameAliensResetTime

        ; increment (and rotate) wave index
        lda aliensWaveIndex
        cmp #WaveIndexMax
        bcc gARDone
        lda #0
        sta aliensWaveIndex
gARDone
        rts

;==============================================================================

gameAliensSetupSprite
        LIBSPRITE_SETPOSITION_AAAA aliensSprite, aliensXHigh, aliensXLow, aliensY

        ; update the alien char positions
        LIBSCREEN_PIXELTOCHAR_AAVAVAAAA aliensXHigh, aliensXLow, 12, aliensY, 40, aliensXChar, aliensXOffset, aliensYChar, aliensYOffset

        LIBSPRITE_STOPANIM_A          aliensSprite
        LIBSPRITE_ENABLE_AV           aliensSprite, False
        LIBSPRITE_SETFRAME_AA         aliensSprite, aliensFrame
        LIBSPRITE_SETCOLOR_AA         aliensSprite, aliensColor
        rts

;===============================================================================

gameAliensResetTime

        lda #$60
        sta time1

        ldy aliensWaveTimeIndex
        lda aliensWaveTimeArray,Y
        sta time2

        iny
        cpy #WavesMax
        bcc gARTDone
        ldy #0
gARTDone
        sty aliensWaveTimeIndex
        rts

;==============================================================================

gameAliensUpdate
        lda playerActive
        beq gAUReturn

        ldx #0
        stx aliensSprite

gAULoop
        inc aliensSprite ; x+1

        jsr gameAliensGetVariables

        lda aliensActive
        beq gAUSkipThisAlien

        jsr gameAliensUpdatePosition
        jsr gameAliensUpdateFiring
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

        ; increment alien step
        ldy aliensStep
        cpy #AliensYDelay
        bne gAUIncMove
        ldy #0
        jmp gAUFinish

gAUIncMove
        iny

gAUFinish
        sty aliensStep
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
        lda #0
        sta aliensCount
        lda #255
        cmp aliensYFire
        beq gAUReturn
        sta aliensYFire
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

        stx aliensTemp; save X register as it gets trashed

        rts

;==============================================================================

gameAliensUpdatePosition

        lda playerActive ; only move if the player is alive
        beq gAUPISetPosition

        ldy aliensStep
        cpy #AliensYDelay
        bne gAUPISetPosition

        lda aliensFrame
        cmp #AlienShooter
        beq gAUPIShooters
        
        lda aliensY
        jmp gAUPIIncMove

gAUPIShooters
        lda aliensY
        cmp aliensYFire
        bcs gAUPISetPosition
       
gAUPIIncMove
        adc #aliensYSpeed
        sta aliensY
        cmp #254
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
        LIBSPRITE_SETVERTICALTPOS_AA aliensSprite, aliensY

        ; update the alien char positions
        LIBSCREEN_PIXELTOCHAR_AAVAVAAAA aliensXHigh, aliensXLow, 12, aliensY, 40, aliensXChar, aliensXOffset, aliensYChar, aliensYOffset
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
        LIBSPRITE_SETPRIORITY_AA aliensSprite, aliensPriority
        rts

;==============================================================================

gameAliensUpdateFiring
        lda playerActive ; only fire if the player is alive
        beq gAUFDontfire

        lda aliensFrame ; only one type of alien fires
        cmp #AlienRed
        beq gAUFDontfire

        ldy aliensY ; don't fire if alien is not on right position
        cpy aliensYFire
        bcc gAUFDontfire

        inc aliensFire

        ldy aliensFireIndex
        lda aliensFirePattern,y
        cmp aliensFire
        beq gAUFFire
        jmp gAUFDontfire

gAUFFire
        GAMEBULLETS_FIRE_AAAVV aliensXChar, aliensXOffset, aliensYChar, Yellow, False

        lda #0
        sta aliensFire

        inc aliensFireIndex
        ldy aliensFireIndex
        cpy #AliensFirePatternMax
        bcc gAUFGetNextDelay
        ldy #0

gAUFGetNextDelay
        sty aliensFireIndex

gAUFDontfire
        rts

;==============================================================================

gameAliensUpdateCollisions
        lda #5 ;killed by shield
        sta aliensScore

        ldy aliensSprite
        lda SpriteNumberMask,y
        and aliensCollision
        bne gAUCKill

        GAMEBULLETS_COLLIDED aliensXChar, aliensYChar, True
        beq gAUCDone

        lda #10 ;killed by bullet
        sta aliensScore

gAUCKill
        jsr gameAliensKill
        jmp gAUCDone

gAUCDone
        rts

;==============================================================================

gameAliensKill
        ; run explosion animation
        LIBSPRITE_PLAYANIM_AVVVV      aliensSprite, AliensExplode, FinishExplode, 1, False
        LIBSPRITE_SETCOLOR_AV         aliensSprite, Yellow

        ; play explosion sound
        LIBSOUND_PLAY_VAA 2, soundExplosionHigh, soundExplosionLow

        ; don't increase score when the player dies together
        lda playerWillDie
        bne gAKDone

        jsr gameFlowIncreaseScore

gAKDone

        lda #False
        sta aliensActive

        rts

;==============================================================================

gameAliensSetVariables
        ldx aliensTemp ; restore X register as it gets trashed

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
        lda aliensFrame
        cmp #AlienRed
        beq gAUIRed
        lda #Green
        jmp gAUISetSprite

gAUIRed
        lda #LightRed

gAUISetSprite
        sta aliensColor

        lda #0
        sta aliensRespawn
        lda #AliensYStart
        sta aliensY

        LIBSPRITE_STOPANIM_A            aliensSprite
        LIBSPRITE_ENABLE_AV             aliensSprite, True
        LIBSPRITE_SETFRAME_AA           aliensSprite, aliensFrame
        LIBSPRITE_SETCOLOR_AA           aliensSprite, aliensColor
      
        lda #True
        sta aliensActive

        jsr gameAliensUpdatePosition

gAUIDontRespawn
        rts
