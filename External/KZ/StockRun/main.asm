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
# fsquare
#   f1 = x
#   returns: f1
fsquare:
    fmuls f1, f1, f1
blr


#----------------------------------------------------------------------------#
# fminf
#   f1 = a
#   f2 = b
#   returns: f1
fminf:
    fcmpo cr0, f1, f2
    blelr
    fmr f1, f2
blr


#----------------------------------------------------------------------------#
# is_stick_active
#   f1 = x
#   f2 = y
is_stick_active:
    mflr r0
    stw r0, 0x4(r1)
    stwu r1, -0x20(r1)
    stfd f31, 0x18(r1)
    stfd f30, 0x10(r1)
    fmr f30, f1
    fmr f1, f2
    bl fsquare
    fmr f31, f1
    fmr f1, f30
    bl fsquare
    fadds f1, f1, f31
    lfs f0, RTOC_0_015625(rtoc)
    fcmpo cr0, f1, f0
    mfcr r0
    extrwi r3, r0, 1, 1
    lwz r0, 0x24(r1)
    lfd f31, 0x18(r1)
    lfd f30, 0x10(r1)
    addi r1, r1, 0x20
    mtlr r0
blr


#----------------------------------------------------------------------------#
# get_card_from_stick
#   f1 = x
#   f2 = y
#   returns: r3 = int direction
get_card_from_stick:
    mflr r0
    stw r0, 0x4(r1)
    stwu r1, -0x28(r1)
    stfd f31, 0x20(r1)
    fmr f31, f2
    stfd f30, 0x18(r1)
    fmr f30, f1
    bl is_stick_active
    cmpwi r3, 0x0
    bne label_0x2a0
    li r3, -0x1
    b label_0x318
  label_0x2a0:
    fmr f1, f31
    fmr f2, f30
    branchl r12, atan2
    lfs f0, RTOC_M_PI_4(rtoc)
    fneg f2, f0
    fcmpo cr0, f1, f2
    ble label_0x2d0
    fcmpo cr0, f1, f0
    cror eq, lt, eq
    bne label_0x2d0
    li r3, 0x1
    b label_0x318
  label_0x2d0:
    lfs f0, RTOC_M_PI_4(rtoc)
    fcmpo cr0, f1, f0
    ble label_0x2f4
    lfs f0, RTOC_2_3561945(rtoc)
    fcmpo cr0, f1, f0
    cror eq, lt, eq
    bne label_0x2f4
    li r3, 0x0
    b label_0x318
  label_0x2f4:
    fcmpo cr0, f1, f2
    bge label_0x314
    lfs f0, RTOC_2_3561945(rtoc)
    fneg f0, f0
    fcmpo cr0, f1, f0
    cror eq, gt, eq
    bne label_0x314
    li r3, 0x2
    b label_0x318
  label_0x314:
    li r3, 0x3
  label_0x318:
    lwz r0, 0x2c(r1)
    lfd f31, 0x20(r1)
    lfd f30, 0x18(r1)
    addi r1, r1, 0x28
    mtlr r0
blr

