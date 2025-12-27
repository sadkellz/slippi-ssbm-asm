################################################################################
# Address: 0x80232f10
################################################################################

.include "Online/Menus/CustomRules/CustomRules.s"
.include "Common/Common.s"

CODE_START:
.set REG_HOVERED_OPTION, 28
.set REG_SIS_IDX, 4
  backup

  cmpwi REG_HOVERED_OPTION, OPTION_RESET_IDX
  bne EXIT

  SET_SIS_IDX:
    restore
    li REG_SIS_IDX, OPTION_RESET_SIS_IDX
    branch r12, 0x80232f14

EXIT:
  restore
  # original code line
  rlwinm r4, r29, 0, 24, 31