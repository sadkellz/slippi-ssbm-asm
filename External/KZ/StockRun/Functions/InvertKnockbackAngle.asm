################################################################################
# Address: 0x804a3128
################################################################################
# r3 - Hitbox
# r4 - angle
# r5 - fgp

.include "./StockRun.s"
.include "Common/Common.s"

CODE_START:
  backup

EXIT:
  restore
  blr