@ =============================================================================
@ DevSound Advance sound driver for Game Boy Advance
@ Copyright (c) 2024 DevEd
@ 
@ Permission is hereby granted, free of charge, to any person obtaining a copy
@ of this software and associated documentation files (the "Software"), to deal
@ in the Software without restriction, including without limitation the rights
@ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
@ copies of the Software, and to permit persons to whom the Software is
@ furnished to do so, subject to the following conditions:
@  
@ The above copyright notice and this permission notice shall be included in
@ all copies or substantial portions of the Software.
@ 
@ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
@ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
@ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
@ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
@ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
@ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
@ SOFTWARE.
@ =============================================================================

@ =============================================================================
@ TODO:
@ - get zombie mode working
@   - if I can't get zombie mode working then use hardware envelopes instead
@ - sequence parsing
@ - dmg register update
@ - direct dma
@ - minmod integration
@ =============================================================================

    .syntax unified

@ =============================================================================
@ Flags
@ =============================================================================

@    .equ    ENABLE_ZOMBIE_MODE, 1   @ set to 0 for emulator compatibility

@ =============================================================================
@ Equates
@ =============================================================================

    .equ    REG_SOUND1CNT_L,0x04000060 @ NR10
    .equ    REG_SOUND1CNT_H,0x04000062 @ NR11 + NR12
    .equ    REG_SOUND1CNT_X,0x04000064 @ NR13 + NR14
    
    .equ    REG_SOUND2CNT_L,0x04000068 @ NR21 + NR22
    .equ    REG_SOUND2CNT_H,0x0400006C @ NR23 + NR24
    
    .equ    REG_SOUND3CNT_L,0x04000070 @ NR30
    .equ    REG_SOUND3CNT_H,0x04000072 @ NR31 + NR32
    .equ    REG_SOUND3CNT_X,0x04000074 @ NR33 + NR34
    
    .equ    REG_SOUND4CNT_L,0x04000078 @ NR41 + NR42
    .equ    REG_SOUND4CNT_H,0x0400007C @ NR43 + NR44
    
    .equ    REG_SOUNDCNT_L, 0x04000080 @ NR50 + NR51
    .equ    REG_SOUNDCNT_H, 0x04000082 @ Direct Sound + DMG output ratio
    .equ    REG_SOUNDCNT_X, 0x04000084 @ NR52
    .equ    REG_SOUNDBIAS,  0x04000088 @ Sound bias + amplitude resolution

    .equ    REG_WAVE_RAM,   0x04000090 @ DMG wave RAM

    @ DMG register name defines
    .equ    REG_NR10,       0x04000060
    .equ    REG_NR11,       0x04000062
    .equ    REG_NR12,       0x04000063
    .equ    REG_NR13,       0x04000064
    .equ    REG_NR14,       0x04000065
    
    .equ    REG_NR21,       0x04000068
    .equ    REG_NR22,       0x04000069
    .equ    REG_NR23,       0x0400006C
    .equ    REG_NR24,       0x0400006D
    
    .equ    REG_NR30,       0x04000070
    .equ    REG_NR31,       0x04000072
    .equ    REG_NR32,       0x04000073
    .equ    REG_NR33,       0x04000074
    .equ    REG_NR34,       0x04000075
    
    .equ    REG_NR41,       0x04000078
    .equ    REG_NR42,       0x04000079
    .equ    REG_NR43,       0x0400007C
    .equ    REG_NR44,       0x0400007D
    
    @ DMA registers
    .equ    REG_FIFO_A_L,   0x040000A0 @ FIFO A
    .equ    REG_FIFO_A_H,   0x040000A2
    .equ    REG_FIFO_B_L,   0x040000A4 @ FIFO B
    .equ    REG_FIFO_B_H,   0x040000A6
    
    
    .equ    SCNT_DMG_VOL25, 0
    .equ    SCNT_DMG_VOL50, 1
    .equ    SCNT_DMG_VOL100,2
    
    .equ    SCNT_DSA_VOL50, 0 << 2
    .equ    SCNT_DSA_VOL100,1 << 2
    
    .equ    SCNT_DSB_VOL50, 0 << 3
    .equ    SCNT_DSB_VOL100,1 << 3
    
    .equ    SCNT_DSA_RIGHT, 1 << 8
    .equ    SCNT_DSA_LEFT,  1 << 9
    .equ    SCNT_DSA_TIMR0, 0 << 10
    .equ    SCNT_DSA_TIMR1, 1 << 10
    .equ    SCNT_DSA_RESET, 1 << 11
    
    .equ    SCNT_DSB_RIGHT, 1 << 12
    .equ    SCNT_DSB_LEFT,  1 << 13
    .equ    SCNT_DSB_TIMR0, 0 << 14
    .equ    SCNT_DSB_TIMR1, 1 << 14
    .equ    SCNT_DSB_RESET, 1 << 15
    
    .equ    SCNT_DSA_LR,    SCNT_DSA_LEFT + SCNT_DSA_RIGHT
    .equ    SCNT_DSB_LR,    SCNT_DSB_LEFT + SCNT_DSB_RIGHT
    .equ    SCNT_DS_LR,     SCNT_DSA_LR + SCNT_DSB_LR
    .equ    SCNT_DS_TIMR0,  SCNT_DSA_TIMR0 + SCNT_DSB_TIMR0
    .equ    SCNT_DS_TIMR1,  SCNT_DSA_TIMR1 + SCNT_DSB_TIMR1
    .equ    SCNT_DS_RESET,  SCNT_DSA_RESET + SCNT_DSB_RESET
    
    .equ    SCNT_DS_VOL50,  SCNT_DSA_VOL50 + SCNT_DSB_VOL50
    .equ    SCNT_DS_VOL100, SCNT_DSA_VOL100 + SCNT_DSB_VOL100
    
    .equ    SCNT_DMG1_STAT, 1 << 0
    .equ    SCNT_DMG2_STAT, 1 << 1
    .equ    SCNT_DMG3_STAT, 1 << 2
    .equ    SCNT_DMG4_STAT, 1 << 3
    .equ    SCNT_DISABLE,   0 << 7
    .equ    SCNT_ENABLE,    1 << 7
    
    .equ    SBIAS_9BIT,     0 << 14
    .equ    SBIAS_8BIT,     1 << 14
    .equ    SBIAS_7BIT,     2 << 14
    .equ    SBIAS_6BIT,     3 << 14
    
    .equ    DMG_SOUND1_L,   1 << 8
    .equ    DMG_SOUND2_L,   1 << 9
    .equ    DMG_SOUND3_L,   1 << 10
    .equ    DMG_SOUND4_L,   1 << 11
    .equ    DMG_SOUND1_R,   1 << 12
    .equ    DMG_SOUND2_R,   1 << 13
    .equ    DMG_SOUND3_R,   1 << 14
    .equ    DMG_SOUND4_R,   1 << 15
    
    .equ    DMG_VOL_LR_77,  0x77
    
    .equ    DMG_CH1_L,      1 << 8
    .equ    DMG_CH2_L,      1 << 9
    .equ    DMG_CH3_L,      1 << 10
    .equ    DMG_CH4_L,      1 << 11
    .equ    DMG_CH1_R,      1 << 12
    .equ    DMG_CH2_R,      1 << 13
    .equ    DMG_CH3_R,      1 << 14
    .equ    DMG_CH4_R,      1 << 15
    .equ    DMG_CH1_LR,     DMG_CH1_L | DMG_CH1_R
    .equ    DMG_CH2_LR,     DMG_CH2_L | DMG_CH2_R
    .equ    DMG_CH3_LR,     DMG_CH3_L | DMG_CH3_R
    .equ    DMG_CH4_LR,     DMG_CH4_L | DMG_CH4_R
    .equ    DMG_LR,         DMG_CH1_LR | DMG_CH2_LR | DMG_CH3_LR | DMG_CH4_LR
    
    .equ    DMG_SWEEP_UP,   0 << 3
    .equ    DMG_SWEEP_DOWN, 1 << 3
    
    .equ    DMG_PW_125,     0 << 6
    .equ    DMG_PW_25,      1 << 6
    .equ    DMG_PW_50,      2 << 6
    .equ    DMG_PW_75,      3 << 6
    
