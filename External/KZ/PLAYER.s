.ifndef HEADER_PLAYER_STRUCT

################################################################################
# Struct
################################################################################

.set FT_GOBJ, 0
.set FT_CID, FT_GOBJ + 4
.set FT_SPAWNCOUNT, FT_CID + 4
.set FT_SLOT, FT_SPAWNCOUNT + 4
.set FT_BONES, 0x5E8
.set FT_HIT_KB, 0x1850
.set FT_HURTBOXES, 0x11A0
.set FT_HURTBOXCOUNT, 0x119E
.set FT_DMG_RECEIVED, 0x1838
.set FT_ATTACKER, 0x18C4
.set FT_SHIELD_HP, 0x1998
.set FT_LIGHTSHIELD_HP, 0x199C
.set FT_CHAR_DATA, 0x10C
.set FT_STATS, 0x110

.set STATS_JUMPS, 0x58
.set STATS_JUMP_FH_MULT, 0x40
.set STATS_JUMP_SH_MULT, 0x4C
.set STATS_JUMP_DJ_MULT, 0x50

.set PB_FLAG1, 0xAC

.set HURTBOX_STATE, 0
.set HURTBOX_OFST1, HURTBOX_STATE + 4
.set HURTBOX_OFST2, HURTBOX_OFST1 + 4
.set HURTBOX_RADIUS, HURTBOX_OFST2 + 4
.set HURTBOX_BONE, HURTBOX_RADIUS + 4
.set HURTBOX_FLAGS, HURTBOX_BONE + 4
.set HURTBOX_POS1, HURTBOX_FLAGS + 4
.set HURTBOX_POS2, HURTBOX_POS1 + 12
.set HURTBOX_BONEID, HURTBOX_POS2 + 12
.set HURTBOX_FLINCH, HURTBOX_BONEID + 4
.set HURTBOX_GRABBABLE, HURTBOX_FLINCH + 4

.set BONES_JOBJ, 0
.set BONES_JOBJ2, BONES_JOBJ + 4
.set BONES_FLAGS1, BONES_JOBJ2 + 4

################################################################################
# Functions
################################################################################

.set PlayerBlock_GetGObj, 0x80034110 # (int slot)
.set PlayerBlock_GetStocks, 0x80033bd8 # (int slot)
.set PlayerBlock_GetSlotType, 0x8003241c # (int slot)
.set PlayerBlock_GetPortColor, 0x80036538 # (int slot)

.set PlayerBlock_SetSpawnTime, 0x80035fdc # (int slot, u8 time)
.set PlayerBlock_StoreCopiedCharacter, 0x80035df8 # (int slot,CharacterKind character)
.set PlayerBlock_SetFlag_KirbyLoadCopy, 0x800356d0 # (int slot)
.set PlayerBlock_PlayChant, 0x8003fda0 # (int slot)

.set Player_GetPosition, 0x80086644 # (HSD_GObjPlayer *gobj_player,Vec *vec)
.set Player_IsDead, 0x8008732c
.set Player_InitCharacterStats, 0x800d105c

.set Kirby_LoadHatPrefunc, 0x80169c54 # (CharacterKind character,byte costume_id)
.set Kirby_LoadHat, 0x80031da8 # (CharacterKind character,byte costume_id)

.set GetPlayerCount, 0x8016b558

.set Item_Apply_Metal, 0x800c8348
.set Item_Apply_Cloak, 0x800c88d4


################################################################################
# Constants
################################################################################

.set PLAYERBLOCK_0, 0x80453080
.set PLAYERBLOCK_1, 0x80453f10
.set PLAYERBLOCK_2, 0x80454da0
.set PLAYERBLOCK_3, 0x80455c30
.set PLAYERBLOCK_4, 0x80456ac0
.set PLAYERBLOCK_5, 0x80457950

.set SHIELD_COLORS, 0x804d650c

################################################################################
# Directives
################################################################################

.set SZ_BONE, 0x10
.set SZ_HURTBOX, 0x4C

.set P1, 0
.set P2, 1
.set P3, 2
.set P4, 3


.endif
.set HEADER_PLAYER_STRUCT, 1
