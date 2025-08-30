################################################################################
# Address: 0x8007bbe4
################################################################################

.include "External/KZ/StockRun/StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/PLAYER.s"

CODE_START:
.set REG_FGP, 31
.set REG_SRPD, 4

  lwz r3, GOBJ_USERDATA(REG_FGP)
  addi REG_SRPD, r3, FT_SRP_OFST
  lwz r3, SRP_OPP_FP(REG_SRPD)
  addi REG_SRPD, r3, FT_SRP_OFST
  lwz r3, SRP_CARDS(REG_SRPD)

  rlwinm. r3, r3, 0, 31-SR_CARD_FIRE, 31-SR_CARD_FIRE
  # bne EXIT
  # lfs	f1, RTOC_0(rtoc)
  # branch r12, 0x8007bc74

EXIT:
  lwz	r0, -0x5148 (r13) # original codeline

