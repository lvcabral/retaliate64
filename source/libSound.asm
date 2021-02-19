;===============================================================================
;  libSound.asm - SID Sound related Macros
;
;  Copyright (C) 2017,2018 RetroGameDev - <https://www.retrogamedev.com>
;  Copyright (C) 2018 Marcelo Lv Cabral - <https://lvcabral.com>
;
;  Distributed under the MIT software license, see the accompanying
;  file LICENSE or https://opensource.org/licenses/MIT
;
;===============================================================================
; Constants

TriangleStart   = 17
TriangleEnd     = 16
SawtoothStart   = 33
SawtoothEnd     = 32
PulseStart      = 65
PulseEnd        = 64
NoiseStart      = 129
NoiseEnd        = 128

Attack_2ms      = 0
Attack_8ms      = 16    ; 1<<4
Attack_16ms     = 32    ; 2<<4
Attack_24ms     = 48    ; 3<<4
Attack_38ms     = 64    ; 4<<4
Attack_56ms     = 80    ; 5<<4
Attack_68ms     = 96    ; 6<<4
Attack_80ms     = 112   ; 7<<4
Attack_100ms    = 128   ; 8<<4
Attack_250ms    = 144   ; 9<<4
Attack_500ms    = 160   ; 10<<4
Attack_800ms    = 176   ; 11<<4
Attack_1s       = 192   ; 12<<4
Attack_3s       = 208   ; 13<<4
Attack_5s       = 224   ; 14<<4
Attack_8s       = 240   ; 15<<4

Decay_6ms       = 0
Decay_24ms      = 1
Decay_48ms      = 2
Decay_72ms      = 3
Decay_114ms     = 4
Decay_168ms     = 5
Decay_204ms     = 6
Decay_240ms     = 7
Decay_300ms     = 8
Decay_750ms     = 9
Decay_1_5s      = 10
Decay_2_4s      = 11
Decay_3s        = 12
Decay_9s        = 13
Decay_15s       = 14
Decay_24s       = 15

Sustain_Vol0    = 0
Sustain_Vol1    = 16    ; 1<<4
Sustain_Vol2    = 32    ; 2<<4
Sustain_Vol3    = 48    ; 3<<4
Sustain_Vol4    = 64    ; 4<<4
Sustain_Vol5    = 80    ; 5<<4
Sustain_Vol6    = 96    ; 6<<4
Sustain_Vol7    = 112   ; 7<<4
Sustain_Vol8    = 128   ; 8<<4
Sustain_Vol9    = 144   ; 9<<4
Sustain_Vol10   = 160   ; 10<<4
Sustain_Vol11   = 176   ; 11<<4
Sustain_Vol12   = 192   ; 12<<4
Sustain_Vol13   = 208   ; 13<<4
Sustain_Vol14   = 224   ; 14<<4
Sustain_Vol15   = 240   ; 15<<4

Release_6ms     = 0
Release_24ms    = 1
Release_48ms    = 2
Release_72ms    = 3
Release_114ms   = 4
Release_168ms   = 5
Release_204ms   = 6
Release_240ms   = 7
Release_300ms   = 8
Release_750ms   = 9
Release_1_5s    = 10
Release_2_4s    = 11
Release_3s      = 12
Release_9s      = 13
Release_15s     = 14
Release_24s     = 15

CmdWave                 = 0
CmdAttackDecay          = 1
CmdSustainRelease       = 2
CmdFrequencyHigh        = 3
CmdFrequencyLow         = 4
CmdPulseWidthHigh       = 5
CmdPulseWidthLow        = 6
CmdDelay                = 7
CmdEnd                  = 8

;===============================================================================
; Variables
soundDisabled           byte 0
soundVoiceActive        byte 0, 0, 0
soundVoiceCmdPtrHigh    byte 0, 0, 0
soundVoiceCmdPtrLow     byte 0, 0, 0
soundVoiceCmdIndex      byte 0, 0, 0
soundVoiceDelay         byte 0, 0, 0

;===============================================================================
; Pre-made sound effect comand buffers

