################################################################################
# Address: 0x804a3128
################################################################################
# inputs:
#   r3 - hitbox
#   r4 - kb
#   r5 - fp
################################################################################

.include "./StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/PLAYER.s"

CODE_START:
  backup

EXIT:
  restore
  blr