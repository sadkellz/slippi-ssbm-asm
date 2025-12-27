################################################################################
# Address: 0x80232994
# Menu_UpdateExtraRulesDisplay(0x802327a4) runs the logic to update all of the
# animations for the options and their values. We handle this ourselves since
# the data this menu uses doesn't have our new option, and it would be more
# annoying to try and add it to said data.
################################################################################

.include "Online/Menus/CustomRules/CustomRules.s"
.include "Common/Common.s"

CODE_START:
.set REG_OLD_OPTION, 22
  backup

  cmpwi REG_OLD_OPTION, OPTION_RESET_IDX
  bne EXIT

  # skip upcoming logic if its our custom option
  SKIP:
    restore
    branch r12, 0x80232a10


EXIT:
  restore
  # original code line
  li r6, 17
