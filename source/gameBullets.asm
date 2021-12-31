;===============================================================================
;  gameBullets.asm - Bullets control module
;
;  Copyright (C) 2017-2021 Marcelo Lv Cabral - <https://lvcabral.com>
;  Copyright (C) 2017 RetroGameDev - <https://www.retrogamedev.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
; Constants

BulletsMax          = 12
BulletsAliens       = 10
Bullet1stCharDown   = 112
Bullet1stCharUp     = 120
BulletLeftOffset    = 3
BulletRightOffset   = 5
BulletLeftEdge      = Bullet1stCharDown + BulletLeftOffset
BulletRightEdge     = Bullet1stCharDown + BulletRightOffset
BulletFlameOffset   = 16
BulletColor         = Yellow

;===============================================================================
; Page Zero

ammoXCharCol        = $7E
ammoXOffsetCol      = $7F
ammoYCharCol        = $80

ammoXCharCurrent    = $81
ammoXOffsetCurrent  = $82
ammoYCharCurrent    = $83
ammoCharCurrent     = $84
ammoColorCurrent    = $85

bulletsDirCurrent   = $86
bulletsDirCol       = $87
bulletsUpdCnt       = $88
bulletsIndex        = $89
bulletsActiveTotal  = $8A
bulletsActiveUp     = $8B
bulletsActiveDown   = $8C

;===============================================================================
; Variables

bulletsActive       dcb BulletsMax, 0
bulletsXChar        dcb BulletsMax, 0
bulletsYChar        dcb BulletsMax, 0
bulletsXOffset      dcb BulletsMax, 0
bulletsDir          dcb BulletsMax, 0

bulletSpeedArray    byte 3, 4, 4, 6  ; 12/3=4(slow) 12/4=3(medium) 12/6=2(fast)
bulletSpeed         byte 0

;===============================================================================
; Macros/Subroutines

defm    GAMEBULLETS_FIRE_UP_AAA      ; /1 = XChar            (Address)
                                     ; /2 = XOffset          (Address)
                                     ; /3 = YChar            (Address)
        ldx #0
@loop
        lda bulletsActive,X
        bne @skip

        ; save the current bullet in the list
        lda #1
        sta bulletsActive,X
        lda /1
        sta bulletsXChar,X
        
        clc
        lda /2                  ; get the character offset
        adc #Bullet1stCharUp    ; add on the bullet first character
        sta bulletsXOffset,X

        lda /3
        sta bulletsYChar,X

        lda #True
        sta bulletsDir,X

        ; found a slot, quit the loop
        inc bulletsActiveUp
        inc bulletsActiveTotal
        jmp @found
@skip
        ; loop for each bullet
        inx
        cpx #BulletsMax
        bne @loop
@found
        endm

;===============================================================================

defm    GAMEBULLETS_FIRE_DOWN_AAA    ; /1 = XChar            (Address)
                                     ; /2 = XOffset          (Address)
                                     ; /3 = YChar            (Address)
        ldx #0
@loop
        lda bulletsActive,X
        bne @skip

        ; save the current bullet in the list
        lda #1
        sta bulletsActive,X
        lda /1
        sta bulletsXChar,X

        clc
        lda /2                  ; get the character offset
        adc #Bullet1stCharDown  ; add on the bullet first character
        sta bulletsXOffset,X

        lda /3
        sta bulletsYChar,X

        lda #False
        sta bulletsDir,X

        ; found a slot, quit the loop
        inc bulletsActiveDown
        inc bulletsActiveTotal
        jmp @found
@skip
        ; loop for each bullet
        inx
        cpx #BulletsMax
        bne @loop
@found
        endm


;===============================================================================

defm    GAMEBULLETS_COLLIDED_UP_AA      ; /1 = XChar (Address)
                                        ; /2 = YChar (Address)
        lda bulletsActiveUp
        beq @exit

        lda #True
        sta bulletsDirCol
        lda /1
        sta ammoXCharCol
        lda /2
        sta ammoYCharCol
        jsr gameBulletsCollided
