.ifndef MACROS_INC
MACROS_INC = 1
; -----------------------------------------------------------------------------
;   File: macros.inc
;   Description: macro definitions
; -----------------------------------------------------------------------------

; [ set the size of accumulator/index registers ]

.macro setA8
	sep #$20
.endmacro

.macro setA16
	rep #$20
.endmacro

.macro setAXY8
	sep #$30
.endmacro

.macro setAXY16
	rep #$30
.endmacro

.macro setXY8
	sep #$10
.endmacro

.macro setXY16
	rep #$10
.endmacro

; [ bne/beq extension ]

.macro jeq addr
    bne mbne
    jmp addr
    mbne:
.endmacro

.macro jne addr
    beq mbeq
    jmp addr
    mbeq:
.endmacro

; ------------------------------------------------------------------------------

; [ repeated operation ]

.mac op_n op, n
        .repeat n
        op
        .endrep
.endmac

; no operation
.define nop2 op_n nop, 2
.define nop3 op_n nop, 3
.define nop4 op_n nop, 4
.define nop5 op_n nop, 5
.define nop6 op_n nop, 6
.define nop7 op_n nop, 7
.define nop8 op_n nop, 8

; shift left
.define asl2 op_n asl, 2
.define asl3 op_n asl, 3
.define asl4 op_n asl, 4
.define asl5 op_n asl, 5
.define asl6 op_n asl, 6
.define asl7 op_n asl, 7
.define asl8 op_n asl, 8

; shift right
.define lsr2 op_n lsr, 2
.define lsr3 op_n lsr, 3
.define lsr4 op_n lsr, 4
.define lsr5 op_n lsr, 5
.define lsr6 op_n lsr, 6
.define lsr7 op_n lsr, 7
.define lsr8 op_n lsr, 8

; rotate left
.define rol2 op_n rol, 2
.define rol3 op_n rol, 3
.define rol4 op_n rol, 4
.define rol5 op_n rol, 5
.define rol6 op_n rol, 6
.define rol7 op_n rol, 7
.define rol8 op_n rol, 8

; rotate right
.define ror2 op_n ror, 2
.define ror3 op_n ror, 3
.define ror4 op_n ror, 4
.define ror5 op_n ror, 5
.define ror6 op_n ror, 6
.define ror7 op_n ror, 7
.define ror8 op_n ror, 8

; increment
.define inc2 op_n inc, 2
.define inc3 op_n inc, 3
.define inc4 op_n inc, 4
.define inc5 op_n inc, 5
.define inc6 op_n inc, 6
.define inc7 op_n inc, 7
.define inc8 op_n inc, 8

; decrement
.define dec2 op_n dec, 2
.define dec3 op_n dec, 3
.define dec4 op_n dec, 4
.define dec5 op_n dec, 5
.define dec6 op_n dec, 6
.define dec7 op_n dec, 7
.define dec8 op_n dec, 8

; increment x
.define inx2 op_n inx, 2
.define inx3 op_n inx, 3
.define inx4 op_n inx, 4
.define inx5 op_n inx, 5
.define inx6 op_n inx, 6
.define inx7 op_n inx, 7
.define inx8 op_n inx, 8

; decrement x
.define dex2 op_n dex, 2
.define dex3 op_n dex, 3
.define dex4 op_n dex, 4
.define dex5 op_n dex, 5
.define dex6 op_n dex, 6
.define dex7 op_n dex, 7
.define dex8 op_n dex, 8

; increment y
.define iny2 op_n iny, 2
.define iny3 op_n iny, 3
.define iny4 op_n iny, 4
.define iny5 op_n iny, 5
.define iny6 op_n iny, 6
.define iny7 op_n iny, 7
.define iny8 op_n iny, 8

; decrement y
.define dey2 op_n dey, 2
.define dey3 op_n dey, 3
.define dey4 op_n dey, 4
.define dey5 op_n dey, 5
.define dey6 op_n dey, 6
.define dey7 op_n dey, 7
.define dey8 op_n dey, 8

;-------------------------------------------------------------------------------

; [ DMA macros ]

;-------------------------------------------------------------------------------
;   DMA channel 0 - a8, x16
;   control: .byte, dest: .addr, start: .addr, numBytes: .word
;-------------------------------------------------------------------------------
.macro DMA0 control, dest, start, numBytes
    lda control
    sta DMAP0
    lda dest
    sta BBAD0           ; Set DMA destination address
    ldx start
    stx A1T0L           ; Set low and high bytes of start address
    stz A1T0B           ; Set start adress bank to 0
    ldx numBytes
    stx DAS0L           ; Set number of bytes to transfer
    lda #$01
    sta MDMAEN          ; Start DMA in channel 0
.endmacro

; ------------------------------------------------------------------------------
.endif
