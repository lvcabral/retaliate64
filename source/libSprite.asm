;===============================================================================
;  libScreen.asm - VIC II Screen related Macros
;
;  Copyright (C) 2017,2018 RetroGameDev - <https://www.retrogamedev.com>
;  Copyright (C) 2017,2018 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
; Constants

SpriteAnimsMax = 8

;===============================================================================
; Variables

spriteAnimsActive       dcb SpriteAnimsMax, 0
spriteAnimsStartFrame   dcb SpriteAnimsMax, 0
spriteAnimsFrame        dcb SpriteAnimsMax, 0
spriteAnimsEndFrame     dcb SpriteAnimsMax, 0
spriteAnimsStopFrame    dcb SpriteAnimsMax, 0
spriteAnimsSpeed        dcb SpriteAnimsMax, 0
spriteAnimsDelay        dcb SpriteAnimsMax, 0
spriteAnimsLoop         dcb SpriteAnimsMax, 0

spriteAnimsCurrent       byte 0
spriteAnimsFrameCurrent  byte 0
spriteAnimsEndFrameCurrent  byte 0

spriteNumberMask  byte %00000001, %00000010, %00000100, %00001000
                  byte %00010000, %00100000, %01000000, %10000000
spriteLastCollision byte  0
;===============================================================================
; Macros/Subroutines


defm    LIBSPRITE_DIDCOLLIDEWITHSPRITE_A  ; /1 = Sprite Number (Address)
        lda SPSPCL
        sta spriteLastCollision

        ldy /1
        lda SpriteNumberMask,y
        and spriteLastCollision
        
        endm

;===============================================================================

defm    LIBSPRITE_ENABLE_AV                ; /1 = Sprite Number (Address)
                                           ; /2 = Enable/Disable (Value)
        ldy /1
        lda spriteNumberMask,y

        ldy #/2
        beq @disable
@enable
        ora SPENA ; merge with the current SpriteEnable register
        sta SPENA ; set the new value into the SpriteEnable register
        jmp @done
@disable
        eor #$FF ; get mask compliment
        and SPENA
        sta SPENA
@done
        endm

;===============================================================================

defm    LIBSPRITE_ENABLE_AA                ; /1 = Sprite Number (Address)
                                           ; /2 = Enable/Disable (Address)
        ldy /1
        lda spriteNumberMask,y

        ldy /2
        beq @disable
@enable
        ora SPENA ; merge with the current SpriteEnable register
        sta SPENA ; set the new value into the SpriteEnable register
        jmp @done
@disable
        eor #$FF ; get mask compliment
        and SPENA
        sta SPENA
@done
        endm

;==============================================================================

defm    LIBSPRITE_ISANIMPLAYING_A      ; /1 = Sprite Number    (Address)

        ldy /1
        lda spriteAnimsActive,y

        endm

;===============================================================================

defm    LIBSPRITE_MULTICOLORENABLE_AA    ; /1 = Sprite Number (Address)
                                         ; /2 = Enable/Disable (Address)
        ldy /1
        lda spriteNumberMask,y
        
        ldy /2
        beq @disable
@enable
        ora SPMC
        sta SPMC
        jmp @done 
@disable
        eor #$FF ; get mask compliment
        and SPMC
        sta SPMC
@done
        endm

;===============================================================================

defm    LIBSPRITE_MULTICOLORENABLE_AV   ; /1 = Sprite Number (Address)
                                        ; /2 = Enable/Disable (Value)
        ldy /1
        lda spriteNumberMask,y
        
        ldy #/2
        beq @disable
@enable
        ora SPMC
        sta SPMC
        jmp @done 
@disable
        eor #$FF ; get mask compliment
        and SPMC
        sta SPMC
@done
        endm

;==============================================================================

defm    LIBSPRITE_PLAYANIM_AVVVV        ; /1 = Sprite Number    (Address)
                                        ; /2 = StartFrame       (Value)
                                        ; /3 = EndFrame         (Value)
                                        ; /4 = Speed            (Value)
                                        ; /5 = Loop True/False  (Value)

        ldy /1

        lda #True
        sta spriteAnimsActive,y
        lda #/2
        sta spriteAnimsStartFrame,y
        sta spriteAnimsFrame,y
        lda #/3
        sta spriteAnimsEndFrame,y
        lda #/4
        sta spriteAnimsSpeed,y
        sta spriteAnimsDelay,y
        lda #/5
        sta spriteAnimsLoop,y

        endm

;===============================================================================

defm    LIBSPRITE_SETCOLOR_AV           ; /1 = Sprite Number    (Address)
                                        ; /2 = Color            (Value)
        ldy /1
        lda #/2
        sta SP0COL,y
        endm

;===============================================================================

defm    LIBSPRITE_SETCOLOR_AA           ; /1 = Sprite Number    (Address)
                                        ; /2 = Color            (Address)
        ldy /1
        lda /2
        sta SP0COL,y
        endm

;==============================================================================

defm    LIBSPRITE_SETFRAME_AA           ; /1 = Sprite Number    (Address)
                                        ; /2 = Anim Index       (Address)
        ldy /1
        
        clc     ; Clear carry before add
        lda /2  ; Get first number
        adc #SPRITERAM ; Add
         
        sta SPRITE0,y
        endm

;===============================================================================

defm    LIBSPRITE_SETFRAME_AV           ; /1 = Sprite Number    (Address)
                                        ; /2 = Anim Index       (Value)
        ldy /1
        
        clc     ; Clear carry before add
        lda #/2  ; Get first number
        adc #SPRITERAM ; Add
         
        sta SPRITE0,y
        endm

;===============================================================================

