;===============================================================================
;  buildLoader.asm - Game Loader
;
;  Copyright (C) 2018-2021 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
; Press F6 to build the prg file

GenerateTo "..\out\retaliate.prg"

#region Basic Loader
*=$0801 ; 10 SYS (2064)

        byte $0E, $08, $0A, $00, $9E, $20, $28, $32
        byte $30, $36, $34, $29, $00, $00, $00

        ; Our code starts at $0810 (2064 decimal)
        ; after the 15 bytes for the BASIC loader

        jmp initMenu

        incasm "libDefines.asm"
        incasm "libInput.asm"
        incasm "libSprite.asm"
#endregion
#region Splash Screen
;===============================================================================

startSplash
        mva #%00011000, VMCSB
        mva #$18, SCROLX                ; Set Multicolor mode
        mva #$3B, SCROLY                ; Enable Bitmap mode
        mva #Black, EXTCOL              ; Border color
        mva BITMAPRAM+$2710, BGCOL0     ; Background color
        ldx #$00

drawSplash
        lda BITMAPRAM+$1F40,X
        sta SCREENMEM,X
        lda BITMAPRAM+$2328,X
        sta COLORRAM,X
        lda BITMAPRAM+$2040,X
        sta SCREENMEM+$100,X
        lda BITMAPRAM+$2428,X
        sta COLORRAM+$100,X
        lda BITMAPRAM+$2140,X
        sta SCREENMEM+$200,X
        lda BITMAPRAM+$2528,X
        sta COLORRAM+$200,X
        lda BITMAPRAM+$2240,X
        sta SCREENMEM+$300,X
        lda BITMAPRAM+$2628,X
        sta COLORRAM+$300,X
        inx
        bne drawSplash

loopSplash
        clc
        lda CIAPRA
        and #GameportFireMask
        beq endSplash
        jsr libInputKeys
        beq loopSplash
        cmp #KEY_SPACE
        beq endSplash
        WAIT_V 255
        jmp loopSplash                  ; loop if nothing was pressed

endSplash
        mva #$9B, SCROLY                ; Disable Bitmap mode
        mva #$08, SCROLX                ; Disable Multicolor mode
        LIBINPUT_GETFIREPRESSED         ; clear fire
        rts
#endregion
#region Language Menu
;===============================================================================
; Initialize Menu

initMenu
        ; Disable shift + C= keys
        mva $80, MODE

        ; Disable run/stop + restore keys
        mva #$FC, ISTOP

        ; Save VIC II registers
        mva CI2PRA, vicReg1
        mva VMCSB, vicReg2

        ; Show Splash Bitmap
        jsr startSplash

        ; Fill 1000 bytes (40x25) of screen memory
        SET1000 SCREENRAM, SpaceCharacter

menuDraw
        ; Move VIC II to see 2nd memory bank ($4000-$7FFF)
        lda CI2PRA
        and #%11111100
        ora #%00000010
        sta CI2PRA

        ; Screen Memory @ $0800 and Charset @ $1800
        mva #%00100110, VMCSB

        ; Set border and background colors
        SETCOLORS Black, Black, Yellow, DarkGray, Black

        ; Set sprite multicolors
        LIBSPRITE_SETMULTICOLORS_VV LightBlue, White

        CharsOnScreen 12, 10, boxMenuChars, boxMenuColors, 80
        CharsOnScreen 16, 19, joystickChars, joystickColors, 42
        jsr showLogo
        jsr showMenu

menuLoop
        WAIT_V 255
        jsr libInputUpdate
        jsr updateMenu
        beq menuLoop
        rts

;===============================================================================

showLogo
        mva #0, logoFrame
        ldx #0
        stx logoSprite

slLoop
        lda logoXArray,X
        sta logoX
        lda logoYArray,X
        sta logoY
        lda logoModeArray,X
        sta logoMode
        lda logoColorArray,X
        sta logoColor

        jsr setLogoFrame

        ; loop for each frame
        inc logoSprite
        inc logoFrame
        inx
        cpx #6
        bcc slLoop
        rts

;===============================================================================

showLogoDX
        mva #0, logoFrame
        ldx #0
        stx logoSprite

