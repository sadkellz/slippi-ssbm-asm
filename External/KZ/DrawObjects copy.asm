################################################################################
# Address: 0x802ff4e4
################################################################################

.include "Common/Common.s"
.include "KZ/HSD_GOBJ.s"
.include "KZ/HSD_COBJ.s"
.include "KZ/HSD_JOBJ.s"
.include "KZ/HSD_PAD.s"
.include "KZ/PLAYER.s"
.include "KZ/MATH.s"
.include "KZ/GX.s"
.include "KZ/StageHeader.s"
.include "KZ/KZ_COMMON.s"

# replaced code
stw	r3, 0 (r31)

b CODE_START

COBJDESC_BLRL:
blrl
.set DESC_NAME, 0
  .long 0
.set DESC_FLAGS, DESC_NAME + 4
  .short 0
.set DESC_PROJTYPE, DESC_FLAGS + 2
  .short 1
.set DESC_VIEWP_L, DESC_PROJTYPE + 2
.set DESC_VIEWP_R, DESC_VIEWP_L + 2
.set DESC_VIEWP_T, DESC_VIEWP_R + 2
.set DESC_VIEWP_B, DESC_VIEWP_T + 2
  # center is 640x480
  .short 0
  .short 640
  .short 0
  .short 480
.set DESC_SCISSOR_L, DESC_VIEWP_B + 2
.set DESC_SCISSOR_R, DESC_SCISSOR_L + 2
.set DESC_SCISSOR_T, DESC_SCISSOR_R + 2
.set DESC_SCISSOR_B, DESC_SCISSOR_T + 2
  .short 0
  .short 640
  .short 0
  .short 480
.set DESC_EYEDESC, DESC_SCISSOR_B + 2
.set DESC_INTERESTDESC, DESC_EYEDESC + 4
  .long 0
  .long 0
.set DESC_ROLL, DESC_INTERESTDESC + 4
  .float 0
.set DESC_UPVEC, DESC_ROLL + 4
  .long 0
.set DESC_NEAR, DESC_UPVEC + 4
.set DESC_FAR, DESC_NEAR + 4
  .float 1
  .float 3500
.set DESC_FOV, DESC_FAR + 4
  .float 60
.set DESC_ASPECT, DESC_FOV + 4
  .float 1.217

EYEDESC_BLRL:
blrl
.set EYE_NAME, 0
  .long 0
.set EYE_POS, EYE_NAME + 4
  .float 0
  .float 0
  .float 350
.set EYE_ROBJ, EYE_POS + 12
  .long 0

INTDESC_BLRL:
blrl
.set INT_NAME, 0
  .long 0
.set INT_POS, INT_NAME + 4
  .float 0
  .float 1
  .float 0
.set INT_ROBJ, INT_POS + 12
  .long 0

.set REG_GOBJ, 31
.set REG_COBJ, 30
.set REG_DATA, 29
.set REG_CAMGOBJ, 28

.set FREG_LEFT, 31
.set FREG_RIGHT, 30
.set FREG_TOP, 29
.set FREG_BOTTOM, 28
.set FREG_W, 27
.set FREG_H, 26

.set GXPRIO, 8
.set GXLINK, 31
.set PLINK_PRIO, 0


CODE_START:
  backup

# setup cobj desc
  bl COBJDESC_BLRL
  mflr REG_DATA

  bl EYEDESC_BLRL
  mflr r3
  bl INTDESC_BLRL
  mflr r4
  stw r3, DESC_EYEDESC(REG_DATA)
  stw r4, DESC_INTDESC(REG_DATA)

CREATE_GOBJ:
# create our cam gobj and init
  gobj_create GOBJ_CLASS_CAMERA, GOBJ_PLINK_HUD, PLINK_PRIO, REG_CAMGOBJ

  # load r3, DevelopCobjDesc
  mr r3, REG_DATA
  branchl r12, HSD_CObjCreate
  mr r5, r3
  mr r3, REG_CAMGOBJ
  li r4, GOBJ_KIND_COBJ
  branchl r12, GObj_AddObj

  mr r3, REG_CAMGOBJ
  bl FN_GXProc
  mflr r4
  li r5, GXPRIO
  branchl r12, GObj_InitCamera