@ =============================================================================
@ Useful macros
@ =============================================================================

    .macro brk
    mov     r11,r11
    .endm
    
    .macro align_word reg1,reg2
    ldr     \reg2,=0xFFFFFFFC
    push    {\reg1}
    ands    \reg1,\reg2
    movs    \reg2,\reg1
    pop     {\reg1}
    cmp     \reg1,\reg2
    beq     0f
    ldr     \reg2,=0xFFFFFFFC
    adds    \reg1,4
    ands    \reg1,\reg2
0:  
    .endm

@ =============================================================================
@ Sound command definitions
@ =============================================================================

    .equ    PITCH_MODE_NONE,        0
    .equ    PITCH_MODE_SLIDE_UP,    1
    .equ    PITCH_MODE_SLIDE_DOWN,  2
    .equ    PITCH_MODE_PORTAMENTO,  3
    
    .equ    PITCH_BIT_MONTY,        7
    .equ    PITCH_MODE_MASK,        0b00001111
    .equ    PITCH_BIT_MASK,         0b11110000

    .global nC_
    .global nCs
    .global nD_
    .global nDs
    .global nE_
    .global nF_
    .global nFs
    .global nG_
    .global nGs
    .global nA_
    .global nAs
    .global nB_
    .equ nC_,0
    .equ nCs,1
    .equ nD_,2
    .equ nDs,3
    .equ nE_,4
    .equ nF_,5
    .equ nFs,6
    .equ nG_,7
    .equ nGs,8
    .equ nA_,9
    .equ nAs,10
    .equ nB_,11
    
    .equ seq_wait,0xFD
    .equ seq_loop,0xFE
    .equ seq_end,0xFF
    .equ pitch_loop,0x7f
    .equ pitch_end,0x80

    @ Play a note
    .global note
    .macro note num,octave,length
    .byte ((\octave - 2) * 12) + \num
    .byte \length
    .endm
    
    @ Release a playing note
    .global release
    .macro release length
    .byte 0x7d
    .byte \length
    .endm
    
    @ Wait a given number of ticks without playing a new note
    .global wait
    .macro wait length
    .byte 0x7e
    .byte \length
    .endm
    
    @ Stop currently playing note
    .global rest
    .macro rest length
    .byte 0x7f
    .byte \length
    .endm
    
    @ Set instrument
    .global sound_instrument
    .macro sound_instrument ptr
    .byte 0x80
    .align 2
    .word \ptr
    .endm
    
    @ Jump to another section
    .global sound_jump
    .macro sound_jump ptr
    .byte 0x81
    .align 2
    .word \ptr
    .endm
    
    @ Loop a section
    .global sound_loop
    .macro sound_loop cnt,ptr
    .byte 0x82
    .byte \cnt
    .align 2
    .word \ptr
    .endm
    
    @ Jump to another section and return when a sound_ret command is reached
    .global sound_call
    .macro sound_call ptr
    .byte 0x83
    .align 2
    .word \ptr
    .endm
    
    @ Return from a section after sound_call
    .global sound_ret
    .macro sound_ret
    .byte 0x84
    .endm
    
    @ Initiate an upward note slide
    .global sound_slide_up
    .macro sound_slide_up speed
    .byte 0x85
    .byte \speed
    .endm
    
    @ Initiate a downward note slide
    .global sound_slide_down
    .macro sound_slide_down speed
    .byte 0x86
    .byte \speed
    .endm
    
    @ Enable portamento
    .global sound_portamento
    .macro sound_portamento speed
    .byte 0x87
    .byte \speed
    .endm
    
    @ Enable or disable monty mode
    .global sound_toggle_monty
    .macro sound_toggle_monty
    .byte 0x88
    .endm
    
    @ Play a sample on a given direct DMA channel
    @ WARNING: Only effective if MinMod channels are not in use!
    .global sound_sample
    .macro sound_sample channel, ptr
    .byte 0x89
    .byte \channel
    .align 2
    .word ptr
    .endm
    
    @ Set volume for current channel
    @ Ineffective on DMG CH3
    .global sound_volume
    .macro sound_volume vol
    .byte 0x8a
    .byte (\vol & 0xF)
    .endm
    
    @ Transpose CURRENT channel by a given amount
    @ Ineffective on DMG CH4
    .global sound_transpose
    .macro sound_transpose amount
    .byte 0x8b
    .byte \amount
    .endm
    
    @ Transpose ALL channels by a given amount
    @ WARNING: Overrides any previous transpose commands!
    .global sound_transpose_global
    .macro sound_transpose_global amount
    .byte 0x8c
    .byte \amount
    .endm
    
    @ Reset transposition for CURRENT channel
    @ Ineffective on DMG CH4
    .global sound_reset_transpose
    .macro sound_reset_transpose
    .byte 0x8d
    .endm
    
    @ Reset transposition for ALL channels
    .global sound_reset_transpose_global
    .macro sound_reset_transpose_global
    .byte 0x8e
    .endm
    
    @ Override current instrument's arpeggio pointer
    @ NOTE: You must reload the instrument in order to cancel this command.
    .global sound_set_arp_ptr
    .macro sound_set_arp_ptr ptr
    .byte 0x8f
    .align 2
    .word \ptr
    .endm
    
    @ Set song tempo
    .global sound_set_speed
    .macro sound_set_speed spd1, spd2
    .byte 0x90
    .align 2
    .byte \spd1
    .byte \spd2
    .endm
    
    @ Marks the end of a channel
    .global sound_end
    .macro sound_end
    .byte 0xFF
    .endm    
    
    .global sfix
    .macro sfix length
    note nC_,2,\length
    .endm
    
    .global sfixins
    .macro sfixins ptr,length
    sound_instrument \ptr
    note nC_,2,\length
    .endm

    
@ =============================================================================
    
DS_Thumbprint:
    .asciz  "DevSound Advance sound driver by DevEd | deved8@gmail.com"
    .align  4

@ =============================================================================

    .global DS_Init
    .type DS_Init STT_FUNC   
DS_Init:
    push    {r0-r12, lr}

    ldr     r5,=REG_SOUNDCNT_L
    ldr     r6,=REG_SOUNDCNT_X
    
    mov     r4,SCNT_DISABLE
    str     r4,[r6]
    mov     r4,SCNT_ENABLE
    str     r4,[r6]
    ldr     r4,=(DMG_VOL_LR_77 + DMG_LR) + ((SCNT_DMG_VOL100 + SCNT_DS_VOL100 + SCNT_DS_LR + SCNT_DS_TIMR0) << 16)
    str     r4,[r5]

    bl      DS_ClearMem
    
    @ init ch3 wave
    mov     r0,0
    ldr     r1,=REG_SOUND3CNT_L
    strh    r0,[r1]
    ldr     r2,=DS_DefaultWave
    ldr     r3,=REG_WAVE_RAM
    mov     r4,4
