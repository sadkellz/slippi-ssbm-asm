################################################################################
# Address: 0x8008e7a8
################################################################################

.include "External/KZ/StockRun/StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/PLAYER.s"

CODE_START:
.set REG_FP, 31

  addi r3, REG_FP, FT_SRP_OFST
  lwz r0, SRP_CARDS(r3)
  rlwinm. r0, r0, 0, 31-SR_CARD_AWDI, 31-SR_CARD_AWDI
  beq EXIT

  lfs f2, RTOC_9(rtoc)

EXIT:
  fmuls	f1, f1, f2
  fmuls	f2, f0, f2

