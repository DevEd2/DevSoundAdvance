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
    
    .equ    REG_WAVE_RAM,   0x04000090 @ DMG wave RAM bank
    
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

    .global brk
    .macro brk
    mov     r11,r11
    .endm
@ =============================================================================
@ Sound command definitions
@ =============================================================================

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
    .word \ptr
    .endm
    
    @ Jump to another section
    .global sound_jump
    .macro sound_jump ptr
    .byte 0x81
    .word \ptr
    .endm
    
    @ Loop a section
    .global sound_loop
    .macro sound_loop cnt,ptr
    .byte 0x82
    .byte \cnt
    .word \ptr
    .endm
    
    @ Jump to another section and return when a sound_ret command is reached
    .global sound_call
    .macro sound_call ptr
    .byte 0x83
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
    .word \ptr
    .endm
    
    @ Set song tempo
    .global sound_set_speed
    .macro sound_set_speed spd1, spd2
    .byte 0x90
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
    note C_,2,\length
    .endm
    
    .global sfixins
    .macro sfixins ptr,length
    sound_instrument \ptr
    note C_,2,\length
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

    @ clear memory
    ldr     r0,=DS_RAMStart
    ldr     r1,=DS_RAMEnd
    mov     r2,0
.clearloop:
    str     r2,[r0]
    add     r0,4
    cmp     r0,r1
    blt     .clearloop
    
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
    
    pop     {r0-r12, lr}
    bx      lr

@ =============================================================================

    .global DS_LoadSong
    .type DS_LoadSong STT_FUNC
@ INPUT: song ID in r0
DS_LoadSong:
    brk
    push    {r0-r12, lr}
    ldr     r1,=DS_SongPointers
    mov     r2,4
    mul     r0,r2
    ldr     r0,[r1,r0]
    @ pointer to song header is now in r0
    ldr     r1,=DS_CH1_SeqPtr
    mov     r4,12
1:  ldr     r3,[r0]
    str     r3,[r1]
    add     r0,4
    add     r1,4
    sub     r4,1
    cmp     r4,0
    bne     1b
    mov     r0,1
    ldr     r1,=DS_MusicPlaying
    strh    r0,[r1]
    ldr     r1,=DS_MusicFlags
    ldr     r0,=0b111111111111
    strh    r0,[r1]
    
    pop     {r0-r12, lr}
    bx      lr

@ =============================================================================

    .global DS_Stop
    .type   DS_Stop STT_FUNC
DS_Stop:
    brk
    push    {r0-r12, lr}
    
    pop     {r0-r12, lr}
    bx      lr

@ =============================================================================

    .global DS_Update
    .type   DS_Update STT_FUNC
    
    .thumb
DS_Update:
    push    {r0-r7,lr}

    
    
    pop     {r0-r7,pc}

@ =============================================================================
@ Utility routines
@ =============================================================================

@ INPUT: note number in r2
@ OUTPUT: r7 = frequency
DS_GetNoteFrequencyDMG:
    push    {lr}
    ldr     r0,=DS_FreqTable
    adds    r0,r2
    ldrh    r7,[r0]
    pop     {pc}

@ INPUT: wave pointer in r2
DS_LoadWave:
    push    {r0-r4,lr}
    movs    r0,0
    ldr     r1,=REG_SOUND3CNT_L
    strh    r0,[r1]
    ldr     r3,=REG_WAVE_RAM
    movs    r4,4
.loop:
    ldr     r0,[r2]
    str     r0,[r3]
    adds    r2,4
    adds    r2,4
    subs    r4,1
    cmp     r4,0
    bne     .loop
    movs    r0,0b10000000
    strh    r0,[r1]
    pop     {r0-r4,pc}

@ =============================================================================

    .section .text
    .align 4
DS_DefaultWave:
DS_Waves:
    .byte   0x8A,0xCD,0xEE,0xFF,0xFF,0xEE,0xCD,0xA8,0x75,0x32,0x11,0x00,0x00,0x11,0x23,0x57 @ sine
    .byte   0xFF,0xFF,0xFF,0xFF,0xFF,0xF0,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 @ bass
    
@    .byte   0x00,0x11,0x22,0x33,0x44,0x55,0x66,0x77,0x88,0x99,0xAA,0xBB,0xCC,0xDD,0xEE,0xFF @ sawtooth
@    .byte   0x01,0x23,0x45,0x67,0x89,0xAB,0xCD,0xEF,0xFE,0xDC,0xBA,0x98,0x76,0x54,0x32,0x10 @ triangle
@    .byte   0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 @ 50% pulse (square)
@    .byte   0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 @ 37.5% pulse
@    .byte   0xFF,0xFF,0xFF,0xFF,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 @ 25% pulse
@    .byte   0xFF,0xFF,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 @ 12.5% pulse
@    .byte   0xFF,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 @ 6.25% pulse (SN7 noise)

    .global DS_FreqTable
