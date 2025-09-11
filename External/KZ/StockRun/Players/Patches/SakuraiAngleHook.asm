################################################################################
# Address: 0x8008d8c4
################################################################################
# cant do this in the subaction hook without it being a massive pain

.include "External/KZ/StockRun/StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/PLAYER.s"

.set REG_FP, 31

CODE_START:
  backup

  lwz	r3, 0x1848 (REG_FP)
  cmpwi r3, 361
  bne EXIT

  addi r3, REG_FP, FT_SRP_OFST
  lwz r3, SRP_OPP_FP(r3)
  addi r3, r3, FT_SRP_OFST
  lwz r0, SRP_CARDS(r3)
  rlwinm. r0, r0, 0, 31-SR_CARD_KBINV, 31-SR_CARD_KBINV
  beq EXIT

  lfs	f0, RTOC_180(rtoc) # 180.0f'
  lfs f3, RTOC_DEG2RAD(rtoc) # 0.0174532925f
  fmuls f0, f0, f3
  fadds f1, f1, f0

EXIT:
  restore
  lwz	r0, 0x0024(sp)
  
