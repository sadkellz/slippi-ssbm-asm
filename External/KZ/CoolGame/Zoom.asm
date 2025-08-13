################################################################################
# Address: 0x8016c814
################################################################################

.include "Common/Common.s"

.set ZoomCamera, 0x8002f7ac

b CODE_START

CODE_START:
  backup

  li r3, 1
  branchl r12, ZoomCamera

EXIT:
  restore
  lwz	r12, 0x2518 (r31)
