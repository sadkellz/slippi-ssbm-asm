################################################################################
# Address: 0x8017a09c
################################################################################

.include "Common/Common.s"
.include "KZ/HSD_GOBJ.s"
.include "KZ/HSD_COBJ.s"
.include "KZ/HSD_JOBJ.s"
.include "KZ/HSD_PAD.s"
.include "KZ/PLAYER.s"
.include "KZ/MATH.s"
.include "KZ/GX.s"
.include "KZ/StageHeader.s"
.include "KZ/KZ_COMMON.s"

.set REG_GOBJ, 20

.set GXLINK, 7
.set GXPRIO, 6

b CODE_START

CODE_START:
  backup

  gobj_create GOBJ_CLASS_UI, GOBJ_PLINK_UI, 1, REG_GOBJ

  mr r3, REG_GOBJ
  bl FN_CustomGX
  mflr r4
  li r5, GXLINK
  li r6, GXPRIO
  branchl r12, GObj_SetupGXLink


  b EXIT


FN_CustomGX:
blrl

.set REG_GOBJ, 31
.set REG_COBJ, 30
.set REG_DATA, 29
.set REG_MTX, 28
.set REG_GXPIPE, 26


.set FREG_X, 20
.set FREG_Y, 21
.set FREG_Z, 24

.set LINE_WIDTH, 8
.set POINT_WIDTH, 32

.set SP_MTX, BKP_FREE_SPACE_OFFSET
.set SP_COLOR, SP_MTX + 44

FN_CustomGX_Body:
  # backup
  bp
#   b FN_CustomGX_Exit

#   mr REG_GOBJ, r3
#   # lwz REG_COBJ, GOBJ_OBJ(REG_GOBJ)

# # GX Setup
#   load REG_GXPIPE, STC_GXPIPE

#   branchl r12, HSD_CObjGetCurrent
#   mr REG_COBJ, r3

#   mr r3, REG_COBJ
#   branchl r12, HSD_LObjSetupInit

#   li r3, 0
#   branchl r12, GXSetCullMode
#   branchl r12, GXClearVtxDesc

#   li r3, GX_VA_POS
#   li r4, GX_DIRECT
#   branchl r12, GXSetVtxDesc

#   li r3, GX_VTXFMT0
#   li r4, GX_VA_POS
#   li r5, 1
#   li r6, 4
#   li r7, 0
#   branchl r12, GXSetVtxAttrFmt

#   mr r3, REG_COBJ
#   addi r4, sp, SP_MTX
#   branchl r12, HSD_CObjGetViewingMtx

#   li r3, 0
#   branchl r12, GXSetCurrentMtx

#   addi r3, sp, SP_MTX
#   li r4, 0
#   branchl r12, GXLoadPosMtxImm

#   load r3, 0xFFFFFFFF
#   stw r3, SP_COLOR(sp)

#   addi r3, sp, SP_COLOR
#   branchl r12, HSD_SetDrawColor

#   load r3, 0x43c80000
#   stw r3, SP_MTX(sp)

#   li r3, 1
#   li r4, 3
#   li r5, 0
#   branchl r12, GXSetZMode

#   li r3, LINE_WIDTH
#   li r4, 0
#   branchl r12, GXSetLineWidth

#   lfs FREG_X, RTOC_0(rtoc)
#   lfs FREG_Y, SP_MTX(sp)
#   fmr FREG_Z, FREG_X

#   li r3, GX_POINTS
#   li r4, GX_VTXFMT0
#   li r5, 1
#   branchl r12, GXBegin

  

#   GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE


#   load r3, -1
#   branchl r12, HSD_StateInvalidate

  FN_CustomGX_Exit:
  # restore
  blr

EXIT:
  restore
  # mr	r3, r31
  li	r3, 19