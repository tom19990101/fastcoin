;
; Implementation by the Keccak, Keyak and Ketje Teams, namely, Guido Bertoni,
; Joan Daemen, Michaël Peeters, Gilles Van Assche and Ronny Van Keer, hereby
; denoted as "the implementer".
;
; For more information, feedback or questions, please refer to our websites:
; http://keccak.noekeon.org/
; http://keyak.noekeon.org/
; http://ketje.noekeon.org/
;
; To the extent possible under law, the implementer has waived all copyright
; and related or neighboring rights to the source code in this file.
; http://creativecommons.org/publicdomain/zero/1.0/
;

; INFO: Tested on ATmega1280 simulator

; Registers used in all routines
#define zero    1
#define rpState 24
#define rX      26
#define rY      28
#define rZ      30
#define sp      0x3D

;----------------------------------------------------------------------------
;
; void KeccakF1600_Initialize( void )
;
.global KeccakF1600_Initialize

;----------------------------------------------------------------------------
;
; void KeccakF1600_StateInitialize(void *state)
;
; argument state   is passed in r24:r25
;
.global KeccakF1600_StateInitialize
KeccakF1600_StateInitialize:
    movw    rZ, r24
    ldi     r23, 5*5        ; clear state (8 bytes/1 lane per iteration)
KeccakF1600_StateInitialize_Loop:
    st      z+, zero
    st      z+, zero
    st      z+, zero
    st      z+, zero
    st      z+, zero
    st      z+, zero
    st      z+, zero
    st      z+, zero
    dec     r23
    brne    KeccakF1600_StateInitialize_Loop
KeccakF1600_Initialize:
    ret

;----------------------------------------------------------------------------
;
; void KeccakF1600_StateComplementBit(void *state, unsigned int position)
;
; argument state    is passed in r24:r25
; argument position is passed in r22:r23
;
.global KeccakF1600_StateComplementBit
KeccakF1600_StateComplementBit:
    movw    rZ, r24
    ldi     r21, 1
    mov     r20, r22        ; bitnumber = position & 7
    andi    r20, 7
    breq    KeccakF1600_StateComplementBit_LoopEnd
KeccakF1600_StateComplementBit_Loop:
    lsl     r21
    dec     r20
    brne    KeccakF1600_StateComplementBit_Loop
KeccakF1600_StateComplementBit_LoopEnd:
    lsr     r23              ; bytenumber = position >> 3
    ror     r22
    lsr     r23
    ror     r22
    lsr     r23
    ror     r22
    add     rZ, r22
    adc     rZ+1, zero
    ld      r20, Z
    eor     r20, r21
    st      Z, r20
    ret

;----------------------------------------------------------------------------
;
; void KeccakF1600_StateXORBytes(void *state, const unsigned char *data, unsigned int offset, unsigned int length)
;
; argument state     is passed in r24:r25
; argument data      is passed in r22:r23
; argument offset    is passed in r20:r21, only LSB (r20) is used
; argument length    is passed in r18:r19, only LSB (r18) is used
;
.global KeccakF1600_StateXORBytes
KeccakF1600_StateXORBytes:
    movw    rZ, r24
    add     rZ, r20
    adc     rZ+1, zero
    movw    rX, r22
    subi    r18, 8
    brcs    KeccakF1600_StateXORBytes_Byte
    ;do 8 bytes per iteration
KeccakF1600_StateXORBytes_Loop8:
    ld      r21, X+
    ld      r0, Z
    eor     r0, r21
    st      Z+, r0
    ld      r21, X+
    ld      r0, Z
    eor     r0, r21
    st      Z+, r0
    ld      r21, X+
    ld      r0, Z
    eor     r0, r21
    st      Z+, r0
    ld      r21, X+
    ld      r0, Z
    eor     r0, r21
    st      Z+, r0
    ld      r21, X+
    ld      r0, Z
    eor     r0, r21
    st      Z+, r0
    ld      r21, X+
    ld      r0, Z
    eor     r0, r21
    st      Z+, r0
    ld      r21, X+
    ld      r0, Z
    eor     r0, r21
    st      Z+, r0
    ld      r21, X+
    ld      r0, Z
    eor     r0, r21
    st      Z+, r0
    subi    r18, 8
    brcc    KeccakF1600_StateXORBytes_Loop8
KeccakF1600_StateXORBytes_Byte:
    ldi     r19, 8
    add     r18, r19
    breq    KeccakF1600_StateXORBytes_End
