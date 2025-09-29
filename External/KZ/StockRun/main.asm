################################################################################
# Address: 0x8016e8c8
################################################################################

.include "External/KZ/StockRun/StockRun.s"
.include "Common/Common.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/HSD_COBJ.s"
.include "External/KZ/MATCH.s"
.include "External/KZ/PLAYER.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_PAD.s"
.include "External/KZ/OS.s"

b CODE_START

CODE_START:
  backup
    li r3, 0xe
    li r4, 0xf
    li r5, 0x6f
    branchl r12, GObj_Create
    addi r30, r3, 0x0
    li r3, 0xb8
    branchl r12, HSD_MemAlloc
    lis r31, 0x804a
    stw r3, 0x304c(r31)
    li r4, 0x0
    li r5, 0xb8
    lwz r3, 0x304c(r31)
    branchl r12, memset
    lis r3, HSD_Free@ha
    lwz r6, 0x304c(r31)
    addi r5, r3, HSD_Free@l
    addi r3, r30, 0x0
    li r4, 0x0
    branchl r12, GObj_AddUserData
    lwz r4, 0x304c(r31)
    li r8, 0x0
    stw r8, 0x8(r4)
    bl StockRun_Update
    mflr r4
    li r5, 0x1
    lwz r3, 0x304c(r31)
    li r7, -0x1
    li r0, 0x1e
    stw r5, 0xc(r3)
    mr r3, r30
    li r5, 0x0
    lwz r6, 0x304c(r31)
    stw r7, 0x10(r6)
    lwz r6, 0x304c(r31)
    stw r0, 0x18(r6)
    lwz r6, 0x304c(r31)
    stw r8, 0x0(r6)
    lwz r6, 0x304c(r31)
    stw r8, 0x14(r6)
    lwz r6, 0x304c(r31)
    stw r8, 0x1c(r6)
    lwz r6, 0x304c(r31)
    stw r7, 0x20(r6)
    lwz r6, 0x304c(r31)
    stw r7, 0x78(r6)
    lwz r6, 0x304c(r31)
    stw r7, 0x7c(r6)
    branchl r12, GObj_AddProc

  b EXIT

#==============================================================================#

#----------------------------------------------------------------------------#
# get_card_from_stick
#   f1 = x
#           f2 = y
#   returns: r3 = int direction
get_card_from_stick:
    fmr f4, f1
    mflr r0
    stw r0, 0x4(r1)
    fmuls f1, f2, f2
    fmuls f3, f4, f4
    stwu r1, -0x8(r1)
    fadds f1, f3, f1
    lfs f0, RTOC_0_95(rtoc)
    fcmpo cr0, f1, f0
    bgt label_0x230
    li r3, -0x1
    b label_0x2a8
  label_0x230:
    fmr f1, f2
    fmr f2, f4
    branchl r12, atan2
    lfs f0, RTOC_M_PI_4(rtoc)
    fneg f2, f0
    fcmpo cr0, f1, f2
    ble label_0x260
    fcmpo cr0, f1, f0
    cror eq, lt, eq
    bne label_0x260
    li r3, 0x1
    b label_0x2a8
  label_0x260:
    lfs f0, RTOC_M_PI_4(rtoc)
    fcmpo cr0, f1, f0
    ble label_0x284
    lfs f0, RTOC_2_3561945(rtoc)
    fcmpo cr0, f1, f0
    cror eq, lt, eq
    bne label_0x284
    li r3, 0x0
    b label_0x2a8
  label_0x284:
    fcmpo cr0, f1, f2
    bge label_0x2a4
    lfs f0, RTOC_2_3561945(rtoc)
    fneg f0, f0
    fcmpo cr0, f1, f0
    cror eq, gt, eq
    bne label_0x2a4
    li r3, 0x2
    b label_0x2a8
  label_0x2a4:
    li r3, 0x3
  label_0x2a8:
    lwz r0, 0xc(r1)
    addi r1, r1, 0x8
    mtlr r0
blr


#----------------------------------------------------------------------------#
# apply_blur
#   f1 = amount
apply_blur:
    lis r3, 0x8047
    lfs f0, RTOC_1(rtoc)
    lfs f2, 0x2e38(r3)
    fadds f2, f2, f1
    fcmpo cr0, f2, f0
    ble label_0x2d4
    fmr f2, f0
  label_0x2d4:
    lis r3, 0x8047
    stfs f2, 0x2e38(r3)
    lfs f2, 0x2e3c(r3)
    lfs f0, RTOC_1(rtoc)
    fadds f1, f2, f1
    fcmpo cr0, f1, f0
    ble label_0x2f4
    fmr f1, f0
  label_0x2f4:
    lis r3, 0x8047
    stfs f1, 0x2e3c(r3)
