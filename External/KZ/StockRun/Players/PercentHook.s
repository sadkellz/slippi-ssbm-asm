################################################################################
# Address: 0x8006d374
################################################################################

.include "./StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/PLAYER.s"
.include "External/KZ/OS.s"

lfs	f31, FT_DMG_RECEIVED(r30)

CODE_START:
.set REG_SLOT, 31
.set REG_FP, 30
.set REG_SRPD, 29
.set REG_FLAGS, 28
  backup

  # init
  lbz REG_SLOT, FT_SLOT(REG_FP)
  # load REG_SRPD, stc_sr_plydata
  addi REG_SRPD, REG_FP, FT_SRP_OFST

  # does attacker have random percent?
  lwz r3, FT_ATTACKER(REG_FP)
  mulli r0, r3, SRP_SIZE
  add r3, REG_SRPD, r0
  lwz REG_FLAGS, SRP_CARDS(r3)
  rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_POWERSHIELD, 31-SR_CARD_POWERSHIELD
  beq EXIT


  branchl r12, HSD_Randf
  lfs f0, RTOC_100(rtoc)
  # cube to favour towards 0
  fmuls f1, f1, f1
  fmuls f1, f1, f1
  fmuls f1, f1, f1
  fmuls f31, f1, f0


EXIT:
  mr r3, REG_FP
  restore