KeccakF1600_StateXORBytes_Loop1:
    ld      r21, X+
    ld      r0, Z
    eor     r0, r21
    st      Z+, r0
    dec     r18
    brne    KeccakF1600_StateXORBytes_Loop1
KeccakF1600_StateXORBytes_End:
    ret


;----------------------------------------------------------------------------
;
; void KeccakF1600_StateOverwriteBytes(void *state, const unsigned char *data, unsigned int offset, unsigned int length)
;
; argument state     is passed in r24:r25
; argument data      is passed in r22:r23
; argument offset    is passed in r20:r21, only LSB (r20) is used
; argument length    is passed in r18:r19, only LSB (r18) is used
;
.global KeccakF1600_StateOverwriteBytes
KeccakF1600_StateOverwriteBytes:
    movw    rZ, r24
    add     rZ, r20
    adc     rZ+1, zero
    movw    rX, r22
    subi    r18, 8
    brcs    KeccakF1600_StateOverwriteBytes_Byte
    ;do 8 bytes per iteration
KeccakF1600_StateOverwriteBytes_Loop8:
    ld      r0, X+
    st      Z+, r0
    ld      r0, X+
    st      Z+, r0
    ld      r0, X+
    st      Z+, r0
    ld      r0, X+
    st      Z+, r0
    ld      r0, X+
    st      Z+, r0
    ld      r0, X+
    st      Z+, r0
    ld      r0, X+
    st      Z+, r0
    ld      r0, X+
    st      Z+, r0
    subi    r18, 8
    brcc    KeccakF1600_StateOverwriteBytes_Loop8
KeccakF1600_StateOverwriteBytes_Byte:
    ldi     r19, 8
    add     r18, r19
    breq    KeccakF1600_StateOverwriteBytes_End
KeccakF1600_StateOverwriteBytes_Loop1:
    ld      r0, X+
    st      Z+, r0
    dec     r18
    brne    KeccakF1600_StateOverwriteBytes_Loop1
KeccakF1600_StateOverwriteBytes_End:
    ret

;----------------------------------------------------------------------------
;
; void KeccakF1600_StateOverwriteWithZeroes(void *state, unsigned int byteCount)
;
; argument state        is passed in r24:r25
; argument byteCount    is passed in r22:r23, only LSB (r22) is used
;
.global KeccakF1600_StateOverwriteWithZeroes
KeccakF1600_StateOverwriteWithZeroes:
    movw    rZ, r24         ; rZ = state
    mov     r23, r22
    lsr     r23
    lsr     r23
    lsr     r23
    breq    KeccakF1600_StateOverwriteWithZeroes_Bytes
KeccakF1600_StateOverwriteWithZeroes_LoopLanes:
    st      Z+, r1
    st      Z+, r1
    st      Z+, r1
    st      Z+, r1
    st      Z+, r1
    st      Z+, r1
    st      Z+, r1
    st      Z+, r1
    dec     r23
    brne    KeccakF1600_StateOverwriteWithZeroes_LoopLanes
KeccakF1600_StateOverwriteWithZeroes_Bytes:
    andi    r22, 7
    breq    KeccakF1600_StateOverwriteWithZeroes_End
KeccakF1600_StateOverwriteWithZeroes_LoopBytes:
    st      Z+, r1
    dec     r22
    brne    KeccakF1600_StateOverwriteWithZeroes_LoopBytes
KeccakF1600_StateOverwriteWithZeroes_End:
    ret

;----------------------------------------------------------------------------
;
; void KeccakF1600_StateExtractBytes(void *state, const unsigned char *data, unsigned int offset, unsigned int length)
;
; argument state     is passed in r24:r25
; argument data      is passed in r22:r23
; argument offset    is passed in r20:r21, only LSB (r20) is used
; argument length    is passed in r18:r19, only LSB (r18) is used
;
.global KeccakF1600_StateExtractBytes
KeccakF1600_StateExtractBytes:
    movw    rZ, r24
    add     rZ, r20
    adc     rZ+1, zero
    movw    rX, r22
    subi    r18, 8
    brcs    KeccakF1600_StateExtractBytes_Byte
    ;do 8 bytes per iteration
