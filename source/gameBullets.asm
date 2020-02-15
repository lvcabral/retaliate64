;===============================================================================
;  gameBullets.asm - Bullets control module
;
;  Copyright (C) 2017,2018 RetroGameDev - <https://www.retrogamedev.com>
;  Copyright (C) 2017,2018 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
; Constants

BulletsMax              = 12
BulletsAliens           = 10
Bullet1stCharDown       = 64
Bullet1stCharUp         = 72
BulletFlameOffset       = 89

;===============================================================================
; Page Zero

bulletsXCharCol         = $7E
bulletsYCharCol         = $7F

bulletsXCharCurrent     = $80
bulletsXOffsetCurrent   = $81
bulletsYCharCurrent     = $82
bulletsCharCurrent      = $83
bulletsColorCurrent     = $84
bulletsDirCurrent       = $85
bulletsXFlag            = $86
bulletsDirCol           = $87
bulletsUpdCnt           = $88
bulletsIndex            = $89
bulletsActiveTotal      = $8A
bulletsActiveUp         = $8B
bulletsActiveDown       = $8C

;===============================================================================
; Variables

bulletsActive           dcb BulletsMax, 0
bulletsXChar            dcb BulletsMax, 0
bulletsYChar            dcb BulletsMax, 0
bulletsXOffset          dcb BulletsMax, 0
bulletsDir              dcb BulletsMax, 0

bulletSpeedArray        byte 3, 4, 4, 6    ; 12/4=3 (slower) 12/6=2 (faster)
bulletSpeed             byte 0

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
gameBulletsGet
        lda bulletsDir,X
        sta bulletsDirCurrent
        lda bulletsXChar,X
        sta bulletsXCharCurrent
        ldy bulletsXOffset,X
        sty bulletsXOffsetCurrent
        lda bulletsYChar,X
        sta bulletsYCharCurrent
        lsr A
        bcc gBGEvenLine
        jmp gBGDone
gBGEvenLine
        clc
        tya
        adc #BulletFlameOffset
        sta bulletsXOffsetCurrent
gBGDone
        rts

;==============================================================================
gameBulletsReset

        ldx #0

gBRLoop
        lda bulletsActive,x
        beq gBRSkip

        ; remove the bullet from the screen
        jsr gameBulletsGet
        jsr gameBulletsClear

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
        ldx bulletsIndex

buloop
        lda bulletsActive,X
        bne buok
        jmp skipBulletUpdate

buok
        ; get the current bullet from the list
        jsr gameBulletsGet
        jsr gameBulletsClear
        
        lda bulletsDirCurrent
        beq @down

@up
        ldy bulletsYCharCurrent
        dey
        sty bulletsYCharCurrent
        cpy #0; this leave a row empty at the top for the scores
        bne @draw
        dec bulletsActiveUp
        jmp @dirdone

@down
        ldy bulletsYCharCurrent
        iny
        sty bulletsYCharCurrent
        cpy #24; Ignore the bottom row to not erase the gauge and ammo
        bne @draw
        dec bulletsActiveDown

@dirdone
        lda #0
        sta bulletsActive,X
        dec bulletsActiveTotal
        jmp skipBulletUpdate        

@draw
        ; set the bullet color
        LIBSCREEN_SETCOLORPOSITION_AA bulletsXCharCurrent, bulletsYCharCurrent
        LIBSCREEN_SETCHAR_V Yellow
        
        ; set the bullet character
        LIBSCREEN_SETCHARPOSITION_AA bulletsXCharCurrent, bulletsYCharCurrent
        LIBSCREEN_SETCHAR_A bulletsXOffsetCurrent

        lda bulletsYCharCurrent
        sta bulletsYChar,X

skipBulletUpdate
        inx
        inc bulletsUpdCnt
        lda bulletsUpdCnt
        cmp bulletSpeed
        bcc buloop
        cpx #BulletsMax
        bcc finishBulletUpdate

countBulletUpdate
        ldx #0

finishBulletUpdate
        stx bulletsIndex
        lda #0
        sta bulletsUpdCnt
        rts

;===============================================================================
defm    GAMEBULLETS_COLLIDED_UP_AA      ; /1 = XChar (Address)
                                        ; /2 = YChar (Address)
        lda bulletsActiveUp
        beq @exit

        lda #True
        sta bulletsDirCol
        lda /1
        sta bulletsXCharCol
        lda /2
        sta bulletsYCharCol
        jsr gameBulletsCollided
@exit
        endm

;===============================================================================
defm    GAMEBULLETS_COLLIDED_DOWN_AA    ; /1 = XChar (Address)
                                        ; /2 = YChar (Address)
        lda bulletsActiveDown
        beq @exit

        lda #False
        sta bulletsDirCol
        lda /1
        sta bulletsXCharCol
        lda /2
        sta bulletsYCharCol
        jsr gameBulletsCollided
@exit
        endm

;===============================================================================
gameBulletsCollided

        ldx #0
@loop
        ; skip this bullet if not active
        lda bulletsActive,X
        beq @skip

        ; skip if up/down not equal
        lda bulletsDir,X
        cmp bulletsDirCol
        bne @skip

        ; skip if currentbullet YChar != YChar
        ldy bulletsYChar,X
        cpy bulletsYCharCol
        bne @yminus1
        jmp @checkx

@yminus1
        ; skip if currentbullet XChar-1 != XChar
        dey
        cpy bulletsYCharCol
        bne @skip

@checkx
        lda #0
        sta bulletsXFlag

        ; skip if currentbullet XChar != XChar
        ldy bulletsXChar,X
        cpy bulletsXCharCol
        bne @xminus1
        lda #1
        sta bulletsXFlag
        jmp @doneXCheck

@xminus1
        ; skip if currentbullet XChar-1 != XChar
        dey
        cpy bulletsXCharCol
        bne @xplus1
        lda #1
        sta bulletsXFlag
        jmp @doneXCheck
@xplus1
        ; skip if currentbullet XChar+1 != XChar
        iny
        iny
        cpy bulletsXCharCol
        bne @doneXCheck
        lda #1
        sta bulletsXFlag

@doneXCheck
        lda bulletsXFlag
        beq @skip
   
        ; collided
        lda #0
        sta bulletsActive,X ; disable bullet
        dec bulletsActiveTotal

        ; delete bullet from screen
        lda bulletsXChar,X
        sta bulletsXCharCurrent
        lda bulletsYChar,X
        sta bulletsYCharCurrent
        jsr gameBulletsClear
        lda #1 ; set as collided
        jmp @collided
@skip
        ; loop for each bullet
        inx
        cpx #BulletsMax
        bne @loop

        ; set as not collided
        lda #0

@collided

        rts

;===============================================================================
gameBulletsClear
        GAMESTARS_GETCOLOR_AAA bulletsXCharCurrent, bulletsYCharCurrent, bulletsColorCurrent

        LIBSCREEN_SETCOLORPOSITION_AA bulletsXCharCurrent, bulletsYCharCurrent
        LIBSCREEN_SETCHAR_A bulletsColorCurrent

        GAMESTARS_GETCHAR_AAA bulletsXCharCurrent, bulletsYCharCurrent, bulletsCharCurrent

        LIBSCREEN_SETCHARPOSITION_AA bulletsXCharCurrent, bulletsYCharCurrent
        LIBSCREEN_SETCHAR_A bulletsCharCurrent

        rts