blr


#----------------------------------------------------------------------------#
# reset_visuals
#   f1 = amount
reset_visuals:
    mflr r0
    lis r3, 0x8047
    stw r0, 0x4(r1)
    stwu r1, -0x8(r1)
    lfs f0, RTOC_0(rtoc)
    stfs f0, 0x2e38(r3)
    stfs f0, 0x2e3c(r3)
    branchl r12, Match_EnableHud
    lwz r0, 0xc(r1)
    addi r1, r1, 0x8
    mtlr r0
blr


#----------------------------------------------------------------------------#
# update_input_state
#   r3 = stockrun data
update_input_state:
    mflr r0
    stw r0, 0x4(r1)
    stwu r1, -0x20(r1)
    stw r31, 0x1c(r1)
    stw r30, 0x18(r1)
    addi r30, r3, 0x0
    lis r3, 0x8003
    lwz r0, 0x14(r30)
    subi r12, r3, 0x496c
    addi r31, r30, 0x58
    mtlr r12
    addi r3, r31, 0x0
    clrlwi r4, r0, 24
    blrl
    lwz r0, 0x20(r31)
    stw r0, 0x24(r31)
    lfs f1, 0x4(r31)
    lfs f2, 0x0(r31)
    fmuls f3, f1, f1
    lfs f0, RTOC_0_95(rtoc)
    fmuls f4, f2, f2
    fadds f3, f4, f3
    fcmpo cr0, f3, f0
    bgt label_0x398
    li r0, -0x1
    b label_0x408
  label_0x398:
    branchl r12, atan2
    lfs f0, RTOC_M_PI_4(rtoc)
    fneg f2, f0
    fcmpo cr0, f1, f2
    ble label_0x3c0
    fcmpo cr0, f1, f0
    cror eq, lt, eq
    bne label_0x3c0
    li r0, 0x1
    b label_0x408
  label_0x3c0:
    lfs f0, RTOC_M_PI_4(rtoc)
    fcmpo cr0, f1, f0
    ble label_0x3e4
    lfs f0, RTOC_2_3561945(rtoc)
    fcmpo cr0, f1, f0
    cror eq, lt, eq
    bne label_0x3e4
    li r0, 0x0
    b label_0x408
  label_0x3e4:
    fcmpo cr0, f1, f2
    bge label_0x404
    lfs f0, RTOC_2_3561945(rtoc)
    fneg f0, f0
    fcmpo cr0, f1, f0
    cror eq, gt, eq
    bne label_0x404
    li r0, 0x2
    b label_0x408
  label_0x404:
    li r0, 0x3
  label_0x408:
    stw r0, 0x20(r31)
    li r0, 0x0
    srwi r4, r0, 31
    lwz r5, 0x20(r31)
    srawi r3, r5, 31
    subfc r0, r0, r5
    adde r0, r3, r4
    stw r0, 0x1c(r30)
    lwz r0, 0x20(r31)
    stw r0, 0x20(r30)
    lwz r0, 0x24(r1)
    lwz r31, 0x1c(r1)
    lwz r30, 0x18(r1)
    addi r1, r1, 0x20
    mtlr r0
blr


#----------------------------------------------------------------------------#
# handle_hover_sound
#   r3 = stockrun data
handle_hover_sound:
    mflr r0
    addi r4, r3, 0x58
    stw r0, 0x4(r1)
    stwu r1, -0x8(r1)
    lwz r0, 0x78(r3)
    cmpwi r0, 0x0
    blt label_0x47c
    lwz r3, 0x20(r4)
    lwz r0, 0x24(r4)
    cmpw r3, r0
    beq label_0x47c
    li r3, 0x1
    branchl r12, SFX_Menu_CommonSound
  label_0x47c:
    lwz r0, 0xc(r1)
    addi r1, r1, 0x8
    mtlr r0
blr


