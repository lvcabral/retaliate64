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
; Adapted from the code posted at Codebase 64 website:
; http://codebase64.org/doku.php?id=base:dos_examples

;===============================================================================
; Constants

GAMEDATA        = $0340
; 3 bytes for highscore
; 2 bytes for ship frame + color
; 1 byte for shield color
; 1 byte for disable sound effects
; 1 byte for disable music
; 1 byte for dificulty level
; 1 byte for future use
ENDOFFILE       = $034A

;===============================================================================
; Variables

diskErrorFlag   byte 0
diskErrorCode   byte 0

scratch         byte $53,$30,$3A ;"s0:"
fname           byte "retdata"
fname_end

;===============================================================================
; Subroutines

gameDataLoad
        ; Read data from disk
        lda #0
        sta diskErrorFlag ; Clear error flag
        jsr setFileName
        lda #$01
        ldx $BA       ; last used device number
        bne gDLSkip
        ldx #$08      ; default to device 8
gDLSkip
        ldy #$01      ; not $01 means: load to address stored in file
        jsr SETLFS

        lda #$00      ; $00 means: load to memory (not verify)
        jsr LOAD
        bcs gDLError  ; if carry set, a load error has happened

        lda #$01
        jsr CLOSE

        ; Copy data to global variables
        lda GAMEDATA
        sta hiscore1
        lda GAMEDATA + 1
        sta hiscore2
        lda GAMEDATA + 2
        sta hiscore3
        lda GAMEDATA + 3
        cmp #PlayerMaxModels
        bcs gDLPlayer   ; Ignore if is invalid index
        sta playerFrameIndex
gDLPlayer
        lda GAMEDATA + 4
        beq gDLShield   ; Ignore if color is black
        sta shipColorIndex
gDLShield
        lda GAMEDATA + 5
        beq gDLSfx      ; Ignore if color is black
        sta shldColorIndex
gDLSfx
        lda GAMEDATA + 6
        sta soundDisabled
gDLMusic
        lda GAMEDATA + 7
        sta sidDisabled
gDLLevel
        lda GAMEDATA + 8
        cmp #4
        bcs gDLReturn   ; Ignore if is invalid level
        sta levelNum
        jmp gDLReturn
gDLError
        ; Accumulator contains BASIC error code
        ; most likely errors:
        ; A = $05 (DEVICE NOT PRESENT)
        ; A = $04 (FILE NOT FOUND)
        ; A = $1D (LOAD ERROR)
        ; A = $00 (BREAK, RUN/STOP has been pressed during loading)
        sta diskErrorCode
        inc diskErrorFlag
gDLReturn
        rts

;===============================================================================
gameDataSave
        lda #0
        sta diskErrorFlag ; Clear error flag

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
        inc diskErrorFlag
gSSNoError
        lda #$0F
        jsr CLOSE
        jsr CLRCHN

        ; Copy global variables data
        lda hiscore1
        sta GAMEDATA
        lda hiscore2
        sta GAMEDATA + 1
        lda hiscore3
        sta GAMEDATA + 2
        lda playerFrameIndex
        sta GAMEDATA + 3
        lda shipColorIndex
        sta GAMEDATA + 4
        lda shldColorIndex
        sta GAMEDATA + 5
        lda soundDisabled
        sta GAMEDATA + 6
        lda sidDisabled
        sta GAMEDATA + 7
        lda levelNum
        sta GAMEDATA + 8
        ; Save new file to disk
        lda #$FF
        ldy #$00
        jsr setFileName
        lda #<GAMEDATA
        sta ZeroPageTemp1
        lda #>GAMEDATA
        sta ZeroPageTemp2
        ldx #<ENDOFFILE
        ldy #>ENDOFFILE
        lda #ZeroPageTemp1
        jsr SAVE
        bcc gSSDone
        sta diskErrorCode
        inc diskErrorFlag
gSSDone
        rts

;===============================================================================
setFileName
        lda #fname_end-fname
        ldx #<fname
        ldy #>fname
        jmp SETNAM
        rts
