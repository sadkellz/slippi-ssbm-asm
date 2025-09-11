################################################################################
# Address: 0x8006cc98
################################################################################

.include "External/KZ/StockRun/StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/PLAYER.s"


CODE_START:
.set REG_FP, 31
.set REG_SRPD, 20
.set REG_FLAGS, 21
.set REG_OPP, 22
# floats
.set FREG_DMG, 31
  backup

  addi REG_SRPD, REG_FP, FT_SRP_OFST
  lwz REG_FLAGS, SRP_CARDS(REG_SRPD)

  GLASS_CANNON_CHECK:
    # does our opp have glass cannon?
    lwz r3, SRP_OPP_FP(REG_SRPD)
    addi r3, r3, FT_SRP_OFST
    lwz r3, SRP_CARDS(r3)
    rlwinm. r0, r3, 0, 31-SR_CARD_GLASSCANNON, 31-SR_CARD_GLASSCANNON
    beq EXIT

    # double the percent
    lfs f0, RTOC_2(rtoc)
    fmuls FREG_DMG, f0, FREG_DMG


EXIT:
  restore
  lbz	r3, 0x2226(REG_FP)