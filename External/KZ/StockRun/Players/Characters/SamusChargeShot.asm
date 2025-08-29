################################################################################
# Address: 0x801295b4
################################################################################

.include "External/KZ/StockRun/StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/PLAYER.s"

CODE_START:
.set REG_FP, 30
  backup

  QUICK_CHARGE_CHECK:
    addi r3, REG_FP, FT_SRP_OFST
    lwz r3, SRP_CARDS(r3)
    rlwinm. r0, r3, 0, 31-SR_CARD_QUICKCHARGE, 31-SR_CARD_QUICKCHARGE
    beq EXIT
    # set it to 6 out of 7
    lwz r0, FT_CHARGE_AMT(REG_FP)
    cmpwi r0, 6
    bge EXIT
    li r0, 6
    stw r0, FT_CHARGE_AMT(REG_FP)

EXIT:
  restore
  mr	r3, r29