sldxLoop
        lda logoXArray,X
        sta logoX
        lda logoYArray,X
        sta logoY
        lda logoModeArray,X
        sta logoMode
        lda logoColorArray,X
        sta logoColor

        jsr setLogoFrame

        ; loop for each frame
        inc logoSprite
        inc logoFrame
        inx
        cpx #8
        bcc sldxLoop
        rts


;===============================================================================

hideLogo
        ldx #0

hlLoop
        stx logoSprite
        LIBSPRITE_ENABLE_AV logoSprite, False
        inx
        cpx #8
        bcc hlLoop
        rts

;===============================================================================

setLogoFrame
        LIBSPRITE_MULTICOLORENABLE_AA logoSprite, logoMode
        LIBSPRITE_SETFRAME_AA         logoSprite, logoFrame
        LIBSPRITE_SETPOSITION_AAAA    logoSprite, #0, logoX, logoY
        LIBSPRITE_ENABLE_AV           logoSprite, True
        LIBSPRITE_SETCOLOR_AA         logoSprite, logoColor
        rts

;===============================================================================

showMenu
        DRAWTEXT_AAAV #11, #04, community, LightGreen
        DRAWTEXT_AAAV #14, #11, menu1, MenuColor
        DRAWTEXT_AAAV #14, #13, menu2, MenuColor
        ldx menuOption
        lda menuYArray,X
        sta menuY
        SETCHARPOSITION_AA #14,menuY
        SETCHAR_V CursorCharacter
        SETCOLORPOSITION_AA #14,menuY
        SETCHAR_V Yellow
        COLORTEXT_AAAA #15, menuY, #MenuHighlight, #10
        lda #0
        rts

;===============================================================================

clearMenu
        jsr hideLogo
        SET1000 SCREENRAM, SpaceCharacter
        SET1000 SCREENMEM, SpaceCharacter

        ; Restore
        mva vicReg1, CI2PRA
        mva vicReg2, VMCSB
        WRITE_AAAV #15, #13, loading1, White
        rts

;===============================================================================

updateMenu
        LIBINPUT_GETFIREPRESSED
        beq select
        lda flowJoystick
        bne decJoystick
        mva #JoyStickDelay, flowJoystick

joyUp
        LIBINPUT_GETHELD GameportUpMask
        bne joyDown
        lda menuOption
        beq return
        dec menuOption
        jmp refreshMenu

joyDown
        LIBINPUT_GETHELD GameportDownMask
        bne return
        lda menuOption
        cmp #1
        bcs return
        inc menuOption
        jmp refreshMenu

decJoystick
        dec flowJoystick
        lda #0
        rts

refreshMenu
        DRAWTEXT_AAAV #14, #18, clearError, Red ; clear error message (if there)
        jmp showMenu

return
        lda #0
        rts

select
        lda menuOption
        cmp #1
        beq showDX

loadEn
        jsr clearMenu
        jsr setFileEn
        jmp loadGame

showDX
        jsr showLogoDX
        SET1000 SCREENRAM, SpaceCharacter
        DRAWTEXT_AAAV #02, #07, dxLine0, LightBlue
        DRAWTEXT_AAAV #02, #08, dxLine1, Cyan
        DRAWTEXT_AAAV #02, #09, dxLine2, Green
        DRAWTEXT_AAAV #02, #10, dxLine3, LightGreen
        DRAWTEXT_AAAV #02, #11, dxLine4, Yellow
        DRAWTEXT_AAAV #02, #12, dxLine5, Orange
        DRAWTEXT_AAAV #02, #13, dxLine6, Red
        DRAWTEXT_AAAV #02, #14, dxLine7, LightRed
        DRAWTEXT_AAAV #02, #15, dxLine8, Purple
        DRAWTEXT_AAAV #02, #17, dxLine9, LightGreen
        CharsOnScreen 16, 19, joystickChars, joystickColors, 42

loopDX
        WAIT_V 255
        jsr libInputUpdate
        LIBINPUT_GETFIREPRESSED
        bne loopDX
        jsr hideLogo
        mva #0, menuOption
        SET1000 SCREENRAM, SpaceCharacter
        jmp menuDraw
        
#endregion
#region Binary Load Assets
;==============================================================================

SCREENMEM       = $0400
SCREENRAM       = $4800
SPRITE0         = SCREENRAM + $03F8

; Splash screen bitmap
BITMAPRAM       = $2000
* = $2000
        incbin "..\assets\splash.kla",2