KeccakF1600_StateExtractBytes_Loop8:
    ld      r0, Z+
    st      X+, r0
    ld      r0, Z+
    st      X+, r0
    ld      r0, Z+
    st      X+, r0
    ld      r0, Z+
    st      X+, r0
    ld      r0, Z+
    st      X+, r0
    ld      r0, Z+
    st      X+, r0
    ld      r0, Z+
    st      X+, r0
    ld      r0, Z+
    st      X+, r0
    subi    r18, 8
    brcc    KeccakF1600_StateExtractBytes_Loop8
KeccakF1600_StateExtractBytes_Byte:
    ldi     r19, 8
    add     r18, r19
    breq    KeccakF1600_StateExtractBytes_End
KeccakF1600_StateExtractBytes_Loop1:
    ld      r0, Z+
    st      X+, r0
    dec     r18
    brne    KeccakF1600_StateExtractBytes_Loop1
KeccakF1600_StateExtractBytes_End:
    ret

;----------------------------------------------------------------------------
;
; void KeccakF1600_StateExtractAndXORBytes(void *state, const unsigned char *data, unsigned int offset, unsigned int length)
;
; argument state     is passed in r24:r25
; argument data      is passed in r22:r23
; argument offset    is passed in r20:r21, only LSB (r20) is used
; argument length    is passed in r18:r19, only LSB (r18) is used
;
.global KeccakF1600_StateExtractAndXORBytes
KeccakF1600_StateExtractAndXORBytes:
    movw    rZ, r24
    add     rZ, r20
    adc     rZ+1, zero
    movw    rX, r22
    subi    r18, 8
    brcs    KeccakF1600_StateExtractAndXORBytes_Byte
    ;do 8 bytes per iteration
KeccakF1600_StateExtractAndXORBytes_Loop8:
    ld      r21, Z+
    ld      r0, X
    eor     r0, r21
    st      X+, r0
    ld      r21, Z+
    ld      r0, X
    eor     r0, r21
    st      X+, r0
    ld      r21, Z+
    ld      r0, X
    eor     r0, r21
    st      X+, r0
    ld      r21, Z+
    ld      r0, X
    eor     r0, r21
    st      X+, r0
    ld      r21, Z+
    ld      r0, X
    eor     r0, r21
    st      X+, r0
    ld      r21, Z+
    ld      r0, X
    eor     r0, r21
    st      X+, r0
    ld      r21, Z+
    ld      r0, X
    eor     r0, r21
    st      X+, r0
    ld      r21, Z+
    ld      r0, X
    eor     r0, r21
    st      X+, r0
    subi    r18, 8
    brcc    KeccakF1600_StateExtractAndXORBytes_Loop8
KeccakF1600_StateExtractAndXORBytes_Byte:
    ldi     r19, 8
    add     r18, r19
    breq    KeccakF1600_StateExtractAndXORBytes_End
KeccakF1600_StateExtractAndXORBytes_Loop1:
    ld      r21, Z+
    ld      r0, X
    eor     r0, r21
    st      X+, r0
    dec     r18
    brne    KeccakF1600_StateExtractAndXORBytes_Loop1
KeccakF1600_StateExtractAndXORBytes_End:
    ret


#define ROT_BIT(a)      ((a) & 7)
#define ROT_BYTE(a)     ((((a)/8 + !!(((a)%8) > 4)) & 7) * 9)

KeccakP1600_12_RhoPiConstants:
    .BYTE   ROT_BIT( 1), ROT_BYTE( 3), 10 * 8
    .BYTE   ROT_BIT( 3), ROT_BYTE( 6),  7 * 8
    .BYTE   ROT_BIT( 6), ROT_BYTE(10), 11 * 8
    .BYTE   ROT_BIT(10), ROT_BYTE(15), 17 * 8
    .BYTE   ROT_BIT(15), ROT_BYTE(21), 18 * 8
    .BYTE   ROT_BIT(21), ROT_BYTE(28),  3 * 8
    .BYTE   ROT_BIT(28), ROT_BYTE(36),  5 * 8
    .BYTE   ROT_BIT(36), ROT_BYTE(45), 16 * 8
    .BYTE   ROT_BIT(45), ROT_BYTE(55),  8 * 8
    .BYTE   ROT_BIT(55), ROT_BYTE( 2), 21 * 8
    .BYTE   ROT_BIT( 2), ROT_BYTE(14), 24 * 8
    .BYTE   ROT_BIT(14), ROT_BYTE(27),  4 * 8
    .BYTE   ROT_BIT(27), ROT_BYTE(41), 15 * 8
    .BYTE   ROT_BIT(41), ROT_BYTE(56), 23 * 8
    .BYTE   ROT_BIT(56), ROT_BYTE( 8), 19 * 8
    .BYTE   ROT_BIT( 8), ROT_BYTE(25), 13 * 8
    .BYTE   ROT_BIT(25), ROT_BYTE(43), 12 * 8
    .BYTE   ROT_BIT(43), ROT_BYTE(62),  2 * 8
    .BYTE   ROT_BIT(62), ROT_BYTE(18), 20 * 8
    .BYTE   ROT_BIT(18), ROT_BYTE(39), 14 * 8
    .BYTE   ROT_BIT(39), ROT_BYTE(61), 22 * 8
    .BYTE   ROT_BIT(61), ROT_BYTE(20),  9 * 8
    .BYTE   ROT_BIT(20), ROT_BYTE(44),  6 * 8
    .BYTE   ROT_BIT(44), ROT_BYTE( 1),  1 * 8

