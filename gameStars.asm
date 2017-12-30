;===============================================================================
;  gameStars.asm - Background star field control module
;
;  Copyright (C) 2017,2018 RetroGameDev - <https://www.retrogamedev.com>
;  Copyright (C) 2017 Dion Olsthoorn 
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
;
;==============================================================================
; Constants

StarsNumColumns         = 40
Stars1stCharacter       = 72
StarsNumFrames          = 8

;==============================================================================
; Variables

starsYCharArray         byte 15,  6, 17,  1, 18,  2,  4, 14, 12,  5
                        byte 13,  3,  9,  7, 10, 21,  5, 13, 10, 23
                        byte 11,  5, 15,  1,  5,  9,  7, 18, 11,  2
                        byte 12, 16, 21,  9,  2,  5, 16,  8, 15,  2

starsFrameArray         dcb StarsNumColumns, Stars1stCharacter
starsDelayArray         dcb StarsNumColumns, 1

starsSpeedColArray      byte  4,  2,  4,  3,  4,  3,  4,  3,  4,  3
                        byte  1,  2,  4,  2,  4,  2,  3,  4,  2,  3
                        byte  2,  3,  4,  3,  4,  1,  4,  3,  1,  3
                        byte  4,  3,  4,  1,  4,  2,  4,  2,  3,  2

starsCurrentX           byte 0
starsCurrentY           byte 0
starsCurrentFrame       byte 0
starsCurrentColor       byte 0
starsNextSpeed          byte 1

;==============================================================================
; Functions/Macros

gameStarsUpdate

        ldx #0
@loop
        ; only update when the delay is zero
        dec starsDelayArray,X
        ;bne @skipUpdate    
        beq @ok        
        jmp @skipUpdate
@ok
        ; reset the star delay
        lda starsSpeedColArray,X
        sta starsDelayArray,X

        ; set the current X & Y chars
        stx starsCurrentX
        lda starsYCharArray,X
        sta starsCurrentY

        ; move to the next star animation frame
        inc starsFrameArray,X
        lda starsFrameArray,X
        cmp #Stars1stCharacter + StarsNumFrames
        bne @skip

        ; reset the star frame
        lda #Stars1stCharacter
        sta starsFrameArray,X

        ; erase the current star character on screen
        LIBSCREEN_SETCHARPOSITION_AA starsCurrentX, starsCurrentY
        LIBSCREEN_GETCHAR_ACC
        and #%11111000
        cmp #Stars1stCharacter
        bne @skipErase
        LIBSCREEN_SETCHAR_V SpaceCharacter
@skipErase
        ; inc char position
        inc starsYCharArray,X
        lda starsYCharArray,X
        cmp #25
        bne @skip
             
        ; reset char position
        lda #0
        sta starsYCharArray,X

        ; reset the speed & color
        inc starsNextSpeed
        lda starsNextSpeed
        sta starsSpeedColArray,X
        cmp #4 ; purple & slow
        bne @skip
        lda #1 ; red & fast - gets incremented to 2 first time around - maybe change this
        sta starsNextSpeed

@skip
        ; set the current Y char
        lda starsYCharArray,X
        sta starsCurrentY

        ; set the current frame
        lda starsFrameArray,X
        sta starsCurrentFrame

        ; set the current color
        lda starsSpeedColArray,X
        sta starsCurrentColor

        ; only draw the star if the XY position is empty or already contains a star
        LIBSCREEN_SETCHARPOSITION_AA starsCurrentX, starsCurrentY
        LIBSCREEN_GETCHAR_ACC
        and #%11111000
        cmp #Stars1stCharacter
        beq @drawStar
        LIBSCREEN_GETCHAR_ACC
        cmp #SpaceCharacter
        beq @drawStar
        jmp @skipUpdate

@drawStar
        ; draw the current star
        ;LIBSCREEN_SETCHARPOSITION_AA starsCurrentX, starsCurrentY
        LIBSCREEN_SETCHAR_A starsCurrentFrame

        LIBSCREEN_SETCOLORPOSITION_AA starsCurrentX, starsCurrentY
        LIBSCREEN_SETCHAR_A starsCurrentColor

@skipUpdate
        ; loop for each star
        inx
        cpx #StarsNumColumns
        ;bne @loop
        beq @finished
        jmp @loop
@finished
   
        rts