#----------------------------------------------------------------------------#
# setup_camera_for_player
#   r3 = stockrun data
#   r4 = slot
setup_camera_for_player:
    mflr r0
    lis r6, stc_matchcam@ha
    stw r0, 0x4(r1)
    lis r5, stc_cam_settings@ha
    stwu r1, -0x30(r1)
    stw r31, 0x2c(r1)
    addi r31, r5, stc_matchcam@l
    stw r30, 0x28(r1)
    addi r30, r6, stc_cam_settings0@l
    stw r29, 0x24(r1)
    addi r29, r4, 0x0
    stw r28, 0x20(r1)
    addi r28, r3, 0x0
    addi r3, r29, 0x0
    branchl r12, PlayerBlock_GetGObj
    addi r4, r1, 0x10
    branchl r12, Player_GetPosition
    extsb r3, r29
    branchl r12, Camera_SetMode3
    lfs f0, RTOC_0_1(rtoc)
    stfs f0, 0x1cc(r31)
    stfs f0, 0x1d0(r31)
    lfs f0, RTOC_10(rtoc)
    stfs f0, 0x1d4(r31)
    lfs f1, 0x10(r1)
    lfs f0, RTOC_0(rtoc)
    fcmpo cr0, f1, f0
    cror eq, gt, eq
    bne label_0x508
    lfs f0, RTOC_N_0_5(rtoc)
    b label_0x50c
  label_0x508:
    lfs f0, RTOC_0_5(rtoc)
  label_0x50c:
    stfs f0, 0xb0(r28)
    lfs f0, RTOC_0_2(rtoc)
    stfs f0, 0xb4(r28)
    lfs f0, 0xb0(r28)
    stfs f0, 0x2c8(r30)
    lfs f0, 0xb4(r28)
    stfs f0, 0x2cc(r30)
    stw r29, 0x293c(r30)
    lwz r0, 0x34(r1)
    lwz r31, 0x2c(r1)
    lwz r30, 0x28(r1)
    lwz r29, 0x24(r1)
    lwz r28, 0x20(r1)
    addi r1, r1, 0x30
    mtlr r0
blr


#----------------------------------------------------------------------------#
# refresh_cards
#   r3 = stockrun data
refresh_cards:
blr


#----------------------------------------------------------------------------#
# update_card_panels
#   r3 = stockrun data
update_card_panels:
blr


#----------------------------------------------------------------------------#
# apply_card_to_player
#   r3 = stockrun data
#   r4 = card idx
apply_card_to_player:
    cmpwi r4, 0x0
    bltlr
    cmpwi r4, 0x4
    blt label_0x568
    blr
  label_0x568:
    lwz r5, 0x14(r3)
    slwi r0, r4, 2
    add r4, r3, r0
    mulli r5, r5, 0xc
    lwz r0, 0x24(r4)
    addi r5, r5, 0x80
    add r5, r3, r5
    li r4, 0x1
    lwz r3, 0x0(r5)
    slw r0, r4, r0
    or r0, r3, r0
    stw r0, 0x0(r5)
    lbz r3, 0x4(r5)
    addi r0, r3, 0x1
    stb r0, 0x4(r5)
    stw r4, 0x8(r5)
blr


#----------------------------------------------------------------------------#
# start_transition
#   r3 = stockrun data
#   r4 = GAME_STATE
#   r5 = frames
start_transition:
    stw r4, 0x4(r3)
    li r0, 0x2
    stw r5, 0x18(r3)
    stw r0, 0x0(r3)
    blr


#----------------------------------------------------------------------------#
# advance_to_next_player
#   r3 = stockrun data
advance_to_next_player:
    mflr r0
    lis r5, stc_matchcam@ha
    stw r0, 0x4(r1)
    lis r4, stc_cam_settings0@ha
    stwu r1, -0x28(r1)
    stw r31, 0x24(r1)
    mr r31, r3
    stw r30, 0x20(r1)
    addi r30, r4, stc_cam_settings@l
    stw r29, 0x1c(r1)
    addi r29, r5, stc_matchcam@l
    stw r28, 0x18(r1)
    lwz r3, 0x10(r3)
    addi r0, r3, 0x1
    stw r0, 0x10(r31)
    lwz r0, 0x10(r31)
    cmpwi r0, 0x2
    blt label_0x634
    li r3, 0x4
    branchl r12,  Scene_ClearPauseFlag
    branchl r12,  Camera_SetNormal
    lfs f0, RTOC_0(rtoc)
    lis r3, 0x8047
    stfs f0, 0x2e38(r3)
    stfs f0, 0x2e3c(r3)
    branchl r12, Match_EnableHud
    li r0, 0x3
    stw r0, 0x0(r31)
    b label_0x6cc
  label_0x634:
    slwi r0, r0, 2
    add r3, r31, r0
    lwz r0, 0x8(r3)
    stw r0, 0x14(r31)
    lwz r28, 0x14(r31)
    mr r3, r28
    branchl r12, PlayerBlock_GetGObj
    addi r4, r1, 0xc
    branchl r12, Player_GetPosition
    extsb r3, r28
    branchl r12, Camera_SetMode3
    lfs f0, RTOC_0_1(rtoc)
    stfs f0, 0x1cc(r30)
    stfs f0, 0x1d0(r30)
    lfs f0, RTOC_10(rtoc)
    stfs f0, 0x1d4(r30)
    lfs f1, 0xc(r1)
    lfs f0, RTOC_0(rtoc)
    fcmpo cr0, f1, f0
    cror eq, gt, eq
    bne label_0x690
    lfs f0, RTOC_N_0_5(rtoc)
    b label_0x694
  label_0x690:
    lfs f0, RTOC_0_5(rtoc)
  label_0x694:
    stfs f0, 0xb0(r31)
    li r4, 0x1
    li r3, 0x1e
    lfs f0, RTOC_0_2(rtoc)
    li r0, 0x2
    stfs f0, 0xb4(r31)
    lfs f0, 0xb0(r31)
    stfs f0, 0x2c8(r29)
    lfs f0, 0xb4(r31)
    stfs f0, 0x2cc(r29)
    stw r28, 0x293c(r29)
    stw r4, 0x4(r31)
    stw r3, 0x18(r31)
    stw r0, 0x0(r31)
  label_0x6cc:
    lwz r0, 0x2c(r1)
    lwz r31, 0x24(r1)
    lwz r30, 0x20(r1)
    lwz r29, 0x1c(r1)
    lwz r28, 0x18(r1)
    addi r1, r1, 0x28
    mtlr r0
