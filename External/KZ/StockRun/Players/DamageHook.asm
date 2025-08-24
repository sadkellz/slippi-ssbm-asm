################################################################################
# Address: 0x80076f58
################################################################################

.include "./StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/PLAYER.s"


CODE_START:
.set REG_FP, 28
.set REG_ATK_FP, 26
.set REG_SRPD, 16
.set REG_FLAGS, 17
.set REG_RNG, 18
# floats
.set FREG_DMG_MULT, 20
  backup
  backup_rng REG_RNG

  lfs	FREG_DMG_MULT, 0x182C(REG_FP)
  load REG_SRPD, stc_sr_plydata

  # does attacker have crit hits?
  lwz r3, FT_SLOT(REG_ATK_FP)
  mulli r0, r3, SRP_SIZE
  add r3, REG_SRPD, r0
  lwz REG_FLAGS, SRP_CARDS(r3)
  rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_CRIT, 31-SR_CARD_CRIT
  beq EXIT

  # roll for crit
  li r3, 100
  branchl r12, HSD_Randi
  cmpwi r3, SR_CRIT_CHANCE
  bgt EXIT

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


EXIT:
  restore_rng REG_RNG
  restore
  lfs	f2, 0x182C(r28)