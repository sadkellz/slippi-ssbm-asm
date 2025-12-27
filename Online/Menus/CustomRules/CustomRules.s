.ifndef HEADER_CUSTOM_RULES
################################################################################
# Functions
################################################################################
.set JObj_LoopAnim, 0x8022ed6c # (HSD_JObj* jobj, HSD_AnimLoop* anim_loop)
.set JObj_GetJointsByDepth, 0x8001204C # (HSD_JObj *root, HSD_JObj **jobj_tree, ushort *depth_tree, int obj_count)
.set JObj_AddChild, 0x803717a8 # (HSD_JObj *parent, HSD_JObj *child)
.set GetGameRules, 0x8015cc34 # (void) -> GameRules*
.set Menu_ExitRulesMenu, 0x8022f4cc

################################################################################
# Structs
################################################################################
# HSD_AnimLoop
.set ANIM_LOOP_START, 0 # f32 - start frame
.set ANIM_LOOP_END, ANIM_LOOP_START + 4 # f32 - end frame
.set ANIM_LOOP_LOOP, ANIM_LOOP_END + 4 # f32 - loop frame, -0.1f for no loop

# MenuRulesPlusData - additional rules menu data
.set MRPD_MENU_KIND, 0 # u8
.set MRPD_HOVERED_OPTION, MRPD_MENU_KIND + 1 # u8
.set MRPD_TIME_LIMIT, MRPD_HOVERED_OPTION + 1 # u8
.set MRPD_FRIENDLY_FIRE, MRPD_TIME_LIMIT + 1 # u8
.set MRPD_PAUSE, MRPD_FRIENDLY_FIRE + 1 # u8
.set MRPD_SCORE, MRPD_PAUSE + 1 # u8
.set MRPD_SD_PENALTY, MRPD_SCORE + 1 # u8
.set MRPD_X7, MRPD_SD_PENALTY + 1 # u8
.set MRPD_MENU_STATE, MRPD_X7 + 1 # u8
.set MRPD_OPTION_TREE, MRPD_MENU_STATE + 4 # HSD_JObj*[10]
.set MRPD_VALUE_TREES, MRPD_OPTION_TREE + 0x28 # HSD_JObj*[6][7]
.set MRPD_DESCRIPTION, MRPD_VALUE_TREES + 0xA8 # HSD_Text*
.set MRPD_SIZE, MRPD_DESCRIPTION + 4

# Cursor Parts
.set CURSOR_PART_TOP, 0
.set CURSOR_PART_CON, CURSOR_PART_TOP + 4
.set CURSOR_PART_PANEL, CURSOR_PART_CON+ 4
.set CURSOR_PART_PANEL_CENTER, CURSOR_PART_PANEL + 4
.set CURSOR_PART_PANEL_LEFT, CURSOR_PART_PANEL_CENTER + 4
.set CURSOR_PART_PANEL_RIGHT, CURSOR_PART_PANEL_LEFT + 4
.set CURSOR_PART_VALUE_BACKGROUND, CURSOR_PART_PANEL_RIGHT + 4
.set CURSOR_PART_RULE_NAME, CURSOR_PART_VALUE_BACKGROUND + 4
.set CURSOR_PART_BG_ARROW_CON, CURSOR_PART_RULE_NAME + 4
.set CURSOR_PART_BG_ARROW_9, CURSOR_PART_BG_ARROW_CON + 4
.set CURSOR_PART_BG_ARROW_10, CURSOR_PART_BG_ARROW_9 + 4
.set CURSOR_PART_BG_ARROW_11, CURSOR_PART_BG_ARROW_10 + 4
.set CURSOR_PART_BG_ARROW_12, CURSOR_PART_BG_ARROW_11 + 4
.set CURSOR_PART_VALUE_ARROW_CON, CURSOR_PART_BG_ARROW_12 + 4
.set CURSOR_PART_VALUE_ARROW_RIGHT, CURSOR_PART_VALUE_ARROW_CON + 4
.set CURSOR_PART_VALUE_ARROW_LEFT, CURSOR_PART_VALUE_ARROW_RIGHT + 4
.set CURSOR_PART_HIGHLIGHTER, CURSOR_PART_VALUE_ARROW_LEFT + 4
.set CURSOR_PART_SIZE, CURSOR_PART_HIGHLIGHTER + 4

