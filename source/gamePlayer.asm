;===============================================================================
;  gamePlayer.asm - Player ship control module
;
;  Copyright (C) 2017-2019 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
; Constants

ShieldSprite            = 0

StartExplode            = 22
FinishExplode           = 27
ShieldFirst             = 16
ShieldLast              = 19

PlayerStartX            = 86
PlayerStartY            = 220
PlayerXMin              = 22
PlayerXMax              = 150
PlayerYMin              = PlayerStartY
PlayerYMax              = PlayerStartY
PlayerMaxModels         = 5
PlayerVerticalSpeed     = 2
IntertiaSteps           = 5
Left                    = 1
Right                   = 2
ShieldMaxEnergy         = $9A   ; Handled as decimal

SizeX1                  = $07   ; offset for ship collision on the left
SizeX2                  = $0F   ; offset for ship collision on the right
ShieldX1                = $0D   ; offset for shield colision on the left
ShieldX2                = $1A   ; offset for shield colision on the right

SizeY1                  = PlayerStartY - 15 ; collision pos for ship top
SizeY2                  = PlayerStartY + 8  ; collision pos for ship top
ShieldY1                = PlayerStartY - 16 ; collision pos for shield top

StageEnd                = 1     ; Fly up at Stage End
GameEnd                 = 2     ; Fly up at Game End (Win Medal)
FlyUpWaitTime           = 2     ; Number of seconds to wait off screen

OldFaithful             = 0     ; Ship Model Constants
SturdyStriker           = 1
DynamicDestroyer        = 2
ArcedAssailant          = 3
RuthlessRetaliator      = 4

ShieldSlow              = 1
ShieldNormal            = 2
ShieldFast              = 3

ExplodeSprite           = AliensMax+4

;===============================================================================
; Page Zero

fullMode                = $30
collisionX1             = $31
collisionX2             = $32
collisionY1             = $33
collisionY2             = $34

playerActive            = $35
shieldActive            = $36
playerFlyUp             = $37
playerDirection         = $38
playerInertia           = $39
playerSpeed             = $3A

playerX                 = $3B
playerY                 = $3C
playerFrame             = $3D
playerSprite            = $3E
shieldEnergy            = $3F

shieldSpeed             = $19
shieldRecover           = $1A

;===============================================================================
; Variables
playerSpeedArray        byte 1, 1, 2, 2, 2
playerFrameArray        byte 0, 3, 6, 9, 12
playerFrameIndex        byte 0
playerColor             byte Cyan
playerXHigh             byte 0
playerXLow              byte 0
playerXChar             byte 0
playerXOffset           byte 0
playerYChar             byte 0
playerWillDie           byte False
shieldColor             byte LightBlue
shieldSpeedArray        byte ShieldSlow, ShieldNormal, ShieldNormal, ShieldFast
shieldY                 byte HideY
fullWaves               byte 2

;===============================================================================
; Macros/Subroutines

gamePlayerReset
        mva #True, playerActive
        lda #ShieldMaxEnergy
        sta shieldEnergy
        sta lastEnergy

        jsr gamePlayerSetupShield

        sta playerFlyUp
        sta playerInertia
        ; Debug: Full bulletsmode
if FULLBULLETS = 1
        lda #99
endif
        sta fullMode
        mva #AliensMax+1, playerSprite

        LIBMPLEX_SETFRAME_AA playerSprite, playerFrame
        LIBMPLEX_SETCOLOR_AA playerSprite, playerColor

        mva #PlayerStartX, playerX
        mva #PlayerStartY, playerY
        mva #SizeY1, collisionY1
        mva #SizeY2, collisionY2

        LIBMATH_ADD16BIT_VAVAAA 0, playerX, 0, playerX, playerXHigh, playerXLow
        LIBMPLEX_SETPOSITION_AAAA playerSprite, playerXHigh, playerXLow, playerY

        mva #HideY, shieldY
        mva #False, shieldActive
        jmp gameflowShieldGaugeFull

