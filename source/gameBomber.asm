;===============================================================================
;  gameBomber.asm - Bomber control module
;
;  Copyright (C) 2018,2019 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
; Constants
BombMissile     = 1
BombPulsar      = 2
BombBouncer     = 3
BombRndArrayMax = 32
BomberMaxPos    = 174
BombMaxChars    = 6
BombSpeed       = 3
BombColor       = LightGreen
BomberColor     = Cyan
BomberBack      = 20
BomberFront     = 21
MissileDownChr  = 144
MissileUpChr    = 148
PulsarChr       = 152
BouncerDownChr  = 154
BouncerUpChr    = 160

;===============================================================================
; Page Zero

bomberTime      = $EA
bomberSprite    = $EB
bomberXHigh     = $EC
bomberXLow      = $ED
bomberY         = $EE
bomberIndex     = $EF

;===============================================================================
; Variables

bomberFrame       byte 0
bomberXChar       byte 0
bomberYChar       byte 0
bombDropped       byte 0
bombLaunched      byte 0
; Bomb Type Random Array - 60% Missile - 25% Bouncer - 15% Pulsar
bombTypeRndArray  byte BombMissile, BombMissile, BombPulsar,  BombBouncer
                  byte BombMissile, BombMissile, BombBouncer, BombMissile
                  byte BombBouncer, BombPulsar,  BombMissile, BombMissile
                  byte BombMissile, BombBouncer, BombPulsar,  BombMissile
                  byte BombMissile, BombMissile, BombBouncer, BombMissile
                  byte BombMissile, BombPulsar,  BombMissile, BombMissile
                  byte BombMissile, BombBouncer, BombPulsar,  BombMissile
                  byte BombBouncer, BombMissile, BombBouncer, BombMissile
bombTypeRndIndex  byte 0
; Bombs Characters for Animation
missileDownArray  byte MissileDownChr+0, MissileDownChr+1, MissileDownChr+2
                  byte MissileDownChr+3, MissileDownChr+3, MissileDownChr+0
missileUpArray    byte MissileUpChr+0, MissileUpChr+1, MissileUpChr+2
                  byte MissileUpChr+3, MissileUpChr+3, MissileUpChr+0
pulsarDownArray   byte PulsarChr+0, PulsarChr+0, PulsarChr+0
                  byte PulsarChr+1, PulsarChr+1, PulsarChr+1
bouncerDownArray  byte BouncerDownChr+0, BouncerDownChr+1, BouncerDownChr+2
                  byte BouncerDownChr+3, BouncerDownChr+4, BouncerDownChr+5
bouncerUpArray    byte BouncerUpChr+0, BouncerUpChr+1, BouncerUpChr+2
                  byte BouncerUpChr+3, BouncerUpChr+4, BouncerUpChr+5
bombCharIndexDown byte 0
bombDelayDown     byte 0
bombActiveDown    byte 0
bombXCharDown     byte 0
bombYCharDown     byte 0
bombCharIndexUp   byte 0
bombDelayUp       byte 0
bombActiveUp      byte 0
bombXCharUp       byte 0
bombYCharUp       byte 0
bouncerCount      byte 0
saveBomberTime    byte 0

;===============================================================================
; Macros/Subroutines

defm    GAMEBOMB_LAUNCH_UP_AAV          ; /1 = XChar (Address)
                                        ; /2 = YChar (Address)
                                        ; /3 = Type  (Value)
        inc bombActiveUp
        lda #0
        sta bombCharIndexUp
        sta bombDelayUp
        lda /1
        sta bombXCharUp
        lda /2
        sta bombYCharUp
        lda #/3
        sta bombLaunched

        endm

;===============================================================================

defm    GAMEBOMB_LAUNCH_DOWN_AA         ; /1 = XChar (Address)
                                        ; /2 = YChar (Address)
        inc bombActiveDown
        lda #0
        sta bombCharIndexDown
        sta bombDelayDown
        lda /1
        sta bombXCharDown
        lda /2
        sta bombYCharDown
        endm

;===============================================================================

