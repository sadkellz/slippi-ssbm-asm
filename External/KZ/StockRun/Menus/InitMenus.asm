################################################################################
# Address: 0x802f393c # CreateHUD
################################################################################

.include "./StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/HSD_COBJ.s"
.include "External/KZ/HSD_JOBJ.s"
.include "External/KZ/HSD_PAD.s"
.include "External/KZ/PLAYER.s"
.include "External/KZ/MATCH.s"

################################################################################
# We will run a gobj proc to handle the menu/cards and player selections
#

b CODE_START

CODE_START:
  .set REG_GOBJ, 31
  .set REG_DATA, 30
  backup

  gobj_create GOBJ_CLASS_UI, GOBJ_PLINK_UI, 111, REG_GOBJ
  load r3, stc_sr_data
  stw REG_GOBJ, SR_GOBJ_MENU(r3)

# add proc
  mr r3, REG_GOBJ
  bl FN_PickerDisplayBLRL
  mflr r4
  li r5, 0
  branchl r12, GObj_AddProc

  b EXIT

################################################################################
################################################################################
FN_PickerDisplayBLRL:
blrl
.set REG_STICK, 29  # jobj
.set REG_BORDER, 28 # jobj
.set REG_FRAME, 27
.set REG_PICKER, 26
FN_PickerDisplay:
  backup

  mr REG_GOBJ, r3 # store gobj just incase
  load r3, stc_sr_data # load our static data
  lwz r3, SR_GOBJ_INIT(r3)
  lwz REG_DATA, GOBJ_USERDATA(r3)

  bp
  # load jobjs
  load r3, stc_pause_data
  addi r4, r3, PAUSE_UI_STICK
  lwz REG_STICK, 0(r4)
  addi r4, r3, PAUSE_UI_STICK_BORDER
  lwz REG_BORDER, 0(r4)

  # check if we should show the displayer
  load_scene_frame REG_FRAME
  cmpwi REG_FRAME, MENU_START_FRAME
  blt FN_PickerDisplay_Exit

  mr r3, REG_STICK
  li r4, JOBJFLAG_HIDDEN
  branchl r12, HSD_JObjClearFlagsAll

  # logf LOG_LEVEL_ERROR, "CLEARING FLAGS\n"


FN_PickerDisplay_Exit:
  restore
  blr

################################################################################

EXIT:
  restore
  lis	r4, 0x8040