#----------------------------------------------------------------------------#
# apply_blur
#   f1 = amount
apply_blur:
    mflr r0
    stw r0, 0x4(r1)
    stwu r1, -0x20(r1)
    stfd f31, 0x18(r1)
    fmr f31, f1
    stw r31, 0x14(r1)
    lis r31, 0x8047
    lfs f0, 0x2e34(r31)
    lfs f2, RTOC_1(rtoc)
    fadds f1, f0, f31
    bl fminf
    stfs f1, 0x2e34(r31)
    lfs f0, 0x2e38(r31)
    lfs f2, RTOC_1(rtoc)
    fadds f1, f0, f31
    bl fminf
    stfs f1, 0x2e38(r31)
    lwz r0, 0x24(r1)
    lfd f31, 0x18(r1)
    lwz r31, 0x14(r1)
    addi r1, r1, 0x20
    mtlr r0
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
    stfs f0, 0x2e34(r3)
    stfs f0, 0x2e38(r3)
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
    stwu r1, -0x18(r1)
    stw r31, 0x14(r1)
    stw r30, 0x10(r1)
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
    lfs f1, 0x0(r31)
    lfs f2, 0x4(r31)
    bl get_card_from_stick
    stw r3, 0x20(r31)
    li r0, 0x0
    srwi r4, r0, 31
    lwz r5, 0x20(r31)
    srawi r3, r5, 31
    subfc r0, r0, r5
    adde r0, r3, r4
    stw r0, 0x1c(r30)
    lwz r0, 0x20(r31)
    stw r0, 0x20(r30)
    lwz r0, 0x1c(r1)
    lwz r31, 0x14(r1)
    lwz r30, 0x10(r1)
    addi r1, r1, 0x18
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
    lis r6, ...bss.0@ha
    stw r0, 0x4(r1)
    lis r5, ...data.0@ha
    stwu r1, -0x30(r1)
    stw r31, 0x2c(r1)
    addi r31, r5, ...data.0@l
    stw r30, 0x28(r1)
    addi r30, r6, ...bss.0@l
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
    stw r0, 0x4(r1)
    stwu r1, -0x18(r1)
    stw r31, 0x14(r1)
    mr r31, r3
    lwz r3, 0x10(r3)
    addi r0, r3, 0x1
    stw r0, 0x10(r31)
    lwz r0, 0x10(r31)
    cmpwi r0, 0x2
    blt label_0x608
    li r3, 0x4
    branchl r12, Scene_ClearPauseFlag
    branchl r12, Camera_SetNormal
    bl reset_visual
    li r0, 0x3
    stw r0, 0x0(r31)
    b label_0x644
  label_0x608:
    slwi r0, r0, 2
    add r3, r31, r0
    lwz r0, 0x8(r3)
    mr r3, r31
    stw r0, 0x14(r31)
    lwz r4, 0x14(r31)
    bl setup_camera_for_player
    mr r3, r31
    bl refresh_cards
    mr r3, r31
    bl update_card_panels
    addi r3, r31, 0x0
    li r4, 0x1
    li r5, 0x1e
    bl start_transition
  label_0x644:
    lwz r0, 0x1c(r1)
    lwz r31, 0x14(r1)
    addi r1, r1, 0x18
    mtlr r0
blr


#----------------------------------------------------------------------------#
# handle_init_state
#   r3 = stockrun data
handle_init_state:
    mflr r0
    stw r0, 0x4(r1)
    stwu r1, -0x18(r1)
    stw r31, 0x14(r1)
    addi r31, r3, 0x0
    li r3, 0x4
    branchl r12, Scene_SetPauseFlag
    li r0, 0x0
    stw r0, 0x10(r31)
    mr r3, r31
    lwz r0, 0x8(r31)
    stw r0, 0x14(r31)
    lwz r4, 0x14(r31)
    bl setup_camera_for_player
    mr r3, r31
    bl refresh_cards
    mr r3, r31
    bl update_card_panels
    addi r3, r31, 0x0
    li r4, 0x1
    li r5, 0x1e
    bl start_transition
    lwz r0, 0x1c(r1)
    lwz r31, 0x14(r1)
    addi r1, r1, 0x18
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
    mr r31, r3
    bl update_input_state
    mr r3, r31
    bl handle_hover_sound
    lwz r0, 0x70(r31)
    li r4, 0x0
    lwz r5, 0x74(r31)
    li r3, 0x100
    and r0, r0, r4
    and r3, r5, r3
    xor r3, r3, r4
    xor r0, r0, r4
    or. r0, r3, r0
    beq label_0x740
    lwz r0, 0x1c(r31)
    cmpwi r0, 0x0
    beq label_0x738
    li r3, 0x2
    branchl r12, SFX_Menu_CommonSound
    mr r3, r31
    lwz r4, 0x20(r31)
    bl apply_card_to_player
    mr r3, r31
    bl advance_to_next_player
    b label_0x740
  label_0x738:
    li r3, 0x3
    branchl r12, SFX_Menu_CommonSound
  label_0x740:
    lwz r0, 0x1c(r1)
    lwz r31, 0x14(r1)
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
    mflr r0
    stw r0, 0x4(r1)
    stwu r1, -0x18(r1)
    stw r31, 0x14(r1)
    mr r31, r3
    lfs f1, RTOC_0_015625(rtoc)
    bl apply_blur
    lwz r3, 0x18(r31)
    subi r0, r3, 0x1
    stw r0, 0x18(r31)
    lwz r0, 0x18(r31)
    cmpwi r0, 0x0
    bgt label_0x7c0
    li r0, 0x5
    stw r0, 0x0(r31)
    mr r3, r31
    bl update_card_panels
  label_0x7c0:
    lwz r0, 0x1c(r1)
    lwz r31, 0x14(r1)
    addi r1, r1, 0x18
    mtlr r0