.waveloop:
    ldr     r0,[r2]
    str     r0,[r3]
    add     r2,4
    add     r3,4
    sub     r4,1
    cmp     r4,0
    bne     .waveloop
    mov     r0,0b10000000
    strh    r0,[r1]
    
    @ init tables
    ldr     r0,=DS_DummyTable
    ldr     r1,=DS_CH1_VolPtr
    ldr     r2,=DS_CH1_VolResetPtr
    ldr     r3,=DS_CH1_VolReleasePtr
    str     r0,[r1]
    str     r0,[r2]
    str     r0,[r3]
    ldr     r1,=DS_CH1_ArpPtr
    ldr     r2,=DS_CH1_ArpResetPtr
    ldr     r3,=DS_CH1_ArpReleasePtr
    str     r0,[r1]
    str     r0,[r2]
    str     r0,[r3]
    ldr     r1,=DS_CH1_PulsePtr
    ldr     r2,=DS_CH1_PulseResetPtr
    ldr     r3,=DS_CH1_PulseReleasePtr
    str     r0,[r1]
    str     r0,[r2]
    str     r0,[r3]
    
    ldr     r1,=DS_CH2_VolPtr
    ldr     r2,=DS_CH2_VolResetPtr
    ldr     r3,=DS_CH2_VolReleasePtr
    str     r0,[r1]
    str     r0,[r2]
    str     r0,[r3]
    ldr     r1,=DS_CH2_ArpPtr
    ldr     r2,=DS_CH2_ArpResetPtr
    ldr     r3,=DS_CH2_ArpReleasePtr
    str     r0,[r1]
    str     r0,[r2]
    str     r0,[r3]
    ldr     r1,=DS_CH2_PulsePtr
    ldr     r2,=DS_CH2_PulseResetPtr
    ldr     r3,=DS_CH2_PulseReleasePtr
    str     r0,[r1]
    str     r0,[r2]
    str     r0,[r3]
    
    ldr     r1,=DS_CH3_VolPtr
    ldr     r2,=DS_CH3_VolResetPtr
    ldr     r3,=DS_CH3_VolReleasePtr
    str     r0,[r1]
    str     r0,[r2]
    str     r0,[r3]
    ldr     r1,=DS_CH3_ArpPtr
    ldr     r2,=DS_CH3_ArpResetPtr
    ldr     r3,=DS_CH3_ArpReleasePtr
    str     r0,[r1]
    str     r0,[r2]
    str     r0,[r3]
    ldr     r1,=DS_CH3_WavePtr
    ldr     r2,=DS_CH3_WaveResetPtr
    ldr     r3,=DS_CH3_WaveReleasePtr
    str     r0,[r1]
    str     r0,[r2]
    str     r0,[r3]
    
    ldr     r1,=DS_CH4_VolPtr
    ldr     r2,=DS_CH4_VolResetPtr
    ldr     r3,=DS_CH4_VolReleasePtr
    str     r0,[r1]
    str     r0,[r2]
    str     r0,[r3]
    ldr     r1,=DS_CH4_ArpPtr
    ldr     r2,=DS_CH4_ArpResetPtr
    ldr     r3,=DS_CH4_ArpReleasePtr
    str     r0,[r1]
    str     r0,[r2]
    str     r0,[r3]
    ldr     r1,=DS_CH4_ModePtr
    ldr     r2,=DS_CH4_ModeResetPtr
    ldr     r3,=DS_CH4_ModeReleasePtr
    str     r0,[r1]
    str     r0,[r2]
    str     r0,[r3]

    ldr     r0,=DS_DummyPitch
    ldr     r1,=DS_CH1_PitchPtr
    ldr     r1,=DS_CH1_PitchResetPtr
    ldr     r1,=DS_CH1_PitchReleasePtr
    str     r0,[r1]
    str     r0,[r2]
    str     r0,[r3]
    ldr     r1,=DS_CH2_PitchPtr
    ldr     r1,=DS_CH2_PitchResetPtr
    ldr     r1,=DS_CH2_PitchReleasePtr
    str     r0,[r1]
    str     r0,[r2]
    str     r0,[r3]
    ldr     r1,=DS_CH3_PitchPtr
    ldr     r1,=DS_CH3_PitchResetPtr
    ldr     r1,=DS_CH3_PitchReleasePtr
    str     r0,[r1]
    str     r0,[r2]
    str     r0,[r3]

    
    pop     {r0-r12, lr}
    bx      lr

@ =============================================================================

    .global DS_LoadSong
    .type DS_LoadSong STT_FUNC
@ INPUT:    song ID in r0
@ OUTPUT:   none
@ DESTROYS: none
DS_LoadSong:
    push    {r0-r4,lr}
    bl      DS_Init
    ldr     r1,=DS_SongPointers
    mov     r2,4
    mul     r0,r2
    ldr     r1,[r1,r0]
    @ pointer to song header is now in r0
    @ get song mode
    ldrh    r0,[r1]
    ldr     r2,=DS_Mode
    strh    r0,[r2]
    add     r1,2
    @ get song speed
    ldrh    r0,[r1]
    ldr     r2,=DS_MusicSpeed
    strh    r0,[r2]
    add     r1,2
    @ get sequence pointers
    ldr     r2,=DS_CH1_SeqPtr
    mov     r3,12
1:  ldr     r0,[r1]
    str     r0,[r2]
    add     r1,4
    add     r2,4
    sub     r3,1
    cmp     r3,0
    bne     1b
    @ set music flags
    ldr     r1,=DS_MusicPlaying
    mov     r0,1
    strh    r0,[r1]
    ldr     r1,=DS_MusicSpeedTick
    strh    r0,[r1]
    ldr     r1,=DS_CH1_Timer
    strb    r0,[r1]
    ldr     r1,=DS_CH2_Timer
    strb    r0,[r1]
    ldr     r1,=DS_CH3_Timer
    strb    r0,[r1]
    ldr     r1,=DS_CH4_Timer
    strb    r0,[r1]
    ldr     r1,=DS_MusicFlags
    ldr     r0,=0b1111111100111111
    strh    r0,[r1]
    pop     {r0-r4,lr}
    bx      lr

@ =============================================================================

@ INPUT:    none
@ OUTPUT:   none
@ DESTROYS: none
    .global DS_Stop
    .type   DS_Stop STT_FUNC
    .arm
DS_Stop:
    push    {r0,r1,lr}
    mov     r0,0
    ldr     r1,=DS_MusicPlaying
    strh    r0,[r1]
    ldr     r1,=REG_SOUNDCNT_X
    strh    r0,[r1]
    pop     {r0,r1,lr}
    bx      lr

@ =============================================================================

@ INPUT:    none
@ OUTPUT:   none
@ DESTROYS: none
    .global DS_Update
    .type   DS_Update STT_FUNC    
    .thumb
DS_Update:
    push    {r0-r7,lr}
    ldr     r1,=DS_MusicPlaying
    ldrh    r0,[r1]
    cmp     r0,0
    beq     DS_NoUpdate
    bl      DS_UpdateMusic
    bl      DS_UpdateEffects
    bl      DS_UpdateTables
    bl      DS_UpdateRegisters
DS_NoUpdate:
    pop     {r0-r7,pc}

