################################################################################
# Address: 0x8008da20
# Runs immediately after the game applies knockback but before its processed
################################################################################


.include "./StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/PLAYER.s"

b CODE_START

CODE_START:
# vars
.set REG_DATA, 31
.set REG_SLOT, 30
.set REG_SRPD, 29
.set REG_FLAGS, 28
# floats
.set FREG_KB, 31
  backup
  # init
  lbz REG_SLOT, FT_SLOT(REG_DATA)
  lfs FREG_KB, FT_HIT_KB(REG_DATA)
  load REG_SRPD, stc_sr_plydata

  # this players data
  mulli r0, REG_SLOT, SRP_SIZE
  add REG_SRPD, REG_SRPD, r0
  lwz REG_FLAGS, SRP_CARDS(REG_SRPD)
  li r0, SR_CARD_KBDEC | SR_CARD_KBINC
  and. r0, r0, REG_FLAGS
  beq EXIT # we dont have either flag set

  DECREASE_KB:
    li r0, SR_CARD_KBDEC
    and. r0, r0, REG_FLAGS
    beq INCREASE_KB
    logf LOG_LEVEL_ERROR, "Decrease KB"

  INCREASE_KB:
    li r0, SR_CARD_KBINC
    and. r0, r0, REG_FLAGS
    beq EXIT
    logf LOG_LEVEL_ERROR, "Increase KB"

EXIT:
  restore
  lwz	r3, -0x514C (r13)