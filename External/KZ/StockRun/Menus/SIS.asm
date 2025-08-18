################################################################################
# Address: 0x804a3048
################################################################################

################################################################################
# we can access the right SIS by computing the branch target address
# then add sis idx * 4, then bctrl to it
################################################################################

b SIS_0
b SIS_1

SIS_0:
blrl
.long 0x05000A0E
.long 0x00E100CA
.long 0x10161820
.long 0x0A203520
.long 0x30203220
.long 0x3820351A
.long 0x2019202C
.long 0x20282035
.long 0x20262028
.long 0x0310201D
.long 0x20282036
.long 0x2037190F
.long 0x00000000

SIS_1:
blrl
.long -1
.long -1
.long -1
.long -1
.long -1
.long -1
.long -1
.long -1
.long -1
.long -1
.long -1
.long -1
.long -1