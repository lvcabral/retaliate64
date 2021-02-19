;===============================================================================
;  gameData.asm - Load/Save game data from/to Disk
;
;  Copyright (C) 2018 Marcelo Lv Cabral - <https://lvcabral.com>
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
; 3 bytes for highscore normal
; 3 bytes for highscore hard
; 3 bytes for highscore extreme
; 1 byte for ship frame index
; 1 byte for ship color index
; 1 byte for shield color index
; 1 byte for disable sound effects (boolean)
; 1 byte for disable music (boolean)
; 1 byte for dificulty level index
; 1 byte for ships and medals lock bit flags
ENDOFFILE       = $0354
DATASIZE        = ENDOFFILE - GAMEDATA
HISCORES        = GAMEDATA+1

;===============================================================================
; Variables

hiScoresOffset  byte 0, 3, 6, 9
dataErrorFlag   byte 0

diskErrorCode   byte 0

scratch         byte $53,$30,$3A ;"s0:"
fname           byte "retdata"
fname_end

;===============================================================================
; Subroutines

gameDataLoad
        jsr gameDataLoadDisk
        lda dataErrorFlag
        beq gDLCopy
        rts                     ; return with any disk error

gDLCopy
        ; Check data file version
        lda GAMEDATA
        cmp #DATAVERSION
        beq gDLLoad
        rts                     ; return with invalid or inexistent data file

gDLLoad
        ; Copy data to global variables
        lda GAMEDATA+13
        cmp #PlayerMaxModels
        bcs gDLPlayer           ; Ignore if is invalid index
        sta playerFrameIndex
        sta modelFrameIndex

gDLPlayer
        lda GAMEDATA+14
        cmp #MaxColors
        bcs gDLShield           ; Ignore if is invalid index
        sta shipColorIndex

gDLShield
        lda GAMEDATA+15
        cmp #MaxColors
        bcs gDLShield           ; Ignore if is invalid index
        sta shldColorIndex

gDLSfx
        mva GAMEDATA+16, soundDisabled

gDLMusic
        mva GAMEDATA+17, sidDisabled

gDLLevel
        ldx GAMEDATA+18
        cpx #4
        bcs gDLLocked           ; Ignore if is invalid level
        stx levelNum
        jsr gameDataGetHiScore

gDLLocked
if UNLOCKALL = 1
        ; Debug: Enable all ships and medals
        lda #$FF
else
        lda GAMEDATA+19
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

gameDataSave
        ; Copy global variables data
        mva #DATAVERSION, GAMEDATA
        mva playerFrameIndex, GAMEDATA+13
        mva shipColorIndex, GAMEDATA+14
        mva shldColorIndex, GAMEDATA+15
        mva soundDisabled, GAMEDATA+16
        mva sidDisabled, GAMEDATA+17
        mva levelNum, GAMEDATA+18
        mva unlockFlags, GAMEDATA+19
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