# StaticModelDesc
.set MODEL_DESC_JOINT, 0 # HSD_Joint*
.set MODEL_DESC_ANIM_JOINT, MODEL_DESC_JOINT + 4 # HSD_AnimJoint*
.set MODEL_DESC_MAT_ANIM_JOINT, MODEL_DESC_ANIM_JOINT + 4 # HSD_MatAnimJoint*
.set MODEL_DESC_SHAPE_ANIM_JOINT, MODEL_DESC_MAT_ANIM_JOINT + 4 # HSD_ShapeAnimJoint*

# GameRules
.set GAME_RULES_FORCE_MAIN_MENU, 0
.set GAME_RULES_MENU_BGM, GAME_RULES_FORCE_MAIN_MENU + 1
.set GAME_RULES_MODE, GAME_RULES_MENU_BGM + 1
.set GAME_RULES_TIME_LIMIT, GAME_RULES_MODE + 1
.set GAME_RULES_STOCK_COUNT, GAME_RULES_TIME_LIMIT + 1
.set GAME_RULES_HANDICAP, GAME_RULES_STOCK_COUNT + 1
.set GAME_RULES_DAMAGE_RATIO, GAME_RULES_HANDICAP + 1
.set GAME_RULES_STAGE_SELECT_MODE, GAME_RULES_DAMAGE_RATIO + 1
.set GAME_RULES_STOCK_TIME_LIMIT, GAME_RULES_STAGE_SELECT_MODE + 1
.set GAME_RULES_FRIENDLY_FIRE, GAME_RULES_STOCK_TIME_LIMIT + 1
.set GAME_RULES_PAUSE, GAME_RULES_FRIENDLY_FIRE + 1
.set GAME_RULES_SCORE_DISPLAY, GAME_RULES_PAUSE + 1
.set GAME_RULES_SD_PENALTY, GAME_RULES_SCORE_DISPLAY + 1
.set GAME_RULES_XD, GAME_RULES_SD_PENALTY + 1
.set GAME_RULES_UNLOCK_MASK, GAME_RULES_XD + 1
.set GAME_RULES_X11, GAME_RULES_UNLOCK_MASK + 1
.set GAME_RULES_X12, GAME_RULES_X11 + 1
.set GAME_RULES_X13, GAME_RULES_X12 + 1
.set GAME_RULES_X14, GAME_RULES_X13 + 1
.set GAME_RULES_X15, GAME_RULES_X14 + 1
.set GAME_RULES_X16, GAME_RULES_X15 + 1
.set GAME_RULES_X17, GAME_RULES_X16 + 1
.set GAME_RULES_SIZE, GAME_RULES_X17 + 1

# INJ_ResetOptionInit Data
.set ROD_CURSOR_HIERARCHY, 0 # u16[CURSOR_PARTS_COUNT] : cursor_hierarchy_data
.set ROD_CURSOR_PARTS, ROD_CURSOR_HIERARCHY + (2 * 17) + 2 # HSD_JObj*[17] : ofst = u16[CURSOR_PARTS_COUNT] + align 2
.set ROD_CURSOR_UNHOVER_FRAME, ROD_CURSOR_PARTS + (4 * 17) # f32
.set ROD_CURSOR_HOVER_FRAME, ROD_CURSOR_UNHOVER_FRAME + 4 # f32
.set ROD_CURSOR_SIZE, ROD_CURSOR_HOVER_FRAME + 4

################################################################################
# Directives
################################################################################

# Injections
.set INJ_ResetOptionInit, 0x80233a58
.set INJ_ResetOptionUpdate, 0x80233178

# Statics
.set RulesPlusGObjPtr, 0x804d6be0
.set MenMainCursorRl_Top, 0x804a0558 # StaticModelDesc*
.set DefaultGameRules, 0x803d4a48
# Anim Loops
.set CursorButtonAnim_Hover, 0x803ed258 # HSD_AnimLoop* 
.set CursorButtonAnim_Unhover, 0x803ed24c # HSD_AnimLoop* 
.set CursorHighlighterAnim, 0x803ed21c # HSD_AnimLoop*
.set CursorBgArrowAnim, 0x803ed264 # HSD_AnimLoop*

