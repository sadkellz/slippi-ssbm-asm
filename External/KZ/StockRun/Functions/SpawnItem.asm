################################################################################
# Address: StockRunCard_SpawnItem
################################################################################
# Inputs:
# r3 - Spawn Position (Vec3*)
# r4 - Item Kind
# r5 - Owner (GObj*)
################################################################################

.include "External/KZ/StockRun/StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/HSD_JOBJ.s"
.include "External/KZ/HSD_ITEM.s"
.include "External/KZ/PLAYER.s"

CODE_START:
# vars
.set REG_POS, 31
.set REG_KIND, 30
.set REG_OWNER, 29
.set REG_IGP, 28
.set REG_ITEM, 27
# stack
.set SP_POS, BKP_FREE_SPACE_OFFSET
  backup

  # init
  mr REG_POS, r3
  mr REG_KIND, r4
  mr REG_OWNER, r5

  # check pos, if empty lets spawn it randomly like a normal item
  cmplwi REG_POS, 0
  bne SPAWN_ITEM
  
  addi r3, sp, SP_POS
  branchl r12, Item_GenerateSpawnLocation
  addi REG_POS, sp, SP_POS

  SPAWN_ITEM:
    mr r3, REG_POS
    mr r4, REG_KIND
    branchl r12, TrainingMenu_CreateItem
    cmpwi r3, 0
    beq EXIT # failed to spawn
    mr REG_IGP, r4
    lwz REG_ITEM, GOBJ_USERDATA(REG_IGP)

    # do we have an owner?
    cmplwi REG_OWNER, 0
    beq EXIT # no owner

    # set item owner
    stw REG_OWNER, ITEM_OWNER(REG_ITEM)
    lbz r0, ITEM_FLAGS6(REG_ITEM)
    rlwinm r0, r0, 0, 30, 28       # Clear bit 2
    stb r0, ITEM_FLAGS6(REG_ITEM)

EXIT:
  restore
  blr