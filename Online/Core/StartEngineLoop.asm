################################################################################
# Address: 0x801a4de4
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"

.set REG_FRAME_INDEX, 31
.set REG_ODB_ADDRESS, 30
.set REG_DESYNC_ENTRY_ADDRESS, 29
.set REG_REMOTE_RXB, 28
.set REG_INPUTS_TO_PROCESS, 27 # From parent
.set REG_INPUT_PROCESS_COUNTER, 26 # From parent
.set REG_INTERRUPT_IDX, 25
.set REG_TEXT_STRUCT, 24
.set REG_DATA_ADDR, 23

# Replaced code
branchl r12, HSD_PerfSetStartTime
b CODE_START

DATA_BLRL:
blrl
.set DOFST_TEXT_BASE_Z, 0
.float 0
.set DOFST_TEXT_BASE_CANVAS_SCALING, DOFST_TEXT_BASE_Z + 4
.float 1

.set DOFST_TEXT_X_POS, DOFST_TEXT_BASE_CANVAS_SCALING + 4
.float 1.3
.set DOFST_TEXT_Y_POS, DOFST_TEXT_X_POS + 4
.float -45
.set DOFST_TEXT_SIZE, DOFST_TEXT_Y_POS + 4
.float 0.07
.set DOFST_TEXT_COLOR, DOFST_TEXT_SIZE + 4
.long 0xFF0000FF

.set DOFST_TEXT_STRING, DOFST_TEXT_COLOR + 4
.string "DISCONNECTED"
.align 2

################################################################################
# Computes checksum from game state
################################################################################
.set REG_PLAYER_STATIC_ADDRESS, 31
.set REG_CHECKSUM, 30
.set REG_LAST_PLAYER_ADDRESS, 29

FN_COMPUTE_CHECKSUM:
backup

load REG_PLAYER_STATIC_ADDRESS, 0x80453080
load REG_LAST_PLAYER_ADDRESS, 0x80455C30
li REG_CHECKSUM, 0

FN_COMPUTE_CHECKSUM_LOOP_START:
# The helper function will do nothing if the player entity obj's are zero, so missing players
# will be ignored correctly in the checksum
mr r3, REG_CHECKSUM
lwz r4, 0xB0(REG_PLAYER_STATIC_ADDRESS) # Get player entity obj (gobj?)
bl FN_COMPUTE_CHECKSUM_HELPER
lwz r4, 0xB4(REG_PLAYER_STATIC_ADDRESS) # Get secondary player entity obj (gobj?) (sheik/nana)
bl FN_COMPUTE_CHECKSUM_HELPER
mr REG_CHECKSUM, r3
FN_COMPUTE_CHECKSUM_LOOP_CONTINUE:
addi REG_PLAYER_STATIC_ADDRESS, REG_PLAYER_STATIC_ADDRESS, 0xE90
cmpw REG_PLAYER_STATIC_ADDRESS, REG_LAST_PLAYER_ADDRESS
ble FN_COMPUTE_CHECKSUM_LOOP_START # Loops until we have processed all 4 potential players

mr r3, REG_CHECKSUM
restore
blr

################################################################################
# Helper function for computing checksum
# ------------------------------------------------------------------------------
# Inputs: [r3] Checksum, [r4] PlayerEntityGobj
# ------------------------------------------------------------------------------
# Output: Checksum
################################################################################
FN_COMPUTE_CHECKSUM_HELPER:
cmpwi r4, 0
beq FN_COMPUTE_CHECKSUM_HELPER_EXIT
lwz r5, 0x2C(r4) # Fetch char data
lwz r4, 0x10(r5) # ActionStateID
xor r3, r3, r4
lwz r4, 0xB0(r5) # Position X
xor r3, r3, r4
lwz r4, 0xB4(r5) # Position Y
xor r3, r3, r4
lwz r4, 0x1830(r5) # Percent damage
xor r3, r3, r4
# logf LOG_LEVEL_INFO, "[SEL] Checksum Values: %08x | %08x | %08x | %08x", "lwz r8, 0x1830(r5)", "lwz r7, 0xB4(r5)", "lwz r6, 0xB0(r5)", "lwz r5, 0x10(r5)"
FN_COMPUTE_CHECKSUM_HELPER_EXIT:
blr

CODE_START:
# backup registers and sp
backup

################################################################################
# Short Circuit Conditions
################################################################################
# Ensure that this is an online match
getMinorMajor r3
cmpwi r3, SCENE_ONLINE_IN_GAME
bne EXIT

load r3, 0x80479d64
lwz r3, 0x0(r3) # 0x80479d64 - Believed to be some loading state
cmpwi r3, 0 # Loading state should be zero when game starts
bne EXIT

################################################################################
# Initialize
################################################################################
# fetch data to use throughout function
lwz REG_ODB_ADDRESS, OFST_R13_ODB_ADDR(r13) # data buffer address
loadGlobalFrame REG_FRAME_INDEX
lwz REG_REMOTE_RXB, ODB_RXB_ADDR(REG_ODB_ADDRESS)

branchl r12, OSDisableInterrupts
mr REG_INTERRUPT_IDX, r3

# Log the frame we are starting
# logf LOG_LEVEL_INFO, "[SEL] [%d] Starting frame processing... r26: %d", "mr r5, REG_FRAME_INDEX", "mr r6, 26"

################################################################################
# Check if we should display disconnect message
################################################################################
lbz r3, ODB_IS_DISCONNECT_STATE_DISPLAYED(REG_ODB_ADDRESS)
cmpwi r3, 0
bne DISPLAY_DISCONNECT_END # If already displayed, do nothing

lbz r3, ODB_IS_DISCONNECTED(REG_ODB_ADDRESS)
cmpwi r3, 0
beq DISPLAY_DISCONNECT_END # If not disconnected, do nothing

# We are disconnected, display text and play sound
li r3, 3
branchl r12, SFX_Menu_CommonSound

################################################################################
# Start prepping text display
################################################################################
bl DATA_BLRL
mflr REG_DATA_ADDR

li r3, 2
lwz r4, ODB_HUD_CANVAS(REG_ODB_ADDRESS) # HUD canvas used for names and delay (does not stretch in widescreen)
branchl r12, Text_CreateStruct
mr REG_TEXT_STRUCT, r3

# Set text kerning to close
li r4, 0x1
stb r4, 0x49(REG_TEXT_STRUCT)
# Set text to align center
li r4, 0x1
stb r4, 0x4A(REG_TEXT_STRUCT)

# Store Base Z Offset
lfs f1, DOFST_TEXT_BASE_Z(REG_DATA_ADDR) #Z offset
stfs f1, 0x8(REG_TEXT_STRUCT)

# Scale Canvas Down
lfs f1, DOFST_TEXT_BASE_CANVAS_SCALING(REG_DATA_ADDR)
stfs f1, 0x24(REG_TEXT_STRUCT)
stfs f1, 0x28(REG_TEXT_STRUCT)

# Initialize header
lfs f1, DOFST_TEXT_X_POS(REG_DATA_ADDR)
lfs f2, DOFST_TEXT_Y_POS(REG_DATA_ADDR)
mr r3, REG_TEXT_STRUCT
addi r4, REG_DATA_ADDR, DOFST_TEXT_STRING
branchl r12, Text_InitializeSubtext

# Set header text size
mr r3, REG_TEXT_STRUCT
li r4, 0
lfs f1, DOFST_TEXT_SIZE(REG_DATA_ADDR)
lfs f2, DOFST_TEXT_SIZE(REG_DATA_ADDR)
branchl r12, Text_UpdateSubtextSize

# Set text color
mr r3, REG_TEXT_STRUCT
li r4, 0
addi r5, REG_DATA_ADDR, DOFST_TEXT_COLOR
branchl r12, Text_ChangeTextColor

# Indicate we have displayed disconnect message. Dont worry, we can't rollback
# if disconnected so we dont have to worry about things getting reset
li r3, 1
stb r3, ODB_IS_DISCONNECT_STATE_DISPLAYED(REG_ODB_ADDRESS)

# Check if we should end game (ranked mode), could maybe check if pause is fully off instead
lbz r3, OFST_R13_ONLINE_MODE(r13)
cmpwi r3, ONLINE_MODE_RANKED
bne DISPLAY_DISCONNECT_END