DS_FreqTable:
    .hword  0x02c,0x09d,0x107,0x16b,0x1c9,0x223,0x277,0x2c7,0x312,0x358,0x39b,0x3da @ octave 1
    .hword  0x416,0x44e,0x483,0x4b5,0x4e5,0x511,0x53b,0x563,0x589,0x5ac,0x5ce,0x5ed @ octave 2
    .hword  0x60b,0x627,0x642,0x65b,0x672,0x689,0x69e,0x6b2,0x6c4,0x6d6,0x6e7,0x6f7 @ octave 3
    .hword  0x706,0x714,0x721,0x72d,0x739,0x744,0x74f,0x759,0x762,0x76b,0x773,0x77b @ octave 4
    .hword  0x783,0x78a,0x790,0x797,0x79d,0x7a2,0x7a7,0x7ac,0x7b1,0x7b6,0x7ba,0x7be @ octave 5
    .hword  0x7c1,0x7c5,0x7c8,0x7cb,0x7ce,0x7d1,0x7d4,0x7d6,0x7d9,0x7db,0x7dd,0x7df @ octave 6
    .hword  0x7e1,0x7e2,0x7e4,0x7e6,0x7e7,0x7e9,0x7ea,0x7eb,0x7ec,0x7ed,0x7ee,0x7ef @ octave 7
    .hword  0x7f0,0x7f1,0x7f2,0x7f3,0x7f4,0x7f4,0x7f5,0x7f6,0x7f6,0x7f7,0x7f7,0x7f8 @ octave 8

@ =============================================================================

DS_DummyTable:
DS_DummyChannel:
    sound_end

TestInstrument:
    .word   Vol_Test,Arp_Test,Pulse_Test,Vib_Test
    .word   0,0,0,0

Vol_Test:
    .byte   15,14,13,12,11,11,10,9,9,8,7,7,6,6,5,5,4,4,3,3,3,2,2,2,1,1,1,1,0,seq_end
Arp_Test:
1:  .byte   12,12,12,12,0,0,0,0
    .byte   seq_loop
    .word   1b
Pulse_Test:
1:  .byte   0,seq_wait,3
    .byte   1,seq_wait,3
    .byte   2,seq_wait,3
    .byte   3,seq_wait,3
    .byte   seq_loop
    .word   1b
    
Vib_Test:
    .byte   6
1:  .byte   1,2,3,2,1,0,-1,-2,-3,-2,-1,0
    .byte   pitch_loop
    .word   1b
    
    .align  4
DS_TestSong:
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
    .byte   4,4

DS_Test_CH1:
    sound_instrument    TestInstrument
    note    nC_,4,3
    note    nD_,4,3
    note    nE_,4,3
    note    nF_,4,3
    note    nG_,4,3
    note    nA_,4,3
    note    nB_,4,3
    note    nC_,4,4
    sound_end

@ =============================================================================
    
    .align  4
DS_SongPointers:
    .word   DS_TestSong
@    .word   Mus_Techno
    
    .asciz  "END"

@ =============================================================================
@ Memory defines
@ =============================================================================


    .section .bss

DS_RAMStart:

.align 2
DS_MusicPlaying:        .hword  0   @ 0 = music not playing, 1 = music playing
DS_MusicFlags:          .hword  0   @ ................ MMMMMMMM..BA4321
                                    @ 1, 2, 3, 4 = DMG channels
                                    @ A, B = Direct DMA channels
                                    @ M = MinMod channels
DS_MusicSpeed:          .hword  0   @ ...............2 ..............1
                                    @ lower half = first speed, upper half = second speed
DS_MusicTick:           .hword  0
DS_MusicTimer:          .hword  0
DS_StereoFlags:         .hword  0
DS_GlobalTranspose:     .hword  0
    .align  4
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

    .align  4
