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
.set REG_SRPD, 29
.set REG_FLAGS, 28
  backup
  
  # init
  lbz REG_SLOT, FT_SLOT(REG_DATA)
  load REG_SRPD, stc_sr_plydata

  # this players data
  mulli r0, REG_SLOT, SRP_SIZE
  add r3, REG_SRPD, r0
  lwz REG_FLAGS, SRP_CARDS(r3)

  POWERSHIELD_CHECK:
    rlwinm. r0, REG_FLAGS, 0, 31-SR_CARD_POWERSHIELD, 31-SR_CARD_POWERSHIELD
    beq EXIT
    restore
    branch r12, 0x80076e5c


EXIT:
  restore
  lbz	r0, 0x221C(r31)