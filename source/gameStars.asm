;===============================================================================
;  gameStars.asm - Background star field control module
;
;  Copyright (C) 2017,2018 Jay Aldred - <jay.aldred@gmail.com>
;  Adapted with permission from https://github.com/JasonAldred/C64-Starfield
;  Copyright (C) 2017,2018 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;==============================================================================
; Constants

Star1Init       = CHARSETRAM+$338 ; Init address for each star
Star2Init       = CHARSETRAM+$400
Star3Init       = CHARSETRAM+$3A8

Star1Limit      = CHARSETRAM+$400 ; Limit for each star
Star2Limit      = CHARSETRAM+$4C8 ; Once limit is reached, they are reset
Star3Limit      = CHARSETRAM+$400

Star1Reset      = CHARSETRAM+$338 ; Reset address for each star
Star2Reset      = CHARSETRAM+$400
Star3Reset      = CHARSETRAM+$338

StarsColsLimit  = 25
StarsRowsLimit  = 40
StarsColorsLimit= 20            ; use values 1 to 20

;==============================================================================
; Zero Page Variables

starfieldPtr    = $E0           ; 3 x pointers for moving stars
starfieldPtr2   = $E2
starfieldPtr3   = $E4

rasterCount     = $EE           ; Counter that increments each frame

zeroPointer     = $F8           ; General purpose pointer


;==============================================================================
; Jump table for screen cache

Operator Calc

CacheRAMRowStartLow ;  CACHERAM + 40*0, 40*1, 40*2 ... 40*24
        byte <CACHERAM,     <CACHERAM+40,  <CACHERAM+80
        byte <CACHERAM+120, <CACHERAM+160, <CACHERAM+200
        byte <CACHERAM+240, <CACHERAM+280, <CACHERAM+320
        byte <CACHERAM+360, <CACHERAM+400, <CACHERAM+440
        byte <CACHERAM+480, <CACHERAM+520, <CACHERAM+560
        byte <CACHERAM+600, <CACHERAM+640, <CACHERAM+680
        byte <CACHERAM+720, <CACHERAM+760, <CACHERAM+800
        byte <CACHERAM+840, <CACHERAM+880, <CACHERAM+920
        byte <CACHERAM+960

CacheRAMRowStartHigh ;  CACHERAM + 40*0, 40*1, 40*2 ... 40*24
        byte >CACHERAM,     >CACHERAM+40,  >CACHERAM+80
        byte >CACHERAM+120, >CACHERAM+160, >CACHERAM+200
        byte >CACHERAM+240, >CACHERAM+280, >CACHERAM+320
        byte >CACHERAM+360, >CACHERAM+400, >CACHERAM+440
        byte >CACHERAM+480, >CACHERAM+520, >CACHERAM+560
        byte >CACHERAM+600, >CACHERAM+640, >CACHERAM+680
        byte >CACHERAM+720, >CACHERAM+760, >CACHERAM+800
        byte >CACHERAM+840, >CACHERAM+880, >CACHERAM+920
        byte >CACHERAM+960

ColorCacheRAMRowStartLow ;  CLRCHRAM + 40*0, 40*1, 40*2 ... 40*24
        byte <CLRCHRAM,     <CLRCHRAM+40,  <CLRCHRAM+80
        byte <CLRCHRAM+120, <CLRCHRAM+160, <CLRCHRAM+200
        byte <CLRCHRAM+240, <CLRCHRAM+280, <CLRCHRAM+320
        byte <CLRCHRAM+360, <CLRCHRAM+400, <CLRCHRAM+440
        byte <CLRCHRAM+480, <CLRCHRAM+520, <CLRCHRAM+560
        byte <CLRCHRAM+600, <CLRCHRAM+640, <CLRCHRAM+680
        byte <CLRCHRAM+720, <CLRCHRAM+760, <CLRCHRAM+800
        byte <CLRCHRAM+840, <CLRCHRAM+880, <CLRCHRAM+920
        byte <CLRCHRAM+960

