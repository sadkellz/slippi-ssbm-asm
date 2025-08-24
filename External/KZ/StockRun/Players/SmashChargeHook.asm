################################################################################
# Address: 0x800defa0
################################################################################

.include "./StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/PLAYER.s"

CODE_START:
.set REG_SMASH, 31
.set REG_FP, 30
.set REG_SLOT, 29
.set REG_SRPD, 28
.set REG_FLAGS, 27
  backup

  # init
  lbz REG_SLOT, FT_SLOT(REG_FP)
  load REG_SRPD, stc_sr_plydata

  # this players data
  mulli r0, REG_SLOT, SRP_SIZE
  add r3, REG_SRPD, r0
  lwz REG_FLAGS, SRP_CARDS(r3)

  rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_QUICKCHARGE, 31-SR_CARD_QUICKCHARGE
  beq EXIT

  # set current charge to max charge
  lfs f0, 0x8(REG_SMASH)
  stfs f0, 0x4(REG_SMASH)

EXIT:
  lwz r3, 0(REG_FP)
  restore
  lfs	f1, 0x0004(r31)
