################################################################################
# Address: 0x80279ac8
################################################################################

################################################################################
# Copy of SubactionHook.asm
################################################################################

.include "External/KZ/StockRun/StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/SUBACTIONS.s"

  # original codeline
  mtlr	r12

# exit early if we dont have a fighter event
  cmpwi r28, 10
  blt SKIP_EVENT


CODE_START:
.set REG_ITEM, 30
.set REG_CMD, 29
.set REG_EVENT, 28
.set REG_IGP, 27
.set REG_RNG, 26
.set REG_SRPD, 25
  backup
  backup_rng REG_RNG

  cmpwi REG_EVENT, SA_EVENT_HITBOX_SPAWN
  bne EXIT

  HITBOX_EVENT:
    mr r3, REG_ITEM
    mr r4, REG_CMD
    branchl r12, StockRunCard_ItemHitboxEvent

EXIT:
  restore_rng REG_RNG, r3
  restore
SKIP_EVENT:
  # unclobber vars
  addi	r3, r27, 0
  addi	r4, r29, 0