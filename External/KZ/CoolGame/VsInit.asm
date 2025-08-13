################################################################################
# Address: 0x801a585c
################################################################################

.include "Common/Common.s"
.include "KZ/PLAYER.s"

.set REG_VSDATA, 29

.set Camera_SetMode3, 0x8002f7ac
.set MatchInfo_IsTeams, 0x8016b168
.set SFX_PlayAnnouncerSFX, 0x800243f4

.set MatchInfo, 0x8046b6a0
.set HudVisFlag, 0x804d6d58

.set OFST_ENDGFX, 0x7
.set OFST_MATCHEND, 0x50


# og
addi	r31, r3, 0

CODE_START:
  backup

  addi REG_VSDATA, REG_VSDATA, 8
# set end game graphic, 9 is empty
  li r3, 9
  stb r3, OFST_ENDGFX(REG_VSDATA)

  bl FN_Zoom
  mflr r3
  stw r3, OFST_MATCHEND(REG_VSDATA)
  
  b EXIT


################################################################################

FN_Zoom:
blrl

.set REG_COUNT, 20

FN_Zoom_Body:
  backup

# if teams, exit
  branchl r12, MatchInfo_IsTeams
  cmpwi r3, 1
  beq FN_Zoom_Exit

# if not 1v1, exit
  # branchl r12, GetPlayerCount
  # cmpwi r3, 2
  # bgt FN_Zoom_Exit

# have to manually check who won the match
  li REG_COUNT, 0
  CHECK_WINNER_LOOP:
    mr r3, REG_COUNT
    branchl r12, PlayerBlock_GetSlotType
    cmpwi r3, 3 # check if slot is active
    beq CHECK_WINNER_INC

    mr r3, REG_COUNT
    branchl r12, PlayerBlock_GetStocks
    cmpwi r3, 1
    beq EXECUTE_ZOOM

  CHECK_WINNER_INC:
    addi REG_COUNT, REG_COUNT, 1
    cmpwi REG_COUNT, 4
    blt CHECK_WINNER_LOOP

  EXECUTE_ZOOM:
    # disable hud
    load r3, HudVisFlag
    li r4, 1
    stb r4, 0(r3)
    
    # classic mode camera zoom
    mr r3, REG_COUNT
    branchl r12, Camera_SetMode3


FN_Zoom_Exit:
  restore
  blr

################################################################################

EXIT:
  restore
