;===============================================================================
;  buildGame.asm - Build configuration module
;
;  Copyright (C) 2019-2020 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
; Requires CBM prg Studio 3.13.1 or later
; Press Ctrl+F6 to build the prg file or Ctrl+F5 to build and run with emulator

GenerateTo retaliate-ce.prg

;===============================================================================
; Trainers and Debug Switches (0 = disable trainer)

STARTWAVE       = 0     ; id of first wave
SEQUENTIALWAVES = 0     ; if true, disables random wave selection
MINESFROMSTART  = 0     ; if true, enables mines to be shown from first wave
NUMOFWAVES      = 0     ; # of custom waves per stage (needs to be >= 2)
NUMOFSTAGES     = 0     ; # of custom stages per game (needs to be >= 2)

NOCOLLISION     = 0     ; if true, disables all collision with player ship
UNLOCKALL       = 0     ; if true, unlocks all ships and medals
FULLBULLETS     = 0     ; if true, player has unlimited bullets

SHOWRNDSEED     = 0     ; if true, displays random seed on screen
SHOWWAVEID      = 0     ; if true, displays curren wave ID on screen
SHOWTIMER       = 0     ; if true, shows game timer over hi-score area
