.ifndef HEADER_STOCKRUN
################################################################################
# Functions
################################################################################

################################################################################
# Structs
################################################################################
.set SR_GOBJ_INIT, 0
.set SR_GOBJ_MENU, SR_GOBJ_INIT + 4

# init struct
.set ACTIVE_SLOTS, 0
.set ACTIVE_PICKER, ACTIVE_SLOTS + 4
.set TRANSITION_TIMER, ACTIVE_PICKER + 4

################################################################################
# Directives
################################################################################
.set stc_sr_data, 0x804a2f48

# InitStart
.set PAUSE_BIT_MASK, 0x08
.set OFST_RULES, 0x24C0
.set OFST_PAUSE, 0xA # bitfield in rules
.set MATCH_FREEZE_FLAG, 4 # wont freeze cameras/ui
.set CAM_ZOOM, 0x41200000  # 10.0 as float
.set SETUP_START_FRAME, 64 # first frame after entry
.set ALLOW_INPUTS_FRAME, 144 # just as the camera settles
.set TRANSITION_FRAMES, 80 # same amt of time as the initial transition for the 2nd picker
.set MAX_PLAYERS, 2 # not supporting teams/ffa
.set MAX_PORTS, 4
.set DEBUG_PAD_UNION, 4  # will return if anyone presses a button

# Menus
.set MENU_START_FRAME, SETUP_START_FRAME - 20 # animate 20 frames before we can input
.set MENU_TRANSITION_FRAMES, 20 # 

.endif
.set HEADER_STOCKRUN, 1
