################################################################################
# Address: 0x802ff4e4
################################################################################

.include "Common/Common.s"
.include "KZ/HSD_GOBJ.s"
.include "KZ/HSD_COBJ.s"
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
  .float 500
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

  b EXIT

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

.set LINE_WIDTH, 8
.set POINT_WIDTH, 32

.set DrawBzones, 0x8005a340

.set SP_MTX, BKP_FREE_SPACE_OFFSET
.set SP_COLOR, SP_MTX + 44

FN_CustomGX_Body:
  backup

  mr REG_GOBJ, r3
  # lwz REG_COBJ, GOBJ_OBJ(REG_GOBJ)

  # branchl r12, DrawBzones

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

  li r3, POINT_WIDTH
  li r4, 0
  branchl r12, GXSetPointSize

  loadwz REG_PLINKS, STC_PLINKLIST
  lwz REG_PLAYER, GOBJ_PLINKLIST_PLAYERS(REG_PLINKS)
  cmpwi REG_PLAYER, 0
  beq COLLISION

  PLAYER_LOOP:
    lwz REG_FT, GOBJ_USERDATA(REG_PLAYER)
    mr r3, REG_PLAYER
    branchl r12, Player_IsDead
    cmpwi r3, 1

    beq PLAYER_LOOP_CHECK

    lbz r3, FT_SLOT(REG_FT)

    # branchl r12, PlayerBlock_GetPortColor
    lwz r4, -0x5194(r13) # shield colors
    mulli r3, r3, 0x4
    add r4, r4, r3
    lwz r3, 0(r4)
    stw r3, SP_COLOR(sp)

    addi r3, sp, SP_COLOR
    branchl r12, HSD_SetDrawColor

    lwz REG_CMSUB, 0x890(REG_FT) # cmsubject

    lfs FREG_X, CMSUB_FOCUS(REG_CMSUB)
    lfs FREG_Y, CMSUB_FOCUS+4(REG_CMSUB)

    li r3, GX_POINTS
    li r4, GX_VTXFMT0
    li r5, 1
    branchl r12, GXBegin
    
    # TODO :: replace f15 with zero
    GXPosition3f32 FREG_X, FREG_Y, f15, REG_GXPIPE

  PLAYER_LOOP_CHECK:
    lwz REG_PLAYER, GOBJ_NEXT(REG_PLAYER)
    cmpwi REG_PLAYER, 0
    bne PLAYER_LOOP

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

##################### Camera
  load r3, 0x00FCFFFF
  stw r3, SP_COLOR(sp)

  addi r3, sp, SP_COLOR
  branchl r12, HSD_SetDrawColor

  bl FN_DrawCamera

FN_CustomGX_Exit:
  restore
  blr

################################################################################
################################################################################

FN_GXProc:
blrl

b FN_GXProc_Body

.set REG_GOBJ, 31
.set REG_COBJ, 30
.set REG_COUNT, 20
.set REG_PAD, 21

