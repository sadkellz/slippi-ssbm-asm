.ifndef HEADER_SCENE
################################################################################
# Functions
################################################################################
.set Scene_SetNextMajor, 0x801a42e8
.set Scene_ExitMajor, 0x801a42d4
.set Scene_SetNextMinor, 0x801a42a0
.set Scene_SetExitMinor, 0x801a4b60

################################################################################
# Structs
################################################################################
.set MINORDATA, 0
.set MINORDATA_ID, MINORDATA
.set MINORDATA_HEAPKIND, MINORDATA_ID + 1
.set MINORDATA_PREP, MINORDATA_HEAPKIND + 3
.set MINORDATA_DECIDE, MINORDATA_PREP + 4
.set MINORDATA_MINORKIND, MINORDATA_DECIDE + 4
.set MINORDATA_LOADDATA, MINORDATA_MINORKIND + 4
.set MINORDATA_UNLOADDATA, MINORDATA_LOADDATA + 4

################################################################################
# Constants
################################################################################
.set SZ_MINORDATA, 0x18
.set SZ_RESULTDATA, 1103

.set MAJOR_EVENT, 1

.set MINOR_CSS, 0
.set MINOR_MATCH, 1
.set MINOR_RESULTS, 2

################################################################################
# Event Match Minor Data Array
################################################################################

.macro CreateMinorDataArray
# CSS
  .byte 0 # id
  .byte 3 # heap kind
  .align 2

  .long 0x801baa60 # prep/enter function
  .long 0x801baad0 # decide/exit function

  .byte 8 # minor kind/id
  .align 2

  .long 0x80497758 # prep/enter static data
  .long 0x80497758 # decide/exit static data


# In-Game/VS/Match
  .byte 1 # id
  .byte 3 # heap kind
  .align 2
  .long 0x801bad70 # prep/enter function
  .long 0x801bb758 # decide/exit function
  .byte 2 # minor kind/id
  .align 2
  .long 0x804978a0 # prep/enter static data
  .long 0x804979d8 # decide/exit static data


# Results - Not in the original array
  .byte 2 # id
  .byte 3 # heap kind
  .align 2
  .long 0x801b16a8 # prep/enter function
  .long 0x801b16c8 # decide/exit function
  .byte 5 # minor kind/id
  .align 2
  .long 0x8047c020 # prep/enter static data
  .long 0 # decide/exit static data

# Terminator
  .byte 0xFF
  .byte 0
  .align 2

  .long 0
  .long 0
  .byte 0
  .align 2

  .long 0
  .long 0

.endm

.endif
.set HEADER_SCENE, 1
