################################################################################
# Address: 0x80233a58
# Creates a 7th option in the additional rules menu. Mimics 0x80233648
# The data in this file will be used across other injections for ease of access
# to our new jobj and its parts.
################################################################################

.include "Online/Menus/CustomRules/CustomRules.s"
.include "Common/Common.s"

b CODE_START

# defined in CustomRules.s
ROD_BLRL:
blrl
cursor_hierarchy_data # u16[CURSOR_PARTS_COUNT] + align 2
.fill CURSOR_PARTS_COUNT, 4, 0 # HSD_JObj*[17]
.float 32.0 # unhover frame
.float 33.0 # hover frame

CODE_START:
.set REG_ROD, 31
.set REG_MRPD, 30
.set REG_MODEL, 29
.set REG_JOBJ, 28
.set REG_PARTS, 27
backup

# get our local data
  bl ROD_BLRL
  mflr REG_ROD
  addi REG_PARTS, REG_ROD, ROD_CURSOR_PARTS

  loadwz REG_MRPD, RulesPlusGObjPtr
  lwz REG_MRPD, 0x2C(REG_MRPD)

  # load new option jobj
  load REG_MODEL, MenMainCursorRl_Top
  lwz r3, MODEL_DESC_JOINT(REG_MODEL)
  branchl r12, JObj_LoadJoint
  mr REG_JOBJ, r3

  # add anims
  mr r3, REG_JOBJ
  lwz r4, MODEL_DESC_ANIM_JOINT(REG_MODEL)
  lwz r5, MODEL_DESC_MAT_ANIM_JOINT(REG_MODEL)  
  lwz r6, MODEL_DESC_SHAPE_ANIM_JOINT(REG_MODEL)
  branchl r12, JObj_AddAnimAll
  mr r3, REG_JOBJ
  lfs f1, -0x3b9c(rtoc) # 0.0f
  branchl r12, JObj_ReqAnimAll
  mr r3, REG_JOBJ
  branchl r12, JObj_AnimAll

# get our parts
# JObj_GetJointsByDepth will fill our parts (ROD_CURSOR_PARTS) in the
# order of the u16 array (cursor_hierarchy_data).
# easier to manage than doing a bunch of JObj_GetJObjChild calls
  mr r3, REG_JOBJ # root
  mr r4, REG_PARTS # parts
  mr r5, REG_ROD # hierarchy data
  li r6, CURSOR_PARTS_COUNT
  branchl r12, JObj_GetJointsByDepth

# animate for unhover (default state)
  lfs f31, ROD_CURSOR_UNHOVER_FRAME(REG_ROD)
  cursor_anim_unhover REG_PARTS, f31

  # add new option to parent jobj
  addi r3, REG_MRPD, MRPD_OPTION_TREE
  li r0, 9 # 
  slwi r0, r0, 2
  lwzx r3, r3, r0
  mr r4, REG_JOBJ
  branchl r12, JObj_AddChild

EXIT:
  restore
  # original instruction
  li r3, 0
