;===============================================================================
;  libInput.asm - Keyboard and Joystick Macros
;
;  Copyright (C) 2017,2018 RetroGameDev - <https://www.retrogamedev.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
; Constants

 ; use joystick 2, change to CIAPRB for joystick 1
JoystickRegister        = CIAPRA

GameportUpMask          = %00000001
GameportDownMask        = %00000010
GameportLeftMask        = %00000100
GameportRightMask       = %00001000
GameportFireMask        = %00010000
FireDelayMax            = 30

;===============================================================================
; Variables

gameportLastFrame       byte 0
gameportThisFrame       byte 0
gameportDiff            byte 0
fireDelay               byte 0
fireBlip                byte 1 ; reversed logic to match other input

;===============================================================================
; Macros/Subroutines

defm    LIBINPUT_GETHELD ; (buttonMask)

        lda gameportThisFrame
        and #/1
        endm ; test with bne on return

;===============================================================================

defm    LIBINPUT_GETFIREPRESSED
     
        lda #1
        sta fireBlip ; clear Fire flag

        ; is fire held?
        lda gameportThisFrame
        and #GameportFireMask
        bne @notheld

@held
        ; is this 1st frame?
        lda gameportDiff
        and #GameportFireMask
        
        beq @notfirst
        lda #0
        sta fireBlip ; Fire

        ; reset delay
        lda #FireDelayMax
        sta fireDelay        
@notfirst

        ; is the delay zero?
        lda fireDelay
        bne @notheld
        lda #0
        sta fireBlip ; Fire
        ; reset delay
        lda #FireDelayMax
        sta fireDelay   
        
@notheld 
        lda fireBlip
        endm ; test with bne on return

;===============================================================================

libInputUpdate

        lda JoystickRegister
        sta GameportThisFrame

        eor GameportLastFrame
        sta GameportDiff

        
        lda FireDelay
        beq lIUDelayZero
        dec FireDelay
lIUDelayZero

        lda GameportThisFrame
        sta GameportLastFrame

        rts
