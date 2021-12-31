;===============================================================================
;  libDefines.asm - C64 Constants of RAM/ROM Addresses
;  
;  Copyright (C) 2018-2021 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
; Names taken from 'Mapping the Commodore 64' book

MODE            = $0291
CINVLOW         = $0314
CINVHIGH        = $0315
ISTOP           = $0328

;===============================================================================
; C64 registers that are mapped into IO memory space

D6510           = $00
R6510           = $01
TIME0           = $A0
TIME1           = $A1
TIME2           = $A2
SP0X            = $D000
SP0Y            = $D001
MSIGX           = $D010
SCROLY          = $D011
RASTER          = $D012
SPENA           = $D015
SCROLX          = $D016
YXPAND          = $D017
VMCSB           = $D018
IRQFLAG         = $D019
IRQCTRL         = $D01A
SPBGPR          = $D01B
SPMC            = $D01C
XXPAND          = $D01D
SPSPCL          = $D01E
EXTCOL          = $D020
BGCOL0          = $D021
BGCOL1          = $D022
BGCOL2          = $D023
BGCOL3          = $D024
SPMC0           = $D025
SPMC1           = $D026
SP0COL          = $D027
FRELO1          = $D400 ;(54272)
FREHI1          = $D401 ;(54273)
PWLO1           = $D402 ;(54274)
PWHI1           = $D403 ;(54275)
VCREG1          = $D404 ;(54276)
ATDCY1          = $D405 ;(54277)
SUREL1          = $D406 ;(54278)
FRELO2          = $D407 ;(54279)
FREHI2          = $D408 ;(54280)
PWLO2           = $D409 ;(54281)
PWHI2           = $D40A ;(54282)
VCREG2          = $D40B ;(54283)
ATDCY2          = $D40C ;(54284)
SUREL2          = $D40D ;(54285)
FRELO3          = $D40E ;(54286)
FREHI3          = $D40F ;(54287)
PWLO3           = $D410 ;(54288)
PWHI3           = $D411 ;(54289)
VCREG3          = $D412 ;(54290)
ATDCY3          = $D413 ;(54291)
SUREL3          = $D414 ;(54292)
SIGVOL          = $D418 ;(54296)      
COLORRAM        = $D800
CIAPRA          = $DC00
CIAPRB          = $DC01
CIDDRA          = $DC02
CIDDRB          = $DC03
CIAICR          = $DC0D
CI2PRA          = $DD00
CI2ICR          = $DD0D

;===============================================================================
; Kernal Subroutines

IRQCONTINUE     = $EA81 ; libMultiplex
IRQFINISH       = $EA31
SCNKEY          = $FF9F ; testsound
GETIN           = $FFE4 ; testsound
CLOSE           = $FFC3 ; gameData (disk) and retaliate (loader)
OPEN            = $FFC0 ; gameData (disk) and retaliate (loader)
SETNAM          = $FFBD ; gameData (disk) and retaliate (loader)
SETLFS          = $FFBA ; gameData (disk) and retaliate (loader)
CLRCHN          = $FFCC ; gameData (disk) and retaliate (loader)
CHROUT          = $FFD2
LOAD            = $FFD5 ; gameData (disk) and retaliate (loader)
SAVE            = $FFD8 ; gameData (disk) and retaliate (loader)
RDTIM           = $FFDE ; gameFlow (random generator)

;==============================================================================
defm    mva
        lda /1
        sta /2
        endm

;==============================================================================
defm    txy
        stx ZeroPageTemp
        ldy ZeroPageTemp
        endm

;==============================================================================
defm    tyx
        sty ZeroPageTemp
        ldx ZeroPageTemp
        endm

;==============================================================================
; Copy Memory Params

SL              = ZeroPageLow
SH              = ZeroPageHigh
EL              = ZeroPageParam1
EH              = ZeroPageParam2
DL              = ZeroPageLow2
DH              = ZeroPageHigh2
T1              = ZeroPageTemp1
T2              = ZeroPageTemp2
