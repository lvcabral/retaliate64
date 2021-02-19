;===============================================================================
;  retdata.asm - Game Default Data File Generator
;
;  Copyright (C) 2018,2019 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
; Press F6 to build the prg file

GenerateTo retdata.prg

* = $0340
        byte 1        ; Data file version
        byte 0,0,0    ; High score easy
        byte 0,0,0    ; High score normal
        byte 0,0,0    ; High score hard
        byte 0,0,0    ; High score extreme
        byte 0        ; Player frame (array index)
        byte 1        ; Player color (array index)
        byte 5        ; Shield color (array index)
        byte 0        ; Disable SFX (boolean)
        byte 0        ; Disable Music (boolean)
        byte 1        ; Skill level (array index)
        byte 0        ; Unlocked ships (4 low bits)
                      ; Unlocked medals (4 high bits)
