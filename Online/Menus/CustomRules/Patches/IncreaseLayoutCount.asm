################################################################################
# Address: 0x802335a0
################################################################################

# the original func creates the option count by calling Menu_IsExtraRuleVisible(0x80231f80)
# in a loop for a hardcoded count of 6 times. (why didnt they just use the menu's option count??)
# this just changes that hardcoded loop to run 7 times
cmpwi	r31, 7
