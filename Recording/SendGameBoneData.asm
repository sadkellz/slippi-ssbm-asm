################################################################################
# Address: 8006da38
################################################################################
.include "Common/Common.s"
.include "Recording/Recording.s"

################################################################################
# Routine: SendGameBoneData
# ------------------------------------------------------------------------------
# Description: Gets relevant data to import a replay into Blender
# This data includes player bone transforms, item bone transforms, and the
# metadata associated with them.
################################################################################

.set CamStruct, 0x80452C68
.set HSD_CObjGetEyePosition, 0x80368784 # (CObj* cobj, Vec3* eye_pos)
.set HSD_CObjGetInterest, 0x803686ac # (CObj* cobj, Vec3* interest_pos)
.set HSD_EulerToQuat, 0x8037ee0c # (Vec3 *vec, Quat *quat)

backup

.set REG_CObj, 20
.set REG_BoneBuf, 21
.set REG_BoneCopyPos, 22
.set REG_BoneCount, 23
.set REG_BoneDataSize, 24
.set REG_BoneBuffOffset, 25
.set REG_SplitMsgBuf, 26
.set REG_PlayerSlot,27
.set REG_ItemDataSize, 16
.set REG_ItemJObj, 17
.set REG_ItemGObj, 28
.set REG_ItemData, 29
.set REG_PlayerData,31

# Check if VS Mode
  branchl r12,FN_ShouldRecord
  cmpwi r3,0x0
  beq Injection_Exit

# check if this character is in sleep
  lbz r3,0x221F(REG_PlayerData)
  rlwinm. r3,r3,0,27,27
  bne Injection_Exit

#-------------- Calc Bone Data Size ---------------#
li REG_BoneDataSize, 0 # init data size
#   Bone data size
bl FN_CountBoneData_BLRL
  mflr r4
  lwz r3, 0x0(REG_PlayerData) # Get Entity from CharData
  lwz r3, 0x28(r3) # Get Root JObj from Entity
  li r5, 0 # no context
  branchl r12, 0x8036f0f0 # HSD_JObjWalkTree

  b CountBoneData_EXIT # exit when finished walking the tree

  FN_CountBoneData_BLRL:
  blrl
  backup
  restore
  addi REG_BoneDataSize, REG_BoneDataSize, 0x28 # each time we walk, we add 0x28 to our data size
  blr
  CountBoneData_EXIT:

#-------------- Calc Item Data Size ---------------#
li REG_ItemDataSize, 0
# get first created item
  lwz r3, -0x3E74(r13) # global plink list
  lwz REG_ItemGObj, 0x24(r3) # load the first item
  cmpwi REG_ItemGObj, 0
  beq CountItemData_EXIT # break if the first item is 0

  bl FN_CountItemData_BLRL
  mflr r4
  ItemListLoop:
  mr r3, REG_ItemGObj # move gobj to r3
  lwz r3, 0x28(r3) # Get Root JObj from Entity
  li r5, 0 # no context
  branchl r12, 0x8036f0f0 # HSD_JObjWalkTree

# get next item after walking the first one
  lwz REG_ItemGObj,0x8(REG_ItemGObj)
  cmpwi REG_ItemGObj,0
  bne ItemListLoop # start the loop over again if there is another item

  b CountItemData_EXIT # exit when

  FN_CountItemData_BLRL:
  blrl
  backup
  restore

  addi REG_ItemDataSize, REG_ItemDataSize, 0x28 # add to our data size after each walk
  blr
  CountItemData_EXIT:

#-------------- Save Data to Buffer ---------------#

# Create copy buffer
  add r3, REG_BoneDataSize, REG_ItemDataSize # combine our data sizes
  addi r3, r3, 0x2B # add extra data for camera, item metadata, and bone metadata
  branchl r12, HSD_MemAlloc
  mr REG_BoneBuf, r3
  mr REG_BoneBuffOffset, r3

# zero out the buffer
 mr r3, REG_BoneBuf
 add r4, REG_BoneDataSize, REG_ItemDataSize
 branchl r12, Zero_AreaLength
# Write frame header
  lwz r3, frameIndex(r13)
  stw r3, 0x0(REG_BoneBuffOffset) # Write frame index
  lbz REG_PlayerSlot,0xC(REG_PlayerData)
  stb REG_PlayerSlot, 0x4(REG_BoneBuffOffset) # Write player index
  lwz r3,0x04(REG_PlayerData) 
  stb r3,0x05(REG_BoneBuffOffset) # Write *internal* char id
  stw REG_BoneDataSize, 0x07(REG_BoneBuffOffset) # Write bone data size
  
