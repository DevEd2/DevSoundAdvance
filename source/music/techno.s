    
    .align  2
Mus_Techno:
    .hword  0   @ mode 0 - DMG only
    .byte   7,7 @ song speed 7/7
    .word Mus_Techno_CH2
    .word Mus_Techno_CH1
    .word Mus_Techno_CH3
    .word Mus_Techno_CH4
    .word DS_DummyChannel
    .word DS_DummyChannel
    .word DS_DummyChannel
    .word DS_DummyChannel
    .word DS_DummyChannel
    .word DS_DummyChannel
    .word DS_DummyChannel
    .word DS_DummyChannel

@ ----------------

    .align  2
Ins_Lead1:
    .word Vol_Lead1,DS_DummyTable,Pulse_Lead1,Vib_Lead1
    .word Vol_Lead1R,0,0,0
Ins_WaveBass2:
    .word Vol_WaveBass2,DS_DummyTable,Wave_Bass2,DS_DummyTable
    .word 0,0,0,0
Ins_PulseEcho2:
    .word Vol_PulseEcho2,DS_DummyTable,Pulse_PulseEcho2,DS_DummyTable
    .word Vol_PulseEcho2R,0,0,0
Ins_Arp1:
    .word Vol_Arp1,DS_DummyTable,Pulse_Arp1,DS_DummyTable
    .word 0,0,0,0
Ins_BigArp:
    .word Vol_BigArp,Arp_BigArp,Pulse_BigArp,DS_DummyTable
    .word 0,0,0,0
Ins_SoftKick:
    .word Vol_Kick,Arp_SoftKick,Noise_SoftKick,DS_DummyTable
    .word 0,0,0,0
Ins_Kick:
    .word Vol_Kick,Arp_Kick,Noise_Kick,DS_DummyTable
    .word 0,0,0,0
Ins_Snare:
    .word Vol_Snare,Arp_Snare,Noise_Snare,DS_DummyTable
    .word 0,0,0,0
Ins_CHH:
    .word Vol_CHH,Arp_CHH,Noise_CHH,DS_DummyTable
    .word 0,0,0,0
Ins_OHH:
    .word Vol_OHH,Arp_OHH,Noise_OHH,DS_DummyTable
    .word 0,0,0,0
Ins_Cymbal:
    .word Vol_Cymb,Arp_Cymb,Noise_Cymb,DS_DummyTable
    .word 0,0,0,0
Ins_CymbR:
    .word Vol_CymbR,Arp_CymbR,Noise_OHH,DS_DummyTable
    .word 0,0,0,0

@ ----------------

Vol_Lead1:
    .byte 12,12,11,seq_wait,3,10,seq_wait,4,9,seq_end
Vol_Lead1R:
    .byte 8,seq_wait,10
    .byte 7,seq_wait,10
    .byte 6,seq_wait,10
    .byte 5,seq_wait,10
    .byte 4,seq_wait,10
    .byte 3,seq_wait,10
    .byte 2,seq_wait,10
    .byte 1,seq_wait,10
    .byte 0,seq_end
Vol_Lead2R:
    .byte 7,7,6,6,5,5,5,4,4,4,3,seq_wait,3,2,seq_wait,4,1,seq_end
Vol_WaveBass2:
    .byte 0x20,0x20,0x40,seq_end
Vol_PulseEcho2:
    .byte 6,seq_end
Vol_PulseEcho2R:
    .byte 0x83,seq_end
Vol_Arp1:
    .byte 11,10,9,8,7,6,6,5,5,4,4,4,3,3,3,2,seq_wait,3,1,seq_wait,4,0,seq_end
Vol_BigArp:
    .byte 5,seq_wait,27
    .byte 6,seq_wait,27
    .byte 7,seq_wait,27
    .byte 8,seq_wait,27
    .byte 9,seq_wait,27
    .byte 8,seq_wait,27
    .byte 7,seq_wait,27
    .byte 6,seq_wait,27
    .byte 5,seq_wait,27
    .byte 4,seq_wait,27
    .byte 3,seq_wait,27
    .byte 2,seq_wait,27
    .byte 1,seq_wait,27
    .byte 0,seq_end
