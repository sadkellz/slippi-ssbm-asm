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
.long -1
.long -1
.long 0
.long TRANSITION_FRAMES
.long 0

CODE_START:
  .set REG_GOBJ, 31
  .set REG_DATA, 30
  .set REG_COUNT, 29
  .set REG_PLY_COUNT, 28
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
  # load r12, stc_match_info
  # addi r12, r12, OFST_RULES
  # lbz r3, OFST_PAUSE(r12)
  # ori r3, r3, PAUSE_BIT_MASK
  # stb r3, OFST_PAUSE(r12)

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

  b EXIT

#==============================================================================#


################################################################################
# Functions
################################################################################


# data destructor
#==============================================================================#
.set REG_DATA, 30
SR_InitContext:
  backup

  li r3, -1
  stw r3, SRC_ACTIVE_SLOTS(REG_DATA)
  stw r3, SRC_ACTIVE_SLOTS+4(REG_DATA)
  load r3, TRANSITION_FRAMES
  stw r3, SRC_TRANSITION_FRAMES(REG_DATA)
  li r3, 0
  stw r3, SRC_CURRENT_PICKER(REG_DATA)
  stw r3, SRC_GAME_STATE(REG_DATA)

  logf LOG_LEVEL_ERROR, "SR Data Reset"

SR_InitContext_Exit:
  restore
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
    bne SR_Update_Exit
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
  bklr
  # lwz r3, SRC_GAME_STATE(REG_DATA)
  # cmpwi r3, SRGS_TRANSITION
  # beq SR_ProcessInput_Exit

  lwz r3, SR_GetCurrentPlayerSlot(REG_DATA)
  cmpwi r3, -1
  beq SR_ProcessInput_Exit

  li r3, DEBUG_PAD_UNION # TODO :: use picker slot instead
  branchl r12, Inputs_GetPlayerInstantInputs
  andi. r4, r4, PAD_BTN_A
  bne CHOOSE_CARD
  b SR_ProcessInput_Exit

  CHOOSE_CARD:
    bl SR_SelectCard

SR_ProcessInput_Exit:
  rslr
  blr

#------------------------------------------------------------------------------#

SR_SelectCard:
  bklr

  # implement select logic
  # ...

  lwz REG_PICKER, SRC_CURRENT_PICKER(REG_DATA)
  addi REG_PICKER, REG_PICKER, 1
  stw REG_PICKER, SRC_CURRENT_PICKER(REG_DATA)
  
  bl SR_UpdateCameraTarget
  bl SR_UpdateCameraPos


  lwz r4, SRC_CURRENT_PICKER(REG_DATA)
  cmpwi r4, MAX_PLAYERS
  beq SR_SelectCard_Exit

  li r3, TRANSITION_FRAMES
  stw r3, SRC_TRANSITION_TIMER(REG_DATA)
  li r3, SRGS_TRANSITION
  stw r3, SRC_GAME_STATE(REG_DATA)

SR_SelectCard_Exit:
  rslr
  blr


# Camera Functions
#==============================================================================#
SR_SetupCamera:
  bklr

  load r3, stc_mode3_vars
  # lerp settings
  lfs f1, OFST_TINT(r3)
  stfs f1, OFST_TEYE(r3)
  load r4, CAM_ZOOM # 10.0
  stw r4, OFST_FOV(r3)
  
  lwz r3, SRC_SLOT_ORDER(REG_DATA) # lowest port goes first
  branchl r12, Camera_SetMode3

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
  lfs f0, RTOC_ZERO(rtoc)
  fcmpo cr0, f1, f0
  bge RIGHT_SIDE

  LEFT_SIDE:
    load r3, 0x80452f34 # offset x
    lfs f1, RTOC_HALF(rtoc)
    stfs f1, 0(r3) # pan/tilt camera left
    b SR_UpdateCameraPos_Exit

  RIGHT_SIDE:
    load r3, 0x80452f34
    lfs f1, RTOC_HALF(rtoc)
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
  b SR_GetCurrentPlayerSlot_Exit

  INVALID_CURR_PICKER:
    li r3, -1
    rslr
    blr

SR_GetCurrentPlayerSlot_Exit:
  rslr
  blr

#==============================================================================#
# Main Exit
#==============================================================================#

EXIT:
  restore
  lwz	r12, 0x0044 (r31)
