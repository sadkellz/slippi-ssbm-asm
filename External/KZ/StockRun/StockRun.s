.ifndef HEADER_STOCKRUN
################################################################################
# Functions
################################################################################

################################################################################
# Structs
################################################################################
# StockRun Data
.set SRD_GOBJ_INIT, 0
.set SRD_GOBJ_MENU, SRD_GOBJ_INIT + 4
.set SRD_COBJ_DESC, SRD_GOBJ_MENU + 4
.set SRD_JOBJ_PANEL, SRD_COBJ_DESC + 4

# StockRun Context
.set SRC_SLOT_ORDER, 0                              # int[2]
.set SRC_CURRENT_PICKER, SRC_SLOT_ORDER + 8         # int
.set SRC_TRANSITION_TIMER, SRC_CURRENT_PICKER + 4   # int
.set SRC_GAME_STATE, SRC_TRANSITION_TIMER + 4       # int

################################################################################
# Directives
################################################################################
.set stc_sr_data, 0x804a2f48

# StockRun Game State
.set SRGS_INIT, 0
.set SRGS_CARD_SELECT, 1
.set SRGS_TRANSITION, 2
.set SRGS_GAME_ACTIVE, 3

# StockRun main defs
.set PAUSE_BIT_MASK, 0x08
.set OFST_RULES, 0x24C0
.set OFST_PAUSE, 0xA # bitfield in rules
.set MATCH_FREEZE_FLAG, 4 # wont freeze cameras/ui
.set CAM_ZOOM, 0x41200000  # 10.0 as float
.set SETUP_START_FRAME, 64 # first frame after entry
.set ALLOW_INPUTS_FRAME, 144 # just as the camera settles
.set TRANSITION_FRAMES, 100 # 
.set MAX_PLAYERS, 2 # not supporting teams/ffa
.set MAX_PORTS, 4
.set DEBUG_PAD_UNION, 4  # will return if anyone presses a button
.set SR_GOBJ_PRIO, 111

# GX
.set  COBJ_GXPRI, 8
.set  MY_GXPRI, 80
.set  PANEL_GXLINK, 13
.set  STICK_GXLINK, 14

# Menus
.set MENU_START_FRAME, SETUP_START_FRAME - 20 # animate 20 frames before we can input
.set MENU_TRANSITION_FRAMES, 20 # 
.set IF_PANEL_IDX, 5

.endif
.set HEADER_STOCKRUN, 1
