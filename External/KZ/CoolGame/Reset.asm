################################################################################
# Address: 0x801c0fa8
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"
.include "KZ/DATA.s"


CODE_START:
    backup
    computeBranchTargetAddress r3, 0x802f74b4
    addi r3, r3, 24

    li  r4, 0
    sth r4, 0(r3)
    sth r4, 0x2(r3)
    li  r4, 100
    sth r4, 0x4(r3)
    li  r4, 480
    sth r4, 0x6(r3)
    li  r4, 380
    sth r4, 0x8(r3)
    li  r4, 150
    sth r4, 0xA(r3)

    computeBranchTargetAddress r3, 0x801c0f48
    addi r3, r3, 24

    li r0, 0
    sth r0, 0(r3)
    li  r0, 100
    sth r0, 0x2(r3)
    li r0, 0
    sth r0, 0x4(r3)
    li r0, 380
    sth r0, 0x6(r3)
    li r0, 480
    sth r0, 0x8(r3)
    li r0, 30
    sth r0, 0xA(r3)

    load r3, 0x80472d28
    li r4, 288
    branchl r12, 0x8000c160

    branchl r12, 0x801ba2ec


EXIT:
    restore
    lwz	r0, 0x000C (sp)
