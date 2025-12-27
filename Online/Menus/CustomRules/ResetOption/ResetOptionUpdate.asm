################################################################################
# Address: 0x80233178
################################################################################

.include "Online/Menus/CustomRules/CustomRules.s"
.include "Common/Common.s"

CODE_START:
.set REG_ROD, 31
.set REG_FLOW, 30
.set REG_PARTS, 29
.set REG_OPTION_CHANGED, 28 # bool set by the original func
.set REG_MRPD, 26 # gobj reg in the original func
.set REG_PREV_OPTION, 25
  backup

# get flow data
  load REG_FLOW, Menu_FlowData

# get MRPD
  lwz REG_MRPD, 0x2C(REG_MRPD)

# get our local data
  computeBranchTargetAddress REG_ROD, INJ_ResetOptionInit
  addi REG_ROD, REG_ROD, 0x8 # skip instructions
  addi REG_PARTS, REG_ROD, ROD_CURSOR_PARTS

# check if the option was changed
  cmpwi REG_OPTION_CHANGED, 0
  beq LOOP_ANIMS

bp
# check if we're moving from our new option
  ON_UNHOVER:
    lbz r3, MRPD_HOVERED_OPTION(REG_MRPD)
    cmpwi r3, OPTION_RESET_IDX
    bne ON_HOVER
    lfs f31, ROD_CURSOR_UNHOVER_FRAME(REG_ROD)
    cursor_anim_unhover REG_PARTS, f31
    b LOOP_ANIMS

# check if we're moving to our new option
  ON_HOVER:
    lhz r3, MFD_HOVERED_OPTION(REG_FLOW)
    cmplwi r3, OPTION_RESET_IDX
    bne LOOP_ANIMS
    lfs f31, ROD_CURSOR_HOVER_FRAME(REG_ROD)
    cursor_anim_hover REG_PARTS, f31
    b LOOP_ANIMS


  LOOP_ANIMS:
    # highlighter
    lwz r3, CURSOR_PART_HIGHLIGHTER(REG_PARTS)
    load r4, CursorHighlighterAnim
    branchl r12, JObj_LoopAnim
    # bg arrow
    lwz r3, CURSOR_PART_BG_ARROW_CON(REG_PARTS)
    load r4, CursorBgArrowAnim
    branchl r12, JObj_LoopAnim

    # unhover/hover
    lbz r3, MRPD_HOVERED_OPTION(REG_MRPD)
    cmpwi r3, OPTION_RESET_IDX
    beq LOOP_HOVER
    LOOP_UNHOVER:
      lwz r3, CURSOR_PART_PANEL(REG_PARTS)
      load r4, CursorButtonAnim_Unhover
      branchl r12, JObj_LoopAnim
      b LOOP_ANIMS_END

    LOOP_HOVER:
      lwz r3, CURSOR_PART_PANEL(REG_PARTS)
      load r4, CursorButtonAnim_Hover
      branchl r12, JObj_LoopAnim

  LOOP_ANIMS_END:
  

EXIT:
  restore
  # original code line
  cmpwi r29, 0
