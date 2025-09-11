.ifndef HEADER_SUBACTIONS

################################################################################
# Functions
################################################################################

################################################################################
# Structs
################################################################################

# https://docs.google.com/spreadsheets/d/1MIcQkeoKeXdZEoaz9EWIP1FNXSDjT3_DtHNbH3WkQMs/edit?gid=1938410758

# Command State
  .set SA_CMD_STATE_TIMER, 0                              # float
  .set SA_CMD_STATE_FRAME, SA_CMD_STATE_TIMER + 4         # float
  .set SA_CMD_STATE_SCRIPT, SA_CMD_STATE_FRAME + 4        # char*
  .set SA_CMD_STATE_STACK_DEPTH, SA_CMD_STATE_SCRIPT + 4  # int
  .set SA_CMD_STATE_STACK, SA_CMD_STATE_STACK_DEPTH + 4   # char* [5]
  .set SA_CMD_STATE_SIZE, SA_CMD_STATE_STACK + 20

# Event Scripts
  # Spawn Hitbox 
  .set SA_SCRIPT_HB_SPAWN_COMMAND,    0      # Byte 0: CCCC CCII (Command + Hitbox ID start)
  .set SA_SCRIPT_HB_SPAWN_INFO1,      0      # Bytes 0-3: Command, ID, Unknown-1, Bone, Unknown-2
  .set SA_SCRIPT_HB_SPAWN_DAMAGE,     3      # Byte 3: Damage
  .set SA_SCRIPT_HB_SPAWN_SIZE,       4      # Bytes 4-5: Size (16-bit)
  .set SA_SCRIPT_HB_SPAWN_OFST_Z,     6      # Bytes 6-7: Z-Offset (16-bit)  
  .set SA_SCRIPT_HB_SPAWN_OFST_Y,     8      # Bytes 8-9: Y-Offset (16-bit)
  .set SA_SCRIPT_HB_SPAWN_OFST_X,     10     # Bytes 10-11: X-Offset (16-bit)
  .set SA_SCRIPT_HB_SPAWN_INFO2,      12     # Bytes 12-15: Angle, KB Growth, Weight KB
  .set SA_SCRIPT_HB_SPAWN_INFO3,      16     # Bytes 16-19: Base KB, Element, Shield Dmg, SFX, etc.
  .set SA_SCRIPT_HB_SPAWN_STRUCT_SIZE, 20    # Total size: 20 bytes


################################################################################
# Directives
################################################################################

