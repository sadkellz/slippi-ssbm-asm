################################################################################
# Address: 0x802ff204
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

b CODE_START

.set REG_GOBJ, 31
.set REG_COBJ, 30
.set REG_DATA, 29
.set REG_CAMGOBJ, 28

.set FREG_LEFT, 31
.set FREG_RIGHT, 30
.set FREG_TOP, 29
.set FREG_BOTTOM, 28
.set FREG_W, 27
.set FREG_H, 26

.set GXPRIO, 8
.set GXLINK, 31
.set PLINK_PRIO, 0


CODE_START:
  backup

# CREATE_GOBJ:
# # render gobj
  gobj_create GOBJ_CLASS_UI, GOBJ_PLINK_UI, 1, REG_GOBJ

  mr r3, REG_GOBJ
  bl FN_CustomGX
  mflr r4
  li r5, GXLINK
  li r6, GXPRIO
  branchl r12, GObj_SetupGXLink


  b EXIT


################################################################################
################################################################################

FN_CustomGX:
blrl

.set REG_GOBJ, 31
.set REG_COBJ, 30
.set REG_DATA, 29
.set REG_COUNT, 28
.set REG_HTBOX, 27
.set REG_GXPIPE, 26
.set REG_CMSUB, 25
.set REG_PLINKS, 24
.set REG_PLAYER, 23
.set REG_FT, 22
.set REG_OS, 21

.set FREG_LEFT, 31
.set FREG_RIGHT, 30
.set FREG_TOP, 29
.set FREG_BOTTOM, 28

.set FREG_X, 20
.set FREG_Y, 21
.set FREG_X2, 22
.set FREG_Y2, 23
.set FREG_Z, 24
.set FREG_Z2, 25

.set LINE_WIDTH, 8
.set POINT_WIDTH, 32

.set SP_COLOR, BKP_FREE_SPACE_OFFSET

FN_CustomGX_Body:
  backup

  mr REG_GOBJ, r3

# GX Setup
  load REG_GXPIPE, STC_GXPIPE

  branchl r12, HSD_CObjGetCurrent
  mr REG_COBJ, r3

  # mr r3, REG_COBJ
  # branchl r12, HSD_LObjSetupInit

  # li r3, 0
  # branchl r12, GXSetCullMode
  # branchl r12, GXClearVtxDesc

  # li r3, GX_VA_POS
  # li r4, GX_DIRECT
  # branchl r12, GXSetVtxDesc

  # li r3, GX_VTXFMT0
  # li r4, GX_VA_POS
  # li r5, 1
  # li r6, 4
  # li r7, 0
  # branchl r12, GXSetVtxAttrFmt

  # mr r3, REG_COBJ
  # addi r4, sp, SP_MTX
  # branchl r12, HSD_CObjGetViewingMtx

  # li r3, 0
  # branchl r12, GXSetCurrentMtx

  # addi r3, sp, SP_MTX
  # li r4, 0
  # branchl r12, GXLoadPosMtxImm

####################### PLAYER POINTS
  # load r3, 0xFF00007F
  # stw r3, SP_COLOR(sp)

  # addi r3, sp, SP_COLOR
  # branchl r12, HSD_SetDrawColor

  # li r3, 1
  # li r4, 3
  # li r5, 0
  # branchl r12, GXSetZMode

  # li r3, 8
  # li r4, 0
  # branchl r12, GXSetPointSize

  loadwz REG_PLINKS, STC_PLINKLIST
  lwz REG_PLAYER, GOBJ_PLINKLIST_PLAYERS(REG_PLINKS)
  cmpwi REG_PLAYER, 0
  beq FN_CustomGX_Exit

  PLAYER_LOOP:
    lwz REG_FT, GOBJ_USERDATA(REG_PLAYER)
    mr r3, REG_PLAYER
    branchl r12, Player_IsDead
    cmpwi r3, 1
    beq PLAYER_LOOP_CHECK

    lbz REG_COUNT, FT_HURTBOXCOUNT(REG_FT)
    addi REG_HTBOX, REG_FT, FT_HURTBOXES
    DRAW_HITBOX_LOOP:

      mr r3, REG_HTBOX
      li r4, 2
      li r5, 0
      lfs f1, RTOC_0(rtoc)
      branchl r12, 0x8000a244

    HITBOX_LOOP_INC:
      addi REG_HTBOX, REG_HTBOX, SZ_HURTBOX
      subi REG_COUNT, REG_COUNT, 1
      cmpwi REG_COUNT, 0
      bgt DRAW_HITBOX_LOOP

  PLAYER_LOOP_CHECK:
    lwz REG_PLAYER, GOBJ_NEXT(REG_PLAYER)
    cmpwi REG_PLAYER, 0
    bne PLAYER_LOOP

  load r3, -1
  branchl r12, HSD_StateInvalidate


FN_CustomGX_Exit:
  restore
  blr

################################################################################


EXIT:
  restore
  branchl r12, 0x802fefac