# set gxlink prios
  li r3, 0
  li r4, 1
  li r5, GXLINK
  branchl r12, shl2i # stolen from devtext
  stw r3, GOBJ_GXLINK_PRIOS(REG_CAMGOBJ)
  stw r4, GOBJ_GXLINK_PRIOS+4(REG_CAMGOBJ)

# render gobj
  gobj_create GOBJ_CLASS_UI, GOBJ_PLINK_UI, 0, REG_GOBJ

  mr r3, REG_GOBJ
  bl FN_CustomGX
  mflr r4
  li r5, GXLINK
  li r6, GXPRIO
  branchl r12, GObj_SetupGXLink

# disable regular visuals
  # li r3, 0
  # branchl r12, 0x80030aa4

li r3, 0xFF
load r4, stc_matchcam
stb r3, 0x398(r4)

li r3, 1
load r4, 0x804d6d6c
stb r3, 0(r4)

  b EXIT











################################################################################
################################################################################

FN_GXProc:
blrl

b FN_GXProc_Body

.set REG_GOBJ, 31
.set REG_COBJ, 30
.set REG_PAD, 21

FN_GXProc_Body:
  backup

  mr REG_GOBJ, r3
  lwz REG_COBJ, GOBJ_OBJ(REG_GOBJ)

  mr r3, REG_COBJ
  branchl r12, HSD_CObjSetMtxDirty

RENDER:
  mr r3, REG_COBJ
  branchl r12, HSD_CObjSetCurrent
  cmpwi r3, 0
  beq FN_GXProc_Exit

  mr r3, REG_GOBJ
  li r4, 1 # unsure what mask to use
  branchl r12, GObj_RenderWithPassMask

  load r3, -1
  branchl r12, HSD_StateInvalidate

  branchl r12, HSD_CObjEndCurrent
  

FN_GXProc_Exit:
  restore
  blr


################################################################################
################################################################################

FN_CustomGX:
blrl

.set REG_GOBJ, 31
.set REG_COBJ, 30
.set REG_DATA, 29
.set REG_MTX, 28
.set REG_CLR, 27
.set REG_GXPIPE, 26
.set REG_CMSUB, 25
.set REG_PLINKS, 24
.set REG_PLAYER, 23
.set REG_FT, 22

.set FREG_LEFT, 31
.set FREG_RIGHT, 30
.set FREG_TOP, 29
.set FREG_BOTTOM, 28

.set FREG_X, 20
.set FREG_Y, 21
.set FREG_X2, 22
.set FREG_Y2, 23
.set FREG_Z, 24
.set FREG_Z2, 25

.set LINE_WIDTH, 8
.set POINT_WIDTH, 32

.set DrawBzones, 0x8005a340

.set SP_MTX, BKP_FREE_SPACE_OFFSET
.set SP_COLOR, SP_MTX + 44

FN_CustomGX_Body:
  backup

  mr REG_GOBJ, r3
  # lwz REG_COBJ, GOBJ_OBJ(REG_GOBJ)

# GX Setup
  load REG_GXPIPE, STC_GXPIPE

  branchl r12, HSD_CObjGetCurrent
  mr REG_COBJ, r3

  mr r3, REG_COBJ
  branchl r12, HSD_LObjSetupInit

  li r3, 0
  branchl r12, GXSetCullMode
  branchl r12, GXClearVtxDesc

  li r3, GX_VA_POS
  li r4, GX_DIRECT
  branchl r12, GXSetVtxDesc

  li r3, GX_VTXFMT0
  li r4, GX_VA_POS
  li r5, 1
  li r6, 4
  li r7, 0
  branchl r12, GXSetVtxAttrFmt

  mr r3, REG_COBJ
  addi r4, sp, SP_MTX
  branchl r12, HSD_CObjGetViewingMtx

  li r3, 0
  branchl r12, GXSetCurrentMtx

  addi r3, sp, SP_MTX
  li r4, 0
  branchl r12, GXLoadPosMtxImm