#-------------- Camera Data ---------------#

  loadwz r3, CamStruct
  lwz REG_CObj, 0x28(r3)

  mr r3, REG_CObj
  addi r4, REG_BoneBuffOffset, 0x0B
  branchl r12, HSD_CObjGetEyePosition # Write Eye vector

  mr r3, REG_CObj
  addi r4, REG_BoneBuffOffset, 0x17
  branchl r12, HSD_CObjGetInterest # Write Interest vector

  lwz r3, 0x40(REG_CObj)
  stw r3, 0x23(REG_BoneBuffOffset) # Write FOV

  li REG_BoneCount, 1 # Start count at 1
  # Increment the buffer offset to skip past the header and camera data

  addi REG_BoneBuffOffset, REG_BoneBuffOffset, 0x28

#-------------- Bone Data ---------------#

bl FN_StoreBonePos_BLRL
  mflr r4
  lwz r3, 0x0(REG_PlayerData) # Get Entity from CharData
  lwz r3, 0x28(r3) # Get Root JObj from 
  li r5, 0 # no context
  branchl r12, 0x8036f0f0 # HSD_JObjWalkTree

  b StoreItemData_START

  FN_StoreBonePos_BLRL:
  blrl
  backup

  stb REG_BoneCount, 0x6(REG_BoneBuf) # Write bone count

  mr REG_ItemJObj, r3 # save jobj ptr

  # we want local transforms not global
  lwz r3, 0x38(REG_ItemJObj) # Get local posX
  stw r3, 0(REG_BoneBuffOffset)
  lwz r3, 0x3C(REG_ItemJObj) # Get local posY
  stw r3, 4(REG_BoneBuffOffset)
  lwz r3, 0x40(REG_ItemJObj) # Get local posZ
  stw r3, 8(REG_BoneBuffOffset)

  lwz r3, 0x14(REG_ItemJObj) # Flags
  rlwinm. r3, r3, 0, 14, 14 # USE_QUATERNION(0x20000)
  bne USE_QUAT

  addi r3, REG_ItemJObj, 0x1C # jobj euler rotation
  addi r4, REG_BoneBuffOffset, 12 # buffer quat offset
  branchl r12, HSD_EulerToQuat

  b QUAT_EXIT

  USE_QUAT:
  lwz r3, 0x1C(REG_ItemJObj) # Get rotX
  stw r3, 12(REG_BoneBuffOffset)
  lwz r3, 0x20(REG_ItemJObj) # Get rotY
  stw r3, 16(REG_BoneBuffOffset)
  lwz r3, 0x24(REG_ItemJObj) # Get rotZ
  stw r3, 20(REG_BoneBuffOffset)
  lwz r3, 0x28(REG_ItemJObj) # Get rotW
  stw r3, 24(REG_BoneBuffOffset)
  QUAT_EXIT:
  
  lwz r3, 0x2C(REG_ItemJObj) # Get local scaleX
  stw r3, 28(REG_BoneBuffOffset)
  lwz r3, 0x30(REG_ItemJObj) # Get local scaleY
  stw r3, 32(REG_BoneBuffOffset)
  lwz r3, 0x34(REG_ItemJObj) # Get local scaleZ
  stw r3, 36(REG_BoneBuffOffset)

  # Update the write offset for the next bone
  restore
  addi REG_BoneCount, REG_BoneCount, 1
  addi REG_BoneBuffOffset, REG_BoneBuffOffset, 0x28
  blr

#-------------- Item Data ---------------#

StoreItemData_START:
cmpwi REG_ItemDataSize, 0
beq StoreItemData_EXIT

# get first created item
  lwz r3, -0x3E74(r13) # global plink list
  lwz REG_ItemGObj, 0x24(r3) # load the first item
  cmpwi REG_ItemGObj, 0
  beq StoreItemData_EXIT # break if the first item is 0

# save item metadata
  stw REG_ItemDataSize, 0(REG_BoneBuffOffset)
  lwz REG_ItemData,0x2C(REG_ItemGObj)

  lwz r3, 0x10(REG_ItemData)
  sth r3, 0x4(REG_BoneBuffOffset) # store item ID
  lbz r3, 0xDD7(REG_ItemData) # This stores Samus missile type
  stb r3, 0x6(REG_BoneBuffOffset)
  lbz r3, 0xDDB(REG_ItemData) # This stores Turnip's face ID
  stb r3, 0x7(REG_BoneBuffOffset)
  lbz r3, 0xDEF(REG_ItemData) # This stores charge power for Samus/MewTwo (0-7)
  stb r3, 0x8(REG_BoneBuffOffset)