soundFiring     byte CmdAttackDecay, Attack_2ms+Decay_6ms
                byte CmdSustainRelease, Sustain_Vol10+Release_6ms
                byte CmdWave, SawtoothStart
                byte CmdFrequencyHigh, 18
                byte CmdFrequencyLow, 209
                byte CmdDelay, 5
                byte CmdWave, SawtoothEnd

                byte CmdAttackDecay, Attack_2ms+Decay_6ms
                byte CmdSustainRelease, Sustain_Vol10+Release_6ms
                byte CmdWave, SawtoothStart
                byte CmdFrequencyHigh, 22
                byte CmdFrequencyLow, 96
                byte CmdDelay, 5
                byte CmdWave, SawtoothEnd

                byte CmdEnd

soundFiringHigh byte >soundFiring
soundFiringLow  byte <soundFiring

;-------------------------------------------------------------------------------
; Explosion sound effects

soundExplosion  byte CmdWave, NoiseEnd
                byte CmdAttackDecay, Attack_38ms+Decay_114ms
                byte CmdSustainRelease, Sustain_Vol10+Release_300ms
                byte CmdFrequencyHigh, 21
                byte CmdFrequencyLow, 31
                byte CmdWave, NoiseStart
                byte CmdDelay, 20
                byte CmdWave, NoiseEnd
                byte CmdEnd

soundExplosionHigh byte >soundExplosion
soundExplosionLow  byte <soundExplosion

;-------------------------------------------------------------------------------

soundPickup     byte CmdAttackDecay, Attack_2ms+Decay_6ms
                byte CmdSustainRelease, Sustain_Vol10+Release_6ms
                byte CmdFrequencyHigh, 84
                byte CmdFrequencyLow, 125
                byte CmdWave, SawtoothStart
                byte CmdDelay, 5
                byte CmdWave, SawtoothEnd

                byte CmdAttackDecay, Attack_2ms+Decay_6ms
                byte CmdSustainRelease, Sustain_Vol10+Release_300ms
                byte CmdFrequencyHigh, 100
                byte CmdFrequencyLow, 121
                byte CmdWave, SawtoothStart
                byte CmdDelay, 5
                byte CmdWave, SawtoothEnd

                byte CmdEnd
soundPickupHigh byte >soundPickup
soundPickupLow  byte <soundPickup

;-------------------------------------------------------------------------------

soundFullAmmo   byte CmdAttackDecay, Attack_38ms+Decay_114ms
                byte CmdSustainRelease, Sustain_Vol10+Release_72ms
                byte CmdFrequencyHigh, 18
                byte CmdFrequencyLow, 125
                byte CmdWave, SawtoothStart
                byte CmdDelay, 7
                byte CmdWave, SawtoothEnd

                byte CmdAttackDecay, Attack_2ms+Decay_114ms
                byte CmdSustainRelease, Sustain_Vol10+Release_72ms
                byte CmdFrequencyHigh, 22
                byte CmdFrequencyLow, 125
                byte CmdWave, SawtoothStart
                byte CmdDelay, 7
                byte CmdWave, SawtoothEnd

                byte CmdAttackDecay, Attack_2ms+Decay_114ms
                byte CmdSustainRelease, Sustain_Vol10+Release_72ms
                byte CmdFrequencyHigh, 26
                byte CmdFrequencyLow, 125
                byte CmdWave, SawtoothStart
                byte CmdDelay, 7
                byte CmdWave, SawtoothEnd

                byte CmdAttackDecay, Attack_2ms+Decay_114ms
                byte CmdSustainRelease, Sustain_Vol10+Release_750ms
                byte CmdWave, SawtoothStart
                byte CmdFrequencyHigh, 33
                byte CmdFrequencyLow, 96
                byte CmdDelay, 5
                byte CmdWave, SawtoothEnd
                byte CmdEnd

soundFullAmmoHigh byte >soundFullAmmo
soundFullAmmoLow  byte <soundFullAmmo

;===============================================================================
; Macros/Subroutines

libSoundInit

        ; Clear all the SID registers and Voice Buffer
        ldx #0
        lda #0
@loop1  sta FRELO1,X
        inx
        cpx #$19
        bcc @loop1

        ldx #0
        lda #0