defm    GAMEBOMB_COLLIDED_UP_AA         ; /1 = XChar (Address)
                                        ; /2 = YChar (Address)
        lda bombActiveUp
        beq @exit

        lda bombXCharUp
        sta ammoXCharCurrent
        lda bombYCharUp
        sta ammoYCharCurrent
        lda /1
        sta ammoXCharCol
        lda /2
        sta ammoYCharCol
        jsr gameBombsCollided
        beq @exit
        ldx #0
        stx bombActiveUp
        lda #True
@exit
        endm

;===============================================================================

defm    GAMEBOMB_COLLIDED_DOWN_AA       ; /1 = XChar (Address)
                                        ; /2 = YChar (Address)
        lda bombActiveDown
        beq @exit
                
        lda bombXCharDown
        sta ammoXCharCurrent
        lda bombYCharDown
        sta ammoYCharCurrent
        lda /1
        sta ammoXCharCol
        lda /2
        sta ammoYCharCol
        jsr gameBombsCollided
        beq @exit
        ldx #0
        stx bombActiveDown
        lda #True
@exit
        endm

;===============================================================================

gameBomberInit
        lda #0
        sta bomberTime
        sta bomberIndex
        mva #AliensMax+2, bomberSprite
        mva #BomberBack, bomberFrame
        mva #HideY, bomberY
        jsr gameBomberSetSprite
        rts

;===============================================================================

gameBomberReset
        lda #0
        sta bomberIndex
        sta bombXCharDown
        sta bombYCharDown
        sta bombActiveDown
        sta bombActiveUp
        sta bombDropped
        sta bouncerCount
        rts

;===============================================================================

gameBombsReset
        lda bombActiveUp
        beq gBSRClearDown
        mva bombYCharUp, ammoYCharCurrent
        mva bombXCharUp, ammoXCharCurrent
        jsr gameAmmoClear

gBSRClearDown
        lda bombActiveDown
        beq gBSRClearVars
        mva bombYCharDown, ammoYCharCurrent
        mva bombXCharDown, ammoXCharCurrent
        jsr gameAmmoClear

gBSRClearVars
        lda #0
        sta bombActiveDown
        sta bombActiveUp
        rts

;===============================================================================

gameBomberSetSprite
        LIBMPLEX_STOPANIM_A bomberSprite
        LIBMPLEX_SETFRAME_AA bomberSprite, bomberFrame
        LIBMPLEX_SETCOLOR_AV bomberSprite, BomberColor
        LIBMPLEX_MULTICOLORENABLE_AV bomberSprite, True
        rts

;===============================================================================

gameBomberUpdate
        lda bomberTime
        bne gBUCheckTime
        rts

gBUCheckTime
        cmp time2
        bcs gBUBegin
        rts

gBUBegin
        ldx bombTypeRndIndex
        lda bombTypeRndArray,X
        sta bombDropped
        cmp #BombBouncer
        bne gBUDestroyerUpdate
        jmp gBUBouncerUpdate

gBUDestroyerUpdate
        ldy bomberIndex
        bne gBUMoveDestroyer
        mva #BomberFront, bomberFrame
        mva #AliensMax+3, bomberSprite
        jsr gameBomberSetSprite
        ldy #0

gBUMoveDestroyer
        lda bomberXHighArray,Y
        sta bomberXHigh
        lda bomberXLowArray,Y
        sta bomberXLow
        lda bomberYArray,Y
        sta bomberY
        cmp #HideY
        beq gBUCheckLaunch
        LIBMPLEX_SETPOSITION_AAAA #AliensMax+2, bomberXHigh, bomberXLow, bomberY
        LIBMATH_ADD16BIT_AAVVAA bomberXHigh, bomberXLow, 0, 24, bomberXHigh, bomberXLow
        LIBMPLEX_SETPOSITION_AAAA #AliensMax+3, bomberXHigh, bomberXLow, bomberY
        LIBSCREEN_PIXELTOCHAR_AAVAVAA bomberXHigh, bomberXLow, 12, bomberY, 40, bomberXChar, bomberYChar
        ; Don't check collisions every frame
        lda aliensStep
        beq gBUCheckLaunch
        jsr gameBomberUpdateCollisions

gBUCheckLaunch
        lda bomberXChar
        cmp playerXChar
        bne gBUCheckEnd
        ; Drop Bomb
        lda bombActiveDown
        bne gBUCheckEnd
        GAMEBOMB_LAUNCH_DOWN_AA bomberXChar, bomberYChar

