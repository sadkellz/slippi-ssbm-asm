################################################################################
# Address: 0x800cba9c
################################################################################

.include "External/KZ/StockRun/StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/PLAYER.s"

CODE_START:
.set REG_FP, 30
  # backup

  DJ_CARD_CHECK:
    addi r3, REG_FP, FT_SRP_OFST
    lwz r3, SRP_CARDS(r3)
    rlwinm. r0, r3, 0, 31-SR_CARD_DJARMOUR, 31-SR_CARD_DJARMOUR
    beq EXIT
    # set the kb_subaction_reduction
    lfs f0, RTOC_120(rtoc)
    stfs f0, FT_KB_SUBACTION_RESIST(REG_FP)

EXIT:
  # restore
  li	r3, 1