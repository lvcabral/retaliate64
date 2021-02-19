;===============================================================================
;  resEnglish.asm - English Text Resources
;
;  Copyright (C) 2018,2019 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
* = $8000
; Menu Screens
MAPRAM
        ; Export List: 1-7(9),1-7(10),1-7(11),1-7(12),1-7(13),1-7(14),1-7(15),1-7(16),1-7(17),1-7(18),1-7(19),1-7(20),1-7(21),1-7(22)
        incbin "screens.bin"

;===============================================================================
;Constants

ScoreX       = 5
ScoreY       = 0
ScoreValX    = 11
HiScoreX     = 26
AmmoX        = 28
AmmoValX     = 33
StageEndX    = 12
StageEndY    = 11
GameEndX     = 11
GameEndY     = 11
PauseTextX   = 15
PauseTextY   = 12
MenuStartX   = 7
MenuStartLen = 10
MenuHangarX  = 20
MenuHangarLen= 11
MenuColorX   = 2
ModelTitleX  = 24
ModelTitleY  = 8
ModelNameX   = 21
ModelNameY   = 18
MusicX       = 8
MusicY       = 15
SfxX         = 8
SfxY         = 17
LevelX       = 8
LevelY       = 19
MsgPosX      = 2
MsgPosY      = 21
MenuExitX    = 21
MsgHangarX   = 2
MsgHangarY   = 23

;===============================================================================
; Game Flow text

flowScoreText   text 'score:'
                byte 0
flowHiScoreText text 'hi:'
                byte 0
flowAmmoText    text 'ammo:'
                byte 0
stageEndText    text 'stage '
stageNumChar    byte $30
                text ' completed'
                byte $00
gamePauseText   text 'game paused'
                byte $00
gameEndText1    text 'contratulations pilot'
                byte $00
gameEndText2    text '  mission complete   '
                byte $00

;===============================================================================
; Game Menu text

levelEasyText   text 'easy   '
                byte 0
levelNormalText text 'normal '
                byte 0
levelHardText   text 'hard   '
                byte 0
levelXtremeText text 'extreme'
                byte 0
modelTitle      text 'select model'
                byte 0
lockedTitle     text 'unlock model'
                byte 0
modelNamesLn1   text '                  '
                byte 0,0
                text '                  '
                byte 0,0
                text '     dynamic      '
                byte 0,0
                text '                  '
                byte 0,0
                text '     ruthless     '
                byte 0,0
modelNamesLn2   text '   old faithful   '
                byte 0,0
                text '  sturdy striker  '
                byte 0,0
                text '    destroyer     '
                byte 0,0
                text ' arced assailant  '
                byte 0,0
                text '    retaliator    '
                byte 0,0
lockedNamesLn1  text '                  '
                byte 0,0
                text ' make 1000 points '
                byte 0,0
                text ' make 1000 points '
                byte 0,0
                text ' make 1000 points '
                byte 0,0
                text ' make 1000 points '
                byte 0,0
lockedNamesLn2  text '   old faithful   '
                byte 0,0
                text '  on easy level   '
                byte 0,0
                text '  on normal level '
                byte 0,0
                text '  on hard level   '
                byte 0,0
                text ' on extreme level '
                byte 0,0
statsMsgBad     text ' keep practicing, you will improve! '
                byte 0
statsMsgHigh    text '     new high score, great job!     '
                byte 0
statsMsgShip    text '     you unlocked a new spaceship!  '
                byte 0
statsMsgMedal   text '     great flight, you won a medal! '
                byte 0
menuSaving      text '           saving on disk...         '
                byte 0
menuSaveOK      text '    high score and settings saved    '
                byte 0
menuSaveError   text ' error saving high score and settings'
                byte 0
hangarXArray    byte 5,  4,  1,  3,  1,  1, 14, 26, 23
hangarYArray    byte 9, 12, 15, 17, 19, 23, 23, 23,  8
hangarSizeArray byte 4,  6,  6,  4,  6, 10,  9, 11, 12
hangarOptsChr   byte $20
                text ' start game   save data   exit hangar '
                byte $20
hangarOptsClr   byte $0E,$07,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$01,$01,$07
                byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$01,$01,$07,$0E,$0E,$0E
                byte $0E,$01,$0E,$0E,$0E,$0E,$0E,$0E,$01,$0E
menuOptsChr     byte $20,$20,$20,$20,$20,$20,$20
                text ' start game   open hangar '
                byte $20,$20,$20,$20,$20,$20,$20
menuOptsClr     byte $05,$00,$06,$00,$0E,$0E,$03,$07,$0E,$0E,$0E,$0E,$0E,$0E,$0E
                byte $0E,$0E,$0E,$0D,$01,$07,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
                byte $0E,$0E,$0D,$03,$0E,$0E,$0E,$06,$00,$05
