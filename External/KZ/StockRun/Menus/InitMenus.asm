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
.include "External/KZ/MATH.s"
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
.set PANEL_Y, PROMPT_JOBJ + 4
.float 14.0

PANEL_DATA_BLRL:
blrl
.set DEADZONE, 0
  .float 0.27
.set MOVE_SPEED, DEADZONE + 4
  .float 2.0

CODE_START:
  .set REG_GOBJ, 31
  .set REG_DATA, 30
  .set REG_STICK, 29  # jobj
  .set REG_BORDER, 28 # jobj
  .set REG_JOBJ, 27
  .set REG_COBJ, 26
  .set SP_JOBJ, BKP_FREE_SPACE_OFFSET
  backup

# Panels
#------------------------------------------------------------------------------#
  # Get camera descriptor from archive
  load r3, stc_ifall
  lwz r3, 0x0(r3)
  load r4, stc_str_ScInfDmg_scene_data
  branchl r12, HSD_ArchiveGetSymbol
  lwz r3, 0x4(r3)
  lwz r3, 0x0(r3)
  load r4, stc_sr_data
  stw r3, SRD_COBJ_DESC(r4)

  bl FN_CameraGX
  mflr r16
  spawn_cobj r3, GOBJ_CLASS_CAMERA, GOBJ_PLINK_HUD, r16, COBJ_GXPRI, 1 << MY_GXLINK, REG_GOBJ, REG_COBJ

  # add proc
  mr r3, REG_GOBJ
  bl FN_CameraProcessBLRL
  mflr r4
  li r5, 0
  branchl r12, GObj_AddProc

  mr r3, REG_GOBJ
  li r4, 0
  li r5, 0
  bl PANEL_DATA_BLRL
  mflr r6
  branchl r12, GObj_AddUserData

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
  gobj_create GOBJ_CLASS_UI, GOBJ_PLINK_UI, SR_GOBJ_PRIO, REG_GOBJ

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
  load r5, MY_GXLINK # usually 0xB
  li r6, 128
  branchl r12, GObj_SetupGXLink

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

  # hide everything
  mr r3, REG_JOBJ
  li r4, JOBJFLAG_HIDDEN
  branchl r12, HSD_JObjSetFlagsAll

  # get the panel jobj
  mr r3, REG_JOBJ
  addi r4, sp, SP_JOBJ
  li r5, IF_PANEL_IDX
  li r6, -1
  branchl r12, HSD_JObjGetChild

  # unhide the panel
  lwz r3, SP_JOBJ(sp)
  li r4, JOBJFLAG_HIDDEN
  branchl r12, HSD_JObjClearFlagsAll

  # hide the text dobj
  lwz r3, SP_JOBJ(sp)
  branchl r12, HSD_JObjGetDObj
  lwz r3, 0x4(r3) # next dobj is the text
  li r4, 0x1 # hidden
  branchl r12, HSD_DObjSetFlags

  # set the position
  lfs f1, PANEL_Y(REG_DATA)
  lwz r3, SP_JOBJ(sp)
  stfs f1, JOBJ_POS+Y(r3)


# Stick Interface
#------------------------------------------------------------------------------#
  gobj_create GOBJ_CLASS_UI, GOBJ_PLINK_UI, SR_GOBJ_PRIO, REG_GOBJ
  load r3, stc_sr_data
  stw REG_GOBJ, SRD_GOBJ_MENU(r3)

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

  b EXIT

#==============================================================================#



# Picker Process
#------------------------------------------------------------------------------#

FN_PickerDisplayBLRL:
blrl
.set REG_FRAME, 27
.set REG_PICKER, 26
.set REG_SLOT, 25
FN_PickerDisplay:
  backup

  mr REG_GOBJ, r3 # store gobj just incase
  load r3, stc_sr_data # load our static data
  lwz r3, SRD_GOBJ_INIT(r3)
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


# Camera GX
#------------------------------------------------------------------------------#
.set REG_GOBJ, 31
FN_CameraGX:
  blrl
  backup

  mr REG_GOBJ, r3
  mr r3, REG_GOBJ
  branchl r12, 0x803910d8

FN_CameraGX_Exit:
  restore
  blr
  

