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
.set PD_CURRENT_SCALE, PD_POS + 12
.set PD_CURRENT_ALPHA, PD_CURRENT_SCALE + 4
.set PD_SIZE, PD_CURRENT_ALPHA + 4
PD_TOP_BLRL:
blrl
  .float 0.0
  .float 17.0
  .float 0.0
  .float 1.0
  .float 0.0
PD_RIGHT_BLRL:
  .float 34.0
  .float 0.0
  .float 0.0
  .float 1.0
  .float 0.0
PD_BOT_BLRL:
  .float 0.0
  .float -17.0
  .float 0.0
  .float 1.0
  .float 0.0
PD_LEFT_BLRL:
  .float -34.0
  .float 0.0
  .float 0.0
  .float 1.0
  .float 0.0

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

# Text Data - TOP, RIGHT, BOTTOM, LEFT
TEXT_DATA_BLRL:
blrl
.set TXT_WIDTH, 0
.set TXT_HEIGHT, TXT_WIDTH + 4
.set TXT_OFSTX, TXT_HEIGHT + 4
.set TXT_OFSTY, TXT_OFSTX + 4
.set TXT_SCALE, TXT_OFSTY + 4
.set TXT_TRANS, TXT_SCALE + 4
.set TD_SIZE, TXT_TRANS + 4
TEXT_DATA_TOP:
  .float 40.0
  .float 16.0
  .float -20.0
  .float -25.0
  .float 0.0
  .float 1.0
TEXT_DATA_RIGHT:
  .float 40.0
  .float 16.0
  .float -20.0
  .float -25.0
  .float 0.0
  .float 1.0
TEXT_DATA_BOTTOM:
  .float 40.0
  .float 16.0
  .float -20.0
  .float -25.0
  .float 0.0
  .float 1.0
TEXT_DATA_LEFT:
  .float 40.0
  .float 16.0
  .float -20.0
  .float -25.0
  .float 0.0
  .float 1.0


CODE_START:
  .set REG_GOBJ, 31
  .set REG_DATA, 30
  .set REG_STICK, 29  # jobj
  .set REG_BORDER, 28 # jobj
  .set REG_JOBJ, 27
  .set REG_COBJ, 26
  .set REG_COBJDESC, 25
  .set REG_COUNT, 24
  .set REG_CANVAS, 23
  .set REG_CAMGOBJ, 22
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
  # load archive
  load r3, stc_str_gmtou1p
  branchl r12, HSD_ArchiveLoad

  # get symbol
  load r4, stc_str_ScGamTour_scene_data
  branchl r12, HSD_ArchiveGetSymbol
  lwz r3, 0x4(r3)
  lwz REG_COBJDESC, 0x0(r3)
  load r4, stc_sr_data
  stw REG_COBJDESC, SRD_COBJ_DESC(r4)

  bl FN_CameraGX
  mflr r16
  spawn_cobj REG_COBJDESC, GOBJ_CLASS_CAMERA, GOBJ_PLINK_HUD, r16, COBJ_GXPRI, 1 << PANEL_GXLINK, REG_CAMGOBJ, REG_COBJ
  load r4, stc_sr_data
  stw REG_COBJ, SRD_COBJ(r4)
  # add proc
  mr r3, REG_CAMGOBJ
  bl FN_CameraProcessBLRL
  mflr r4
  li r5, 0
  branchl r12, GObj_AddProc

  mr r3, REG_CAMGOBJ
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

  # we have to turn on zupdate in the mobj desc before it gets loaded
  # otherwise it will always draw over our text
  # lwz r3, SP_PROMPT_MODEL_SET(sp)
  # lwz r3, DYN_MODEL_JOINT(r3)
  # # traverse tree
  # lwz r3, 0x8(r3) # child
  # lwz r3, 0xC(r3) # next
  # # dobjdesc
  # lwz r3, 0x10(r3)
  # # mobjdesc
  # lwz r3, 0x8(r3)
  # # set flags
  # load r4, 1 << 29 # zupdate
  # lwz r5, 0x4(r3) # flags
  # andc r5, r5, r4
  # # why does this hide the entire panel?
  # stw r5, 0x4(r3)

  # create 4 panels
  li REG_COUNT, 0
CREATE_PANEL_LOOP:
  # create gobj
  gobj_create GOBJ_CLASS_UI, GOBJ_PLINK_UI, SR_GOBJ_PRIO, REG_GOBJ
