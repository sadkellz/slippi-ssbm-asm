################################################################################
# Address: 0x8023206c
################################################################################

.include "Online/Menus/CustomRules/CustomRules.s"
.include "Common/Common.s"

CODE_START:
.set REG_DEFAULT_RULES, 31
.set REG_CUR_RULES, 30
.set REG_FLOW, 29
.set REG_HOVERED_OPTION, 3
  backup

# check if this is our custom option
  lhz REG_HOVERED_OPTION, MFD_HOVERED_OPTION(REG_FLOW)
  cmplwi REG_HOVERED_OPTION, OPTION_RESET_IDX
  bne EXIT

  # reset the rules to default
  ON_RESET:
    restore
    load REG_DEFAULT_RULES, DefaultGameRules
    branchl r12, GetGameRules
    mr REG_CUR_RULES, r3

    mr r3, REG_CUR_RULES
    mr r4, REG_DEFAULT_RULES
    li r5, GAME_RULES_SIZE
    branchl r12, memcpy

    # this function handles proper cleanup of the rules menu
    # and will kick us back to the scene we were in
    branchl r12, Menu_ExitRulesMenu

    branch r12, 0x80232438

EXIT:
  restore
  # original code line
  cmplwi REG_HOVERED_OPTION, 0x5
