################################################################################
# Address: 0x804a3128
################################################################################
# inputs:
#   r3 - fp
#   r4 - ft cmd state
#------------------------------------------------------------------------------#
# loops through pending hitboxes and inverts the kb
################################################################################

.include "./StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/PLAYER.s"
.include "External/KZ/SUBACTIONS.s"

CODE_START:
.set REG_FP, 31
.set REG_SCRIPT, 30
.set REG_ANGLE, 29
  backup
  mr REG_FP, r3
  lwz REG_SCRIPT, 0x8(r4)

  GET_HB_ANGLE REG_ANGLE, REG_SCRIPT
  # logf LOG_LEVEL_ERROR, "angle: %d"
  # logf LOG_LEVEL_ERROR, ""

  # sakurai angles need more thought...
  cmpwi REG_ANGLE, 361
  beq EXIT
  
  # add 180 and then normalize
    addi REG_ANGLE, REG_ANGLE, 180
    li r4, 360
    divw r5, REG_ANGLE, r4
    mullw r5, r5, r4
    subf REG_ANGLE, r5, REG_ANGLE

    cmpwi REG_ANGLE, 0
    bge SET_HITBOX
    add REG_ANGLE, REG_ANGLE, r4
  SET_HITBOX:
    SET_HB_ANGLE REG_SCRIPT, REG_ANGLE

EXIT:
  restore
  blr