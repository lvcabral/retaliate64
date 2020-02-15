;===============================================================================
; libMusic.asm - Macros and subroutines to play SID music files.
; Plays nicely with the sound effects from libSound!
;
;  Copyright (C) 2018 Dion Olsthoorn - <http://www.dionoidgames.com>
;  Copyright (C) 2018 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;==============================================================================
; Constants

SIDFILTERREG = 23
SIDVOLUMEREG = 24
SIDREGSTART  = FRELO1

; Note: you need to swap around the voice-numbers of the sound effects so they 
; interfere less with the music's lead voice

;===============================================================================
; Variables

vicMode           byte 0         ; 0=NTSC 1=PAL (set on game startup)
sidCounter        byte 5         ; Counter to adjust PAL songs timing on NTSC
sidRegisterBuffer dcb 25, 0      ; SID register buffer
sidFilterCtrlMask byte %11111000 ; mask for the SID's filter control register
sidDisabled       byte 0         ; Flag to disable Music

;===============================================================================
; Macros/Subroutines

libMusicInit

        ; Push current ROM/RAM setup to stack
        lda $01
        pha
        ; Switch to I/O ROM only mode
        lda #$35
        sta $01

        ; Call SID init subroutine
        lda #SIDSONG
        tax
        tay
        jsr SIDINIT

        ; Switch back to previous RAM/ROM setup
        pla
        sta $01

        rts

;===============================================================================

libMusicUpdate
        ;inc EXTCOL
        ; Skip counter in PAL machines
        lda vicMode
        bne lMUPlayMusic

        ; Decrease play rate in 20% for NTSC
        lda sidCounter
        beq lMUSkip
        dec sidCounter
lMUPlayMusic
        ; Only play mixed if SFX is enabled
        lda soundDisabled
        beq sidPlayMixed
        jsr SIDPLAY
        ;dec EXTCOL
        rts
lMUSkip
        lda #5
        sta sidCounter
        ;dec EXTCOL
        rts
sidPlayMixed
        ;inc EXTCOL
        ; Push current ROM/RAM setup to stack
        lda $01
        pha
        sei
        ; Switch to RAM only
        lda #$34
        sta $01

        ; Call SID play subroutine
        ; This results in shadow RAM at $d400-$d418 getting modified
        jsr SIDPLAY

        ; Copy $d400-$d418 to sidRegisterBuffer
        ldy #$18
@copyLoop
        lda SIDREGSTART,Y
        sta sidRegisterBuffer,Y
        dey
        bpl @copyLoop

        ; Switch back to previous RAM/ROM setup
        pla
        sta $01
        cli
        ;inc EXTCOL
        ; check soundVoiceActive (libSound) to see which SID voices are active
        ; only write registers from sidRegisterBuffer back to $d400-$d418 
        ; for voices that aren't already playing a sound effect
        lda #%11111000
        sta sidFilterCtrlMask
checkvoice1
        lda soundVoiceActive
        bne checkvoice2
        LIBMUSIC_RESTORE_REGISTERS_VVA 0, 6, sidRegisterBuffer
        LIBMUSIC_UNMASK_VOICE_FILTER_VA %00000001, sidFilterCtrlMask
checkvoice2
        lda soundVoiceActive + 1
        bne checkvoice3
        LIBMUSIC_RESTORE_REGISTERS_VVA 7, 13, sidRegisterBuffer
        LIBMUSIC_UNMASK_VOICE_FILTER_VA %00000010, sidFilterCtrlMask
checkvoice3
        lda soundVoiceActive + 2
        bne checkvoicedone
        LIBMUSIC_RESTORE_REGISTERS_VVA 14, 20, sidRegisterBuffer
        LIBMUSIC_UNMASK_VOICE_FILTER_VA %00000100, sidFilterCtrlMask
checkvoicedone
        ; set filter voice mask
        lda sidFilterCtrlMask
        and sidRegisterBuffer + SIDFILTERREG
        sta sidRegisterBuffer + SIDFILTERREG

        ; change volume to lowest (this might be different from the original SID music)
        lda sidRegisterBuffer + SIDVOLUMEREG
        and #%11110000
        ora #%00000111
        sta sidRegisterBuffer + SIDVOLUMEREG

        ; copy Filter and Volume registers
        LIBMUSIC_RESTORE_REGISTERS_VVA 21, 24, sidRegisterBuffer
        ;inc EXTCOL
        rts

;===============================================================================

defm LIBMUSIC_RESTORE_REGISTERS_VVA     ; /1 = Start index (Value)
                                        ; /2 = End index (Value)
                                        ; /3 = RegisterBuffer (Address)
        ldx #/1
@restoreLoop
        lda /3,X
        sta SIDREGSTART,X
        inx
        cpx #/2 + 1
        bne @restoreLoop
        endm

;===============================================================================

defm LIBMUSIC_UNMASK_VOICE_FILTER_VA    ; /1 = VoiceBitMask (Value)
                                        ; /2 = VoiceFilterMask (Address)
        lda /2
        ora #/1 ; unmask filter for specific voice
        sta /2
        endm