# 80d3dd88
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
  # store joint
  # load r4, stc_sr_data
  # addi r4, r4, SRD_JOBJ_PANELS
  # mulli r0, REG_COUNT, 4
  # stwx REG_JOBJ, r4, r0

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
  lfs f1, RTOC_0(rtoc)
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

  # store panels
  lwz r3, SP_JOBJ(sp)
  load r4, stc_sr_data
  addi r4, r4, SRD_JOBJ_PANELS
  mulli r0, REG_COUNT, 4
  stwx r3, r4, r0

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
  # load r4, stc_sr_data
  # stw REG_COBJ, SRD_COBJ(r4)

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
  lfs f1, RTOC_0(rtoc)
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
  lfs f1, RTOC_2(rtoc)
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


# Init Text Process
#-------------------------------------------------------------------------------#
  # create canvas
  li r3, SIS_ID          # sis id
  mr r4, REG_CAMGOBJ   # camera gobj
  # li r4, 0
  # load r4, 0x804a0fd8
  li r5, GOBJ_CLASS_UI          # gobj class
  li r6, GOBJ_PLINK_UI         # plink
  li r7, 0          # prio
  li r8, PANEL_GXLINK        # gxlink
  li r9, 0          # render prio
  li r10, 0        # camera prio
  branchl r12, Text_CreateCanvas
  mr REG_CANVAS, r3

.set REG_TEXT, 16
.set REG_SISDATA, 17
.set REG_SISTABLE, 18
.set SP_CLR, BKP_FREE_SPACE_OFFSET
  bl TEXT_DATA_BLRL
  mflr REG_DATA

  # get SdTou filename
  branchl r12, 0x8018f5f0
  mr r4, r3
  li r3, SIS_ID
  load r5, 0x803da0b8 # "SIS_TournamentData"
  branchl r12, 0x803a62a0 # LoadSIS
  # replace SIS text
  # get our SIS address we're replacing - taken from 803a637c
  load r0, 0x804d1124 # SISData - SIS[4]
  li r5, SIS_ID
  rlwinm r3, r5, 2, 0, 29
  add	r3, r0, r3
  lwz	REG_SISDATA, 0(r3) # SISData[SIS_ID]
  computeBranchTargetAddress REG_SISTABLE, stc_sr_sistable
  li REG_COUNT, 0
  SIS_LOOP:
    # now the idx we want
    rlwinm r0, REG_COUNT, 2, 0, 29
    add r12, REG_SISTABLE, r0
    mtctr r12
    bctrl
    mflr r3
    stwx r3, REG_SISDATA, r0

  SIS_LOOP_CHECK:
    addi REG_COUNT, REG_COUNT, 1
    cmpwi REG_COUNT, SIS_COUNT
    ble SIS_LOOP

  # create text
  li REG_COUNT, 0
  SPAWN_TEXT_LOOP:
    li r3, SIS_ID
    mr r4, REG_CANVAS
    # text process handles position
    lfs	f1, TXT_OFSTX(REG_DATA)
    lfs	f2, TXT_OFSTY(REG_DATA)
    lfs	f3, RTOC_0(rtoc)
    lfs	f4, TXT_WIDTH(REG_DATA)
    lfs	f5, TXT_HEIGHT(REG_DATA)
    branchl r12, Text_AllocateTextObject
    mr REG_TEXT, r3
    # load r3, 0xFF00007F
    # stw r3, TEXT_BACKGROUND_CLR(REG_TEXT)

    mr r3, REG_TEXT
    mr r4, REG_COUNT
    branchl r12, Text_SetFromSIS

    li r3, TRUE
    stb r3, TEXT_DEFAULT_USE_ASPECT(REG_TEXT)
    stb r3, TEXT_DEPTH_TEST(REG_TEXT)
    

    load r4, stc_sr_data
    addi r4, r4, SRD_TEXTS
    mulli r0, REG_COUNT, 4
    stwx REG_TEXT, r4, r0

    mr r5, REG_TEXT
    logf LOG_LEVEL_NOTICE, "text %x"

    SPAWN_TEXT_LOOP_CHECK:
      addi REG_COUNT, REG_COUNT, 1
      cmpwi REG_COUNT, 4
      blt SPAWN_TEXT_LOOP
      mr r5, REG_COUNT

    load r4, stc_sr_data
    lwz REG_TEXT, SRD_TEXTS(r4)
    load r3, 0xFF00007F
    stw r3, TEXT_BACKGROUND_CLR(REG_TEXT)


  gobj_create GOBJ_CLASS_UI, GOBJ_PLINK_UI, SR_GOBJ_PRIO, REG_GOBJ

