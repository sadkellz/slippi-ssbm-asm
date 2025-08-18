.ifndef HEADER_MATCH
################################################################################
# Functions
################################################################################
.set Scene_SetPauseFlag, 0x801a4634 # (u8 flag)
.set Scene_ClearPauseFlag, 0x801a4674 # (u8 flag)

.set MatchInfo_IsTeams, 0x8016b168
.set SFX_PlayAnnouncerSFX, 0x800243f4


################################################################################
# Structs
################################################################################
.set PAUSE_UI_BG, 0 # background jobj
.set PAUSE_UI_STICK, PAUSE_UI_BG + 4 # stick jobj
.set PAUSE_UI_LRAS, PAUSE_UI_STICK + 4 # lras jobj
.set PAUSE_UI_Z, PAUSE_UI_LRAS + 4 # z jobj
.set PAUSE_UI_STICK_BORDER, PAUSE_UI_Z + 4 # stick border jobj
.set PAUSE_UI_SLOT, PAUSE_UI_STICK_BORDER + 4 # player slot

.set IFVSCAM_ARCHIVE, 0
.set IFVSCAM_JOBJ_UI, IFVSCAM_ARCHIVE + 4
.set IFVSCAM_JOBJ_PROMPT, IFVSCAM_JOBJ_UI + 4
# it continues but idk rn

.set DYN_MODEL_JOINT, 0                                     # joint *
.set DYN_MODEL_ANIMJOINT, DYN_MODEL_JOINT + 4               # animjoint **
.set DYN_MODEL_MATANIMJOINT, DYN_MODEL_ANIMJOINT + 4        # matanimjoint **
.set DYN_MODEL_SHAPEANIMJOINT, DYN_MODEL_MATANIMJOINT + 4   # shapeanimjoint **

.set HSD_FOG_OBJ, 0 # HSD_Obj
.set HSD_FOG_TYPE, HSD_FOG_OBJ + 8 # u32
.set HSD_FOG_ADJ, HSD_FOG_TYPE + 4 # HSD_FogAdj*
.set HSD_FOG_START, HSD_FOG_ADJ + 4 # float
.set HSD_FOG_END, HSD_FOG_START + 4 # float
.set HSD_FOG_COLOR, HSD_FOG_END + 4 # GXcolor
.set HSD_FOG_AOBJ, HSD_FOG_COLOR + 4 # HSD_AObj


################################################################################
# Directives
################################################################################
.set stc_match_info, 0x8046b6a0
.set stc_hud_vis, 0x804d6d58
.set stc_mode3_vars, 0x803bcd04

.set stc_pause_scdata, 0x804d6700 # HSD_Archive*
.set stc_gobj_pause, 0x804d6704
.set stc_pause_data, 0x80479b10
.set stc_pause_stickmult, 0x804da980 # 10.0

.set stc_ifvscam_str, 0x804d4260
.set stc_ifvscam, 0x80479bc8
.set stc_ifcammodel_str, 0x803da73c

.set stc_ifall, 0x804d6d5c
.set stc_str_ScInfDmg_scene_data, 0x803f94d0

.set stc_str_gmtou1p, 0x804d41e0
.set stc_str_ScGamTour_scene_data, 0x803da260

# stage
.set stc_stage_fog, 0x8049e7f4

.set OFST_TINT, 0
.set OFST_TEYE, 4
.set OFST_FOV, 8
.set OFST_TFOV, 12


.endif
.set HEADER_MATCH, 1