# Camera Process
#------------------------------------------------------------------------------#
# This will rotate the camera towards our selection
FN_CameraProcessBLRL:
blrl
.set REG_GOBJ, 31
.set REG_COBJ, 30
.set REG_DATA, 29
.set REG_MTX, 28
# float regs
.set FREG_X, 31
.set FREG_Y, 30
.set FREG_PITCH, 29
.set FREG_YAW, 28
.set FREG_DEADZONE, 27
.set FREG_SCALE, 26
FN_CameraProcess:
  backup

  # init vars
  mr REG_GOBJ, r3
  lwz REG_COBJ, GOBJ_OBJ(REG_GOBJ)
  # sticks
  li r3, DEBUG_PAD_UNION # TODO :: use the active players port
  get_port_pad r3
  lfs FREG_X, PAD_stick_x(r3)
  lfs FREG_Y, PAD_stick_y(r3)
  lwz REG_DATA, GOBJ_USERDATA(REG_GOBJ)
  # deadzone
  lfs FREG_DEADZONE, DEADZONE(REG_DATA)
  lfs FREG_SCALE, MOVE_SPEED(REG_DATA)
  
  check_deadzones FREG_X, FREG_Y, FREG_DEADZONE
  cmpwi r0, FALSE
  beq CALCULATE_ANGLES
  # no inputs, exit
  lfs FREG_X, RTOC_ZERO(rtoc)
  lfs FREG_Y, RTOC_ZERO(rtoc)
  b EXECUTE

  CALCULATE_ANGLES:
    CHECK_X:
      check_deadzone FREG_X, FREG_DEADZONE
      cmpwi r0, TRUE
      beq SET_HORIZONTAL_ZERO
      b CHECK_Y
      
      SET_HORIZONTAL_ZERO:
        lfs FREG_X, RTOC_ZERO(rtoc)

    CHECK_Y:
      check_deadzone FREG_Y, FREG_DEADZONE
      cmpwi r0, TRUE
      beq SET_VERTICAL_ZERO
      b EXECUTE
      
      SET_VERTICAL_ZERO:
        lfs FREG_Y, RTOC_ZERO(rtoc)

  EXECUTE:
    # just using the stack pointer since its there
    .set SP_UP, BKP_FREE_SPACE_OFFSET
    .set SP_FWD, SP_UP + 12
    .set SP_LEFT, SP_FWD + 12
    .set SP_EYE, SP_LEFT + 12
    .set SP_NEW_EYE, SP_LEFT + 12
    .set SP_TARGET, SP_NEW_EYE + 12
    .set SP_NEW_TARGET, SP_TARGET + 12
    .set SP_OFFSET, SP_NEW_TARGET + 12
    .set SP_VOFFSET, SP_OFFSET + 12

  # fmr f1, FREG_X
  # fmr f2, FREG_Y
  # logf LOG_LEVEL_ERROR, "sticks: %f, %f\n"

    fmuls FREG_X, FREG_X, FREG_SCALE
    fmuls FREG_Y, FREG_Y, FREG_SCALE
    stick_curve FREG_X, FREG_Y
    fneg FREG_X, FREG_X

    # reset camera?
    mr r3, REG_COBJ
    load r4, stc_sr_data
    lwz r4, SRD_COBJ_DESC(r4)
    branchl r12, HSD_CObjInit

    mr r3, REG_COBJ
    addi r4, sp, SP_EYE
    branchl r12, HSD_CObjGetEyePosition
    mr r3, REG_COBJ
    addi r4, sp, SP_TARGET
    branchl r12, HSD_CObjGetInterest
    mr r3, REG_COBJ
    addi r4, sp, SP_FWD
    branchl r12, HSD_CObjGetForwardVector
    addi r3, sp, SP_FWD
    addi r4, sp, SP_FWD
    branchl r12, PSVECNormalize

    # Set world up vector
    lfs f0, RTOC_ZERO(rtoc)
    lfs f1, RTOC_ONE(rtoc)
    stfs f0, SP_UP+X(sp)
    stfs f1, SP_UP+Y(sp)
    stfs f0, SP_UP+Z(sp)

    # Calculate right vector
    addi r3, sp, SP_UP
    addi r4, sp, SP_FWD
    addi r5, sp, SP_LEFT
    branchl r12, PSVECCrossProduct
    addi r3, sp, SP_LEFT
    addi r4, sp, SP_LEFT
    branchl r12, PSVECNormalize

    # Calculate camera-aligned up vector
    addi r3, sp, SP_FWD
    addi r4, sp, SP_LEFT
    addi r5, sp, SP_UP
    branchl r12, PSVECCrossProduct

    # Calculate horizontal pan offset
    fmr f1, FREG_X
    addi r3, sp, SP_LEFT
    addi r4, sp, SP_OFFSET
    branchl r12, PSVECScale

    # Calculate vertical pan offset
    fmr f1, FREG_Y
    addi r3, sp, SP_UP
    addi r4, sp, SP_VOFFSET
    branchl r12, PSVECScale

    # Combine offsets
    addi r3, sp, SP_OFFSET
    addi r4, sp, SP_VOFFSET
    addi r5, sp, SP_OFFSET
    branchl r12, PSVECAdd

    # Apply to eye position
    addi r3, sp, SP_EYE
    addi r4, sp, SP_OFFSET
    addi r5, sp, SP_NEW_EYE
    branchl r12, PSVECAdd

    # Apply to target
    addi r3, sp, SP_TARGET
    addi r4, sp, SP_OFFSET
    addi r5, sp, SP_NEW_TARGET
    branchl r12, PSVECAdd

  lfs f1, SP_NEW_EYE+X(sp)
  lfs f2, SP_NEW_EYE+Y(sp)
  lfs f3, SP_NEW_EYE+Z(sp)
  logf LOG_LEVEL_ERROR, "Camera: New Eye: (%f, %f, %f)\n"

    # Update camera
    mr r3, REG_COBJ
    addi r4, sp, SP_NEW_EYE
    branchl r12, HSD_CObjSetEyePosition
    mr r3, REG_COBJ
    addi r4, sp, SP_NEW_TARGET
    branchl r12, HSD_CObjSetInterest

FN_CameraProcess_Exit:
  restore
  blr


# Jobj Process
#-----------------------------------------------------------------------------#
FN_UpdatePanel:
  blrl
  backup

FN_UpdatePanel_Exit:
  restore
  blr



# Main exit
#=============================================================================#

EXIT:
  restore
  lis	r4, 0x8040