DS_UpdateMusic:
    push    {lr}
    ldr     r1,=DS_MusicPlaying
    ldrh    r0,[r1]
    cmp     r0,0
    bne     1f
    pop     {pc}
1:  ldr     r1,=DS_GlobalTick
    ldrh    r0,[r1]
    adds    r0,1
    strh    r0,[r1]
    
    ldr     r1,=DS_MusicSpeedTick
    ldrh    r0,[r1]
    subs    r0,1
    strh    r0,[r1]
    cmp     r0,0
    beq     2f
    pop     {pc}

2:  ldr     r1,=DS_MusicTick
    ldrh    r0,[r1]
    adds    r0,1
    strh    r0,[r1]
    ldr     r1,=DS_MusicSpeed
    movs    r2,1
    ands    r0,r2
    cmp     r0,0
    bne     3f
    adds    r1,1
3:  ldrb    r0,[r1]
    ldr     r1,=DS_MusicSpeedTick
    strh    r0,[r1]
    
    bl      DS_UpdateCH1
    bl      DS_UpdateCH2
    
    pop     {pc}

@ ======================================================================

DS_UpdateEffects:
    push    {lr}
    
    pop     {pc}

@ ======================================================================

DS_UpdateTables:
    push    {lr}
    @ pulse 1 tables
    ldr     r2,=DS_CH1_VolPtr
    ldr     r3,=DS_CH1_Volume
    ldr     r4,=DS_CH1_VolDelay
    bl      DS_UpdateTableSingle
    ldr     r2,=DS_CH1_ArpPtr
    ldr     r3,=DS_CH1_ArpTranspose
    ldr     r4,=DS_CH1_ArpDelay
    bl      DS_UpdateTableSingle
    ldr     r2,=DS_CH1_PulsePtr
    ldr     r3,=DS_CH1_Pulse
    ldr     r4,=DS_CH1_PulseDelay
    bl      DS_UpdateTableSingle
    
2:  @ pulse 2 tables
    ldr     r2,=DS_CH2_VolPtr
    ldr     r3,=DS_CH2_Volume
    ldr     r4,=DS_CH2_VolDelay
    bl      DS_UpdateTableSingle
    ldr     r2,=DS_CH2_ArpPtr
    ldr     r3,=DS_CH2_ArpTranspose
    ldr     r4,=DS_CH2_ArpDelay
    bl      DS_UpdateTableSingle
    ldr     r2,=DS_CH2_PulsePtr
    ldr     r3,=DS_CH2_Pulse
    ldr     r4,=DS_CH2_PulseDelay
    bl      DS_UpdateTableSingle
3:    
    pop     {pc}

@ INPUT:    r2 = pointer to table pointer
@           r3 = pointer to value table modulates
@           r4 = pointer to table delay
DS_UpdateTableSingle:
    ldr     r5,[r2]
    @ process delay
    ldrb    r0,[r4]
    cmp     r0,0
    beq     1f
    subs    r0,1
    strb    r0,[r4]
    bx      lr
1:  @ get byte from table
    ldrb    r0,[r5]
    adds    r5,1
    cmp     r0,seq_end
    bne     2f
    pop     {pc}
2:  cmp     r0,seq_loop
    beq     DS_TableLoop
    cmp     r0,seq_wait
    beq     DS_TableWait
    @ default case: write to modulation value
    strb    r0,[r3]
    b       DS_TableDone
DS_TableLoop:
    align_word r5,r6
    ldr     r5,[r5]
    b       1b
DS_TableWait:
    ldrb    r0,[r5]
    adds    r0,1
    strb    r0,[r4]
    @ fall through
DS_TableDone:
    str     r5,[r2]
    bx      lr

@ ======================================================================

DS_UpdateRegisters:
    push    {lr}

    @ DMG pulse 1
    @ volume
    ldr     r1,=DS_CH1_Volume
    ldr     r2,=DS_CH1_OldVolume
    ldrb    r0,[r1]
    ldrb    r4,[r2]
    cmp     r0,r4
    beq     1f
    strb    r0,[r2]
    ldr     r1,=REG_NR12
    lsls    r0,4
    strb    r0,[r1]
    ldr     r0,=0x8000
    ldr     r2,=REG_SOUND1CNT_X
    strh    r0,[r2]
1:  @ pulse
    ldr     r1,=DS_CH1_Pulse
    ldr     r2,=REG_NR11
    ldrb    r0,[r1]
    lsls    r0,6
    strb    r0,[r2]
    @ note + transpose + arpeggio
    ldr     r1,=DS_CH1_Note
    ldr     r2,=DS_CH1_Transpose
    ldr     r3,=DS_CH1_ArpTranspose
    ldrb    r0,[r1]
    ldrb    r2,[r2]
    ldrb    r3,[r3]
    adds    r0,r2    
    adds    r0,r3
    bl      DS_GetNoteFrequencyDMG
    @ note pitch + pitch table offset + note slide offset
    ldr     r1,=DS_CH1_VibOffset
    ldr     r2,=DS_CH1_SlideOffset
    ldrh    r1,[r1]
    ldrh    r2,[r2]
    adds    r7,r1
    adds    r7,r2
    ldr     r1,=REG_SOUND1CNT_X
    strh    r7,[r1]
    
    @ DMG pulse 2
    @ volume
    ldr     r1,=DS_CH2_Volume
    ldr     r2,=DS_CH2_OldVolume
    ldrb    r0,[r1]
    ldrb    r4,[r2]
    cmp     r0,r4
    beq     2f
    strb    r0,[r2]
    ldr     r1,=REG_NR22
    lsls    r0,4
    strb    r0,[r1]
    ldr     r0,=0x8000
    ldr     r2,=REG_SOUND2CNT_H
    strh    r0,[r2]
2:  @ pulse
    ldr     r1,=DS_CH2_Pulse
    ldr     r2,=REG_NR21
    ldrb    r0,[r1]
    lsls    r0,6
    strb    r0,[r2]
    @ note + transpose + arpeggio
    ldr     r1,=DS_CH2_Note
    ldr     r2,=DS_CH2_Transpose
    ldr     r3,=DS_CH2_ArpTranspose
    ldrb    r0,[r1]
    ldrb    r2,[r2]
    ldrb    r3,[r3]
    adds    r0,r2    
    adds    r0,r3
    bl      DS_GetNoteFrequencyDMG
    @ note pitch + pitch table offset + note slide offset
    ldr     r1,=DS_CH2_VibOffset
    ldr     r2,=DS_CH2_SlideOffset
    ldrh    r1,[r1]
    ldrh    r2,[r2]
    adds    r7,r1
    adds    r7,r2
    ldr     r1,=REG_SOUND2CNT_H
    strh    r7,[r1]
    
    pop     {pc}


@ ======================================================================

DS_UpdateCH1:
    push    {lr}
    ldr     r1,=DS_MusicFlags
    ldrb    r0,[r1]
    movs    r2,0b00000001
    ands    r0,r2
    cmp     r0,0
    beq     JumpTo_DS_CH1_Done @ ugh
    
    ldr     r1,=DS_CH1_Timer
    ldrb    r0,[r1]
    subs    r0,1
    strb    r0,[r1]
    cmp     r0,0
    bne     JumpTo_DS_CH1_Done
    ldr     r1,=DS_CH1_SeqPtr
    ldr     r1,[r1]