FN_GXProc_Body:
  backup

  mr REG_GOBJ, r3
  lwz REG_COBJ, GOBJ_OBJ(REG_GOBJ)

  # rotate camera from cstick
  li REG_COUNT, 0
  ROTATE_CAM_LOOP:
    mr r3, REG_COUNT
    get_port_pad r3
    mr REG_PAD, r3

    lfs f0, RTOC_STICKTHRESH(rtoc)
    lfs f1, PAD_cstick_x(REG_PAD)
    fabs f3, f1
    fcmpo cr0, f3, f0
    bgt CHECK_STICKY
      lfs f1, RTOC_ZERO(rtoc)

    CHECK_STICKY:
      lfs f2, PAD_cstick_y(REG_PAD)
      fabs f3, f2
      fcmpo cr0, f3, f0
      bgt EXEC_CAM_ORBIT
      lfs f2, RTOC_ZERO(rtoc)

    EXEC_CAM_ORBIT:
      mr r3, REG_GOBJ
      lwz r4, COBJ_EYE_POS(REG_COBJ)
      addi r4, r4, 0xC
      lwz r5, COBJ_INTEREST(REG_COBJ)
      addi r5, r5, 0xC
      branchl r12, DevelopCam_OrbitCam

    CHECK_ZPOS:
      lwz r5, COBJ_EYE_POS(REG_COBJ)

      lwz r3, PAD_button_repeated(REG_PAD)
      andi. r3, r3, PAD_BTN_DPadLeft
      bne ZPOS_INC
      lwz r3, PAD_button_pressed(REG_PAD)
      andi. r3, r3, PAD_BTN_DPadLeft
      bne ZPOS_INC

      lwz r3, PAD_button_repeated(REG_PAD)
      andi. r3, r3, PAD_BTN_DPadRight
      bne ZPOS_DEC
      lwz r3, PAD_button_pressed(REG_PAD)
      andi. r3, r3, PAD_BTN_DPadRight
      bne ZPOS_DEC

      lwz r3, PAD_button_repeated(REG_PAD)
      andi. r3, r3, PAD_BTN_DPadDown
      bne RESET_CAM
      lwz r3, PAD_button_pressed(REG_PAD)
      andi. r3, r3, PAD_BTN_DPadDown
      bne RESET_CAM
      b ROTATE_CAM_LOOP_CHECK

      ZPOS_INC:
        lfs f0, RTOC_HUND(rtoc)
        lfs f1, 0xC+Z(r5)
        fadds f1, f1, f0
        stfs f1, 0xC+Z(r5)
        b ROTATE_CAM_LOOP_CHECK

      ZPOS_DEC:
        lfs f0, RTOC_HUND(rtoc)
        fneg f0, f0
        lfs f1, 0xC+Z(r5)
        fadds f1, f1, f0
        stfs f1, 0xC+Z(r5)
        b ROTATE_CAM_LOOP_CHECK

      RESET_CAM:
        lfs f1, RTOC_ZERO(rtoc)
        stfs f1, 0xC+X(r5)
        stfs f1, 0xC+Y(r5)
        stfs f1, COBJ_PITCH(REG_COBJ)
        stfs f1, COBJ_YAW(REG_COBJ)
        lfs f1, RTOC_HUND(rtoc)
        # lol
        fadds f1, f1, f1
        fadds f1, f1, f1
        stfs f1, 0xC+Z(r5)



  ROTATE_CAM_LOOP_CHECK:
    addi REG_COUNT, REG_COUNT, 1
    cmpwi REG_COUNT, 4
    blt ROTATE_CAM_LOOP

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

.set SP_TL, BKP_FREE_SPACE_OFFSET
.set SP_TR, SP_TL + SZ_VEC3
.set SP_BL, SP_TR + SZ_VEC3
.set SP_BR, SP_BL + SZ_VEC3
.set SP_COLOR, SP_BR + SZ_VEC3
.set SP_FTL, SP_COLOR + 4
.set SP_FTR, SP_FTL + SZ_VEC3
.set SP_FBL, SP_FTR + SZ_VEC3
.set SP_FBR, SP_FBL + SZ_VEC3
.set SP_CAMPOS, SP_FBR + SZ_VEC3
.set SP_DIFF, SP_CAMPOS + SZ_VEC3
.set SP_SCLDIFF, SP_DIFF + SZ_VEC3

# .set SP_INVVIEW, SP_MTX + 64
# .set SP_POS, SP_MTX + 64

.set REG_COUNT, 14
.set REG_CORNERS, 15
.set REG_INVVIEWPROJ, 16
.set REG_INVVIEW, 17
.set REG_PLANE, 18
.set REG_TEMP, 20

.set FREG_T, 23
.set FREG_NEARW, 24
.set FREG_FARW, 25
.set FREG_ASPECT, 26
.set FREG_FOV, 27
.set FREG_NEAR, 28
.set FREG_FAR, 29
.set FREG_NEARH, 30
.set FREG_FARH, 31

FN_DrawCamera:
  backup

  b DrawCamera_Start

DrawCamera_Start:
  branchl r12, Camera_LoadCameraEntity
  lwz REG_COBJ, GOBJ_OBJ(r3)

