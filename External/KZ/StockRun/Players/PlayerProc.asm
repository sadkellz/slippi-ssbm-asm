################################################################################
# Address: 0x800691b0
# creates a fighter proc before any other procs spawn
################################################################################

.include "External/KZ/StockRun/StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/HSD_JOBJ.s"
.include "External/KZ/HSD_ITEM.s"
.include "External/KZ/PLAYER.s"

b CODE_START

# Init
#==============================================================================#
CODE_START:
.set REG_FGP, 31
  backup

  mr r3, REG_FGP
  bl FN_FighterThinkBLRL
  mflr r4
  li r5, 0
  branchl r12, GObj_AddProc

  mr r5, REG_FGP
  logf LOG_LEVEL_ERROR, "Fighter GOBJ: %08x\n"

  # zero out our SRP data
  lwz r3, GOBJ_USERDATA(REG_FGP)
  addi r3, r3, FT_SRP_OFST
  li r4, SRP_SIZE
  branchl r12, memzero

  b EXIT

#==============================================================================#


# This handles item/monster spawns after card selections
#------------------------------------------------------------------------------#
FN_FighterThinkBLRL:
blrl
.set REG_FGP, 31
.set REG_FP, 30
.set REG_SRPD, 29
.set REG_CARDS, 28
.set REG_STATS, 27
.set REG_COUNT, 28
.set REG_COLOR, 27
.set REG_PANEL, 26
.set REG_BLOCK, 25
FN_FighterThink:
  backup

# init vars
  mr REG_FGP, r3
  lwz REG_FP, GOBJ_USERDATA(REG_FGP)
  addi REG_SRPD, REG_FP, FT_SRP_OFST

# check if we should apply a card
  lwz r3, SRP_APPLY_CARD(REG_SRPD)
  cmpwi r3, FALSE
  beq FN_FighterThink_Exit

  addi REG_STATS, REG_FP, FT_STATS
  lwz REG_CARDS, SRP_CARDS(REG_SRPD)


  # check applicable cards
  # items first because of InitCharacterStats
  BUNNYHOOD:
    rlwinm. r0, REG_CARDS, 0, 31-SR_CARD_BUNNYHOOD, 31-SR_CARD_BUNNYHOOD
    beq METAL
    # have to spawn the hood first...
    addi r3, REG_FP, FT_POS
    li r4, ITEM_KIND_RABBITC
    branchl r12, StockRunCard_SpawnItem
    mr r4, r3
    mr r3, REG_FGP
    branchl r12, Player_GiveItem
    addi r3, REG_FP, FT_ITEM_TIMERS
    load r4, 0x7FFFFFFF
    stw r4, ITEM_TIMER_BUNNYHOOD(r3)

  METAL:
    rlwinm. r0, REG_CARDS, 0, 31-SR_CARD_METAL, 31-SR_CARD_METAL
    beq CLOAK
    # spawn metal box
    addi r3, REG_FP, FT_POS
    li r4, ITEM_KIND_METALB
    branchl r12, StockRunCard_SpawnItem
    mr r4, r3
    mr r3, REG_FGP
    branchl r12, Player_GiveItem
    addi r3, REG_FP, FT_ITEM_TIMERS
    load r4, 0x7FFFFFFF
    stw r4, ITEM_TIMER_METAL(r3)
    stw r4, ITEM_TIMER_METAL_HP(r3)

  CLOAK:
    rlwinm. r0, REG_CARDS, 0, 31-SR_CARD_CLOAK, 31-SR_CARD_CLOAK
    beq ALLIED_GOOMBA
    # spawn metal box
    addi r3, REG_FP, FT_POS
    li r4, ITEM_KIND_SPYCLOAK
    branchl r12, StockRunCard_SpawnItem
    mr r4, r3
    mr r3, REG_FGP
    branchl r12, Player_GiveItem
    addi r3, REG_FP, FT_ITEM_TIMERS
    load r4, 0x7FFFFFFF
    stw r4, ITEM_TIMER_CLOAK(r3)

  ALLIED_GOOMBA:
    rlwinm. r0, REG_CARDS, 0, 31-SR_CARD_ALLIED_GOOMBA, 31-SR_CARD_ALLIED_GOOMBA
    beq FN_FighterThink_Exit
    lwz r3, FT_CID(REG_FP)
    cmpwi r3, 0xB # Nana shouldnt spawn an item as well...
    beq FN_FighterThink_Exit
    li r3, 0
    li r4, ITEM_KIND_KURIBOH
    mr r5, REG_FGP
    branchl r12, StockRunCard_SpawnItem


FN_FighterThink_Exit:
  li r3, 0
  stw r3, SRP_APPLY_CARD(REG_SRPD)
  
  restore
  blr

#------------------------------------------------------------------------------#


EXIT:
  restore
  lis	r3, 0x8007
