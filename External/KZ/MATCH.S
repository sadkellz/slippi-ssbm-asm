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


################################################################################
# Directives
################################################################################
.set stc_match_info, 0x8046b6a0
.set stc_hud_vis, 0x804d6d58
.set stc_mode3_vars, 0x803bcd04

.set OFST_TINT, 0
.set OFST_TEYE, 4
.set OFST_FOV, 8
.set OFST_TFOV, 12


.endif
.set HEADER_MATCH, 1
