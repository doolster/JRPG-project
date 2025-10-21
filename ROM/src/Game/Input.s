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
        sec
        sbc PLAYER_SPEED
        sta PLAYER_Y
        bmi CorrectPlayerPosUp
        lda V_SCROLL
        sec
        rep #$80
        sbc PLAYER_SPEED
        sta V_SCROLL
        setA8
        sta BG1VOFS
        lda V_SCROLLH
        sta BG1VOFS                         ; BG1VOFS write twice register
        bra CheckUpButtonDone
CorrectPlayerPosUp:
        setA16
        stz PLAYER_Y
CheckUpButtonDone:
        setA16                              ; set A to 16-bit

CheckDownButton:
        lda #$0000                          ; set A to zero
        ora (Trigger)                       ; check whether the down button was pressed this frame...
        ora (Held)                          ; ...or held from last frame
        and #DOWN_BUTTON
        beq CheckDownButtonDone             ; if neither has occured, move on
        lda PLAYER_Y
        clc
        adc PLAYER_SPEED
        sta PLAYER_Y
        adc #(2 * SPRITE_SIZE)
        dec
        cmp BG_HEIGHT                       ; stop moving if at bottom of BG
        bcs CorrectPlayerPosDown
        lda V_SCROLL                        ; else, move with scroll
        clc
        adc PLAYER_SPEED
        sta V_SCROLL
        setA8
        sta BG1VOFS
        lda V_SCROLLH
        sta BG1VOFS
        bra CheckDownButtonDone
CorrectPlayerPosDown:
        setA16          ; Shouldn't be doing anything but breaks if removed
        lda BG_HEIGHT
        sec
        sbc #(2 * SPRITE_SIZE)
        sta PLAYER_Y
CheckDownButtonDone:
        setA16

CheckLeftButton:
        lda #$0000                          ; set A to zero
        ora (Trigger)                       ; check whether the up button was pressed this frame...
        ora (Held)                          ; ...or held from last frame
        and #LEFT_BUTTON
        beq CheckLeftButtonDone             ; if neither has occured, move on
        lda PLAYER_X
        sec
        sbc PLAYER_SPEED
        sta PLAYER_X
        bmi CorrectPlayerPosLeft
        lda H_SCROLL
        sec
        rep #$80
        sbc PLAYER_SPEED
        sta H_SCROLL
        setA8
        sta BG1HOFS
        lda H_SCROLLH
        sta BG1HOFS
        bra CheckLeftButtonDone
CorrectPlayerPosLeft:
        setA16
        stz PLAYER_X
CheckLeftButtonDone:
        setA16                              ; set A to 16-bit

CheckRightButton:
        lda #$0000                          ; set A to zero
        ora (Trigger)                       ; check whether the down button was pressed this frame...
        ora (Held)                          ; ...or held from last frame
        and #RIGHT_BUTTON
        beq CheckRightButtonDone            ; if neither has occured, move on
        lda PLAYER_X
        clc
        adc PLAYER_SPEED
        sta PLAYER_X
        adc #(2 * SPRITE_SIZE)
        dec
        cmp BG_WIDTH
        bcs CorrectPlayerPosRight
        lda H_SCROLL
        clc
        adc PLAYER_SPEED
        sta H_SCROLL
        setA8
        sta BG1HOFS
        lda H_SCROLLH
        sta BG1HOFS
        bra CheckRightButtonDone
CorrectPlayerPosRight:
        setA16
        lda BG_WIDTH
        sec
        sbc #(2 * SPRITE_SIZE)
        sta PLAYER_X
CheckRightButtonDone:
        setA16


InputDone:
        setA8                               ; set A back to 8-bit
        pld                                 ; restore D...
        plx                                 ; ...and X registers

        rts
.endproc
;-------------------------------------------------------------------------------