@exit
        endm

;===============================================================================

defm    GAMEBULLETS_COLLIDED_DOWN_AAA    ; /1 = XChar   (Address)
                                         ; /2 = XOffset (Address)
                                         ; /3 = YChar   (Address)
        lda bulletsActiveDown
        beq @exit
        lda #False
        sta bulletsDirCol
        lda /1
        sta ammoXCharCol
        lda /3
        sta ammoYCharCol
        lda shieldActive
        beq @offset
        jsr gameBulletsCollided
        jmp @exit
@offset
        lda /2
        sta ammoXOffsetCol
        jsr gameBulletsCollidedOffset
@exit
        endm

;==============================================================================

gameBulletsReset
        ldx #0

gBRLoop
        lda bulletsActive,x
        beq gBRSkip

        ; remove the bullet from the screen
        jsr gameBulletsGet
        jsr gameAmmoClear

        lda #0
        sta bulletsActive,x

gBRSkip
        inx
        cpx #BulletsMax
        bne gBRLoop       ; loop for each bullet
        sta bulletsActiveUp
        sta bulletsActiveDown
        sta bulletsActiveTotal
        sta bulletsIndex
        sta bulletsUpdCnt
        rts

;===============================================================================

gameBulletsUpdate
        lda bulletsActiveTotal
        bne gBUStart
        rts
gBUStart
        ldx bulletsIndex

gBULoop
        lda bulletsActive,X
        bne gBUOk
        jmp gBUNext

gBUOk
        ; get the current bullet from the list
        jsr gameBulletsGet
        lda bulletsDirCurrent
        beq gBUDown

gBUUp
        ldy ammoYCharCurrent
        dey
        sty ammoYCharCurrent
        ; this leave a row empty at the top for the scores
        bne gBUDraw
        dec bulletsActiveUp
        jmp gBUDone

gBUDown
        ldy ammoYCharCurrent
        iny
        sty ammoYCharCurrent
        ; Ignore the bottom row to not erase the gauge and ammo
        cpy #StatusY
        bne gBUDraw
        dec bulletsActiveDown

gBUDone
        lda #0
        sta bulletsActive,X
        dec bulletsActiveTotal
        jmp gBUNext

gBUDraw
        ; set the bullet color
        LIBSCREEN_SETCOLORPOSITION_AA ammoXCharCurrent, ammoYCharCurrent
        LIBSCREEN_SETCHAR_V BulletColor
        
        ; set the bullet character
        LIBSCREEN_SETCHARPOSITION_AA ammoXCharCurrent, ammoYCharCurrent
        LIBSCREEN_SETCHAR_A ammoXOffsetCurrent

        lda ammoYCharCurrent
        sta bulletsYChar,X

gBUNext
        inx
        cpx #BulletsMax
        bcs gBUZero
        inc bulletsUpdCnt
        lda bulletsUpdCnt
        cmp bulletSpeed
        bcc gBULoop
        jmp gBUFinish

gBUZero
        ldx #0

gBUFinish
        stx bulletsIndex
        mva #0, bulletsUpdCnt
        rts

;===============================================================================

gameBulletsGet
        lda bulletsDir,X
        sta bulletsDirCurrent
        lda bulletsXChar,X
        sta ammoXCharCurrent
        ldy bulletsXOffset,X
        sty ammoXOffsetCurrent
        lda bulletsYChar,X
        sta ammoYCharCurrent
        lsr A
        bcs gameAmmoClear

gBGEvenLine
        clc
        tya
        adc #BulletFlameOffset
        sta ammoXOffsetCurrent

;===============================================================================
; Don't move needs to be after gameBulletsGet
gameAmmoClear
        GAMESTARS_GETCOLOR_AAA ammoXCharCurrent, ammoYCharCurrent, ammoColorCurrent

        LIBSCREEN_SETCOLORPOSITION_AA ammoXCharCurrent, ammoYCharCurrent
        LIBSCREEN_SETCHAR_A ammoColorCurrent

        GAMESTARS_GETCHAR_AAA ammoXCharCurrent, ammoYCharCurrent, ammoCharCurrent

        LIBSCREEN_SETCHARPOSITION_AA ammoXCharCurrent, ammoYCharCurrent
        LIBSCREEN_SETCHAR_A ammoCharCurrent
        rts

