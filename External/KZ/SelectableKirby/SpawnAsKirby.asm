################################################################################
# Address: 0x800692dc # Player_Create
################################################################################

.include "Common/Common.s"
.include "KZ/PLAYER.s"

.set CSSIcons, 0x803f0b24

.set SZ_ICON, 0x1C
.set OFST_ICONCHAR, 1

.set CharacterKindToId, 0x800325c8

b CODE_START

DATA_BLRL:
blrl
.set KIRBY_TYPE, 0
.byte 0xD
.byte 0xD
.byte 0xD
.byte 0xD

.set REG_FTGOBJ, 31
.set REG_FIGHTER, 30
.set REG_SLOT, 29
.set REG_DATA, 28
.set REG_TYPE, 27

CODE_START:
  backup

  bl DATA_BLRL
  mflr REG_DATA

  lbz REG_SLOT, FT_SLOT(REG_FIGHTER)

  # mr r3, REG_SLOT
  # branchl r12, PlayerBlock_SetFlag_KirbyLoadCopy

  addi r4, REG_DATA, KIRBY_TYPE
  lbzx r4, r4, REG_SLOT
  cmpwi r4, 0xD
  beq EXIT

  load r5, CSSIcons
  mulli r0, r4, SZ_ICON
  add r5, r0, r5
  lbz REG_TYPE, OFST_ICONCHAR(r5)

  mr r3, REG_TYPE
  li r4, 0
  branchl r12, CharacterKindToId
  mr REG_TYPE, r3

  mr r3, REG_SLOT
  mr r4, REG_TYPE
  branchl r12, PlayerBlock_StoreCopiedCharacter

  mr r3, REG_TYPE
  li r4, 0
  branchl r12, Kirby_LoadHat


EXIT:
  restore
  mr r3, REG_FTGOBJ

