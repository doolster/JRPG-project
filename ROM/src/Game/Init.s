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

        ; load sprite characters into VRAM
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
        lda #(BG1_TILEMAP>>8 + 1)       ; shifting to get correct format for register
        sta BG1SC                       ; set address for BG 1 tilemap in VRAM
        lda #BG1_CHARS>>12              ; shifting to get correct format for register
        sta BG12NBA                     ; set address for BG 1 characters in VRAM

        ; load BG 1 characters into VRAM
        tsx
        pea BG1_CHARS
        pea BGCharData
        ldy #$00c0                      ; number of bytes to transfer (6 8x8 4BPP characters)
        phy
        jsr LoadVRAM
        txs

        setA16                          ; store the current BG height and width
        lda #$0118
        sta BG_WIDTH
        lda #$01f0
        sta BG_HEIGHT
        setA8

        setA16                          ; initialize tilemap mirror fro starting screen
        ldy #$0000
LoadRow:
        lda BG_WIDTH
        lsr2
        setA8
        sta M7A
        stz M7A         ; Note this only works for backgounds with width < #$0400
        sty M7B                         ; multiply row # by byte width of background
        setA16
        lda MPYL
        clc
        adc #BGTileMap
        tax                             ; starting address (#BGTileMap + (BG_WIDTH/4 * Y))

        phy
        tya
        asl6
        clc
        adc #TM1MIRROR
        tay                             ; destination address (#TM1MIRROR + (64 * Y))

        lda #$003f                      ; # of bytes to transfer minus 1 (32 tiles * 2 bytes)

        mvn #$00, #$00                  ; move one row from BGTileMap to TM1MIRROR (bank 00 to bank 00)

        ply
        iny
        cpy #$1d
        bcc LoadRow
        setA8

        ; copy tilemap mirror into VRAM
        tsx
        pea BG1_TILEMAP
        pea TM1MIRROR
        ldy #$0700                      ; # of bytes to transfer (1 screen of 32x28 total tiles)
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
        ldx #SPRITE_SPEED
        stx PLAYER_SPEED

        ; set initial BG scroll offset
        ldx #$0000
        stx H_SCROLL
        stx V_SCROLL

        ; set initial player position
        ldx #(SCREEN_BOTTOM/2 - SPRITE_SIZE)
        stx PLAYER_Y
        ldx #(SCREEN_RIGHT/2 - SPRITE_SIZE)
        stx PLAYER_X

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