DS_CH1_GetByte:
    ldrb    r0,[r1]
    adds    r1,1
    cmp     r0,0x80
    bhs     DS_CH1_Command
    cmp     r0,0x7f
    beq     DS_CH1_Rest
    cmp     r0,0x7e
    beq     DS_CH1_Wait
    cmp     r0,0x7d
    beq     DS_CH1_Release
    @ default case: note
    ldr     r2,=DS_CH1_Note
    strb    r0,[r2]
    @ echo buffer processing
    ldr     r2,=DS_CH1_FirstNote
    ldrb    r3,[r2]
    cmp     r3,0    @ is this the first note we've played on this channel?
    bne     1f      @ if yes, initialize the echo buffer
    strb    r0,[r2] @ store first note
    ldr     r2,=DS_CH1_EchoBuffer
    strb    r0,[r2,0]
    strb    r0,[r2,1]
    strb    r0,[r2,2]
    strb    r0,[r2,3]
1:  @ update echo buffer
    ldr     r2,=DS_CH1_EchoPos
    ldr     r3,=DS_CH1_EchoBuffer
    strh    r0,[r3,r2]
    ldrb    r0,[r2]
    adds    r0,1
    movs    r3,3
    ands    r0,r3
    strb    r0,[r2]
    @ set timer
    ldrb    r0,[r1]
    adds    r1,1
    ldr     r2,=DS_CH1_Timer
    strb    r0,[r2]
    @ reset tables if applicable
    ldr     r2,=DS_CH1_PitchMode
    ldrb    r0,[r2]
    movs    r3,PITCH_MODE_MASK
    ands    r0,r3
    cmp     r0,0
    bne     3f
    ldr     r2,=DS_CH1_VolResetPtr
    ldr     r3,=DS_CH1_VolPtr
    movs    r4,3
2:  ldr     r0,[r2]
    str     r0,[r3]
    adds    r2,4
    adds    r3,4
    subs    r4,1
    cmp     r4,0
    bne     2b
    @ reset arpeggio transpose
    ldr     r2,=DS_CH1_ArpTranspose
    ldrb    r4,[r2]
3:  @ reset pitch bend and pitch macro offsets
    movs    r0,0
    ldr     r2,=DS_CH1_VibOffset
    strh    r0,[r2]
    ldr     r2,=DS_CH1_SlideOffset
    strh    r0,[r2]
    @ reset pitch table
    ldr     r2,=DS_CH1_PitchResetPtr
    ldr     r0,[r2]
    ldr     r2,=DS_CH1_PitchPtr
    str     r0,[r2]
    ldr     r2,=DS_CH1_PitchMode
    ldrb    r0,[r2]
    movs    r3,PITCH_MODE_MASK
    ands    r0,r3
    cmp     r0,PITCH_MODE_PORTAMENTO
    beq     4f
    ldr     r2,=DS_CH1_Note
    ldrb    r0,[r2]
    ldr     r2,=DS_CH1_NoteTarget
    strb    r0,[r2]
    bl      DS_GetNoteFrequencyDMG
    ldr     r2,=DS_CH1_SlideTarget
    strh    r7,[r2]
    b       5f
4:  @ disable slide + monty on new note
    movs    r0,0
    ldr     r2,=DS_CH1_PitchMode
    ldrb    r0,[r2]
5:  @ reset delays
    movs    r0,0
    ldr     r2,=DS_CH1_VolDelay
    strb    r0,[r2]
    ldr     r2,=DS_CH1_ArpDelay
    strb    r0,[r2]
    ldr     r2,=DS_CH1_PulseDelay
    strb    r0,[r2]
    @ check if we should get the next note
    ldr     r2,=DS_CH1_Timer
    ldrb    r0,[r2]
    cmp     r0,0
    beq     DS_CH1_GetByte
    bne     JumpTo_DS_CH1_DoneUpdating
JumpTo_DS_CH1_Done:
    b       DS_CH1_Done
DS_CH1_Rest:
    @ set note + timer
    ldr     r2,=DS_CH1_Note
    strb    r0,[r2]
    ldrb    r0,[r1]
    adds    r1,1
    ldr     r2,=DS_CH1_Timer
    strb    r0,[r2]
    ldr     r0,=DS_RestVol
    ldr     r2,=DS_CH1_VolPtr
    str     r0,[r2]
    movs    r0,0
    ldr     r2,=DS_CH1_Volume
    strb    r0,[r2]
    b       DS_CH1_DoneUpdating
DS_CH1_Wait:
    ldrb    r0,[r1]
    adds    r1,1
    ldr     r2,=DS_CH1_Timer
    strb    r0,[r2]
    b       DS_CH1_DoneUpdating
DS_CH1_Release:
    ldrb    r0,[r1]
    adds    r1,1
    ldr     r2,=DS_CH1_Timer
    strb    r0,[r2]
    @ TODO
    b       DS_CH1_DoneUpdating

DS_CH1_Command:
    cmp     r0,0xFF
    beq     JumpTo_DS_CH1_CMD_End
    ldr     r2,=DS_CH1_CommandTable
    movs    r3,0x7f
    ands    r0,r3
    movs    r3,4
    muls    r0,r3
    adds    r2,r0
    ldr     r7,[r2]
    adds    r7,1 @ add 1 to jump address to ensure we stay in thumb mode
    bx      r7

JumpTo_DS_CH1_DoneUpdating:
    b       DS_CH1_DoneUpdating
JumpTo_DS_CH1_GetByte:
    b       DS_CH1_GetByte
JumpTo_DS_CH1_CMD_End:
    b       DS_CH1_CMD_End
    
    .pool   @ ugh x2
    
    .align  4
DS_CH1_CommandTable:
    .word   DS_CH1_CMD_SetInstrument
    .word   DS_CH1_CMD_Jump
    .word   DS_CH1_CMD_Loop
    .word   DS_CH1_CMD_Call
    .word   DS_CH1_CMD_Return
    .word   DS_CH1_CMD_SlideUp
    .word   DS_CH1_CMD_SlideDown
    .word   DS_CH1_CMD_Portamento
    .word   DS_CH1_CMD_ToggleMonty
    .word   DS_CH1_CMD_Dummy
    .word   DS_CH1_CMD_SetVol
    .word   DS_CH1_CMD_SetTranspose
    .word   DS_CH1_CMD_SetTransposeGlobal
    .word   DS_CH1_CMD_ResetTranspose
    .word   DS_CH1_CMD_ResetTransposeGlobal
    .word   DS_CH1_CMD_SetArpPtr
    .word   DS_CH1_CMD_SetSpeed


DS_CH1_CMD_Dummy:
    b       DS_CH1_GetByte

DS_CH1_CMD_SetInstrument:
    align_word r1,r7
    @ read word
    ldr     r2,[r1]
    adds    r1,4
    ldr     r3,=DS_CH1_VolPtr
    ldr     r4,=DS_CH1_VolResetPtr
    ldr     r0,[r2]
    adds    r2,4
    str     r0,[r3]
    str     r0,[r4]
    ldr     r3,=DS_CH1_ArpPtr
    ldr     r4,=DS_CH1_ArpResetPtr
    ldr     r0,[r2]
    adds    r2,4
    str     r0,[r3]
    str     r0,[r4]
    ldr     r3,=DS_CH1_PulsePtr
    ldr     r4,=DS_CH1_PulseResetPtr
    ldr     r0,[r2]
    adds    r2,4
    str     r0,[r3]
    str     r0,[r4]
    ldr     r3,=DS_CH1_PitchPtr
    ldr     r4,=DS_CH1_PitchResetPtr
    ldr     r0,[r2]
    adds    r2,4
    str     r0,[r3]
    str     r0,[r4]
    
    ldr     r3,=DS_CH1_VolReleasePtr
    ldr     r0,[r2]
    adds    r2,4
    str     r0,[r3]
    ldr     r3,=DS_CH1_ArpReleasePtr
    ldr     r0,[r2]
    adds    r2,4
    str     r0,[r3]
    ldr     r3,=DS_CH1_PulseReleasePtr
    ldr     r0,[r2]
    adds    r2,4
    str     r0,[r3]
    ldr     r3,=DS_CH1_PitchReleasePtr
    ldr     r0,[r2]
    adds    r2,4
    str     r0,[r3]
    b       DS_CH1_GetByte

