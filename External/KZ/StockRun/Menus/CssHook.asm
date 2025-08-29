################################################################################
# Address: 0x8026454c
################################################################################

.include "External/KZ/StockRun/StockRun.s"
.include "Common/Common.s"

CODE_START:
  backup
  branchl r12, StockRun_DisplayCssText

EXIT:
  restore
  branch r12, 0x80264578