# add proc
  mr r3, REG_GOBJ
  bl FN_TextProcessBLRL
  mflr r4
  li r5, 8
  branchl r12, GObj_AddProc

# add data
  mr r3, REG_GOBJ
  li r4, 0
  li r5, 0
  load r6, stc_sr_data
  branchl r12, GObj_AddUserData


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
  li r3, DEBUG_PAD_UNION # TODO :: use the active players port
  get_port_pad r3
  # get_active_pad r3
  lfs FREG_X, PAD_stick_x(r3)
  lfs FREG_Y, PAD_stick_y(r3)
  lwz REG_DATA, GOBJ_USERDATA(REG_GOBJ)
  # deadzone
  # lfs FREG_DEADZONE, DEADZONE(REG_DATA)
  lfs FREG_DEADZONE, RTOC_STICKTHRESH(rtoc)
  lfs FREG_SCALE, MOVE_SPEED_Y(REG_DATA)
  lfs FREG_SCALEX, MOVE_SPEED_X(REG_DATA)
  
  check_deadzones FREG_X, FREG_Y, FREG_DEADZONE
  cmpwi r0, FALSE
  beq CALCULATE_ANGLES
  # no inputs, exit
  lfs FREG_X, RTOC_0(rtoc)
  lfs FREG_Y, RTOC_0(rtoc)
  b EXECUTE

  CALCULATE_ANGLES:
    CHECK_X:
      check_deadzone FREG_X, FREG_DEADZONE
      cmpwi r0, TRUE
      beq SET_HORIZONTAL_ZERO
      b CHECK_Y
      
      SET_HORIZONTAL_ZERO:
        lfs FREG_X, RTOC_0(rtoc)

    CHECK_Y:
      check_deadzone FREG_Y, FREG_DEADZONE
      cmpwi r0, TRUE
      beq SET_VERTICAL_ZERO
      b EXECUTE
      
      SET_VERTICAL_ZERO:
        lfs FREG_Y, RTOC_0(rtoc)

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
    lfs f0, RTOC_0(rtoc)
    lfs f1, RTOC_1(rtoc)
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

    # lfs f1, SP_NEW_EYE+X(sp)
    # lfs f2, SP_NEW_EYE+Y(sp)
    # lfs f3, SP_NEW_EYE+Z(sp)

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