####################### BLASTZONE
  get_blastzones FREG_LEFT, FREG_RIGHT, FREG_TOP, FREG_BOTTOM

  load r3, 0xFFFFFFFF
  stw r3, SP_COLOR(sp)

  addi r3, sp, SP_COLOR
  branchl r12, HSD_SetDrawColor

  li r3, 1
  li r4, 3
  li r5, 0
  branchl r12, GXSetZMode

  li r3, LINE_WIDTH
  li r4, 0
  branchl r12, GXSetLineWidth

  li r3, GX_LINESTRIP
  li r4, GX_VTXFMT0
  li r5, 5
  branchl r12, GXBegin

  GXPosition3f32 FREG_LEFT, FREG_BOTTOM, f15, REG_GXPIPE
  GXPosition3f32 FREG_RIGHT, FREG_BOTTOM, f15, REG_GXPIPE
  GXPosition3f32 FREG_RIGHT, FREG_TOP, f15, REG_GXPIPE
  GXPosition3f32 FREG_LEFT, FREG_TOP, f15, REG_GXPIPE
  GXPosition3f32 FREG_LEFT, FREG_BOTTOM, f15, REG_GXPIPE

####################### CAM LIMITS
  get_camlimits FREG_LEFT, FREG_RIGHT, FREG_TOP, FREG_BOTTOM

  # load r3, 0xFFFFFFFF
  # stw r3, SP_COLOR(sp)

  addi r3, sp, SP_COLOR
  branchl r12, HSD_SetDrawColor

  li r3, 1
  li r4, 3
  li r5, 0
  branchl r12, GXSetZMode

  li r3, LINE_WIDTH
  li r4, 0
  branchl r12, GXSetLineWidth

  li r3, GX_LINESTRIP
  li r4, GX_VTXFMT0
  li r5, 5
  branchl r12, GXBegin

  GXPosition3f32 FREG_LEFT, FREG_BOTTOM, f15, REG_GXPIPE
  GXPosition3f32 FREG_RIGHT, FREG_BOTTOM, f15, REG_GXPIPE
  GXPosition3f32 FREG_RIGHT, FREG_TOP, f15, REG_GXPIPE
  GXPosition3f32 FREG_LEFT, FREG_TOP, f15, REG_GXPIPE
  GXPosition3f32 FREG_LEFT, FREG_BOTTOM, f15, REG_GXPIPE

####################### PLAYER POINTS
  load r3, 0xFF00007F
  stw r3, SP_COLOR(sp)

  addi r3, sp, SP_COLOR
  branchl r12, HSD_SetDrawColor

  li r3, 1
  li r4, 3
  li r5, 0
  branchl r12, GXSetZMode

  li r3, 8
  li r4, 0
  branchl r12, GXSetPointSize

  loadwz REG_PLINKS, STC_PLINKLIST
  lwz REG_PLAYER, GOBJ_PLINKLIST_PLAYERS(REG_PLINKS)
  cmpwi REG_PLAYER, 0
  beq COLLISION
  
  
