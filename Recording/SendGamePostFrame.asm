################################################################################
# Address: 8006da34
################################################################################
.include "Common/Common.s"
.include "Recording/Recording.s"

################################################################################
# Routine: SendGamePostFrame
# ------------------------------------------------------------------------------
# Description: Gets information relevant to calculating stats and writes
# it to Slippi device
################################################################################

.set REG_PlayerData,31
.set REG_Buffer,29
.set REG_BufferOffset,28
.set REG_PlayerSlot,27


backup

# Check if VS Mode
  branchl r12,FN_ShouldRecord
  cmpwi r3,0x0
  beq Injection_Exit

# check if this character is in sleep
  lbz r3,0x221F(REG_PlayerData)
  rlwinm. r3,r3,0,27,27
  bne Injection_Exit

#------------- INITIALIZE -------------
# here we want to initalize some variables we plan on using throughout
  lbz REG_PlayerSlot,0xC(REG_PlayerData)      #loads this player slot
# get current offset in buffer
  lwz r3, primaryDataBuffer(r13)
  lwz REG_Buffer, RDB_TXB_ADDRESS(r3)
  lwz REG_BufferOffset,bufferOffset(r13)
  add REG_Buffer,REG_Buffer,REG_BufferOffset

# send OnPostFrameUpdate event code
  li r3, CMD_POST_FRAME
  stb r3,0x0(REG_Buffer)

# send frame count
  lwz r3,frameIndex(r13)
  stw r3,0x1(REG_Buffer)

# send playerslot
  stb REG_PlayerSlot,0x5(REG_Buffer)

# send isFollowerBool
  mr  r3,REG_PlayerData
  branchl r12,FN_GetIsFollower
  stb r3,0x6(REG_Buffer)

# send player data
  lwz r3,0x04(REG_PlayerData) #load internal char ID
  stb r3,0x07(REG_Buffer)
  lwz r3,0x10(REG_PlayerData) #load action state ID
  sth r3,0x08(REG_Buffer)
  lwz r3,0xB0(REG_PlayerData) #load x coord
  stw r3,0x0A(REG_Buffer)
  lwz r3,0xB4(REG_PlayerData) #load y coord
  stw r3,0x0E(REG_Buffer)
  lwz r3,0x2C(REG_PlayerData) #load facing direction
  stw r3,0x12(REG_Buffer)
  lwz r3,0x1830(REG_PlayerData) #load current damage
  stw r3,0x16(REG_Buffer)
  lwz r3,0x1998(REG_PlayerData) #load shield health
  stw r3,0x1A(REG_Buffer)
  lwz r3,0x208C(REG_PlayerData) #load last attack ID hit by
  stb r3,0x1E(REG_Buffer)
  lhz r3,0x2090(REG_PlayerData) #load combo count
  stb r3,0x1F(REG_Buffer)
  lwz r3,0x18C4(REG_PlayerData) #load player slot who last hit this player
  stb r3,0x20(REG_Buffer)

# send stocks remaining
  mr  r3,REG_PlayerSlot
  branchl r12,PlayerBlock_LoadRemainingStocks
  stb r3,0x21(REG_Buffer)

# send AS frame
  lwz r3,0x894(REG_PlayerData)
  stw r3,0x22(REG_Buffer)

# send bitflags
  lbz r3,0x2218(REG_PlayerData)   #0x10 = isReflectActive
  stb r3,0x26(REG_Buffer)
  lbz r3,0x221A(REG_PlayerData)   #0x04 = HasIntangOrInvinc // 0x08 = isFastFalling // 0x20 = isHitlag
  stb r3,0x27(REG_Buffer)
  lbz  r3,0x221B(REG_PlayerData)  #0x80 = isShieldActive
  stb r3,0x28(REG_Buffer)
  lbz r3,0x221C(REG_PlayerData)   #0x2 = isHitstun // 0x4 = owners detection hitbox touching shield bubble // 0x20 = Powershield Active Bool
  stb r3,0x29(REG_Buffer)
  lbz r3,0x221F(REG_PlayerData)   #0x80 = isOffscreen // 0x40 = isDead // 0x20 =  // 0x10 = inSleep // 0x8 = isFollower
  stb r3,0x2A(REG_Buffer)

# send misc AS variable (is histun frames left when offset 0x221C has hitstun bool enabled)
  lwz r3,0x2340(REG_PlayerData)
  stw r3,0x2B(REG_Buffer)

# send ground/air state
  lwz r3,0xE0(REG_PlayerData)
  stb r3,0x2F(REG_Buffer)

