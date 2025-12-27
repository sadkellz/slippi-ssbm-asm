################################################################################
# Address: 0x802323ac
# Since our new option is a button and not a "carousel", we exit early to skip
# the logic for left/right inputs that handle updating rule values
################################################################################

.include "Online/Menus/CustomRules/CustomRules.s"
.include "Common/Common.s"

CODE_START:
.set REG_HOVERED_OPTION, 5
  backup

  cmplwi REG_HOVERED_OPTION, 0x5 # original codeline
  beq SKIP
  cmplwi REG_HOVERED_OPTION, OPTION_RESET_IDX
  beq SKIP

  b EXIT

  # skip to end of func
  SKIP:
    restore
    branch r12, 0x80232438


EXIT:
  restore