backup
.set SP_IDX, BKP_FREE_SPACE_OFFSET
.set SP_POS1, SP_IDX + 4
.set SP_POS2, SP_POS1 + SZ_VEC3
.set REG_JOBJ, 15
.set REG_ARGS, 16
.set REG_CHILD, 17

  PLAYER_LOOP:
    lwz REG_FT, GOBJ_USERDATA(REG_PLAYER)
    mr r3, REG_PLAYER
    branchl r12, Player_IsDead
    cmpwi r3, 1
    beq PLAYER_LOOP_CHECK

    li r0, 0
    stw r0, SP_IDX(sp)

    lwz r3, GOBJ_OBJ(REG_PLAYER)
    bl DRAW_JOBJ_POINT
    mflr r4
    addi r5, sp, BKP_FREE_SPACE_OFFSET
    branchl r12, 0x8036f0f0 # walk tree

    li r3, -1
    branchl r12, HSD_StateInvalidate
    b PLAYER_LOOP_CHECK

  DRAW_JOBJ_POINT:
    blrl
    backup
    mr REG_JOBJ, r3
    mr REG_ARGS, r4

    lwz r3, 0(REG_ARGS)
    cmpwi r3, 4
    blt DRAW_JOBJ_INC

    lwz REG_CHILD, JOBJ_CHILD(REG_JOBJ)
    cmpwi REG_CHILD, 0
    beq DRAW_JOBJ_INC

    bp
    lwz r3, GOBJ_USERDATA(REG_PLAYER)
    lwz r3, FT_BONES(r3)
    lwz r0, 0(REG_ARGS)
    mulli r0, r0, SZ_BONE
    add r3, r3, r0
    addi r3, r3, 0x10 # child
    lbz r0, BONES_FLAGS1(r3)
    andi. r0, r0, 0x80
    bne DRAW_JOBJ_INC

    lfs f0, RTOC_0(rtoc)

  CHECK_PARENT_BONE:
    lfs FREG_X, 0x50(REG_JOBJ)
    lfs FREG_Y, 0x60(REG_JOBJ)
    lfs FREG_Z, 0x70(REG_JOBJ)
    fcmpo cr0, FREG_X, f0
    bne CHECK_CHILD_BONE
    fcmpo cr0, FREG_Y, f0
    beq DRAW_JOBJ_INC

  CHECK_CHILD_BONE:
    lfs FREG_X2, 0x50(REG_CHILD)
    lfs FREG_Y2, 0x60(REG_CHILD)
    lfs FREG_Z2, 0x70(REG_CHILD)
    fcmpo cr0, FREG_X2, f0
    bne BONE_DRAW
    fcmpo cr0, FREG_Y2, f0
    beq DRAW_JOBJ_INC

  BONE_DRAW:
    li r3, GX_LINES
    li r4, GX_VTXFMT0
    li r5, 2
    branchl r12, GXBegin 

    GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE
    GXPosition3f32 FREG_X2, FREG_Y2, FREG_Z2, REG_GXPIPE

    DRAW_JOBJ_INC:
      lwz r3, 0(REG_ARGS)
      addi r3, r3, 1
      DRAW_JOBJ_INC_STORE:
      stw r3, 0(REG_ARGS)

    DRAW_JOBJ_POINT_EXIT:
      restore
      blr

  PLAYER_LOOP_CHECK:
    lwz REG_PLAYER, GOBJ_NEXT(REG_PLAYER)
    cmpwi REG_PLAYER, 0
    bne PLAYER_LOOP

restore

###################### Collisions
COLLISION:
  load r3, 0xFFFFFFFF
  stw r3, SP_COLOR(sp)

  addi r3, sp, SP_COLOR
  branchl r12, HSD_SetDrawColor

  li r3, 1
  li r4, 3
  li r5, 0
  branchl r12, GXSetZMode

  li r3, 6
  li r4, 0
  branchl r12, GXSetLineWidth

  bl FN_DrawPlatforms

FN_CustomGX_Exit:
  restore
  blr

################################################################################
################################################################################

.set REG_LINES, 31
.set REG_LINE_COUNT, 30
.set REG_PARAMS, 29
.set REG_VTX, 28
.set REG_CURDESC, 27
.set REG_VAR, 25