gBUCheckEnd
        inc bomberIndex
        lda bomberIndex
        cmp #BomberMaxPos
        bcc gBUDoneBomber
        lda #0
        sta bomberIndex
        sta bomberTime
        LIBMPLEX_SETVERTICALTPOS_AA #AliensMax+2, #HideY
        LIBMPLEX_SETVERTICALTPOS_AA #AliensMax+3, #HideY
        inc bombTypeRndIndex
        lda bombTypeRndIndex
        cmp #BombRndArrayMax
        bcc gBUDoneBomber
        mva #0, bombTypeRndIndex

gBUDoneBomber
        rts
;-------------------------------------------------------------------------------
gBUBouncerUpdate
        ldy bomberIndex
        bne gBUMoveBouncer
        jsr gameBouncerSetSprite
        ldy #0

gBUMoveBouncer
        lda bomberXHighArray,Y
        sta bomberXHigh
        lda bomberXLowArray,Y
        sta bomberXLow
        lda bouncerYArray,Y
        sta bomberY
        cmp #HideY
        beq gBUCheckBouncer
        LIBMPLEX_SETPOSITION_AAAA #AliensMax+3, bomberXHigh, bomberXLow, bomberY
        LIBSCREEN_PIXELTOCHAR_AAVAVAA bomberXHigh, bomberXLow, 12, bomberY, 40, bomberXChar, bomberYChar
        ; Don't check collisions every frame
        lda aliensStep
        beq gBUReturn
        jsr gameBomberUpdateCollisions
        jmp gBUCheckLaunch

gBUCheckBouncer
        inc bouncerCount
        lda bouncerCount
        cmp #3
        bcs gBUReturn
        mva #0, bomberIndex

gBUReturn
        jmp gBUCheckLaunch

;===============================================================================

gameBouncerSetSprite
        LIBMPLEX_SETVERTICALTPOS_AA #AliensMax+2, #HideY
        LIBMPLEX_PLAYANIM_AVVVV #AliensMax+3, AlienClamp, AlienClamp+2, 4, True
        LIBMPLEX_SETCOLOR_AV #AliensMax+3, BomberColor
        LIBMPLEX_MULTICOLORENABLE_AV #AliensMax+3, True
        rts
;===============================================================================

gameBomberUpdateCollisions
        GAMEBULLETS_COLLIDED_UP_AA bomberXChar, bomberYChar
        bne gBUCCollided
        GAMEBOMB_COLLIDED_UP_AA bomberXChar, bomberYChar
        bne gBUCCollided
        lda bomberXChar
        cmp #3
        bcc gBUCNoCollision
        sec
        sbc #3
        sta bomberXChar
        lda #$10
        sta aliensScore
        GAMEBULLETS_COLLIDED_UP_AA bomberXChar, bomberYChar
        bne gBUCCollided
        lda #$15
        sta aliensScore
        GAMEBOMB_COLLIDED_UP_AA bomberXChar, bomberYChar
        bne gBUCCollided

gBUCNoCollision
        rts

gBUCCollided
        dec bulletsActiveUp
        ; run explosion animation on front sprite
        LIBMPLEX_PLAYANIM_AVVVV #AliensMax+3, StartExplode, FinishExplode, 2, False
        LIBMPLEX_SETCOLOR_AV     #AliensMax+3, Yellow
        ; hide other sprite
        LIBMPLEX_SETVERTICALTPOS_AA #AliensMax+2, #HideY

        ; play explosion sound
        LIBSOUND_PLAY_VAA ExplosionVoice, soundExplosionHigh, soundExplosionLow
        mva #0, bomberTime
        jmp gameFlowIncreaseScore

;===============================================================================

gameBombsUpdate
        lda bombActiveDown
        beq gBBUCheckUp
        lda bombDelayDown
        cmp #BombSpeed
        bne gBBUUSkip
        jsr gameBombsMoveDown
        jmp gBBUCheckUp

gBBUUSkip
        inc bombDelayDown

gBBUCheckUp
        lda bombActiveUp
        bne gBBUpdateUp
        rts