DS_CH1_CMD_Jump:
    align_word  r1,r7
    ldr     r1,[r1]
    b       DS_CH1_GetByte

DS_CH1_CMD_Loop:
    ldrb    r0,[r1]
    adds    r1,1
    ldr     r2,=DS_CH1_LoopCount
    ldrb    r3,[r2]
    cmp     r0,0
    bne     1f
    strb    r0,[r2]
1:  ldrb    r0,[r2]
    subs    r0,1
    strb    r0,[r2]
    cmp     r0,0
    bne     DS_CH1_CMD_Jump
    adds    r1,2
    b       DS_CH1_GetByte

DS_CH1_CMD_Call:
    adds    r1,4
    ldr     r2,=DS_CH1_ReturnPtr
    str     r1,[r2]
    subs    r1,4
    b       DS_CH1_CMD_Jump

DS_CH1_CMD_Return:
    ldr     r2,=DS_CH1_ReturnPtr
    ldr     r1,[r2]
    b       DS_CH1_GetByte

DS_CH1_CMD_SlideUp:
    ldrb    r0,[r1]
    adds    r1,1
    ldr     r2,=DS_CH1_SlideSpeed
    ldrb    r0,[r2]
    ldr     r2,=DS_CH1_PitchMode
    ldrb    r0,[r2]
    movs    r3,PITCH_BIT_MASK
    ands    r0,r3
    adds    r0,PITCH_MODE_SLIDE_UP
    strb    r0,[r2]
    b       DS_CH1_GetByte

DS_CH1_CMD_SlideDown:
    ldrb    r0,[r1]
    adds    r1,1
    ldr     r2,=DS_CH1_SlideSpeed
    ldrb    r0,[r2]
    ldr     r2,=DS_CH1_PitchMode
    ldrb    r0,[r2]
    movs    r3,PITCH_BIT_MASK
    ands    r0,r3
    adds    r0,PITCH_MODE_SLIDE_UP
    strb    r0,[r2]
    b       DS_CH1_GetByte

DS_CH1_CMD_Portamento:
    ldrb    r0,[r1]
    adds    r1,1
    ldr     r2,=DS_CH1_SlideSpeed
    ldrb    r0,[r2]
    ldr     r2,=DS_CH1_PitchMode
    ldrb    r0,[r2]
    movs    r3,PITCH_BIT_MASK
    ands    r0,r3
    adds    r0,PITCH_MODE_PORTAMENTO
    strb    r0,[r2]
    b       DS_CH1_GetByte

DS_CH1_CMD_ToggleMonty:
    ldr     r2,=DS_CH1_PitchMode
    ldrb    r0,[r2]
    movs    r3,1 << PITCH_BIT_MONTY
    eors    r0,r3
    strb    r0,[r2]
    b       DS_CH1_GetByte

DS_CH1_CMD_SetVol:
    ldrb    r0,[r1]
    adds    r1,1
    ldr     r2,=DS_CH1_ChannelVol
    strb    r0,[r2]
    b       DS_CH1_GetByte

DS_CH1_CMD_SetTranspose:
    ldrb    r0,[r1]
    adds    r1,1
    ldr     r2,=DS_CH1_Transpose
    strb    r0,[r2]
    b       DS_CH1_GetByte

DS_CH1_CMD_SetTransposeGlobal:
    ldrb    r0,[r1]
    adds    r1,1
    ldr     r2,=DS_CH1_Transpose
    ldr     r3,=DS_CH2_Transpose
    ldr     r4,=DS_CH3_Transpose
    strb    r0,[r2]
    strb    r0,[r3]
    strb    r0,[r4]
    @ TODO: direct dma/directsound channels
    b       DS_CH1_GetByte

DS_CH1_CMD_ResetTranspose:
    movs    r0,0
    ldr     r2,=DS_CH1_Transpose
    strb    r0,[r2]
    b       DS_CH1_GetByte

DS_CH1_CMD_ResetTransposeGlobal:
    movs    r0,0
    ldr     r2,=DS_CH1_Transpose
    ldr     r3,=DS_CH2_Transpose
    ldr     r4,=DS_CH3_Transpose
    strb    r0,[r2]
    strb    r0,[r3]
    strb    r0,[r4]
    @ TODO: direct dma/directsound channels
    b       DS_CH1_GetByte

DS_CH1_CMD_SetArpPtr:
    align_word  r1,r7
    @ read word
    ldr     r0,[r1]
    adds    r1,4
    @ TODO
    b       DS_CH1_GetByte


DS_CH1_CMD_SetSpeed:
    align_word  r1,r7
    ldrh    r0,[r1]
    adds    r1,1
    ldr     r2,=DS_MusicSpeed
    strh    r0,[r2]
    b       DS_CH1_GetByte

DS_CH1_CMD_End:
    ldr     r1,=DS_MusicFlags
    ldrh    r0,[r1]
    ldr     r2,=0b1111111100111110
    ands    r0,r2
    strh    r0,[r1]
    pop     {pc}

DS_CH1_DoneUpdating:
    ldr     r2,=DS_CH1_SeqPtr
    str     r1,[r2]
DS_CH1_Done:
    pop     {pc}

@ ================================================================================

DS_UpdateCH2:
    bx      lr
    
DS_UpdateCH3:
    bx      lr
    
DS_UpdateCH4:
    bx      lr
    
@ INPUT:    r7 = channel ID
DS_UpdateChannelDDMA:
    bx      lr

@ INPUT:    r7 = channel ID
DS_UpdateChannelMM:
    bx      lr
  
@ =============================================================================
@ Utility routines
@ =============================================================================

@ Clear DevSound's memory.
@ INPUT:    none
@ OUTPUT:   none
@ DESTROYS: r0, r1, r2
    .align  4
    .arm
DS_ClearMem:
    push    {r0-r2}
    ldr     r0,=DS_RAMStart
    ldr     r1,=DS_RAMEnd
    mov     r2,0
.clearloop:
    str     r2,[r0]
    add     r0,4
    cmp     r0,r1
    blt     .clearloop
    pop     {r0-r2}
    bx      lr

    .thumb
@ INPUT:    r0 = note number
@ OUTPUT:   r7 = frequency
@ DESTROYS: r0, r2, r3, r7
DS_GetNoteFrequencyDMG:
    ldr     r2,=DS_FreqTable
    movs    r3,2
    muls    r0,r3
    adds    r2,r0
    ldrh    r7,[r2]
    bx      lr

@ INPUT:    r2 = wave pointer
@ OUTPUT:   none
@ DESTROYS: none
DS_LoadWave:
    push    {r0-r4,lr}
    movs    r0,0
    ldr     r1,=REG_SOUND3CNT_L
    strh    r0,[r1]
    ldr     r3,=REG_WAVE_RAM
    movs    r4,4
