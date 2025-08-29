################################################################################
# Address: 0x8007332c
################################################################################

.include "External/KZ/StockRun/StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/PLAYER.s"
.include "External/KZ/SUBACTIONS.s"

CODE_START:
.set REG_DATA, 31
.set REG_FP, 30
.set REG_CMD, 29
.set REG_EVENT, 28
  backup

  load REG_DATA, stc_sr_sa_fighter
  lwz r0, SR_SA_RESTORE(REG_DATA)
  cmpwi r0, FALSE
  beq EXIT

  # revert script
  lwz r3, 0x8(REG_CMD)
  lwz r3, 0(r3)
  addi r3, r3, 20
  stw r3, 0x8(REG_CMD)

  li r0, FALSE
  stw r0, SR_SA_RESTORE(REG_DATA)


EXIT:
  restore
  lfs	f0, 0(r29)
