.ifndef HEADER_COBJ_STRUCT

################################################################################
# Struct
################################################################################

.set COBJ_BASE, 0
.set COBJ_FLAGS, COBJ_BASE + 8
.set COBJ_VIEWP_L, COBJ_FLAGS + 4
.set COBJ_VIEWP_R, COBJ_VIEWP_L + 4
.set COBJ_VIEWP_T, COBJ_VIEWP_R + 4
.set COBJ_VIEWP_B, COBJ_VIEWP_T + 4
.set COBJ_SCISSOR_L, COBJ_VIEWP_B + 4
.set COBJ_SCISSOR_R, COBJ_SCISSOR_L + 2
.set COBJ_SCISSOR_T, COBJ_SCISSOR_R + 2
.set COBJ_SCISSOR_B, COBJ_SCISSOR_T + 2
.set COBJ_EYE_POS, COBJ_SCISSOR_B + 2
.set COBJ_INTEREST, COBJ_EYE_POS + 4
.set COBJ_ROLL, COBJ_INTEREST + 4
.set COBJ_PITCH, COBJ_ROLL + 4
.set COBJ_YAW, COBJ_PITCH + 4
.set COBJ_NEAR, COBJ_YAW + 4
.set COBJ_FAR, COBJ_NEAR + 4
.set COBJ_FOV, COBJ_FAR + 4
.set COBJ_ASPECT, COBJ_FOV + 4
.set COBJ_UNK, COBJ_ASPECT + 4
.set COBJ_PROJECTION, COBJ_UNK + 12
.set COBJ_UNK2, COBJ_PROJECTION + 1
.set COBJ_VIEW_MTX, COBJ_UNK2 + 4
.set COBJ_UNK3, COBJ_VIEW_MTX + 30
.set COBJ_PROJ_MTX, COBJ_UNK3 + 4

.set COBJDESC_NAME, 0
.set COBJDESC_FLAGS, COBJDESC_NAME + 4
.set COBJDESC_PROJTYPE, COBJDESC_FLAGS + 2
.set COBJDESC_VIEWP_L, COBJDESC_PROJTYPE + 2
.set COBJDESC_VIEWP_R, COBJDESC_VIEWP_L + 2
.set COBJDESC_VIEWP_T, COBJDESC_VIEWP_R + 2
.set COBJDESC_VIEWP_B, COBJDESC_VIEWP_T + 2
.set COBJDESC_SCISSOR_L, COBJDESC_VIEWP_B + 2
.set COBJDESC_SCISSOR_R, COBJDESC_SCISSOR_L + 2
.set COBJDESC_SCISSOR_T, COBJDESC_SCISSOR_R + 2
.set COBJDESC_SCISSOR_B, COBJDESC_SCISSOR_T + 2
.set COBJDESC_EYEDESC, COBJDESC_SCISSOR_B + 2
.set COBJDESC_INTERESTDESC, COBJDESC_EYEDESC + 4
.set COBJDESC_ROLL, COBJDESC_INTERESTDESC + 4
.set COBJDESC_UPVEC, COBJDESC_ROLL + 4
.set COBJDESC_NEAR, COBJDESC_UPVEC + 4
.set COBJDESC_FAR, COBJDESC_NEAR + 4
.set COBJDESC_FOV, COBJDESC_FAR + 4
.set COBJDESC_ASPECT, COBJDESC_FOV + 4

.set DEVCAM_INT, 0
.set DEVCAM_EYE, DEVCAM_INT + 12
.set DEVCAM_FOV, DEVCAM_EYE + 12

.set X_MIN, 0
.set Y_MIN, X_MIN + 4
.set X_MAX, Y_MIN + 4
.set Y_MAX, X_MAX + 4
.set SUBJECTS, Y_MAX + 4
.set Z_POS, SUBJECTS + 4