1:  ldr     r0,[r2]
    str     r0,[r3]
    adds    r2,4
    adds    r2,4
    subs    r4,1
    cmp     r4,0
    bne     1b
    movs    r0,0b10000000
    strh    r0,[r1]
    pop     {r0-r4,pc}

@ =============================================================================

    .align 2 @ alignment needed for wave copy routine
DS_DefaultWave:
DS_Waves:
    .byte   0x8A,0xCD,0xEE,0xFF,0xFF,0xEE,0xCD,0xA8,0x75,0x32,0x11,0x00,0x00,0x11,0x23,0x57 @ sine
    .byte   0xFF,0xFF,0xFF,0xFF,0xFF,0xF0,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 @ bass
    .byte   0x00,0x11,0x22,0x33,0x44,0x55,0x66,0x77,0x88,0x99,0xAA,0xBB,0xCC,0xDD,0xEE,0xFF @ sawtooth
    .byte   0x01,0x23,0x45,0x67,0x89,0xAB,0xCD,0xEF,0xFE,0xDC,0xBA,0x98,0x76,0x54,0x32,0x10 @ triangle
    .byte   0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 @ 50% pulse (square)
    .byte   0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 @ 37.5% pulse
    .byte   0xFF,0xFF,0xFF,0xFF,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 @ 25% pulse
    .byte   0xFF,0xFF,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 @ 12.5% pulse
    .byte   0xFF,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 @ 6.25% pulse (SN7 noise)

DS_FreqTable:
    .hword  0x02c,0x09d,0x107,0x16b,0x1c9,0x223,0x277,0x2c7,0x312,0x358,0x39b,0x3da @ octave 1
    .hword  0x416,0x44e,0x483,0x4b5,0x4e5,0x511,0x53b,0x563,0x589,0x5ac,0x5ce,0x5ed @ octave 2
    .hword  0x60b,0x627,0x642,0x65b,0x672,0x689,0x69e,0x6b2,0x6c4,0x6d6,0x6e7,0x6f7 @ octave 3
    .hword  0x706,0x714,0x721,0x72d,0x739,0x744,0x74f,0x759,0x762,0x76b,0x773,0x77b @ octave 4
    .hword  0x783,0x78a,0x790,0x797,0x79d,0x7a2,0x7a7,0x7ac,0x7b1,0x7b6,0x7ba,0x7be @ octave 5
    .hword  0x7c1,0x7c5,0x7c8,0x7cb,0x7ce,0x7d1,0x7d4,0x7d6,0x7d9,0x7db,0x7dd,0x7df @ octave 6
    .hword  0x7e1,0x7e2,0x7e4,0x7e6,0x7e7,0x7e9,0x7ea,0x7eb,0x7ec,0x7ed,0x7ee,0x7ef @ octave 7
    .hword  0x7f0,0x7f1,0x7f2,0x7f3,0x7f4,0x7f4,0x7f5,0x7f6,0x7f6,0x7f7,0x7f7,0x7f8 @ octave 8

DSX_NoiseTable:
    .byte   0xA4
    .byte   0x97,0x96,0x95,0x94
    .byte   0x87,0x86,0x85,0x84
    .byte   0x77,0x76,0x75,0x74
    .byte   0x67,0x66,0x65,0x64
    .byte   0x57,0x56,0x55,0x54
    .byte   0x47,0x46,0x45,0x44
    .byte   0x37,0x36,0x35,0x34
    .byte   0x27,0x26,0x25,0x24
    .byte   0x17,0x16,0x15,0x14
    .byte   0x07,0x06,0x05,0x04
    .byte   0x03,0x02,0x01,0x00

    .pool   @ ugh

@ =============================================================================
    
    .align  4
DS_SongPointers:
    .word   DS_TestSong
    .word   Mus_Techno

@ =============================================================================

DS_RestVol:
DS_DummyTable:
DS_DummyChannel:
    sound_end
DS_DummyPitch:
    .byte  1,0,pitch_end

    .align  2
TestInstrument:
    .word   Vol_Test,Arp_Test,Pulse_Test,Vib_Test
    .word   0,0,0,0

Vol_Test:
    .byte   15,14,13,12,11,11,10,9,9,8,7,7,6,6,5,5,4,4,3,3,3,2,2,2,1,1,1,1,0,seq_end
Arp_Test:
1:  .byte   12,12,12,12,0,0,0,0
    .byte   seq_loop
    .align  2
    .word   1b
Pulse_Test:
1:  .byte   0,seq_wait,3
    .byte   1,seq_wait,3
    .byte   2,seq_wait,3
    .byte   3,seq_wait,3
    .byte   seq_loop
    .align  2
    .word   1b
    
Vib_Test:
    .byte   6
1:  .byte   1,2,3,2,1,0,-1,-2,-3,-2,-1,0
    .byte   pitch_loop
    .align  2
    .word   1b
    
    .align  2
DS_TestSong:
    .hword  0
    .byte   6,6
    .word   DS_Test_CH1
    .word   DS_DummyChannel
    .word   DS_DummyChannel
    .word   DS_DummyChannel
    
    .word   DS_DummyChannel
    .word   DS_DummyChannel
    .word   DS_DummyChannel
    .word   DS_DummyChannel
    .word   DS_DummyChannel
    .word   DS_DummyChannel
    .word   DS_DummyChannel
    .word   DS_DummyChannel

DS_Test_CH1:
    sound_instrument    TestInstrument
    note    nC_,4,3
    note    nD_,4,3
    note    nE_,4,3
    note    nF_,4,3
    note    nG_,4,3
    note    nA_,4,3
    note    nB_,4,3
    note    nC_,5,4
    sound_end

    .include "../source/music/techno.s"

@ =============================================================================
@ Memory defines
@ =============================================================================


    .section .bss

DS_RAMStart:

.align 2
DS_MusicPlaying:        .hword  0   @ 0 = music not playing, 1 = music playing
DS_GlobalTick:          .hword  0
DS_MusicFlags:          .hword  0   @  MMMMMMMM..BA4321
                                    @ 1, 2, 3, 4 = DMG channels
                                    @ A, B = Direct DMA channels
                                    @ M = MinMod channels
DS_MusicSpeed:          .hword  0   @ .......2 ......1
                                    @ lower half = first speed, upper half = second speed
DS_Mode:                .hword  0   @ (0 = DMG only, 1 = DMG + direct DMA, 2 = DMG + MinMod)
DS_MusicTick:           .hword  0
DS_MusicSpeedTick:      .hword  0
DS_MusicTimer:          .hword  0
DS_StereoFlags:         .hword  0
DS_GlobalTranspose:     .hword  0
    .align  2
DS_CH1_EchoBuffer:      .word   0
DS_CH2_EchoBuffer:      .word   0
DS_CH3_EchoBuffer:      .word   0
DS_CH4_EchoBuffer:      .word   0
DS_MM1_EchoBuffer:      .word   0
DS_MM2_EchoBuffer:      .word   0
DS_MM3_EchoBuffer:      .word   0
DS_MM4_EchoBuffer:      .word   0
DS_MM5_EchoBuffer:      .word   0
DS_MM6_EchoBuffer:      .word   0
DS_MM7_EchoBuffer:      .word   0
DS_MM8_EchoBuffer:      .word   0