; 192 decimal * 64(sprite size) = 12288(hex $3000)
SPRITERAM       = 64
* = $5000
        incbin "sprites.spt",82,89,true

* = $5800
        ; letters and numbers from the font "Teggst shower 5"
        ; http://kofler.dot.at/c64/download/teggst_shower_5.zip
        incbin "characters.cst",0,178

#endregion
#region Disk Game Loader
;===============================================================================
* = $6000
loadGame
        lda #$08
        ldx $ba         ;Read from current disk drive present
        ldy #$01
        jsr SETLFS      ;Is device present?
        lda #$00
        jsr LOAD
        bcs loadError   ; if carry set, a load error has happened

        jsr CLOSE          
        jsr CLRCHN
        
        jmp $080D       ;Exomized prg entry point

loadError
        ; Accumulator contains BASIC error code
        ; most likely errors:
        ; A = $05 (DEVICE NOT PRESENT)
        ; A = $04 (FILE NOT FOUND)
        ; A = $1D (LOAD ERROR)
        ; A = $00 (BREAK, RUN/STOP has been pressed during loading)
        DRAWTEXT_AAAV #14, #18, loadingError, Red
        jmp menuDraw

;===============================================================================
setFileEn
        lda #fen_end-fen
        ldx #<fen
        ldy #>fen
        jmp SETNAM

fen     text "ret-en"
fen_end

#endregion
#region Constants & Variables
;===============================================================================
; Zero Page

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
                ; $FF       Reserved for Kernal

;===============================================================================
; Constants

; Color Codes
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

MenuColor       = LightBlue
MenuHighlight   = White

XC              = Cyan
XW              = Cyan
XB              = Cyan
XE              = Black

SpaceCharacter  = 32
CursorCharacter = 94

False           = 0
True            = 1

LogoXPos        = 110
LogoYPos        = 52


JoyStickDelay   = 10

MAXSPR          = 8

;===============================================================================
; Variables

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

ScreenMEMRowStartLow ;  ScreenMEM + 40*0, 40*1, 40*2 ... 40*24
                byte <SCREENMEM,     <SCREENMEM+40,  <SCREENMEM+80
                byte <SCREENMEM+120, <SCREENMEM+160, <SCREENMEM+200
                byte <SCREENMEM+240, <SCREENMEM+280, <SCREENMEM+320
                byte <SCREENMEM+360, <SCREENMEM+400, <SCREENMEM+440
                byte <SCREENMEM+480, <SCREENMEM+520, <SCREENMEM+560
                byte <SCREENMEM+600, <SCREENMEM+640, <SCREENMEM+680
                byte <SCREENMEM+720, <SCREENMEM+760, <SCREENMEM+800
                byte <SCREENMEM+840, <SCREENMEM+880, <SCREENMEM+920
                byte <SCREENMEM+960

SCREENMEMRowStartHigh ;  SCREENMEM + 40*0, 40*1, 40*2 ... 40*24
                byte >SCREENMEM,     >SCREENMEM+40,  >SCREENMEM+80
                byte >SCREENMEM+120, >SCREENMEM+160, >SCREENMEM+200
                byte >SCREENMEM+240, >SCREENMEM+280, >SCREENMEM+320
                byte >SCREENMEM+360, >SCREENMEM+400, >SCREENMEM+440
                byte >SCREENMEM+480, >SCREENMEM+520, >SCREENMEM+560
                byte >SCREENMEM+600, >SCREENMEM+640, >SCREENMEM+680
                byte >SCREENMEM+720, >SCREENMEM+760, >SCREENMEM+800
                byte >SCREENMEM+840, >SCREENMEM+880, >SCREENMEM+920
                byte >SCREENMEM+960

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


boxMenuChars    byte $69,$67,$67,$67,$67,$67,$67,$67,$67,$67,$67,$67,$67,$67,$6E,$00
                byte $6A,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$6A,$00
                byte $6A,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$6A,$00
                byte $6A,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$6A,$00
                byte $6D,$67,$67,$67,$67,$67,$67,$67,$67,$67,$67,$67,$67,$67,$68,$00

