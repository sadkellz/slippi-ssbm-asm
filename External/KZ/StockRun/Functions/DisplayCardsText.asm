################################################################################
# Address: StockRun_DisplayCardText
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"
.include "External/KZ/StockRun/StockRun.s"
.include "External/KZ/KZ_COMMON.s"

b CODE_START

STATIC_MEMORY_TABLE_BLRL:
blrl
.long 0 # text ptr
.long 0 # string ptr

LOCAL_MEMORY_TABLE_BLRL:
blrl
# text config stuff
.set DOFST_TEXT_BASE_Z, 0
.float 0
.set DOFST_TEXT_BASE_CANVAS_SCALING, DOFST_TEXT_BASE_Z + 4
.float 0.1

# delay values
.set DOFST_TEXT_X_POS, DOFST_TEXT_BASE_CANVAS_SCALING + 4
.float -150
.set DOFST_TEXT_Y_POS, DOFST_TEXT_X_POS + 4
.float 207
.set DOFST_TEXT_SIZE, DOFST_TEXT_Y_POS + 4
.float 0.33

# strings
.set DOFST_TEXT_DELAYSTRING, DOFST_TEXT_SIZE + 4
.string "0x%08x -- 0x%08x"
.align 2

CODE_START:
.set REG_IGDB_ADDR, 31
.set REG_P1_CARDS, 30
.set REG_DATA_ADDR, 29
.set REG_TEXT_STRUCT, 28
.set REG_CANVAS, 27
.set REG_COBJ, 26
.set REG_GOBJ, 25
.set REG_P2_CARDS, 24
	backup

################################################################################
# Prepare canvas for displaying delay
################################################################################
# CObj stuff
.set  COBJ_GXPRI, 8
.set  TEXT_GXPRI, 80
.set  TEXT_GXLINK, 12

# Create canvas
li  r3,	2
li 	r4, 0
li  r5, 9
li  r6, 13
li  r7, 0
li  r8, TEXT_GXLINK
li  r9, TEXT_GXPRI
li  r10, COBJ_GXPRI
branchl r12, 0x803a611c
mr  REG_CANVAS, r3

################################################################################
# Prepare delay display
################################################################################
bl LOCAL_MEMORY_TABLE_BLRL
mflr REG_DATA_ADDR

# Start prepping text struct
li r3, 2
mr  r4,	REG_CANVAS
branchl r12, Text_CreateStruct
mr REG_TEXT_STRUCT, r3

# Set text kerning to close
li r4, 0x1
stb r4, 0x49(REG_TEXT_STRUCT)
# Set text to align right
li r4, 0x2
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
addi r4, REG_DATA_ADDR, DOFST_TEXT_DELAYSTRING
mr r31, r4
li r5, 0
li r6, 0
branchl r12, Text_InitializeSubtext

# Set header text size
mr r3, REG_TEXT_STRUCT
li r4, 0
# Scale text X based on Aspect Ratio
lfs f1, DOFST_TEXT_SIZE(REG_DATA_ADDR)
lfs f2, DOFST_TEXT_SIZE(REG_DATA_ADDR)
branchl r12, Text_UpdateSubtextSize

bl STATIC_MEMORY_TABLE_BLRL
mflr REG_DATA_ADDR
stw REG_TEXT_STRUCT, 0(REG_DATA_ADDR)
stw r31, 4(REG_DATA_ADDR)

RESTORE_EXIT:
restore
EXIT:
blr