DS_CH1_SeqPtr:          .word   0
DS_CH2_SeqPtr:          .word   0
DS_CH3_SeqPtr:          .word   0
DS_CH4_SeqPtr:          .word   0
DS_MM1_SeqPtr:          .word   0
DS_MM2_SeqPtr:          .word   0
DS_MM3_SeqPtr:          .word   0
DS_MM4_SeqPtr:          .word   0
DS_MM5_SeqPtr:          .word   0
DS_MM6_SeqPtr:          .word   0
DS_MM7_SeqPtr:          .word   0
DS_MM8_SeqPtr:          .word   0

DS_CH1_ReturnPtr:       .word   0
DS_CH1_VolPtr:          .word   0
DS_CH1_ArpPtr:          .word   0
DS_CH1_PulsePtr:        .word   0
DS_CH1_PitchPtr:        .word   0
DS_CH1_VolResetPtr:     .word   0
DS_CH1_ArpResetPtr:     .word   0
DS_CH1_PulseResetPtr:   .word   0
DS_CH1_PitchResetPtr:   .word   0
DS_CH1_VolReleasePtr:   .word   0
DS_CH1_ArpReleasePtr:   .word   0
DS_CH1_PulseReleasePtr: .word   0
DS_CH1_PitchReleasePtr: .word   0
DS_CH1_LoopCount:       .byte   0
DS_CH1_VolDelay:        .byte   0
DS_CH1_ArpDelay:        .byte   0
DS_CH1_PulseDelay:      .byte   0
DS_CH1_PitchDelay:      .byte   0
DS_CH1_Tick:            .byte   0
DS_CH1_Note:            .byte   0
DS_CH1_Timer:           .byte   0
DS_CH1_ArpTranspose:    .byte   0
DS_CH1_PitchMode:       .byte   0
    .align  1
DS_CH1_VibOffset:       .hword  0
DS_CH1_SlideOffset:     .hword  0
DS_CH1_SlideTarget:     .hword  0
DS_CH1_SlideSpeed:      .hword  0
DS_CH1_NoteTarget:      .byte   0
DS_CH1_Transpose:       .byte   0
DS_CH1_Sweep:           .byte   0
DS_CH1_ChannelVol:      .byte   0
DS_CH1_EchoPos:         .byte   0
DS_CH1_FirstNote:       .byte   0
DS_CH1_Pulse:           .byte   0
DS_CH1_Volume:          .byte   0
DS_CH1_OldVolume:       .byte   0
    .align  1
DS_CH1_Pitch:           .hword  0

    .align  2
DS_CH2_ReturnPtr:       .word   0
DS_CH2_VolPtr:          .word   0
DS_CH2_ArpPtr:          .word   0
DS_CH2_PulsePtr:        .word   0
DS_CH2_PitchPtr:        .word   0
DS_CH2_VolResetPtr:     .word   0
DS_CH2_ArpResetPtr:     .word   0
DS_CH2_PulseResetPtr:   .word   0
DS_CH2_PitchResetPtr:   .word   0
DS_CH2_VolReleasePtr:   .word   0
DS_CH2_ArpReleasePtr:   .word   0
DS_CH2_PulseReleasePtr: .word   0
DS_CH2_PitchReleasePtr: .word   0
DS_CH2_LoopCount:       .byte   0
DS_CH2_VolDelay:        .byte   0
DS_CH2_ArpDelay:        .byte   0
DS_CH2_PulseDelay:      .byte   0
DS_CH2_PitchDelay:      .byte   0
DS_CH2_Tick:            .byte   0
DS_CH2_Note:            .byte   0
DS_CH2_Timer:           .byte   0
DS_CH2_ArpTranspose:    .byte   0
DS_CH2_PitchMode:       .byte   0
    .align  1
DS_CH2_VibOffset:       .hword  0
DS_CH2_SlideOffset:     .hword  0
DS_CH2_SlideTarget:     .hword  0
DS_CH2_SlideSpeed:      .hword  0
DS_CH2_NoteTarget:      .byte   0
DS_CH2_Transpose:       .byte   0
DS_CH2_ChannelVol:      .byte   0
DS_CH2_EchoPos:         .byte   0
DS_CH2_FirstNote:       .byte   0
DS_CH2_Pulse:           .byte   0
DS_CH2_Volume:          .byte   0
DS_CH2_OldVolume:       .byte   0
    .align  1
DS_CH2_Pitch:           .hword  0

    .align  2
DS_CH3_ReturnPtr:       .word   0
DS_CH3_VolPtr:          .word   0
DS_CH3_ArpPtr:          .word   0
DS_CH3_WavePtr:         .word   0
DS_CH3_PitchPtr:        .word   0
DS_CH3_VolResetPtr:     .word   0
DS_CH3_ArpResetPtr:     .word   0
DS_CH3_WaveResetPtr:    .word   0
DS_CH3_PitchResetPtr:   .word   0
DS_CH3_VolReleasePtr:   .word   0
DS_CH3_ArpReleasePtr:   .word   0
DS_CH3_WaveReleasePtr:  .word   0
DS_CH3_PitchReleasePtr: .word   0
DS_CH3_LoopCount:       .byte   0
DS_CH3_VolDelay:        .byte   0
DS_CH3_ArpDelay:        .byte   0
DS_CH3_WaveDelay:       .byte   0
DS_CH3_PitchDelay:      .byte   0
DS_CH3_Tick:            .byte   0
DS_CH3_Note:            .byte   0
DS_CH3_Timer:           .byte   0
DS_CH3_ArpTranspose:    .byte   0
DS_CH3_PitchMode:       .byte   0
    .align  1
DS_CH3_VibOffset:       .hword  0
DS_CH3_SlideOffset:     .hword  0
DS_CH3_SlideTarget:     .hword  0
DS_CH3_SlideSpeed:      .hword  0
DS_CH3_NoteTarget:      .byte   0
DS_CH3_Transpose:       .byte   0
DS_CH3_EchoPos:         .byte   0
DS_CH3_FirstNote:       .byte   0
DS_CH3_Wave:            .byte   0
DS_CH3_OldWave:         .byte   0
DS_CH3_Volume:          .byte   0
    .align  1
DS_CH3_Pitch:           .hword  0

    .align  2
DS_CH4_ReturnPtr:       .word   0
DS_CH4_VolPtr:          .word   0
DS_CH4_ArpPtr:          .word   0
DS_CH4_ModePtr:         .word   0
DS_CH4_VolResetPtr:     .word   0
DS_CH4_ArpResetPtr:     .word   0
DS_CH4_ModeResetPtr:    .word   0
DS_CH4_VolReleasePtr:   .word   0
DS_CH4_ArpReleasePtr:   .word   0
DS_CH4_ModeReleasePtr:  .word   0
DS_CH4_LoopCount:       .byte   0
DS_CH4_VolDelay:        .byte   0
DS_CH4_ArpDelay:        .byte   0
DS_CH4_ModeDelay:       .byte   0
DS_CH4_Tick:            .byte   0
DS_CH4_Note:            .byte   0
DS_CH4_Timer:           .byte   0
DS_CH4_ArpTranspose:    .byte   0
DS_CH4_ChannelVol:      .byte   0
DS_CH4_EchoPos:         .byte   0
DS_CH4_FirstNote:       .byte   0
DS_CH4_Mode:            .byte   0
DS_CH4_Volume:          .byte   0
DS_CH4_OldVolume:       .byte   0

DS_RAMEnd: