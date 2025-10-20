; -----------------------------------------------------------------------------
;   File: Input.s
;   Description: Subroutines to handle input
; -----------------------------------------------------------------------------

;----- Export ------------------------------------------------------------------
.export     HandleInput
;-------------------------------------------------------------------------------

;----- Assembler Directives ----------------------------------------------------
.p816                           ; tell the assembler this is 65816 code
.a8
.i16
;-------------------------------------------------------------------------------

;----- Includes ----------------------------------------------------------------
.include "Registers.inc"
.include "macros.inc"
.include "GameConstants.inc"
.include "MemoryMapWRAM.inc"
;-------------------------------------------------------------------------------

.segment "CODE"
;-------------------------------------------------------------------------------
;   This subroutines handles all input
;   Parameters: Raw: .addr, Trigger: .addr, Held: .addr
;-------------------------------------------------------------------------------
.proc   HandleInput
        phx                                 ; save old stack pointer
        ; create frame pointer
        phd                                 ; push Direct Register to stack
        tsc                                 ; transfer Stack to... (via Accumulator)
        tcd                                 ; ...Direct Register.
        ; use constants to access arguments on stack with Direct Addressing
        Raw         = $07                   ; address to store raw input data
        Trigger     = $09                   ; address to store triggered buttons
        Held        = $0b                   ; address to store held buttons

        setA16                              ; set A to 16-bit
        ; check the dpad, if any of the directional buttons where pressed or held,
        ; move the sprites accordingly
CheckUpButton:
        lda #$0000                          ; set A to zero
        ora (Trigger)                       ; check whether the up button was pressed this frame...
        ora (Held)                          ; ...or held from last frame
        and #UP_BUTTON
        beq CheckUpButtonDone               ; if neither has occured, move on
        lda PLAYER_Y
        cmp #(SCREEN_BOTTOM/2 - SPRITE_SIZE)
        bcc MoveSpritesUp                   ; If player is near top of BG, move spite
        lda BG_HEIGHT
        sec
        sbc PLAYER_Y
        cmp #(SCREEN_BOTTOM/2 + SPRITE_SIZE + 1)
        bcc MoveSpritesUp                   ; or if player is near bottom of BG
        lda V_SCROLL                        ; else, scroll screen
        sec
        rep #$80
        sbc PLAYER_SPEED
        sta V_SCROLL
        setA8
        sta BG1VOFS
        lda V_SCROLLH
        sta BG1VOFS                         ; BG1VOFS write twice register
        bra UpdatePlayerPosUp
MoveSpritesUp:
        ldx #$0000                          ; X is the loop counter
        ldy #$0001                          ; Y is the offset into the OAM mirror
        setA8                               ; set A to 8-bit
MoveSpritesUpLoop:
        lda OAMMIRROR, Y
        sec
        sbc PLAYER_SPEED
        cmp #SCREEN_TOP
        bcc CorrectVerticalPositionDown     ; if vertical position is below zero, correct it down
        sta OAMMIRROR, Y
        iny                                 ; increment Y by 4
        iny
        iny
        iny
        inx
        cpx #$0004                          ; unless X = 4, continue loop
        bne MoveSpritesUpLoop
        bra UpdatePlayerPosUp
CorrectVerticalPositionDown:
        setA8                               ; set A to 8-bit
        lda #SCREEN_TOP
        sta OAMMIRROR + 1                   ; sprite 1, vertical position
        sta OAMMIRROR + 5                   ; sprite 3, vertical position
        lda #(SCREEN_TOP + SPRITE_SIZE)
        sta OAMMIRROR + 9                   ; sprite 2, vertical position
        sta OAMMIRROR + 13                  ; sprite 4, vertical position
        setA16                              ; set A to 16-bit
UpdatePlayerPosUp:
        setA16
        lda #$0000
        setA8
        clc
        adc SPRITE1_Y
        setA16
        adc V_SCROLL
        sta PLAYER_Y                        ; global player position is always (scroll offset + sprite position)
CheckUpButtonDone:
        setA16                              ; set A to 16-bit

CheckDownButton:
        lda #$0000                          ; set A to zero
        ora (Trigger)                       ; check whether the down button was pressed this frame...
        ora (Held)                          ; ...or held from last frame
        and #DOWN_BUTTON
        beq CheckDownButtonDone             ; if neither has occured, move on
        lda PLAYER_Y
        cmp #(SCREEN_BOTTOM/2 - SPRITE_SIZE)
        bcc MoveSpritesDown
        lda BG_HEIGHT
        sec
        sbc PLAYER_Y
        cmp #(SCREEN_BOTTOM/2 + SPRITE_SIZE + 1)
        bcc MoveSpritesDown
        lda V_SCROLL
        clc
        adc PLAYER_SPEED
        sta V_SCROLL
        setA8
        sta BG1VOFS
        lda V_SCROLLH
        sta BG1VOFS
        bra UpdatePlayerPosDown
MoveSpritesDown:
        ldx #$0000                          ; X is the loop counter
        ldy #$0001                          ; Y is the offset into the OAM mirror
        setA8                               ; set A to 8-bit
        ; check if sprites move below buttom boundry
        lda OAMMIRROR, Y
        clc
        adc PLAYER_SPEED
        cmp #(SCREEN_BOTTOM - 2 * SPRITE_SIZE)
        bcs CorrectVerticalPositionUp
MoveSpritesDownLoop:
        lda OAMMIRROR, Y
        clc
        adc PLAYER_SPEED
        sta OAMMIRROR, Y
        iny                                 ; increment Y by 4
        iny
        iny
        iny
        inx
        cpx #$0004                          ; unless X = 4, continue loop
        bne MoveSpritesDownLoop
        bra UpdatePlayerPosDown
