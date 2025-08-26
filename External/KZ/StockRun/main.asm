################################################################################
# Address: 0x8016e8c8
# StartMelee after InitOnlinePlay has run but before standard Slippi stuff
################################################################################

.include "./StockRun.s"
.include "Common/Common.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/HSD_COBJ.s"
.include "External/KZ/MATCH.s"
.include "External/KZ/PLAYER.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_PAD.s"
.include "External/KZ/OS.s"

# Initialize Stock Run
#==============================================================================#
b CODE_START

DATA_BLRL:
blrl
# StockRun Context
.set SRC_SLOT_ORDER, 0                              # int[2]
.set SRC_CURRENT_PICKER, SRC_SLOT_ORDER + 8         # int
.set SRC_TRANSITION_TIMER, SRC_CURRENT_PICKER + 4   # int
.set SRC_GAME_STATE, SRC_TRANSITION_TIMER + 4       # int
.set SRC_ACTIVE_SLOT, SRC_GAME_STATE + 4            # int
.set SRC_HOVER_STATE, SRC_ACTIVE_SLOT + 4           # int
.long -1
.long -1
.long 0
.long TRANSITION_FRAMES
.long 0
.long 0
.long 0

CODE_START:
  .set REG_GOBJ, 31
  .set REG_DATA, 30
  .set REG_COUNT, 29
  .set REG_PLY_COUNT, 28
  .set REG_COLOR, 27
  .set REG_PANEL, 26
  backup

  bl DATA_BLRL
  mflr REG_DATA

# create gobj to run our in-game code
# ui class - so when we freeze players, code still runs
  gobj_create GOBJ_CLASS_UI, GOBJ_PLINK_UI, SR_GOBJ_PRIO, REG_GOBJ
  load r3, stc_sr_data
  stw REG_GOBJ, SRD_GOBJ_INIT(r3)

# add proc
  mr r3, REG_GOBJ
  bl StockRun_UpdateBLRL
  mflr r4
  li r5, 0
  branchl r12, GObj_AddProc

# add data
  mr r3, REG_GOBJ
  li r4, 0
  li r5, 0
  mr r6, REG_DATA
  branchl r12, GObj_AddUserData

  bl SR_InitContext

# disable pause
  load r12, stc_match_info
  addi r12, r12, OFST_RULES
  lbz r3, OFST_PAUSE(r12)
  ori r3, r3, PAUSE_BIT_MASK
  stb r3, OFST_PAUSE(r12)

# disable hud
  load r3, stc_hud_vis
  li r4, TRUE 
  stb r4, 0(r3)

# get slot order
  li REG_COUNT, 0
  li REG_PLY_COUNT, 0
  SET_ACTIVE_SLOTS_LOOP:
    mr r3, REG_COUNT
    branchl r12, PlayerBlock_GetSlotType
    cmpwi r3, 1 # if slot is HMN or CPU
    bgt SET_ACTIVE_SLOT_LOOP_CHECK

    cmpwi REG_PLY_COUNT, MAX_PLAYERS # we should only be in direct or have two players
    bgt SET_ACTIVE_SLOT_LOOP_CHECK
    mulli r4,REG_PLY_COUNT, 4
    stwx REG_COUNT, r4, REG_DATA # port order
    addi REG_PLY_COUNT, REG_PLY_COUNT, 1

  SET_ACTIVE_SLOT_LOOP_CHECK:
    addi REG_COUNT, REG_COUNT, 1
    cmpwi REG_COUNT, MAX_PORTS
    blt SET_ACTIVE_SLOTS_LOOP

# store opponent port
    lwz r3, SRC_SLOT_ORDER(REG_DATA)
    branchl r12, PlayerBlock_GetGObj
    lwz r3, GOBJ_USERDATA(r3)
    addi r3, r3, FT_SRP_OFST
    lwz r4, SRC_SLOT_ORDER+4(REG_DATA)
    stw r4, SRP_OPP_SLOT(r3)

    lwz r3, SRC_SLOT_ORDER+4(REG_DATA)
    branchl r12, PlayerBlock_GetGObj
    lwz r3, GOBJ_USERDATA(r3)
    addi r3, r3, FT_SRP_OFST
    lwz r4, SRC_SLOT_ORDER(REG_DATA)
    stw r4, SRP_OPP_SLOT(r3)
    