gBBUpdateUp
        lda bombDelayUp
        cmp #BombSpeed
        bne gBBUDelay
        jmp gameBombsMoveUp

gBBUDelay
        inc bombDelayUp
        rts

;===============================================================================

gameBombsMoveDown
        ; clear current bomb position
        mva bombYCharDown, ammoYCharCurrent
        mva bombXCharDown, ammoXCharCurrent
        jsr gameAmmoClear
        ; move bomb down
        ldy bombYCharDown
        iny
        sty bombYCharDown
        ; ignore the bottom row to not erase the gauge and ammo
        cpy #StatusY
        bne gBMDDraw
        lda #0
        sta bombActiveDown
        sta bombDropped
        rts

gBMDDraw
        lda bombXCharDown
        cmp playerXChar
        beq gBMDSkip
        bcc gBMDLeft
        dec bombXCharDown
        jmp gBMDSkip

gBMDLeft
        inc bombXCharDown

gBMDSkip
        ; set the bomb color
        LIBSCREEN_SETCOLORPOSITION_AA bombXCharDown, bombYCharDown
        LIBSCREEN_SETCHAR_V BombColor

        ; set the bomb character
        LIBSCREEN_SETCHARPOSITION_AA bombXCharDown, bombYCharDown
        inc bombCharIndexDown
        ldx bombCharIndexDown
        cpx #BombMaxChars
        bcc gBMDSelChar
        ldx #0
        stx bombCharIndexDown

gBMDSelChar
        lda bombDropped
        cmp #BombPulsar
        bcc gBMDMissile
        beq gBMDPulsar
        lda bouncerDownArray,X
        jmp gBMDSetChar

gBMDPulsar
        lda pulsarDownArray,X
        jmp gBMDSetChar

gBMDMissile
        lda missileDownArray,X

gBMDSetChar
        LIBSCREEN_SETCHAR_ACC
        mva #0, bombDelayDown
        rts

;===============================================================================

gameBombsMoveUp
        ; clear current bomb position
        mva bombYCharUp, ammoYCharCurrent
        mva bombXCharUp, ammoXCharCurrent
        jsr gameAmmoClear
        ; move bomb up
        mva playerXChar, bombXCharUp
        ldy bombYCharUp
        dey
        sty bombYCharUp
        ; ignore the top row to not erase the scores
        bne gBMUDraw
        mva #0, bombActiveUp
        rts

gBMUDraw
        ; set the bomb color
        LIBSCREEN_SETCOLORPOSITION_AA bombXCharUp, bombYCharUp
        LIBSCREEN_SETCHAR_V BombColor

        ; set the bomb character
        LIBSCREEN_SETCHARPOSITION_AA bombXCharUp, bombYCharUp
        inc bombCharIndexUp
        ldx bombCharIndexUp
        cpx #BombMaxChars
        bcc gBMUSelChar
        ldx #0
        stx bombCharIndexUp

gBMUSelChar
        lda bombLaunched
        cmp #BombBouncer
        bne gBMUMissile
        lda bouncerUpArray,X
        jmp gBMUSetChar

gBMUMissile
        lda missileUpArray,X

gBMUSetChar
        LIBSCREEN_SETCHAR_ACC
        mva #0, bombDelayUp
        rts

;===============================================================================

gameBombsCollided
        ; skip if bomb YChar != YChar
        ldy ammoYCharCurrent
        cpy ammoYCharCol
        beq gBDCCheckX

gBDCYMinus1
        ; skip if bomb XChar-1 != XChar
        dey
        cpy ammoYCharCol
        bne gBDCSkip

gBDCCheckX
        ; skip if bomb XChar != XChar
        ldy ammoXCharCurrent
        cpy ammoXCharCol
        beq gBDCCollided

gBDCXMinus1
        ; skip if bomb XChar-1 != XChar
        dey
        cpy ammoXCharCol
        beq gBDCCollided

gBDCXPlus1
        ; skip if bomb XChar+1 != XChar
        iny
        iny
        cpy ammoXCharCol
        bne gBDCSkip

gBDCCollided
        ; collided so delete bomb from screen
        jsr gameAmmoClear
        ; set A to notify collision and return
        lda #True
        rts

gBDCSkip
        ; set A as not collided
        lda #False
        rts
