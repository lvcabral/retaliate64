;===============================================================================
;  libSprite.asm - VIC II Sprite related Macros and Routines
;
;  Copyright (C) 2017,2019 Marcelo Lv Cabral - <https://lvcabral.com>
;  Copyright (C) 2017,2018 RetroGameDev - <https://www.retrogamedev.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
; Variables

spriteId                   byte 0
spriteFrame                byte 0
spriteColor                byte 0
spriteMulticolor           byte 0
spriteX                    byte 0
spriteY                    byte 0

spriteNumberMask           byte %00000001, %00000010, %00000100, %00001000
                           byte %00010000, %00100000, %01000000, %10000000

spriteLastCollision        byte 0

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
                                        ; /2 = Frame Index       (Address)
        ldy /1
        
        clc     ; Clear carry before add
        lda /2  ; Get first number
        adc #SPRITERAM ; Add
         
        sta SPRITE0,y
        endm

;===============================================================================

defm    LIBSPRITE_SETFRAME_AV           ; /1 = Sprite Number    (Address)
                                        ; /2 = Frame Index       (Value)
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

defm    LIBSPRITE_SETPRIORITY_AV ; /1 = Sprite Number              (Address)
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

defm    LIBSPRITE_SETPRIORITY_AA ; /1 = Sprite Number              (Address)
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
