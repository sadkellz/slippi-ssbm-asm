################################################################################
# Address: 0x8029a7f4
################################################################################

.include "External/KZ/StockRun/StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/HSD_JOBJ.s"
.include "External/KZ/HSD_ITEM.s"
.include "External/KZ/PLAYER.s"

CODE_START:
.set REG_ITEM, 30
.set REG_IGP, 29

  li r0, 0
  lwz r3, GOBJ_OBJ(REG_IGP)
  stw r0, JOBJ_FLAGS(r3)

  lbz r0, ITEM_FLAGS6(REG_ITEM)
  ori r0, r0, 0x20
  stb r0, ITEM_FLAGS6(REG_ITEM)


EXIT:
  mr	r3, r29