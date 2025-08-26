################################################################################
# Address: 0x8007332c
################################################################################

################################################################################
# hooking here at the end of every subaction event lets us do a couple things
# more efficiently...
#   1 - instead of creating a bunch of hooks in across various functions, we can
#       modify the data here before it gets used at those locations.
#   2 - we have immediate access to the fighters gobj.
# ie: if the event was create hitbox, we could loop through all of the pending
# hitboxes and modify its data.
#
# reg notes:
# the cmd loop needs r31-27 and f31-30
################################################################################

.include "./StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/SUBACTIONS.s"

# exit early if we dont have a fighter event
  cmpwi r28, 10
  blt ORIGINAL_CODELINE

b CODE_START

CODE_START:
.set REG_FP, 30
.set REG_EVENT, 28
.set REG_FGP, 27
.set REG_RNG, 26
  backup , 2 # backup f31-30
  backup_rng REG_RNG

  cmpwi REG_EVENT, SA_EVENT_HITBOX_SPAWN
  bne EXIT
  logf LOG_LEVEL_ERROR, "HITBOX CREATED"

EXIT:
  restore_rng REG_RNG
  restore , 2
  ORIGINAL_CODELINE:
    lfs	f0, 0(r29)