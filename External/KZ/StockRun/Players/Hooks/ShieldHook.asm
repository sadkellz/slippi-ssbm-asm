################################################################################
# Address: 0x80076dfc
################################################################################

.include "External/KZ/StockRun/StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/PLAYER.s"

CODE_START:
# vars
.set REG_FP, 31
.set REG_HITBOX, 30
.set REG_ATKER, 29
.set REG_FLAGS, 28
.set REG_SRPD, 27
  backup
  
  # init
  addi REG_SRPD, REG_FP, FT_SRP_OFST
  lwz REG_FLAGS, SRP_CARDS(REG_SRPD)

  POWERSHIELD_CHECK:
    rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_POWERSHIELD, 31-SR_CARD_POWERSHIELD
    beq EXIT
    restore
    branch r12, 0x80076e5c


EXIT:
  restore
  lbz	r0, 0x221C(r31)