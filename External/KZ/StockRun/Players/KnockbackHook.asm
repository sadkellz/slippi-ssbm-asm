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
  bp
  # init
  lbz REG_SLOT, FT_SLOT(REG_DATA)
  lfs FREG_KB, FT_HIT_KB(REG_DATA)
  load REG_SRPD, stc_sr_plydata

  # this players data
  mulli r0, REG_SLOT, SRP_SIZE
  add r3, REG_SRPD, r0
  lwz REG_FLAGS, SRP_CARDS(r3)
  # li r0, SR_CARD_KBDEC | SR_CARD_KBINC
  # and. r0, r0, REG_FLAGS
  # beq EXIT # we dont have either flag set

  DECREASE_KB_CHECK:
    li r0, SR_CARD_KBDEC
    and. r0, r0, REG_FLAGS
    beq INCREASE_KB_CHECK
    # logf LOG_LEVEL_ERROR, "Decrease KB"
    lfs f1, FT_HIT_KB(REG_DATA)
    lfs f0, RTOC_0_5(rtoc)
    fmuls f1, f1, f0
    stfs f1, FT_HIT_KB(REG_DATA)

    

  INCREASE_KB_CHECK:
    # check if the attacker has the inc flag
    lwz r3, FT_ATTACKER(REG_DATA)
    mulli r0, r3, SRP_SIZE
    add r3, REG_SRPD, r0
    lwz REG_FLAGS, SRP_CARDS(r3)
    li r0, SR_CARD_KBINC
    and. r0, r0, REG_FLAGS
    beq EXIT
    # logf LOG_LEVEL_ERROR, "Increase KB"
    lfs f1, FT_HIT_KB(REG_DATA)
    lfs f0, RTOC_1_5(rtoc)
    fmuls f1, f1, f0
    stfs f1, FT_HIT_KB(REG_DATA)

EXIT:
  restore
  lwz	r3, -0x514C (r13)