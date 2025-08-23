################################################################################
# Address: 0x802669d4
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"

stb	r0, -0x49AC(r13)

bp

getMinorMajor r3
cmpwi r3, SCENE_ONLINE_CSS
bne EXIT

# Check for direct mode
lbz r3, OFST_R13_ONLINE_MODE(r13)
cmpwi r3, ONLINE_MODE_DIRECT
bne 0

EXIT:
