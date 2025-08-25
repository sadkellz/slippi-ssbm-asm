################################################################################
# Address: 0x804a3124
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"

.set REG_TEXT_STRUCT, 29

b CODE_START

DATA_BLRL:
blrl
.set TEXT_ENTRY_X, 0
.set TEXT_ENTRY_Y, TEXT_ENTRY_X + 4
.set TEXT_ENTRY_SIZE, TEXT_ENTRY_Y + 4
.set TEXT_ENTRY_COLOR, TEXT_ENTRY_SIZE + 4
.set TEXT_ENTRY_STRING, TEXT_ENTRY_COLOR + 4

.set TITLE_TEXT_ENTRY, 0
.float 16.5 # x-pos
.float -8 # y-pos
.float 0.06 # text size
.long 0xFFFFFFFF # text color
.string "Stock Run v0.1a2" # text
.set TITLE_SIZE, 16 + 17

.set COPYRIGHT_TEXT_ENTRY, TITLE_TEXT_ENTRY + TITLE_SIZE
.float 26 # x-pos
.float -6 # y-pos
.float 0.035 # text size
.long 0x00FF0020 # text color
.short 0x8169 # (
.short 0x8283 # c
.short 0x816A # )
.string " KELLZ 2025" # text
.set COPYWRITE_TEXT_ENTRY_SIZE, 16 + 19
.align 2

.set WARNING_TEXT_ENTRY, COPYRIGHT_TEXT_ENTRY + COPYWRITE_TEXT_ENTRY_SIZE
.float -25 # x-pos
.float -4 # y-pos
.float 0.05 # text size
.long 0xFF9C00FF # text color
.string "Warning: Slippi Recording is enabled." # text
.set TITLE_SIZE, 16 + 38
.align 2


CODE_START:
    backup

    # Create Text Struct
    li r3, 0
    li r4, 0
    branchl r12, Text_CreateStruct
    mr REG_TEXT_STRUCT, r3

    # Set text kerning to close
    li r4, 0x1
    stb r4, 0x49(REG_TEXT_STRUCT)
    # Set text to align left
    li r4, 0x0
    stb r4, 0x4A(REG_TEXT_STRUCT)

    mr r3, REG_TEXT_STRUCT
    li r4, TITLE_TEXT_ENTRY
    bl FN_CREATE_HUD_SUBTEXT

    mr r3, REG_TEXT_STRUCT
    li r4, COPYRIGHT_TEXT_ENTRY
    bl FN_CREATE_HUD_SUBTEXT

    load r0, 0x3c608017 # Slippi Recording is disabled
    loadwz r3, 0x8016e74c
    cmpw r3, r0
    beq EXIT

    mr r3, REG_TEXT_STRUCT
    li r4, WARNING_TEXT_ENTRY
    bl FN_CREATE_HUD_SUBTEXT


EXIT:
    restore
    blr

################################################################################
# Creates a subtext
# ------------------------------------------------------------------------------
# Inputs: [r3] TextStruct, [r4] DOFST for Text Entry
# ------------------------------------------------------------------------------
# Output: [r3] SubtextId
################################################################################
.set REG_TEXT_CONFIG_ADDR, 31
.set REG_SUBTEXT_ID, 30
.set REG_TEXT_STRUCT, 29

FN_CREATE_HUD_SUBTEXT:
backup

mr REG_TEXT_STRUCT, r3

bl DATA_BLRL
mflr REG_TEXT_CONFIG_ADDR
add REG_TEXT_CONFIG_ADDR, REG_TEXT_CONFIG_ADDR, r4

# Initialize header
lfs f1, TEXT_ENTRY_X(REG_TEXT_CONFIG_ADDR)
lfs f2, TEXT_ENTRY_Y(REG_TEXT_CONFIG_ADDR)
mr r3, REG_TEXT_STRUCT
addi r4, REG_TEXT_CONFIG_ADDR, TEXT_ENTRY_STRING
branchl r12, Text_InitializeSubtext
mr REG_SUBTEXT_ID, r3

# Set header text size
mr r3, REG_TEXT_STRUCT
mr r4, REG_SUBTEXT_ID
lfs f1, TEXT_ENTRY_SIZE(REG_TEXT_CONFIG_ADDR)
lfs f2, TEXT_ENTRY_SIZE(REG_TEXT_CONFIG_ADDR)
branchl r12, Text_UpdateSubtextSize

# Set text color
mr r3, REG_TEXT_STRUCT
mr r4, REG_SUBTEXT_ID
addi r5, REG_TEXT_CONFIG_ADDR, TEXT_ENTRY_COLOR
branchl r12, Text_ChangeTextColor

mr r3, REG_SUBTEXT_ID

restore
blr