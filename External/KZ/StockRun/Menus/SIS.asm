################################################################################
# Address: 0x804a3048
################################################################################

################################################################################
# we can access the right SIS by computing the branch target address
# then add sis idx * 4, then bctrl to it
################################################################################

b SIS_KBINC
b SIS_KBDEC
b SIS_CRIT
b SIS_SHIELDHP
b SIS_JUMPHEIGHT
b SIS_SHIELDDMG

SIS_KBINC: # Armour Pierce
blrl
.long 0x0E001400
.long 0x14101618
.long 0x03200A20
.long 0x35203020
.long 0x32203820
.long 0x351A2019
.long 0x202C2028
.long 0x20352026
.long 0x20280303
.long 0x0CAAAAAA
.long 0x10162015
.long 0x20242038
.long 0x20312026
.long 0x202B1A20
.long 0x3C203220
.long 0x3820351A
.long 0x20322033
.long 0x20332032
.long 0x20312028
.long 0x20312037
.long 0x1A202920
.long 0x38203520
.long 0x37202B20
.long 0x28203520
.long 0xE7190F00
.long 0

SIS_KBDEC: # Knights Armour
blrl
.long 0x0E001400
.long 0x14101618
.long 0x03201420
.long 0x31202C20
.long 0x2A202B20
.long 0x3720361A
.long 0x200A2035
.long 0x20302032
.long 0x20382035
.long 0x03030CAA
.long 0xAAAA1016
.long 0x200D2028
.long 0x20262035
.long 0x20282024
.long 0x20362028
.long 0x1A202B20
.long 0x32203A1A
.long 0x20292024
.long 0x20351A20
.long 0x3C203220
.long 0x381A2024
.long 0x20352028
.long 0x1A202F20
.long 0x24203820
.long 0x31202620
.long 0x2B202820
.long 0x2720E719
.long 0x0F000000
.long 0

SIS_CRIT:
blrl
.long 0x0E001400
.long 0x14101618
.long 0x03200C20
.long 0x35202C20
.long 0x37202C20
.long 0x26202420
.long 0x2F1A2011
.long 0x202C2037
.long 0x20360303
.long 0x0CAAAAAA
.long 0x1016200A
.long 0x1A202620
.long 0x2B202420
.long 0x31202620
.long 0x281A2027
.long 0x20321A20
.long 0x27202820
.long 0x24202F1A
.long 0x20262035
.long 0x202C2037
.long 0x202C2026
.long 0x2024202F
.long 0x1A202720
.long 0x24203020
.long 0x24202A20
.long 0x2820E719
.long 0x0F000000
.long 0

SIS_SHIELDHP:
blrl
.long 0x0E001400
.long 0x14101618
.long 0x03200D20
.long 0x38203520
.long 0x24202520
.long 0x2F20281A
.long 0x201C202B
.long 0x202C2028
.long 0x202F2027
.long 0x03030CAA
.long 0xAAAA1016
.long 0x20122031
.long 0x20262035
.long 0x20282024
.long 0x20362028
.long 0x20271A20
.long 0x1C202B20
.long 0x2C202820
.long 0x2F20271A
.long 0x20112019
.long 0x20E7190F
.long 0

SIS_JUMPHEIGHT:
blrl
.long 0x0E001400
.long 0x14101618
.long 0x03201620
.long 0x32203220
.long 0x311A201C
.long 0x202B2032
.long 0x20282036
.long 0x03030CAA
.long 0xAAAA1016
.long 0x20122031
.long 0x20262035
.long 0x20282024
.long 0x20362028
.long 0x20271A20
.long 0x2D203820
.long 0x3020331A
.long 0x202B2028
.long 0x202C202A
.long 0x202B2037
.long 0x20E7190F
.long 0

SIS_SHIELDDMG:
blrl
.long 0x0E001400
.long 0x14101618
.long 0x03201C20
.long 0x2B202C20
.long 0x28202F20
.long 0x271A201C
.long 0x20302024
.long 0x2036202B
.long 0x20282035
.long 0x03030CAA
.long 0xAAAA1016
.long 0x200D2028
.long 0x2024202F
.long 0x1A202820
.long 0x3B203720
.long 0x3520241A
.long 0x2036202B
.long 0x202C2028
.long 0x202F2027
.long 0x1A202720
.long 0x24203020
.long 0x24202A20
.long 0x2820E719
.long 0x0F000000
.long 0
