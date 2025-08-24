################################################################################
# Address: 0x802299cc
# Same as HandleOnlineLockedOptions.asm
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"

cmpwi r3, 0x3
bne- CHECK_SLIPPI
branch r12, 0x802299d4

CHECK_SLIPPI:
  cmpwi r3, 0x8
  bne- EXIT

lbz r3, OFST_R13_APP_STATE(r13)
cmpwi r3, 0
beq NOT_LOGGED_IN_STATE
cmpwi r3, 1
beq LOGGED_IN_STATE
cmpwi r3, 2
beq UPDATE_STATE

NOT_LOGGED_IN_STATE:
cmpwi r4, OPTION_RANKED_IDX
beq RETURN_LOCKED
cmpwi r4, OPTION_UNRANKED_IDX
beq RETURN_LOCKED
cmpwi r4, OPTION_DIRECT_IDX
beq RETURN_LOCKED
cmpwi r4, OPTION_TEAMS_IDX
beq RETURN_LOCKED
cmpwi r4, OPTION_LOGOUT_IDX
beq RETURN_LOCKED
cmpwi r4, OPTION_UPDATE_IDX
beq RETURN_LOCKED
b EXIT

# direct and logout are the only options
LOGGED_IN_STATE:
cmpwi r4, OPTION_RANKED_IDX
beq RETURN_LOCKED
cmpwi r4, OPTION_UNRANKED_IDX
beq RETURN_LOCKED
cmpwi r4, OPTION_TEAMS_IDX
beq RETURN_LOCKED
cmpwi r4, OPTION_LOGIN_IDX
beq RETURN_LOCKED
cmpwi r4, OPTION_UPDATE_IDX
beq RETURN_LOCKED
b EXIT

UPDATE_STATE:
cmpwi r4, OPTION_RANKED_IDX
beq RETURN_LOCKED
cmpwi r4, OPTION_UNRANKED_IDX
beq RETURN_LOCKED
cmpwi r4, OPTION_DIRECT_IDX
beq RETURN_LOCKED
cmpwi r4, OPTION_TEAMS_IDX
beq RETURN_LOCKED
cmpwi r4, OPTION_LOGIN_IDX
beq RETURN_LOCKED
cmpwi r4, OPTION_LOGOUT_IDX
beq RETURN_LOCKED
b EXIT

RETURN_LOCKED:
li r3, 0
branch r12, 0x802299f4

EXIT:
li r3, 1