# Text Process
#-----------------------------------------------------------------------------#
FN_TextProcessBLRL:
blrl
# stack
.set SP_OUT, BKP_FREE_SPACE_OFFSET
.set SP_STICK_DIR, SP_OUT + 12
.set SP_PANEL_DIR, SP_STICK_DIR + 12
.set SP_TEMP, SP_PANEL_DIR + 12
# regs
.set REG_DATA, 31
.set REG_PANEL, 30
.set REG_TEXT, 29
.set REG_PAD, 27
# floats
.set FREG_STICK_X, 31
.set FREG_STICK_Y, 30
.set FREG_STICK_MAG, 29
.set FREG_INPUT_STRENGTH, 28
.set FREG_SCALE, 27
.set FREG_TRANSLATION, 26
.set FREG_LERP_SPEED, 25
.set FREG_ALIGNMENT, 24
.set FREG_OFST_X, 23
.set FREG_OFST_Y, 22
FN_TextProcess:
  backup
  
  # init data/vars
  lwz REG_DATA, GOBJ_USERDATA(r3)
  lwz REG_PANEL, SRD_JOBJ_PANELS(REG_DATA)
  lwz REG_TEXT, SRD_TEXTS(REG_DATA)
  
  bl TEXT_DATA_BLRL
  mflr REG_DATA
  
  li r3, DEBUG_PAD_UNION  # or use player port
  get_port_pad r3
  mr REG_PAD, r3
  lfs FREG_STICK_X, PAD_stick_x(r3)
  lfs FREG_STICK_Y, PAD_stick_y(r3)
  lfs f0, RTOC_0(rtoc)
  # store stick direction
  stfs FREG_STICK_X, SP_STICK_DIR+X(sp)
  stfs FREG_STICK_Y, SP_STICK_DIR+Y(sp)
  stfs f0, SP_STICK_DIR+Z(sp)
  
  # stick magnitude
  fmuls f0, FREG_STICK_X, FREG_STICK_X
  fmuls f1, FREG_STICK_Y, FREG_STICK_Y
  fadds f0, f0, f1
  fsqrts FREG_STICK_MAG, f0

  # fmr f1, FREG_STICK_MAG
  # logf LOG_LEVEL_ERROR, "Stick magnitude: %f"
  
  # Initialize input_strength to 0
  lfs FREG_INPUT_STRENGTH, RTOC_0(rtoc)

  # panel
  lfs f1, JOBJ_POS+X(REG_PANEL)
  lfs f2, JOBJ_POS+Y(REG_PANEL)
  lfs f3, JOBJ_POS+Z(REG_PANEL)
  stfs f1, SP_PANEL_DIR+X(sp)
  stfs f2, SP_PANEL_DIR+Y(sp)
  stfs f3, SP_PANEL_DIR+Z(sp)
  # normalize
  addi r3, sp, SP_PANEL_DIR
  addi r4, sp, SP_PANEL_DIR
  branchl r12, PSVECNormalize
  
  # stick_mag > 0.001f
  lfs f0, RTOC_0_001(rtoc)
  fcmpo cr0, FREG_STICK_MAG, f0
  ble LERP_AND_TRANSFORM
  
  # normalize stick vector
  addi r3, sp, SP_STICK_DIR
  addi r4, sp, SP_STICK_DIR
  branchl r12, PSVECNormalize
  
  # alignment
  addi r3, sp, SP_STICK_DIR
  addi r4, sp, SP_PANEL_DIR
  branchl r12, PSVECDotProduct
  fmr FREG_ALIGNMENT, f1
  # logf LOG_LEVEL_ERROR, "dot product: %f"
  fmuls FREG_INPUT_STRENGTH, FREG_ALIGNMENT, FREG_STICK_MAG
  lfs f1, RTOC_0(rtoc)
  lfs f2, RTOC_1(rtoc)
  clamp_float FREG_INPUT_STRENGTH, f1, f2
  fmr f1, FREG_INPUT_STRENGTH
  # logf LOG_LEVEL_ERROR, "input_strength: %f"

  LERP_AND_TRANSFORM:
    # current vals
    lfs FREG_SCALE, TXT_SCALE(REG_DATA)
    lfs FREG_TRANSLATION, TXT_TRANS(REG_DATA)

    # lerp vals
    lfs FREG_LERP_SPEED, RTOC_0_5(rtoc)
    fsubs f0, FREG_INPUT_STRENGTH, FREG_SCALE
    fmuls f0, f0, FREG_LERP_SPEED
    fadds FREG_SCALE, FREG_SCALE, f0

    lfs f1, RTOC_1(rtoc)
    fsubs f0, f1, FREG_INPUT_STRENGTH
    fsubs f0, f0, FREG_TRANSLATION
    fmuls f0, f0, FREG_LERP_SPEED
    fadds FREG_TRANSLATION, FREG_TRANSLATION, f0
    # text offsets to so that they align with the panels
    lfs FREG_OFST_X, TXT_OFSTX(REG_DATA)
    lfs FREG_OFST_Y, TXT_OFSTY(REG_DATA)

    # x
    lfs f1, RTOC_10(rtoc)
    fmuls f4, FREG_STICK_X, f1
    lfs f1, RTOC_100(rtoc)
    # fmuls f4, FREG_STICK_X, f1
    lfs f0, SP_PANEL_DIR+X(sp)
    fneg f0, f0
    fmuls f0, f0, FREG_TRANSLATION
    fmuls f0, f0, f1
    fadds f0, f0, FREG_OFST_X
    fsubs f0, f0, f4
    stfs f0, TEXT_TRANS+X(REG_TEXT)
    # y
    lfs f1, RTOC_15(rtoc)
    lfs f0, SP_PANEL_DIR+Y(sp)
    fneg f0, f0
    fmuls f0, f0, FREG_TRANSLATION
    fmuls f0, f0, f1 
    fadds f0, f0, FREG_OFST_Y
    stfs f0, TEXT_TRANS+Y(REG_TEXT)
    # z
    lfs f1, RTOC_100(rtoc)
    fneg f0, f1
    fmuls f2, FREG_SCALE, f1
    fadds f0, f0, f2
    stfs f0, TEXT_TRANS+Z(REG_TEXT)

    stfs FREG_SCALE, TXT_SCALE(REG_DATA)
    stfs FREG_TRANSLATION, TXT_TRANS(REG_DATA)

    # alpha
    lfs f0, RTOC_255(rtoc)
    fmuls f0, FREG_INPUT_STRENGTH, f0
    fctiwz f0, f0
    stfd f0, SP_TEMP(sp)
    lbz r3, SP_TEMP+7(sp)
    stb r3, TEXT_COLOR+A(REG_TEXT)

  
