;===============================================================================
;  gameSplash.asm - Game Splash Screen
;
;  Copyright (C) 2017,2018 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
; Constants

BITMAPRAM = $4000

;===============================================================================
; Macros/Subroutines

startSplash
        lda #$A0        ; Screen Memory @ $2800 + Bitmap @ $0000
        sta VMCSB
        lda #$18
        sta SCROLX      ; Set Multicolor mode
        lda #$3B
        sta SCROLY      ; Enable Bitmap mode
        lda #Black
        sta EXTCOL      ; Border color
        lda BITMAPRAM+$2710
        sta BGCOL0      ; Background color
        ldx #$00

drawSplash
        lda BITMAPRAM+$1F40,X
        sta SCREENRAM,X
        lda BITMAPRAM+$2328,X
        sta COLORRAM,X
        lda BITMAPRAM+$2040,X
        sta SCREENRAM+$100,X
        lda BITMAPRAM+$2428,X
        sta COLORRAM+$100,X
        lda BITMAPRAM+$2140,X
        sta SCREENRAM+$200,X
        lda BITMAPRAM+$2528,X
        sta COLORRAM+$200,X
        lda BITMAPRAM+$2240,X
        sta SCREENRAM+$300,X
        lda BITMAPRAM+$2628,X
        sta COLORRAM+$300,X
        inx
        bne drawSplash

loopSplash
        clc 
        lda CIAPRA
        and #GameportFireMask
        beq endSplash
        jsr SCNKEY
        jsr GETIN
        cmp #$00
        beq loopSplash
        cmp #KEY_RETURN
        beq endSplash
        cmp #KEY_SPACE
        beq endSplash

        jmp loopSplash ; loop if nothing was pressed
endSplash
        lda #$9B   ; Disable Bitmap mode
        sta SCROLY
        lda #$08   ; Disable Multicolor mode
        sta SCROLX
        LIBINPUT_GETFIREPRESSED ; clear fire 
        rts
