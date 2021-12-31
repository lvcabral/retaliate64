;===============================================================================
;  buildGame.asm - Build configuration module
;
;  Copyright (C) 2019-2021 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
; Requires CBM prg Studio 3.13.1 or later
; Press Ctrl+F6 to build the prg file or Ctrl+F5 to build and run with emulator

GenerateTo "..\out\retaliate-ce.prg"

;===============================================================================
; Trainers and Debug Switches (0 = disables trainer)

STARTWAVE       = 0     ; id of first wave
SEQUENTIALWAVES = 0     ; if true, disables random wave selection
MINESFROMSTART  = 0     ; if true, enables mines to be shown from first wave
NUMOFWAVES      = 0     ; # of waves per stage (needs to be >= 2)
NUMOFSTAGES     = 0     ; # of stages per game (needs to be >= 2 and <= 9)

NOCOLLISION     = 0     ; if true, disables all collision with player ship
IMMORTAL        = 0     ; if true, player can't die, but can collect and kill
UNLOCKALL       = 0     ; if true, unlocks all ship models
FULLBULLETS     = 0     ; if true, player has unlimited bullets

SHOWRNDSEED     = 0     ; if true, displays random seed on screen
SHOWWAVEID      = 0     ; if true, displays current wave ID on screen
SHOWTIMER       = 0     ; if true, shows game timer over hi-score area
