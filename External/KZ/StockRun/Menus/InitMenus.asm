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
.include "External/KZ/OS.s"

################################################################################
# We will run a gobj proc to handle the menu/cards and player selections
#
b CODE_START

DATA_BLRL:
blrl
.set PROMPT_MODEL_SET, 0
.long 0 # DynamicModelDesc
.set PROMPT_JOBJ, PROMPT_MODEL_SET + 4
.long 0

CODE_START:
  .set REG_GOBJ, 31
  .set REG_DATA, 30
  .set REG_STICK, 29  # jobj
  .set REG_BORDER, 28 # jobj
  .set REG_JOBJ, 27
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

# transform jobjs
  load r3, stc_pause_data
  addi r4, r3, PAUSE_UI_STICK
  lwz REG_STICK, 0(r4)
  lwz REG_STICK, JOBJ_PARENT(REG_STICK)
  addi r4, r3, PAUSE_UI_STICK_BORDER
  lwz REG_BORDER, 0(r4)

  # pos
  lfs f1, RTOC_ZERO(rtoc)
  stfs f1, JOBJ_POS(REG_STICK)
  stfs f1, JOBJ_POS+4(REG_STICK)
  stfs f1, JOBJ_ROT(REG_STICK)
  stfs f1, JOBJ_ROT+4(REG_STICK)
  stfs f1, JOBJ_ROT+8(REG_STICK)

  lfs f1, RTOC_ONE(rtoc)
  fneg f1, f1
  load r0, 0xbf666666 # -0.9 whatever dude
  stfs f1, JOBJ_POS(REG_BORDER)
  stw r0, JOBJ_POS+4(REG_BORDER)

  # scale
  lfs f1, RTOC_TWO(rtoc)
  stfs f1, JOBJ_SCALE(REG_STICK)
  stfs f1, JOBJ_SCALE+4(REG_STICK)
  stfs f1, JOBJ_SCALE+8(REG_STICK)

  stfs f1, JOBJ_SCALE(REG_BORDER)
  stfs f1, JOBJ_SCALE+4(REG_BORDER)
  stfs f1, JOBJ_SCALE+8(REG_BORDER)

  mr r3, REG_STICK
  branchl r12, HSD_JObjSetMtxDirty

  # increase stick mult
  load r0, 0x41c80000 # 25.0
  load r3, stc_pause_stickmult
  stw r0, 0(r3)


# set up the radial menu - uses the vscam interface
  bl DATA_BLRL
  mflr REG_DATA

  load r3, stc_ifvscam_str
  branchl r12, HSD_ArchiveLoad
  load r4, stc_ifvscam
  stw r3, 0(r4)

  # get symbol
  loadwz r3, stc_ifvscam
  load r4, stc_ifcammodel_str
  branchl r12, HSD_ArchiveGetSymbol
  stw r3, PROMPT_MODEL_SET(REG_DATA)

  # create gobj
  gobj_create GOBJ_CLASS_UI, GOBJ_CLASS_MAINCAM, 0, REG_GOBJ

  # load joint
  lwz r3, PROMPT_MODEL_SET(REG_DATA)
  lwz r3, DYN_MODEL_JOINT(r3)
  branchl r12, HSD_JObjLoadJoint
  mr REG_JOBJ, r3
  stw REG_JOBJ, PROMPT_JOBJ(REG_DATA)

  # add to gobj
  mr r3, REG_GOBJ
  li r4, 3
  mr r5, REG_JOBJ
  branchl r12, GObj_AddToObj

  # gx link
  mr r3, REG_GOBJ
  load r4, 0x80391070
  li r5, 0xC # usually 0xB
  li r6, 0

  # add anims
  mr r3, REG_JOBJ
  lwz r4, PROMPT_MODEL_SET(REG_DATA)
  li r5, 0
  branchl r12, HSD_JObjAddSceneAnimByIndex

  # anim
  mr r3, REG_JOBJ
  lfs f1, RTOC_ZERO(rtoc)
  branchl r12, HSD_JObjReqAnimAll

  mr r3, REG_JOBJ
  branchl r12, HSD_JObjAnimAll

  mr r3, REG_JOBJ
  li r4, JOBJFLAG_HIDDEN
  branchl r12, HSD_JObjClearFlagsAll

  b EXIT

################################################################################
################################################################################
FN_PickerDisplayBLRL:
blrl
.set REG_FRAME, 27
.set REG_PICKER, 26
.set REG_SLOT, 25
FN_PickerDisplay:
  backup

  mr REG_GOBJ, r3 # store gobj just incase
  load r3, stc_sr_data # load our static data
  lwz r3, SR_GOBJ_INIT(r3)
  lwz REG_DATA, GOBJ_USERDATA(r3)

  lwz r3, ACTIVE_PICKER(REG_DATA)
  lbzx REG_SLOT, REG_DATA, r3 # get the slot of the active picker
  load r4, stc_pause_data
  stw REG_SLOT, PAUSE_UI_SLOT(r4)

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

  # display
  mr r3, REG_STICK
  li r4, JOBJFLAG_HIDDEN
  branchl r12, HSD_JObjClearFlagsAll

  mr r3, REG_BORDER
  li r4, JOBJFLAG_HIDDEN
  branchl r12, HSD_JObjClearFlagsAll



FN_PickerDisplay_Exit:
  restore
  blr

################################################################################

EXIT:
  restore
  lis	r4, 0x8040