# send ground ID
  lwz r3,0x83C(REG_PlayerData)
  sth r3,0x30(REG_Buffer)

# send number of jumps remaining
  lbz r3,0x1968(REG_PlayerData)
  lwz r4,0x168(REG_PlayerData)
  sub r3,r4,r3
  stb r3,0x32(REG_Buffer)

# send status of lcancel. 0 = none, 1 = successful lcancel, 2 = unsuccessful lcancel
  lbz r3,LCancelStatus(REG_PlayerData)
  stb r3,0x33(REG_Buffer)

# send hurtbox collision status (0 = vulnerable, 1 = invulnerable, 2 = intangible)
  lwz r3,0x1988(REG_PlayerData)     #Move-induced collision state has priority over game-induced
  cmpwi r3,0
  bne HurtboxCollision_Send
  lwz r3,0x198C(REG_PlayerData)
  HurtboxCollision_Send:
  stb r3,0x34(REG_Buffer)

  # send self-induced air x speed
  lwz r3,0x80(REG_PlayerData)
  stw r3,0x35(REG_Buffer)

  # send self-induced y speed
  lwz r3,0x84(REG_PlayerData)
  stw r3,0x39(REG_Buffer)

  # send attack-based x speed
  lwz r3,0x8c(REG_PlayerData)
  stw r3,0x3d(REG_Buffer)

  # send attack-based y speed
  lwz r3,0x90(REG_PlayerData)
  stw r3,0x41(REG_Buffer)

  # send self-induced ground x speed
  lwz r3,0xec(REG_PlayerData)
  stw r3,0x45(REG_Buffer)

  # send hitlag frames left (stored internally as a float)
  lwz r3,0x195c(REG_PlayerData)
  stw r3,0x49(REG_Buffer)

  # send current animation. useful for knowing the current Wait animation
  lwz r3,0x14(REG_PlayerData)
  stw r3,0x4d(REG_Buffer)

  # send instance information
  lhz r3,0x18ec(REG_PlayerData)
  sth r3,0x51(REG_Buffer)
  lhz r3,0x2088(REG_PlayerData)
  sth r3,0x53(REG_Buffer)

#------------- Increment Buffer Offset ------------
  lwz REG_BufferOffset,bufferOffset(r13)
  addi REG_BufferOffset,REG_BufferOffset,(GAME_POST_FRAME_PAYLOAD_LENGTH+1)
  stw REG_BufferOffset,bufferOffset(r13)

################################################################################
# Extract bone positions
################################################################################


#-------------- Save Bone Data ---------------
.set REG_BoneBuf, 21
.set REG_BoneCopyPos, 22
.set REG_BoneCount, 23
.set REG_BoneDataSize, 24
.set REG_BoneBuffOffset, 25
.set REG_SplitMsgBuf, 26

  li REG_BoneDataSize, 4845 # Init total size of bone data for a character
# Create copy buffer
  mr r3, REG_BoneDataSize
  branchl r12, HSD_MemAlloc
  mr REG_BoneBuf, r3
  mr REG_BoneBuffOffset, r3

# zero out the buffer
  mr r3, REG_BoneBuf
  mr r4, REG_BoneDataSize
  branchl r12, Zero_AreaLength

# Write frame header
  lwz r3, frameIndex(r13)
  stw r3, 0x0(REG_BoneBuffOffset) # Write frame index
  stb REG_PlayerSlot, 0x4(REG_BoneBuffOffset) # Write player index
  lwz r3,0x04(REG_PlayerData) 
  stb r3,0x05(REG_BoneBuffOffset) # Write char id
  #mr r17, r4 # Backup r4 so we can save total bone count to 0x6 later
  li REG_BoneCount, 1 # Start count at 1

  # Increment the buffer offset to skip past the frame, player, char id, and bone count.
  addi REG_BoneBuffOffset, REG_BoneBuffOffset, 0x7

