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

SIS_KBINC: # Armour Pierce
blrl
.long 0x0E00E100
.long 0xCA101618
.long 0x200A2035
.long 0x20302032
.long 0x20382035
.long 0x1A201920
.long 0x2C202820
.long 0x35202620
.long 0x2803030C
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

SIS_KBDEC: # Knights Armour
blrl
.long 0x0E00E100
.long 0xCA101618
.long 0x20142031
.long 0x202C202A
.long 0x202B2037
.long 0x20361A20
.long 0x0A203520
.long 0x30203220
.long 0x38203503
.long 0x030CAAAA
.long 0xAA101620
.long 0x0D202820
.long 0x26203520
.long 0x28202420
.long 0x3620281A
.long 0x202B2032
.long 0x203A1A20
.long 0x29202420
.long 0x351A203C
.long 0x20322038
.long 0x1A202420
.long 0x3520281A
.long 0x202F2024
.long 0x20382031
.long 0x2026202B
.long 0x20282027
.long 0x20E7190F
.long 0

SIS_CRIT:
blrl
.long 0x0E00E100
.long 0xCA101618
.long 0x200C2035
.long 0x202C2037
.long 0x202C2026
.long 0x2024202F
.long 0x1A201120
.long 0x2C203720
.long 0x3603030C
.long 0xAAAAAA10
.long 0x16200A1A
.long 0x2026202B
.long 0x20242031
.long 0x20262028
.long 0x1A202720
.long 0x321A2027
.long 0x20282024
.long 0x202F1A20
.long 0x26203520
.long 0x2C203720
.long 0x2C202620
.long 0x24202F1A
.long 0x20272024
.long 0x20302024
.long 0x202A2028
.long 0x20E7190F
.long 0

SIS_SHIELDHP:
blrl
.long 0x0E00E100
.long 0xCA101618
.long 0x200D2038
.long 0x20352024
.long 0x2025202F
.long 0x20281A20
.long 0x1C202B20
.long 0x2C202820
.long 0x2F202703
.long 0x030CAAAA
.long 0xAA101620
.long 0x12203120
.long 0x26203520
.long 0x28202420
.long 0x36202820
.long 0