blr


#----------------------------------------------------------------------------#
# handle_init_state
#   r3 = stockrun data
    mflr r0
    lis r5, stc_matchcam@ha
    stw r0, 0x4(r1)
    lis r4, stc_cam_settings@ha
    stwu r1, -0x28(r1)
    stw r31, 0x24(r1)
    addi r31, r4, stc_cam_settings@l
    stw r30, 0x20(r1)
    addi r30, r5, stc_matchcam@l
    stw r29, 0x1c(r1)
    stw r28, 0x18(r1)
    addi r28, r3, 0x0
    li r3, 0x4
    branchl r12, Scene_SetPauseFlag
    li r0, 0x0
    stw r0, 0x10(r28)
    lwz r0, 0x8(r28)
    stw r0, 0x14(r28)
    lwz r29, 0x14(r28)
    mr r3, r29
    branchl r12, PlayerBlock_GetGObj
    addi r4, r1, 0xc
    branchl r12, Player_GetPosition
    extsb r3, r29
    branchl r12, Camera_SetMode3
    lfs f0, RTOC_0_1(rtoc)
    stfs f0, 0x1cc(r31)
    stfs f0, 0x1d0(r31)
    lfs f0, RTOC_10(rtoc)
    stfs f0, 0x1d4(r31)
    lfs f1, 0xc(r1)
    lfs f0, RTOC_0(rtoc)
    fcmpo cr0, f1, f0
    cror eq, gt, eq
    bne label_0x780
    lfs f0, RTOC_N_0_5(rtoc)
    b label_0x784
  label_0x780:
    lfs f0, RTOC_0_5(rtoc)
  label_0x784:
    stfs f0, 0xb0(r28)
    li r4, 0x1
    li r3, 0x1e
    lfs f0, RTOC_0_2(rtoc)
    li r0, 0x2
    stfs f0, 0xb4(r28)
    lfs f0, 0xb0(r28)
    stfs f0, 0x2c8(r30)
    lfs f0, 0xb4(r28)
    stfs f0, 0x2cc(r30)
    stw r29, 0x293c(r30)
    stw r4, 0x4(r28)
    stw r3, 0x18(r28)
    stw r0, 0x0(r28)
    lwz r0, 0x2c(r1)
    lwz r31, 0x24(r1)
    lwz r30, 0x20(r1)
    lwz r29, 0x1c(r1)
    lwz r28, 0x18(r1)
    addi r1, r1, 0x28
    mtlr r0
blr