KeccakP1600_12_RoundConstants:
    .BYTE   0x8b, 0x80, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
    .BYTE   0x8b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80
    .BYTE   0x89, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80
    .BYTE   0x03, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80
    .BYTE   0x02, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80
    .BYTE   0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80
    .BYTE   0x0a, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .BYTE   0x0a, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x80
    .BYTE   0x81, 0x80, 0x00, 0x80, 0x00, 0x00, 0x00, 0x80
    .BYTE   0x80, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80
    .BYTE   0x01, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
    .BYTE   0x08, 0x80, 0x00, 0x80, 0x00, 0x00, 0x00, 0x80
    .BYTE   0xFF, 0        ; terminator

    .text

#define pRound        22        // 2 regs (22-23)

;----------------------------------------------------------------------------
;
; void KeccakP1600_12_StatePermute( void *state )
;
.global KeccakP1600_12_StatePermute
KeccakP1600_12_StatePermute:
    ldi     pRound,   lo8(KeccakP1600_12_RoundConstants)
    ldi     pRound+1, hi8(KeccakP1600_12_RoundConstants)
    push    r2
    push    r3
    push    r4
    push    r5
    push    r6
    push    r7
    push    r8
    push    r9
    push    r10
    push    r11
    push    r12
    push    r13
    push    r14
    push    r15
    push    r16
    push    r17
    push    r28
    push    r29

    ; Allocate C variables (5*8)
    in      rZ,   sp
    in      rZ+1, sp+1
    sbiw     rZ, 40
    in      r0, 0x3F
    cli
    out     sp+1, rZ+1
    out     sp, rZ          ; Z points to 5 C lanes
    out     0x3F, r0

    ; Variables used in multiple operations
    #define rTemp        2        // 8 regs (2-9)
    #define rTempBis    10        // 8 regs (10-17)
    #define rTempTer    18        // 4 regs (18-21)

    ; Initial Prepare Theta
    #define TCIPx        rTempTer

    ldi     TCIPx, 5
    movw    rY, rpState
