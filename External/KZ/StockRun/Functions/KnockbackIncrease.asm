################################################################################
# Address: 0x804a3128
################################################################################
# inputs:
#   r3 - fp
#------------------------------------------------------------------------------#
# loops through pending hitboxes and applies the increase
################################################################################

.include "./StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/PLAYER.s"

CODE_START:
.set REG_FP, 31
  backup
  mr REG_FP, r3

  


EXIT:
  restore
  blr