;===============================================================================

gamePlayerLoadConfig
        ldx playerFrameIndex
        lda playerFrameArray,X
        sta playerFrame
        lda playerSpeedArray,X
        sta playerSpeed
        cpx #SturdyStriker
        beq gPLCStableShield
        cpx #RuthlessRetaliator
        beq gPLCStableShield
        mva #ShieldSlow, shieldSpeedArray + 0
        mva #ShieldNormal, shieldSpeedArray + 1
        mva #ShieldNormal, shieldSpeedArray + 2
        mva #ShieldFast, shieldSpeedArray + 3
        jmp gPLCSetFullWaves

gPLCStableShield
        lda levelNum
        cmp #LevelNormal
        bcc gPLCSlow
        mva #ShieldNormal, shieldSpeed
        jmp gPLCSetArray

gPLCSlow
        mva #ShieldSlow, shieldSpeed

gPLCSetArray
        mva shieldSpeed, shieldSpeedArray + 0
        mva shieldSpeed, shieldSpeedArray + 1
        mva shieldSpeed, shieldSpeedArray + 2
        mva shieldSpeed, shieldSpeedArray + 3

gPLCSetFullWaves
        cpx #ArcedAssailant
        bcs gPLCMoreWaves
        mva #2, fullWaves
        jmp gPLCSetColors

gPLCMoreWaves
        mva #3, fullWaves

gPLCSetColors
        ldx shipColorIndex
        lda menuColorArray,X
        sta playerColor

        ldx shldColorIndex
        lda menuColorArray,X
        sta shieldColor
        rts

;===============================================================================

gamePlayerSetupShield
        LIBMPLEX_PLAYANIM_AVVVV  #ShieldSprite, ShieldFirst, ShieldLast, 5, True
        LIBMPLEX_SETCOLOR_AA         #ShieldSprite, shieldColor
        LIBMPLEX_MULTICOLORENABLE_AV #ShieldSprite, False
        rts

;===============================================================================

gamePlayerUpdate
        lda playerFlyUp
        bne gPUFlyUp

        jsr gamePlayerUpdatePosition
        jsr gamePlayerUpdateShieldEnergy

        ; Don't fire or check collisions every frame
        lda aliensStep
        bne gPUCollision

        jmp gamePlayerUpdateFiring

gPUCollision
        ; Debug: disable collision
if NOCOLLISION = 1
        jmp gPUDone
endif
        jsr gamePlayerUpdateAmmoCollisions
        lda playerActive
        beq gPUDone
        jmp gamePlayerUpdateSpriteCollisions

gPUFlyUp
        lda playerY
        cmp #PlayerStartY
        bne gamePlayerMoveUp

gPUEndFlyUp
        lda #False
        sta playerFlyUp

        lda flowStageCnt
        cmp #LastStageCnt+1
        bcs gPUEndGame

        mva cycles, time1
        mva saveWaveTime, time2
        mva saveBomberTime, bomberTime
        GAMESTARS_COPYMAPROW_V StageEndY
        jmp gPUDone

gPUEndGame
        mva #False, playerActive
        ldx levelNum      ; unlock medal
        lda unlockFlags
        ora medalLockMask,X
        sta unlockFlags
        inc medalUnlocked
        jmp gameFlowGameOver

gPUDone
        rts

;===============================================================================

gamePlayerMoveUp
        lda playerY
        cmp #PlayerStartY
        bcc gPMUFly
        lda time2
        beq gPMUEndWait
        jmp gameFlowDecreaseTime

gPMUEndWait
        lda playerFlyUp
        cmp #StageEnd
        beq gPMUGoBack
        jmp gPUEndFlyUp

gPMUGoBack
        mva #0, playerInertia
        mva #PlayerStartX, playerX

gPMUFly
        LIBMPLEX_SETFRAME_AA playerSprite, playerFrame
        LIBMATH_SUB8BIT_AVA playerY, PlayerVerticalSpeed, playerY

