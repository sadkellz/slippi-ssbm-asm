################################################################################
# Address: 0x800691b0
# creates a fighter proc before any other procs spawn
################################################################################

.include "Common/Common.s"

b CODE_START

# Init
#==============================================================================#
CODE_START:
.set REG_GOBJ, 31
  backup

  mr r3, REG_GOBJ
  bl FN_FighterThinkBLRL
  mflr r4
  li r5, 0
  branchl r12, GObj_AddProc

  # mr r5, REG_GOBJ
  # logf LOG_LEVEL_ERROR, "Fighter GOBJ: %08x\n"

  b EXIT

#==============================================================================#



#------------------------------------------------------------------------------#
FN_FighterThinkBLRL:
blrl
.set REG_GOBJ, 31
.set REG_DATA, 30
FN_FighterThink:
  backup

  # init vars
  mr REG_GOBJ, r3
  lwz REG_DATA, GOBJ_USERDATA(REG_GOBJ)


FN_FighterThink_Exit:
  restore
  blr

#------------------------------------------------------------------------------#


EXIT:
  restore
  lis	r3, 0x8007