ColorCacheRAMRowStarHigh ;  CLRCHRAM + 40*0, 40*1, 40*2 ... 40*24
        byte >CLRCHRAM,     >CLRCHRAM+40,  >CLRCHRAM+80
        byte >CLRCHRAM+120, >CLRCHRAM+160, >CLRCHRAM+200
        byte >CLRCHRAM+240, >CLRCHRAM+280, >CLRCHRAM+320
        byte >CLRCHRAM+360, >CLRCHRAM+400, >CLRCHRAM+440
        byte >CLRCHRAM+480, >CLRCHRAM+520, >CLRCHRAM+560
        byte >CLRCHRAM+600, >CLRCHRAM+640, >CLRCHRAM+680
        byte >CLRCHRAM+720, >CLRCHRAM+760, >CLRCHRAM+800
        byte >CLRCHRAM+840, >CLRCHRAM+880, >CLRCHRAM+920
        byte >CLRCHRAM+960

Operator HiLo

;==============================================================================
; Data Variables

starsColors     ; Dark starfield so it doesnt distract from bullets and text
        byte 14,10,12,15,14,13,12,11,10,14
        byte 14,10,14,15,14,13,12,11,10,12

starsRows       ; Star positions, 40 X positions, range 103-152
        byte 103,137,118,109,136,107,138,126,111,139
        byte 131,104,124,132,125,116,121,112,127,140
        byte 145,123,144,105,120,108,129,110,128,141
        byte 113,133,119,106,135,143,130,146,142,122

;==============================================================================
; Functions/Macros

gameStarsUpdate
        inc rasterCount         ; Increment our 8 bit counter

        lda #0                  ; Erase 3 stars
        tay
        sta (starfieldPtr),y
        sta (starfieldPtr2),y
        sta (starfieldPtr3),y

; Move star 1

        lda rasterCount         ; Test bit 0 of counter
        and #1                  ; move 1 pixel every
        beq @Star1Done          ; other frame, to simulate
        inc starfieldPtr        ; 1/2 pixel movement
        bne @ok
        inc starfieldPtr+1
@ok
        lda starfieldPtr
        cmp #<Star1Limit
        bne @Star1Done
        lda starfieldPtr+1
        cmp #>Star1Limit
        bne @Star1Done
        lda #<Star1Reset        ; Reset 1
        sta starfieldPtr
        lda #>Star1Reset
        sta starfieldPtr+1
@Star1Done

; Move star 2

        inc starfieldPtr2       ; 1 pixel per frame
        bne @ok2
        inc starfieldPtr2+1
@ok2
        lda starfieldPtr2
        cmp #<Star2Limit
        bne @Star2Done
        lda starfieldPtr2+1
        cmp #>Star2Limit
        bne @Star2Done
        lda #<Star2Reset        ; Reset 2
        sta starfieldPtr2
        lda #>Star2Reset
        sta starfieldPtr2+1
@Star2Done

; Move star 3

        lda rasterCount         ; half pixel per frame
        and #1
        beq @Star3done
        inc starfieldPtr3
        bne @ok3
        inc starfieldPtr3+1
@ok3
        lda starfieldPtr3
        cmp #<Star3Limit
        bne @Star3done
        lda starfieldPtr3+1
        cmp #>Star3Limit
        bne @Star3done
        lda #<Star3Reset        ; Reset 3
        sta starfieldPtr3
        lda #>Star3Reset
        sta starfieldPtr3+1
@Star3done

; Plot new stars

        ldy #0
        lda (starfieldPtr),y    ; Moving stars dont overlap other stars
        ora #1                  ; as they use non conflicting bit
        sta (starfieldPtr),y    ; combinations

        lda (starfieldPtr2),y
        ora #1
        sta (starfieldPtr2),y

        lda (starfieldPtr3),y
        ora #4
        sta (starfieldPtr3),y

        rts

