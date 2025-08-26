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
    .set SA_SCRIPT_HB_SPAWN_INFO, 0
    .set SA_SCRIPT_HB_SPAWN_RADIUS, SA_SCRIPT_HB_SPAWN_DATA + 4
    .set SA_SCRIPT_HB_SPAWN_OFST_Z, SA_SCRIPT_HB_RADIUS + 2
    .set SA_SCRIPT_HB_SPAWN_OFST_Y, SA_SCRIPT_HB_OFST_Z + 2
    .set SA_SCRIPT_HB_SPAWN_OFST_X, SA_SCRIPT_HB_OFST_Y + 2
    .set SA_SCRIPT_HB_SPAWN_INFO2, SA_SCRIPT_HB_SPAWN_OFST_X + 2
    .set SA_SCRIPT_HB_SPAWN_INFO3, SA_SCRIPT_HB_SPAWN_INFO2 + 4
    .set SA_SCRIPT_HB_SPAWN_SIZE, SA_SCRIPT_HB_SPAWN_INFO3 + 4    # 0x14


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


.endif
.set HEADER_SUBACTIONS, 1