CorrectVerticalPositionUp:
        setA8                               ; set A to 8-bit
        lda #(SCREEN_BOTTOM - 2 * SPRITE_SIZE)
        sta OAMMIRROR + 1                   ; sprite 1, vertical position
        sta OAMMIRROR + 5                   ; sprite 3, vertical position
        lda #(SCREEN_BOTTOM - SPRITE_SIZE)
        sta OAMMIRROR + 9                   ; sprite 2, vertical position
        sta OAMMIRROR + 13                  ; sprite 4, vertical position
        setA16
UpdatePlayerPosDown:
        setA16
        lda #$0000
        setA8
        clc
        adc SPRITE1_Y
        setA16
        adc V_SCROLL
        sta PLAYER_Y
CheckDownButtonDone:
        setA16                              ; set A to 16-bit                      ; set A to 16-bit

CheckLeftButton:
        lda #$0000                          ; set A to zero
        ora (Trigger)                       ; check whether the up button was pressed this frame...
        ora (Held)                          ; ...or held from last frame
        and #LEFT_BUTTON
        beq CheckLeftButtonDone             ; if neither has occured, move on
        lda PLAYER_X
        cmp #(SCREEN_RIGHT/2 - SPRITE_SIZE)
        bcc MoveSpritesLeft
        lda BG_WIDTH
        sec
        sbc PLAYER_X
        cmp #(SCREEN_RIGHT/2 + SPRITE_SIZE + 1)
        bcc MoveSpritesLeft
        lda H_SCROLL
        sec
        rep #$80
        sbc PLAYER_SPEED
        sta H_SCROLL
        setA8
        sta BG1HOFS
        lda H_SCROLLH
        sta BG1HOFS
        bra UpdatePlayerPosLeft
MoveSpritesLeft:
        sta DEBUG
        ldx #$0000
        ldy #$0000
        setA8
MoveSpritesLeftLoop:
        lda OAMMIRROR, Y
        sec
        sbc PLAYER_SPEED
        cmp #SCREEN_LEFT
        bcc CorrectHorizontalPositionRight
        sta OAMMIRROR, Y
        iny                                 ; increment X by 4
        iny
        iny
        iny
        inx
        cpx #$0004                          ; unless Y = 4, continue loop
        bne MoveSpritesLeftLoop
        bra UpdatePlayerPosLeft
CorrectHorizontalPositionRight:
        setA8                               ; set A to 8-bit
        lda #SCREEN_LEFT
        sta OAMMIRROR + 0                   ; sprite 1, horizontal position
        sta OAMMIRROR + 8                   ; sprite 2, horizontal position
        lda #(SCREEN_LEFT + SPRITE_SIZE)
        sta OAMMIRROR + 4                   ; sprite 3, horizontal position
        sta OAMMIRROR + 12                  ; sprite 4, horizontal position
        setA16
UpdatePlayerPosLeft:
        setA16
        lda #$0000
        setA8
        clc
        adc SPRITE1_X
        setA16
        adc H_SCROLL
        sta PLAYER_X
CheckLeftButtonDone:
        setA16                              ; set A to 16-bit

CheckRightButton:
        lda #$0000                          ; set A to zero
        ora (Trigger)                       ; check whether the down button was pressed this frame...
        ora (Held)                          ; ...or held from last frame
        and #RIGHT_BUTTON
        beq CheckRightButtonDone            ; if neither has occured, move on
        lda PLAYER_X
        cmp #(SCREEN_RIGHT/2 - SPRITE_SIZE)
        bcc MoveSpritesRight
        lda BG_WIDTH
        sec
        sbc PLAYER_X
        cmp #(SCREEN_RIGHT/2 + SPRITE_SIZE + 1)
        bcc MoveSpritesRight
        lda H_SCROLL
        clc
        adc PLAYER_SPEED
        sta H_SCROLL
        setA8
        sta BG1HOFS
        lda H_SCROLLH
        sta BG1HOFS
        bra UpdatePlayerPosRight
MoveSpritesRight:
        ldx #$0000                          ; X is the loop counter
        ldy #$0000                          ; Y is the offset into the OAM mirror
        setA8                               ; set A to 8-bit
        ; check whether sprites move beyond right boundry
        lda OAMMIRROR, Y
        clc
        adc PLAYER_SPEED
        cmp #(SCREEN_RIGHT - 2 * SPRITE_SIZE)
        bcs CorrectHorizontalPositionLeft
MoveSpritesRightLoop:
        lda OAMMIRROR, Y
        clc
        adc PLAYER_SPEED
        sta OAMMIRROR, Y
        iny                                 ; increment Y by 4
        iny
        iny
        iny
        inx
        cpx #$0004                          ; unless X = 4, continue loop
        bne MoveSpritesRightLoop
        bra UpdatePlayerPosRight
CorrectHorizontalPositionLeft:
        setA8                               ; set A to 8-bit
        lda #(SCREEN_RIGHT - 2 * SPRITE_SIZE)
        sta OAMMIRROR + 0                   ; sprite 1, horizontal position
        sta OAMMIRROR + 8                   ; sprite 2, horizontal position
        lda #(SCREEN_RIGHT - SPRITE_SIZE)
        sta OAMMIRROR + 4                   ; sprite 3, horizontal position
        sta OAMMIRROR + 12                  ; sprite 4, horizontal position
        setA16
UpdatePlayerPosRight:
        setA16
        lda #$0000
        setA8
        clc
        adc SPRITE1_X
        setA16
        adc H_SCROLL
        sta PLAYER_X
CheckRightButtonDone:
        setA16                              ; set A to 16-bit


InputDone:
        setA8                               ; set A back to 8-bit
        pld                                 ; restore D...
        plx                                 ; ...and X registers

        rts
.endproc
;-------------------------------------------------------------------------------
