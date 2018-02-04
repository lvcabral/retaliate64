;===============================================================================
;  gamePlayer.asm - Player ship control module
;
;  Copyright (C) 2017,2018 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;==============================================================================
; Constants

ShieldFirst             = 1
ShieldLast              = 4
PlayerExplode           = 7
FinishExplode           = 18
PlayerHorizontalSpeed   = 2
PlayerVerticalSpeed     = 1
PlayerStartXHigh        = 0
PlayerStartXLow         = 175
PlayerStartY            = 220
PlayerXMinHigh          = 0     ; Reduced X range to increase difficulty
PlayerXMinLow           = 48
PlayerXMaxHigh          = 1     ; Reduced X range to increase difficulty
PlayerXMaxLow           = 40
PlayerYMin              = 220
PlayerYMax              = 220
PlayerMaxModels         = 5
ShieldMaxEnergy         = $9A   ; Handled as decimal

;===============================================================================
; Variables

playerFrameArray        byte 0, 26, 27, 28, 29
playerFrameIndex        byte 0
playerFrame             byte 0
playerColor             byte Red
playerSprite            byte 7
shieldSprite            byte 0
playerXHigh             byte PlayerStartXHigh
playerXLow              byte PlayerStartXLow
playerY                 byte PlayerStartY
playerXChar             byte 0
playerXOffset           byte 0
playerYChar             byte 0
playerYOffset           byte 0
playerActive            byte False
playerWillDie           byte False
shieldActive            byte False
shieldColor             byte LightBlue
shieldEnergy            byte ShieldMaxEnergy
shieldSpeedArray        byte 1, 2, 3
shieldSpeed             byte 2

;===============================================================================
; Macros/Subroutines

gamePlayerInit
        
        LIBSPRITE_MULTICOLORENABLE_AV   playerSprite, True
        
        rts

;==============================================================================

gamePlayerReset

        lda #True
        sta playerActive
        lda #ShieldMaxEnergy
        sta shieldEnergy

        jsr gamePlayerLoadConfig
        jsr gamePlayerSetupShield

        LIBSPRITE_ENABLE_AV             playerSprite, True
        LIBSPRITE_SETFRAME_AA           playerSprite, playerFrame
        LIBSPRITE_SETCOLOR_AA           playerSprite, playerColor

        lda #PlayerStartXHigh
        sta playerXHigh
        lda #PlayerStartXLow
        sta PlayerXLow
        lda #PlayerStartY
        sta PlayerY
        LIBSPRITE_SETPOSITION_AAAA playerSprite, playerXHigh, playerXLow, playerY
        LIBSPRITE_SETPOSITION_AAAA shieldSprite, playerXHigh, playerXLow, playerY
        LIBSPRITE_DIDCOLLIDEWITHSPRITE_A playerSprite ; clear collision flag

        lda 0
        sta lastEnergy
        sta shieldActive

        jsr gameFlowUpdateGauge

        rts


;===============================================================================
gamePlayerLoadConfig
        ldx playerFrameIndex
        lda playerFrameArray,X
        sta playerFrame

        ldx shipColorIndex
        lda menuColorArray,X
        sta playerColor

        ldx shldColorIndex
        lda menuColorArray,X
        sta shieldColor
        rts

;===============================================================================
gamePlayerSetupShield
        LIBSPRITE_ENABLE_AV             shieldSprite, False
        LIBSPRITE_PLAYANIM_AVVVV        shieldSprite, ShieldFirst, ShieldLast, 5, True
        LIBSPRITE_SETCOLOR_AA           shieldSprite, shieldColor
        LIBSPRITE_MULTICOLORENABLE_AV   shieldSprite, False
        rts

;===============================================================================
gamePlayerUpdate

        lda playerActive
        beq gPUSkip

        jsr gamePlayerUpdatePosition
        jsr gamePlayerUpdateShieldEnergy
        jsr gamePlayerUpdateFiring
        jsr gamePlayerUpdateBulletCollisions
        lda playerActive
        beq gPUSkip

        jsr gamePlayerUpdateSpriteCollisions

gPUSkip

        rts

;==============================================================================

gamePlayerUpdateSpriteCollisions

        lda #False
        sta playerWillDie

        LIBSPRITE_DIDCOLLIDEWITHSPRITE_A playerSprite
        beq gPUSCNoCollide

        lda spriteLastCollision
        sta aliensCollision

        lda shieldActive
        bne gPUSCNoCollide

        lda #True
        sta playerWillDie

        jsr gameAliensUpdate ; make the alien to explode
        jsr gamePlayerKilled

gPUSCNoCollide
        rts

;==============================================================================

gamePlayerUpdateBulletCollisions

        GAMEBULLETS_COLLIDED playerXChar, playerYChar, False
        beq gPUBCReturn

        lda shieldActive
        bne gPUBCCollectBullet

        jsr gamePlayerKilled
        jmp gPUBCReturn