#----------------------------------------------------------------------------#
# handle_card_select_state
#   r3 = stockrun data
handle_card_select_state:
    mflr r0
    stw r0, 0x4(r1)
    stwu r1, -0x18(r1)
    stw r31, 0x14(r1)
    addi r31, r3, 0x0
    lis r3, 0x8003
    stw r30, 0x10(r1)
    subi r12, r3, 0x496c
    addi r30, r31, 0x58
    mtlr r12
    lwz r0, 0x14(r31)
    addi r3, r30, 0x0
    clrlwi r4, r0, 24
    blrl
    lwz r0, 0x20(r30)
    stw r0, 0x24(r30)
    lfs f1, 0x0(r30)
    lfs f2, 0x4(r30)
    bl get_card_from_stick
    stw r3, 0x20(r30)
    li r0, 0x0
    srwi r4, r0, 31
    lwz r5, 0x20(r30)
    srawi r3, r5, 31
    subfc r0, r0, r5
    adde r0, r3, r4
    stw r0, 0x1c(r31)
    lwz r0, 0x20(r30)
    stw r0, 0x20(r31)
    lwz r0, 0x78(r31)
    cmpwi r0, 0x0
    blt label_0x874
    lwz r3, 0x20(r30)
    lwz r0, 0x24(r30)
    cmpw r3, r0
    beq label_0x874
    li r3, 0x1
    branchl r12, SFX_Menu_CommonSound
  label_0x874:
    lwz r0, 0x70(r31)
    li r4, 0x0
    lwz r5, 0x74(r31)
    li r3, 0x100
    and r0, r0, r4
    and r3, r5, r3
    xor r3, r3, r4
    xor r0, r0, r4
    or. r0, r3, r0
    beq label_0x988
    lwz r0, 0x1c(r31)
    cmpwi r0, 0x0
    beq label_0x980
    li r3, 0x2
    branchl r12, SFX_Menu_CommonSound
    lwz r0, 0x20(r31)
    cmpwi r0, 0x0
    blt label_0x904
    cmpwi r0, 0x4
    bge label_0x904
    lwz r4, 0x14(r31)
    slwi r0, r0, 2
    add r3, r31, r0
    mulli r4, r4, 0xc
    lwz r0, 0x24(r3)
    addi r5, r4, 0x80
    add r5, r31, r5
    li r4, 0x1
    lwz r3, 0x0(r5)
    slw r0, r4, r0
    or r0, r3, r0
    stw r0, 0x0(r5)
    lbz r3, 0x4(r5)
    addi r0, r3, 0x1
    stb r0, 0x4(r5)
    stw r4, 0x8(r5)
  label_0x904:
    lwz r3, 0x10(r31)
    addi r0, r3, 0x1
    stw r0, 0x10(r31)
    lwz r0, 0x10(r31)
    cmpwi r0, 0x2
    blt label_0x948
    li r3, 0x4
    branchl r12, Scene_ClearPauseFlag
    branchl r12, Camera_SetNormal
    lfs f0, RTOC_0(rtoc)
    lis r3, 0x8047
    stfs f0, 0x2e38(r3)
    stfs f0, 0x2e3c(r3)
    branchl r12, Match_EnableHud
    li r0, 0x3
    stw r0, 0x0(r31)
    b label_0x988
  label_0x948:
    slwi r0, r0, 2
    add r3, r31, r0
    lwz r0, 0x8(r3)
    mr r3, r31
    stw r0, 0x14(r31)
    lwz r4, 0x14(r31)
    bl setup_camera_for_player
    li r0, 0x1
    stw r0, 0x4(r31)
    li r3, 0x1e
    li r0, 0x2
    stw r3, 0x18(r31)
    stw r0, 0x0(r31)
    b label_0x988
  label_0x980:
    li r3, 0x3
    branchl r12, SFX_Menu_CommonSound
  label_0x988:
    lwz r0, 0x1c(r1)
    lwz r31, 0x14(r1)
    lwz r30, 0x10(r1)
    addi r1, r1, 0x18
    mtlr r0
blr


#----------------------------------------------------------------------------#
# handle_transition_state
#   r3 = stockrun data
handle_transition_state:
    lwz r4, 0x18(r3)
    subi r0, r4, 0x1
    stw r0, 0x18(r3)
    lwz r0, 0x18(r3)
    cmpwi r0, 0x0
    bgtlr
    lwz r0, 0x4(r3)
    stw r0, 0x0(r3)
blr


#----------------------------------------------------------------------------#
# handle_vs_state
#   r3 = stockrun data
handle_vs_state:
blr


#----------------------------------------------------------------------------#
# handle_vs_transition_state
#   r3 = stockrun data
handle_vs_transition_state:
    lis r4, 0x8047
    lfs f0, RTOC_0_015625(rtoc)
    lfs f2, 0x2e38(r4)
    lfs f0, RTOC_1(rtoc)
    fadds f1, f2, f1
    fcmpo cr0, f1, f0
    ble label_0x9e8
    fmr f1, f0
  label_0x9e8:
    lis r4, 0x8047
    stfs f1, 0x2e38(r4)
    lfs f2, 0x2e3c(r4)
    lfs f0, RTOC_0_015625(rtoc)
    lfs f0, RTOC_1(rtoc)
    fadds f1, f2, f1
    fcmpo cr0, f1, f0
    ble label_0xa0c
    fmr f1, f0
  label_0xa0c:
    lis r4, 0x8047
    stfs f1, 0x2e3c(r4)
    lwz r4, 0x18(r3)
    subi r0, r4, 0x1
    stw r0, 0x18(r3)
    lwz r0, 0x18(r3)
    cmpwi r0, 0x0
    bgtlr
    li r0, 0x5
    stw r0, 0x0(r3)
blr


