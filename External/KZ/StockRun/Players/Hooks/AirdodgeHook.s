################################################################################
# Address: 0x80099bf0
################################################################################


needs more thought...
probably inject near here 80099b94 and set the frame rate
also would need to keep track of amt of airdodges to stop spam

.include "External/KZ/StockRun/StockRun.s"
.include "Common/Common.s"
.include "External/KZ/KZ_COMMON.s"
.include "External/KZ/HSD_GOBJ.s"
.include "External/KZ/HSD_JOBJ.s"
.include "External/KZ/HSD_ITEM.s"
.include "External/KZ/PLAYER.s"

CODE_START:
.set REG_FGP, 29

  lwz r3, GOBJ_USERDATA(REG_FGP)
  addi r3, r3, FT_SRP_OFST
  lwz r0, SRP_CARDS(r3)

  rlwinm. r0, r3, 0, 31-SR_CARD_ACTAIRDODGE, 31-SR_CARD_ACTAIRDODGE
  # beq EXIT

  mr r3, REG_FGP
  branchl r12, AS_Fall
  branch r12, 0x80099c10

EXIT:
  lwz	r6, -0x514C (r13)