;===============================================================================

gameBulletsCollided
        ldx #0
gBCLoop
        ; skip this bullet if not active
        lda bulletsActive,X
        beq gBCSkip

        ; skip if up/down not equal
        lda bulletsDir,X
        cmp bulletsDirCol
        bne gBCSkip

        ; skip if currentbullet YChar != YChar
        ldy bulletsYChar,X
        cpy ammoYCharCol
        beq gBCCheckX

gBCYMinus1
        ; skip if currentbullet YChar-1 != YChar
        dey
        cpy ammoYCharCol
        bne gBCSkip

gBCCheckX
        ; skip if currentbullet XChar != XChar
        ldy bulletsXChar,X
        cpy ammoXCharCol
        beq gBCCollided

gBCXMinus1
        ; skip if currentbullet XChar-1 != XChar
        dey
        cpy ammoXCharCol
        beq gBCCollided

gBCXPlus1
        ; skip if currentbullet XChar+1 != XChar
        iny
        iny
        cpy ammoXCharCol
        bne gBCSkip

gBCCollided
        lda #0
        sta bulletsActive,X ; disable bullet
        dec bulletsActiveTotal

        ; delete bullet from screen
        lda bulletsXChar,X
        sta ammoXCharCurrent
        lda bulletsYChar,X
        sta ammoYCharCurrent
        jsr gameAmmoClear
        ; set A to notify collision and return
        lda #True
        rts

gBCSkip
        ; loop for each bullet
        inx
        cpx #BulletsMax
        bne gBCLoop

        ; set as not collided
        lda #False
        rts

;===============================================================================

gameBulletsCollidedOffset
        ldx #0
gBCOLoop
        ; skip this bullet if not active
        lda bulletsActive,X
        beq gBCOSkip

        ; skip if up/down not equal
        lda bulletsDir,X
        cmp bulletsDirCol
        bne gBCOSkip

        ; skip if currentbullet YChar != YChar
        ldy bulletsYChar,X
        cpy ammoYCharCol
        beq gBCOCheckX

gBCOYMinus1
        ; skip if currentbullet YChar-1 != YChar
        dey
        cpy ammoYCharCol
        bne gBCOSkip

gBCOCheckX
        ; skip if currentbullet XChar != XChar
        ldy bulletsXChar,X
        cpy ammoXCharCol
        beq gBCOCollided

gBCOXMinus1
        ; skip if currentbullet XChar-1 != XChar
        dey
        cpy ammoXCharCol
        bne gBCOXPlus1
        lda ammoXOffsetCol
        cmp #BulletRightOffset
        bcs gBCOCollided
        lda bulletsXOffset,X
        cmp #BulletLeftEdge
        bcc gBCOCollided
        jmp gBCOSkip

gBCOXPlus1
        ; skip if currentbullet XChar+1 != XChar
        iny
        iny
        cpy ammoXCharCol
        bne gBCOSkip
        lda ammoXOffsetCol
        cmp #BulletLeftOffset
        bcc gBCOCollided
        lda bulletsXOffset,X
        cmp #BulletRightEdge
        bcc gBCOSkip

gBCOCollided
        lda #0
        sta bulletsActive,X ; disable bullet
        dec bulletsActiveTotal

        ; delete bullet from screen
        lda bulletsXChar,X
        sta ammoXCharCurrent
        lda bulletsYChar,X
        sta ammoYCharCurrent
        jsr gameAmmoClear
        ; set A to notify collision and return
        lda #True
        rts

gBCOSkip
        ; loop for each bullet
        inx
        cpx #BulletsMax
        bne gBCOLoop

        ; set as not collided
        lda #False
        rts
