; -----------------------------------------------------------------------------
;   File: Assets.s
;   Description: Creates a segment for all assets and exports symbols to make
;   them accessible to other parts of the project.
; -----------------------------------------------------------------------------

;----- Export ------------------------------------------------------------------
.export     SpriteData
.export     ColorData
.export     BGColor
.export     BGCharData
;-------------------------------------------------------------------------------

;----- Assset Data -------------------------------------------------------------
.segment "SPRITEDATA"
BGColor:    .incbin "GrassColors.pal"
ColorData:  .incbin "SpriteColors.pal"
SpriteData: .incbin "Sprites.vra"
BGCharData: .incbin "GrassTiles.bin"
;-------------------------------------------------------------------------------