# Write bone data to buffer
bl FN_StoreBonePos_BLRL
  mflr r4
  lwz r3, 0x0(REG_PlayerData) # Get Entity from CharData
  lwz r3, 0x28(r3) # Get Root JObj from Entity
  li r5, 0 # no context
  branchl r12, 0x8036f0f0 # HSD_JObjWalkTree

  b SPLIT_MSG_START

  FN_StoreBonePos_BLRL:
  blrl
  backup

  stb REG_BoneCount, 0x6(REG_BoneBuf) # Write bone count

  mr r15, r3 # save jobj ptr
  #branchl r12, 0x8000b1cc # GetEntityPosition 8065ea7c

  # we want local transforms not global
  lwz r3, 0x38(r15) # Get local posX
  stw r3, 0(REG_BoneBuffOffset)
  lwz r3, 0x3C(r15) # Get local posY
  stw r3, 4(REG_BoneBuffOffset)
  lwz r3, 0x40(r15) # Get local posZ
  stw r3, 8(REG_BoneBuffOffset)

  lwz r3, 0x1C(r15) # Get rotX
  stw r3, 12(REG_BoneBuffOffset)
  lwz r3, 0x20(r15) # Get rotY
  stw r3, 16(REG_BoneBuffOffset)
  lwz r3, 0x24(r15) # Get rotZ
  stw r3, 20(REG_BoneBuffOffset)
  lwz r3, 0x28(r15) # Get rotW # W is last, sometimes not used
  stw r3, 24(REG_BoneBuffOffset)

  lwz r3, 0x2C(r15) # Get local scaleX
  stw r3, 28(REG_BoneBuffOffset)
  lwz r3, 0x30(r15) # Get local scaleY
  stw r3, 32(REG_BoneBuffOffset)
  lwz r3, 0x34(r15) # Get local scaleZ
  stw r3, 36(REG_BoneBuffOffset)

  lwz r3, 0x14(r15) # Flags
  rlwinm. r3, r3, 0, 14, 14 # USE_QUATERNION(0x20000)
  bne USE_QUAT
  li r3, 0
  stb r3, 40(REG_BoneBuffOffset) # Write flag if used/not used
  b QUAT_EXIT

  USE_QUAT:
  li r3, 1
  stb r3, 40(REG_BoneBuffOffset)

  QUAT_EXIT:
  # Update the write offset for the next bone

  restore
  addi REG_BoneCount, REG_BoneCount, 1
  addi REG_BoneBuffOffset, REG_BoneBuffOffset, 0x28
  blr

#-------------- Transfer Bone Data ---------------
SPLIT_MSG_START:

# Create copy buffer
  li r3, SPLIT_MESSAGE_BUF_LEN
  branchl r12, HSD_MemAlloc
  mr REG_SplitMsgBuf, r3

  li r3, CMD_SPLIT_MESSAGE
  stb r3, SPLIT_MESSAGE_OFST_COMMAND(REG_SplitMsgBuf)

  # Copy command
  li r3, CMD_BONES
  stb r3, SPLIT_MESSAGE_OFST_INTERNAL_CMD(REG_SplitMsgBuf)

  # Initialize the data size, will be overwritten once last message is sent
  li r3, SPLIT_MESSAGE_INTERNAL_DATA_LEN
  sth r3, SPLIT_MESSAGE_OFST_SIZE(REG_SplitMsgBuf)

  # Initialize isComplete, will be overwritten once last message is sent
  li r3, 0
  stb r3, SPLIT_MESSAGE_OFST_IS_COMPLETE(REG_SplitMsgBuf)

  li REG_BoneCopyPos, 0

BONE_DATA_LOOP_START:
  sub r3, REG_BoneDataSize, REG_BoneCopyPos
  cmpwi r3, SPLIT_MESSAGE_INTERNAL_DATA_LEN
  bgt BONE_DATA_COPY_BLOCK

  # This is the last message, write the size
  sth r3, SPLIT_MESSAGE_OFST_SIZE(REG_SplitMsgBuf)

  # Indicate last message
  li r3, 1
  stb r3, SPLIT_MESSAGE_OFST_IS_COMPLETE(REG_SplitMsgBuf)

BONE_DATA_COPY_BLOCK:
  # Copy next gecko list section
  addi r3, REG_SplitMsgBuf, SPLIT_MESSAGE_OFST_DATA # destination
  mr r4, REG_BoneBuf
  add r4, r4, REG_BoneCopyPos
  lhz r5, SPLIT_MESSAGE_OFST_SIZE(REG_SplitMsgBuf)
  branchl r12, memcpy

  # Transfer codes
  mr r3, REG_SplitMsgBuf
  li r4, SPLIT_MESSAGE_BUF_LEN
  li r5, CONST_ExiWrite
  branchl r12, FN_EXITransferBuffer

  addi REG_BoneCopyPos, REG_BoneCopyPos, SPLIT_MESSAGE_INTERNAL_DATA_LEN
  cmpw REG_BoneCopyPos, REG_BoneDataSize
  blt BONE_DATA_LOOP_START



BONE_DATA_CLEANUP:
  # Free memory of both buffers
  mr r3, REG_BoneBuf
  branchl r12, HSD_Free

  mr r3, REG_SplitMsgBuf
  branchl r12, HSD_Free

Injection_Exit:
  restore
  lwz r0, 0x001C (sp)
