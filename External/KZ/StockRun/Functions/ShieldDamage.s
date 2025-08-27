################################################################################
# Address: 0x804a312c
################################################################################
# inputs:
#   r3 - fp
#   r4 - ft cmd state
#------------------------------------------------------------------------------#
# increases shield damage by 10?
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
.set REG_DMG, 29
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

  GET_HB_SHIELD_DAMAGE REG_DMG, REG_DATA
  addi REG_DMG, REG_DMG, 10
  SET_HB_SHIELD_DAMAGE REG_DATA, REG_DMG

  # overwrite script
  stw REG_DATA, 0x8(REG_CMD_STATE) 
  load r3, stc_sr_subaction
  li r0, TRUE
  stw r0, SR_SA_RESTORE(r3)

EXIT:
  restore
  blr