FN_TextProcess_Exit:
  restore
  blr


# Jobj Process
#-----------------------------------------------------------------------------#
FN_UpdatePanel:
blrl
.set REG_GOBJ, 31
.set REG_PANEL, 30
.set REG_DATA, 29
.set REG_DOBJ, 27
# floats
.set FREG_STICK_X, 31
.set FREG_STICK_Y, 30
.set FREG_MAGNITUDE, 29
.set FREG_ALIGNMENT, 28
.set FREG_CURRENT_SCALE, 27
.set FREG_CURRENT_ALPHA, 26
.set FREG_RESET_SPEED, 25
.set FREG_CHANGE_SPEED, 24
# stack
.set SP_STICK_DIR, BKP_FREE_SPACE_OFFSET
.set SP_TO_PANEL, SP_STICK_DIR + 12
.set SP_TEMP, SP_TO_PANEL + 12
  backup
  mr REG_GOBJ, r3
  lwz REG_DATA, GOBJ_USERDATA(REG_GOBJ)

  # get panel
  lwz r3, GOBJ_OBJ(REG_GOBJ)
  addi r4, sp, SP_TEMP
  li r5, IF_PANEL_IDX
  li r6, -1
  branchl r12, HSD_JObjGetChild
  lwz REG_PANEL, SP_TEMP(sp)

  # Get pad input
  li r3, DEBUG_PAD_UNION # TODO :: use the active players port
  get_port_pad r3
  # get_active_pad r3
  lfs FREG_STICK_X, PAD_stick_x(r3)
  lfs FREG_STICK_Y, PAD_stick_y(r3)

  # Create stick direction vector
  stfs FREG_STICK_X, SP_STICK_DIR+X(sp)
  stfs FREG_STICK_Y, SP_STICK_DIR+Y(sp)
  lfs f0, RTOC_0(rtoc)
  stfs f0, SP_STICK_DIR+Z(sp)

  # Copy panel translation to to_panel
  lfs f1, JOBJ_POS+X(REG_PANEL)
  lfs f2, JOBJ_POS+Y(REG_PANEL)
  lfs f3, JOBJ_POS+Z(REG_PANEL)
  stfs f1, SP_TO_PANEL+X(sp)
  stfs f2, SP_TO_PANEL+Y(sp)
  stfs f3, SP_TO_PANEL+Z(sp)

  # Normalize to_panel
  addi r3, sp, SP_TO_PANEL
  addi r4, sp, SP_TO_PANEL
  branchl r12, PSVECNormalize

  # Load static variables
  lfs FREG_CURRENT_SCALE, PD_CURRENT_SCALE(REG_DATA)
  lfs FREG_CURRENT_ALPHA, PD_CURRENT_ALPHA(REG_DATA)

  # Set constants
  load r3, 0x3ecccccd  # 0.4f (reset_speed)
  stw r3, SP_TEMP(sp)
  lfs FREG_RESET_SPEED, SP_TEMP(sp)

  load r3, 0x3f800000  # 1.0f (change_speed) - was 0x3d23d70a (0.04f)
  stw r3, SP_TEMP(sp)
  lfs FREG_CHANGE_SPEED, SP_TEMP(sp)

  # Get stick magnitude
  addi r3, sp, SP_STICK_DIR
  branchl r12, PSVECMag
  fmr FREG_MAGNITUDE, f1

  # Check if magnitude > deadzone threshold
  lfs f0, RTOC_STICKTHRESH(rtoc)
  fcmpo cr0, FREG_MAGNITUDE, f0
  ble RESET_SCALE  # Below deadzone - reset

  # Normalize stick direction
  addi r3, sp, SP_STICK_DIR
  addi r4, sp, SP_STICK_DIR
  branchl r12, PSVECNormalize

  # Calculate alignment
  addi r3, sp, SP_STICK_DIR
  addi r4, sp, SP_TO_PANEL
  branchl r12, PSVECDotProduct
  fmr FREG_ALIGNMENT, f1

  # Check if alignment > 0
  lfs f0, RTOC_0(rtoc)
  fcmpo cr0, FREG_ALIGNMENT, f0
  ble RESET_SCALE  # Negative alignment - reset

  # Set scale directly based on current input: 1.0 + (alignment * magnitude * scale_factor)
  lfs f0, RTOC_1(rtoc)                    # Start with 1.0
  fmuls f1, FREG_ALIGNMENT, FREG_MAGNITUDE  # alignment * magnitude
  fmuls f1, f1, FREG_CHANGE_SPEED          # * scale_factor (maybe increase this value)
  fadds FREG_CURRENT_SCALE, f0, f1         # 1.0 + scaled_input
  fmr FREG_CURRENT_ALPHA, f1               # alpha = just the scaled_input (0 to max)
  b CLAMP_VALUES