# init cam vals
  lfs FREG_FOV, COBJ_FOV(REG_COBJ)
  lfs f0, RTOC_DEG2RAD(rtoc)
  fmuls FREG_FOV, f0, FREG_FOV
  lfs FREG_ASPECT, COBJ_ASPECT(REG_COBJ)
  # lfs FREG_NEAR, COBJ_NEAR(REG_COBJ)
  lfs FREG_NEAR, RTOC_HUND(rtoc)
  lfs FREG_FAR, COBJ_FAR(REG_COBJ)

# tan(fov/2.0) * 2.0
  lfs f0, RTOC_TWO(rtoc)
  fdivs f1, FREG_FOV, f0
  branchl r12, tan
  lfs f0, RTOC_TWO(rtoc)
  fmuls f1, f0, f1

# get near width and height
  fmuls FREG_NEARH, f1, FREG_NEAR
  fmuls FREG_NEARW, FREG_NEARH, FREG_ASPECT

# get far width and height
  fmuls FREG_FARH, f1, FREG_FAR
  fmuls FREG_FARW, FREG_FARH, FREG_ASPECT

# alloc our corners
  li r3, SZ_VEC3 * 8
  branchl r12, HSD_MemAlloc
  mr REG_CORNERS, r3

# near top left
  lfs f0, RTOC_TWO(rtoc)
  fneg f1, FREG_NEARW
  fdivs f1, f1, f0
  stfs f1, NEAR_TL+X(REG_CORNERS)
  fdivs f1, FREG_NEARH, f0
  stfs f1, NEAR_TL+Y(REG_CORNERS)
  fneg f1, FREG_NEAR
  stfs f1, NEAR_TL+Z(REG_CORNERS)

# near top right
  lfs f0, RTOC_TWO(rtoc)
  fdivs f1, FREG_NEARW, f0
  stfs f1, NEAR_TR+X(REG_CORNERS)
  fdivs f1, FREG_NEARH, f0
  stfs f1, NEAR_TR+Y(REG_CORNERS)
  fneg f1, FREG_NEAR
  stfs f1, NEAR_TR+Z(REG_CORNERS)

# near bottom left
  lfs f0, RTOC_TWO(rtoc)
  fneg f1, FREG_NEARW
  fdivs f1, f1, f0
  stfs f1, NEAR_BL+X(REG_CORNERS)
  fneg f1, FREG_NEARH
  fdivs f1, f1, f0
  stfs f1, NEAR_BL+Y(REG_CORNERS)
  fneg f1, FREG_NEAR
  stfs f1, NEAR_BL+Z(REG_CORNERS)

# near bottom right
  lfs f0, RTOC_TWO(rtoc)
  fdivs f1, FREG_NEARW, f0
  stfs f1, NEAR_BR+X(REG_CORNERS)
  fneg f1, FREG_NEARH
  fdivs f1, f1, f0
  stfs f1, NEAR_BR+Y(REG_CORNERS)
  fneg f1, FREG_NEAR
  stfs f1, NEAR_BR+Z(REG_CORNERS)

# bot top left
  lfs f0, RTOC_TWO(rtoc)
  fneg f1, FREG_FARW
  fdivs f1, f1, f0
  stfs f1, FAR_TL+X(REG_CORNERS)
  fdivs f1, FREG_FARH, f0
  stfs f1, FAR_TL+Y(REG_CORNERS)
  fneg f1, FREG_FAR
  stfs f1, FAR_TL+Z(REG_CORNERS)

# bot top right
  lfs f0, RTOC_TWO(rtoc)
  fdivs f1, FREG_FARW, f0
  stfs f1, FAR_TR+X(REG_CORNERS)
  fdivs f1, FREG_FARH, f0
  stfs f1, FAR_TR+Y(REG_CORNERS)
  fneg f1, FREG_FAR
  stfs f1, FAR_TR+Z(REG_CORNERS)

