;===============================================================================
;  gameSplash.asm - Game Splash Screen
;
;  Copyright (C) 2017,2018 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
;
;===============================================================================
; Macros/Subroutines

startSplash
        lda #$18
        sta $d018

        lda #$18
        sta $d016

        lda #$3b
        sta $d011 ;Enable Bitmap mode

        lda #$00
        sta $d020
        lda $4710
        sta $d021
        ldx #$00
drawSplash
        lda $3f40,X
        sta $0400,X
        lda $4328,X
        sta $d800,X
        lda $4040,X
        sta $0500,X
        lda $4428,X
        sta $d900,X
        lda $4140,X
        sta $0600,X
        lda $4528,X
        sta $da00,X
        lda $4240,X
        sta $0700,X
        lda $4628,X
        sta $db00,X
        inx
        bne drawSplash
loopSplash
        ; Wait joystick fire
        clc 
        lda $DC00
        and #$10  ;mask %00010000
        beq endSplash
        ; Wait space bar
        lda #$7F  ;%01111111 
        sta $DC00 
        lda $DC01 
        and #$10  ;mask %00010000 
        beq endSplash
        ; loop if nothing was pressed
        jmp loopSplash
endSplash
        lda #$9b  ;Disable Bitmap mode
        sta $d011
        lda #0
        sta $d016 ;Set default text mode
        LIBINPUT_GETFIREPRESSED ; clear fire 
        rts
