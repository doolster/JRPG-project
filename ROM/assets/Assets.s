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
.export     BGTileMap
;-------------------------------------------------------------------------------

;----- Assset Data -------------------------------------------------------------
.segment "SPRITEDATA"
BGColor:    .incbin "grassbg.pal"
ColorData:  .incbin "SpriteColors.pal"
SpriteData: .incbin "Sprites.vra"
BGCharData: .incbin "grassbgTileset.bin"
BGTileMap:  .incbin "grassbgTilemap.bin"
;-------------------------------------------------------------------------------
