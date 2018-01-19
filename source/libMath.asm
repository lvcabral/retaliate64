;===============================================================================
;  libMath.asm - Mathematics Macros
;
;  Copyright (C) 2017,2018 RetroGameDev - <https://www.retrogamedev.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
; Macros/Subroutines

defm    LIBMATH_ABS_AA  ; /1 = Number (Address)
                        ; /2 = Result (Address)
        lda /1
        bpl @positive
        eor #$FF        ; invert the bits
        sta /2
        inc /2          ; add 1 to give the two's compliment
        jmp @done
@positive
        sta /2
@done
        endm

;==============================================================================

defm    LIBMATH_ADD8BIT_AAA
                ; /1 = 1st Number (Address)
                ; /2 = 2nd Number (Address)
                ; /3 = Sum (Address)
        clc     ; Clear carry before add
        lda /1  ; Get first number
        adc /2 ; Add to second number
        sta /3  ; Store in sum
        endm

;==============================================================================

defm    LIBMATH_ADD8BIT_AVA
                ; /1 = 1st Number (Address)
                ; /2 = 2nd Number (Value)
                ; /3 = Sum (Address)
        clc     ; Clear carry before add
        lda /1  ; Get first number
        adc #/2 ; Add to second number
        sta /3  ; Store in sum
        endm

;==============================================================================

defm    LIBMATH_ADD16BIT_AAVAAA
                ; /1 = 1st Number High Byte (Address)
                ; /2 = 1st Number Low Byte (Address)
                ; /3 = 2nd Number High Byte (Value)
                ; /4 = 2nd Number Low Byte (Address)
                ; /5 = Sum High Byte (Address)
                ; /6 = Sum Low Byte (Address)
        clc     ; Clear carry before first add
        lda /2  ; Get LSB of first number
        adc /4  ; Add LSB of second number
        sta /6  ; Store in LSB of sum
        lda /1  ; Get MSB of first number
        adc #/3 ; Add carry and MSB of NUM2
        sta /5  ; Store sum in MSB of sum
        endm

;==============================================================================

defm    LIBMATH_ADD16BIT_AAVVAA
                ; /1 = 1st Number High Byte (Address)
                ; /2 = 1st Number Low Byte (Address)
                ; /3 = 2nd Number High Byte (Value)
                ; /4 = 2nd Number Low Byte (Value)
                ; /5 = Sum High Byte (Address)
                ; /6 = Sum Low Byte (Address)
        clc     ; Clear carry before first add
        lda /2  ; Get LSB of first number
        adc #/4 ; Add LSB of second number
        sta /6  ; Store in LSB of sum
        lda /1  ; Get MSB of first number
        adc #/3 ; Add carry and MSB of NUM2
        sta /5  ; Store sum in MSB of sum
        endm

;==============================================================================

defm    LIBMATH_MIN8BIT_AV      ; /1 = Number 1 (Address)
                                ; /2 = Number 2 (Value)
        
        lda #/2                 ; load Number 2
        cmp /1                  ; compare with Number 1
        bcs @skip               ; if Number 2 >= Number 1 then skip
        sta /1                  ; else replace Number1 with Number2
@skip
        endm

;==============================================================================

defm    LIBMATH_MAX8BIT_AV      ; /1 = Number 1 (Address)
                                ; /2 = Number 2 (Value)
        
        lda #/2                 ; load Number 2
        cmp /1                  ; compare with Number 1
        bcc @skip               ; if Number 2 < Number 1 then skip
        sta /1                  ; else replace Number1 with Number2
@skip
        endm

;==============================================================================

defm    LIBMATH_MIN16BIT_AAVV   ; /1 = Number 1 High (Address)
                                ; /2 = Number 1 Low (Address)
                                ; /3 = Number 2 High (Value)
                                ; /4 = Number 2 Low (Value)
        
        ; high byte
        lda /1                  ; load Number 1
        cmp #/3                 ; compare with Number 2
        bmi @skip               ; if Number 1 < Number 2 then skip
        lda #/3
        sta /1                  ; else replace Number1 with Number2

        ; low byte
        lda #/4                 ; load Number 2
        cmp /2                  ; compare with Number 1
        bcs @skip               ; if Number 2 >= Number 1 then skip
        sta /2                  ; else replace Number1 with Number2
@skip
        endm

;==============================================================================

defm    LIBMATH_MAX16BIT_AAVV   ; /1 = Number 1 High (Address)
                                ; /2 = Number 1 Low (Address)
                                ; /3 = Number 2 High (Value)
                                ; /4 = Number 2 Low (Value)
        
        ; high byte
        lda #/3                 ; load Number 2
        cmp /1                  ; compare with Number 1
        bcc @skip               ; if Number 2 < Number 1 then skip
        sta /1                  ; else replace Number1 with Number2

        ; low byte
        lda #/4                 ; load Number 2
        cmp /2                  ; compare with Number 1
        bcc @skip               ; if Number 2 < Number 1 then skip
        sta /2                  ; else replace Number1 with Number2

@skip
        endm

;==============================================================================

defm    LIBMATH_SUB8BIT_AAA
                ; /1 = 1st Number (Address)
                ; /2 = 2nd Number (Address)
                ; /3 = Sum (Address)
        sec     ; sec is the same as clear borrow
        lda /1  ; Get first number
        sbc /2  ; Subtract second number
        sta /3  ; Store in sum
        endm

;==============================================================================

defm    LIBMATH_SUB8BIT_AVA
                ; /1 = 1st Number (Address)
                ; /2 = 2nd Number (Value)
                ; /3 = Sum (Address)
        sec     ; sec is the same as clear borrow
        lda /1  ; Get first number
        sbc #/2 ; Subtract second number
        sta /3  ; Store in sum
        endm

;==============================================================================

defm    LIBMATH_SUB16BIT_AAVAAA
                ; /1 = 1st Number High Byte (Address)
                ; /2 = 1st Number Low Byte (Address)
                ; /3 = 2nd Number High Byte (Value)
                ; /4 = 2nd Number Low Byte (Address)
                ; /5 = Sum High Byte (Address)
                ; /6 = Sum Low Byte (Address)
        sec     ; sec is the same as clear borrow
        lda /2  ; Get LSB of first number
        sbc /4 ; Subtract LSB of second number
        sta /6  ; Store in LSB of sum
        lda /1  ; Get MSB of first number
        sbc #/3 ; Subtract borrow and MSB of NUM2
        sta /5  ; Store sum in MSB of sum
        endm

;==============================================================================

defm    LIBMATH_SUB16BIT_AAVVAA
                ; /1 = 1st Number High Byte (Address)
                ; /2 = 1st Number Low Byte (Address)
                ; /3 = 2nd Number High Byte (Value)
                ; /4 = 2nd Number Low Byte (Value)
                ; /5 = Sum High Byte (Address)
                ; /6 = Sum Low Byte (Address)
        sec     ; sec is the same as clear borrow
        lda /2  ; Get LSB of first number
        sbc #/4 ; Subtract LSB of second number
        sta /6  ; Store in LSB of sum
        lda /1  ; Get MSB of first number
        sbc #/3 ; Subtract borrow and MSB of NUM2
        sta /5  ; Store sum in MSB of sum
        endm
