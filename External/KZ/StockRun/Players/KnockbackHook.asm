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
.set REG_FP, 31
.set REG_SLOT, 30
.set REG_SRPD, 29
.set REG_FLAGS, 28
# floats
.set FREG_KB, 31
  backup
  # init
  lbz REG_SLOT, FT_SLOT(REG_FP)
  lfs FREG_KB, FT_HIT_KB(REG_FP)
  load REG_SRPD, stc_sr_plydata

  # this players data
  mulli r0, REG_SLOT, SRP_SIZE
  add r3, REG_SRPD, r0
  lwz REG_FLAGS, SRP_CARDS(r3)
  # li r0, SR_CARD_KBDEC | SR_CARD_KBINC
  # and. r0, r0, REG_FLAGS
  # beq EXIT # we dont have either flag set

  DECREASE_KB_CHECK:
    rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_KBDEC, 31-SR_CARD_KBDEC
    beq INCREASE_KB_CHECK
    # logf LOG_LEVEL_ERROR, "Decrease KB"
    lfs f1, FT_HIT_KB(REG_FP)
    lfs f0, RTOC_0_5(rtoc)
    fmuls f1, f1, f0
    stfs f1, FT_HIT_KB(REG_FP)

  INCREASE_KB_CHECK:
    # check if the attacker has the inc flag
    lwz r3, FT_ATTACKER(REG_FP)
    mulli r0, r3, SRP_SIZE
    add r3, REG_SRPD, r0
    lwz r3, SRP_CARDS(r3)  # load bitfield
    rlwinm. r0, r3, 0, 31-SR_CARD_KBINC, 31-SR_CARD_KBINC
    beq DJ_ARMOUR_CHECK                      # branch if bit is NOT set
    # logf LOG_LEVEL_ERROR, "Increase KB"
    lfs f1, FT_HIT_KB(REG_FP)
    lfs f0, RTOC_1_5(rtoc)
    fmuls f1, f1, f0
    stfs f1, FT_HIT_KB(REG_FP)

  DJ_ARMOUR_CHECK:
    # check if we are even djing
    lwz r0, FT_ACTION_STATE(REG_FP)
    cmpwi r0, AS_JUMP_AERIALF
    beq DJ_CARD_CHECK
    cmpwi r0, AS_JUMP_AERIALB
    bne EXIT

    DJ_CARD_CHECK:
      rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_DJARMOUR, 31-SR_CARD_DJARMOUR
      beq EXIT
      # melee dj armour has already been applied by this point, so if it was and we will subtract the difference
      lfs f0, RTOC_120(rtoc)
      lfs f1, FT_KB_SUBACTION_RESIST(REG_FP)
      fsubs f0, f0, f1
      lfs f1, FT_HIT_KB(REG_FP)
      fsubs f1, f1, f0
      stfs f1, FT_HIT_KB(REG_FP)
      # logf LOG_LEVEL_ERROR, "Dj armour amt: %f"


EXIT:
  restore
  lwz	r3, -0x514C (r13)