#----------------------------------------------------------------------------#
# handle_vs_card_select_state
#   r3 = stockrun data
handle_vs_card_select_state:
    mflr r0
    stw r0, 0x4(r1)
    stwu r1, -0x18(r1)
    stw r31, 0x14(r1)
    addi r31, r3, 0x0
    lis r3, 0x8003
    stw r30, 0x10(r1)
    subi r12, r3, 0x496c
    addi r30, r31, 0x58
    mtlr r12
    lwz r0, 0x14(r31)
    addi r3, r30, 0x0
    clrlwi r4, r0, 24
    blrl
    lwz r0, 0x20(r30)
    stw r0, 0x24(r30)
    lfs f1, 0x0(r30)
    lfs f2, 0x4(r30)
    bl get_card_from_stick
    stw r3, 0x20(r30)
    li r0, 0x0
    srwi r4, r0, 31
    lwz r5, 0x20(r30)
    srawi r3, r5, 31
    subfc r0, r0, r5
    adde r0, r3, r4
    stw r0, 0x1c(r31)
    lwz r0, 0x20(r30)
    stw r0, 0x20(r31)
    lwz r0, 0x78(r31)
    cmpwi r0, 0x0
    blt label_0xad0
    lwz r3, 0x20(r30)
    lwz r0, 0x24(r30)
    cmpw r3, r0
    beq label_0xad0
    li r3, 0x1
    branchl r12, SFX_Menu_CommonSound
  label_0xad0:
    lwz r0, 0x70(r31)
    li r4, 0x0
    lwz r5, 0x74(r31)
    li r3, 0x100
    and r0, r0, r4
    and r3, r5, r3
    xor r3, r3, r4
    xor r0, r0, r4
    or. r0, r3, r0
    beq label_0xb94
    lwz r0, 0x1c(r31)
    cmpwi r0, 0x0
    beq label_0xb8c
    li r3, 0x2
    branchl r12, SFX_Menu_CommonSound
    lwz r0, 0x20(r31)
    cmpwi r0, 0x0
    blt label_0xb60
    cmpwi r0, 0x4
    bge label_0xb60
    lwz r4, 0x14(r31)
    slwi r0, r0, 2
    add r3, r31, r0
    mulli r4, r4, 0xc
    lwz r0, 0x24(r3)
    addi r5, r4, 0x80
    add r5, r31, r5
    li r4, 0x1
    lwz r3, 0x0(r5)
    slw r0, r4, r0
    or r0, r3, r0
    stw r0, 0x0(r5)
    lbz r3, 0x4(r5)
    addi r0, r3, 0x1
    stb r0, 0x4(r5)
    stw r4, 0x8(r5)
  label_0xb60:
    li r3, 0x4
    branchl r12, Scene_ClearPauseFlag
    branchl r12, Camera_SetNormal
    lfs f0, RTOC_0(rtoc)
    lis r3, 0x8047
    stfs f0, 0x2e38(r3)
    stfs f0, 0x2e3c(r3)
    branchl r12, Match_EnableHud
    li r0, 0x3
    stw r0, 0x0(r31)
    b label_0xb94
  label_0xb8c:
    li r3, 0x3
    branchl r12, SFX_Menu_CommonSound
  label_0xb94:
    lwz r0, 0x1c(r1)
    lwz r31, 0x14(r1)
    lwz r30, 0x10(r1)
    addi r1, r1, 0x18
    mtlr r0
  blr


