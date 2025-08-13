################################################################################
# Address: 0x802f3988
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"
.include "KZ/DATA.s"


CODE_START:
    backup
    mr r20, r3
    computeBranchTargetAddress r3, 0x802f74b4
    addi r3, r3, 24
    stw r20, 12(r3)

    computeBranchTargetAddress r3, 0x801c0f48
    addi r3, r3, 24
    stw r20, 12(r3)

EXIT:
    mr r3, r20
    restore
    lbz	r4, -0x3E55 (r13)
