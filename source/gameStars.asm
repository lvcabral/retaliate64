;===============================================================================
;  gameStars.asm - Background star field control module
;
;  Copyright (C) 2017,2018 Marcelo Lv Cabral - <https://lvcabral.com>
;  Adapted from https://github.com/JasonAldred/C64-Starfield
;  Copyright (C) 2017,2018 Jay Aldred - <jay.aldred@gmail.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
; Constants

FSC             = 181                   ; First star character
StarsCharsLimit = 50
StarsColsLimit  = 25
StarsRowsLimit  = 40
StarsColorsLimit= 20                    ; use values 1 to 20

POS1            = FSC
POS2            = FSC+14
POS3            = FSC+25
POS4            = FSC+50

Star1Init       = CHARSETRAM+POS1*8      ; Init address for each star
Star2Init       = CHARSETRAM+POS3*8
Star3Init       = CHARSETRAM+POS2*8

Star1Limit      = CHARSETRAM+POS3*8     ; Limit for each star
Star2Limit      = CHARSETRAM+POS4*8     ; Once limit is reached, they are reset
Star3Limit      = CHARSETRAM+POS3*8

Star1Reset      = CHARSETRAM+POS1*8      ; Reset address for each star
Star2Reset      = CHARSETRAM+POS3*8
Star3Reset      = CHARSETRAM+POS1*8

; Stars field cache
CACHERAM        = $0400
CLRCHRAM        = $BC00

;===============================================================================
; Zero Page Variables

starfieldPtr    = $E0             ; 3 x pointers for moving stars
starfieldPtr2   = $E2             ; $E2-$E3
starfieldPtr3   = $E4             ; $E4-$E5

rasterCount     = $E6             ; Counter that increments each frame

zeroPointer     = $E7             ; General purpose pointer $E7-$E8


;===============================================================================
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

ColorCacheRAMRowStartHigh ;  CLRCHRAM + 40*0, 40*1, 40*2 ... 40*24
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

;===============================================================================
; Data Arrays

starsColors  byte 07,10,04,14,07,13,04,03,10,07
             byte 07,10,07,14,07,13,04,03,10,04

; Star positions, 40 X positions, range FSC-FSC+49
starsRows    byte FSC,    FSC+34, FSC+15, FSC+6,  FSC+33, FSC+4,  FSC+35, FSC+23
             byte FSC+8,  FSC+36, FSC+28, FSC+1,  FSC+21, FSC+29, FSC+22, FSC+13
             byte FSC+18, FSC+9,  FSC+24, FSC+37, FSC+42, FSC+20, FSC+41, FSC+2
             byte FSC+17, FSC+5,  FSC+26, FSC+7,  FSC+25, FSC+38, FSC+10, FSC+30
             byte FSC+16, FSC+3,  FSC+32, FSC+40, FSC+27, FSC+43, FSC+39, FSC+19

;===============================================================================
; Functions/Macros

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

;===============================================================================

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
        lda flowLevel           ; Slow down on Easy mode
        bne @Star2Inc
        lda rasterCount
        and #1
        beq @Star2done
@Star2Inc
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

;===============================================================================

gameStarsWarp
        inc rasterCount         ; Increment our 8 bit counter

        lda #0                  ; Erase 3 stars
        tay
        sta (starfieldPtr),y
        sta (starfieldPtr2),y
        sta (starfieldPtr3),y

; Move star 1
        lda starfieldPtr       ; 2 pixels per frame
        clc
        adc #2
        sta starfieldPtr
        bcc @ok
        inc starfieldPtr+1
@ok
        lda starfieldPtr
        cmp #<Star1Limit
        bcc @Star1Done
        lda starfieldPtr+1
        cmp #>Star1Limit
        bcc @Star1Done
        lda #<Star1Reset        ; Reset 1
        sta starfieldPtr
        lda #>Star1Reset
        sta starfieldPtr+1
@Star1Done

; Move star 2
        lda starfieldPtr2       ; 4 pixels per frame
        clc
        adc #4
        sta starfieldPtr2
        bcc @ok2
        inc starfieldPtr2+1
@ok2
        lda starfieldPtr2
        cmp #<Star2Limit
        bcc @Star2Done
        lda starfieldPtr2+1
        cmp #>Star2Limit
        bcc @Star2Done
        lda #<Star2Reset        ; Reset 2
        sta starfieldPtr2
        lda #>Star2Reset
        sta starfieldPtr2+1
@Star2Done

; Move star 3
        lda starfieldPtr3       ; 2 pixels per frame
        clc
        adc #2
        sta starfieldPtr3
        bcc @ok3
        inc starfieldPtr3+1
@ok3
        lda starfieldPtr3
        cmp #<Star3Limit
        bcc @Star3done
        lda starfieldPtr3+1
        cmp #>Star3Limit
        bcc @Star3done
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

;===============================================================================
gameStarsScreen
        GAMESTARS_CREATEFIELD_VV SCREENRAM, COLORRAM
        rts

;===============================================================================
gameStarsCache
        GAMESTARS_CREATEFIELD_VV CACHERAM, CLRCHRAM
        rts

;===============================================================================
defm    GAMESTARS_CREATEFIELD_VV   ; /1 = CHAR RAM
                                   ; /2 = COLOR RAM

        ldx #StarsRowsLimit-1   ; Create starfield of chars
@lp     txa
        pha
        tay
        lda starsRows,x

        sta @smc1+1
        ldx #FSC+StarsColsLimit
        cmp #FSC+StarsColsLimit
        bcc @low
        ldx #FSC+StarsCharsLimit
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

;===============================================================================
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

;===============================================================================
defm    GAMESTARS_GETCOLOR_AAA   ; /1 = X Position 0-39 (Address)
                                 ; /2 = Y Position 0-24 (Address)
                                 ; /3 = Cached Color
        ldy /2  ; load y position as index into list

        lda ColorCacheRAMRowStartLow,Y ; load low address byte
        sta ZeroPageLow

        lda ColorCacheRAMRowStartHigh,Y ; load high address byte
        sta ZeroPageHigh

        ldy /1 ; load x position into Y register

        ; Retrieve the color
        lda (ZeroPageLow),Y
        sta /3
        endm

;===============================================================================
defm    GAMESTARS_COPYMAPROW_V   ; /1 = Row Number (Value)

        lda #True
        sta ZeroPageParam1       ; Enable flag to skip screen data
        ldy #/1                  ; load y position as index into list
        tya
        sta ZeroPageParam2
        lda #0
        sta ZeroPageParam3

        lda CacheRAMRowStartLow,Y  ; load low address byte
        sta ZeroPageLow2
        lda CacheRAMRowStartHigh,Y ; load high address byte
        sta ZeroPageHigh2

        jsr libScreen_CopyMapRow

        ldy #/1                  ; load y position as index into list
        lda ColorCacheRAMRowStartLow,Y  ; load low address byte
        sta ZeroPageLow2
        lda ColorCacheRAMRowStartHigh,Y ; load high address byte
        sta ZeroPageHigh2

        jsr libScreen_CopyMapRowColor
        endm
