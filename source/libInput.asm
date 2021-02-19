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
FireDelayMax            = 15

; PETSCII Key Codes
KEY_BACK     = $5F
KEY_RETURN   = $0D
KEY_DEL      = $14
KEY_CLR      = $93
KEY_HOME     = $13
KEY_INST     = $94
KEY_SPACE    = $20
KEY_M        = $4D
KEY_S        = $53
KEY_F1       = $85
KEY_F2       = $89
KEY_F3       = $86
KEY_F4       = $8A
KEY_F5       = $87
KEY_F6       = $8B
KEY_F7       = $88
KEY_F8       = $8C
KEY_DOWN     = $11
KEY_UP       = $91
KEY_RIGHT    = $1D
KEY_LEFT     = $9D

;===============================================================================
; Variables

gameportLastFrame       byte 0
gameportThisFrame       byte 0
gameportDiff            byte 0
fireDelay               byte 0
fireBlip                byte 1 ; reversed logic to match other input
keyDown                 byte 0

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
        mva JoystickRegister, GameportThisFrame
        eor GameportLastFrame
        sta GameportDiff
        lda FireDelay
        beq lIUDelayZero
        dec FireDelay

lIUDelayZero
        mva GameportThisFrame, GameportLastFrame

        rts

;===============================================================================

libInputKeys
        mva #$00, CIDDRB        ; port b ddr (input)
        mva #$FF, CIDDRA        ; port a ddr (output)
        mva #%11101111, CIAPRA  ; Check M key
        lda CIAPRB
        cmp #$EF
        bne lIKSpace
        lda keyDown
        bne lIKPressed
        lda #KEY_M
        jmp lIKRetKey

lIKSpace
        mva #%01111111, CIAPRA  ; Check space bar
        lda CIAPRB
        cmp #$EF
        bne lIKNoKey
        lda keyDown
        bne lIKPressed
        lda #KEY_SPACE
        jmp lIKRetKey

lIKPressed
        ldx #$FF
        stx CIAPRA
        lda #0
        rts

lIKNoKey
        lda #0

lIKRetKey
        ldx #$FF
        stx CIAPRA
        sta keyDown
        rts
