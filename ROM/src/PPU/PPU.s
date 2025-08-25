; -----------------------------------------------------------------------------
;   File: PPU.s
;   Description: A collection of subroutines for interacting with VRAM, CGRAM,
;   OAMRAM, and the PPU.
; -----------------------------------------------------------------------------

;----- Export ------------------------------------------------------------------
.export     LoadVRAM
.export     LoadCGRAM
.export     UpdateOAMRAM
;-------------------------------------------------------------------------------

;----- Assembler Directives ----------------------------------------------------
.p816                           ; tell the assembler this is 65816 code
.A8                             ; set accumulator to 8-bit
.I16                            ; set index registers to 16-bit
;-------------------------------------------------------------------------------

;----- Includes ----------------------------------------------------------------
.include "Registers.inc"
.include "macros.inc"
;-------------------------------------------------------------------------------

.segment "CODE"
;-------------------------------------------------------------------------------
;   Load sprite data into VRAM
;   Parameters: NumBytes: .word, SrcPointer: .addr, DestPointer: .addr
;-------------------------------------------------------------------------------
.proc   LoadVRAM
        phx                     ; save old stack pointer
        ; create frame pointer
        phd                     ; push Direct Register to stack
        tsc                     ; transfer Stack to... (via Accumulator)
        tcd                     ; ...Direct Register.
        ; use constants to access arguments on stack with Direct Addressing
        NumBytes    = $07       ; number of bytes to transfer
        SrcPointer  = $09       ; source address of sprite data
        DestPointer = $0b       ; destination address in VRAM

        ; set destination address in VRAM, and address increment after writing to VRAM
        ldx DestPointer         ; load the destination pointer...
        stx VMADDL              ; ...and set VRAM address register to it
        lda #$80
        sta VMAINC              ; increment VRAM address by 1 when writing to VMDATAH

        DMA0 #%00000001, #<VMDATAL, SrcPointer, NumBytes

        ; all done
        pld                     ; restore caller's frame pointer
        plx                     ; restore old stack pointer
        rts
.endproc
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;   Load color data into CGRAM
;   NumBytes: .word, SrcPointer: .byte, DestPointer: .addr
;-------------------------------------------------------------------------------
.proc   LoadCGRAM
        phx                     ; save old stack pointer
        ; create frame pointer
        phd                     ; push Direct Register to stack
        tsc                     ; transfer Stack to... (via Accumulator)
        tcd                     ; ...Direct Register.
        ; use constants to access arguments on stack with Direct Addressing
        NumBytes    = $07       ; number of bytes to transfer
        SrcPointer  = $09       ; source address of sprite data
        DestPointer = $0b       ; destination address in VRAM

        ; set CGDRAM destination address
        lda DestPointer         ; get destination address
        sta CGADD               ; set CGRAM destination address

        DMA0 #%00000010, #<CGDATA, SrcPointer, NumBytes

        ; all done
        pld                     ; restore caller's frame pointer
        plx                     ; restore old stack pointer
        rts
.endproc
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;   Copies the OAMRAM mirror into OAMRAM
;-------------------------------------------------------------------------------
.proc   UpdateOAMRAM
        phx                     ; save old stack pointer
        ; create frame pointer
        phd                     ; push Direct Register to stack
        tsc                     ; transfer Stack to... (via Accumulator)
        tcd                     ; ...Direct Register.
        ; use constants to access arguments on stack with Direct Addressing
        MirrorAddr  = $07       ; address of the mirror we want to copy

        DMA0 #%00000010, #<OAMDATA, MirrorAddr, #$0220

        ; OAMRAM update is done, restore frame and stack pointer
        pld                     ; restore caller's frame pointer
        plx                     ; restore old stack pointer
        rts
.endproc
;-------------------------------------------------------------------------------
