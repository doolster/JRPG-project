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

; ------------------------------------------------------------------------------

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
