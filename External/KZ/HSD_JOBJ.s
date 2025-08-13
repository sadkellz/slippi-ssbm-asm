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
.set JOBJ_SCL, JOBJ_ROT + 16
.set JOBJ_POS, JOBJ_SCL + 12
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

.set JOBJFLAG_HIDDEN, 0x10

################################################################################
# Functions
################################################################################

.set HSD_JObjGetChild, 0x80011e24

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

################################################################################
# Constants
################################################################################

.set ptr_CSSJobj, 0x804d6cc0
# anim
  # li r3, 0x18 # ganon id - 1
  # lfd	f31, -0x35F8(rtoc) # 4330000080000000

  # li r4, 0
  # lis r4, 0x4330 # 43300000
  # stw r4, SP_DOUBLE(sp)
 
  # xoris	r5, r3, 0x8000 # 80000018
  # stw r5, SP_DOUBLE+4(sp) # double is now 4330000080000018
  # lfd f0, SP_DOUBLE(sp)
  # fsubs f1, f0, f31 # 24.0f

.endif
.set HEADER_JOBJ_STRUCT, 1