@loop2  sta FRELO2,X
        inx
        cpx #$19
        bcc @loop2

        ldx #0
        lda #0
@loop3  sta FRELO3,X
        inx
        cpx #$19
        bcc @loop3

        ldx #0
        lda #0
@loop4  sta soundVoiceActive,X
        inx
        cpx #3
        bcc @loop4

        ; Volume & Filter Select
        lda #15
        sta SIGVOL

        rts

;===============================================================================

defm LIBSOUND_PLAY_VAA  ; /1 = Voice                   (Value)
                        ; /2 = Command Buffer Ptr High (Address)
                        ; /3 = Command Buffer Ptr Low  (Address)


        lda soundDisabled
        bne @done

        ldx #/1

        lda /2
        sta soundVoiceCmdPtrHigh,X

        lda /3
        sta soundVoiceCmdPtrLow,X

        lda #True
        sta soundVoiceActive,X

        lda #0
        sta soundVoiceCmdIndex,X
@done
        endm


;===============================================================================

libSoundUpdate

        ldx #0
lSULoop
        lda soundVoiceActive,X
        bne lSUActive
        jmp lSUDone

lSUActive
        lda soundVoiceDelay,X
        beq lSUProcess
        dec soundVoiceDelay,X
        jmp lSUDone

lSUProcess

        lda soundVoiceCmdPtrLow,X ; load low address byte
        sta ZeroPageLow

        lda soundVoiceCmdPtrHigh,X ; load high address byte
        sta ZeroPageHigh

        ldy soundVoiceCmdIndex,X ; load x position into Y register
        lda (ZeroPageLow),Y     ; load the command

        
lSUProcessLoop
        ; process the command
        LIBSOUND_PROCESSWAVE
        LIBSOUND_PROCESSATTACKDECAY
        LIBSOUND_PROCESSSUSTAINRELEASE
        LIBSOUND_PROCESSFREQUENCYHIGH
        LIBSOUND_PROCESSFREQUENCYLOW
        LIBSOUND_PROCESSPULSEWIDTHHIGH
        LIBSOUND_PROCESSPULSEWIDTHLOW
        LIBSOUND_PROCESSDELAY
        LIBSOUND_PROCESSEND
        jmp lSUProcessLoop

lSUDone
        inx
        cpx #3
        beq lSUFinished
        jmp lSULoop
lSUFinished

        rts

;===============================================================================

defm    LIBSOUND_PROCESSWAVE

lSUWave
        cmp #CmdWave
        bne @skip
        inc soundVoiceCmdIndex,X ; move to next byte
        ldy soundVoiceCmdIndex,X
        lda (ZeroPageLow),Y
 
        cpx #0
        bne @reg2
        sta VCREG1
        jmp @regdone
@reg2 
        cpx #1
        bne @reg3
        sta VCREG2
        jmp @regdone
@reg3   
        sta VCREG3
@regdone        
        inc soundVoiceCmdIndex,X ; move to next byte
        ldy soundVoiceCmdIndex,X
        lda (ZeroPageLow),Y
@skip
        endm

;===============================================================================

defm    LIBSOUND_PROCESSATTACKDECAY
        
lSUAttackDecay
        cmp #CmdAttackDecay
        bne @skip
        inc soundVoiceCmdIndex,X ; move to next byte
        ldy soundVoiceCmdIndex,X
        lda (ZeroPageLow),Y

        cpx #0
        bne @reg2
        sta ATDCY1
        jmp @regdone
@reg2 
        cpx #1
        bne @reg3
        sta ATDCY2
        jmp @regdone
@reg3   
        sta ATDCY3
@regdone        
        inc soundVoiceCmdIndex,X ; move to next byte
        ldy soundVoiceCmdIndex,X
        lda (ZeroPageLow),Y
@skip
        endm

;===============================================================================

defm    LIBSOUND_PROCESSSUSTAINRELEASE
        
lSUSustainRelease
        cmp #CmdSustainRelease
        bne @skip
        inc soundVoiceCmdIndex,X ; move to next byte
        ldy soundVoiceCmdIndex,X
        lda (ZeroPageLow),Y
        
        cpx #0
        bne @reg2
        sta SUREL1
        jmp @regdone