# setup camera blur
  load r3, 0x80472d28
  li r4, 288
  branchl r12, memzero # zero out the imagedesc mem
  
  load r3, stc_blur_imagedesc
  li r4, 640
  li r5, 480
  li r6, 5
  li r7, 0
  branchl r12, 0x800121fc

  lfs f1, RTOC_0(rtoc)
  lfs f2, RTOC_0(rtoc)
  lfs f3, RTOC_1(rtoc)
  lfs f4, RTOC_1(rtoc)
  load r3, stc_blur_imagedesc
  li r4, 0
  li r5, 2
  li r6, 50
  branchl r12, 0x800138ec
  mr REG_GOBJ, r3
  load r3, 0x80472d54
  stw REG_GOBJ, 0(r3)

  mr r3, REG_GOBJ
  li r4, 1
  branchl r12, 0x800138d8

  mr r3, REG_GOBJ
  load r4, 0x8017fe54
  branchl r12, 0x800138cc

# setup panel colours
  li REG_COUNT, 0
  get_panel_color REG_COLOR
  load REG_PANEL, stc_sr_data
  addi REG_PANEL, REG_PANEL, SRD_JOBJ_PANELS
  SET_PANEL_COLORS:
    mulli r0, REG_COUNT, 4
    lwzx r3, REG_PANEL, r0
    branchl r12, HSD_JObjGetDObj
    lwz r3, 0x4(r3)
    lwz r3, 0x4(r3)
    lwz r3, 0x8(r3) # mobj
    lbz r4, R(REG_COLOR)
    lbz r5, G(REG_COLOR)
    lbz r6, B(REG_COLOR)
    lbz r7, A(REG_COLOR)
    branchl r12, HSD_MObjSetDiffuseColor
  SET_PANEL_COLORS_CHECK:
    addi REG_COUNT, REG_COUNT, 1
    cmpwi REG_COUNT, 4
    blt SET_PANEL_COLORS

# set stocks
  li REG_COUNT, 0
  SET_STOCKS_LOOP:
    rlwinm r0, REG_COUNT, 2, 0, 29
    lwzx r3, REG_DATA, r0
    li r4, SR_STOCK_COUNT
    branchl r12, PlayerBlock_SetStocks
  
  SET_STOCKS_LOOP_CHECK:
    addi REG_COUNT, REG_COUNT, 1
    cmpwi REG_COUNT, 2
    blt SET_STOCKS_LOOP

  b EXIT

#==============================================================================#


################################################################################
# Functions
################################################################################


# data destructor
#==============================================================================#
.set REG_DATA, 30
SR_InitContext:
  bklr

  li r3, -1
  stw r3, SRC_ACTIVE_SLOTS(REG_DATA)
  stw r3, SRC_ACTIVE_SLOTS+4(REG_DATA)
  load r3, TRANSITION_FRAMES
  stw r3, SRC_TRANSITION_FRAMES(REG_DATA)
  li r3, 0
  stw r3, SRC_CURRENT_PICKER(REG_DATA)
  stw r3, SRC_GAME_STATE(REG_DATA)
  stw r3, SRC_HOVER_STATE(REG_DATA)
  # load r3, stc_sr_plydata
  # li r4, SRP_SIZE
  # mulli r4, r4, 4
  # branchl r12, memzero

  # logf LOG_LEVEL_ERROR, "SR Data Reset"

SR_InitContext_Exit:
  rslr
  blr


