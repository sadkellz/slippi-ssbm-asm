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
lbz REG_SLOT, FT_SLOT(REG_FP)
load REG_SRPD, stc_sr_plydata

# this players data
mulli r0, REG_SLOT, SRP_SIZE
add REG_FLAGS, REG_SRPD, r0
lwz REG_FLAGS, SRP_CARDS(REG_FLAGS)

rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_GRACE, 31-SR_CARD_GRACE
beq EXIT

branchl r12, AS_SmashTurn
branch r12, 0x800c9d24

EXIT:
  branchl r12, 0x800c9d94
