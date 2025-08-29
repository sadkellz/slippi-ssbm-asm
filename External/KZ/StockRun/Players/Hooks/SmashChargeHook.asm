################################################################################
# Address: 0x800defa0
################################################################################

.include "External/KZ/StockRun/StockRun.s"
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
  addi REG_SRPD, REG_FP, FT_SRP_OFST
  lwz REG_FLAGS, SRP_CARDS(REG_SRPD)

  rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_QUICKCHARGE, 31-SR_CARD_QUICKCHARGE
  beq EXIT

  # set current charge to max charge
  lfs f0, 0x8(REG_SMASH)
  stfs f0, 0x4(REG_SMASH)

EXIT:
  lwz r3, 0(REG_FP)
  restore
  lfs	f1, 0x0004(r31)