# Misc
.set OPTION_RESET_IDX, 6
.set OPTION_RESET_SIS_IDX, 1612
.set SZ_HIERARCHY, 2 * 17 # u16[CURSOR_PARTS_COUNT]
.set SZ_PARTS, 4 * 17 # HSD_JObj*[17]
.set CURSOR_PARTS_COUNT, 17
.set JOBJ_HIDDEN, 0x10

################################################################################
# Macros
################################################################################

# used by JObj_GetJointsByDepth
.macro cursor_hierarchy_data
.short 0 # top
.short 1 # container
.short 2 # panel
.short 3 # panel center
.short 4 # panel left
.short 5 # panel right
.short 6 # value background
.short 7 # rule name
.short 8 # bg arrow con
.short 9 # bg arrow 9
.short 10 # bg arrow 10
.short 11 # bg arrow 11
.short 12 # bg arrow 12
.short 13 # value arrow con
.short 14 # value arrow right
.short 15 # value arrow left  
.short 16 # highlighter
.align 2
.endm

.macro cursor_anim_unhover reg_parts, reg_frame
  # hide value, bg arrow, and highlighter
  lwz r3, CURSOR_PART_VALUE_ARROW_CON(\reg_parts)
  li r4, JOBJ_HIDDEN
  branchl r12, JObj_SetFlagsAll
  lwz r3, CURSOR_PART_BG_ARROW_CON(\reg_parts)
  li r4, JOBJ_HIDDEN
  branchl r12, JObj_SetFlagsAll
  lwz r3, CURSOR_PART_HIGHLIGHTER(\reg_parts)
  li r4, JOBJ_HIDDEN
  branchl r12, JObj_SetFlagsAll

  # animate for unhover
  # panel
  lwz r3, CURSOR_PART_PANEL(\reg_parts)
  load r4, CursorButtonAnim_Unhover
  branchl r12, JObj_ReqAnimAll
  lwz r3, CURSOR_PART_PANEL(\reg_parts)
  branchl r12, JObj_AnimAll
  # rule name
  lwz r3, CURSOR_PART_RULE_NAME(\reg_parts)
  fmr f1, \reg_frame
  branchl r12, JObj_ReqAnim
  lwz r3, CURSOR_PART_RULE_NAME(\reg_parts)
  branchl r12, JObj_Anim
.endm

.macro cursor_anim_hover reg_parts, reg_frame
  # show bg arrow and highlighter
  lwz r3, CURSOR_PART_BG_ARROW_CON(\reg_parts)
  li r4, JOBJ_HIDDEN
  branchl r12, JObj_ClearFlagsAll
  lwz r3, CURSOR_PART_HIGHLIGHTER(\reg_parts)
  li r4, JOBJ_HIDDEN
  branchl r12, JObj_ClearFlagsAll

  # animate for hover
  # bg arrow
  lwz r3, CURSOR_PART_BG_ARROW_CON(\reg_parts)
  load r4, CursorBgArrowAnim
  branchl r12, JObj_ReqAnimAll
  lwz r3, CURSOR_PART_BG_ARROW_CON(\reg_parts)
  branchl r12, JObj_AnimAll
  # highlighter
  lwz r3, CURSOR_PART_HIGHLIGHTER(\reg_parts)
  load r4, CursorHighlighterAnim
  branchl r12, JObj_ReqAnimAll
  lwz r3, CURSOR_PART_HIGHLIGHTER(\reg_parts)
  branchl r12, JObj_AnimAll
  # panel
  lwz r3, CURSOR_PART_PANEL(\reg_parts)
  load r4, CursorButtonAnim_Hover
  branchl r12, JObj_ReqAnimAll
  lwz r3, CURSOR_PART_PANEL(\reg_parts)
  branchl r12, JObj_AnimAll
  # rule name
  lwz r3, CURSOR_PART_RULE_NAME(\reg_parts)
  fmr f1, \reg_frame
  branchl r12, JObj_ReqAnim
  lwz r3, CURSOR_PART_RULE_NAME(\reg_parts)
  branchl r12, JObj_Anim
.endm

.endif
.set HEADER_CUSTOM_RULES, 1