# Events
  # Control
    .set SA_EVENT_END, 0
    .set SA_EVENT_TIMER_SYNC, 1
    .set SA_EVENT_TIMER_ASYNC, 2
    .set SA_EVENT_LOOP_SET, 3
    .set SA_EVENT_LOOP_EXEC, 4
    .set SA_EVENT_SUBROUTINE, 5
    .set SA_EVENT_RETURN, 6
    .set SA_EVENT_GOTO, 7
    .set SA_EVENT_TIMER_SET, 8
    .set SA_EVENT_SCREEN_FLASH, 9

  # Fighter
    .set SA_EVENT_GFX_SPAWN, 10 #
    .set SA_EVENT_HITBOX_SPAWN, 11
    .set SA_EVENT_HITBOX_ADJUST_DMG, 12
    .set SA_EVENT_HITBOX_ADJUST_RADIUS, 13
    .set SA_EVENT_HITBOX_SET_INTERACTION, 14
    .set SA_EVENT_HITBOX_REMOVE, 15
    .set SA_EVENT_HITBOX_REMOVE_ALL, 16
    .set SA_EVENT_SFX, 17
    .set SA_EVENT_SFX_RAND, 18
    .set SA_EVENT_SET_FLAG, 19
    .set SA_EVENT_REVERSE_DIR, 20
    .set SA_EVENT_GANON_FALCON_FLAG, 21 # for kick/punch texture
    .set SA_EVENT_JAB_COMBO, 22
    .set SA_EVENT_IASA, 23
    .set SA_EVENT_PROJECTILE, 24
    .set SA_EVENT_SET_AIRBORNE, 25
    .set SA_EVENT_BODY_STATE_CHANGE, 26
    .set SA_EVENT_BONE_STATE_CHANGE_ALL, 27
    .set SA_EVENT_BONE_STATE_CHANGE, 28
    .set SA_EVENT_JAB_FOLLOW_UP, 29
    .set SA_EVENT_JAB_RAPID, 30
    .set SA_EVENT_MODEL_CHANGE, 31
    .set SA_EVENT_MODEL_RESET, 32
    .set SA_EVENT_MODEL_REMOVE, 33
    .set SA_EVENT_THROW, 34
    .set SA_EVENT_VIS_ITEM, 35
    .set SA_EVENT_VIS_ARTICLE, 36
    .set SA_EVENT_VIS_FIGHTER, 37
    .set SA_EVENT_SFX_RAND2, 38
    .set SA_EVENT_SFX_STAGE, 39
    .set SA_EVENT_ANIM_TEX, 40
    .set SA_EVENT_ANIM_MODEL, 41
    .set SA_EVENT_ANIM_ARTICLE, 42
    .set SA_EVENT_RUMBLE, 43
    .set SA_EVENT_RUMBLE_REMOVE, 44
    .set SA_EVENT_BEAM_SWORD, 45
    .set SA_EVENT_BODY_AURA, 46
    .set SA_EVENT_BODY_AURA_REMOVE, 47
    .set SA_EVENT_0xC0, 48
    .set SA_EVENT_SWORD_TRAIL, 49
    .set SA_EVENT_BONE_SET_PHYS, 50
    .set SA_EVENT_DMG_SELF, 51
    .set SA_EVENT_FOOTSNAP, 52
    .set SA_EVENT_VIS_KIRBY_ARTICLE, 53
    .set SA_EVENT_FX_FOOTSTEP, 54
    .set SA_EVENT_FX, 55
    .set SA_EVENT_SMASH_CHARGE, 56
    .set SA_EVENT_VIS_CLOAK, 57
    .set SA_EVENT_FX_WIND, 58

# Hitbox Elements
  .set SA_HB_TYPE_NONE, 0
  .set SA_HB_TYPE_FIRE, 1
  .set SA_HB_TYPE_ELECTRIC, 2
  .set SA_HB_TYPE_x3, 3
  .set SA_HB_TYPE_x4, 4
  .set SA_HB_TYPE_ICE, 5
  .set SA_HB_TYPE_SING, 6
  .set SA_HB_TYPE_x7, 7
  .set SA_HB_TYPE_GRAB, 8
  .set SA_HB_TYPE_BURY, 9
  .set SA_HB_TYPE_CAPE, 10
  .set SA_HB_TYPE_TRIGGER, 11
  .set SA_HB_TYPE_DISABLE, 12
  .set SA_HB_TYPE_DARKNESS, 13
  .set SA_HB_TYPE_SCREW, 14
  .set SA_HB_TYPE_LIPSTICK, 15
  .set SA_HB_TYPE_FAN, 16

################################################################################
# Macros
################################################################################

.macro GET_HB_BASE_DAMAGE reg, data_reg
    lwz \reg, SA_SCRIPT_HB_SPAWN_INFO1(\data_reg)
    rlwinm \reg, \reg, 0, 22, 31        # Extract bits 9-0 (10 bits)
.endm

.macro SET_HB_BASE_DAMAGE data_reg, value_reg
    lwz r0, SA_SCRIPT_HB_SPAWN_INFO1(\data_reg)
    rlwimi r0, \value_reg, 0, 22, 31    # Insert 10 bits at position 0
    stw r0, SA_SCRIPT_HB_SPAWN_INFO1(\data_reg)
.endm

# SA_SCRIPT_HB_SPAWN_INFO2
.macro GET_HB_ANGLE reg, data_reg
    lwz \reg, SA_SCRIPT_HB_SPAWN_INFO2(\data_reg)
    rlwinm \reg, \reg, 9, 23, 31        # Extract bits 31-23 (9 bits) - Angle
.endm

.macro SET_HB_ANGLE data_reg, value_reg
    lwz r0, SA_SCRIPT_HB_SPAWN_INFO2(\data_reg)
    rlwimi r0, \value_reg, 23, 0, 8    # Insert 9 bits at position 23
    stw r0, SA_SCRIPT_HB_SPAWN_INFO2(\data_reg)
