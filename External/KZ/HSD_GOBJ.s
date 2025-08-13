.ifndef HEADER_GOBJ_STRUCT

################################################################################
# Struct
################################################################################

# HSD_GOBJ
  .set GOBJ_CLASSIFIER, 0
  .set GOBJ_PLINK, GOBJ_CLASSIFIER + 2
  .set GOBJ_GXLINK, GOBJ_PLINK + 1
  .set GOBJ_PRIO, GOBJ_GXLINK + 1
  .set GOBJ_RENDER_PRIO, GOBJ_PRIO + 1
  .set GOBJ_OBJ_KIND, GOBJ_RENDER_PRIO + 1
  .set GOBJ_USERDATA_KIND, GOBJ_OBJ_KIND + 1
  .set GOBJ_NEXT, GOBJ_USERDATA_KIND + 1
  .set GOBJ_PREV, GOBJ_NEXT + 4
  .set GOBJ_NEXT_GX, GOBJ_PREV + 4
  .set GOBJ_PREV_GX, GOBJ_NEXT_GX + 4
  .set GOBJ_PROC, GOBJ_PREV_GX + 4
  .set GOBJ_RENDER_CB, GOBJ_PROC + 4
  .set GOBJ_GXLINK_PRIOS, GOBJ_RENDER_CB + 4
  .set GOBJ_OBJ, GOBJ_GXLINK_PRIOS + 8
  .set GOBJ_USERDATA, GOBJ_OBJ + 4
  .set GOBJ_USERDATA_REMOVE_FUNC, GOBJ_USERDATA + 4
  .set GOBJ_X34_UNK, GOBJ_USER_DATA_REMOVE_FUNC + 4

# GOBJ_CLASS
  .set GOBJ_CLASS_ZAKO, 2
  .set GOBJ_CLASS_STAGE, 3
  .set GOBJ_CLASS_PLAYER, 4
  .set GOBJ_CLASS_ITEM, 6
  .set GOBJ_CLASS_GFX, 8
  .set GOBJ_CLASS_TEXT, 9
  .set GOBJ_CLASS_FOG, 10
  .set GOBJ_CLASS_LIGHT, 11
  .set GOBJ_CLASS_UI, 14
  .set GOBJ_CLASS_15, 15
  .set GOBJ_CLASS_MAINCAM, 16
  .set GOBJ_CLASS_CAMERA, 19
  .set GOBJ_CLASS_DEVTEXT, 21

# GOBJ_PLINK
  .set GOBJ_PLINK_LIGHT, 3
  .set GOBJ_PLINK_STAGE, 5
  .set GOBJ_PLINK_PLAYER, 8
  .set GOBJ_PLINK_ITEM, 9
  .set GOBJ_PLINK_GFX1, 11
  .set GOBJ_PLINK_GFX2, 12
  .set GOBJ_PLINK_UI, 15
  .set GOBJ_PLINK_MENU_CAMERA, 18
  .set GOBJ_PLINK_HUD, 20
  .set GOBJ_PLINK_DEVTEXT, 24
  .set GOBJ_PLINK_MENU_SCENE, 26

# GOBJ_GXLINK
  .set GOBJ_GXLINK_FOG, 0
  .set GOBJ_GXLINK_LIGHT, 1
  .set GOBJ_GXLINK_MENU_BG, 2
  .set GOBJ_GXLINK_MENU_FG, 3
  .set GOBJ_GXLINK_PLAYER, 5
  .set GOBJ_GXLINK_ITEM, 6
  .set GOBJ_GXLINK_HUD, 11
  .set GOBJ_GXLINK_OVERLAY, 16
  .set GOBJ_GXLINK_DEVTEXT, 17
  .set GOBJ_GXLINK_SAVE_ICON, 19
  .set GOBJ_GXLINK_NONE, 255

# GOBJ_KIND
  .set GOBJ_KIND_SOBJ, 0
  .set GOBJ_KIND_COBJ, 1
  .set GOBJ_KIND_LIGHT, 2
  .set GOBJ_KIND_JOBJ, 3
  .set GOBJ_KIND_NONE, 255

# GOBJ_USERDATA_KIND
  .set GOBJ_USERDATA_GENERIC, 0
  .set GOBJ_USERDATA_PLAYER, 4
  .set GOBJ_USERDATA_NONE, 255

# GOBJ_PLINK_LIST
  .set GOBJ_PLINKLIST_PLAYERS, 0x20

################################################################################
# Functions
################################################################################

.set GObj_AddObj, 0x80390a70 # (HSD_GObj *gobj, GObjKind obj_kind, void *obj_ptr)
.set GObj_AddProc, 0x8038fd54 # (HSD_GObj *gobj,void *cb,byte s_prio)
.set GObj_CopyGXLink, 0x803909d8 # (HSD_GObj *child,HSD_GObj *parent)
.set GObj_Create, 0x803901f0 # (GObjClass class,GObjPLink p_link,byte p_prio)
.set GObj_Free, 0x80390228 # (HSD_GObj *gobj)
.set GObj_InitCamera, 0x8039075c
.set GObj_GXProcCamera, 0x803910d8
.set GObj_RenderWithPassMask, 0x80390ed0 # (HSD_GObj *gobj,uint mask)


################################################################################
# Constants
################################################################################

.set STC_COBJDESC, 0x803bcb64
.set STC_HUDGOBJ, 0x804a0fd8
.set STC_PLINKLIST, 0x804d782c

################################################################################
# Macros
################################################################################

.macro gobj_create class, plink, prio, return
li r3, \class
li r4, \plink
li r5, \prio
branchl r12, GObj_Create
mr \return, r3
.endm

.endif
.set HEADER_GOBJ_STRUCT, 1