# bot bottom left
  lfs f0, RTOC_TWO(rtoc)
  fneg f1, FREG_FARW
  fdivs f1, f1, f0
  stfs f1, FAR_BL+X(REG_CORNERS)
  fneg f1, FREG_FARH
  fdivs f1, f1, f0
  stfs f1, FAR_BL+Y(REG_CORNERS)
  fneg f1, FREG_FAR
  stfs f1, FAR_BL+Z(REG_CORNERS)

# bot bottom right
  lfs f0, RTOC_TWO(rtoc)
  fdivs f1, FREG_FARW, f0
  stfs f1, FAR_BR+X(REG_CORNERS)
  fneg f1, FREG_FARH
  fdivs f1, f1, f0
  stfs f1, FAR_BR+Y(REG_CORNERS)
  fneg f1, FREG_FAR
  stfs f1, FAR_BR+Z(REG_CORNERS)

# get camera inverse view mtx
  mr r3, REG_COBJ
  branchl r12, 0x80369624 # inverse view mtx
  mr REG_INVVIEW, r3

# near
  mr r3, REG_INVVIEW
  addi r4, REG_CORNERS, NEAR_TL
  addi r5, sp, SP_TL
  branchl r12, PSMTXMultVec

  mr r3, REG_INVVIEW
  addi r4, REG_CORNERS, NEAR_TR
  addi r5, sp, SP_TR
  branchl r12, PSMTXMultVec

  mr r3, REG_INVVIEW
  addi r4, REG_CORNERS, NEAR_BL
  addi r5, sp, SP_BL
  branchl r12, PSMTXMultVec

  mr r3, REG_INVVIEW
  addi r4, REG_CORNERS, NEAR_BR
  addi r5, sp, SP_BR
  branchl r12, PSMTXMultVec

# far
  mr r3, REG_INVVIEW
  addi r4, REG_CORNERS, FAR_TL
  addi r5, sp, SP_FTL
  branchl r12, PSMTXMultVec

  mr r3, REG_INVVIEW
  addi r4, REG_CORNERS, FAR_TR
  addi r5, sp, SP_FTR
  branchl r12, PSMTXMultVec

  mr r3, REG_INVVIEW
  addi r4, REG_CORNERS, FAR_BL
  addi r5, sp, SP_FBL
  branchl r12, PSMTXMultVec

  mr r3, REG_INVVIEW
  addi r4, REG_CORNERS, FAR_BR
  addi r5, sp, SP_FBR
  branchl r12, PSMTXMultVec

# set far plane to gameplay axis
  mr r3, REG_COBJ
  addi r4, sp, SP_CAMPOS
  branchl r12, HSD_CObjGetEyePosition

bp
addi REG_TEMP, sp, SP_FTL
li REG_COUNT, 0
SCALE_FAR_PLANE:
  mr r3, REG_TEMP
  addi r4, sp, SP_CAMPOS
  addi r5, sp, SP_DIFF
  branchl r12, PSVECSubtract

  # t
  lfs f0, RTOC_ZERO(rtoc)
  lfs f1, SP_CAMPOS+Z(sp)
  fsubs f1, f0, f1
  lfs f0, SP_DIFF+Z(sp)
  fdivs f1, f1, f0
  addi r3, sp, SP_DIFF
  addi r4, sp, SP_SCLDIFF
  branchl r12, PSVECScale

  addi r3, sp, SP_CAMPOS
  addi r4, sp, SP_SCLDIFF
  mr r5, REG_TEMP
  branchl r12, PSVECAdd

  SCALE_LOOP_INC:
    addi REG_COUNT, REG_COUNT, 1
    addi REG_TEMP, REG_TEMP, SZ_VEC3
    cmpwi REG_COUNT, 4
    blt SCALE_FAR_PLANE

# # near plane
#   load r3, 0xFF00007F
#   stw r3, SP_COLOR(sp)

#   addi r3, sp, SP_TL
#   addi r4, sp, SP_BR
#   addi r5, sp, SP_COLOR
#   branchl r12, HSD_DrawQuad

# # far plane
#   load r3, 0x00FF007F
#   stw r3, SP_COLOR(sp)

#   addi r3, sp, SP_FTL
#   addi r4, sp, SP_FBR
#   addi r5, sp, SP_COLOR
#   branchl r12, HSD_DrawQuad

  # lfs f1, SP_TL+Y(sp)
  # logf LOG_LEVEL_WARN, "Y: %f"

