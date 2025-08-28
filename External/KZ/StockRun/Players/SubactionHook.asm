################################################################################
# Address: 0x80073324
################################################################################

################################################################################
# hooking here at the beginning of every subaction event lets us do a couple things
# more efficiently...
#   1 - instead of creating a bunch of hooks in across various functions, we can
#       modify the script data here before it gets processed at all.
#   2 - we have immediate access to the fighters gobj.
# ie: if the event is create hitbox, we can modify the stream before anything
# touches it.
#
# reg notes:
# the cmd loop needs r31-27 and f31-30
################################################################################

.include "./StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/SUBACTIONS.s"

  # original codeline
  mtlr	r12

# exit early if we dont have a fighter event
  cmpwi r28, 10
  blt SKIP_EVENT


CODE_START:
.set REG_FP, 30
.set REG_CMD, 29
.set REG_EVENT, 28
.set REG_FGP, 27
.set REG_RNG, 26
.set REG_SRPD, 25
.set REG_FLAGS, 24
  backup
  backup_rng REG_RNG

# get our cards


  cmpwi REG_EVENT, SA_EVENT_HITBOX_SPAWN
  bne EXIT

  HITBOX_EVENT:
    mr r3, REG_FP
    mr r4, REG_CMD
    branchl r12, StockRunCard_HitboxEvent

EXIT:
  restore_rng REG_RNG, r3
  restore
SKIP_EVENT:
  # unclobber vars
  addi	r3, r27, 0
  addi	r4, r29, 0