Vol_Kick:
    .byte 15,15,14,12,1,4,4,3,3,2,2,1,1,0,seq_end
Vol_Snare:
    .byte 12,11,10,9,8,7,6,5,4,3,2,1,0,seq_end
Vol_CHH:
    .byte 6,3,3,2,seq_wait,4,1,1,1,0,seq_end
Vol_OHH:
    .byte 6,5,4,4,3,seq_wait,3,2,seq_end
Vol_Cymb:
    .byte 10,seq_wait,7
    .byte  6,seq_wait,7
    .byte  5,seq_wait,7
    .byte  4,seq_wait,7
    .byte  3,seq_wait,15
    .byte  2,seq_wait,15
    .byte  1,seq_wait,15
    .byte  0,seq_end
Vol_CymbR:
    .byte  1,seq_wait,7
    .byte  2,seq_wait,7
    .byte  3,seq_wait,7
    .byte  4,seq_wait,7
    .byte  5,seq_wait,7
    .byte  6,seq_wait,7
    .byte  7,seq_wait,7
    .byte  8,seq_wait,7
    .byte  9,seq_wait,7
    .byte 10,seq_end
    
@ ----------------

Arp_Kick:
    .byte 19,15,15,15,36,36,42,seq_end
Arp_SoftKick:
    .byte 18,18,43,seq_end
Arp_Snare:
    .byte 29,23,20,35,seq_end
Arp_CHH:
    .byte 43,seq_end
Arp_Cymb:
    .byte 26
    @ fall through
Arp_OHH:
Arp_CymbR:
    .byte 41,seq_end

Arp_1_037:
    .byte 0,3,7
    .byte seq_loop
    .align  2
    .word Arp_1_037
Arp_1_047:
    .byte 0,4,7
    .byte seq_loop
    .align  2
    .word Arp_1_047
Arp_1_038:
    .byte 0,3,8
    .byte seq_loop
    .align  2
    .word Arp_1_038
Arp_BigArp:
    .byte 0,0,0,0,2,2,2,5,5,5,5,9,9,9,12,12,12,12,3,9,9,9,7,7,7,7,5,5,5
    .byte seq_loop
    .align  2
    .word Arp_BigArp

@ ----------------

Pulse_Square:
    .byte 2,seq_end
Pulse_Lead1:
    .byte 2,0,seq_wait,2
1:  .byte 1,seq_wait,11
    .byte 0,seq_wait,11
    .byte 1,seq_wait,11
    .byte 2,seq_wait,11
    .byte seq_loop
    .align  2
    .word 1b 
Wave_Bass2:
    .byte 1,seq_end
Noise_Kick:
    .byte 1
    @ fall through
Noise_Snare:
    .byte 1
    @ fall through
Noise_SoftKick:
    .byte 1
    @ fall through
Noise_Cymb:
    .byte 1
    @ fall through
Wave_Bass1:
Noise_CHH:
Noise_OHH:
Pulse_PulseEcho2:
    .byte 0,seq_end
Pulse_Arp1:
    .byte 0,seq_wait,4
    .byte 1,seq_wait,4
    .byte 2,seq_wait,4
    .byte 3,seq_wait,4
    .byte seq_loop
    .align  2
    .word Pulse_Arp1
Pulse_BigArp:
    .byte 0,seq_wait,6
    .byte 1,seq_wait,6
    .byte 2,seq_wait,6
    .byte 3,seq_wait,6
    .byte 2,seq_wait,6
    .byte 1,seq_wait,6
    .byte seq_loop
    .align  2
    .word Pulse_BigArp
 
@ ----------------

Vib_Lead1:
    .byte 9