@reg2 
        cpx #1
        bne @reg3
        sta SUREL2
        jmp @regdone
@reg3   
        sta SUREL3
@regdone     
        inc soundVoiceCmdIndex,X ; move to next byte
        ldy soundVoiceCmdIndex,X
        lda (ZeroPageLow),Y
@skip
        endm

;===============================================================================

defm    LIBSOUND_PROCESSFREQUENCYHIGH
        
lSUFrequencyHigh
        cmp #CmdFrequencyHigh
        bne @skip
        inc soundVoiceCmdIndex,X ; move to next byte
        ldy soundVoiceCmdIndex,X
        lda (ZeroPageLow),Y

        cpx #0
        bne @reg2
        sta FREHI1
        jmp @regdone
@reg2 
        cpx #1
        bne @reg3
        sta FREHI2
        jmp @regdone
@reg3   
        sta FREHI3
@regdone
        inc soundVoiceCmdIndex,X ; move to next byte
        ldy soundVoiceCmdIndex,X
        lda (ZeroPageLow),Y
@skip
        endm

;===============================================================================

defm    LIBSOUND_PROCESSFREQUENCYLOW
        
lSUFrequencyLow
        cmp #CmdFrequencyLow
        bne @skip
        inc soundVoiceCmdIndex,X ; move to next byte
        ldy soundVoiceCmdIndex,X
        lda (ZeroPageLow),Y
        
        cpx #0
        bne @reg2
        sta FRELO1
        jmp @regdone
@reg2 
        cpx #1
        bne @reg3
        sta FRELO2
        jmp @regdone
@reg3   
        sta FRELO3
@regdone
        inc soundVoiceCmdIndex,X ; move to next byte
        ldy soundVoiceCmdIndex,X
        lda (ZeroPageLow),Y
@skip
        endm

;===============================================================================

defm    LIBSOUND_PROCESSPULSEWIDTHHIGH
        
lSUPulseWidthHigh
        cmp #CmdPulseWidthHigh
        bne @skip
        inc soundVoiceCmdIndex,X ; move to next byte
        ldy soundVoiceCmdIndex,X
        lda (ZeroPageLow),Y

        cpx #0
        bne @reg2
        sta PWHI1
        jmp @regdone
@reg2 
        cpx #1
        bne @reg3
        sta PWHI2
        jmp @regdone
@reg3   
        sta PWHI3
@regdone
        inc soundVoiceCmdIndex,X ; move to next byte
        ldy soundVoiceCmdIndex,X
        lda (ZeroPageLow),Y
@skip
        endm

;===============================================================================

defm    LIBSOUND_PROCESSPULSEWIDTHLOW
        
lSUPulseWidthLow
        cmp #CmdPulseWidthLow
        bne @skip
        inc soundVoiceCmdIndex,X ; move to next byte
        ldy soundVoiceCmdIndex,X
        lda (ZeroPageLow),Y
        
        cpx #0
        bne @reg2
        sta PWLO1
        jmp @regdone
@reg2 
        cpx #1
        bne @reg3
        sta PWLO2
        jmp @regdone
@reg3   
        sta PWLO3
@regdone
        inc soundVoiceCmdIndex,X ; move to next byte
        ldy soundVoiceCmdIndex,X
        lda (ZeroPageLow),Y
@skip
        endm

;===============================================================================

defm    LIBSOUND_PROCESSDELAY

lSUDelay
        cmp #CmdDelay
        bne @skip
        inc soundVoiceCmdIndex,X ; move to next byte
        ldy soundVoiceCmdIndex,X
        lda (ZeroPageLow),Y
        sta soundVoiceDelay,X
        inc soundVoiceCmdIndex,X ; move to next byte
        ldy soundVoiceCmdIndex,X
        lda (ZeroPageLow),Y
        jmp lSUDone
@skip
        endm

;===============================================================================

defm    LIBSOUND_PROCESSEND
     
lSUEnd   
        cmp #CmdEnd
        bne @skip
        lda #False
        sta soundVoiceActive,X
        sta soundVoiceCmdIndex,X
        jmp lSUDone
@skip
        endm