KeccakInitialPrepTheta_Loop:
    ld      rTemp+0, Y+     ; state[x]
    ld      rTemp+1, Y+
    ld      rTemp+2, Y+
    ld      rTemp+3, Y+
    ld      rTemp+4, Y+
    ld      rTemp+5, Y+
    ld      rTemp+6, Y+
    ld      rTemp+7, Y+

    adiw    rY, 32
    ld      r0, Y+          ; state[5+x]
    eor     rTemp+0, r0
    ld      r0, Y+
    eor     rTemp+1, r0
    ld      r0, Y+
    eor     rTemp+2, r0
    ld      r0, Y+
    eor     rTemp+3, r0
    ld      r0, Y+
    eor     rTemp+4, r0
    ld      r0, Y+
    eor     rTemp+5, r0
    ld      r0, Y+
    eor     rTemp+6, r0
    ld      r0, Y+
    eor     rTemp+7, r0

    adiw    rY, 32
    ld      r0, Y+          ; state[10+x]
    eor     rTemp+0, r0
    ld      r0, Y+
    eor     rTemp+1, r0
    ld      r0, Y+
    eor     rTemp+2, r0
    ld      r0, Y+
    eor     rTemp+3, r0
    ld      r0, Y+
    eor     rTemp+4, r0
    ld      r0, Y+
    eor     rTemp+5, r0
    ld      r0, Y+
    eor     rTemp+6, r0
    ld      r0, Y+
    eor     rTemp+7, r0

    adiw    rY, 32
    ld      r0, Y+          ; state[15+x]
    eor     rTemp+0, r0
    ld      r0, Y+
    eor     rTemp+1, r0
    ld      r0, Y+
    eor     rTemp+2, r0
    ld      r0, Y+
    eor     rTemp+3, r0
    ld      r0, Y+
    eor     rTemp+4, r0
    ld      r0, Y+
    eor     rTemp+5, r0
    ld      r0, Y+
    eor     rTemp+6, r0
    ld      r0, Y+
    eor     rTemp+7, r0

    adiw    rY, 32
    ld      r0, Y+          ; state[20+x]
    eor     rTemp+0, r0
    ld      r0, Y+
    eor     rTemp+1, r0
    ld      r0, Y+
    eor     rTemp+2, r0
    ld      r0, Y+
    eor     rTemp+3, r0
    ld      r0, Y+
    eor     rTemp+4, r0
    ld      r0, Y+
    eor     rTemp+5, r0
    ld      r0, Y+
    eor     rTemp+6, r0
    ld      r0, Y+
    eor     rTemp+7, r0

    st      Z+, rTemp+0
    st      Z+, rTemp+1
    st      Z+, rTemp+2
    st      Z+, rTemp+3
    st      Z+, rTemp+4
    st      Z+, rTemp+5
    st      Z+, rTemp+6
    st      Z+, rTemp+7

    subi    rY, 160
    sbc     rY+1, zero

    subi    TCIPx,                 1
    breq    KeccakInitialPrepTheta_Done
    rjmp    KeccakInitialPrepTheta_Loop
KeccakInitialPrepTheta_Done:
    #undef  TCIPx

Keccak_RoundLoop:

    ; Theta
    #define TCplus          rX
    #define TCminus         rZ
    #define TCcoordX        rTempTer
    #define TCcoordY        rTempTer+1

    in      TCminus,   sp
    in      TCminus+1, sp+1
    movw    TCplus,  TCminus
    adiw    TCminus, 4*8
    adiw    TCplus,  1*8
    movw    rY, rpState

    ldi     TCcoordX, 0x16
KeccakTheta_Loop1:
    ld      rTemp+0, X+
    ld      rTemp+1, X+
    ld      rTemp+2, X+
    ld      rTemp+3, X+
    ld      rTemp+4, X+
    ld      rTemp+5, X+
    ld      rTemp+6, X+
    ld      rTemp+7, X+

    lsl     rTemp+0
    rol     rTemp+1
    rol     rTemp+2
    rol     rTemp+3
    rol     rTemp+4
    rol     rTemp+5
    rol     rTemp+6
    rol     rTemp+7
    adc     rTemp+0, zero

    ld      r0, Z+
    eor     rTemp+0, r0
    ld      r0, Z+
    eor     rTemp+1, r0
    ld      r0, Z+
    eor     rTemp+2, r0
    ld      r0, Z+
    eor     rTemp+3, r0
    ld      r0, Z+
    eor     rTemp+4, r0
    ld      r0, Z+
    eor     rTemp+5, r0
    ld      r0, Z+
    eor     rTemp+6, r0
    ld      r0, Z+
    eor     rTemp+7, r0

    ldi     TCcoordY, 5
KeccakTheta_Loop2:
    ld      r0, Y
    eor     r0, rTemp+0
    st      Y+, r0
    ld      r0, Y
    eor     r0, rTemp+1
    st      Y+, r0
    ld      r0, Y
    eor     r0, rTemp+2
    st      Y+, r0
    ld      r0, Y
    eor     r0, rTemp+3
    st      Y+, r0
    ld      r0, Y
    eor     r0, rTemp+4
    st      Y+, r0
    ld      r0, Y
    eor     r0, rTemp+5
    st      Y+, r0
    ld      r0, Y
    eor     r0, rTemp+6
    st      Y+, r0
    ld      r0, Y
    eor     r0, rTemp+7
    st      Y+, r0
    adiw    rY, 32

    dec     TCcoordY
    brne    KeccakTheta_Loop2

    subi    rY, 200-8
    sbc     rY+1, zero

    lsr     TCcoordX
    brcc    1f
    breq    KeccakTheta_End
    rjmp    KeccakTheta_Loop1
1:
    cpi     TCcoordX, 0x0B
    brne    2f
    sbiw    TCminus, 40
    rjmp    KeccakTheta_Loop1
2:
    sbiw    TCplus, 40
    rjmp    KeccakTheta_Loop1