#----------------------------------------------------------------------------#
# StockRun_Update
#   r3 = gobj
StockRun_Update:
blrl
    mflr r0
    lis r4, 0x8048
    stw r0, 0x4(r1)
    stwu r1, -0x28(r1)
    stw r31, 0x24(r1)
    stw r30, 0x20(r1)
    lwz r0, -0x62a4(r4)
    lwz r31, 0x2c(r3)
    cmpwi r0, 0x40
    blt label_0xf10
    cmpwi r0, 0x90
    bgt label_0xc28
    lis r3, 0x8047
    lfs f0, RTOC_0_015625(rtoc)
    lfs f2, 0x2e38(r3)
    lfs f0, RTOC_1(rtoc)
    fadds f1, f2, f1
    fcmpo cr0, f1, f0
    ble label_0xbfc
    fmr f1, f0
  label_0xbfc:
    lis r3, 0x8047
    stfs f1, 0x2e38(r3)
    lfs f2, 0x2e3c(r3)
    lfs f0, RTOC_0_015625(rtoc)
    lfs f0, RTOC_1(rtoc)
    fadds f1, f2, f1
    fcmpo cr0, f1, f0
    ble label_0xc20
    fmr f1, f0
  label_0xc20:
    lis r3, 0x8047
    stfs f1, 0x2e3c(r3)
  label_0xc28:
    lwz r0, 0x0(r31)
    cmpwi r0, 0x3
    beq label_0xf10
    bge label_0xc50
    cmpwi r0, 0x1
    beq label_0xca0
    bge label_0xd80
    cmpwi r0, 0x0
    bge label_0xc60
    b label_0xf10
  label_0xc50:
    cmpwi r0, 0x5
    beq label_0xe14
    bge label_0xf10
    b label_0xda4
  label_0xc60:
    li r3, 0x4
    branchl r12, Scene_SetPauseFlag
    li r0, 0x0
    stw r0, 0x10(r31)
    mr r3, r31
    lwz r0, 0x8(r31)
    stw r0, 0x14(r31)
    lwz r4, 0x14(r31)
    bl setup_camera_for_player
    li r0, 0x1
    stw r0, 0x4(r31)
    li r3, 0x1e
    li r0, 0x2
    stw r3, 0x18(r31)
    stw r0, 0x0(r31)
    b label_0xf10
  label_0xca0:
    lis r3, 0x8003
    lwz r0, 0x14(r31)
    subi r12, r3, 0x496c
    addi r30, r31, 0x58
    mtlr r12
    addi r3, r30, 0x0
    clrlwi r4, r0, 24
    blrl
    lwz r0, 0x20(r30)
    stw r0, 0x24(r30)
    lfs f1, 0x0(r30)
    lfs f2, 0x4(r30)
    bl get_card_from_stick
    stw r3, 0x20(r30)
    li r0, 0x0
    srwi r4, r0, 31
    lwz r5, 0x20(r30)
    srawi r3, r5, 31
    subfc r0, r0, r5
    adde r0, r3, r4
    stw r0, 0x1c(r31)
    lwz r0, 0x20(r30)
    stw r0, 0x20(r31)
    lwz r0, 0x78(r31)
    cmpwi r0, 0x0
    blt label_0xd20
    lwz r3, 0x20(r30)
    lwz r0, 0x24(r30)
    cmpw r3, r0
    beq label_0xd20
    li r3, 0x1
    branchl r12, SFX_Menu_CommonSound
  label_0xd20:
    lwz r0, 0x70(r31)
    li r4, 0x0
    lwz r5, 0x74(r31)
    li r3, 0x100
    and r0, r0, r4
    and r3, r5, r3
    xor r3, r3, r4
    xor r0, r0, r4
    or. r0, r3, r0
    beq label_0xf10
    lwz r0, 0x1c(r31)
    cmpwi r0, 0x0
    beq label_0xd74
    li r3, 0x2
    branchl r12, SFX_Menu_CommonSound
    mr r3, r31
    lwz r4, 0x20(r31)
    bl apply_card_to_player
    mr r3, r31
    bl advance_to_next_player
    b label_0xf10
  label_0xd74:
    li r3, 0x3
    branchl r12, SFX_Menu_CommonSound
    b label_0xf10
  label_0xd80:
    lwz r3, 0x18(r31)
    subi r0, r3, 0x1
    stw r0, 0x18(r31)
    lwz r0, 0x18(r31)
    cmpwi r0, 0x0
    bgt label_0xf10
    lwz r0, 0x4(r31)
    stw r0, 0x0(r31)
    b label_0xf10
  label_0xda4:
    lis r3, 0x8047
    lfs f0, RTOC_0_015625(rtoc)
    lfs f2, 0x2e38(r3)
    lfs f0, RTOC_1(rtoc)
    fadds f1, f2, f1
    fcmpo cr0, f1, f0
    ble label_0xdc4
    fmr f1, f0
  label_0xdc4:
    lis r3, 0x8047
    stfs f1, 0x2e38(r3)
    lfs f2, 0x2e3c(r3)
    lfs f0, RTOC_0_015625(rtoc)
    lfs f0, RTOC_1(rtoc)
    fadds f1, f2, f1
    fcmpo cr0, f1, f0
    ble label_0xde8
    fmr f1, f0
  label_0xde8:
    lis r3, 0x8047
    stfs f1, 0x2e3c(r3)
    lwz r3, 0x18(r31)
    subi r0, r3, 0x1
    stw r0, 0x18(r31)
    lwz r0, 0x18(r31)
    cmpwi r0, 0x0
    bgt label_0xf10
    li r0, 0x5
    stw r0, 0x0(r31)
    b label_0xf10
  label_0xe14:
    lis r3, 0x8003
    lwz r0, 0x14(r31)
    subi r12, r3, 0x496c
    addi r30, r31, 0x58
    mtlr r12
    addi r3, r30, 0x0
    clrlwi r4, r0, 24
    blrl
    lwz r0, 0x20(r30)
    stw r0, 0x24(r30)
    lfs f1, 0x0(r30)
    lfs f2, 0x4(r30)
    bl get_card_from_stick
    stw r3, 0x20(r30)
    li r0, 0x0
    srwi r4, r0, 31
    lwz r5, 0x20(r30)
    srawi r3, r5, 31
    subfc r0, r0, r5
    adde r0, r3, r4
    stw r0, 0x1c(r31)
    lwz r0, 0x20(r30)
    stw r0, 0x20(r31)
    lwz r0, 0x78(r31)
    cmpwi r0, 0x0
    blt label_0xe94
    lwz r3, 0x20(r30)
    lwz r0, 0x24(r30)
    cmpw r3, r0
    beq label_0xe94
    li r3, 0x1
    branchl r12, SFX_Menu_CommonSound
  label_0xe94:
    lwz r0, 0x70(r31)
    li r4, 0x0
    lwz r5, 0x74(r31)
    li r3, 0x100
    and r0, r0, r4
    and r3, r5, r3
    xor r3, r3, r4
    xor r0, r0, r4
    or. r0, r3, r0
    beq label_0xf10
    lwz r0, 0x1c(r31)
    cmpwi r0, 0x0
    beq label_0xf08
    li r3, 0x2
    branchl r12, SFX_Menu_CommonSound
    mr r3, r31
    lwz r4, 0x20(r31)
    bl apply_card_to_player
    li r3, 0x4
    branchl r12, Scene_ClearPauseFlag
    branchl r12, Camera_SetNormal
    lfs f0, RTOC_0(rtoc)
    lis r3, 0x8047
    stfs f0, 0x2e38(r3)
    stfs f0, 0x2e3c(r3)
    branchl r12, Match_EnableHud
    li r0, 0x3
    stw r0, 0x0(r31)
    b label_0xf10
  label_0xf08:
    li r3, 0x3
    branchl r12, SFX_Menu_CommonSound
  label_0xf10:
    lwz r0, 0x2c(r1)
    lwz r31, 0x24(r1)
    lwz r30, 0x20(r1)
    addi r1, r1, 0x28
    mtlr r0