boxMenuColors   byte XC,XW,XW,XW,XW,XW,XW,XW,XW,XW,XW,XW,XW,XW,XC,$00
                byte XB,XE,XE,XE,XE,XE,XE,XE,XE,XE,XE,XE,XE,XW,XB,$00
                byte XB,XE,XE,XE,XE,XE,XE,XE,XE,XE,XE,XE,XE,XW,XB,$00
                byte XB,XE,XE,XE,XE,XE,XE,XE,XE,XE,XE,XE,XE,XC,XB,$00
                byte XC,XW,XW,XW,XW,XW,XW,XW,XW,XW,XW,XW,XW,XW,XC,$00

community       text 'community edition'
                byte $00
menu1           text ' load game'
                byte $00
menu2           text ' dx edition'
                byte $00

joystickChars   byte $20,$20,$20,$A6,$20,$20,$00
                byte $20,$20,$A7,$A8,$20,$20,$00
                byte $20,$A9,$AA,$AB,$AC,$20,$00
                byte $20,$AD,$AE,$AF,$B0,$20,$00
                byte $20,$20,$B1,$B2,$20,$20,$00
                byte 'p','o','r','t',' ','2',$00

joystickColors  byte $00,$00,$00,$01,$00,$00,$00
                byte $00,$00,$01,$01,$00,$00,$00
                byte $00,$01,$01,$01,$02,$00,$00
                byte $00,$01,$01,$01,$01,$00,$00
                byte $00,$00,$01,$01,$00,$00,$00
                byte $01,$01,$01,$01,$01,$01,$00

dxline0         text '* available as digital download'
                byte $00
dxline1         text '* in english, portuguese and spanish'
                byte $00
dxline2         text '* support snes gamepad on user port '
                byte $00
dxline3         text '* new menu sid music and improved sfx'
                byte $00
dxline4         text '* amazing graphics by trevor storey'
                byte $00
dxline5         text '* two ship models with double cannons'
                byte $00
dxline6         text '* 6 different probes & escort enemies'
                byte $00
dxline7         text '* 18 additional wave formations'
                byte $00
dxline8         text '* space station end scene and tune'
                byte $00
dxline9         text 'buy now at https://lvcabral.itch.io'
                byte $00
                

loading1        text 'loading...'
                byte $00
loadingError    text 'load error!'
                byte $00
clearError      text '           '
                byte $00

menuOption      byte $00
menuYArray      byte  11,  13,  15
menuY           byte $00

logoXArray      byte LogoXPos   , LogoXPos+24, LogoXPos+48, LogoXPos+72
                byte LogoXPos+96, LogoXPos+120, LogoXPos+96, LogoXPos+120

logoYArray      byte LogoYPos, LogoYPos, LogoYPos, LogoYPos
                byte LogoYPos, LogoYPos, LogoYPos+21, LogoYPos+21

logoModeArray   byte True, True, True, True, True, True, False, False

logoColorArray  byte LightBlue, LightBlue, LightBlue, LightBlue
                byte LightBlue, LightBlue, Red, Red

logoSprite      byte $00
logoFrame       byte $00
logoX           byte $00
logoY           byte $00
logoMode        byte $00
logoColor       byte $00

flowJoystick    byte $00

vicReg1         byte $00
vicReg2         byte $00

#endregion
#region Macros
;==============================================================================
; Macros

defm    WAIT_V                  ; /1 = Scanline (Value)

@loop   lda #/1                 ; Scanline -> A
        cmp RASTER              ; Compare A to current raster line
        bne @loop               ; Loop if raster line not reached 255

        endm

;===============================================================================

defm    SETCHARMEMORY  ; /1 = Character Memory Slot (Value)
        ; point vic (lower 4 bits of $D018)to new character data
        lda VMCSB
        and #%11110000 ; keep higher 4 bits
        ; p208 M Jong book
        ora #/1;$0E ; maps to  $3800 memory address
        sta VMCSB
        endm


;==============================================================================

defm    SETCHAR_A  ; /1 = Character Code (Value)
        lda /1
        sta (ZeroPageLow),Y
        endm

;==============================================================================

defm    SETCHAR_V  ; /1 = Character Code (Value)
        lda #/1
        sta (ZeroPageLow),Y
        endm

;==============================================================================

defm    SETCHARPOSITION_AA              ; /1 = X Position 0-39 (Address)
                                        ; /2 = Y Position 0-24 (Address)
        
        ldy /2 ; load y position as index into list
        
        lda ScreenRAMRowStartLow,Y ; load low address byte
        sta ZeroPageLow

        lda ScreenRAMRowStartHigh,Y ; load high address byte
        sta ZeroPageHigh

        ldy /1 ; load x position into Y register

        endm

