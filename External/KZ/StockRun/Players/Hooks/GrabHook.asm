################################################################################
# Address: 0x80078b2c
################################################################################
# This can't be done in the subaction as the hitbox itself only has a point position


.include "External/KZ/StockRun/StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/PLAYER.s"
.include "External/KZ/OS.s"

CODE_START:
.set REG_HITBOX, 31
.set REG_FP, 30
.set REG_VFP, 29
.set REG_SRPD, 28
.set REG_FLAGS, 27
.set REG_SLOT, 26
# floats
.set FREG_X, 31
  backup
  mr REG_HITBOX, r3
  addi REG_SRPD, REG_FP, FT_SRP_OFST
  lwz REG_FLAGS, SRP_CARDS(REG_SRPD)

  rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_EXTGRAB, 31-SR_CARD_EXTGRAB
  beq EXIT
  
  # get our hitbox x pos
  lfs FREG_X, HITBOX_POS+X(REG_HITBOX)
  lfs f0, FT_FACING_DIR(REG_FP)
  lfs f2, RTOC_0(rtoc)
  lfs f1, RTOC_20(rtoc)
  fcmpo cr0, f2, f0
  blt ADD_OFFSET

  SUB_OFFSET:
    fsubs FREG_X, FREG_X, f1
    b STORE_OFFSET

  ADD_OFFSET:
    fadds FREG_X, FREG_X, f1

  STORE_OFFSET:
    stfs FREG_X, HITBOX_LAST_POS+X(REG_HITBOX)

  # play sound
  # li r3, 0
  # li r4, 94
  # li r5, 90
  # li r6, 64
  # branchl r12, SFX_FighterSFX

EXIT:
  mr r3, REG_HITBOX
  restore
  rlwinm.	r0, r0, 27, 31, 31
