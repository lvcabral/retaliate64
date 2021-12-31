;===============================================================================
;  gameData.asm - Load/Save game data from/to Disk
;
;  Copyright (C) 2018-2021 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
;
; Disk routines adapted from the code posted at Codebase 64 website:
; http://codebase64.org/doku.php?id=base:dos_examples
;
;===============================================================================
; Constants

DATAVERSION     = 1

GAMEDATA        = $0340
; 1 byte for version of data file
; 3 bytes for highscore easy
; 1 byte for stage easy
; 3 bytes for highscore normal
; 1 byte for stage normal
; 3 bytes for highscore hard
; 1 byte for stage hard
; 3 bytes for highscore extreme
; 1 byte for stage extreme
; 1 byte for ship frame index
; 1 byte for ship color index
; 1 byte for shield color index
; 1 byte for disable sound effects (boolean)
; 1 byte for disable music (boolean)
; 1 byte for dificulty level index
; 1 byte for ships and medals lock bit flags
ENDOFFILE       = $0358
DATASIZE        = ENDOFFILE - GAMEDATA ; 24 bytes
HISCORES        = GAMEDATA+1
SHIPFRAMEIDX    = GAMEDATA+17
SHIPCOLORIDX    = GAMEDATA+18
SHLDCOLORIDX    = GAMEDATA+19
SOUNDFLAG       = GAMEDATA+20
MUSICFLAG       = GAMEDATA+21
DIFFLEVEL       = GAMEDATA+22
UNLKFLAGS       = GAMEDATA+23

;===============================================================================
; Variables

hiScoresOffset  byte 0, 4, 8, 12
dataErrorFlag   byte 0

diskErrorCode   byte 0

scratch         byte $53,$30,$3A ;"s0:"
fname           text "retdata"
fname_end

;===============================================================================
; Subroutines

gameDataLoad
        jsr gameDataLoadDisk
        lda dataErrorFlag
        beq gDLCopy             ; return with any disk error
        jmp gameDataClearHiScore

gDLCopy
        ; Check data file version
        lda GAMEDATA
        cmp #DATAVERSION
        beq gDLLoad             ; return with invalid or inexistent data file
        jmp gameDataClearHiScore

gDLLoad
        ; Copy data to global variables
        lda SHIPFRAMEIDX
        cmp #PlayerMaxModels
        bcs gDLPlayer           ; Ignore if is invalid index
        sta playerFrameIndex
        sta modelFrameIndex

gDLPlayer
        lda SHIPCOLORIDX
        cmp #MaxColors
        bcs gDLShield           ; Ignore if is invalid index
        sta shipColorIndex

gDLShield
        lda SHLDCOLORIDX
        cmp #MaxColors
        bcs gDLShield           ; Ignore if is invalid index
        sta shldColorIndex

gDLSfx
        mva SOUNDFLAG, soundDisabled

gDLMusic
        mva MUSICFLAG, sidDisabled

gDLLevel
        ldx DIFFLEVEL
        cpx #4
        bcs gDLLocked           ; Ignore if is invalid level
        stx levelNum
        jsr gameDataGetHiScore

gDLLocked
if UNLOCKALL = 1
        ; Debug: Enable all ships
        lda #$0F
else
        lda UNLKFLAGS
endif
        sta unlockFlags
        rts

;===============================================================================

gameDataGetHiScore
        ; X must have current level
        ldy hiScoresOffset,X
        lda HISCORES,Y
        sta hiscore3
        iny
        lda HISCORES,Y
        sta hiscore2
        iny
        lda HISCORES,Y
        sta hiscore1
        rts
;===============================================================================

gameDataClearHiScore
        ldx #0
        lda #0

gDCHSLoop
        sta HISCORES,X
        inx
        cpx #12
        bcc gDCHSLoop
if UNLOCKALL = 1
        ; Debug: Enable all ships
        lda #$0F
        sta unlockFlags
endif
        rts

;===============================================================================

gameDataSave
        ; Copy global variables data
        mva #DATAVERSION, GAMEDATA
        mva playerFrameIndex, SHIPFRAMEIDX
        mva shipColorIndex, SHIPCOLORIDX
        mva shldColorIndex, SHLDCOLORIDX
        mva soundDisabled, SOUNDFLAG
        mva sidDisabled, MUSICFLAG
        mva levelNum, DIFFLEVEL
        mva unlockFlags, UNLKFLAGS
        ; Clear error flag
        mva #0, dataErrorFlag
        ; Save data
        jmp gameDataSaveDisk
;===============================================================================

gameDataLoadDisk
        ; Read data from disk
        mva #0, dataErrorFlag   ; Clear error flag
        jsr setFileName
        lda #$01
        ldx $BA                 ; last used device number
        bne gDLSkip
        ldx #$08                ; default to device 8

gDLSkip
        ldy #$01                ; not $01 means: load to address stored in file
        jsr SETLFS

        lda #$00                ; $00 means: load to memory (not verify)
        jsr LOAD
        bcs gDLError            ; if carry set, a load error has happened

        lda #$01
        jmp CLOSE
        
gDLError
        ; Accumulator contains BASIC error code
        ; most likely errors:
        ; A = $05 (DEVICE NOT PRESENT)
        ; A = $04 (FILE NOT FOUND)
        ; A = $1D (LOAD ERROR)
        ; A = $00 (BREAK, RUN/STOP has been pressed during loading)
        sta diskErrorCode
        inc dataErrorFlag
        rts

;===============================================================================

gameDataSaveDisk
        ; Erase old file
        lda #$0F
        ldy #$0F
        ldx $BA
        bne gSSSkip
        ldx #$08

gSSSkip
        jsr SETLFS
        lda #fname_end-scratch
        ldx #<scratch
        ldy #>scratch
        jsr SETNAM
        jsr OPEN
        bcc gSSNoError
        sta diskErrorCode
        inc dataErrorFlag

gSSNoError
        lda #$0F
        jsr CLOSE
        jsr CLRCHN
        ; Save new file to disk
        lda #$FF
        ldy #$00
        jsr setFileName
        mva #<GAMEDATA, ZeroPageTemp1
        mva #>GAMEDATA, ZeroPageTemp2
        ldx #<ENDOFFILE
        ldy #>ENDOFFILE
        lda #ZeroPageTemp1
        jsr SAVE
        bcc gSSDone
        sta diskErrorCode
        inc dataErrorFlag

gSSDone
        rts

;===============================================================================

setFileName
        lda #fname_end-fname
        ldx #<fname
        ldy #>fname
        jmp SETNAM
