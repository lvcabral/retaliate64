;===============================================================================
;  testsound.asm - SFX Test Tool
;
;  Copyright (C) 2018 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
;  Press F5 to assemble and run
;===============================================================================
GenerateTo testsound.prg

;===============================================================================
; Initialize

*=$0801 ; 10 SYS (2064)

        byte $0E, $08, $0A, $00, $9E, $20, $28, $32
        byte $30, $36, $34, $29, $00, $00, $00

        jmp start

;===============================================================================
; Libraries

        incasm libMemory.asm
        incasm libInput.asm
        incasm libSound.asm
        incasm libMath.asm

;===============================================================================
; Menu String

menuTextTop     text '   retaliate sfx'
                byte 0
menuTextF1      text 'f1 - soundFiring'
                byte 0
menuTextF3      text 'f3 - soundExplosion'
                byte 0
menuTextF5      text 'f5 - soundPickup'
                byte 0
menuTextF7      text 'f7 - soundFullAmmo'
                byte 0

;===============================================================================
; Main Loop

start
        ; Initialize SID registers
        jsr libSoundInit
        SET1000 SCREENRAM, $20
        DRAWTEXT_AAAV #10, #4, menuTextTop, Yellow
        DRAWTEXT_AAAV #10, #7, menuTextF1, White
        DRAWTEXT_AAAV #10, #9, menuTextF3, White
        DRAWTEXT_AAAV #10, #11, menuTextF5, White
        DRAWTEXT_AAAV #10, #13, menuTextF7, White

;===============================================================================
; Update

gMLoop
        ; Wait for scanline 255
        WAIT_V 255
        
        ldx #2
        lda soundVoiceActive,X
        beq checkKeys
        jmp UpdateSID
checkKeys
        clc 
        jsr SCNKEY
        jsr GETIN
        beq gMLoop
        cmp #KEY_F1
        beq playF1
        cmp #KEY_F3
        beq playF3
        cmp #KEY_F5
        beq playF5
        cmp #KEY_F7
        beq playF7
        jmp UpdateSID
playF1
        lda soundFiringHigh
        sta SoundHigh
        lda soundFiringLow
        sta SoundLow
        jsr playSound
        jmp UpdateSID

playF3
        lda soundExplosionHigh
        sta SoundHigh
        lda soundExplosionLow
        sta SoundLow
        jsr playSound
        jmp UpdateSID

playF5
        lda soundPickupHigh
        sta SoundHigh
        lda soundPickupLow
        sta SoundLow
        jsr playSound
        jmp UpdateSID

playF7
        lda soundFullAmmoHigh
        sta SoundHigh
        lda soundFullAmmoLow
        sta SoundLow
        jsr playSound

UpdateSID
        jsr libSoundUpdate

        ; Loop back to the start of the game loop
        jmp gMLoop

playSound
        LIBSOUND_PLAY_VAA 2, soundHigh, soundLow
        rts


;===============================================================================
; Constants
False           = 0
True            = 1

Black           = 0
White           = 1
Red             = 2
Cyan            = 3 
Purple          = 4
Green           = 5
Blue            = 6
Yellow          = 7
Orange          = 8
Brown           = 9
LightRed        = 10
DarkGray        = 11
MediumGray      = 12
LightGreen      = 13
LightBlue       = 14
LightGray       = 15

SCREENRAM       = $0400

;===============================================================================
; Variables Zero Page

SoundHigh       = $10
SoundLow        = $11
SoundId         = $12
ZeroPageTemp    = $72
ZeroPageParam1  = $73
ZeroPageParam2  = $74
ZeroPageParam3  = $75
ZeroPageParam4  = $76
ZeroPageParam5  = $77
ZeroPageParam6  = $78
ZeroPageParam7  = $79
ZeroPageParam8  = $7A
ZeroPageParam9  = $7B
ZeroPageTemp1   = $7C
ZeroPageTemp2   = $7D
ZeroPageLow     = $FB
ZeroPageHigh    = $FC
ZeroPageLow2    = $FD
ZeroPageHigh2   = $FE


;===============================================================================
; Screen Pointers

Operator Calc

ScreenRAMRowStartLow ;  SCREENRAM + 40*0, 40*1, 40*2 ... 40*24
                byte <SCREENRAM,     <SCREENRAM+40,  <SCREENRAM+80
                byte <SCREENRAM+120, <SCREENRAM+160, <SCREENRAM+200
                byte <SCREENRAM+240, <SCREENRAM+280, <SCREENRAM+320
                byte <SCREENRAM+360, <SCREENRAM+400, <SCREENRAM+440
                byte <SCREENRAM+480, <SCREENRAM+520, <SCREENRAM+560
                byte <SCREENRAM+600, <SCREENRAM+640, <SCREENRAM+680
                byte <SCREENRAM+720, <SCREENRAM+760, <SCREENRAM+800
                byte <SCREENRAM+840, <SCREENRAM+880, <SCREENRAM+920
                byte <SCREENRAM+960

