################################################################################
# Address: 0x804a3128
################################################################################
# inputs:
#   r3 - fp
#   r4 - cmdstate
#------------------------------------------------------------------------------#
# This will check and apply any hitbox card modifications the player has.
# We copy the original script data into our own, modify it, then replace the
# script pointer in the cmdstate. 
#
# After the event runs, we restore the original script 
# data pointer + 20 bytes. This is because the subaction code streams in
# the data, so we are restoring the pointer to where it would be if the
# original code ran. Making it non-destructive.
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
.set REG_DMG, 29
.set REG_DATA, 28
.set REG_SRPD, 27
.set REG_FLAGS, 26
.set REG_CUSTOM, 25
  backup
  mr REG_FP, r3
  mr REG_CMD_STATE, r4

  bl SCRIPT_BLRL
  mflr REG_DATA

  addi REG_SRPD, REG_FP, FT_SRP_OFST
  lwz REG_FLAGS, SRP_CARDS(REG_SRPD)

  INVERT_KB:
    rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_KBINV, 31-SR_CARD_KBINV
    beq SHIELD_DMG

    # copy script data
    # mr r3, REG_DATA
    # lwz r4, 0x8(REG_CMD_STATE) # script
    # stw r4, SCRIPT_BACKUP(REG_DATA)
    # li r5, 20
    # branchl r12, memcpy
    COPY_SCRIPT_DATA REG_DATA, REG_CMD_STATE, 20
    li REG_CUSTOM, TRUE
    GET_HB_ANGLE REG_ANGLE, REG_DATA

    # sakurai angles need more thought...
    cmpwi REG_ANGLE, 361
    beq SHIELD_DMG
    
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


  SHIELD_DMG:
    rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_SHIELDDMG, 31-SR_CARD_SHIELDDMG
    beq EXIT

    cmpwi REG_CUSTOM, TRUE
    beq SHIELD_DMG_START
    COPY_SCRIPT_DATA REG_DATA, REG_CMD_STATE, 20

    SHIELD_DMG_START:
    GET_HB_SHIELD_DAMAGE REG_DMG, REG_DATA
    addi REG_DMG, REG_DMG, 10
    SET_HB_SHIELD_DAMAGE REG_DATA, REG_DMG

    cmpwi REG_CUSTOM, TRUE
    beq SHIELD_DMG_END
    # overwrite script
    stw REG_DATA, 0x8(REG_CMD_STATE) 
    load r3, stc_sr_subaction
    li r0, TRUE
    stw r0, SR_SA_RESTORE(r3)
    SHIELD_DMG_END:



EXIT:
  restore
  blr