1:  .byte 2,4,4,2,0,-2,-4,-4,-2,0
    .byte pitch_loop
    .align  2
    .word 1b
Vib_Lead2:
    .byte 11
1:  .byte 2,4,6,4,2,0,-2,-4,-6,-4,-2,0
    .byte pitch_loop
    .align  2
    .word 1b

@ ================================================================

Mus_Techno_CH1:
    sound_instrument Ins_PulseEcho2
    rest 128
0:
    sound_call 3f
    sound_loop 9,0b
1:
    sound_call 3f
    sound_call 3f
    sound_transpose 2
    sound_call 3f
    sound_call 3f
    sound_reset_transpose
    sound_loop 1,1b
    rest 128
2:
    sound_call 3f
    sound_loop 3,2b
    sound_jump 0b

3:
    note nC_,5,1
    release 1
    note nC_,4,1
    release 1
    note nC_,6,1
    release 1
    note nC_,5,1
    note nG_,5,1
    release 1
    note nC_,5,1
    note nF_,5,1
    release 1
    note nG_,5,1
    release 1
    note nAs,4,1
    release 1
    note nC_,5,1
    release 1
    note nC_,4,1
    release 1
    note nC_,6,1
    release 1
    note nC_,5,1
    note nG_,5,1
    release 1
    note nC_,5,1
    note nF_,5,1
    release 1
    note nG_,5,1
    release 1
    note nAs,5,1
    release 1
    sound_ret

@ ----------------

Mus_Techno_CH2:
    rest 128
0:
    sound_instrument Ins_Arp1
    sound_volume 15
    sound_call 2f
    sound_call 2f
    sound_call 3f
    sound_call 2f
    sound_call 2f
    sound_call 3f
    sound_instrument Ins_BigArp
    note nAs,4,64
    rest 128
    rest 128
    sound_instrument Ins_Lead1
    sound_volume 10
1:
    note nB_,3,0
    sound_portamento 2
    note nC_,4,32
    note nC_,4,0
    sound_portamento 3
    note nD_,4,32
    note nB_,3,0
    sound_portamento 2
    note nC_,4,32
    note nD_,4,0
    sound_portamento 2
    note nDs,4,16
    note nC_,4,0
    sound_portamento 3
    note nD_,4,16
    sound_loop 1,1b
    sound_jump 0b
2:
    sound_set_arp_ptr Arp_1_037
    rest 2
    note nC_,5,2
    note nC_,5,3
    note nC_,5,2
    note nC_,5,3
    note nC_,5,2
    note nC_,5,4
    note nC_,5,2
    note nC_,5,3
    note nC_,5,2
    note nC_,5,2
    note nC_,5,1
    sound_set_arp_ptr Arp_1_047
    note nAs,4,2
    sound_set_arp_ptr Arp_1_037
    note nC_,5,2
    sound_ret
3:
    sound_set_arp_ptr Arp_1_047
    wait 2
    note nAs,4,2
    note nAs,4,3
    note nAs,4,2
    note nAs,4,3
    note nAs,4,2
    note nAs,4,4
    note nAs,4,2
    note nAs,4,3
    note nAs,4,2
    note nAs,4,2
    note nAs,4,1
    note nAs,4,2
    note nAs,4,4
    sound_set_arp_ptr Arp_1_038
    note nA_,4,2
    note nA_,4,3
    note nA_,4,2
    note nA_,4,3
    note nA_,4,2
    note nA_,4,4
    note nA_,4,2
    note nA_,4,3
    note nA_,4,2
    note nA_,4,2
    note nA_,4,1
    note nA_,4,2
    note nA_,4,2
    sound_ret

@ ----------------

Mus_Techno_CH3:
    sound_instrument Ins_WaveBass2
1:
@    sound_call 13f
@    sound_loop 7,1b
2:
    sound_call 13f
    sound_loop 3,2b
3:
    sound_call 14f
    sound_loop 1,3b