KeccakTheta_End:
    #undef  TCplus
    #undef  TCminus
    #undef  TCcoordX
    #undef  TCcoordY

    ; Rho Pi
    #define RPpConst    rTempTer        // 2 regs
    #define RPindex     rTempTer+2
    #define RPpBitRot   rX
    #define RPpByteRot  pRound

    sbiw    rY, 32

    ld      rTemp+0, Y+
    ld      rTemp+1, Y+
    ld      rTemp+2, Y+
    ld      rTemp+3, Y+
    ld      rTemp+4, Y+
    ld      rTemp+5, Y+
    ld      rTemp+6, Y+
    ld      rTemp+7, Y+

    push    pRound
    push    pRound+1
    ldi     RPpConst,   lo8(KeccakP1600_12_RhoPiConstants)
    ldi     RPpConst+1, hi8(KeccakP1600_12_RhoPiConstants)
    ldi     RPpBitRot,   pm_lo8(bit_rot_jmp_table)
    ldi     RPpBitRot+1, pm_hi8(bit_rot_jmp_table)
    ldi     RPpByteRot,   pm_lo8(rotate64_0byte_left)
    ldi     RPpByteRot+1, pm_hi8(rotate64_0byte_left)

KeccakRhoPi_Loop:
    ; get rotation codes and state index
    movw    rZ, RPpConst
    lpm     r0, Z+          ; bits
    lpm     rTempBis, Z+    ; bytes
    lpm     RPindex, Z+
    movw    RPpConst, rZ

    ; do bit rotation
    movw    rZ, RPpBitRot
    add     rZ, r0
    adc     rZ+1, zero
    ijmp

KeccakRhoPi_RhoBitRotateDone:
    movw    rY, rpState
    add     rY, RPindex
    adc     rY+1, zero

    movw    rZ, RPpByteRot
    add     rZ, rTempBis
    adc     rZ+1, zero
    ijmp

KeccakRhoPi_PiStore:
    sbiw    rY, 8
    st      Y+, rTemp+0
    st      Y+, rTemp+1
    st      Y+, rTemp+2
    st      Y+, rTemp+3
    st      Y+, rTemp+4
    st      Y+, rTemp+5
    st      Y+, rTemp+6
    st      Y+, rTemp+7

    movw    rTemp+0, rTempBis+0
    movw    rTemp+2, rTempBis+2
    movw    rTemp+4, rTempBis+4
    movw    rTemp+6, rTempBis+6
KeccakRhoPi_RhoDone:
    subi    RPindex, 8
    brne    KeccakRhoPi_Loop
    pop     pRound+1
    pop     pRound

    #undef  RPpConst
    #undef  RPindex
    #undef  RPpBitrot
    #undef  RPpByteRot


    ; Chi Iota prepare Theta
    #define CIPTa0          rTemp
    #define CIPTa1          rTemp+1
    #define CIPTa2          rTemp+2
    #define CIPTa3          rTemp+3
    #define CIPTa4          rTemp+4
    #define CIPTc0          rTempBis
    #define CIPTc1          rTempBis+1
    #define CIPTc2          rTempBis+2
    #define CIPTc3          rTempBis+3
    #define CIPTc4          rTempBis+4
    #define CIPTz           rTempBis+6
    #define CIPTy           rTempBis+7

    in      rX, sp          ; 5 * C
    in      rX+1, sp+1
    movw    rY, rpState
    movw    rZ, pRound

    ldi     CIPTz, 8
KeccakChiIotaPrepareTheta_zLoop:
    mov     CIPTc0, zero
    mov     CIPTc1, zero
    movw    CIPTc2, CIPTc0
    mov     CIPTc4, zero

    ldi     CIPTy, 5
