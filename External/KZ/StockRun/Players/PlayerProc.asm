################################################################################
# Address: 0x800691b0
# creates a fighter proc before any other procs spawn
################################################################################

.include "./StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/PLAYER.s"

b CODE_START

# Init
#==============================================================================#
CODE_START:
.set REG_GOBJ, 31
  backup

  mr r3, REG_GOBJ
  bl FN_FighterThinkBLRL
  mflr r4
  li r5, 0
  branchl r12, GObj_AddProc

  # mr r5, REG_GOBJ
  # logf LOG_LEVEL_ERROR, "Fighter GOBJ: %08x\n"

  b EXIT

#==============================================================================#



#------------------------------------------------------------------------------#
FN_FighterThinkBLRL:
blrl
.set REG_GOBJ, 31
.set REG_DATA, 30
.set REG_SRPD, 29
.set REG_CARDS, 28
.set REG_STATS, 27
FN_FighterThink:
  backup

  # init vars
  mr REG_GOBJ, r3
  lwz REG_DATA, GOBJ_USERDATA(REG_GOBJ)

  # check if we should apply a card
  lbz r0, FT_SLOT(REG_DATA)
  mulli r0, r0, SRP_SIZE
  load REG_SRPD, stc_sr_plydata
  add REG_SRPD, REG_SRPD, r0
  lwz r3, SRP_APPLY_CARD(REG_SRPD)
  cmpwi r3, FALSE
  beq FN_FighterThink_Exit

  addi REG_STATS, REG_DATA, FT_STATS

  # check applicable cards
  SHIELD_HP:
    lwz REG_CARDS, SRP_CARDS(REG_SRPD)
    rlwinm. r0, REG_CARDS, 0, 31-SR_CARD_SHIELDHP, 31-SR_CARD_SHIELDHP
    beq EXTRA_JUMP

    # apply shield hp
    lfs f0, RTOC_2(rtoc) # shield * 2
    lfs f1, FT_SHIELD_HP(REG_DATA)
    lfs f2, FT_LIGHTSHIELD_HP(REG_DATA)
    fmuls f1, f1, f0
    fmuls f2, f2, f0
    stfs f1, FT_SHIELD_HP(REG_DATA)
    stfs f2, FT_LIGHTSHIELD_HP(REG_DATA)

  EXTRA_JUMP:
    rlwinm. r0, REG_CARDS, 0, 31-SR_CARD_EXTRAJUMP, 31-SR_CARD_EXTRAJUMP
    beq JUMP_HEIGHT
    lwz r4, STATS_JUMPS(REG_STATS)
    addi r4, r4, 1
    stw r4, STATS_JUMPS(REG_STATS)

  JUMP_HEIGHT:
    rlwinm. r0, REG_CARDS, 0, 31-SR_CARD_JUMPHEIGHT, 31-SR_CARD_JUMPHEIGHT
    beq FN_FighterThink_Exit
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



FN_FighterThink_Exit:
  li r3, 0
  stw r3, SRP_APPLY_CARD(REG_SRPD)
  restore
  blr

#------------------------------------------------------------------------------#


EXIT:
  restore
  lis	r3, 0x8007