.endm

# KNOCKBACK GROWTH
.macro GET_HB_KB_GROWTH reg, data_reg
    lwz \reg, SA_SCRIPT_HB_SPAWN_INFO2(\data_reg)
    rlwinm \reg, \reg, 18, 23, 31       # Extract bits 22-14 (9 bits)
.endm

.macro SET_HB_KB_GROWTH reg, data_reg
    lwz r0, SA_SCRIPT_HB_SPAWN_INFO2(\data_reg)
    rlwimi r0, \reg, 14, 9, 17    # Insert 9 bits at position 14
    stw r0, SA_SCRIPT_HB_SPAWN_INFO2(\data_reg)
.endm

# SA_SCRIPT_HB_SPAWN_INFO3
.macro GET_HB_SHIELD_DAMAGE reg, data_reg
    lwz \reg, SA_SCRIPT_HB_SPAWN_INFO3(\data_reg)
    rlwinm \reg, \reg, 22, 24, 31       # Extract bits 17-10 (8 bits)
.endm

.macro SET_HB_SHIELD_DAMAGE data_reg, value_reg
    lwz r0, SA_SCRIPT_HB_SPAWN_INFO3(\data_reg)
    rlwimi r0, \value_reg, 10, 14, 21    # Insert 8 bits at position 10
    stw r0, SA_SCRIPT_HB_SPAWN_INFO3(\data_reg)
.endm



.macro GET_HB_ELEMENT reg, data_reg
    lwz \reg, SA_SCRIPT_HB_SPAWN_INFO3(\data_reg)
    rlwinm \reg, \reg, 14, 27, 31    # Rotate left 14 to move bits 18-22 to bits 0-4, mask bits 27-31 (the low 5 bits)
.endm

.macro SET_HB_ELEMENT value_reg, data_reg
    lwz r0, SA_SCRIPT_HB_SPAWN_INFO3(\data_reg)  # Load current value
    rlwimi r0, \value_reg, 18, 9, 13             # Insert bits 0-4 of value_reg into bits 18-22 (PowerPC bits 9-13)
    stw r0, SA_SCRIPT_HB_SPAWN_INFO3(\data_reg)  # Store back
.endm


.macro GET_HB_OFFSET_X_FLOAT freg, data_reg
    lha r3, SA_SCRIPT_HB_SPAWN_OFST_X(\data_reg)  # Load signed 16-bit
    branchl r12, FN_IntToFloat
    fmuls \freg, f0, f1                         # Scale the result
.endm

.macro GET_HB_OFFSET_X reg, data_reg
    lha \reg, SA_SCRIPT_HB_SPAWN_OFST_X(\data_reg)
.endm

.macro SET_HB_OFFSET_X value_reg, data_reg
    sth \value_reg, SA_SCRIPT_HB_SPAWN_OFST_X(\data_reg)
.endm


# Items
.macro GET_ITEM_HB_SHIELD_DAMAGE reg, data_reg
    lwz \reg, SA_SCRIPT_HB_SPAWN_INFO3(\data_reg)
    rlwinm	\reg, \reg, 15, 0, 8 # (0001ff00)
    srawi	\reg, \reg, 24
.endm

.macro SET_ITEM_HB_SHIELD_DAMAGE value_reg, data_reg
    lwz r0, SA_SCRIPT_HB_SPAWN_INFO3(\data_reg)  # Load current value
    rlwimi r0, \value_reg, 9, 9, 17              # Insert bits 0-8 of value_reg into bits 9-17 of r0
    stw r0, SA_SCRIPT_HB_SPAWN_INFO3(\data_reg)  # Store back
.endm

# make sure the destination has room at the end for the original scripts pointer
.macro COPY_SCRIPT_DATA reg_dest, reg_cmd, script_size
  mr r3, \reg_dest
  lwz r4, 0x8(\reg_cmd) # script
  stw r4, \script_size(\reg_dest)
  li r5, \script_size
  branchl r12, memcpy
.endm


.endif
.set HEADER_SUBACTIONS, 1
