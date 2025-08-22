################################################################################
# Address: 0x800d5618 # AS_RebirthWait
################################################################################

.include "./StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/PLAYER.s"

# replaced codeline
lwz	r31, 0x002C(r3)

CODE_START:
.set REG_SRCD, 16 # StockRun Context data
.set REG_SLOT, 17
.set REG_FP, 31 # fighter data
.set REG_FGP, 30 # fighter gobj
  backup
  # we will set the game state, transition timer, and active slot
  loadwz REG_SRCD, stc_sr_data # init gobj
  lwz REG_SRCD, GOBJ_USERDATA(REG_SRCD)

  lbz REG_SLOT, FT_SLOT(REG_FP)
  stw REG_SLOT, SRC_ACTIVE_SLOT(REG_SRCD)
  li r3, SRGS_GAME_TRANSITION
  stw r3, SRC_GAME_STATE(REG_SRCD)
  li r3, TRANSITION_FRAMES
  stw r3, SRC_TRANSITION_TIMER(REG_SRCD)

  li r3, MATCH_FREEZE_FLAG # freezes players but not cameras/ui
  branchl r12, Scene_SetPauseFlag

  # set the camera here as well since its easier
  # update slot
  load r4, 0x80452f2c # mode 3 slot
  stb REG_SLOT, 0(r4)
  load r4, stc_pause_data
  stw REG_SLOT, PAUSE_UI_SLOT(r4)

  mr r3, REG_SLOT
  branchl r12, Camera_SetMode3

  # disable hud
  load r3, stc_hud_vis
  li r4, TRUE 
  stb r4, 0(r3)

  # update pos
  mr r3, REG_SLOT
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
    b EXIT

  RIGHT_SIDE:
    load r3, 0x80452f34
    lfs f1, RTOC_0_5(rtoc)
    fneg f1, f1
    stfs f1, 0(r3) # pan/tilt camera right

EXIT:
  restore