# Main loop
#==============================================================================#
StockRun_UpdateBLRL:
blrl
.set REG_GOBJ, 31
.set REG_DATA, 30
.set REG_FRAME, 29
.set REG_STATE, 28
.set REG_PICKER, 27
SR_Update:
  backup

  # init vars
  mr REG_GOBJ, r3
  lwz REG_DATA, GOBJ_USERDATA(REG_GOBJ)
  load_scene_frame REG_FRAME
  lwz REG_STATE, SRC_GAME_STATE(REG_DATA)

  cmpwi REG_FRAME, SETUP_START_FRAME # first frame after entry
  blt SR_Update_Exit
  cmpwi REG_FRAME, ALLOW_INPUTS_FRAME 
  bgt STATE_SWITCH # this is so we can start our blur

  # add blur until we can input
  load r3, stc_blur_amt
  lfs f1, 0(r3)
  lfs f0, RTOC_0_015625(rtoc)
  fadds f1, f1, f0
  stfs f1, 0(r3) # blur
  stfs f1, 4(r3) # tint

  STATE_SWITCH:
    STATE_INIT:
    cmpwi REG_STATE, SRGS_INIT
    bne STATE_CARD_SELECT
      bl SR_InitCardSelect
      # update state
      li r3, SRGS_TRANSITION
      stw r3, SRC_GAME_STATE(REG_DATA)
      b SR_Update_Exit
    
    STATE_CARD_SELECT:
    cmpwi REG_STATE, SRGS_CARD_SELECT
    bne STATE_TRANSITION
      bl SR_IsSelectionComplete
      cmpwi r3, TRUE
      bne _INPUT
      bl SR_EndCardSelect
      b SR_Update_Exit
      # run input
      _INPUT:
      bl SR_ProcessInput
      b SR_Update_Exit

    STATE_TRANSITION:
    cmpwi REG_STATE, SRGS_TRANSITION
    bne STATE_GAME_ACTIVE
      lwz r3, SRC_TRANSITION_TIMER(REG_DATA)
      subi r3, r3, 1
      stw r3, SRC_TRANSITION_TIMER(REG_DATA)
      cmpwi r3, 0
      bgt SR_Update_Exit
      li r3, SRGS_CARD_SELECT
      stw r3, SRC_GAME_STATE(REG_DATA)
      b SR_Update_Exit

    STATE_GAME_ACTIVE:
    cmpwi REG_STATE, SRGS_GAME_ACTIVE
    bne STATE_GAME_TRANSITION
      # could do run logic here if needed
      b SR_Update_Exit

    STATE_GAME_TRANSITION:
    cmpwi REG_STATE, SRGS_GAME_TRANSITION
    bne STATE_GAME_CARD_SELECT
      load r3, stc_blur_amt
      lfs f1, 0(r3)
      lfs f0, RTOC_0_015625(rtoc)
      fadds f1, f1, f0
      stfs f1, 0(r3) # blur
      stfs f1, 4(r3) # tint

      lwz r3, SRC_TRANSITION_TIMER(REG_DATA)
      subi r3, r3, 1
      stw r3, SRC_TRANSITION_TIMER(REG_DATA)
      cmpwi r3, 0
      bgt SR_Update_Exit

      li r3, SRGS_GAME_CARD_SELECT
      stw r3, SRC_GAME_STATE(REG_DATA)
      bl SR_UpdatePanelColor
      b SR_Update_Exit

    STATE_GAME_CARD_SELECT:
    cmpwi REG_STATE, SRGS_GAME_CARD_SELECT
    bne SR_Update_Exit
      bl SR_ProcessInput
      b SR_Update_Exit

SR_Update_Exit:
  restore
  blr


# Card Select Functions
#==============================================================================#
SR_InitCardSelect:
  bklr

  # pause players
  li r3, MATCH_FREEZE_FLAG # freezes players but not cameras/ui
  branchl r12, Scene_SetPauseFlag

  # init camera
  bl SR_SetupCamera
  bl SR_UpdateCameraPos

SR_InitCardSelect_Exit:
  rslr
  blr

#------------------------------------------------------------------------------#

SR_IsSelectionComplete:
  bklr

  li r3, FALSE
  lwz r4, SRC_CURRENT_PICKER(REG_DATA)
  cmpwi r4, MAX_PLAYERS - 1
  ble SR_IsSelectionComplete_Exit

  # enable hud
  load r3, stc_hud_vis
  li r4, FALSE 
  stb r4, 0(r3)

  # reset blur
  load r3, stc_blur_amt
  li r4, 0
  stw r4, 0(r3)
  stw r4, 4(r3) # tint

  # update state
  li r3, SRGS_GAME_ACTIVE
  stw r3, SRC_GAME_STATE(REG_DATA)
  li r3, TRUE

SR_IsSelectionComplete_Exit:
  rslr
  blr

#------------------------------------------------------------------------------#

SR_EndCardSelect:
  bklr

  # unpause
  li r3, MATCH_FREEZE_FLAG
  branchl r12, Scene_ClearPauseFlag

  # reset camera
  branchl r12, Camera_SetNormal

