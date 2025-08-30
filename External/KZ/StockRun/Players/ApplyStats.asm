################################################################################
# Address: 0x800d14c8
################################################################################

.include "External/KZ/StockRun/StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/HSD_JOBJ.s"
.include "External/KZ/HSD_ITEM.s"
.include "External/KZ/PLAYER.s"

b CODE_START

CODE_START:
.set REG_SRPD, 31
.set REG_FP, 30
.set REG_FGP, 29
.set REG_CARDS, 28
.set REG_STATS, 27
.set REG_BLOCK, 26
  backup

  addi REG_SRPD, REG_FP, FT_SRP_OFST

  load REG_BLOCK, PLAYERBLOCKS
  lbz r0, FT_SLOT(REG_FP)
  mulli r0, r0, SZ_PBLOCK
  add REG_BLOCK, REG_BLOCK, r0

# copy the cards to the subchar
  lwz r3, 0xB4(REG_BLOCK)
  cmplwi r3, 0
  beq SKIP_SUBCHAR
  lwz r3, GOBJ_USERDATA(r3)
  addi r3, r3, FT_SRP_OFST
  lwz r0, SRP_CARDS(REG_SRPD)
  stw r0, SRP_CARDS(r3)
  SKIP_SUBCHAR:

  addi REG_STATS, REG_FP, FT_STATS
  lwz REG_CARDS, SRP_CARDS(REG_SRPD)

  # check applicable cards
  KB_INCREASE: # Pak-A-Punch
    rlwinm. r0, REG_CARDS, 0, 31-SR_CARD_KBINC, 31-SR_CARD_KBINC
    beq KB_DECREASE
    lfs f1, RTOC_1_25(rtoc)
    stfs f1, BLOCK_OFFENSE_RATIO(REG_BLOCK)

  KB_DECREASE: # Flak Jacket
    rlwinm. r0, REG_CARDS, 0, 31-SR_CARD_KBDEC, 31-SR_CARD_KBDEC
    beq SHIELD_HP
    lfs f1, RTOC_0_8(rtoc)
    stfs f1, BLOCK_DEFENSE_RATIO(REG_BLOCK)

  SHIELD_HP:
    rlwinm. r0, REG_CARDS, 0, 31-SR_CARD_SHIELDHP, 31-SR_CARD_SHIELDHP
    beq EXTRA_JUMP

    # apply shield hp
    lfs f0, RTOC_2(rtoc) # shield * 2
    lfs f1, FT_SHIELD_HP(REG_FP)
    lfs f2, FT_LIGHTSHIELD_HP(REG_FP)
    fmuls f1, f1, f0
    fmuls f2, f2, f0
    stfs f1, FT_SHIELD_HP(REG_FP)
    stfs f2, FT_LIGHTSHIELD_HP(REG_FP)

  EXTRA_JUMP:
    rlwinm. r0, REG_CARDS, 0, 31-SR_CARD_EXTRAJUMP, 31-SR_CARD_EXTRAJUMP
    beq JUMP_HEIGHT
    lwz r4, STATS_JUMPS(REG_STATS)
    addi r4, r4, 1
    stw r4, STATS_JUMPS(REG_STATS)

  JUMP_HEIGHT:
    rlwinm. r0, REG_CARDS, 0, 31-SR_CARD_JUMPHEIGHT, 31-SR_CARD_JUMPHEIGHT
    beq GRACE
    lfs f0, RTOC_1_10(rtoc) # jumpheight * 1.25
    lfs f1, STATS_JUMP_SH_MULT(REG_STATS)
    lfs f2, STATS_JUMP_FH_MULT(REG_STATS)
    lfs f3, STATS_JUMP_DJ_MULT(REG_STATS)
    fmuls f1, f1, f0
    fmuls f2, f2, f0
    fmuls f3, f3, f0
    stfs f1, STATS_JUMP_SH_MULT(REG_STATS)
    stfs f2, STATS_JUMP_FH_MULT(REG_STATS)
    stfs f3, STATS_JUMP_DJ_MULT(REG_STATS)

  GRACE:
    rlwinm. r0, REG_CARDS, 0, 31-SR_CARD_GRACE, 31-SR_CARD_GRACE
    beq EXIT
    lfs f1, RTOC_1(rtoc)
    stfs f1, STATS_LAG_LAND(REG_STATS)
    stfs f1, STATS_LAG_NAIR(REG_STATS)
    stfs f1, STATS_LAG_FAIR(REG_STATS)
    stfs f1, STATS_LAG_BAIR(REG_STATS)
    stfs f1, STATS_LAG_UAIR(REG_STATS)
    stfs f1, STATS_LAG_DAIR(REG_STATS)

EXIT:
  restore
  lwz	r0, 0x004C (sp)