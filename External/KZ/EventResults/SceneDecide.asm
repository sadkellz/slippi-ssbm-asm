################################################################################
# Address: 0x801bba3c
################################################################################

.include "Common/Common.s"
.include "./Scene.s"

b CODE_START

CODE_START:
  backup

  # instead of going back to the event screen, go to the new scene we've added
  li r3, MINOR_RESULTS
  branchl r12, Scene_SetNextMinor

EXIT:
  restore
