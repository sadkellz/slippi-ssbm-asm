################################################################################
# Address: StockRunCard_HitboxEvent
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
.include "External/KZ/StockRun/StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/PLAYER.s"
.include "External/KZ/HSD_ITEM.s"
.include "External/KZ/SUBACTIONS.s"

b CODE_START
SCRIPT_BLRL:
blrl
.long 0, 0, 0, 0, 0
.set SCRIPT_BACKUP, 20
.long 0

CODE_START:
# vars
.set REG_FP, 31
.set REG_CMD_STATE, 30
.set REG_TEMP, 29
.set REG_DATA, 28
.set REG_SRPD, 27
.set REG_FLAGS, 26
.set REG_SCRIPT_COPIED, 25
# floats
.set FREG_X, 31

  backup
  mr REG_FP, r3
  mr REG_CMD_STATE, r4
  bl SCRIPT_BLRL
  mflr REG_DATA
  
  # player cards
  addi REG_SRPD, REG_FP, FT_SRP_OFST
  lwz REG_FLAGS, SRP_CARDS(REG_SRPD)
  li REG_SCRIPT_COPIED, FALSE
  
  # check cards
  rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_KBINV, 31-SR_CARD_KBINV
  bne PROCESS_MODIFICATIONS
  rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_SHIELDDMG, 31-SR_CARD_SHIELDDMG
  bne PROCESS_MODIFICATIONS
  rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_DARKNESS, 31-SR_CARD_DARKNESS
  bne PROCESS_MODIFICATIONS
  rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_ELECTRIC, 31-SR_CARD_ELECTRIC
  bne PROCESS_MODIFICATIONS
  rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_FIRE, 31-SR_CARD_FIRE
  bne PROCESS_MODIFICATIONS
  rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_ICE, 31-SR_CARD_ICE
  bne PROCESS_MODIFICATIONS
  beq EXIT

PROCESS_MODIFICATIONS:
  # copy script data
  COPY_SCRIPT_DATA REG_DATA, REG_CMD_STATE, 20
  li REG_SCRIPT_COPIED, TRUE
  
  PROCESS_KB_INVERT:
    rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_KBINV, 31-SR_CARD_KBINV
    beq PROCESS_SHIELD_DMG
    
    GET_HB_ANGLE REG_TEMP, REG_DATA
    # skip sakurai angles
    cmpwi REG_TEMP, 361
    beq PROCESS_SHIELD_DMG
    
    # invert angle: (angle + 180) % 360
    addi REG_TEMP, REG_TEMP, 180
    li r4, 360
    divw r5, REG_TEMP, r4
    mullw r5, r5, r4
    subf REG_TEMP, r5, REG_TEMP
    cmpwi REG_TEMP, 0
    bge ANGLE_SET
    add REG_TEMP, REG_TEMP, r4
    ANGLE_SET:
      SET_HB_ANGLE REG_DATA, REG_TEMP

  PROCESS_SHIELD_DMG:
    rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_SHIELDDMG, 31-SR_CARD_SHIELDDMG
    beq PROCESS_ELEMENTS
    
    GET_HB_SHIELD_DAMAGE REG_TEMP, REG_DATA
    addi REG_TEMP, REG_TEMP, SR_SHIELD_DMG_AMT
    SET_HB_SHIELD_DAMAGE REG_DATA, REG_TEMP

  PROCESS_ELEMENTS:
    # get element type
    GET_HB_ELEMENT REG_TEMP, REG_DATA
    cmpwi REG_TEMP, SA_HB_TYPE_NONE
    bne APPLY_MODIFICATIONS # exit if this is a grab

    # random card select only allows for one of these to be active.
    ELEMENT_DARKNESS:
      rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_DARKNESS, 31-SR_CARD_DARKNESS
      beq ELEMENT_ELECTRIC
      li REG_TEMP, SA_HB_TYPE_DARKNESS
      SET_HB_ELEMENT REG_TEMP, REG_DATA
      # darkness doesnt natively do anything,
      b APPLY_MODIFICATIONS

    ELEMENT_ELECTRIC:
      rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_ELECTRIC, 31-SR_CARD_ELECTRIC
      beq ELEMENT_FIRE
      li REG_TEMP, SA_HB_TYPE_ELECTRIC
      SET_HB_ELEMENT REG_TEMP, REG_DATA
      b APPLY_MODIFICATIONS

    ELEMENT_FIRE:
      rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_FIRE, 31-SR_CARD_FIRE
      beq ELEMENT_ICE
      li REG_TEMP, SA_HB_TYPE_FIRE
      SET_HB_ELEMENT REG_TEMP, REG_DATA
      b APPLY_MODIFICATIONS

    ELEMENT_ICE:
      rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_ICE, 31-SR_CARD_ICE
      beq APPLY_MODIFICATIONS
      li REG_TEMP, SA_HB_TYPE_ICE
      SET_HB_ELEMENT REG_TEMP, REG_DATA
      b APPLY_MODIFICATIONS
    

APPLY_MODIFICATIONS:
  cmpwi REG_SCRIPT_COPIED, TRUE
  bne EXIT
  
  # overwrite script pointer
  stw REG_DATA, 0x8(REG_CMD_STATE)
  
  # set restore flag
  load r3, stc_sr_sa_fighter
  li r0, TRUE
  stw r0, SR_SA_RESTORE(r3)

EXIT:
  restore
  blr