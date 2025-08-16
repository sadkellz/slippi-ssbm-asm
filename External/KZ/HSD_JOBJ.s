.ifndef HEADER_JOBJ_STRUCT

################################################################################
# Struct
################################################################################
.set JOBJ_BASE, 0
.set JOBJ_NEXT, JOBJ_BASE + 8
.set JOBJ_PARENT, JOBJ_NEXT + 4
.set JOBJ_CHILD, JOBJ_PARENT + 4
.set JOBJ_FLAGS, JOBJ_CHILD + 4
.set JOBJ_DOBJ, JOBJ_FLAGS + 4
.set JOBJ_ROT, JOBJ_DOBJ + 4
.set JOBJ_SCALE, JOBJ_ROT + 16
.set JOBJ_POS, JOBJ_SCALE + 12
.set JOBJ_MTX, JOBJ_POS + 12
.set JOBJ_PVEC, JOBJ_MTX + 48
.set JOBJ_VMTX, JOBJ_PVEC + 4
.set JOBJ_AOBJ, JOBJ_VMTX + 4
.set JOBJ_ROBJ, JOBJ_AOBJ + 4
.set JOBJ_DESC, JOBJ_ROBJ + 4

.set JOINT, 0
.set ANIMJOINT, JOINT + 4
.set MATANIMJOINT, ANIMJOINT + 4
.set SHAPEANIMJOINT, MATANIMJOINT + 4

################################################################################
# Functions
################################################################################

.set HSD_JObjGetChild, 0x80011e24
.set HSD_JObjGetDObj, 0x80371bec
.set HSD_JObjSetMtxDirty, 0x800c6afc # (HSD_JObj *jobj)
.set HSD_JObjSetFlags, 0x80371d00 # (HSD_JObj *jobj,JObjFlag flag)
.set HSD_JObjSetFlagsAll, 0x80371d9c # (HSD_JObj *jobj,JObjFlag flag)
.set HSD_JObjClearFlags, 0x80371f00 # (HSD_JObj *jobj,JObjFlag flag)
.set HSD_JObjClearFlagsAll, 0x80371f9c # (HSD_JObj *jobj,JObjFlag flag)

.set HSD_JObjLoadJoint, 0x80370e44 # (HSD_Joint *desc)

.set HSD_JObjAddAnimAll, 0x8036fb5c # (HSD_JObj *jobj,HSD_AnimJoint *animjoint,HSD_MatAnimJoint *matanim_joint, HSD_ShapeAnimJoint *shapeanim_joint)
.set HSD_JObjRemoveAnimAll, 0x8036f6b4
.set HSD_JObjReqAnimAll, 0x8036f8bc # (HSD_JObj *jobj,float frame)
.set HSD_JObjReqAnim, 0x8036f934 # (HSD_JObj *jobj,float frame)
.set HSD_JObjAnimAll, 0x80370928 # (HSD_JObj *jobj)
.set HSD_JObjAnim, 0x80370780 # (HSD_JObj *jobj)
.set JObj_ForEachAnim, 0x80364C08 # (JOBJ *joint, int unk, u16 flags, void *cb, int argkind, ...);
.set HSD_JObjAddSceneAnimByIndex, 0x8016895c # (HSD_JObj *jobj, DynamicModelDesc *model,int index)

.set HSD_DObjSetFlags, 0x8035ddb8 # (HSD_DObj *Dobj, DObjFlag flag)

################################################################################
# Constants
################################################################################
.set stc_css_jobj, 0x804d6cc0

# flags
.set JOBJFLAG_SKELETON, 0x1
.set JOBJFLAG_SKELETON_ROOT, 0x2
.set JOBJFLAG_ENVELOPE_MODEL, 0x4
.set JOBJFLAG_CLASSICAL_SCALE, 0x8
.set JOBJFLAG_HIDDEN, 0x10
.set JOBJFLAG_PTCL, 0x20
.set JOBJFLAG_MTX_DIRTY, 0x40
.set JOBJFLAG_LIGHTING, 0x80
.set JOBJFLAG_TEXGEN, 0x100
.set JOBJFLAG_INSTANCE, 0x1000
.set JOBJFLAG_SPLINE, 0x4000
.set JOBJFLAG_FLIP_IK, 0x8000
.set JOBJFLAG_SPECULAR, 0x10000
.set JOBJFLAG_USE_QUATERNION, 0x20000
.set JOBJFLAG_UNK_B18, 0x40000
.set JOBJFLAG_UNK_B19, 0x80000
.set JOBJFLAG_UNK_B20, 0x100000
.set JOBJFLAG_NULL_OBJ, 0x0
.set JOBJFLAG_JOINT1, 0x200000
.set JOBJFLAG_JOINT2, 0x400000
.set JOBJFLAG_JOINT, 0x600000
.set JOBJFLAG_EFFECTOR, 0x600000
.set JOBJFLAG_USER_DEF_MTX, 0x800000
.set JOBJFLAG_MTX_INDEP_PARENT, 0x1000000
.set JOBJFLAG_MTX_INDEP_SRT, 0x2000000
.set JOBJFLAG_UNK_B26, 0x4000000
.set JOBJFLAG_UNK_B27, 0x8000000
.set JOBJFLAG_ROOT_OPA, 0x10000000
.set JOBJFLAG_ROOT_XLU, 0x20000000
.set JOBJFLAG_ROOT_TEXEDGE, 0x40000000

################################################################################
# Macros
################################################################################

.macro jobj_set_pos, jobj, vec
  lfs f1, X(\vec)
  lfs f2, Y(\vec)
  lfs f3, Z(\vec)
  stfs f1, JOBJ_POS+X(\jobj)
  stfs f2, JOBJ_POS+Y(\jobj)
  stfs f3, JOBJ_POS+Z(\jobj)
.endm

.endif
.set HEADER_JOBJ_STRUCT, 1