FN_DrawPlatforms:
  backup

  loadwz REG_LINES, COLL_LINE
  loadwz REG_PARAMS, COLL_PARAM
  loadwz REG_VTX, COLL_VTX

  lwz REG_LINE_COUNT, COLL_PARAM_LINECOUNT(REG_PARAMS)

  get_blastzones FREG_LEFT, FREG_RIGHT, FREG_TOP, FREG_BOTTOM

  LINE_POINT_LOOP:
    # check if solid
    lwz r0, COLL_LINE_FLAGS(REG_LINES)
    rlwinm. r0, r0, 0, 15, 15
    beq LINE_POINT_LOOP_CHECK

    # unk flag check, active?
    lwz r0, COLL_LINE_FLAGS(REG_LINES)
    rlwinm. r0, r0, 0, 13, 13
    bne LINE_POINT_LOOP_CHECK

    lwz REG_CURDESC, COLL_LINE_DESC(REG_LINES)
    lhz r0, 0(REG_CURDESC) # point
    mulli r0, r0, SZ_VTX
    add REG_VAR, REG_VTX, r0
    lfs FREG_X, 0x8(REG_VAR)
    lfs FREG_Y, 0xC(REG_VAR)

    CHECK_X:
      fcmpo cr0, FREG_X, FREG_LEFT
      blt SET_MIN_X
      fcmpo cr0, FREG_X, FREG_RIGHT
      bgt SET_MAX_X
      b CHECK_Y

      SET_MIN_X:
        fmr FREG_X, FREG_LEFT
        b CHECK_Y
      
      SET_MAX_X:
        fmr FREG_X, FREG_RIGHT

    CHECK_Y:
      fcmpo cr0, FREG_Y, FREG_BOTTOM
      blt SET_MIN_Y
      fcmpo cr0, FREG_Y, FREG_TOP
      bgt SET_MAX_Y
      b P_2

      SET_MIN_Y:
        fmr FREG_Y, FREG_BOTTOM
        b P_2

      SET_MAX_Y:
        fmr FREG_Y, FREG_TOP
      

    P_2:
    lhz r0, 0x2(REG_CURDESC) # point2
    mulli r0, r0, SZ_VTX
    add REG_VAR, REG_VTX, r0
    lfs FREG_X2, 0x8(REG_VAR)
    lfs FREG_Y2, 0xC(REG_VAR)

        CHECK_X2:
      fcmpo cr0, FREG_X2, FREG_LEFT
      blt SET_MIN_X2
      fcmpo cr0, FREG_X2, FREG_RIGHT
      bgt SET_MAX_X2
      b CHECK_Y2

      SET_MIN_X2:
        fmr FREG_X2, FREG_LEFT
        b CHECK_Y2
      
      SET_MAX_X2:
        fmr FREG_X2, FREG_RIGHT

    CHECK_Y2:
      fcmpo cr0, FREG_Y2, FREG_BOTTOM
      blt SET_MIN_Y2
      fcmpo cr0, FREG_Y2, FREG_TOP
      bgt SET_MAX_Y2
      b BEGIN

      SET_MIN_Y2:
        fmr FREG_Y2, FREG_BOTTOM
        b BEGIN

      SET_MAX_Y2:
        fmr FREG_Y2, FREG_TOP
  
  BEGIN:
    li r3, GX_LINES
    li r4, GX_VTXFMT0
    li r5, 2
    branchl r12, GXBegin
    
    # TODO :: replace f15 with zero
    GXPosition3f32 FREG_X, FREG_Y, f15, REG_GXPIPE
    GXPosition3f32 FREG_X2, FREG_Y2, f15, REG_GXPIPE

  LINE_POINT_LOOP_CHECK:
    subi REG_LINE_COUNT, REG_LINE_COUNT, 1
    addi REG_LINES, REG_LINES, SZ_COLLLINE
    cmpwi REG_LINE_COUNT, 0
    bne LINE_POINT_LOOP

FN_DrawPlatforms_Exit:
  restore
  blr

################################################################################
################################################################################

EXIT:
  restore

