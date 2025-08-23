.ifndef HEADER_STOCKRUN
################################################################################
# Functions
################################################################################

.set StockRun_RandomizeCards, 0x804a3120

################################################################################
# Structs
################################################################################
# StockRun Data
.set SRD_GOBJ_INIT, 0 # 0x0
.set SRD_GOBJ_MENU, SRD_GOBJ_INIT + 4 # 0x4
.set SRD_COBJ_DESC, SRD_GOBJ_MENU + 4 # 0x8
.set SRD_JOBJ_PANELS, SRD_COBJ_DESC + 4 # 0xC - jobj[4]
.set SRD_TEXTS, SRD_JOBJ_PANELS + 16 # 0x1C - text[4]
.set SRD_CURRENT_PANEL, SRD_TEXTS + 16 # 0x2C - jobj
.set SRD_CURRENT_CARDS, SRD_CURRENT_PANEL + 4 # 0x30 int[4]

# StockRun Context
.set SRC_SLOT_ORDER, 0                              # int[2]
.set SRC_CURRENT_PICKER, SRC_SLOT_ORDER + 8         # int
.set SRC_TRANSITION_TIMER, SRC_CURRENT_PICKER + 4   # int
.set SRC_GAME_STATE, SRC_TRANSITION_TIMER + 4       # int
.set SRC_ACTIVE_SLOT, SRC_GAME_STATE + 4            # int
.set SRC_HOVER_STATE, SRC_ACTIVE_SLOT + 4           # int

# StockRun Player
.set SRP_CARDS, 0 # int bitfield
.set SRP_SIZE, SRP_CARDS + 4

################################################################################
# Directives
################################################################################
.set stc_sr_data, 0x804a2f48
.set stc_sr_sistable, 0x804a3048
.set stc_sr_plydata, 0x804a304c # this has a size of SRP_SIZE * 4

# StockRun Game State
.set SRGS_INIT, 0
.set SRGS_CARD_SELECT, 1
.set SRGS_TRANSITION, 2
.set SRGS_GAME_ACTIVE, 3
.set SRGS_GAME_TRANSITION, 4
.set SRGS_GAME_CARD_SELECT, 5

# StockRun main defs
.set PAUSE_BIT_MASK, 0x08
.set OFST_RULES, 0x24C0
.set OFST_PAUSE, 0xA # bitfield in rules
.set MATCH_FREEZE_FLAG, 4 # wont freeze cameras/ui
.set CAM_ZOOM, 0x41200000  # 10.0 as float
.set SETUP_START_FRAME, 64 # first frame after entry
.set ALLOW_INPUTS_FRAME, 144 # just as the camera settles
.set TRANSITION_FRAMES, 80 # 
.set MAX_PLAYERS, 2 # not supporting teams/ffa
.set MAX_PORTS, 4
.set DEBUG_PAD_UNION, 4  # will return if anyone presses a button
.set SR_GOBJ_PRIO, 111

# GX
.set  COBJ_GXPRI, 8
.set  MY_GXPRI, 80
.set  TEXT_GXLINK, 13
.set  PANEL_GXLINK, 14
.set  STICK_GXLINK, 18

# Menus
.set MENU_START_FRAME, SETUP_START_FRAME - 20 # animate 20 frames before we can input
.set MENU_TRANSITION_FRAMES, 20 # 
.set IF_PANEL_IDX, 5
.set IF_BG_IDX, 2
.set MIN_SCALE, RTOC_0_5
.set MAX_SCALE, RTOC_2
.set SIS_ID, 3
.set CARD_COUNT, 10 # also the number of replaced SIS entries we've made

# StockRun Cards
.set SR_CARD_KBINC, 0
.set SR_CARD_KBDEC, 1
.set SR_CARD_CRIT, 2
.set SR_CARD_SHIELDHP, 3


################################################################################
# Macros
################################################################################

.macro get_game_state reg_state
  loadwz \reg_state, stc_sr_data # init gobj
  lwz \reg_state, GOBJ_USERDATA(\reg_state)
  lwz \reg_state, SRC_GAME_STATE(\reg_state)
.endm

.macro get_active_pad reg_pad
  loadwz \reg_pad, stc_sr_data
  lwz \reg_pad, GOBJ_USERDATA(\reg_pad)
  lwz \reg_pad, SRC_ACTIVE_SLOT(\reg_pad)
  get_port_pad \reg_pad
.endm


.endif
.set HEADER_STOCKRUN, 1