4:
    sound_call 15f
    sound_loop 1,4b
5:
    sound_call 13f
    sound_loop 3,5b
6:
    sound_call 14f
    sound_loop 1,6b
7:
    sound_call 15f
    sound_loop 1,7b
8:
    sound_call 13f
    sound_loop 7,8b
    sound_transpose 2
9:
    sound_call 13f
    sound_loop 3,9b
    sound_reset_transpose
10:
    sound_call 13f
    sound_loop 3,10b
    sound_transpose 2
11:
    sound_call 13f
    sound_loop 3,11b
    sound_reset_transpose
12:
    sound_call 13f
    sound_call 13f
    sound_call 14f
    sound_call 14f
    sound_call 15f
    sound_call 15f
    sound_call 16f
    sound_call 14f
    sound_loop 1,12b
    sound_jump 2b
    
13:
    note nAs,3,1
    note nC_,4,1
    note nC_,3,1
    note nC_,4,1
    note nC_,3,1
    note nC_,4,1
    note nDs,4,1
    note nC_,4,1
    note nC_,3,1
    note nC_,4,1
    note nC_,3,1
    note nC_,4,1
    note nAs,4,1
    note nC_,4,1
    note nC_,5,1
    note nC_,4,1
    sound_ret
14:
    note nA_,2,1
    note nAs,3,1
    note nAs,2,1
    note nAs,3,1
    note nAs,2,1
    note nAs,3,1
    note nD_,4,1
    note nAs,3,1
    note nAs,2,1
    note nAs,3,1
    note nAs,2,1
    note nAs,3,1
    note nGs,4,1
    note nAs,3,1
    note nAs,4,1
    note nAs,3,1
    sound_ret
15:
    note nA_,2,1
    note nF_,3,1
    note nF_,2,1
    note nF_,3,1
    note nF_,2,1
    note nF_,3,1
    note nGs,3,1
    note nF_,3,1
    note nF_,2,1
    note nF_,3,1
    note nF_,2,1
    note nF_,3,1
    note nDs,4,1
    note nF_,3,1
    note nF_,4,1
    note nF_,3,1
    sound_ret
16:
    note nG_,2,1
    note nGs,3,1
    note nGs,2,1
    note nGs,3,1
    note nGs,2,1
    note nGs,3,1
    note nC_,4,1
    note nGs,3,1
    note nGs,2,1
    note nGs,3,1
    note nGs,2,1
    note nGs,3,1
    note nG_,4,1
    note nGs,3,1
    note nGs,4,1
    note nGs,3,1
    sound_ret

@ ----------------

Mus_Techno_CH4:
@    sound_call 4f
1:
@    sound_call 5f
@    sound_loop 9,1b
2:
    sound_call 4f
3:
    sound_call 5f
    sound_loop 23,3b
    sound_jump 2b

4:
    sfixins Ins_Cymbal,56
    sfixins Ins_CymbR,8
    sound_ret
5:
    sfixins Ins_Kick,1
    sfixins Ins_CHH,1
    sfix 1
    sfix 1
    sfixins Ins_Snare,1
    sfixins Ins_CHH,1
    sfix 1
    sfix 1
    sfixins Ins_Kick,1
    sfixins Ins_CHH,1
    sfixins Ins_Kick,1
    sfixins Ins_CHH,1
    sfixins Ins_Snare,1
    sfixins Ins_CHH,1
    sfix 1
    sfix 1
    sfixins Ins_Kick,1
    sfixins Ins_CHH,1
    sfix 1
    sfix 1
    sfixins Ins_Snare,1
    sfixins Ins_CHH,1
    sfix 1
    sfix 1
    sfixins Ins_Kick,1
    sfixins Ins_CHH,1
    sfixins Ins_Kick,1
    sfixins Ins_CHH,1
    sfixins Ins_Snare,1
    sfixins Ins_CHH,1
    sfix 1
    sfixins Ins_Snare,1
    sound_ret
