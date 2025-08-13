################################################################################
# Address: 0x8024e54c # Menu_SetupEventMenu
# Note: This will run everytime we open the event menu, we could probably place
# this somewhere better because we only need to run this once
################################################################################

.include "Common/Common.s"
.include "./Scene.s"

.set REG_DATA, 20
.set REG_CUR_DATA, 21

  # original code line
  addi	r30, r4, 2296

  b CODE_START

MINOR_ARRAY:
  blrl
  CreateMinorDataArray


CODE_START:
  backup

  # overwrite original array
  load r4, 0x803db010 # minor data array pointer
  bl MINOR_ARRAY
  mflr REG_DATA
  stw REG_DATA, 0(r4)

  # replace the results exit func
  # probably a better way to do this statically? idk
  li r3, MINOR_RESULTS
  mulli r3, r3, SZ_MINORDATA
  add REG_CUR_DATA, REG_DATA, r3

  # our exit function
  bl FN_ResultsExit
  mflr r3
  stw r3, MINORDATA_DECIDE(REG_CUR_DATA)

  # replace enter func
  bl FN_ResultsEnter
  mflr r3
  stw r3, MINORDATA_PREP(REG_CUR_DATA)

  b EXIT

################################################################################

FN_ResultsEnter:
  blrl

  backup
  # branchl r12, 0x801b16a8 # original results enter
  bl FN_CopyMatchData

  # go back to event screen
  li r3, MAJOR_EVENT
  branchl r12, Scene_SetNextMajor
  branchl r12, Scene_ExitMajor

  restore
  blr

######

FN_ResultsExit:
  blrl

  backup
  branchl r12, 0x801b16c8 # original results exit
  
  # go back to event screen
  li r3, MAJOR_EVENT
  branchl r12, Scene_SetNextMajor
  branchl r12, Scene_ExitMajor

  restore
  blr

#####
# this is a direct copy from the original code, except we replace the match data (r3) with the event match data
# we could replace the exit data pointer in the minor array to the one in the original code, but we would have to make sure
# all of the other references to that data are replaced as well
FN_CopyMatchData:
  backup

  branchl r12, 0x801A427C
  mr	r31, r3
  branchl r12, 0x80177724
  li	r0, 1103
  mtctr	r0

  # lis	r3, 0x8048
  # subi	r3, r3, 25192
  load r3, 0x804979d8 # event match data

  addi	r5, r31, 0
  addi	r4, r3, 4

  COPY_LOOP:
    lwzu	r3, 0x0008 (r4)
    lwz	r0, 0x0004 (r4)
    stwu	r3, 0x0008 (r5)
    stw	r0, 0x0004 (r5)
    bdnz+	COPY_LOOP

  restore
  blr	


################################################################################


EXIT:
  restore
  