;==============================================================================

defm    SETCOLORPOSITION_AA             ; /1 = X Position 0-39 (Address)
                                        ; /2 = Y Position 0-24 (Address)

        ldy /2 ; load y position as index into list

        lda ColorRAMRowStartLow,Y ; load low address byte
        sta ZeroPageLow

        lda ColorRAMRowStartHigh,Y ; load high address byte
        sta ZeroPageHigh

        ldy /1 ; load x position into Y register

        endm

;==============================================================================

defm    WRITE_AAAV              ; /1 = X Position 0-39 (Address)
                                ; /2 = Y Position 0-24 (Address)
                                ; /3 = 0 terminated string (Address)
                                ; /4 = Text Color (Value)

        ldy /2 ; load y position as index into list

        lda ScreenMEMRowStartLow,Y ; load low address byte
        sta ZeroPageLow

        lda ScreenMEMRowStartHigh,Y ; load high address byte
        sta ZeroPageHigh

        ldy /1 ; load x position into Y register

        ldx #0
@loop   lda /3,X

        beq donew

        sta (ZeroPageLow),Y
        inx
        iny
        jmp @loop
donew

        ldy /2 ; load y position as index into list

        lda ColorRAMRowStartLow,Y ; load low address byte
        sta ZeroPageLow

        lda ColorRAMRowStartHigh,Y ; load high address byte
        sta ZeroPageHigh

        ldy /1 ; load x position into Y register

        ldx #0
@loop2  lda /3,X
        beq @donew2
        lda #/4
        sta (ZeroPageLow),Y
        inx
        iny
        jmp @loop2
@donew2

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

defm    COLORTEXT_AAAA           ; /1 = X Position 0-39 (Address)
                                 ; /2 = Y Position 0-24 (Address)
                                 ; /3 = Text Color (Address)
                                 ; /4 = Number of characters to color (Address)

        ldy /2 ; load y position as index into list

        lda ColorRAMRowStartLow,Y ; load low address byte
        sta ZeroPageLow

        lda ColorRAMRowStartHigh,Y ; load high address byte
        sta ZeroPageHigh

        ldy /1 ; load x position into Y register

        lda /4
        sta ZeroPageTemp

        ldx #0
@loop   cpx ZeroPageTemp
        beq @done
        lda /3
        sta (ZeroPageLow),Y
        inx
        iny
        jmp @loop
@done

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

;==============================================================================
; Sets the border and background colors

defm    SETCOLORS               ; /1 = Border Color       (Value)
                                ; /2 = Background Color 0 (Value)
                                ; /3 = Background Color 1 (Value)
                                ; /4 = Background Color 2 (Value)
                                ; /5 = Background Color 3 (Value)

        lda #/1                 ; Color0 -> A
        sta EXTCOL              ; A -> EXTCOL
        lda #/2                 ; Color1 -> A
        sta BGCOL0              ; A -> BGCOL0
        lda #/3                 ; Color2 -> A
        sta BGCOL1              ; A -> BGCOL1
        lda #/4                 ; Color3 -> A
        sta BGCOL2              ; A -> BGCOL2
        lda #/5                 ; Color4 -> A
        sta BGCOL3              ; A -> BGCOL3

        endm

;==============================================================================

charX   byte 0
charY   byte 0
charN   byte 0
charC   byte 0

defm    CharsOnScreen           ; /1 = Screen X       (Value)
                                ; /2 = Screen Y       (Value)
                                ; /3 = Char Array     (Address)
                                ; /4 = Color Array    (Address)
                                ; /5 = Array Size     (Value)
        lda #/1
        sta charX
        lda #/2
        sta charY
        ldx #0

@scbLoop
        lda /4,X
        sta charC
        lda /3,X
        sta charN
        bne @scbSetChar
        lda #/1
        sta charX
        inc charY
        jmp @scbNext

@scbSetChar
        jsr setCharOnScreen
        inc charX

@scbNext
        ; loop for each char
        inx
        cpx #/5
        bcc @scbLoop
        endm
;==============================================================================

setCharOnScreen
        SETCHARPOSITION_AA charX, charY
        SETCHAR_A charN
        SETCOLORPOSITION_AA charX, charY
        SETCHAR_A charC
        rts
#endregion