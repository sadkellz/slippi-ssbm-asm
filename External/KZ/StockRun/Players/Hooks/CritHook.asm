################################################################################
# Address: 0x80076f54
################################################################################

.include "External/KZ/StockRun/StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/PLAYER.s"


CODE_START:
.set REG_FP, 28
.set REG_HITBOX, 27
.set REG_ATKER, 26
.set REG_SRPD, 20
.set REG_FLAGS, 21
.set REG_RNG, 22
.set REG_CRIT_CHANCE, 23
# floats
.set FREG_DMG_MULT, 20
  backup
  backup_rng REG_RNG

  lfs	FREG_DMG_MULT, 0x182C(REG_FP)
  addi REG_SRPD, REG_FP, FT_SRP_OFST
  li REG_CRIT_CHANCE, SR_CRIT_CHANCE

CRIT_CHECK:
  # does attacker have crit hits?
  lwz r3, SRP_OPP_FP(REG_SRPD)
  addi r3, r3, FT_SRP_OFST
  lwz REG_FLAGS, SRP_CARDS(r3)
  rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_CRIT, 31-SR_CARD_CRIT
  beq GLASS_CANNON_CHECK

  # is attacker in a state to crit
  CRIT_CHECK_STATE:
    lbz r3, FT_FLAGS4(REG_ATKER)
    rlwinm. r0, r3, 0, 31-2, 31-2
    bne GLASS_CANNON_CHECK

    # roll for crit
    li r3, 100
    ROLL:
      branchl r12, HSD_Randi
      cmpw r3, REG_CRIT_CHANCE
      bgt GLASS_CANNON_CHECK

    # crit hit
    lfs f0, RTOC_10(rtoc)
    fmuls FREG_DMG_MULT, FREG_DMG_MULT, f0
    stfs FREG_DMG_MULT, 0x182C(REG_FP)
    
    # play crit sfx
    li r3, 223
    li r4, 127
    li r5, 64
    load r6, 0xFFFFFFFF
    branchl r12, SFX_HitboxSFX

  GLASS_CANNON_CHECK:
    # do we have glass cannon?
    lwz REG_FLAGS, SRP_CARDS(REG_SRPD)
    rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_GLASSCANNON, 31-SR_CARD_GLASSCANNON
    beq EXIT
    lwz r0, HITBOX_BKB(REG_HITBOX)
    mulli r0, r0, 4
    stw r0, HITBOX_BKB(REG_HITBOX)


EXIT:
  restore_rng REG_RNG, r3
  restore
  lwz	r3, -0x514C (r13)