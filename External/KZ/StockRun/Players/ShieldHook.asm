################################################################################
# Address: 0x80076dfc
################################################################################

.include "./StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/PLAYER.s"

CODE_START:
# vars
.set REG_DATA, 31
.set REG_SLOT, 30
.set REG_ATKER, 29
.set REG_FLAGS, 28
.set REG_SRPD, 27
  backup
  
  # init
  lbz REG_SLOT, FT_SLOT(REG_DATA)
  load REG_SRPD, stc_sr_plydata

  # this players data
  mulli r0, REG_SLOT, SRP_SIZE
  add r3, REG_SRPD, r0
  lwz REG_FLAGS, SRP_CARDS(r3)

  SHIELD_DMG_CHECK:
    # opponent has shield dmg?
    lwz r3, FT_SLOT(REG_ATKER)
    mulli r0, r3, SRP_SIZE
    add r3, REG_SRPD, r0
    lwz r3, SRP_CARDS(r3)
    rlwinm. r0, r3, 0, 31-SR_CARD_SHIELDDMG, 31-SR_CARD_SHIELDDMG
    beq POWERSHIELD_CHECK
    lfs f1, RTOC_1_5(rtoc)
    stfs f1, 0x19B4(REG_DATA)

  POWERSHIELD_CHECK:
    rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_POWERSHIELD, 31-SR_CARD_POWERSHIELD
    beq EXIT
    restore
    branch r12, 0x80076e5c


EXIT:
  restore
  lbz	r0, 0x221C(r31)