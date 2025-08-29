.ifndef HEADER_PLAYER_STRUCT

################################################################################
# Struct
################################################################################

.set FT_GOBJ, 0
.set FT_CID, FT_GOBJ + 4
.set FT_SPAWNCOUNT, FT_CID + 4
.set FT_SLOT, FT_SPAWNCOUNT + 4
.set FT_ACTION_STATE, 0x10
.set FT_FACING_DIR, 0x2C
.set FT_BONES, 0x5E8
.set FT_HIT_KB, 0x1850
.set FT_HURTBOXES, 0x11A0
.set FT_HURTBOXCOUNT, 0x119E
.set FT_DMG_RECEIVED, 0x1838
.set FT_KB_SUBACTION_RESIST, 0x18B4
.set FT_ATTACKER, 0x18C4
.set FT_SHIELD_HP, 0x1998
.set FT_LIGHTSHIELD_HP, 0x199C
.set FT_CHAR_DATA, 0x10C
.set FT_HITBOXES, 0x914
.set FT_STATS, 0x110
.set FT_HIT_DATA, 0x1844
.set FT_FLAGS4, 0x221B
.set FT_CHARGE_AMT, 0x2230

.set BLOCK_OFFENSE_RATIO, 0x54
.set BLOCK_DEFENSE_RATIO, 0x58

.set STATS_JUMPS, 0x58
.set STATS_JUMP_FH_MULT, 0x40
.set STATS_JUMP_SH_MULT, 0x4C
.set STATS_JUMP_DJ_MULT, 0x50
.set STATS_LAG_LAND, 0xE4
.set STATS_LAG_NAIR, 0xE8
.set STATS_LAG_FAIR, 0xEC
.set STATS_LAG_BAIR, 0xF0
.set STATS_LAG_UAIR, 0xF4
.set STATS_LAG_DAIR, 0xF8

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

.set HITBOX_STATE, 0
.set HITBOX_HITGROUP, HITBOX_STATE + 4
.set HITBOX_DMG, HITBOX_HITGROUP + 4
.set HITBOX_STALED_DMG, HITBOX_DMG + 4 
.set HITBOX_OFFSET, HITBOX_STALED_DMG + 4
.set HITBOX_RADIUS, HITBOX_OFFSET + 12
.set HITBOX_KBANGLE, HITBOX_RADIUS + 4
.set HITBOX_KBG, HITBOX_KBANGLE + 4
.set HITBOX_FKV, HITBOX_KBG + 4
.set HITBOX_BKB, HITBOX_FKV + 4
.set HITBOX_ELEMENT, HITBOX_BKB + 4
.set HITBOX_SHIELD_DMG, HITBOX_ELEMENT + 4
.set HITBOX_SFX, HITBOX_SHIELD_DMG + 4
.set HITBOX_SFX_TYPE, HITBOX_SFX + 4
.set HITBOX_FLAGS1, HITBOX_SFX_TYPE + 4
.set HITBOX_FLAGS2, HITBOX_FLAGS1 + 1
.set HITBOX_FLAGS3, HITBOX_FLAGS2 + 1
.set HITBOX_FLAGS4, HITBOX_FLAGS3 + 1
.set HITBOX_HIT_OBJ_COUNT, HITBOX_FLAGS4 + 1
.set HITBOX_PHANT_HIT_OBJ_COUNT, HITBOX_HIT_OBJ_COUNT + 1
.set HITBOX_x46, HITBOX_PHANT_HIT_OBJ_COUNT + 1
.set HITBOX_x47, HITBOX_x46 + 1
.set HITBOX_BONE, HITBOX_x47 + 1
.set HITBOX_POS, HITBOX_BONE + 4
.set HITBOX_LAST_POS, HITBOX_POS + 12
.set HITBOX_LAST_CONTACT, HITBOX_LAST_POS + 12
.set HITBOX_LAST_CONTACT_DEPTH, HITBOX_LAST_CONTACT + 12
.set HITBOX_HIT_OBJS, HITBOX_LAST_CONTACT_DEPTH + 4
.set HITBOX_PHANT_HIT_OBJS, HITBOX_HIT_OBJS + 96

.set HITDATA_KB_ANGLE, 0x4

.set BONES_JOBJ, 0
.set BONES_JOBJ2, BONES_JOBJ + 4
.set BONES_FLAGS1, BONES_JOBJ2 + 4

################################################################################
# Functions
################################################################################

.set PlayerBlock_GetGObj, 0x80034110 # (int slot)
.set PlayerBlock_GetStocks, 0x80033bd8 # (int slot)
.set PlayerBlock_SetStocks, 0x80033c60 # (int slot, u8 stocks)
.set PlayerBlock_GetSlotType, 0x8003241c # (int slot)
.set PlayerBlock_GetPortColor, 0x80036538 # (int slot)
.set PlayerBlock_GetSubCharGObj, 0x8003418c # (int slot, int subchar)

.set PlayerBlock_SetSpawnTime, 0x80035fdc # (int slot, u8 time)
.set PlayerBlock_StoreCopiedCharacter, 0x80035df8 # (int slot,CharacterKind character)
.set PlayerBlock_SetFlag_KirbyLoadCopy, 0x800356d0 # (int slot)
.set PlayerBlock_PlayChant, 0x8003fda0 # (int slot)

.set Player_GetPosition, 0x80086644 # (HSD_GObjPlayer *gobj_player,Vec *vec)
.set Player_IsDead, 0x8008732c
.set Player_InitCharacterStats, 0x800d105c
.set Fighter_SetAngle, 0x8007ac9c # (PlayerHitbox *hitbox,uint angle,HSD_GObjFighter *fgp)

.set Kirby_LoadHatPrefunc, 0x80169c54 # (CharacterKind character,byte costume_id)
.set Kirby_LoadHat, 0x80031da8 # (CharacterKind character,byte costume_id)

.set GetPlayerCount, 0x8016b558

.set Item_Apply_Metal, 0x800c8348
.set Item_Apply_Cloak, 0x800c88d4

.set AS_TurnRun, 0x800c9d94
.set AS_SmashTurn, 0x800c9c74


################################################################################
# Constants
################################################################################

.set PLAYERBLOCKS, 0x80453080
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
.set SZ_HITBOX, 0x138
.set SZ_PBLOCK, 0xE90

.set P1, 0
.set P2, 1
.set P3, 2
.set P4, 3

.set AS_JUMP_AERIALF, 0x1B
.set AS_JUMP_AERIALB, 0x1C

.set HITBOX_STATE_INACTIVE, 0
.set HITBOX_STATE_ACTIVE_PEND, 1
.set HITBOX_STATE_ACTIVE, 2
.set HITBOX_STATE_ACTIVE_INTERP, 3

################################################################################
# Macros
################################################################################


.endif
.set HEADER_PLAYER_STRUCT, 1
