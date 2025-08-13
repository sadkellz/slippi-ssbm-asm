.ifndef GX_HEADER

# Functions
	.set HSD_LObjSetupInit, 0x80365f28 # (COBJ* cobj)
	.set GXSetCullMode, 0x8033d350 # (GXCullmode gxcullmode)
	.set GXClearVtxDesc, 0x8033c3c8
	.set GXInvalidateVtxCache, 0x8033c898
	.set GXInvalidateTexAll, 0x8033f270
	.set GXSetVtxDesc, 0x8033c3c8 # (GXAttribute attribute, GXAttributeType type)
	.set GXSetVtxAttrFmt, 0x8033c414 # (GXVtxFmt vtxfmt, GXAttribute attribute, GXComponentContents contents, GXComponentType type, u8 fracBits)
	.set COBJ_GetViewingMtx, 0x803695f0 # (COBJ *cobj, Mtx *out)
	.set GXSetCurrentMtx, 0x80341510 # (GXPosNormMtx type)
	.set GXLoadPosMtxImm, 0x80341494 # (Mtx *mtx, GXPosNormMtx type)
	.set GXSetColor, 0x80058acc # (GXColor *color)
	.set GXSetZMode, 0x80340dc0 # (GXBool compare_enable, GXCompare func, GXBool update_enable)
	.set GXSetLineWidth, 0x8033d240 # (u8 width, int tex_offsets)
	.set GXBegin, 0x8033d0dc # (GXPrimitive type, GXVtxFmt vtxfmt, u16 nverts)
	.set GXSetZCompLoc, 0x80340e38 # (GXBool enable)
	.set GXSetBlendMode, 0x80340c3c # 
	.set GXSetAlphaUpdate, 0x80340d80 # 
	.set GXSetPointSize, 0x80361c60
	.set GXSetColorUpdate, 0x80340d40
	.set GXSetTevOp, 0x8033fdc4

	.set HSD_SetDrawColor, 0x80058acc #(GXColor *color)
	.set HSD_StateInitTev, 0x803624d8 # 
	.set HSD_SetRenderColors, 0x80008da4 # 
	.set HSD_ClearVtxDesc, 0x8036c244 # 
	.set HSD_DrawQuad, 0x80009dd4 # (Vec *corner1,Vec *corner2,GXColor *color)
	.set HSD_DrawRectangle, 0x80391580 # (double x,double y,double width,double height,GXColor *color)
	.set HSD_StateInvalidate, 0x80361fc4 # (HSD_StateMask state)
	.set HSD_SetEraseColor, 0x80374a88 # (r, g, b, a)
	.set HSD_CObjEraseScreen, 0x803676f8 # (cobj, enable_clr, enable_alpha, enable_depth)
	.set HSD_Setup2DDrawing, 0x80391a04 # (float scale_x,float scale_y,byte line_width)
	.set CollisionLink_Draw, 0x80059e60	

# GX FIFO Pipe
.set STC_GXPIPE, 0xCC008000

################################################################################
# structs

# GX Pipe Struct
# Its one big union
	.set GXPIPE_U8, 0
	.set GXPIPE_S8, GXPIPE_U8 + 1
	.set GXPIPE_U16, 0
	.set GXPIPE_S16, GXPIPE_U16 + 2
	.set GXPIPE_U32, 0
	.set GXPIPE_S32, GXPIPE_U32 + 4
	.set GXPIPE_F32, 0

# GX_VERTEX_ATTRIBUTE
	.set GX_VA_PTNMTXID, 0
	.set GX_VA_TEX0MTXID, 1
	.set GX_VA_TEX1MTXID, 2
	.set GX_VA_TEX2MTXID, 3
	.set GX_VA_TEX3MTXID, 4
	.set GX_VA_TEX4MTXID, 5
	.set GX_VA_TEX5MTXID, 6
	.set GX_VA_TEX6MTXID, 7
	.set GX_VA_TEX7MTXID, 8
	.set GX_VA_POS, 9
	.set GX_VA_NRM, 10
	.set GX_VA_CLR0, 11
	.set GX_VA_CLR1, 12
	.set GX_VA_TEX0, 13
	.set GX_VA_TEX1, 14
	.set GX_VA_TEX2, 15
	.set GX_VA_TEX3, 16
	.set GX_VA_TEX4, 17
	.set GX_VA_TEX5, 18
	.set GX_VA_TEX6, 19
	.set GX_VA_TEX7, 20
	.set GX_POSMTXARRAY, 21
	.set GX_NRMMTXARRAY, 22
	.set GX_TEXMTXARRAY, 23
	.set GX_LIGHTARRAY, 24
	.set GX_VA_NBT, 25
	.set GX_VA_MAXATTR, 26
	.set GX_VA_NULL, 255

# GX_ATTRIBUTE_INPUT
	.set GX_NONE, 0
	.set GX_DIRECT, 1
	.set GX_INDEX8, 2
	.set GX_INDEX16, 3

# GX_PRIM, TYPE
  .set GX_QUADS, 128
  .set GX_TRIANGLES, 144
  .set GX_TRIANGLESTRIP, 152
  .set GX_TRIANGLEFAN, 160
  .set GX_LINES, 168
  .set GX_LINESTRIP, 176
  .set GX_POINTS, 184

# GX_BOOL
	.set GX_DISABLE, 0
	.set GX_ENABLE, 1

# GX_COMPARE
	.set GX_CMP_NEVER, 0
	.set GX_CMP_LESS, 1
	.set GX_CMP_EQUAL, 2
	.set GX_CMP_LEQUAL, 3
	.set GX_CMP_GREATER, 4
	.set GX_CMP_NEQUAL, 5
	.set GX_CMP_GEQUAL, 6
	.set GX_CMP_ALWAYS, 7

# GX_VTXFMT
	.set GX_VTXFMT0, 0
	.set GX_VTXFMT1, 1
	.set GX_VTXFMT2, 2
	.set GX_VTXFMT3, 3
	.set GX_VTXFMT4, 4
	.set GX_VTXFMT5, 5
	.set GX_VTXFMT6, 6
	.set GX_VTXFMT7, 7

################################################################################
# macros

.macro GXPosition3f32 x, y, z, REG_GXPIPE
	stfs \x, GXPIPE_F32(\REG_GXPIPE)
	stfs \y, GXPIPE_F32(\REG_GXPIPE)
	stfs \z, GXPIPE_F32(\REG_GXPIPE)
.endm

.endif
.set GX_HEADER, 1


  # NEARPLANE_BLRL:
  # blrl
  # .set BOT_L, 0
  #   .float -1
  #   .float -1
  #   .float -1
  #   .float 1
  # .set BOT_R, BOT_L + 16
  #   .float 1
  #   .float -1
  #   .float -1
  #   .float 1
  # .set TOP_L, BOT_R + 16
  #   .float -1
  #   .float 1
  #   .float -1
  #   .float 1
  # .set TOP_R, TOP_L + 16
  #   .float 1
  #   .float 1
  #   .float -1
  #   .float 1
	