defm    LIBSPRITE_SETMULTICOLORS_VV     ; /1 = Color 1          (Value)
                                        ; /2 = Color 2          (Value)
        lda #/1
        sta SPMC0
        lda #/2
        sta SPMC1
        endm

;===============================================================================

defm    LIBSPRITE_SETPOSITION_AAAA      ; /1 = Sprite Number    (Address)
                                        ; /2 = XPos High Byte   (Address)
                                        ; /3 = XPos Low Byte    (Address)
                                        ; /4 = YPos             (Address)

        lda /1                  ; get sprite number
        asl                     ; *2 as registers laid out 2 apart
        tay                     ; copy accumulator to y register

        lda /3                  ; get XPos Low Byte
        sta SP0X,y              ; set the XPos sprite register
        lda /4                  ; get YPos
        sta SP0Y,y              ; set the YPos sprite register
        
        ldy /1
        lda spriteNumberMask,y  ; get sprite mask
        
        eor #$FF                ; get compliment
        and MSIGX               ; clear the bit
        sta MSIGX               ; and store

        ldy /2                  ; get XPos High Byte
        beq @end                ; skip if XPos High Byte is zero
        ldy /1
        lda spriteNumberMask,y  ; get sprite mask
        
        ora MSIGX               ; set the bit
        sta MSIGX               ; and store
@end
        endm

;===============================================================================

defm    LIBSPRITE_SETPOSITION_VAAA      ; /1 = Sprite Number    (Value)
                                        ; /2 = XPos High Byte   (Address)
                                        ; /3 = XPos Low Byte    (Address)
                                        ; /4 = YPos             (Address)

        ldy #/1*2               ; *2 as registers laid out 2 apart
        lda /3                  ; get XPos Low Byte
        sta SP0X,y              ; set the XPos sprite register
        lda /4                  ; get YPos
        sta SP0Y,y              ; set the YPos sprite register
        
        lda #1<<#/1             ; shift 1 into sprite bit position
        eor #$FF                ; get compliment
        and MSIGX               ; clear the bit
        sta MSIGX               ; and store

        ldy /2                  ; get XPos High Byte
        beq @end                ; skip if XPos High Byte is zero
        lda #1<<#/1             ; shift 1 into sprite bit position
        ora MSIGX               ; set the bit
        sta MSIGX               ; and store
@end
        endm

;===============================================================================

defm    LIBSPRITE_SETVERTICALTPOS_AA    ; /1 = Sprite Number    (Address)
                                        ; /2 = YPos             (Address)

        lda /1                  ; get sprite number
        asl                     ; *2 as registers laid out 2 apart
        tay                     ; copy accumulator to y register

        lda /2                  ; get YPos
        sta SP0Y,y              ; set the YPos sprite register
@end
        endm

;===============================================================================

defm    LIBSPRITE_SETPRIORITY_AV ; /1 = Sprite Number           (Address)
                                 ; /2 = True = Back, False = Front (Value)
        ldy /1
        lda spriteNumberMask,y
        
        ldy #/2
        beq @disable
@enable
        ora SPBGPR ; merge with the current SPBGPR register
        sta SPBGPR ; set the new value into the SPBGPR register
        jmp @done 
@disable
        eor #$FF ; get mask compliment
        and SPBGPR
        sta SPBGPR
@done
        endm

;===============================================================================

defm    LIBSPRITE_SETPRIORITY_AA ; /1 = Sprite Number           (Address)
                                 ; /2 = True = Back, False = Front (Address)
        ldy /1
        lda spriteNumberMask,y
        
        ldy /2
        beq @disable
@enable
        ora SPBGPR ; merge with the current SPBGPR register
        sta SPBGPR ; set the new value into the SPBGPR register
        jmp @done 
@disable
        eor #$FF ; get mask compliment
        and SPBGPR
        sta SPBGPR
@done
        endm

;==============================================================================

defm    LIBSPRITE_STOPANIM_A            ; /1 = Sprite Number    (Address)

        ldy /1
        lda #0
        sta spriteAnimsActive,y

        endm

;==============================================================================

libSpritesUpdate

        ldx #0
lSoULoop
        ; skip this sprite anim if not active
        lda spriteAnimsActive,X
        bne lSoUActive
        jmp lSoUSkip
lSoUActive

        stx spriteAnimsCurrent
        lda spriteAnimsFrame,X
        sta spriteAnimsFrameCurrent

        lda spriteAnimsEndFrame,X
        sta spriteAnimsEndFrameCurrent
        
        LIBSPRITE_SETFRAME_AA spriteAnimsCurrent, spriteAnimsFrameCurrent

        dec spriteAnimsDelay,X
        bne lSoUSkip

        ; reset the delay
        lda spriteAnimsSpeed,X
        sta spriteAnimsDelay,X

        ; change the frame
        inc spriteAnimsFrame,X
        
        ; check if reached the end frame
        lda spriteAnimsEndFrameCurrent
        cmp spriteAnimsFrame,X
        bcs lSoUSkip

        ; check if looping
        lda spriteAnimsLoop,X
        beq lSoUDestroy

        ; reset the frame
        lda spriteAnimsStartFrame,X
        sta spriteAnimsFrame,X
        jmp lSoUSkip

lSoUDestroy
        ; turn off
        lda #False
        sta spriteAnimsActive,X
        LIBSPRITE_ENABLE_AV spriteAnimsCurrent, False

lSoUSkip
        ; loop for each sprite anim
        inx
        cpx #SpriteAnimsMax
        ;bne lSUloop
        beq lSoUFinished
        jmp lSoUloop
lSoUFinished

        rts
