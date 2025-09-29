################################################################################
# Address: 0x8016e8c8
################################################################################

.include "Common/Common.s"

b CODE_START

DEBUG_STR_BLRL:
blrl
.string "match rules = %p\n"
.align 2

CODE_START:
  .set REG_DATA, 31
  backup

  bl DEBUG_STR_BLRL
  mflr r3

  branchl r12, 0x804a3120 # static func address

EXIT:
  restore
  lwz	r12, 0x0044(r31)
  