# planes
  branchl r12, HSD_StateInitTev

  branchl r12, HSD_ClearVtxDesc

  li r3, GX_VTXFMT0
  li r4, GX_VA_POS
  li r5, 1
  li r6, 4
  li r7, 0
  branchl r12, GXSetVtxAttrFmt

  li r3, GX_VTXFMT0
  li r4, GX_VA_CLR0
  li r5, 1
  li r6, 5
  li r7, 0
  branchl r12, GXSetVtxAttrFmt

  li r3, GX_VA_POS
  li r4, GX_DIRECT
  branchl r12, GXSetVtxDesc

  li r3, GX_VA_CLR0
  li r4, GX_DIRECT
  branchl r12, GXSetVtxDesc

  li r3, 0
  branchl r12, GXSetCullMode

FAR_PLANE:
  load r3, 0x0000FF7F
  stw r3, SP_COLOR(sp)

  addi r3, sp, SP_COLOR
  addi r4, sp, SP_COLOR
  branchl r12, HSD_SetRenderColors

  li r3, GX_QUADS
  li r4, GX_VTXFMT0
  li r5, 4
  branchl r12, GXBegin

  lfs FREG_X, SP_FTL+X(sp)
  lfs FREG_Y, SP_FTL+Y(sp)
  lfs FREG_Z, SP_FTL+Z(sp)
  GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE

  lfs FREG_X, SP_FTR+X(sp)
  lfs FREG_Y, SP_FTR+Y(sp)
  lfs FREG_Z, SP_FTR+Z(sp)
  GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE

  lfs FREG_X, SP_FBR+X(sp)
  lfs FREG_Y, SP_FBR+Y(sp)
  lfs FREG_Z, SP_FBR+Z(sp)
  GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE

  lfs FREG_X, SP_FBL+X(sp)
  lfs FREG_Y, SP_FBL+Y(sp)
  lfs FREG_Z, SP_FBL+Z(sp)
  GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE
  

NEAR_PLANE:
  load r3, 0xFF00007F
  stw r3, SP_COLOR(sp)
  
  addi r3, sp, SP_COLOR
  addi r4, sp, SP_COLOR
  branchl r12, HSD_SetRenderColors

  li r3, GX_QUADS
  li r4, GX_VTXFMT0
  li r5, 4
  branchl r12, GXBegin

  lfs FREG_X, SP_TL+X(sp)
  lfs FREG_Y, SP_TL+Y(sp)
  lfs FREG_Z, SP_TL+Z(sp)
  GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE

  lfs FREG_X, SP_TR+X(sp)
  lfs FREG_Y, SP_TR+Y(sp)
  lfs FREG_Z, SP_TR+Z(sp)
  GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE

  lfs FREG_X, SP_BR+X(sp)
  lfs FREG_Y, SP_BR+Y(sp)
  lfs FREG_Z, SP_BR+Z(sp)
  GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE

  lfs FREG_X, SP_BL+X(sp)
  lfs FREG_Y, SP_BL+Y(sp)
  lfs FREG_Z, SP_BL+Z(sp)
  GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE

TOP_PLANE:
  load r3, 0x00FF007F
  stw r3, SP_COLOR(sp)
  
  addi r3, sp, SP_COLOR
  addi r4, sp, SP_COLOR
  branchl r12, HSD_SetRenderColors

  li r3, GX_QUADS
  li r4, GX_VTXFMT0
  li r5, 4
  branchl r12, GXBegin

  lfs FREG_X, SP_FTL+X(sp)
  lfs FREG_Y, SP_FTL+Y(sp)
  lfs FREG_Z, SP_FTL+Z(sp)
  GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE

  lfs FREG_X, SP_TL+X(sp)
  lfs FREG_Y, SP_TL+Y(sp)
  lfs FREG_Z, SP_TL+Z(sp)
  GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE

  lfs FREG_X, SP_TR+X(sp)
  lfs FREG_Y, SP_TR+Y(sp)
  lfs FREG_Z, SP_TR+Z(sp)
  GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE

  lfs FREG_X, SP_FTR+X(sp)
  lfs FREG_Y, SP_FTR+Y(sp)
  lfs FREG_Z, SP_FTR+Z(sp)
  GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE

BOT_PLANE:
  load r3, 0xFF00FF7F
  stw r3, SP_COLOR(sp)
  
  addi r3, sp, SP_COLOR
  addi r4, sp, SP_COLOR
  branchl r12, HSD_SetRenderColors

  li r3, GX_QUADS
  li r4, GX_VTXFMT0
  li r5, 4
  branchl r12, GXBegin

  lfs FREG_X, SP_FBL+X(sp)
  lfs FREG_Y, SP_FBL+Y(sp)
  lfs FREG_Z, SP_FBL+Z(sp)
  GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE

  lfs FREG_X, SP_FBR+X(sp)
  lfs FREG_Y, SP_FBR+Y(sp)
  lfs FREG_Z, SP_FBR+Z(sp)
  GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE

  lfs FREG_X, SP_BR+X(sp)
  lfs FREG_Y, SP_BR+Y(sp)
  lfs FREG_Z, SP_BR+Z(sp)
  GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE

  lfs FREG_X, SP_BL+X(sp)
  lfs FREG_Y, SP_BL+Y(sp)
  lfs FREG_Z, SP_BL+Z(sp)
  GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE

LEFT_PLANE:
  load r3, 0xFFFF007F
  stw r3, SP_COLOR(sp)
  
  addi r3, sp, SP_COLOR
  addi r4, sp, SP_COLOR
  branchl r12, HSD_SetRenderColors

  li r3, GX_QUADS
  li r4, GX_VTXFMT0
  li r5, 4
  branchl r12, GXBegin

  lfs FREG_X, SP_FBL+X(sp)
  lfs FREG_Y, SP_FBL+Y(sp)
  lfs FREG_Z, SP_FBL+Z(sp)
  GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE

  lfs FREG_X, SP_FTL+X(sp)
  lfs FREG_Y, SP_FTL+Y(sp)
  lfs FREG_Z, SP_FTL+Z(sp)
  GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE

  lfs FREG_X, SP_TL+X(sp)
  lfs FREG_Y, SP_TL+Y(sp)
  lfs FREG_Z, SP_TL+Z(sp)
  GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE

  lfs FREG_X, SP_BL+X(sp)
  lfs FREG_Y, SP_BL+Y(sp)
  lfs FREG_Z, SP_BL+Z(sp)
  GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE

RIGHT_PLANE:
  load r3, 0x00FFFF7F
  stw r3, SP_COLOR(sp)
  
  addi r3, sp, SP_COLOR
  addi r4, sp, SP_COLOR
  branchl r12, HSD_SetRenderColors

  li r3, GX_QUADS
  li r4, GX_VTXFMT0
  li r5, 4
  branchl r12, GXBegin

  lfs FREG_X, SP_FBR+X(sp)
  lfs FREG_Y, SP_FBR+Y(sp)
  lfs FREG_Z, SP_FBR+Z(sp)
  GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE

  lfs FREG_X, SP_FTR+X(sp)
  lfs FREG_Y, SP_FTR+Y(sp)
  lfs FREG_Z, SP_FTR+Z(sp)
  GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE

  lfs FREG_X, SP_TR+X(sp)
  lfs FREG_Y, SP_TR+Y(sp)
  lfs FREG_Z, SP_TR+Z(sp)
  GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE

  lfs FREG_X, SP_BR+X(sp)
  lfs FREG_Y, SP_BR+Y(sp)
  lfs FREG_Z, SP_BR+Z(sp)
  GXPosition3f32 FREG_X, FREG_Y, FREG_Z, REG_GXPIPE


# Free alloc memory
  mr r3, REG_CORNERS
  branchl r12, HSD_Free

  # mr r3, REG_INVVIEWPROJ
  # branchl r12, HSD_Free

FN_DrawCamera_Exit:
  restore
  blr

EXIT:
  restore

