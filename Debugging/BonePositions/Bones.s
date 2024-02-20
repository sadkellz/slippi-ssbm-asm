.ifndef HEADER_BONES

.macro FunctionBody_PrintFighterBones
backup


mr r23, r31 # Store entity struct

# Prepare callback context to keep track of count
li r4, 0
stw r4, BKP_FREE_SPACE_OFFSET(sp)

bl 8f # FN_LogJObjPosition_BLRL
mflr r4
lwz r3, 0x28(r3) # Get Root JObj from Entity
addi r5, sp, BKP_FREE_SPACE_OFFSET
branchl r12, 0x8036f0f0 # HSD_JObjWalkTree

restore
blr

8: # FN_LogJObjPosition_BLRL:
blrl
backup

# (mtx, (Vec3*) &jobj->rotate)
.set HSD_MtxGetRotation, 0x80379c24
.set HSD_MtxGetScale, 0x80379f88
.set HSD_MtxGetTranslate, 0x80379f6c

.set REG_JobjTransforms, 26
.set REG_JobjPtr, 28
mr r27, r4 # Ptr to iteration count
mr REG_JobjPtr, r3 # Store JObj address

# TEMP: Only print first 3 bones
# lwz r3, 0(r27)
# cmpwi r3, 3
# bgt 9f # FN_LogJObjPosition_EXIT

mr r3, REG_JobjPtr
li r4, 0
addi r5, sp, BKP_FREE_SPACE_OFFSET
branchl r12, 0x8000b1cc # GetEntityPosition

#lwz r6, 0x2C(r23) # char entity struct

# lwz r6, 0x04(r3) # char id
#lfs f1, BKP_FREE_SPACE_OFFSET(sp) # Get posX
#lfs f2, BKP_FREE_SPACE_OFFSET+4(sp) # Get posY
#lfs f3, BKP_FREE_SPACE_OFFSET+8(sp) # Get posZ

   #li r3, 72
   #branchl r12, HSD_MemAlloc
   #mr REG_JobjTransforms, r3

   #addi r3, REG_JobjPtr, 0x44
   #addi r4, REG_JobjTransforms, 0
   #branchl r12, HSD_MtxGetTranslate

   #addi r3, REG_JobjPtr, 0x44
   #addi r4, REG_JobjTransforms, 12
   #branchl r12, HSD_MtxGetRotation

   #addi r3, REG_JobjPtr, 0x44
   #addi r4, REG_JobjTransforms, 24
   #branchl r12, HSD_MtxGetScale

lwz r5, frameIndex(r13)
lwz r6, 0(r27)
mr r7, REG_JobjPtr
#lfs f1, 0(REG_JobjTransforms) # Get posX
#lfs f2, 4(REG_JobjTransforms) # Get posY
#lfs f3, 8(REG_JobjTransforms) # Get posZ
#
#lfs f4, 12(REG_JobjTransforms) # Get rotX
#lfs f5, 16(REG_JobjTransforms) # Get rotY
#lfs f6, 20(REG_JobjTransforms) # Get rotZ

##lfs f7, 24(REG_JobjTransforms) # Get scaleX
##lfs f8, 28(REG_JobjTransforms) # Get scaleY
##lfs f9, 32(REG_JobjTransforms) # Get scaleZ
#logf LOG_LEVEL_WARN, "[Frame: %d] [Bone Transforms] Idx: %d (0x%x), Pos: (%f, %f, %f), Rot: (%f, %f, %f)"

lfs f1, 56(REG_JobjPtr) # Get local posX
lfs f2, 60(REG_JobjPtr) # Get local posY
lfs f3, 64(REG_JobjPtr) # Get local posZ

lfs f4, 28(REG_JobjPtr) # Get rotX  # Quaternion
lfs f5, 32(REG_JobjPtr) # Get rotY
lfs f6, 36(REG_JobjPtr) # Get rotZ
lfs f7, 40(REG_JobjPtr) # Get rotW

# lfs f8, 44(r28) # Get local scaleX
# lfs f9, 48(r28) # Get local scaleY
# lfs f10, 52(r28) # Get local scaleZ

logf LOG_LEVEL_WARN, "[Frame: %d] [Bone Transforms] Idx: %d (0x%x), Pos: (%f, %f, %f), Rot: (%f, %f, %f, %f)"
# logf LOG_LEVEL_WARN, "[%d] [BonePosThrown] %f, %f, %f"

# TEMP: Print anim translation
# lfs f1, 0x38(r28)
# lfs f2, 0x3c(r28)
# lfs f3, 0x40(r28)
# logf LOG_LEVEL_WARN, "Anim: (%f, %f, %f)"

    
# Increment count
lwz r3, 0(r27)
addi r3, r3, 1
stw r3, 0(r27)

mr r3, REG_JobjTransforms
branchl r12, HSD_Free

9: # FN_LogJObjPosition_EXIT:
restore
blr
.endm

.endif
.set HEADER_BONES, 1