KeccakChiIotaPrepareTheta_yLoop:
    ld      CIPTa0, Y
    ldd     CIPTa1, Y+8
    ldd     CIPTa2, Y+16
    ldd     CIPTa3, Y+24
    ldd     CIPTa4, Y+32

    ;*p = t = a0 ^ ((~a1) & a2); c0 ^= t;
    mov     r0, CIPTa1
    com     r0
    and     r0, CIPTa2
    eor     r0, CIPTa0
    eor     CIPTc0, r0
    st      Y, r0

    ;*(p+8) = t = a1 ^ ((~a2) & a3); c1 ^= t;
    mov     r0, CIPTa2
    com     r0
    and     r0, CIPTa3
    eor     r0, CIPTa1
    eor     CIPTc1, r0
    std     Y+8, r0

    ;*(p+16) = a2 ^= ((~a3) & a4); c2 ^= a2;
    mov     r0, CIPTa3
    com     r0
    and     r0, CIPTa4
    eor     r0, CIPTa2
    eor     CIPTc2, r0
    std     Y+16, r0

    ;*(p+24) = a3 ^= ((~a4) & a0); c3 ^= a3;
    mov     r0, CIPTa4
    com     r0
    and     r0, CIPTa0
    eor     r0, CIPTa3
    eor     CIPTc3, r0
    std     Y+24, r0

    ;*(p+32) = a4 ^= ((~a0) & a1); c4 ^= a4;
    com     CIPTa0
    and     CIPTa0, CIPTa1
    eor     CIPTa0, CIPTa4
    eor     CIPTc4, CIPTa0
    std     Y+32, CIPTa0

    adiw    rY, 40
    dec     CIPTy
    brne    KeccakChiIotaPrepareTheta_yLoop

    subi    rY, 200
    sbc     rY+1, zero

    lpm     r0, Z+            ;Round Constant
    ld      CIPTa0, Y
    eor     CIPTa0, r0
    st      Y+, CIPTa0

    movw    pRound, rZ
    movw    rZ, rX
    eor     CIPTc0, r0
    st      Z+, CIPTc0
    std     Z+7, CIPTc1
    std     Z+15, CIPTc2
    std     Z+23, CIPTc3
    std     Z+31, CIPTc4
    movw    rX, rZ
    movw    rZ, pRound

    dec     CIPTz
    brne    KeccakChiIotaPrepareTheta_zLoop

    #undef  CIPTa0
    #undef  CIPTa1
    #undef  CIPTa2
    #undef  CIPTa3
    #undef  CIPTa4
    #undef  CIPTc0
    #undef  CIPTc1
    #undef  CIPTc2
    #undef  CIPTc3
    #undef  CIPTc4
    #undef  CIPTz
    #undef  CIPTy

    ;Check for terminator
    lpm     r0, Z
    inc     r0
    breq    Keccak_Done
    rjmp    Keccak_RoundLoop
Keccak_Done:

    ; Free C(on stack) and registers
    in      rX, sp            ; free 5 C lanes
    in      rX+1, sp+1
    adiw    rX, 40
    in      r0, 0x3F
    cli
    out     sp+1, rX+1
    out     sp, rX
    out     0x3F, r0

    pop     r29
    pop     r28
    pop     r17
    pop     r16
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     r11
    pop     r10
    pop     r9
    pop     r8
    pop     r7
    pop     r6
    pop     r5
    pop     r4
    pop     r3
    pop     r2
    ret

bit_rot_jmp_table:
    rjmp    KeccakRhoPi_RhoBitRotateDone
    rjmp    rotate64_1bit_left
    rjmp    rotate64_2bit_left
    rjmp    rotate64_3bit_left
    rjmp    rotate64_4bit_left
    rjmp    rotate64_3bit_right
    rjmp    rotate64_2bit_right
    rjmp    rotate64_1bit_right

rotate64_4bit_left:
    lsl     rTemp
    rol     rTemp+1
    rol     rTemp+2
    rol     rTemp+3
    rol     rTemp+4
    rol     rTemp+5
    rol     rTemp+6
    rol     rTemp+7
    adc     rTemp, r1
rotate64_3bit_left:
    lsl     rTemp
    rol     rTemp+1
    rol     rTemp+2
    rol     rTemp+3
    rol     rTemp+4
    rol     rTemp+5
    rol     rTemp+6
    rol     rTemp+7
    adc     rTemp, r1
rotate64_2bit_left:
    lsl     rTemp
    rol     rTemp+1
    rol     rTemp+2
    rol     rTemp+3
    rol     rTemp+4
    rol     rTemp+5
    rol     rTemp+6
    rol     rTemp+7
    adc     rTemp, r1
rotate64_1bit_left:
    lsl     rTemp
    rol     rTemp+1
    rol     rTemp+2
    rol     rTemp+3
    rol     rTemp+4
    rol     rTemp+5
    rol     rTemp+6
    rol     rTemp+7
    adc     rTemp, r1
    rjmp    KeccakRhoPi_RhoBitRotateDone