gPMUSkip
        mva #HideY, shieldY
        jmp gPUPSetNewPos

;===============================================================================

gamePlayerUpdateAmmoCollisions
        GAMEBULLETS_COLLIDED_DOWN_AAA playerXChar, playerXOffset, playerYChar
        beq gPUBCCheckBomb
        dec bulletsActiveDown
        lda shieldActive
        bne gPUBCCollectBullet
        jmp gamePlayerKilled

gPUBCCollectBullet
        LIBSOUND_PLAY_VAA CollectVoice, soundPickupHigh, soundPickupLow
        jmp gameFlowAddBullet

gPUBCCheckBomb
        GAMEBOMB_COLLIDED_DOWN_AA playerXChar, playerYChar
        bne gPUBCBombCollided
        rts

gPUBCBombCollided
        lda shieldActive
        bne gPUBCCollectBomb
        jmp gamePlayerKilled

gPUBCCollectBomb
        lda bombDropped
        cmp #BombPulsar
        beq gPUBCFullAmmo
        bcc gPUBCMissile
        jmp gamePlayerBounceBomb

gPUBCMissile
        LIBSOUND_PLAY_VAA CollectVoice, soundPickupHigh, soundPickupLow
        jmp gameFlowAddBomb

gPUBCFullAmmo
        mva fullWaves, fullMode
        LIBSOUND_PLAY_VAA CollectVoice, soundFullAmmoHigh, soundFullAmmoLow
        jmp gameFlowFullAmmoDisplay


;===============================================================================

gamePlayerBounceBomb
        ; check if bomb is active
        lda bombActiveUp
        bne gPBBNoBounce
        ; Bouncethe bomb
        GAMEBOMB_LAUNCH_UP_AAV playerXChar, playerYChar, BombBouncer
        ; play the firing sound
        LIBSOUND_PLAY_VAA FiringVoice, soundFiringHigh, soundFiringLow

gPBBNoBounce
        rts

;===============================================================================

gamePlayerUpdateSpriteCollisions
        lda #False
        sta playerWillDie
        sta aliensCollision

        ; check for collision with aliens
        ldx #$FF
        ldy #$00

gPUSCLoop
        inx
        cpx #AliensMax
        beq gPUSCDone
        iny
        lda aliensActiveArray,X
        beq gPUSCLoop
        lda sprxh,Y
        sta ZeroPageHigh
        lda sprxl,Y
        sta ZeroPageLow
        lsr ZeroPageHigh        ; divide by 2
        ror ZeroPageLow         ; unsigned 16bit

        lda ZeroPageLow
        cmp collisionX1
        bcc gPUSCLoop
        cmp collisionX2
        bcs gPUSCLoop
        lda aliensYArray,X
        cmp collisionY1
        bcc gPUSCLoop
        cmp collisionY2
        bcs gPUSCLoop

gPUSCHit
        sty aliensCollision
        sty aliensSprite
        lda aliensTypeArray,X
        cmp #AlienShooter
        beq gPUSCShield
        lda aliensStepArray,X   ; for probe or asteroid check if just
        cmp #2                  ; 1 more hit is needed to be destroyed  
        bcc gPUSCDie            ; by the shield otherwise player dies

gPUSCShield
        lda shieldActive
        beq gPUSCDie

gPUSCDone
        rts

