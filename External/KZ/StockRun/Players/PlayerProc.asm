################################################################################
# Address: 0x800691b0
# creates a fighter proc before any other procs spawn
################################################################################

.include "./StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/PLAYER.s"

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
.set REG_SRPD, 29
FN_FighterThink:
  backup

  # init vars
  mr REG_GOBJ, r3
  lwz REG_DATA, GOBJ_USERDATA(REG_GOBJ)

  # lwz r0, FT_SLOT(REG_DATA)
  # mulli r0, r0, SRP_SIZE
  # load REG_SRPD, stc_sr_plydata
  # add REG_SRPD, REG_SRPD, r0
  # lwz r5, SRP_CARDS(REG_SRPD)
  # logf LOG_LEVEL_ERROR, "Cards: %08x\n"
  

FN_FighterThink_Exit:
  restore
  blr

#------------------------------------------------------------------------------#


EXIT:
  restore
  lis	r3, 0x8007
