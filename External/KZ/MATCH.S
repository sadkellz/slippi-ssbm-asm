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

.set OFST_TINT, 0
.set OFST_TEYE, 4
.set OFST_FOV, 8
.set OFST_TFOV, 12


.endif
.set HEADER_MATCH, 1