gPUSCDie
        mva #True, playerWillDie
        jsr gameAliensKill
        ; gamePlayerKilled must be the next routine (don't move)

;===============================================================================

gamePlayerKilled
        mva #False, playerActive
        ; run explosion animation
        LIBMPLEX_MULTICOLORENABLE_AV #ShieldSprite, True
        LIBMPLEX_PLAYANIM_AVVVVV  #ShieldSprite, StartExplode, FinishExplode, 9, 5, False
        LIBMPLEX_SETCOLOR_AV      #ShieldSprite, Yellow
        LIBMPLEX_SETVERTICALTPOS_AA #ShieldSprite, #PlayerStartY-5

        LIBMPLEX_PLAYANIM_AVVVVV  playerSprite, StartExplode, FinishExplode, 9, 10, False
        LIBMPLEX_SETCOLOR_AV      playerSprite, LightRed

        LIBMPLEX_MULTICOLORENABLE_AV #ExplodeSprite, True
        LIBMPLEX_PLAYANIM_AVVVVV  #ExplodeSprite, StartExplode, FinishExplode, 7, 30, False
        LIBMPLEX_SETCOLOR_AV      #ExplodeSprite, Yellow
        LIBMPLEX_SETPOSITION_AAAA #ExplodeSprite, playerXHigh, playerXLow, #PlayerStartY+9
        ; play explosion sound
        jsr libSoundInit
        LIBSOUND_PLAY_VAA ExplosionVoice, soundExplosionHigh, soundExplosionLow

        jmp gameFlowGameOver

;===============================================================================

gamePlayerUpdateFiring
        ; do fire after the ship has been clamped to position
        ; so that the bullet lines up
        LIBINPUT_GETFIREPRESSED
        bne gamePlayerUpdateLaunch

        ; do not fire if the shield is up
        lda shieldActive
        bne gamePlayerUpdateLaunch

        ; check if in full bullets mode
        lda fullMode
        bne gPUFFire

        ; check if available bullets
        lda bullets
        beq gamePlayerUpdateLaunch

gPUFFire
        ; fire the bullet
        GAMEBULLETS_FIRE_UP_AAA playerXChar, playerXOffset, playerYChar
        cpx #BulletsMax
        beq gamePlayerUpdateLaunch

        ; play the firing sound
        LIBSOUND_PLAY_VAA FiringVoice, soundFiringHigh, soundFiringLow
        lda fullMode
        bne gamePlayerUpdateLaunch
        jsr gameFlowUseBullet
        ; the next routine must be gamePlayerUpdateLaunch (don't move)

;===============================================================================

gamePlayerUpdateLaunch
        LIBINPUT_GETHELD GameportUpMask
        beq gPULCheckBombs
        rts

gPULCheckBombs
        ; check if available bomb
        lda bombs
        bne gPULCheckActive
        rts

gPULCheckActive
        ; check if bomb is active
        lda bombActiveUp
        bne gPULNoLaunch
        ; launch the bomb
        GAMEBOMB_LAUNCH_UP_AAV playerXChar, playerYChar, BombMissile
        ; play the firing sound
        LIBSOUND_PLAY_VAA FiringVoice, soundFiringHigh, soundFiringLow
        jmp gameFlowUseBomb

gPULNoLaunch
        rts

;===============================================================================

gamePlayerUpdatePosition
        LIBINPUT_GETHELD GameportLeftMask
        bne gPUPRight
        LIBMATH_SUB8BIT_AAA playerX, playerSpeed, playerX
        mva #Left, playerDirection
        mva #IntertiaSteps, playerInertia
        jmp gPUPDown

gPUPRight
        LIBINPUT_GETHELD GameportRightMask
        bne gPUPInertia
        LIBMATH_ADD8BIT_AAA playerX, playerSpeed, playerX
        mva #Right, playerDirection
        mva #IntertiaSteps, playerInertia
        jmp gPUPDown

gPUPInertia
        lda playerInertia
        beq gPUPCenter
        dec playerInertia
        lda playerDirection
        cmp #Left
        beq gPUPInertiaLeft
        inc playerX
        jmp gPUPDown

gPUPInertiaLeft
        dec playerX
        jmp gPUPDown

gPUPCenter
        mva #0, playerDirection

gPUPDown
        LIBMATH_ADD8BIT_AAA playerFrame, playerDirection, ZeroPageTemp
        LIBMPLEX_SETFRAME_AA playerSprite, ZeroPageTemp

        LIBINPUT_GETHELD GameportDownMask
        bne gPUPNoShield ;down not pressed, disable shield
        lda shieldEnergy
        beq gPUPNoShield ;no energy, disable shield
        lda shieldActive
        bne gPUPWithShield
        mva #True, shieldActive
        mva #PlayerStartY-1, shieldY

gPUPWithShield
        ; update horizontal collision params with shield sizes
        lda playerX
        sec
        sbc #ShieldX1
        sta collisionX1
        clc
        adc #ShieldX2
        sta collisionX2
        mva #ShieldY1, collisionY1
        jmp gPUPEndmove

gPUPNoShield
        ; update horizontal collision params with ship sizes
        lda playerX
        sec
        sbc #SizeX1
        sta collisionX1
        clc
        adc #SizeX2
        sta collisionX2
        mva #SizeY1, collisionY1
        ; hide shield if active
        lda shieldActive
        beq gPUPEndmove
        mva #False, shieldActive
        mva #HideY, shieldY

gPUPEndmove
        ; clamp the player x position
        LIBMATH_MIN8BIT_AV playerX, PlayerXMax
        LIBMATH_MAX8BIT_AV playerX, PlayerXMin

gPUPSetNewPos
        ; update the player char positions
        LIBMATH_ADD16BIT_VAVAAA 0, playerX, 0, playerX, playerXHigh, playerXLow
        LIBSCREEN_PIXELTOCHAR_AAVAVAAA playerXHigh, playerXLow, 12, playerY, 40, playerXChar, playerXOffset, playerYChar

        ; set the sprite position
        LIBMPLEX_SETPOSITION_AAAA playerSprite, playerXHigh, playerXLow, playerY
        LIBMPLEX_SETPOSITION_AAAA #ShieldSprite, playerXHigh, playerXLow, shieldY
        rts

;===============================================================================

gamePlayerUpdateShieldEnergy
        LIBINPUT_GETHELD GameportDownMask
        beq gPISEConsumeEnergy

gPISERecoverEnergy        
        lda shieldEnergy
        clc
        adc shieldRecover
        cmp #ShieldMaxEnergy
        bcs gPISEMax
        sta shieldEnergy
        jmp gameFlowUpdateGauge

gPISEConsumeEnergy
        lda shieldEnergy
        cmp shieldSpeed
        bcc gPISEMin
        sec
        sbc shieldSpeed
        sta shieldEnergy
        jmp gameFlowUpdateGauge

gPISEMin
        mva #0, shieldEnergy
        jmp gameFlowUpdateGauge

gPISEMax
        mva #ShieldMaxEnergy, shieldEnergy
        jmp gameFlowUpdateGauge

;===============================================================================

gamePlayerSpriteSwap
        ldy shieldOrder
        ldx playerOrder

        ; Setup Multicolor
        lda sortsprm,y
        bne lSSDone     ; don't swap if sprite 0 is multicolor
        lda #True
        sta sortsprm,y
        lda #False
        sta sortsprm,x
        ; Swap frames
        lda sortsprf,y
        sta temp1
        lda sortsprf,x
        sta sortsprf,y
        lda temp1
        sta sortsprf,x
        ; Setup Y
        lda #PlayerStartY
        sta sortspry,y
        lda #PlayerStartY-1
        sta sortspry,x
        ; Setup Player Color
        lda sortsprc,y
        bmi lSSPlayerEndMark
        lda playerColor
        jmp lSSPlayerColor
lSSPlayerEndMark
        lda playerColor
        ora #$80
lSSPlayerColor
        sta sortsprc,y

        ; Setup Player Color
        lda sortsprc,x
        bmi lSSShieldEndMark
        lda shieldColor
        jmp lSSShieldColor
lSSShieldEndMark
        lda shieldColor
        ora #$80
lSSShieldColor
        sta sortsprc,x
lSSDone
        rts