rotate64_3bit_right:
    bst     rTemp, 0
    ror     rTemp+7
    ror     rTemp+6
    ror     rTemp+5
    ror     rTemp+4
    ror     rTemp+3
    ror     rTemp+2
    ror     rTemp+1
    ror     rTemp
    bld     rTemp+7, 7
rotate64_2bit_right:
    bst     rTemp, 0
    ror     rTemp+7
    ror     rTemp+6
    ror     rTemp+5
    ror     rTemp+4
    ror     rTemp+3
    ror     rTemp+2
    ror     rTemp+1
    ror     rTemp
    bld     rTemp+7, 7
rotate64_1bit_right:
    bst     rTemp, 0
    ror     rTemp+7
    ror     rTemp+6
    ror     rTemp+5
    ror     rTemp+4
    ror     rTemp+3
    ror     rTemp+2
    ror     rTemp+1
    ror     rTemp
    bld     rTemp+7, 7
    rjmp    KeccakRhoPi_RhoBitRotateDone

; Each byte rotate routine must be 9 instructions long.

rotate64_0byte_left:
    ld      rTempBis+0, Y+
    ld      rTempBis+1, Y+
    ld      rTempBis+2, Y+
    ld      rTempBis+3, Y+
    ld      rTempBis+4, Y+
    ld      rTempBis+5, Y+
    ld      rTempBis+6, Y+
    ld      rTempBis+7, Y+
    rjmp    KeccakRhoPi_PiStore

rotate64_1byte_left:
    ld      rTempBis+1, Y+
    ld      rTempBis+2, Y+
    ld      rTempBis+3, Y+
    ld      rTempBis+4, Y+
    ld      rTempBis+5, Y+
    ld      rTempBis+6, Y+
    ld      rTempBis+7, Y+
    ld      rTempBis+0, Y+
    rjmp    KeccakRhoPi_PiStore

rotate64_2byte_left:
    ld      rTempBis+2, Y+
    ld      rTempBis+3, Y+
    ld      rTempBis+4, Y+
    ld      rTempBis+5, Y+
    ld      rTempBis+6, Y+
    ld      rTempBis+7, Y+
    ld      rTempBis+0, Y+
    ld      rTempBis+1, Y+
    rjmp    KeccakRhoPi_PiStore

rotate64_3byte_left:
    ld      rTempBis+3, Y+
    ld      rTempBis+4, Y+
    ld      rTempBis+5, Y+
    ld      rTempBis+6, Y+
    ld      rTempBis+7, Y+
    ld      rTempBis+0, Y+
    ld      rTempBis+1, Y+
    ld      rTempBis+2, Y+
    rjmp    KeccakRhoPi_PiStore

rotate64_4byte_left:
    ld      rTempBis+4, Y+
    ld      rTempBis+5, Y+
    ld      rTempBis+6, Y+
    ld      rTempBis+7, Y+
    ld      rTempBis+0, Y+
    ld      rTempBis+1, Y+
    ld      rTempBis+2, Y+
    ld      rTempBis+3, Y+
    rjmp    KeccakRhoPi_PiStore

rotate64_5byte_left:
    ld      rTempBis+5, Y+
    ld      rTempBis+6, Y+
    ld      rTempBis+7, Y+
    ld      rTempBis+0, Y+
    ld      rTempBis+1, Y+
    ld      rTempBis+2, Y+
    ld      rTempBis+3, Y+
    ld      rTempBis+4, Y+
    rjmp    KeccakRhoPi_PiStore

rotate64_6byte_left:
    ld      rTempBis+6, Y+
    ld      rTempBis+7, Y+
    ld      rTempBis+0, Y+
    ld      rTempBis+1, Y+
    ld      rTempBis+2, Y+
    ld      rTempBis+3, Y+
    ld      rTempBis+4, Y+
    ld      rTempBis+5, Y+
    rjmp    KeccakRhoPi_PiStore

rotate64_7byte_left:
    ld      rTempBis+7, Y+
    ld      rTempBis+0, Y+
    ld      rTempBis+1, Y+
    ld      rTempBis+2, Y+
    ld      rTempBis+3, Y+
    ld      rTempBis+4, Y+
    ld      rTempBis+5, Y+
    ld      rTempBis+6, Y+
    rjmp    KeccakRhoPi_PiStore

    #undef  rTemp
    #undef  rTempBis
    #undef  rTempTer
    #undef  pRound

    #undef  rpState
    #undef  zero
    #undef  rX
    #undef  rY
    #undef  rZ
    #undef  sp
