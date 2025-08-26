; -----------------------------------------------------------------------------
;   File: Init.s
;   Description: Holds subroutines to initialize the demo
; -----------------------------------------------------------------------------

;----- Export ------------------------------------------------------------------
.export     InitDemo
;-------------------------------------------------------------------------------

;----- Assembler Directives ----------------------------------------------------
.p816                           ; tell the assembler this is 65816 code
.a8
.i16
;-------------------------------------------------------------------------------

;----- Includes ----------------------------------------------------------------
.include "Registers.inc"
.include "macros.inc"
.include "Assets.inc"
.include "GameConstants.inc"
.include "MemoryMapWRAM.inc"
.include "MemoryMapVRAM.inc"
.include "PPU.inc"
;-------------------------------------------------------------------------------

.segment "CODE"
;-------------------------------------------------------------------------------
;   This initializes the demo
;-------------------------------------------------------------------------------
.proc   InitDemo
        ; load color data into CGRAM
        tsx                             ; save current stack pointer
        lda #$80                        ; destination address in CGRAM
        pha
        pea ColorData                   ; color data source address
        ldy #$0020                      ; number of bytes (32/$20) to transfer (1 palette)
        phy
        jsr LoadCGRAM                   ; transfer color data into CGRAM
        txs                             ; restore old stack pointer

        tsx
        lda #$00
        pha
        pea BGColor
        ldy #$0020
        phy
        jsr LoadCGRAM
        txs

        ; load sprites into VRAM
        tsx                             ; save current stack pointer
        pea SPRITE_CHARS                ; push VRAM destination address to stack
        pea SpriteData                  ; push sprite data source address to stack
        ldy #$0080                      ; number of bytes (128/$80) to transfer (4 8x8 4BPP characters)
        phy
        jsr LoadVRAM                    ; transfer sprite data to VRAM
        txs                             ; restore old stack pointer

        ; initialize BG 1
        lda #$01
        sta BGMODE                      ; set BG mode to 1
        lda #BG1_TILEMAP>>8             ; shifting to get correct format for register
        sta BG1SC                       ; set address for BG 1 tilemap in VRAM
        lda #BG1_CHARS>>12              ; shifting to get correct format for register
        sta BG12NBA                     ; set address for BG 1 characters in VRAM

        ; load BG 1 characters into VRAM
        tsx
        pea BG1_CHARS
        pea BGCharData
        ldy #$0080                      ; number of bytes (128/$80) to transfer (4 8x8 4BPP characters)
        phy
        jsr LoadVRAM
        txs

        ; initialize tilemap mirror
        ldx #$0000
tilemapLoop:
        lda #$00
        cpx #$0040
        bcc notTopBot
        cpx #$07c0
        bcs notTopBot
        clc
        adc #$02
notTopBot:
        pha
        setA16
        txa
        bit #$003f
        beq notRL
        clc
        adc #$0002
        bit #$003f
        beq notRL
        setA8
        pla
        clc
        adc #$01
        pha
notRL:
        setA8
        pla
        sta TM1MIRROR, X                ; get correct character
        inx

        lda #$00
        cpx #$07c0
        bcc notTop
        clc
        adc #$80                        ; V mirror if on bottom
notTop:
        stx DEBUG
        pha
        setA16
        txa
        inc
        bit #$003f
        bne notR
        setA8
        pla
        clc
        adc #$40                        ; H mirror if on right
        pha
notR:
        setA8
        pla
        sta TM1MIRROR, X                ; flip if neccesary
        inx

        cpx #$0800
        bne tilemapLoop

        ; copy tilemap mirror into VRAM
        tsx
        pea BG1_TILEMAP
        pea TM1MIRROR
        ldy #$0800                      ; number of bytes ($800) to transfer (full 32x32 tilemap)
        phy
        jsr LoadVRAM
        txs

        ; initialize OAMRAM mirror
        ldx #$0000
        ; upper-left sprite
        lda #(SCREEN_RIGHT/2 - SPRITE_SIZE) ; sprite 1, horizontal position
        sta OAMMIRROR, X
        inx                                 ; increment index
        lda #(SCREEN_BOTTOM/2 - SPRITE_SIZE); sprite 1, vertical position
        sta OAMMIRROR, X
        inx
        lda #$00                            ; sprite 1, name
        sta OAMMIRROR, X
        inx
        lda #$20                            ; no flip, (sprite) palette 0, priority 2
        sta OAMMIRROR, X
        inx
        ; upper-right sprite
        lda #(SCREEN_RIGHT/2)               ; sprite 3, horizontal position
        sta OAMMIRROR, X
        inx                                 ; increment index
        lda #(SCREEN_BOTTOM/2 - SPRITE_SIZE); sprite 3, vertical position
        sta OAMMIRROR, X
        inx
        lda #$01                            ; sprite 3, name
        sta OAMMIRROR, X
        inx
        lda #$20                            ; no flip, palette 0
        sta OAMMIRROR, X
        inx
        ; lower-left sprite
        lda #(SCREEN_RIGHT/2 - SPRITE_SIZE) ; sprite 2, horizontal position
        sta OAMMIRROR, X
        inx                                 ; increment index
        lda #(SCREEN_BOTTOM/2)              ; sprite 2, vertical position
        sta OAMMIRROR, X
        inx
        lda #$02                            ; sprite 2, name
        sta OAMMIRROR, X
        inx
        lda #$20                            ; no flip, palette 0
        sta OAMMIRROR, X
        inx
        ; lower-right sprite
        lda #(SCREEN_RIGHT/2)                ; sprite 4, horizontal position
        sta OAMMIRROR, X
        inx                                 ; increment index
        lda #(SCREEN_BOTTOM/2)              ; sprite 4, vertical position
        sta OAMMIRROR, X
        inx
        lda #$03                            ; sprite 4, name
        sta OAMMIRROR, X
        inx
        lda #$20                            ; no flip, palette 0
        sta OAMMIRROR, X
        inx
        ; move the other sprites off screen
        setA16                              ; set A to 16-bit
        lda #$f180                          ; Y = 241, X = -128
OAMLoop:
        sta OAMMIRROR, X
        inx
        inx
        cpx #(OAMMIRROR_SIZE - $20)
        bne OAMLoop
        ; correct bit 9 of horizontal/X position, set size to 8x8
        lda #$5555
OBJLoop:
        sta OAMMIRROR, X
        inx
        inx
        cpx #OAMMIRROR_SIZE
        bne OBJLoop

        setA8
        ; correct extra OAM byte for first four sprites
        ldx #$0200
        lda #$00
        sta OAMMIRROR, X

        ; set initial horizontal and vertical speed
        lda #SPRITE_SPEED
        sta HOR_SPEED
        sta VER_SPEED

        ; make Objects and BG 1 visible
        lda #$11
        sta TM
        ; release forced blanking, set screen to full brightness
        lda #$0f
        sta INIDISP
        ; enable NMI, turn on automatic joypad polling
        lda #$81
        sta NMITIMEN

        rts                     ; all initialization is done
.endproc
;-------------------------------------------------------------------------------