SR_EndCardSelect_Exit:
  rslr
  blr

#------------------------------------------------------------------------------#

SR_ProcessInput:
.set REG_HOVER_STATE, 16
.set REG_PAD, 17
# floats
.set FREG_STICK_MAG, 15
.set FREG_STICK_X, 16
.set FREG_STICK_Y, 17
# stack
.set SP_STICK_DIR, BKP_FREE_SPACE_OFFSET
  backup

  lwz REG_HOVER_STATE, SRC_HOVER_STATE(REG_DATA)

  # bl SR_GetCurrentPlayerSlot
  # cmpwi r3, -1
  # beq SR_ProcessInput_Exit
  # mr r3, REG_PAD
  # check if we are actually hovering a card
  # li REG_PAD, DEBUG_PAD_UNION # TODO :: use the active players port
  # get_port_pad REG_PAD
  get_active_pad REG_PAD
  lfs FREG_STICK_X, PAD_stick_x(REG_PAD)
  lfs FREG_STICK_Y, PAD_stick_y(REG_PAD)
  # create our stick dir
  stfs FREG_STICK_X, SP_STICK_DIR+X(sp)
  stfs FREG_STICK_Y, SP_STICK_DIR+Y(sp)
  lfs f0, RTOC_0(rtoc)
  stfs f0, SP_STICK_DIR+Z(sp)
  # stick magnitude
  addi r3, sp, SP_STICK_DIR
  branchl r12, PSVECMag
  fmr FREG_STICK_MAG, f1
  # fmr f1, FREG_STICK_MAG
  # logf LOG_LEVEL_ERROR, "Stick magnitude: %f"

  lfs f0, RTOC_0_95(rtoc)
  fcmpo cr0, FREG_STICK_MAG, f0
  ble ON_UNHOVER

  lwz r3, PAD_buttons(REG_PAD)
  lwz r4, PAD_last_button(REG_PAD)
  xor r5, r3, r4
  load r6, PAD_BTN_StickUp | PAD_BTN_StickDown | PAD_BTN_StickLeft | PAD_BTN_StickRight
  and r7, r5, r6
  cmpwi r7, 0
  bne PLAY_HOVER_SFX

  # check if we werent already hovering
  cmpwi REG_HOVER_STATE, FALSE
  bne SKIP_SOUND

  PLAY_HOVER_SFX:
    li r3, SFX_CMN_SELECT
    branchl r12, SFX_Menu_CommonSound

  SKIP_SOUND:
    li REG_HOVER_STATE, TRUE
    stw REG_HOVER_STATE, SRC_HOVER_STATE(REG_DATA)
    b CHECK_BUTTON

  ON_UNHOVER:
    cmpwi REG_HOVER_STATE, TRUE
    bne CHECK_BUTTON
    li REG_HOVER_STATE, FALSE
    stw REG_HOVER_STATE, SRC_HOVER_STATE(REG_DATA)

  CHECK_BUTTON:
      lwz r4, PAD_button_pressed(REG_PAD)
      andi. r4, r4, PAD_BTN_A
      bne CHOOSE_CARD
      b SR_ProcessInput_Exit

  CHOOSE_CARD:
    cmpwi REG_HOVER_STATE, FALSE
    beq NOT_ACTIVE_CARD_SFX

    # success
    li r3, SFX_CMN_CONFIRM
    branchl r12, SFX_Menu_CommonSound

    bl SR_SelectCard
    b SR_ProcessInput_Exit

    NOT_ACTIVE_CARD_SFX:
      li r3, SFX_CMN_ERROR
      branchl r12, SFX_Menu_CommonSound

SR_ProcessInput_Exit:
  restore
  blr

#------------------------------------------------------------------------------#

