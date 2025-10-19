.ifndef MEMORY_MAP_WRAM_INC
MEMORY_MAP_WRAM_INC = 1
; -----------------------------------------------------------------------------
;   File: MemoryMapWRAM.inc
;   Description: Symbols representing addresses in WRAM
; -----------------------------------------------------------------------------

;----- Memory Map WRAM ---------------------------------------------------------
DEBUG       = $02e0     ; write to address to trigger breakpoint
HOR_SPEED   = $0300     ; player horizontal speed
VER_SPEED   = $0301     ; player vertical speed
JOYRAW1     = $0302     ; data read from joypad 1
JOYTRIGGER1 = $0304     ; trigger read from joypad 1
JOYHELD1    = $0306     ; held buttons read from joypad 1
PLAYER_X    = $0308     ; player x position
PLAYER_Y    = $030a     ; player y position
H_SCROLL    = $030c     ; current horizontal scroll of backgound
V_SCROLL    = $030e     ; current vertical scroll of background
BG_WIDTH    = $0310     ; current backgound width
BG_HEIGHT   = $0312     ; current background height
OAMMIRROR   = $0400     ; location of OAMRAM mirror in WRAM
TM1MIRROR   = $0620     ; location of tilemap mirror for BG 1 in WRAM
;-------------------------------------------------------------------------------

.endif