.set CMSUB_NEXT, 0
.set CMSUB_PREV, CMSUB_NEXT + 4
.set CMSUB_x8, CMSUB_PREV + 4
.set CMSUB_FLAGS, CMSUB_x8 + 4
.set CMSUB_xD, CMSUB_FLAGS + 1
.set CMSUB_xE, CMSUB_xD + 1
.set CMSUB_FOCUS, CMSUB_xE + 2
.set CMSUB_POS, CMSUB_FOCUS + 4
.set CMSUB_DIR, CMSUB_POS + 4
.set CMSUB_DEFBOUNDS, CMSUB_DIR + 4
.set CMSUB_SIZE, CMSUB_DEFBOUNDS + 16
.set CMSUB_BOUNDS, CMSUB_SIZE + 4
.set CMSUB_DEFSIZE, CMSUB_BOUNDS + 16
.set CMSUB_x54, CMSUB_DEFSIZE + 4
.set CMSUB_x60, CMSUB_x54 + 12

################################################################################
# Functions
################################################################################

.set HSD_CObjGetCurrent, 0x8036a288
.set HSD_CObjGetViewingMtx, 0x803695f0
.set HSD_CObjGetInterest, 0x803686ac
.set HSD_CObjGetEyePosition, 0x80368784
.set HSD_CObjGetForwardVector, 0x8036885c
.set HSD_CObjGetUpVector, 0x80368e70
.set HSD_CObjGetLeftVector, 0x803692e8
.set HSD_CObjGetFar, 0x80369fb0
.set HSD_CObjGetNear, 0x80369f88
.set HSD_CObjGetFov, 0x80369bc8
.set HSD_CObjGetAspect, 0x80369c0c
.set HSD_CObjGetEyeDistance, 0x80368a08
.set HSD_CObjGetFlags, 0x8036a250
.set HSD_CObjGetViewportf, 0x8036a02c
.set HSD_CObjGetScissor, 0x80369fd8
.set HSD_CObjGetPerspective, 0x8036a1b8

.set HSD_CObjSetCurrent, 0x80368458
.set HSD_CObjSetInterest, 0x80368718
.set HSD_CObjSetEyePosition, 0x803687f0
.set HSD_CObjSetMtxDirty, 0x80369564
.set HSD_CObjSetNear, 0x80369fa0
.set HSD_CObjSetFar, 0x80369fc8
.set HSD_CObjSetFlags, 0x8036a258
.set HSD_CObjSetViewportf, 0x8036a0e4
.set HSD_CObjSetScissor, 0x80369ff4
.set HSD_CObjSetPerspective, 0x8036a154
.set HSD_CObjSetCurrent, 0x80368458
.set HSD_CObjEndCurrent, 0x80368608
.set HSD_CObjEraseScreen, 0x803676f8

.set CObj_CopyFromMain, 0x8021eb10 # (GOBJ *gobj)
.set Camera_LoadCameraEntity, 0x80030a50
.set DevelopCam_UpdatePosition, 0x80227fe0
.set DevelopCam_UpdateZoom, 0x80227cac
.set DevelopCam_OrbitCam, 0x802279e8
.set DevelopCam_UpdateRotation, 0x80227b64
.set HSD_CObjCreate, 0x80013B14 # (void *desc)
.set DevelopText_Setup, 0x80302708 # (GObjClass class,GObjPLink p_link,int p_prio,int gx_link, int render_priority,byte camera_priority)
.set DevelopText_Show, 0x80302810 # (HSD_GObj *gobj,DevText *text)

.set HSD_CObjLoadDesc, 0x8036a590 # (void *desc)

################################################################################
# Constants
################################################################################

.set DevelopCamPos, 0x8045304c
.set DevelopCamInterest, 0x80453040
.set DevelopCobjDesc, 0x803fdc48
.set STC_DEVTEXT_GOBJ, 0x804d6e1c
.set CmSubjects, 0x804d6468


.endif
.set HEADER_COBJ_STRUCT, 1