SR_SelectCard:
.set REG_COUNT, 16
.set REG_CARDS, 17
.set REG_TEXT, 18
.set REG_RNG, 19
.set REG_FP, 20
  backup
  # get fighter data
  lwz r3, SRC_ACTIVE_SLOT(REG_DATA)
  branchl r12, PlayerBlock_GetGObj
  lwz REG_FP, GOBJ_USERDATA(r3)

  # check which card we picked
  get_active_pad REG_PAD
  lwz r3, PAD_buttons(REG_PAD)
  li r4, 0
  load r5, PAD_BTN_StickUp
  and. r0, r3, r5
  bne POST_CARD_SELECT
  li r4, 1
  load r5, PAD_BTN_StickRight
  and. r0, r3, r5
  bne POST_CARD_SELECT
  li r4, 2
  load r5, PAD_BTN_StickDown
  and. r0, r3, r5
  bne POST_CARD_SELECT
  li r4, 3
  load r5, PAD_BTN_StickLeft
  and. r0, r3, r5
  bne POST_CARD_SELECT
  # b 0x0 # shouldnt get here

  POST_CARD_SELECT:
    load r6, stc_sr_data
    addi r6, r6, SRD_CURRENT_CARDS
    mulli r0, r4, 4
    lwzx r4, r6, r0 # card we selected

    addi r6, REG_FP, FT_SRP_OFST # current player data 
    lwz r0, SRP_CARDS(r6)   # r0 = current card bits
    li r5, 1                # create bitmask
    slw r5, r5, r4          # shift 1 left by r4 positions (r4 = card to set)
    or r0, r0, r5           # set the bit
    stw r0, SRP_CARDS(r6)   # store back

    # run the card apply callback
    li r3, TRUE
    stw r3, SRP_APPLY_CARD(r6)


  UPDATE_STATE:
    lwz r3, SRC_GAME_STATE(REG_DATA)
    cmpwi r3, SRGS_GAME_CARD_SELECT
    beq MID_GAME_UPDATE

    # roll cards
    backup_rng REG_RNG
    li r3, CARD_COUNT
    load r4, stc_sr_data
    addi REG_CARDS, r4, SRD_CURRENT_CARDS
    mr r4, REG_CARDS
    lwz r5, SRC_ACTIVE_SLOT(REG_DATA)
    branchl r12, StockRun_RandomizeCards
    restore_rng REG_RNG

    # set text
    li REG_COUNT, 0
    load r5, stc_sr_data
    addi REG_TEXT, r5, SRD_TEXTS
    SET_TEXT_LOOP:
      rlwinm r0, REG_COUNT, 2, 0, 29
      lwzx r3, REG_TEXT, r0
      lwzx r4, REG_CARDS, r0
      branchl r12, Text_SetFromSIS
    SET_TEXT_LOOP_CHECK:
      addi REG_COUNT, REG_COUNT, 1
      cmpwi REG_COUNT, 4
      blt SET_TEXT_LOOP

    lwz REG_PICKER, SRC_CURRENT_PICKER(REG_DATA)
    addi REG_PICKER, REG_PICKER, 1
    stw REG_PICKER, SRC_CURRENT_PICKER(REG_DATA)
    
    bl SR_UpdateCameraTarget
    bl SR_UpdateCameraPos
    bl SR_UpdatePanelColor

    lwz r4, SRC_CURRENT_PICKER(REG_DATA)
    cmpwi r4, MAX_PLAYERS
    beq SR_SelectCard_Exit

    li r3, TRANSITION_FRAMES
    stw r3, SRC_TRANSITION_TIMER(REG_DATA)
    li r3, SRGS_TRANSITION
    stw r3, SRC_GAME_STATE(REG_DATA)
    b SR_SelectCard_Exit

  MID_GAME_UPDATE:
    bl SR_EndCardSelect

    # enable hud
    load r3, stc_hud_vis
    li r4, FALSE 
    stb r4, 0(r3)

    # reset blur
    load r3, stc_blur_amt
    li r4, 0
    stw r4, 0(r3)
    stw r4, 4(r3) # tint

    # reset game state
    li r3, SRGS_GAME_ACTIVE
    stw r3, SRC_GAME_STATE(REG_DATA)


SR_SelectCard_Exit:
  restore
  blr


# Camera Functions
#==============================================================================#
SR_SetupCamera:
  bklr

  load r3, stc_mode3_vars
  lfs f1, RTOC_0_1(rtoc)
  stfs f1, 0(r3)
  # lerp settings
  lfs f1, OFST_TINT(r3)
  stfs f1, OFST_TEYE(r3)
  load r4, CAM_ZOOM # 10.0
  stw r4, OFST_FOV(r3)
  
  lwz r3, SRC_SLOT_ORDER(REG_DATA) # lowest port goes first
  branchl r12, Camera_SetMode3

  lwz r3, SRC_SLOT_ORDER(REG_DATA)
  load r4, stc_pause_data
  stw r3, PAUSE_UI_SLOT(r4)