;==============================================================================
gameStarsInit

        lda #<Star1Init
        sta starfieldPtr
        lda #>Star1Init
        sta starfieldPtr+1

        lda #<Star2Init
        sta starfieldPtr2
        lda #>Star2Init
        sta starfieldPtr2+1

        lda #<Star3Init
        sta starfieldPtr3
        lda #>Star3Init
        sta starfieldPtr3+1

        rts

;==============================================================================
gameStarsScreen
        GAMESTARS_CREATEFIELD_VV SCREENRAM, COLORRAM
        rts

;==============================================================================
gameStarsCache
        GAMESTARS_CREATEFIELD_VV CACHERAM, CLRCHRAM
        rts

;==============================================================================
defm    GAMESTARS_CREATEFIELD_VV   ; /1 = CHAR RAM
                                   ; /2 = COLOR RAM

        ldx #StarsRowsLimit-1   ; Create starfield of chars
@lp     txa
        pha
        tay
        lda starsRows,x

        sta @smc1+1
        ldx #103+StarsColsLimit
        cmp #103+StarsColsLimit
        bcc @low
        ldx #103+50
@low    stx @smc3+1
        txa
        sec
        sbc #StarsColsLimit
        sta @smc2+1
        lda #</1
        sta zeroPointer
        lda #>/1
        sta zeroPointer+1
        ldx #StarsColsLimit-1
@smc1   lda #3
        sta (zeropointer),y
        lda zeropointer
        clc
        adc #StarsRowsLimit
        sta zeropointer
        bcc @clr
        inc zeropointer+1
@clr    inc @smc1+1
        lda @smc1+1
@smc3   cmp #0
        bne @onscreen
@smc2   lda #0
        sta @smc1+1
@onscreen
        dex
        bpl @smc1

        pla
        tax
        dex
        bpl @lp

        lda #</2           ; Fill color map with vertical stripes
        sta zeroPointer
        lda #>/2
        sta zeroPointer+1
        ldx #StarsColsLimit-1
@lp1    stx @smcx+1
        ldx #0
        ldy #StarsRowsLimit-1
@lp2
        lda starsColors,x
        sta (zeroPointer),y
        inx
        cpx #StarsColorsLimit
        bne @col
        ldx #0
@col
        dey
        bpl @lp2
        lda zeroPointer
        clc
        adc #StarsRowsLimit
        sta zeroPointer
        bcc @hiOk
        inc zeroPointer+1
@hiOk
@smcx
        ldx #0
        dex
        bpl @lp1

        endm

;==============================================================================
defm    GAMESTARS_GETCHAR_AAA    ; /1 = X Position 0-39 (Address)
                                 ; /2 = Y Position 0-24 (Address)
                                 ; /3 = Cached Char
        ldy /2 ; load y position as index into list

        lda CacheRAMRowStartLow,Y ; load low address byte
        sta ZeroPageLow

        lda CacheRAMRowStartHigh,Y ; load high address byte
        sta ZeroPageHigh

        ldy /1 ; load x position into Y register

        lda (ZeroPageLow),Y
        sta /3

        endm

;==============================================================================
defm    GAMESTARS_GETCOLOR_AAA   ; /1 = X Position 0-39 (Address)
                                 ; /2 = Y Position 0-24 (Address)
                                 ; /3 = Cached Color
        ldy /2  ; load y position as index into list

        lda ColorCacheRAMRowStartLow,Y ; load low address byte
        sta ZeroPageLow

        lda ColorCacheRAMRowStarHigh,Y ; load high address byte
        sta ZeroPageHigh

        ldy /1 ; load x position into Y register

        lda (ZeroPageLow),Y
        sta /3

        endm

;==============================================================================
defm    GAMESTARS_COPYMAPROW_V   ; /1 = Row Number (Value)

        ldy #/1 ; load y position as index into list
        lda #/1
        sta ZeroPageParam2
        lda #0
        sta ZeroPageParam3

        lda CacheRAMRowStartLow,Y ; load low address byte
        sta ZeroPageLow2
        lda CacheRAMRowStartHigh,Y ; load high address byte
        sta ZeroPageHigh2

        jsr libScreen_CopyMapRow

        endm