# ASM Notes. Match struct at 0x8046b6a0 has info about the game. The early values seem to be control
# values. Here are notes on offsets:
# 0x0 (u8): Control byte. 0 during game, 1 during GAME!, 3 to transition to next scene
# 0x1 (u8): Stores index of last person that paused
# 0x8 (u8): Stores type of game exit, instructs which text to show on GAME! screen?
# 0x30 (u8): Counter that counts up during GAME! screen until it is greater than timeout
# 0x24D5 (u8): Max time to stay on GAME! screen

# Write values which will cause line at 0x8016d2c8 to detect game has ended
load r3, 0x8046b6a0 # Some static match state struct
lbz r4, ODB_ONLINE_PLAYER_INDEX(REG_ODB_ADDRESS)
stb r4, 0x1(r3) # Write "pauser" index
li r4, 0x7
stb r4, 0x8(r3) # Write that the game is exiting as an LRAS
li r4, 0x37 # Default value for this is 0x6e
stb r4, 0x24D5(r3) # Overwrite the GAME! think max time to make it shorter

# Hide HUD
# branchl r12, 0x802f3394 # Pause_HideHUD

DISPLAY_DISCONNECT_END:

################################################################################
# Check if we should load state
################################################################################
# Check if a rollback is active
lbz r3, ODB_STABLE_ROLLBACK_IS_ACTIVE(REG_ODB_ADDRESS)
cmpwi r3, 0
beq HANDLE_ROLLBACK_INPUTS_END # If rollback not active, check if we need to save state

# Check if we have a savestate, if so, we need to load state
lbz r3, ODB_STABLE_ROLLBACK_SHOULD_LOAD_STATE(REG_ODB_ADDRESS)
cmpwi r3, 0
beq CONTINUE_ROLLBACK # If we don't need to load state, just continue rollback

################################################################################
# Load state and restore data
################################################################################
# logf LOG_LEVEL_INFO, "[SEL] [%d] Considering loading state: %d", "mr r5, REG_FRAME_INDEX", "lwz r6, ODB_STABLE_SAVESTATE_FRAME(REG_ODB_ADDRESS)"

# If we need a load a state but the requested frame is either equal to or greater than the current
# frame, that means that we have advanced some frames and determined a rollback was needed on the
# advanced frames to a frame that has yet been processed. In this case, we don't want to load state.
# Instead, if the frame is greater than the current frame, we let the frame process as normal and
# don't do any roll back logic. If the frame is equal, we process the rollback without loading a
# state
lwz r3, ODB_STABLE_SAVESTATE_FRAME(REG_ODB_ADDRESS)
# cmpw REG_FRAME_INDEX, r3
# bgt SKIP_LOAD_LOG
# logf LOG_LEVEL_NOTICE, "[SEL] [%d] Surprising state load: %d", "mr r5, REG_FRAME_INDEX", "lwz r6, ODB_STABLE_SAVESTATE_FRAME(REG_ODB_ADDRESS)"
cmpw REG_FRAME_INDEX, r3
beq SKIP_LOAD_STATE
blt HANDLE_ROLLBACK_INPUTS_END
SKIP_LOAD_LOG:

# logf LOG_LEVEL_WARN, "[SEL] [%d] Loading state: %d", "mr r5, REG_FRAME_INDEX", "lwz r6, ODB_STABLE_SAVESTATE_FRAME(REG_ODB_ADDRESS)"

# Load state from savestate frame
lwz r3, ODB_SAVESTATE_SSRB_ADDR(REG_ODB_ADDRESS)
lwz r4, ODB_STABLE_SAVESTATE_FRAME(REG_ODB_ADDRESS) # Stable because we only load one state per iteration
lwz r5, ODB_SAVESTATE_SSCB_ADDR(REG_ODB_ADDRESS)
branchl r12, FN_LoadSavestate
SKIP_LOAD_STATE:

# Unfortunately if we ended up saving a state, it was after predicted inputs
# were added to the raw input buffer. This block will rewind the raw controller
# data index such that subsequent calls to RenewInputs will add inputs to the
# right places.
# Update 2/1/22: I'm a bit worried this won't always work with frame advance though I haven't
# seen a desync in testing yet. If frame advance causes UCF desyncs, this section of code could be
# why. Think the code primarily exists to make sure UCF velocity calculations work correctly
branchl r12, PadAlarmCheck # This loads the number of inputs into r3 (normally 1), should we just use HSD_PadGetRawQueueCount instead?
load r5, 0x804c1f78 # Start of raw controller data section
lbz r4, 0x2(r5) # Load the current raw data index
sub. r4, r4, r3 # Subtract the number of inputs from the raw data index
bge SKIP_ADJUST
lbz r3, 0(r5)
add r4, r4, r3 # Increment by 5, uses variable but could be fixed
SKIP_ADJUST:
stb r4, 0x2(r5) # Write adjusted offset back
li r3, 0
stb r3, 0x3(r5) # Indicate there are no raw inputs