SR_SetupCamera_Exit:
  rslr
  blr

#------------------------------------------------------------------------------#

SR_UpdateCameraPos:
  backup

  # get the current player
  bl SR_GetCurrentPlayerSlot
  cmpwi r3, -1
  beq SR_UpdateCameraPos_Exit

  # get the pos
  branchl r12, PlayerBlock_GetGObj
  addi r4, sp, BKP_FREE_SPACE_OFFSET
  branchl r12, Player_GetPosition

  # set pan/tilt based on where the player is
  load r3, 0x80452f30 # offset y
  lfs f1, RTOC_STICKTHRESH(rtoc) # 0.2
  stfs f1, 0(r3)

  lfs f1, BKP_FREE_SPACE_OFFSET(sp) # x
  lfs f0, RTOC_0(rtoc)
  fcmpo cr0, f1, f0
  bge RIGHT_SIDE

  LEFT_SIDE:
    load r3, 0x80452f34 # offset x
    lfs f1, RTOC_0_5(rtoc)
    stfs f1, 0(r3) # pan/tilt camera left
    b SR_UpdateCameraPos_Exit

  RIGHT_SIDE:
    load r3, 0x80452f34
    lfs f1, RTOC_0_5(rtoc)
    fneg f1, f1
    stfs f1, 0(r3) # pan/tilt camera right

SR_UpdateCameraPos_Exit:
  restore
  blr

#------------------------------------------------------------------------------#

SR_UpdateCameraTarget:
  bklr

  # get current player
  bl SR_GetCurrentPlayerSlot
  cmpwi r3, -1
  beq SR_UpdateCameraTarget_Exit

  load r4, 0x80452f2c # mode 3 slot
  stb r3, 0(r4)
  load r4, stc_pause_data
  stw r3, PAUSE_UI_SLOT(r4)

SR_UpdateCameraTarget_Exit:
  rslr
  blr


# Utility Functions
#==============================================================================#
SR_GetCurrentPlayerSlot:
# return r3 = current player
  bklr

  lwz r3, SRC_CURRENT_PICKER(REG_DATA)
  cmpwi r3, MAX_PLAYERS
  bge INVALID_CURR_PICKER

  mulli r4, r3, 4
  lwzx r3, r4, REG_DATA # SRC_SLOT_ORDER
  stw r3, SRC_ACTIVE_SLOT(REG_DATA)
  b SR_GetCurrentPlayerSlot_Exit

  INVALID_CURR_PICKER:
    li r3, -1
    rslr
    blr

SR_GetCurrentPlayerSlot_Exit:
  rslr
  blr

#------------------------------------------------------------------------------#

SR_UpdatePanelColor:
.set REG_COUNT, 31
.set REG_COLOR, 30
.set REG_PANEL, 29
  backup

    li REG_COUNT, 0
    get_panel_color REG_COLOR
    load REG_PANEL, stc_sr_data
    addi REG_PANEL, REG_PANEL, SRD_JOBJ_PANELS
    UPDATE_PANEL_COLORS:
      mulli r0, REG_COUNT, 4
      lwzx r3, REG_PANEL, r0
      branchl r12, HSD_JObjGetDObj
      lwz r3, 0x4(r3)
      lwz r3, 0x4(r3)
      lwz r3, 0x8(r3) # mobj
      lbz r4, R(REG_COLOR)
      lbz r5, G(REG_COLOR)
      lbz r6, B(REG_COLOR)
      lbz r7, A(REG_COLOR)
      branchl r12, HSD_MObjSetDiffuseColor
    UPDATE_PANEL_COLORS_CHECK:
      addi REG_COUNT, REG_COUNT, 1
      cmpwi REG_COUNT, 4
      blt UPDATE_PANEL_COLORS

SR_UpdatePanelColor_Exit:
  restore
  blr

#==============================================================================#
# Main Exit
#==============================================================================#

EXIT:
  restore
  lwz	r12, 0x0044 (r31)
