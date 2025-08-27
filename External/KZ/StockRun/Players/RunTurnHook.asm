################################################################################
# Address: 0x800c9d20
################################################################################

.include "./StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/PLAYER.s"

.set REG_FGP, 3
.set REG_SLOT, 4
.set REG_FP, 5
.set REG_SRPD, 6
.set REG_FLAGS, 7

# no backup to reduce code size
addi REG_SRPD, REG_FP, FT_SRP_OFST
lwz REG_FLAGS, SRP_CARDS(REG_SRPD)

rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_GRACE, 31-SR_CARD_GRACE
beq EXIT

branchl r12, AS_SmashTurn
branch r12, 0x800c9d24

EXIT:
  branchl r12, 0x800c9d94