ScreenRAMRowStartHigh ;  SCREENRAM + 40*0, 40*1, 40*2 ... 40*24
                byte >SCREENRAM,     >SCREENRAM+40,  >SCREENRAM+80
                byte >SCREENRAM+120, >SCREENRAM+160, >SCREENRAM+200
                byte >SCREENRAM+240, >SCREENRAM+280, >SCREENRAM+320
                byte >SCREENRAM+360, >SCREENRAM+400, >SCREENRAM+440
                byte >SCREENRAM+480, >SCREENRAM+520, >SCREENRAM+560
                byte >SCREENRAM+600, >SCREENRAM+640, >SCREENRAM+680
                byte >SCREENRAM+720, >SCREENRAM+760, >SCREENRAM+800
                byte >SCREENRAM+840, >SCREENRAM+880, >SCREENRAM+920
                byte >SCREENRAM+960

ColorRAMRowStartLow ;  COLORRAM + 40*0, 40*1, 40*2 ... 40*24
                byte <COLORRAM,     <COLORRAM+40,  <COLORRAM+80
                byte <COLORRAM+120, <COLORRAM+160, <COLORRAM+200
                byte <COLORRAM+240, <COLORRAM+280, <COLORRAM+320
                byte <COLORRAM+360, <COLORRAM+400, <COLORRAM+440
                byte <COLORRAM+480, <COLORRAM+520, <COLORRAM+560
                byte <COLORRAM+600, <COLORRAM+640, <COLORRAM+680
                byte <COLORRAM+720, <COLORRAM+760, <COLORRAM+800
                byte <COLORRAM+840, <COLORRAM+880, <COLORRAM+920
                byte <COLORRAM+960

ColorRAMRowStartHigh ;  COLORRAM + 40*0, 40*1, 40*2 ... 40*24
                byte >COLORRAM,     >COLORRAM+40,  >COLORRAM+80
                byte >COLORRAM+120, >COLORRAM+160, >COLORRAM+200
                byte >COLORRAM+240, >COLORRAM+280, >COLORRAM+320
                byte >COLORRAM+360, >COLORRAM+400, >COLORRAM+440
                byte >COLORRAM+480, >COLORRAM+520, >COLORRAM+560
                byte >COLORRAM+600, >COLORRAM+640, >COLORRAM+680
                byte >COLORRAM+720, >COLORRAM+760, >COLORRAM+800
                byte >COLORRAM+840, >COLORRAM+880, >COLORRAM+920
                byte >COLORRAM+960

Operator HiLo

;==============================================================================
; Macros

defm    WAIT_V                  ; /1 = Scanline (Value)

@loop   lda #/1                 ; Scanline -> A
        cmp RASTER              ; Compare A to current raster line
        bne @loop               ; Loop if raster line not reached 255

        endm

;==============================================================================

defm    DRAWTEXT_AAAV           ; /1 = X Position 0-39 (Address)
                                ; /2 = Y Position 0-24 (Address)
                                ; /3 = 0 terminated string (Address)
                                ; /4 = Text Color (Value)

        ldy /2 ; load y position as index into list

        lda ScreenRAMRowStartLow,Y ; load low address byte
        sta ZeroPageLow

        lda ScreenRAMRowStartHigh,Y ; load high address byte
        sta ZeroPageHigh

        ldy /1 ; load x position into Y register

        ldx #0
@loop   lda /3,X
        beq @done
        sta (ZeroPageLow),Y
        inx
        iny
        jmp @loop
@done

        ldy /2 ; load y position as index into list

        lda ColorRAMRowStartLow,Y ; load low address byte
        sta ZeroPageLow

        lda ColorRAMRowStartHigh,Y ; load high address byte
        sta ZeroPageHigh

        ldy /1 ; load x position into Y register

        ldx #0
@loop2  lda /3,X
        beq @done2
        lda #/4
        sta (ZeroPageLow),Y
        inx
        iny
        jmp @loop2
@done2

        endm

;==============================================================================
; Sets 1000 bytes of memory from start address with a value

defm    SET1000                 ; /1 = Start  (Address)
                                ; /2 = Number (Value)

        lda #/2                 ; Get number to set
        ldx #250                ; Set loop value
@loop   dex                     ; Step -1
        sta /1,x                ; Set start + x
        sta /1+250,x            ; Set start + 250 + x
        sta /1+500,x            ; Set start + 500 + x
        sta /1+750,x            ; Set start + 750 + x
        bne @loop               ; If x<>0 loop

        endm