blr


#----------------------------------------------------------------------------#
# StockRun_TriggerMidGameSelect
#   r3 = slot
StockRun_TriggerMidGameSelect:
    mflr r0
    lis r5, stc_matchcam@ha
    stw r0, 0x4(r1)
    lis r4, stc_cam_settings@ha
    stwu r1, -0x28(r1)
    stw r31, 0x24(r1)
    lis r31, 0x804a
    stw r30, 0x20(r1)
    addi r30, r4, stc_cam_settings@l
    stw r29, 0x1c(r1)
    addi r29, r5, stc_matchcam@l
    stw r28, 0x18(r1)
    addi r28, r3, 0x0
    lwz r6, 0x304c(r31)
    cmplwi r6, 0x0
    beq label_0x1100
    lwz r0, 0x0(r6)
    cmpwi r0, 0x3
    beq label_0x1064
    b label_0x1100
  label_0x1064:
    stw r28, 0x14(r6)
    li r3, 0x4
    branchl r12, Scene_SetPauseFlag
    lwz r31, 0x304c(r31)
    mr r3, r28
    branchl r12, PlayerBlock_GetGObj
    addi r4, r1, 0xc
    branchl r12, Player_GetPosition
    extsb r3, r28
    branchl r12, Camera_SetMode3
    lfs f0, RTOC_0_1(rtoc)
    stfs f0, 0x1cc(r30)
    stfs f0, 0x1d0(r30)
    lfs f0, RTOC_10(rtoc)
    stfs f0, 0x1d4(r30)
    lfs f1, 0xc(r1)
    lfs f0, RTOC_0(rtoc)
    fcmpo cr0, f1, f0
    cror eq, gt, eq
    bne label_0x10bc
    lfs f0, RTOC_N_0_5(rtoc)
    b label_0x10c0
  label_0x10bc:
    lfs f0, RTOC_0_5(rtoc)
  label_0x10c0:
    stfs f0, 0xb0(r31)
    lis r5, 0x804a
    li r4, 0x5
    lfs f0, RTOC_0_2(rtoc)
    li r3, 0x1e
    li r0, 0x2
    stfs f0, 0xb4(r31)
    lfs f0, 0xb0(r31)
    stfs f0, 0x2c8(r29)
    lfs f0, 0xb4(r31)
    stfs f0, 0x2cc(r29)
    stw r28, 0x293c(r29)
    lwz r5, 0x304c(r5)
    stw r4, 0x4(r5)
    stw r3, 0x18(r5)
    stw r0, 0x0(r5)
  label_0x1100:
    lwz r0, 0x2c(r1)
    lwz r31, 0x24(r1)
    lwz r30, 0x20(r1)
    lwz r29, 0x1c(r1)
    lwz r28, 0x18(r1)
    addi r1, r1, 0x28
    mtlr r0
blr


EXIT:
  restore
  lwz	r12, 0x0044 (r31)