DS_CH1_ReturnPtr:       .word   0
DS_CH1_VolPtr:          .word   0
DS_CH1_ArpPtr:          .word   0
DS_CH1_PulsePtr:        .word   0
DS_CH1_PitchPtr:        .word   0
DS_CH1_VolResetPtr:     .word   0
DS_CH1_VolReleasePtr:   .word   0
DS_CH1_ArpResetPtr:     .word   0
DS_CH1_ArpReleasePtr:   .word   0
DS_CH1_PulseResetPtr:   .word   0
DS_CH1_PulseReleasePtr: .word   0
DS_CH1_PitchResetPtr:   .word   0
DS_CH1_PitchReleasePtr: .word   0
    .align  1
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
    .align  2
DS_CH1_VibOffset:       .hword  0
DS_CH1_SlideOffset:     .hword  0
DS_CH1_SlideTarget:     .hword  0
DS_CH1_SlideSpeed:      .hword  0
    .align  1
DS_CH1_NoteTarget:      .byte   0
DS_CH1_Transpose:       .byte   0
DS_CH1_Sweep:           .byte   0
DS_CH1_ChannelVol:      .byte   0
DS_CH1_EchoPos:         .byte   0
DS_CH1_FirstNote:       .byte   0
DS_CH1_Pulse:           .byte   0
DS_CH1_Volume:          .byte   0
DS_CH1_OldVolume:       .byte   0
    .align  2
DS_CH1_Pitch:           .hword  0

    .align  4
DS_CH2_ReturnPtr:       .word   0
DS_CH2_VolPtr:          .word   0
DS_CH2_ArpPtr:          .word   0
DS_CH2_PulsePtr:        .word   0
DS_CH2_PitchPtr:        .word   0
DS_CH2_VolResetPtr:     .word   0
DS_CH2_VolReleasePtr:   .word   0
DS_CH2_ArpResetPtr:     .word   0
DS_CH2_ArpReleasePtr:   .word   0
DS_CH2_PulseResetPtr:   .word   0
DS_CH2_PulseReleasePtr: .word   0
DS_CH2_PitchResetPtr:   .word   0
DS_CH2_PitchReleasePtr: .word   0
    .align  1
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
    .align  2
DS_CH2_VibOffset:       .hword  0
DS_CH2_SlideOffset:     .hword  0
DS_CH2_SlideTarget:     .hword  0
DS_CH2_SlideSpeed:      .hword  0
    .align  1
DS_CH2_NoteTarget:      .byte   0
DS_CH2_Transpose:       .byte   0
DS_CH2_ChannelVol:      .byte   0
DS_CH2_EchoPos:         .byte   0
DS_CH2_FirstNote:       .byte   0
DS_CH2_Pulse:           .byte   0
DS_CH2_Volume:          .byte   0
DS_CH2_OldVolume:       .byte   0
    .align  2
DS_CH2_Pitch:           .hword  0

    .align  4
DS_CH3_ReturnPtr:       .word   0
DS_CH3_VolPtr:          .word   0
DS_CH3_ArpPtr:          .word   0
DS_CH3_WavePtr:         .word   0
DS_CH3_PitchPtr:        .word   0
DS_CH3_VolResetPtr:     .word   0
DS_CH3_VolReleasePtr:   .word   0
DS_CH3_ArpResetPtr:     .word   0
DS_CH3_ArpReleasePtr:   .word   0
DS_CH3_WaveResetPtr:    .word   0
DS_CH3_WaveReleasePtr:  .word   0
DS_CH3_PitchResetPtr:   .word   0
DS_CH3_PitchReleasePtr: .word   0
    .align  1
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
    .align  2
DS_CH3_VibOffset:       .hword  0
DS_CH3_SlideOffset:     .hword  0
DS_CH3_SlideTarget:     .hword  0
DS_CH3_SlideSpeed:      .hword  0
    .align  1
DS_CH3_NoteTarget:      .byte   0
DS_CH3_Transpose:       .byte   0
DS_CH3_EchoPos:         .byte   0
DS_CH3_FirstNote:       .byte   0
DS_CH3_Wave:            .byte   0
DS_CH3_OldWave:         .byte   0
DS_CH3_Volume:          .byte   0
    .align  2
DS_CH3_Pitch:           .hword  0

    .align  4
DS_CH4_ReturnPtr:       .word   0
DS_CH4_VolPtr:          .word   0
DS_CH4_ArpPtr:          .word   0
DS_CH4_ModePtr:         .word   0
DS_CH4_VolResetPtr:     .word   0
DS_CH4_VolReleasePtr:   .word   0
DS_CH4_ArpResetPtr:     .word   0
DS_CH4_ArpReleasePtr:   .word   0
DS_CH4_ModeResetPtr:    .word   0
DS_CH4_ModeReleasePtr:  .word   0
    .align  1
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
    .align  4

DS_RAMEnd: