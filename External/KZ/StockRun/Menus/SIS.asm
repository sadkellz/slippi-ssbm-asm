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
b SIS_EXTRAJUMP
b SIS_METAL
b SIS_CLOAK
b SIS_RANDOMDMG
b SIS_SCREWATK
b SIS_QUICKCHARGE
b SIS_DJARMOUR
b SIS_EXTGRAB
b SIS_GRACE

SIS_KBINC: # Pack-A-Punch
blrl
.long 0x0E001400
.long 0x14101618
.long 0x03201920
.long 0x24202620
.long 0x2E20FC20
.long 0x0A20FC20
.long 0x19203820
.long 0x31202620
.long 0x2B03030C
.long 0xAAAAAA10
.long 0x16201520
.long 0x24203820
.long 0x31202620
.long 0x2B1A203C
.long 0x20322038
.long 0x20351A20
.long 0x32203320
.long 0x33203220
.long 0x31202820
.long 0x3120371A
.long 0x20292038
.long 0x20352037
.long 0x202B2028
.long 0x203520E7
.long 0x190F0000
.long 0

SIS_KBDEC: # Flak Jacket
blrl
.long 0x0E001400
.long 0x14101618
.long 0x03200F20
.long 0x2F202420
.long 0x2E1A2013
.long 0x20242026
.long 0x202E2028
.long 0x20370303
.long 0x0CAAAAAA
.long 0x1016200D
.long 0x20282026
.long 0x20352028
.long 0x20242036
.long 0x20281A20
.long 0x2B203220
.long 0x3A1A2029
.long 0x20242035
.long 0x1A203C20
.long 0x3220381A
.long 0x20242035
.long 0x20281A20
.long 0x2F202420
.long 0x38203120
.long 0x26202B20
.long 0x28202720
.long 0xE7190F00
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

SIS_SHIELDHP: # Durable Shield
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
.long 0x36202B20
.long 0x2C202820
.long 0x2F20271A
.long 0x202B2028
.long 0x2024202F
.long 0x2037202B
.long 0x20E7190F
.long 0

SIS_JUMPHEIGHT: # Moon Shoes
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

SIS_SHIELDDMG: # Shield Smasher
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
.long 0x20122031
.long 0x20262035
.long 0x20282024
.long 0x20362028
.long 0x20271A20
.long 0x36202B20
.long 0x2C202820
.long 0x2F20271A
.long 0x20272024
.long 0x20302024
.long 0x202A2028
.long 0x20E7190F
.long 0

SIS_EXTRAJUMP: # Gunkboosters
blrl
.long 0x0E001400
.long 0x14101618
.long 0x03201020
.long 0x38203120
.long 0x2E202520
.long 0x32203220
.long 0x36203720
.long 0x28203520
.long 0x3603030C
.long 0xAAAAAA10
.long 0x16200A20
.long 0x311A2028
.long 0x203B2037
.long 0x20352024
.long 0x1A202D20
.long 0x38203020
.long 0x3320E719
.long 0x0F000000
.long 0

SIS_METAL: # Heavy Metal
blrl
.long 0x0E001400
.long 0x14101618
.long 0x03201120
.long 0x28202420
.long 0x39203C1A
.long 0x20162028
.long 0x20372024
.long 0x202F0303
.long 0x0CAAAAAA
.long 0x10162016
.long 0x20242037
.long 0x20282035
.long 0x202C2024
.long 0x202F202C
.long 0x203D2028
.long 0x1A202C20
.long 0x31203720
.long 0x321A2030
.long 0x20282037
.long 0x2024202F
.long 0x20E7190F
.long 0

SIS_CLOAK: # Active Camo
blrl
.long 0x0E001400
.long 0x14101618
.long 0x03200A20
.long 0x26203720
.long 0x2C203920
.long 0x281A200C
.long 0x20242030
.long 0x20320303
.long 0x0CAAAAAA
.long 0x1016201D
.long 0x20382035
.long 0x20311A20
.long 0x2C203120
.long 0x39202C20
.long 0x36202C20
.long 0x25202F20
.long 0x2820E719
.long 0x0F000000
.long 0

SIS_RANDOMDMG: # Perfect Shield
blrl
.long 0x0E001400
.long 0x14101618
.long 0x03201920
.long 0x28203520
.long 0x29202820
.long 0x2620371A
.long 0x201C202B
.long 0x202C2028
.long 0x202F2027
.long 0x03030CAA
.long 0xAAAA1016
.long 0x20192032
.long 0x203A2028
.long 0x20352036
.long 0x202B202C
.long 0x2028202F
.long 0x20271A20
.long 0x28203920
.long 0x28203520
.long 0x3C203720
.long 0x2B202C20
.long 0x31202A20
.long 0xE7190F00
.long 0

SIS_SCREWATK: # Screwed
blrl
.long 0x0E001400
.long 0x14101618
.long 0x03201C20
.long 0x26203520
.long 0x28203A20
.long 0x28202703
.long 0x030CAAAA
.long 0xAA101620
.long 0x20202B20
.long 0x2820311A
.long 0x202D2038
.long 0x20302033
.long 0x202C2031
.long 0x202A20E6
.long 0x1A203C20
.long 0x3220381A
.long 0x20332028
.long 0x20352029
.long 0x20322035
.long 0x20301A20
.long 0x241A2036
.long 0x20262035
.long 0x2028203A
.long 0x1A202420
.long 0x37203720
.long 0x24202620
.long 0x2E20E719
.long 0x0F000000
.long 0

SIS_QUICKCHARGE: # Quick Charge
blrl
.long 0x0E001400
.long 0x14101618
.long 0x03201A20
.long 0x38202C20
.long 0x26202E1A
.long 0x200C202B
.long 0x20242035
.long 0x202A2028
.long 0x03030CAA
.long 0xAAAA1016
.long 0x200C202B
.long 0x20242035
.long 0x202A2028
.long 0x20271A20
.long 0x24203720
.long 0x37202420
.long 0x26202E20
.long 0x361A202C
.long 0x20312036
.long 0x20372024
.long 0x20312037
.long 0x202F203C
.long 0x1A203520
.long 0x28202420
.long 0x26202B1A
.long 0x20292038
.long 0x202F202F
.long 0x1A203320
.long 0x32203A20
.long 0x28203520
.long 0xE7190F00
.long 0

SIS_DJARMOUR: # Yoshi's Secret
blrl
.long 0x0E001400
.long 0x14101618
.long 0x03202220
.long 0x32203620
.long 0x2B202C20
.long 0xF320361A
.long 0x201C2028
.long 0x20262035
.long 0x20282037
.long 0x03030CAA
.long 0xAAAA1016
.long 0x200D2032
.long 0x20382025
.long 0x202F2028
.long 0x1A202D20
.long 0x38203020
.long 0x331A2024
.long 0x20352030
.long 0x20322038
.long 0x203520E7
.long 0x190F0000
.long 0

SIS_EXTGRAB: # Increased Ape Index
blrl
.long 0x0E001400
.long 0x14101618
.long 0x03201220
.long 0x31202620
.long 0x35202820
.long 0x24203620
.long 0x2820271A
.long 0x200A2033
.long 0x20281A20
.long 0x12203120
.long 0x27202820
.long 0x3B03030C
.long 0xAAAAAA10
.long 0x16200E20
.long 0x3B203720
.long 0x28203120
.long 0x27202820
.long 0x271A202A
.long 0x20352024
.long 0x20251A20
.long 0x35202420
.long 0x31202A20
.long 0x2820E719
.long 0x0F000000
.long 0

SIS_GRACE: # Grace
blrl
.long 0x0E001400
.long 0x14101618
.long 0x030CFAD7
.long 0x3C201020
.long 0x35202420
.long 0x26202803
.long 0x030CFFFF
.long 0xFF101620
.long 0x22203220
.long 0x3820351A
.long 0x20242026
.long 0x2037202C
.long 0x20322031
.long 0x20361A20
.long 0x25202820
.long 0x26203220
.long 0x3020281A
.long 0x20282031
.long 0x202F202C
.long 0x202A202B
.long 0x20372028
.long 0x20312028
.long 0x202720E7
.long 0x190F0000
.long 0
