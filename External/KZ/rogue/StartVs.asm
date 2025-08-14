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

b CODE_START

DATA_BLRL:
blrl
.set ACTIVE_SLOTS, 0
.byte -1, -1
.align 2

CODE_START:
  .set REG_GOBJ, 31
  .set REG_COUNT, 30
  .set REG_PLY_NUM, 29
  .set REG_DATA, 28
  backup

  bl DATA_BLRL
  mflr REG_DATA

# create gobj to run our in-game code
  gobj_create GOBJ_CLASS_ZAKO, GOBJ_PLINK_STAGE, 111, REG_GOBJ

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
  addi r12, r12, 0x24C0
  lbz r3, 0xA(r12)
  ori r3, r3, 0x08
  stb r3, 0xA(r12)

# disable hud
  load r3, stc_hud_vis
  li r4, 1
  stb r4, 0(r3)

# set active slots
  li REG_COUNT, 0
  li REG_PLY_NUM, 0
  SET_ACTIVE_SLOTS_LOOP:
    mr r3, REG_COUNT
    branchl r12, PlayerBlock_GetSlotType
    cmpwi r3, 1
    bgt SET_ACTIVE_SLOT_LOOP_CHECK

    cmpwi REG_PLY_NUM, 2 # we should only be in direct or have two players
    bgt SET_ACTIVE_SLOT_LOOP_CHECK
    stbx REG_COUNT, REG_PLY_NUM, REG_DATA # active slots
    addi REG_PLY_NUM, REG_PLY_NUM, 1

  SET_ACTIVE_SLOT_LOOP_CHECK:
    addi REG_COUNT, REG_COUNT, 1
    cmpwi REG_COUNT, 4
    blt SET_ACTIVE_SLOTS_LOOP

  b EXIT

################################################################################

FN_RogueSetupBLRL:
blrl
FN_RogueSetup:
  backup

  mr REG_GOBJ, r3
  lwz REG_DATA, GOBJ_USERDATA(REG_GOBJ)

  loadGlobalFrame r5
  cmpwi r5, 66
  bne FN_Exit

  li r3, 5 # 5 freezes players but not camera
  branchl r12, Scene_SetPauseFlag

# zoom in on p1 to start card picks
bp
  load r3, stc_mode3_vars
  # lerp
  lfs f1, OFST_TINT(r3)
  stfs f1, OFST_TEYE(r3)
  load r4, 0x41200000
  stw r4, OFST_FOV(r3)

  lbz r3, ACTIVE_SLOTS(REG_DATA)
  branchl r12, Camera_SetMode3

  # clamp the offsets
  li REG_COUNT, 0
  GET_PLAYER_SIDE_LOOP:
    lbzx r3, REG_COUNT, REG_DATA
    branchl r12, PlayerBlock_GetGObj
    
    addi r4, sp, BKP_FREE_SPACE_OFFSET
    branchl r12, Player_GetPosition

    load r3, 0x80452f30 # offset y
    lfs f1, RTOC_STICKTHRESH(rtoc) # 0.2
    stfs f1, 0(r3)

    lfs f1, BKP_FREE_SPACE_OFFSET(sp) # x
    lfs f0, RTOC_ZERO(rtoc)
    fcmpo cr0, f0, f1
    bge RIGHT_SIDE

    LEFT_SIDE:
      load r3, 0x80452f34 # offset x
      lfs f1, RTOC_HALF(rtoc)
      stfs f1, 0(r3) # pan/tilt camera left
      b END_SIDE_CHECK

    RIGHT_SIDE:
      load r3, 0x80452f34
      lfs f1, RTOC_HALF(rtoc)
      fneg f1, f1
      stfs f1, 0(r3) # pan/tilt camera right

    END_SIDE_CHECK:
      addi REG_COUNT, REG_COUNT, 1
      cmpwi REG_COUNT, 2
      blt GET_PLAYER_SIDE_LOOP

FN_Exit:
  restore
  blr

################################################################################

EXIT:
  restore
  lwz	r12, 0x0044 (r31)