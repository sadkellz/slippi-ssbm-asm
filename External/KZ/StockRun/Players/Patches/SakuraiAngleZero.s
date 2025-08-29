################################################################################
# Address: 0x8008d884
################################################################################
# cant do this in the subaction hook without it being a massive pain

.include "External/KZ/StockRun/StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/PLAYER.s"

.set REG_FP, 31

# original codeline
lfs	f1, -0x750C(rtoc) # 0.0f

addi r0, REG_FP, FT_SRP_OFST
addi r0, r0, SRP_CARDS
rlwinm. r0, r0, 0, 31-SR_CARD_KBINV, 31-SR_CARD_KBINV
beq EXIT

lfs	f1, -0x750C(rtoc) # 180.0f


EXIT:
  
