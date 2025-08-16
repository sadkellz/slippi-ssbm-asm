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

# Panel Data - top, right, bottom, left
.set PD_POS, 0
.set PD_SPEED, PD_POS + 12
.set PD_SIZE, PD_SPEED + 4
PD_TOP_BLRL:
blrl
  .float 0.0
  .float 14.0
  .float 0.0
  .float 25.0
PD_RIGHT_BLRL:
  .float 20.0
  .float 0.0
  .float 0.0
  .float 25.0
PD_BOT_BLRL:
  .float 0.0
  .float -14.0
  .float 0.0
  .float 25.0
PD_LEFT_BLRL:
  .float -20.0
  .float 0.0
  .float 0.0
  .float 25.0

# Camera Data
CD_PANEL_BLRL:
blrl
.set DEADZONE, 0
  .float 0.27
.set MOVE_SPEED_Y, DEADZONE + 4
  .float 2.34
.set MOVE_SPEED_X, MOVE_SPEED_Y + 4
  .float 3.15

CD_STICK_BLRL:
blrl
.set DEADZONE, 0
  .float 0.27
.set MOVE_SPEED_Y, DEADZONE + 4
  .float 1.85
.set MOVE_SPEED_X, MOVE_SPEED_Y + 4
  .float 2.85

CODE_START:
  .set REG_GOBJ, 31
  .set REG_DATA, 30
  .set REG_STICK, 29  # jobj
  .set REG_BORDER, 28 # jobj
  .set REG_JOBJ, 27
  .set REG_COBJ, 26
  .set REG_COBJDESC, 25
  .set REG_COUNT, 24
  # stack
  .set SP_JOBJ, BKP_FREE_SPACE_OFFSET
  .set SP_PROMPT_MODEL_SET, SP_JOBJ + 4
  .set SP_GX_START, SP_PROMPT_MODEL_SET + 4
  .set SP_GX_END, SP_GX_START + 4
  backup

# Panels
#------------------------------------------------------------------------------#
# Panel Camera
  # Get camera descriptor from archive
  load r3, stc_ifall
  lwz r3, 0x0(r3)
  load r4, stc_str_ScInfDmg_scene_data
  branchl r12, HSD_ArchiveGetSymbol
  lwz r3, 0x4(r3)
  lwz REG_COBJDESC, 0x0(r3)
  load r4, stc_sr_data
  stw REG_COBJDESC, SRD_COBJ_DESC(r4)

  bl FN_CameraGX
  mflr r16
  spawn_cobj REG_COBJDESC, GOBJ_CLASS_CAMERA, GOBJ_PLINK_HUD, r16, COBJ_GXPRI, 1 << PANEL_GXLINK, REG_GOBJ, REG_COBJ

  # add proc
  mr r3, REG_GOBJ
  bl FN_CameraProcessBLRL
  mflr r4
  li r5, 0
  branchl r12, GObj_AddProc

  mr r3, REG_GOBJ
  li r4, 0
  li r5, 0
  bl CD_PANEL_BLRL
  mflr r6
  branchl r12, GObj_AddUserData

# Panel Jobjs
#------------------------------------------------------------------------------#
  # load archive
  load r3, stc_ifvscam_str
  branchl r12, HSD_ArchiveLoad
  load r4, stc_ifvscam
  stw r3, 0(r4)

  # get symbol
  loadwz r3, stc_ifvscam
  load r4, stc_ifcammodel_str
  branchl r12, HSD_ArchiveGetSymbol
  stw r3, SP_PROMPT_MODEL_SET(sp)

  # create 4 panels
  li REG_COUNT, 0
CREATE_PANEL_LOOP:
  # create gobj
  gobj_create GOBJ_CLASS_UI, GOBJ_PLINK_UI, SR_GOBJ_PRIO, REG_GOBJ

  # data
  bl PD_TOP_BLRL
  mflr REG_DATA
  mulli r0, REG_COUNT, PD_SIZE
  add REG_DATA, REG_DATA, r0

  # load joint
  lwz r3, SP_PROMPT_MODEL_SET(sp)
  lwz r3, DYN_MODEL_JOINT(r3)
  branchl r12, HSD_JObjLoadJoint
  mr REG_JOBJ, r3

  # add to gobj
  mr r3, REG_GOBJ
  li r4, 3
  mr r5, REG_JOBJ
  branchl r12, GObj_AddToObj

  # gx link
  mr r3, REG_GOBJ
  load r4, 0x80391070
  load r5, PANEL_GXLINK # usually 0xB
  li r6, 128
  branchl r12, GObj_SetupGXLink

  # add proc
  mr r3, REG_GOBJ
  bl FN_UpdatePanel
  mflr r4
  li r5, 0
  branchl r12, GObj_AddProc

  mr r3, REG_GOBJ
  li r4, 0
  li r5, 0
  mr r6, REG_DATA
  branchl r12, GObj_AddUserData

  # add anims
  mr r3, REG_JOBJ
  lwz r4, SP_PROMPT_MODEL_SET(sp)
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
  lfs f1, PD_POS+X(REG_DATA)
  lfs f2, PD_POS+Y(REG_DATA)
  lfs f3, PD_POS+Z(REG_DATA)
  lwz r3, SP_JOBJ(sp)
  stfs f1, JOBJ_POS+X(r3)
  stfs f2, JOBJ_POS+Y(r3)
  stfs f3, JOBJ_POS+Z(r3)

  CREATE_PANEL_LOOP_CHECK:
    addi REG_COUNT, REG_COUNT, 1
    cmpwi REG_COUNT, 4
    blt CREATE_PANEL_LOOP