# Store item ownership
  lwz r3, 0x518(REG_ItemData)
  cmpwi r3, 0x0   # Is this a null pointer?
  beq DontFollowItemOwnerPtr
  lwz r3, 0x2C(r3)
  cmpwi r3, 0x0   # Is this a null pointer?
  beq DontFollowItemOwnerPtr
  lbz r3, 0xC(r3)
  b SendItemOwner
DontFollowItemOwnerPtr:
  li r3, -1
SendItemOwner:
  stb r3, 0x9(REG_BoneBuffOffset)
  # store owner id
  lwz r3, 0x514(REG_ItemData)
  stb r3, 0xA(REG_BoneBuffOffset)
# store item instance
  lhz r3, 0xDA8(REG_ItemData)
  sth r3, 0xB(REG_BoneBuffOffset)

addi REG_BoneBuffOffset, REG_BoneBuffOffset, 0xE # offset buffer to store item joints after metadata

bl FN_StoreItemPos_BLRL
  mflr r4
  lwz REG_ItemJObj, 0x28(REG_ItemGObj)
  mr r3, REG_ItemJObj
  StoreItemData_LOOP:
  li r5, 0 # no context
  branchl r12, 0x8036f0f0 # HSD_JObjWalkTree

  # get next item after walking the first one
  lwz REG_ItemGObj,0x8(REG_ItemGObj)
  cmpwi REG_ItemGObj,0
  bne StoreItemData_LOOP # start the loop over again if there is another item
  b SPLIT_MSG_START

  FN_StoreItemPos_BLRL:
  blrl
  backup
  
  # we want local transforms not global
  lwz r3, 0x38(REG_ItemJObj) # Get local posX
  stw r3, 0(REG_BoneBuffOffset)
  lwz r3, 0x3C(REG_ItemJObj) # Get local posY
  stw r3, 4(REG_BoneBuffOffset)
  lwz r3, 0x40(REG_ItemJObj) # Get local posZ
  stw r3, 8(REG_BoneBuffOffset)

  lwz r3, 0x14(REG_ItemJObj) # Flags
  rlwinm. r3, r3, 0, 14, 14 # USE_QUATERNION(0x20000)
  bne USE_QUAT_2

  addi r3, REG_ItemJObj, 0x1C # jobj euler rotation
  addi r4, REG_BoneBuffOffset, 12 # buffer quat offset
  branchl r12, HSD_EulerToQuat

  b QUAT_EXIT_2

  USE_QUAT_2:
  lwz r3, 0x1C(REG_ItemJObj) # Get rotX
  stw r3, 12(REG_BoneBuffOffset)
  lwz r3, 0x20(REG_ItemJObj) # Get rotY
  stw r3, 16(REG_BoneBuffOffset)
  lwz r3, 0x24(REG_ItemJObj) # Get rotZ
  stw r3, 20(REG_BoneBuffOffset)
  lwz r3, 0x28(REG_ItemJObj) # Get rotW
  stw r3, 24(REG_BoneBuffOffset)
  QUAT_EXIT_2:
  
  lwz r3, 0x2C(REG_ItemJObj) # Get local scaleX
  stw r3, 28(REG_BoneBuffOffset)
  lwz r3, 0x30(REG_ItemJObj) # Get local scaleY
  stw r3, 32(REG_BoneBuffOffset)
  lwz r3, 0x34(REG_ItemJObj) # Get local scaleZ
  stw r3, 36(REG_BoneBuffOffset)

  # Update the write offset for the next bone
  restore
  addi REG_BoneBuffOffset, REG_BoneBuffOffset, 0x28
  blr
  StoreItemData_EXIT:

#-------------- Transfer Bone Data ---------------
SPLIT_MSG_START:
add REG_BoneDataSize, REG_BoneDataSize, REG_ItemDataSize
# Create copy buffer
  li r3, SPLIT_MESSAGE_BUF_LEN
  branchl r12, HSD_MemAlloc
  mr REG_SplitMsgBuf, r3
# zero out the buffer
  mr r3, REG_SplitMsgBuf
  li r4, SPLIT_MESSAGE_BUF_LEN
  branchl r12, Zero_AreaLength

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
  # Copy next bone data section
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
  # original lines
  lwz r0, 0x001C (sp)
  lwz r31, 0x0014 (sp)
