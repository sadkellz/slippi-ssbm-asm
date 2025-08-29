################################################################################
# Address: 0x800d5618 # AS_RebirthWait
################################################################################

.include "External/KZ/StockRun/StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/PLAYER.s"

# replaced codeline
lwz	r31, 0x002C(r3)

CODE_START:
.set REG_SRCD, 16 # StockRun Context data
.set REG_SLOT, 17
.set REG_SRD, 18
.set REG_COUNT, 19
.set REG_CARDS, 20
.set REG_TEXT, 21
.set REG_FP, 31 # fighter data
.set REG_FGP, 30 # fighter gobj
  backup
  # we will set the game state, transition timer, and active slot
  load REG_SRD, stc_sr_data
  lwz REG_SRCD, SRD_GOBJ_INIT(REG_SRD)
  lwz REG_SRCD, GOBJ_USERDATA(REG_SRCD)

  lbz REG_SLOT, FT_SLOT(REG_FP)
  stw REG_SLOT, SRC_ACTIVE_SLOT(REG_SRCD)

  # IC's logic...
  lwz r3, FT_CID(REG_FP)
  cmpwi r3, 0xB # Nana
  beq EXIT # nana doesnt get to pick...

  li r3, SRGS_GAME_TRANSITION
  stw r3, SRC_GAME_STATE(REG_SRCD)
  li r3, TRANSITION_FRAMES
  stw r3, SRC_TRANSITION_TIMER(REG_SRCD)

  li r3, MATCH_FREEZE_FLAG # freezes players but not cameras/ui
  branchl r12, Scene_SetPauseFlag

  # texts
  addi REG_TEXT, REG_SRD, SRD_TEXTS

  # roll cards
  li r3, CARD_COUNT
  addi REG_CARDS, REG_SRD, SRD_CURRENT_CARDS
  mr r4, REG_CARDS
  mr r5, REG_SLOT
  branchl r12, StockRun_RandomizeCards
  
  # set text
  li REG_COUNT, 0
  SET_TEXT_LOOP:
    rlwinm r0, REG_COUNT, 2, 0, 29
    lwzx r3, REG_TEXT, r0
    lwzx r4, REG_CARDS, r0
    branchl r12, Text_SetFromSIS
  SET_TEXT_LOOP_CHECK:
    addi REG_COUNT, REG_COUNT, 1
    cmpwi REG_COUNT, 4
    blt SET_TEXT_LOOP

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

  # cleared cards are re-applied in PlayerProc.asm

EXIT:
  restore