# Stick Interface
#------------------------------------------------------------------------------#
  bl FN_CameraGX
  mflr r16
  spawn_cobj REG_COBJDESC, GOBJ_CLASS_CAMERA, GOBJ_PLINK_HUD, r16, COBJ_GXPRI, 1 << STICK_GXLINK, REG_GOBJ, REG_COBJ

  # add proc
  mr r3, REG_GOBJ
  bl FN_CameraProcessBLRL
  mflr r4
  li r5, 0
  branchl r12, GObj_AddProc

  mr r3, REG_GOBJ
  li r4, 0
  li r5, 0
  bl CD_STICK_BLRL
  mflr r6
  branchl r12, GObj_AddUserData

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

  lfs f1, RTOC_NEG_1_1(rtoc)
  stfs f1, JOBJ_POS(REG_BORDER)
  load r0, 0xbf666666 # -0.9 whatever dude
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

  get_game_state r3
  cmpwi r3, SRGS_GAME_ACTIVE
  beq FN_CameraGX_Exit

  DRAW_GX:
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
.set FREG_SCALEX, 25
FN_CameraProcess:
  backup

  # init vars
  mr REG_GOBJ, r3
  lwz REG_COBJ, GOBJ_OBJ(REG_GOBJ)

  get_game_state r3
  cmpwi r3, SRGS_GAME_ACTIVE
  beq FN_CameraProcess_Exit

  # sticks
  # li r3, DEBUG_PAD_UNION # TODO :: use the active players port
  # get_port_pad r3
  get_active_pad r3
  lfs FREG_X, PAD_stick_x(r3)
  lfs FREG_Y, PAD_stick_y(r3)
  lwz REG_DATA, GOBJ_USERDATA(REG_GOBJ)
  # deadzone
  lfs FREG_DEADZONE, DEADZONE(REG_DATA)
  lfs FREG_SCALE, MOVE_SPEED_Y(REG_DATA)
  lfs FREG_SCALEX, MOVE_SPEED_X(REG_DATA)
  
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

    fmuls FREG_X, FREG_X, FREG_SCALEX
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
.set REG_GOBJ, 31
.set REG_JOBJ, 30
.set REG_DATA, 29
# floats
.set FREG_X, 31
.set FREG_Y, 30
.set FREG_DEADZONE, 27
.set FREG_SCALE, 26
.set FREG_MAGNITUDE, 25
.set FREG_ALIGNMENT, 24
# stack
.set SP_STICK_DIR, BKP_FREE_SPACE_OFFSET
.set SP_JOBJ_DIR, SP_STICK_DIR + 12
.set SP_REF_POS, SP_JOBJ_DIR + 12
  backup
  # init vars
  mr REG_GOBJ, r3
  lwz REG_JOBJ, GOBJ_OBJ(REG_GOBJ)
  lwz REG_DATA, GOBJ_USERDATA(REG_GOBJ)

  get_game_state r3
  cmpwi r3, SRGS_GAME_ACTIVE
  beq FN_UpdatePanel_Exit
  
  # get stick input
  # li r3, DEBUG_PAD_UNION
  # get_port_pad r3
  get_active_pad r3
  lfs FREG_X, PAD_stick_x(r3)
  lfs FREG_Y, PAD_stick_y(r3)
  lfs FREG_DEADZONE, RTOC_STICKTHRESH(rtoc)
  
  # create stick direction
  stfs FREG_X, SP_STICK_DIR+X(sp)
  stfs FREG_Y, SP_STICK_DIR+Y(sp)
  lfs f0, RTOC_ZERO(rtoc)
  stfs f0, SP_STICK_DIR+Z(sp)
  
  # get mag and check deadzone
  addi r3, sp, SP_STICK_DIR
  branchl r12, PSVECMag
  fmr FREG_MAGNITUDE, f1
  fcmpo cr0, FREG_MAGNITUDE, FREG_DEADZONE
  blt SET_MIN_SCALE
  
  # apply curve (cube)
  stick_curve FREG_X, FREG_Y
  
  # normalize
  addi r3, sp, SP_STICK_DIR
  addi r4, sp, SP_STICK_DIR
  branchl r12, PSVECNormalize

  # all relative to 0
  lfs f0, RTOC_ZERO(rtoc)
  stfs f0, SP_REF_POS+X(sp)
  stfs f0, SP_REF_POS+Y(sp)  
  stfs f0, SP_REF_POS+Z(sp)

  # calculate direction from ref to jobj
  addi r3, REG_DATA, PD_POS
  addi r4, sp, SP_REF_POS
  addi r5, sp, SP_JOBJ_DIR
  branchl r12, PSVECSubtract

  # normalize jobj direction
  addi r3, sp, SP_JOBJ_DIR
  addi r4, sp, SP_JOBJ_DIR
  branchl r12, PSVECNormalize

  # alignment to jobj
  addi r3, sp, SP_STICK_DIR
  addi r4, sp, SP_JOBJ_DIR
  branchl r12, PSVECDotProduct
  fmr FREG_ALIGNMENT, f1

  # clamp mag
  lfs f0, RTOC_ONE(rtoc)
  fcmpo cr0, FREG_MAGNITUDE, f0
  ble SCALE_CALCULATION
  fmr FREG_MAGNITUDE, f0