RESET_SCALE:
  # current_scale += (1.0 - current_scale) * reset_speed
  lfs f0, RTOC_1(rtoc)
  fsubs f0, f0, FREG_CURRENT_SCALE
  fmuls f0, f0, FREG_RESET_SPEED
  fadds FREG_CURRENT_SCALE, FREG_CURRENT_SCALE, f0

  # current_alpha -= current_alpha * reset_speed  
  fmuls f0, FREG_CURRENT_ALPHA, FREG_RESET_SPEED
  fsubs FREG_CURRENT_ALPHA, FREG_CURRENT_ALPHA, f0

CLAMP_VALUES:
    # Clamp scale (0.1f to 1.5f)
    load r3, 0x3dcccccd  # 0.1f
    stw r3, SP_TEMP(sp)
    lfs f1, SP_TEMP(sp)
    # load r3, 0x3fc00000  # 1.5f
    # stw r3, SP_TEMP(sp)
    lfs f2, RTOC_2(rtoc)
    clamp_float FREG_CURRENT_SCALE, f1, f2

    # Clamp alpha
    lfs f1, RTOC_0(rtoc)
    lfs f2, RTOC_0_75(rtoc)
    clamp_float FREG_CURRENT_ALPHA, f1, f2

    # Set panel scale
    stfs FREG_CURRENT_SCALE, JOBJ_SCALE+X(REG_PANEL)
    stfs FREG_CURRENT_SCALE, JOBJ_SCALE+Y(REG_PANEL)
    stfs FREG_CURRENT_SCALE, JOBJ_SCALE+Z(REG_PANEL)

  # Set alpha for all dobjs
  lwz REG_DOBJ, JOBJ_DOBJ(REG_PANEL)
  DOBJ_ALPHA_LOOP:
    cmpwi REG_DOBJ, 0
    beq DOBJ_ALPHA_DONE
    lwz r3, 0x8(REG_DOBJ)
    cmpwi r3, 0
    beq DOBJ_ALPHA_NEXT
    fmr f1, FREG_CURRENT_ALPHA
    branchl r12, HSD_MObjSetAlpha
  DOBJ_ALPHA_NEXT:
    lwz REG_DOBJ, 0x4(REG_DOBJ)
    b DOBJ_ALPHA_LOOP
  DOBJ_ALPHA_DONE:

  # Set matrix dirty
  mr r3, REG_PANEL
  branchl r12, HSD_JObjSetMtxDirty

  # fmr f1, FREG_CURRENT_SCALE
  # fmr f2, FREG_CURRENT_ALPHA
  # logf LOG_LEVEL_ERROR, "SCALE: %f, ALPHA: %f"

  stfs FREG_CURRENT_SCALE, PD_CURRENT_SCALE(REG_DATA)
  stfs FREG_CURRENT_ALPHA, PD_CURRENT_ALPHA(REG_DATA)

FN_UpdatePanel_Exit:
  restore
  blr




# Main exit
#=============================================================================#

EXIT:
  restore
  lis	r4, 0x8040
