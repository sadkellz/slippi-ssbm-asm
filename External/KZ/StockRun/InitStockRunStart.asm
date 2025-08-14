################################################################################
# Address: 0x8016e8c8
# StartMelee after InitOnlinePlay has run but before standard Slippi stuff
################################################################################

.include "Common/Common.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/HSD_COBJ.s"
.include "External/KZ/MATCH.s"
.include "External/KZ/PLAYER.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_PAD.s"

b CODE_START

# Constants
.set PAUSE_BIT_MASK, 0x08
.set OFST_RULES, 0x24C0
.set OFST_PAUSE, 0xA # bitfield in rules
.set MATCH_FREEZE_FLAG, 4 # wont freeze cameras/ui
.set CAM_ZOOM, 0x41200000  # 10.0 as float
.set SETUP_START_FRAME, 64 # first frame after entry
.set ALLOW_INPUTS_FRAME, 144 # just as the camera settles
.set TRANSITION_FRAMES, 80 # same amt of time as the initial transition for the 2nd picker
.set MAX_PLAYERS, 2 # not supporting teams/ffa
.set MAX_PORTS, 4
.set DEBUG_PAD_UNION, 4  # will return if anyone presses a button

DATA_BLRL:
blrl
.set ACTIVE_SLOTS, 0
.byte -1, -1
.align 2
.set ACTIVE_PICKER, ACTIVE_SLOTS + 4
.long 0
.set TRANSITION_TIMER, ACTIVE_PICKER + 4
.long TRANSITION_FRAMES

CODE_START:
  .set REG_GOBJ, 31
  .set REG_DATA, 30
  .set REG_COUNT, 29
  .set REG_PLY_NUM, 28
  backup

  bl DATA_BLRL
  mflr REG_DATA

# create gobj to run our in-game code
# ui so when we freeze players, code still runs
  gobj_create GOBJ_CLASS_UI, GOBJ_PLINK_UI, 111, REG_GOBJ

# add proc
  mr r3, REG_GOBJ
  bl FN_RogueSetupBLRL
  mflr r4
  li r5, 0
  branchl r12, GObj_AddProc

# add data
  mr r3, REG_GOBJ
  li r4, 0
  li r5, 0
  mr r6, REG_DATA
  branchl r12, GObj_AddUserData

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

# set active slots
  li REG_COUNT, 0
  li REG_PLY_NUM, 0
  SET_ACTIVE_SLOTS_LOOP:
    mr r3, REG_COUNT
    branchl r12, PlayerBlock_GetSlotType
    cmpwi r3, 1
    bgt SET_ACTIVE_SLOT_LOOP_CHECK

    cmpwi REG_PLY_NUM, MAX_PLAYERS # we should only be in direct or have two players
    bgt SET_ACTIVE_SLOT_LOOP_CHECK
    stbx REG_COUNT, REG_PLY_NUM, REG_DATA # active slots
    addi REG_PLY_NUM, REG_PLY_NUM, 1

  SET_ACTIVE_SLOT_LOOP_CHECK:
    addi REG_COUNT, REG_COUNT, 1
    cmpwi REG_COUNT, MAX_PORTS
    blt SET_ACTIVE_SLOTS_LOOP

  b EXIT

################################################################################
################################################################################
FN_RogueSetupBLRL:
blrl
.set REG_GOBJ, 31
.set REG_DATA, 30
.set REG_SLOT, 29
.set REG_FRAME, 28
FN_RogueSetup:
  backup

  mr REG_GOBJ, r3
  lwz REG_DATA, GOBJ_USERDATA(REG_GOBJ)
  load_scene_frame REG_FRAME
  cmpwi REG_FRAME, SETUP_START_FRAME # first frame after entry
  blt FN_Exit
  cmpwi REG_FRAME, ALLOW_INPUTS_FRAME # users are now active
  bge POST_SETUP

  li r3, MATCH_FREEZE_FLAG # freezes players but not cameras/ui
  branchl r12, Scene_SetPauseFlag

# zoom in on first active player to start card picks
  load r3, stc_mode3_vars
  # lerp settings
  lfs f1, OFST_TINT(r3)
  stfs f1, OFST_TEYE(r3)
  load r4, CAM_ZOOM # 10.0
  stw r4, OFST_FOV(r3)

  lbz r3, ACTIVE_SLOTS(REG_DATA)
  mr REG_SLOT, r3
  branchl r12, Camera_SetMode3

  # init camera side to first active player
  # this will be updated elsewhere
  bl FN_SetCameraSide
  b FN_Exit

POST_SETUP:
  # check if picks are done
  lwz r3, ACTIVE_PICKER(REG_DATA)
  cmpwi r3, MAX_PLAYERS
  bge RESUME_MATCH

  # check inputs
  bl FN_InputThink
  b FN_Exit

RESUME_MATCH:
  # unpause
  li r3, MATCH_FREEZE_FLAG
  branchl r12, Scene_ClearPauseFlag

  # reset camera
  branchl r12, Camera_SetNormal

FN_Exit:
  restore
  blr

################################################################################
# make sure REG_SLOT and REG_DATA are set before calling this
FN_SetCameraSide:
  backup
  lbzx r3, REG_SLOT, REG_DATA
  branchl r12, PlayerBlock_GetGObj
  
  addi r4, sp, BKP_FREE_SPACE_OFFSET
  branchl r12, Player_GetPosition

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
    b FN_SetCameraSide_Exit

  RIGHT_SIDE:
    load r3, 0x80452f34
    lfs f1, RTOC_HALF(rtoc)
    fneg f1, f1
    stfs f1, 0(r3) # pan/tilt camera right

FN_SetCameraSide_Exit:
  restore
  blr

################################################################################
FN_InputThink:
  backup
  # get the active picker
  lwz r3, ACTIVE_PICKER(REG_DATA)
  cmpwi r3, MAX_PLAYERS # there are only two players
  beq FN_InputThink_Exit
  cmpwi r3, 1 # if we are on the second picker, we need to wait for the transition to finish
  bne LOAD_ACTIVE_PICKER

  lwz r4, TRANSITION_TIMER(REG_DATA)
  cmpwi r4, 0
  beq LOAD_ACTIVE_PICKER
  subi r4, r4, 1
  stw r4, TRANSITION_TIMER(REG_DATA)
  b FN_InputThink_Exit

  LOAD_ACTIVE_PICKER:
  lbzx REG_SLOT, REG_DATA, r3 # get the slot of the active picker

  # check if we have picked a card
  # mr r3, REG_SLOT
  li r3, DEBUG_PAD_UNION
  branchl r12, Inputs_GetPlayerInstantInputs
  andi. r4, r4, PAD_BTN_A
  bne CHOOSE_CARD
  b FN_InputThink_Exit

  CHOOSE_CARD:
    # increment the active picker
    lwz r3, ACTIVE_PICKER(REG_DATA)
    addi r3, r3, 1
    stw r3, ACTIVE_PICKER(REG_DATA)

    lbzx REG_SLOT, REG_DATA, r3
    bl FN_SetCameraSide

    load r3, 0x80452f2c # mode 3 slot
    stb REG_SLOT, 0(r3)
    logf LOG_LEVEL_ERROR, "Option Picked!\n"


FN_InputThink_Exit:
  restore
  blr

################################################################################

EXIT:
  restore
  lwz	r12, 0x0044 (r31)