SCALE_CALCULATION:
  fmuls f0, FREG_MAGNITUDE, FREG_ALIGNMENT
  lfs f1, RTOC_ZERO(rtoc)
  fcmpo cr0, f0, f1
  blt SCALE_TO_ZERO

  # scale up from 1.0 to max
  lfs f1, RTOC_ONE(rtoc)
  lfs f2, MAX_SCALE(rtoc)
  fsubs f2, f2, f1  # max - 1.0
  fmadds FREG_SCALE, f2, f0, f1  # 1.0 + (max-1.0)*factor
  b SET_SCALE

SCALE_TO_ZERO:
  # scale from min towards zero
  fabs f0, f0
  lfs f1, RTOC_ONE(rtoc)
  lfs f2, RTOC_ZERO(rtoc)
  fsubs f2, f1, f2  # min - 0
  fmuls f2, f2, f0  # (min - 0) * factor
  fsubs FREG_SCALE, f1, f2  # min - (min * factor)
  b SET_SCALE

SET_MIN_SCALE:
 lfs FREG_SCALE, RTOC_ONE(rtoc)

SET_SCALE:
  mr r3, REG_JOBJ
  fmr f1, FREG_SCALE
  fmr f2, FREG_SCALE
  fmr f3, FREG_SCALE
  branchl r12, HSD_JObjSetScale

  # move in opposite direction
  lfs f1, PD_POS+X(REG_DATA)
  lfs f2, PD_POS+Y(REG_DATA)
  lfs f3, PD_POS+Z(REG_DATA)
  
  # (stick direction * magnitude * movement scale) - offset
  lfs f4, SP_STICK_DIR+X(sp)
  lfs f5, SP_STICK_DIR+Y(sp)
  lfs f6, SP_STICK_DIR+Z(sp)
  
  # scale movement by mag and offset
  lfs f0, PD_SPEED(REG_DATA)
  fmuls f4, f4, FREG_MAGNITUDE
  fmuls f4, f4, f0
  fmuls f5, f5, FREG_MAGNITUDE
  fmuls f5, f5, f0
  fmuls f6, f6, FREG_MAGNITUDE
  fmuls f6, f6, f0
  
  fsubs f1, f1, f4
  fsubs f2, f2, f5
  fsubs f3, f3, f6
  
  # set position
  stfs f1, JOBJ_POS+X(REG_JOBJ)
  stfs f2, JOBJ_POS+Y(REG_JOBJ)
  stfs f3, JOBJ_POS+Z(REG_JOBJ)
 
  mr r3, REG_JOBJ
  branchl r12, HSD_JObjSetMtxDirty

  # fmr f1, FREG_MAGNITUDE
  # fmr f2, FREG_ALIGNMENT
  # fmr f3, FREG_SCALE
  # fmr f4, FREG_Y
  # logf LOG_LEVEL_ERROR, "\nMAG: %f ALIGN: %f SCALE: %f Y: %f\n"

FN_UpdatePanel_Exit:
 restore
 blr



# Main exit
#=============================================================================#

EXIT:
  restore
  lis	r4, 0x8040