loadGlobalFrame REG_FRAME_INDEX # This might have changed since savestate load

 # Since ODB is preserved through savestate, we need to indicate we've gone back
lwz r3, ODB_SAVESTATE_FRAME(REG_ODB_ADDRESS)
stw r3, ODB_FRAME(REG_ODB_ADDRESS)

.if DEBUG_INPUTS==1
logf LOG_LEVEL_WARN, "[Rollback] Finished reverting state to frame: %d", "mr r5, 3"
.endif

# Clear savestate and should load flags flag
li r3, 0
stb r3, ODB_SAVESTATE_IS_PREDICTING(REG_ODB_ADDRESS)
stb r3, ODB_PLAYER_SAVESTATE_IS_PREDICTING+0x0(REG_ODB_ADDRESS)
stb r3, ODB_PLAYER_SAVESTATE_IS_PREDICTING+0x1(REG_ODB_ADDRESS)
stb r3, ODB_PLAYER_SAVESTATE_IS_PREDICTING+0x2(REG_ODB_ADDRESS)
stb r3, ODB_ROLLBACK_SHOULD_LOAD_STATE(REG_ODB_ADDRESS)
stb r3, ODB_STABLE_ROLLBACK_SHOULD_LOAD_STATE(REG_ODB_ADDRESS)

################################################################################
# Fetch the next inputs during a rollback
################################################################################
CONTINUE_ROLLBACK:

# logf LOG_LEVEL_INFO, "[SEL] [%d] About to request rollback input. End frame: %d", "mr r5, REG_FRAME_INDEX", "lwz r6, ODB_STABLE_ROLLBACK_END_FRAME(REG_ODB_ADDRESS)"

# If there is an active rollback, trigger a controller status renewal.
# This should pick up on the new global frame timer inputs for this game engine
# loop and continue the rollback
branchl r12, RenewInputs_Prefunction

# logf LOG_LEVEL_INFO, "[SEL] [%d] Finished getting rollback input. End frame: %d", "mr r5, REG_FRAME_INDEX", "lwz r6, ODB_STABLE_ROLLBACK_END_FRAME(REG_ODB_ADDRESS)"

HANDLE_ROLLBACK_INPUTS_END:

################################################################################
# Store stable data that needs to update every time RenewInputs_Prefunction is
# called
################################################################################
# logf LOG_LEVEL_INFO, "[SEL] [%d] Considering updating stable finalized frame. CurrentStable: %d, Volatile: %d", "mr r5, REG_FRAME_INDEX", "lwz r6, ODB_STABLE_FINALIZED_FRAME(REG_ODB_ADDRESS)", "lwz r7, ODB_FINALIZED_FRAME(REG_ODB_ADDRESS)"
lwz r3, ODB_FINALIZED_FRAME(REG_ODB_ADDRESS)
cmpw REG_FRAME_INDEX, r3
bgt UPDATE_STABLE_FINALIZED # If cur frame greater than volatile, set stable to volatile
# Here the frame is equal to or less than or equal to the finalized frame. This might happen in
# the case of processing a rollback. Set the stable finalized frame to the current frame
mr r3, REG_FRAME_INDEX
b UPDATE_STABLE_FINALIZED
UPDATE_STABLE_FINALIZED:
lwz r4, ODB_STABLE_FINALIZED_FRAME(REG_ODB_ADDRESS)
cmpw r3, r4
ble SKIP_STABLE_FINALIZED_UPDATE
# logf LOG_LEVEL_WARN, "[SEL] [%d] Stable finalized value updated to %d. Volatile: %d", "mr r5, REG_FRAME_INDEX", "mr r6, 3", "lwz r7, ODB_FINALIZED_FRAME(REG_ODB_ADDRESS)"
stw r3, ODB_STABLE_FINALIZED_FRAME(REG_ODB_ADDRESS)
SKIP_STABLE_FINALIZED_UPDATE:

####################################################################################################
# Write checksum for this frame, overwrite if there is an existing entry for this frame,
# we won't send any checksums to the opponent that are past the finalized frame
####################################################################################################
# Start working towards fetching the entry where we are going to write
lwz r3, ODB_LOCAL_DESYNC_LAST_FRAME(REG_ODB_ADDRESS)
addi r3, r3, 1
sub. r3, REG_FRAME_INDEX, r3
lbz r4, ODB_LOCAL_DESYNC_WRITE_IDX(REG_ODB_ADDRESS)
blt SKIP_DESYNC_WRITE_IDX_ADJUST
# If we get here, this is a new frame we haven't seen yet, store that frame as the last frame
# and also increment the write index
incrementByteInBuf r6, REG_ODB_ADDRESS, ODB_LOCAL_DESYNC_WRITE_IDX, DESYNC_ENTRY_COUNT
stw REG_FRAME_INDEX, ODB_LOCAL_DESYNC_LAST_FRAME(REG_ODB_ADDRESS)
SKIP_DESYNC_WRITE_IDX_ADJUST:

# Here r3 is equal to the offset from the write index where we want to write our checksum, r4 is
# equal to the current write index, let's fetch the address to that entry
li r5, DESYNC_ENTRY_COUNT
adjustCircularIndex r4, r4, r3, r5, r6
# logf LOG_LEVEL_NOTICE, "Writing checksum for frame %d. Write idx: %d", "mr r5, REG_FRAME_INDEX", "mr r6, 4"
mulli r4, r4, DESYNC_ENTRY_SIZE
addi r3, r4, ODB_LOCAL_DESYNC_ARR
add REG_DESYNC_ENTRY_ADDRESS, REG_ODB_ADDRESS, r3

# Write the frame
stw REG_FRAME_INDEX, DESYNC_ENTRY_FRAME(REG_DESYNC_ENTRY_ADDRESS)

# Compute and write the checksum
bl FN_COMPUTE_CHECKSUM
stw r3, DESYNC_ENTRY_CHECKSUM(REG_DESYNC_ENTRY_ADDRESS)
# logf LOG_LEVEL_INFO, "Local checksum value %d: %08x", "mr r5, REG_FRAME_INDEX", "mr r6, 3"
SKIP_TAKE_CHECKSUM:

####################################################################################################
# Check local checksums against the remote checksums to see if we have a desync
####################################################################################################
li r12, 0 # Player index
CHECKSUM_CHECK_PLAYER_LOOP_START:
mulli r3, r12, DESYNC_ENTRY_SIZE
addi r3, r3, RXB_OPNT_DESYNC_ENTRY
add r11, REG_REMOTE_RXB, r3 # r11 now stores desync entry address for this remote player
lwz r10, DESYNC_ENTRY_FRAME(r11) # r10 now contains the desync entry frame
lwz r3, ODB_STABLE_FINALIZED_FRAME(REG_ODB_ADDRESS)
cmpw r10, r3 # If this checksum frame is greater than our stable finalized frame, skip for now
bgt CHECKSUM_CHECK_PLAYER_LOOP_CONTINUE
cmpwi r10, UNFREEZE_INPUTS_FRAME
ble CHECKSUM_CHECK_PLAYER_LOOP_CONTINUE

# Now we loop through all of our local frames to find the entry that matches
li r9, 0
FIND_CHECKSUM_LOOP_START:
mulli r3, r9, DESYNC_ENTRY_SIZE
addi r3, r3, ODB_LOCAL_DESYNC_ARR
add r8, REG_ODB_ADDRESS, r3 # r8 now contains the desync entry for our local player
lwz r3, DESYNC_ENTRY_FRAME(r8)
cmpw r10, r3
bne FIND_CHECKSUM_LOOP_CONTINUE
# Here we have found the desync entry for the latest finalized frame
lwz r3, DESYNC_ENTRY_CHECKSUM(r8)
lwz r4, DESYNC_ENTRY_CHECKSUM(r11)
# logf LOG_LEVEL_ERROR, "[SEL] [%d] Comparing Checksums. RemoteIdx: %d, Frame: %d, %08x vs %08x", "mr r5, REG_FRAME_INDEX", "mr r6, 12", "mr r7, 10", "mr r8, 3", "mr r9, 4"
cmpw r3, r4
beq FIND_CHECKSUM_LOOP_EXIT
logf LOG_LEVEL_NOTICE, "Desync detected!"
b FIND_CHECKSUM_LOOP_EXIT
FIND_CHECKSUM_LOOP_CONTINUE:
addi r9, r9, 1
cmpwi r9, DESYNC_ENTRY_COUNT
blt FIND_CHECKSUM_LOOP_START
FIND_CHECKSUM_LOOP_EXIT:

CHECKSUM_CHECK_PLAYER_LOOP_CONTINUE:
addi r12, r12, 1
lbz r3, RXB_OPNT_COUNT(REG_REMOTE_RXB)
cmpw r12, r3
blt CHECKSUM_CHECK_PLAYER_LOOP_START

################################################################################
# Check if we should capture state. We need to do this after the rollback
# logic because triggering RenewInputs might cause a new savestate request
# even during a rollback
################################################################################
CAPTURE_CHECK:
# logf LOG_LEVEL_INFO, "[SEL] [%d] Considering saving state. Predicting: %d, Finalized: %d", "mr r5, REG_FRAME_INDEX", "lbz r6, ODB_SAVESTATE_IS_PREDICTING(REG_ODB_ADDRESS)", "lwz r7, ODB_STABLE_FINALIZED_FRAME(REG_ODB_ADDRESS)"

# First check if a savestate is required (the frame has predicted inputs)
lbz r3, ODB_SAVESTATE_IS_PREDICTING(REG_ODB_ADDRESS)
cmpwi r3, 0
beq CAPTURE_END

# Next check if this frame is greater than or equal to the frame we need
lwz r3, ODB_STABLE_FINALIZED_FRAME(REG_ODB_ADDRESS)
cmpw REG_FRAME_INDEX, r3
ble CAPTURE_END

# logf LOG_LEVEL_WARN, "[SEL] [%d] Saving state", "mr r5, REG_FRAME_INDEX"

# Do savestate
lwz r3, ODB_SAVESTATE_SSRB_ADDR(REG_ODB_ADDRESS)
mr r4, REG_FRAME_INDEX
lwz r5, ODB_SAVESTATE_SSCB_ADDR(REG_ODB_ADDRESS)
branchl r12, FN_CaptureSavestate
CAPTURE_END:

################################################################################
# Check if game has ended. We give a buffer of ROLLBACK_MAX_FRAME_COUNT
################################################################################
lbz r3, ODB_IS_GAME_OVER(REG_ODB_ADDRESS)
cmpwi r3, 1
beq CHECK_GAME_END_END

# Load game end ID, if non-zero, game ended
load r3, 0x8046b6a0
lbz r3, 0x8(r3)
cmpwi r3, 0
bne SKIP_GAME_END_FRAME_RESET

# Game end is 0, that means the game is not over, reset the end frame
li r3, 0
stw r3, ODB_GAME_END_FRAME(REG_ODB_ADDRESS)
b CHECK_GAME_END_END
SKIP_GAME_END_FRAME_RESET:

lwz r3, ODB_GAME_END_FRAME(REG_ODB_ADDRESS)
cmpwi r3, 0
bne SKIP_SET_GAME_END_FRAME
stw REG_FRAME_INDEX, ODB_GAME_END_FRAME(REG_ODB_ADDRESS)
SKIP_SET_GAME_END_FRAME:

lwz r3, ODB_GAME_END_FRAME(REG_ODB_ADDRESS)
sub r3, REG_FRAME_INDEX, r3
cmpwi r3, ROLLBACK_MAX_FRAME_COUNT
ble CHECK_GAME_END_END # Not sure if this could be blt instead... ble is safer

HANDLE_GAME_CONFIRMED_OVER:
# We have been in game end for long enough to go past rollback limit, this is
# a legitimate game completion
li r3, 1
stb r3, ODB_IS_GAME_OVER(REG_ODB_ADDRESS)

# Call game end handler function
lwz r3, ODB_FN_HANDLE_GAME_OVER_ADDR(REG_ODB_ADDRESS)
mtctr r3
bctrl

CHECK_GAME_END_END:

################################################################################
# Restore and exit
################################################################################
RESTORE_AND_EXIT:
mr r3, REG_INTERRUPT_IDX
branchl r12, OSRestoreInterrupts

EXIT:
restore