gPUBCCollectBullet
        jsr gamePlayerCollectBullet
        
gPUBCReturn
        rts

;==============================================================================

gamePlayerKilled
        lda #False
        sta playerActive
        ; run explosion animation
        LIBSPRITE_SETCOLOR_AV     playerSprite, Yellow
        LIBSPRITE_PLAYANIM_AVVVV  playerSprite, PlayerExplode, FinishExplode, 3, False

        LIBSPRITE_ENABLE_AV       shieldSprite, False

        ; play explosion sound
        jsr libSoundInit
        LIBSOUND_PLAY_VAA 1, soundExplosionHigh, soundExplosionLow

        jsr gameFlowPlayerDied

        rts
;==============================================================================

gamePlayerCollectBullet
        ; play explosion sound
        LIBSOUND_PLAY_VAA 1, soundPickupHigh, soundPickupLow

        jsr gameFlowAddBullet
        rts
;==============================================================================

gamePlayerUpdateFiring

        ; do fire after the ship has been clamped to position
        ; so that the bullet lines up
        LIBINPUT_GETFIREPRESSED
        bne gPUFNofire

        ; do not fire if the shield is up
        lda shieldActive
        bne gPUFNofire

        ; check if available bullets
        lda bullets
        beq gPUFNofire

        ; fire the bullet
        GAMEBULLETS_FIRE_AAAVV playerXChar, playerXOffset, playerYChar, Yellow, 1

        ; play the firing sound
        LIBSOUND_PLAY_VAA 1, soundFiringHigh, soundFiringLow

        jsr gameFlowUseBullet

gPUFNofire

        rts

;===============================================================================

gamePlayerUpdatePosition

        LIBINPUT_GETHELD GameportLeftMask
        bne gPUPRight
        LIBMATH_SUB16BIT_AAVVAA playerXHigh, PlayerXLow, 0, PlayerHorizontalSpeed, playerXHigh, PlayerXLow
gPUPRight
        LIBINPUT_GETHELD GameportRightMask
        bne gPUPDown
        LIBMATH_ADD16BIT_AAVVAA playerXHigh, PlayerXLow, 0, PlayerHorizontalSpeed, playerXHigh, PlayerXLow
gPUPDown
        LIBINPUT_GETHELD GameportDownMask
        bne gPUPNoShield ;down not pressed, disable shield
        lda shieldEnergy
        beq gPUPNoShield ;no energy, disable shield
        lda shieldActive
        bne gPUPEndmove
        lda #True
        sta shieldActive
        LIBSPRITE_ENABLE_AV shieldSprite, True
        jmp gPUPEndmove
gPUPNoShield
        lda shieldActive
        beq gPUPEndmove
        lda #False
        sta shieldActive
        LIBSPRITE_ENABLE_AV shieldSprite, False
        LIBSPRITE_DIDCOLLIDEWITHSPRITE_A playerSprite ; clear collision flag
gPUPEndmove
        
        ; clamp the player x position
        LIBMATH_MIN16BIT_AAVV playerXHigh, playerXLow, PlayerXMaxHigh, PLayerXMaxLow
        LIBMATH_MAX16BIT_AAVV playerXHigh, playerXLow, PlayerXMinHigh, PLayerXMinLow
        
        ; clamp the player y position
        LIBMATH_MIN8BIT_AV playerY, PlayerYMax
        LIBMATH_MAX8BIT_AV playerY, PlayerYMin

        ; set the sprite position
        LIBSPRITE_SETPOSITION_AAAA playerSprite, playerXHigh, PlayerXLow, PlayerY
        LIBSPRITE_SETPOSITION_AAAA shieldSprite, playerXHigh, PlayerXLow, PlayerY

        ; update the player char positions
        LIBSCREEN_PIXELTOCHAR_AAVAVAAAA playerXHigh, playerXLow, 12, playerY, 40, playerXChar, playerXOffset, playerYChar, playerYOffset

        rts

;===============================================================================

gamePlayerUpdateShieldEnergy

        LIBINPUT_GETHELD GameportDownMask
        beq gPISEConsumeEnergy
gPISERecoverEnergy        
        lda shieldEnergy
        cmp #ShieldMaxEnergy
        bcs gPISEMax
        clc
        adc shieldSpeed
        sta shieldEnergy
        jmp gPISECUpdate
gPISEConsumeEnergy
        lda shieldEnergy
        cmp shieldSpeed
        bcc gPISEMin
        sec
        sbc shieldSpeed
        sta shieldEnergy
        jmp gPISECUpdate
gPISEMin
        lda #0
        sta shieldEnergy
        jmp gPISECUpdate
gPISEMax
        lda #ShieldMaxEnergy
        sta shieldEnergy
gPISECUpdate
        jsr gameFlowUpdateGauge
        rts
