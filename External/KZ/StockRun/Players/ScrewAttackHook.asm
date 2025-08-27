################################################################################
# Address: 0x800d2d1c
################################################################################

.include "./StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/PLAYER.s"
.include "External/KZ/OS.s"

CODE_START:
# vars
.set REG_FP, 31
.set REG_SRPD, 30
.set REG_FLAGS, 29
  backup
  mr REG_FP, r3
  # init
  addi REG_SRPD, REG_FP, FT_SRP_OFST
  lwz REG_FLAGS, SRP_CARDS(REG_SRPD)

  li r3, FALSE
  rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_SCREWATK, 31-SR_CARD_SCREWATK
  beq EXIT
  li r3, TRUE

EXIT:
  restore
  branch r12, 0x800d2d40
