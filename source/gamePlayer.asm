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
PlayerHorizontalSpeed   = 1
PlayerStartX            = 87
PlayerStartY            = 220
PlayerXMin              = 24    ; Reduced X range to increase difficulty
PlayerXMax              = 149   ; Reduced X range to increase difficulty
PlayerYMin              = 220
PlayerYMax              = 220
PlayerMaxModels         = 5
ShieldMaxEnergy         = $9A   ; Handled as decimal
SizeX1                  = $0A   ; The area of the drawn sprite on the left
SizeX2                  = $18   ; The area of the drawn sprite on the right
SizeY1                  = $10   ; The area of the drawn sprite at the top
SizeY2                  = $18   ; The area of the drawn sprite at the bottom

;===============================================================================
; Page Zero
collisionX1             = $31
collisionX2             = $32
collisionY1             = $33
collisionY2             = $34

playerActive            = $35
shieldActive            = $36

;===============================================================================
; Variables

playerFrameArray        byte 0, 26, 27, 28, 29
playerFrameIndex        byte 0
playerFrame             byte 0
playerColor             byte Red
playerSprite            byte 0
shieldSprite            byte 0
playerX                 byte PlayerStartX
playerY                 byte PlayerStartY
playerXHigh             byte 0
playerXLow              byte 0
playerXChar             byte 0
playerXOffset           byte 0
playerYChar             byte 0
playerWillDie           byte False
shieldColor             byte LightBlue
shieldEnergy            byte ShieldMaxEnergy
shieldSpeedArray        byte 1, 2, 3, 3
shieldSpeed             byte 0
shieldY                 byte 255

;===============================================================================
; Macros/Subroutines

gamePlayerReset
        lda #True
        sta playerActive
        lda #ShieldMaxEnergy
        sta shieldEnergy
        sta lastEnergy

        jsr gamePlayerLoadConfig
        jsr gamePlayerSetupShield

        lda #AliensMax + 1
        sta playerSprite

        LIBMPLEX_SETFRAME_AA playerSprite, playerFrame
        LIBMPLEX_SETCOLOR_AA playerSprite, playerColor

        lda #PlayerStartX
        sta playerX
        lda #PlayerStartY
        sta playerY
        sec
        sbc #SizeY1
        sta collisionY1
        clc
        adc #SizeY2
        sta collisionY2
        LIBMATH_ADD16BIT_VAVAAA 0, playerX, 0, playerX, playerXHigh, playerXLow
        LIBMPLEX_SETPOSITION_AAAA playerSprite, playerXHigh, playerXLow, playerY

        lda hideY
        sta shieldY
        lda #False
        sta shieldActive
        jsr gameflowShieldGaugeFull

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
        LIBSPRITE_PLAYANIM_AVVVV  shieldSprite, ShieldFirst, ShieldLast, 5, True
        LIBMPLEX_SETCOLOR_AA         shieldSprite, shieldColor
        LIBMPLEX_MULTICOLORENABLE_AV shieldSprite, False
        rts

;===============================================================================

gamePlayerUpdate
        lda playerActive
        beq gPUSkip

        jsr gamePlayerUpdatePosition
        jsr gamePlayerUpdateShieldEnergy
        jsr gamePlayerUpdateFiring

        ; Don't check collisions every frame
        lda aliensStep
        bne gPUSkip

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
        sta aliensCollision

        ; update horizontal collision params
        lda playerX
        sec
        sbc #SizeX1
        sta collisionX1
        clc
        adc #SizeX2
        sta collisionX2
        ; check for collision with aliens
        ldx #$FF

gPUSCLoop
        inx
        cpx #AliensMax
        beq gPUSCDone

        lda aliensActiveArray,X
        beq gPUSCLoop
        lda aliensXArray,X
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
        inx
        stx aliensCollision
        stx aliensSprite
        lda shieldActive
        bne gPUSCDone
        lda #True
        sta playerWillDie
        jsr gameAliensKill
        jsr gamePlayerKilled

gPUSCDone
        rts

;==============================================================================

gamePlayerUpdateBulletCollisions
        GAMEBULLETS_COLLIDED_DOWN_AA playerXChar, playerYChar
        beq gPUBCReturn
        dec bulletsActiveDown
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
        LIBSPRITE_PLAYANIM_AVVVV  playerSprite, PlayerExplode, FinishExplode, 3, False
        LIBMPLEX_SETCOLOR_AV      playerSprite, Yellow
        LIBMPLEX_SETPOSITION_AAAA shieldSprite, #0, playerX, hideY

        ; play explosion sound
        jsr libSoundInit
        LIBSOUND_PLAY_VAA SoundVoice, soundExplosionHigh, soundExplosionLow

        jsr gameFlowPlayerDied
        rts

;==============================================================================

gamePlayerCollectBullet
        ; play explosion sound
        LIBSOUND_PLAY_VAA SoundVoice, soundPickupHigh, soundPickupLow

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
        GAMEBULLETS_FIRE_UP_AAA playerXChar, playerXOffset, playerYChar
        cpx #BulletsMax
        beq gPUFNofire

        ; play the firing sound
        LIBSOUND_PLAY_VAA SoundVoice, soundFiringHigh, soundFiringLow

        jsr gameFlowUseBullet

gPUFNofire
        rts

;===============================================================================

gamePlayerUpdatePosition
        LIBINPUT_GETHELD GameportLeftMask
        bne gPUPRight
        LIBMATH_SUB8BIT_AVA playerX, PlayerHorizontalSpeed, playerX

gPUPRight
        LIBINPUT_GETHELD GameportRightMask
        bne gPUPDown
        LIBMATH_ADD8BIT_AVA playerX, PlayerHorizontalSpeed, playerX

gPUPDown
        LIBINPUT_GETHELD GameportDownMask
        bne gPUPNoShield ;down not pressed, disable shield
        lda shieldEnergy
        beq gPUPNoShield ;no energy, disable shield
        lda shieldActive
        bne gPUPEndmove
        lda #True
        sta shieldActive
        lda #PlayerStartY-1
        sta shieldY
        jmp gPUPEndmove

gPUPNoShield
        lda shieldActive
        beq gPUPEndmove
        lda #False
        sta shieldActive
        lda hideY
        sta shieldY

gPUPEndmove
        ; clamp the player x position
        LIBMATH_MIN8BIT_AV playerX, PlayerXMax
        LIBMATH_MAX8BIT_AV playerX, PlayerXMin

        ; update the player char positions
        LIBMATH_ADD16BIT_VAVAAA 0, playerX, 0, playerX, playerXHigh, playerXLow
        LIBSCREEN_PIXELTOCHAR_AAVAVAAA playerXHigh, playerXLow, 12, playerY, 40, playerXChar, playerXOffset, playerYChar

        ; set the sprite position
        LIBMPLEX_SETPOSITION_AAAA playerSprite, playerXHigh, playerXLow, playerY
        LIBMPLEX_SETPOSITION_AAAA shieldSprite, playerXHigh, playerXLow, shieldY

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
