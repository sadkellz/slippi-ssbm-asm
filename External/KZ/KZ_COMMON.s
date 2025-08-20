.ifndef HEADER_KZCOMMON

################################################################################
# rtoc constants
################################################################################

.set RTOC_ZERO, -0x1568
.set RTOC_ONE, -0x1564
.set RTOC_HALF, -0x7bb0
.set RTOC_NEG_HALF, -0x7bac
.set RTOC_DEG2RAD, -0x7b80 # 0.017453292
.set RTOC_RAD2DEG, -0x76c4 # 57.29578
.set RTOC_TWO, -0x7a1c
.set RTOC_HUND, -0x35e8
.set RTOC_STICKTHRESH, -0x3c98
.set RTOC_TEN, -0x1e64
.set RTOC_NEG_1_1, -0x125c
.set RTOC_0_01, -0x7ebc
.set RTOC_0_015625, -0x7da8
.set RTOC_0_75, -0x7d5c
.set RTOC_60, -0x7854
.set RTOC_160, -0x5450
.set RTOC_190, -0x4f44
.set RTOC_300, -0x7ab4
.set RTOC_1_25, -0x4d70
.set RTOC_255, -0x7dd4

################################################################################
# Directives
################################################################################

.set TRUE, 1
.set FALSE, 0

.set R, 0
.set G, 1
.set B, 2
.set A, 3

.set X, 0
.set Y, 4
.set Z, 8
.set W, 12


################################################################################
# Macros
################################################################################
.macro load_scene_frame reg
  loadwz \reg, 0x80479d5c
.endm

.macro bklr
  mflr r0
  stw r0, 0x4(r1)
  stwu r1, -0x10(r1)  # Allocate 16 bytes (8 for backchain/LR + 8 free space)
.endm

.macro rslr
  lwz r0, 0x14(r1)    # Load LR from saved location
  mtlr r0
  addi r1, r1, 0x10   # Restore stack pointer
.endm

# this will branch to the out_label if either stick is outside the deadzone
# after this macro use a branch to skip the logic
.macro check_deadzones stick_x, stick_y, deadzone
  fabs f0, \stick_x
  fcmpo cr0, f0, \deadzone
  bge 1f
  fabs f0, \stick_y
  fcmpo cr0, f0, \deadzone
  bge 1f
  li r0, TRUE
  b 2f
  1: li r0, FALSE
  2:
.endm

.macro check_deadzone stick_z, deadzone
  fabs f0, \stick_z
  fcmpo cr0, f0, \deadzone
  bge 1f
  li r0, TRUE
  b 2f
  1: li r0, FALSE
  2:
.endm

.macro clamp_int value, min_val, max_val
  cmpw \value, \min_val
  bge 1f
  mr \value, \min_val
  b 2f
  1: cmpw \value, \max_val
  ble 2f
  mr \value, \max_val
  2:
.endm

.macro clamp_float value, min_val, max_val
  fcmpo cr0, \value, \min_val
  bge 1f
  fmr \value, \min_val
  b 2f
  1: fcmpo cr0, \value, \max_val
  ble 2f
  fmr \value, \max_val
  2:
.endm

################################################################################
# Constants
################################################################################

.set stc_matchcam, 0x80452c68



.endif
.set HEADER_KZCOMMON, 1