blr


#----------------------------------------------------------------------------#
# handle_vs_card_select_state
#   r3 = stockrun data
handle_vs_card_select_state:
    mflr r0
    stw r0, 0x4(r1)
    stwu r1, -0x18(r1)
    stw r31, 0x14(r1)
    mr r31, r3
    bl update_input_state
    mr r3, r31
    bl handle_hover_sound
    lwz r0, 0x70(r31)
    li r4, 0x0
    lwz r5, 0x74(r31)
    li r3, 0x100
    and r0, r0, r4
    and r3, r5, r3
    xor r3, r3, r4
    xor r0, r0, r4
    or. r0, r3, r0
    beq label_0x860
    lwz r0, 0x1c(r31)
    cmpwi r0, 0x0
    beq label_0x858
    li r3, 0x2
    branchl r12, SFX_Menu_CommonSound
    mr r3, r31
    lwz r4, 0x20(r31)
    bl apply_card_to_player
    li r3, 0x4
    branchl r12, Scene_ClearPauseFlag
    branchl r12, Camera_SetNormal
    bl reset_visual
    li r0, 0x3
    stw r0, 0x0(r31)
    b label_0x860
label_0x858:
    li r3, 0x3
    branchl r12, SFX_Menu_CommonSound
label_0x860:
    lwz r0, 0x1c(r1)
    lwz r31, 0x14(r1)
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
    stwu r1, -0x18(r1)
    stw r31, 0x14(r1)
    lwz r0, -0x62a4(r4)
    lwz r31, 0x2c(r3)
    cmpwi r0, 0x40
    blt label_0x924
    cmpwi r0, 0x90
    bgt label_0x8a8
    lfs f1, RTOC_0_015625(rtoc)
    bl apply_blur
  label_0x8a8:
    lwz r0, 0x0(r31)
    cmpwi r0, 0x3
    beq label_0x904
    bge label_0x8d0
    cmpwi r0, 0x1
    beq label_0x8ec
    bge label_0x8f8
    cmpwi r0, 0x0
    bge label_0x8e0
    b label_0x924
  label_0x8d0:
    cmpwi r0, 0x5
    beq label_0x91c
    bge label_0x924
    b label_0x910
  label_0x8e0:
    mr r3, r31
    bl handle_init_state
    b label_0x924
  label_0x8ec:
    mr r3, r31
    bl handle_card_select_state
    b label_0x924
  label_0x8f8:
    mr r3, r31
    bl handle_transition_state
    b label_0x924
  label_0x904:
    mr r3, r31
    bl handle_vs_state
    b label_0x924
  label_0x910:
    mr r3, r31
    bl handle_vs_transition_state
    b label_0x924
  label_0x91c:
    mr r3, r31
    bl handle_vs_card_select_state
  label_0x924:
    lwz r0, 0x1c(r1)
    lwz r31, 0x14(r1)
    addi r1, r1, 0x18
    mtlr r0
blr

#----------------------------------------------------------------------------#
# StockRun_TriggerMidGameSelect
#   r3 = slot
StockRun_TriggerMidGameSelect:
    mflr r0
    stw r0, 0x4(r1)
    stwu r1, -0x18(r1)
    stw r31, 0x14(r1)
    lis r31, 0x804a
    stw r30, 0x10(r1)
    addi r30, r3, 0x0
    lwz r4, 0x304c(r31)
    cmplwi r4, 0x0
    beq label_0xa94
    lwz r0, 0x0(r4)
    cmpwi r0, 0x3
    beq label_0xa5c
    b label_0xa94
  label_0xa5c:
    stw r30, 0x14(r4)
    li r3, 0x4
    branchl r12, Scene_SetPauseFlag
    lwz r3, 0x304c(r31)
    mr r4, r30
    bl setup_camera_for_player
    lwz r3, 0x304c(r31)
    bl refresh_cards
    lwz r3, 0x304c(r31)
    bl update_card_panels
    lwz r3, 0x304c(r31)
    li r4, 0x5
    li r5, 0x1e
    bl start_transition
  label_0xa94:
    lwz r0, 0x1c(r1)
    lwz r31, 0x14(r1)
    lwz r30, 0x10(r1)
    addi r1, r1, 0x18
    mtlr r0
blr

#==============================================================================#

EXIT:
  restore
  lwz	r12, 0x0044(r31)