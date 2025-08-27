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

b CODE_START

SCRIPT_BLRL:
blrl
.long 0
.long 0
.long 0
.long 0
.long 0
.set SCRIPT_BACKUP, 20
.long 0

CODE_START:
.set REG_FP, 31
.set REG_CMD_STATE, 30
.set REG_ANGLE, 29
.set REG_DATA, 28
  backup
  mr REG_FP, r3
  mr REG_CMD_STATE, r4
  bl SCRIPT_BLRL
  mflr REG_DATA

  # copy script data
  mr r3, REG_DATA
  lwz r4, 0x8(REG_CMD_STATE) # script
  stw r4, SCRIPT_BACKUP(REG_DATA)
  li r5, 20
  branchl r12, memcpy

  GET_HB_ANGLE REG_ANGLE, REG_DATA
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
    SET_HB_ANGLE REG_DATA, REG_ANGLE

  # overwrite script
  stw REG_DATA, 0x8(REG_CMD_STATE) 
  load r3, stc_sr_subaction
  li r0, TRUE
  stw r0, SR_SA_RESTORE(r3)

EXIT:
  restore
  blr