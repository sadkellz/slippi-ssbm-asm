################################################################################
# Address: StockRunCard_ItemHitboxEvent
################################################################################
# inputs:
#   r3 - item
#   r4 - cmdstate
#------------------------------------------------------------------------------#
# same as HitboxEventHook.asm, but for item hitboxes
################################################################################
.include "External/KZ/StockRun/StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/PLAYER.s"
.include "External/KZ/SUBACTIONS.s"

b CODE_START
SCRIPT_BLRL:
blrl
.long 0, 0, 0, 0, 0, 0
.set SCRIPT_BACKUP, 24
.long 0

CODE_START:
.set REG_ITEM, 31
.set REG_CMD_STATE, 30
.set REG_TEMP, 29
.set REG_DATA, 28
.set REG_SRPD, 27
.set REG_FLAGS, 26
.set REG_SCRIPT_COPIED, 25

  backup
  mr REG_ITEM, r3
  mr REG_CMD_STATE, r4
  bl SCRIPT_BLRL
  mflr REG_DATA
  
  # player cards
  addi REG_SRPD, REG_ITEM, FT_SRP_OFST
  lwz REG_FLAGS, SRP_CARDS(REG_SRPD)
  li REG_SCRIPT_COPIED, FALSE
  
  # check cards
  # all item angles are sakurai?
  # rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_KBINV, 31-SR_CARD_KBINV
  # bne PROCESS_MODIFICATIONS
  rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_SHIELDDMG, 31-SR_CARD_SHIELDDMG
  beq EXIT
  

PROCESS_MODIFICATIONS:
  # copy script data
  COPY_SCRIPT_DATA REG_DATA, REG_CMD_STATE, 24
  li REG_SCRIPT_COPIED, TRUE
  
  # PROCESS_KB_INVERT:
  #   rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_KBINV, 31-SR_CARD_KBINV
  #   # beq PROCESS_SHIELD_DMG
    
  #   GET_HB_ANGLE REG_TEMP, REG_DATA
  #   mr r5, REG_TEMP
  #   logf LOG_LEVEL_ERROR, "Angle Before: %d"
  #   # skip sakurai angles
  #   cmpwi REG_TEMP, 361
  #   beq PROCESS_SHIELD_DMG
    
  #   # invert angle: (angle + 180) % 360
  #   addi REG_TEMP, REG_TEMP, 180
  #   li r4, 360
  #   divw r5, REG_TEMP, r4
  #   mullw r5, r5, r4
  #   subf REG_TEMP, r5, REG_TEMP
  #   cmpwi REG_TEMP, 0
  #   bge ANGLE_SET
  #   add REG_TEMP, REG_TEMP, r4
  #   ANGLE_SET:
  #     SET_HB_ANGLE REG_DATA, REG_TEMP
  #   mr r5, REG_TEMP
  #   logf LOG_LEVEL_ERROR, "Angle After: %d"
  

  PROCESS_SHIELD_DMG:
    rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_SHIELDDMG, 31-SR_CARD_SHIELDDMG
    beq APPLY_MODIFICATIONS
    
    GET_ITEM_HB_SHIELD_DAMAGE REG_TEMP, REG_DATA
    addi REG_TEMP, REG_TEMP, SR_SHIELD_DMG_AMT
    SET_ITEM_HB_SHIELD_DAMAGE REG_TEMP, REG_DATA
  

APPLY_MODIFICATIONS:
  cmpwi REG_SCRIPT_COPIED, TRUE
  bne EXIT
  
  # overwrite script pointer
  stw REG_DATA, 0x8(REG_CMD_STATE)
  
  # set restore flag
  load r3, stc_sr_sa_item
  li r0, TRUE
  stw r0, SR_SA_RESTORE(r3)

EXIT:
  restore
  blr