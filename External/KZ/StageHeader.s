.ifndef HEADER_STAGE_HEADER

# Collision
.set COLL_LINE, 0x804d64bc
.set COLL_PARAM, 0x804d64b4
.set COLL_VTX, 0x804d64b8
.set SZ_COLLLINE, 0x8
.set SZ_VTX, 0x18

.set COLL_LINE_DESC, 0
.set COLL_LINE_FLAGS, COLL_LINE_DESC + 4

.set COLL_PARAM_VTX, 0
.set COLL_PARAM_VTXCOUNT, COLL_PARAM_VTX + 4
.set COLL_PARAM_LINEDESCS, COLL_PARAM_VTXCOUNT + 4
.set COLL_PARAM_LINECOUNT, COLL_PARAM_LINEDESCS + 4
.set COLL_PARAM_FLOORSTART, COLL_PARAM_LINECOUNT + 4
.set COLL_PARAM_FLOORCOUNT, COLL_PARAM_FLOORSTART + 2
.set COLL_PARAM_CEILSTART, COLL_PARAM_FLOORCOUNT + 2
.set COLL_PARAM_CEILCOUNT, COLL_PARAM_CEILSTART + 2
.set COLL_PARAM_RIGHTSTART, COLL_PARAM_CEILCOUNT + 2
.set COLL_PARAM_RIGHTCOUNT, COLL_PARAM_RIGHTSTART + 2
.set COLL_PARAM_LEFTSTART, COLL_PARAM_RIGHTCOUNT + 2
.set COLL_PARAM_LEFTCOUNT, COLL_PARAM_LEFTSTART + 2
.set COLL_PARAM_UNKSTART, COLL_PARAM_LEFTCOUNT + 2
.set COLL_PARAM_UNKCOUNT, COLL_PARAM_UNKSTART + 2
.set COLL_PARAM_JOINTDESCS, COLL_PARAM_UNKCOUNT + 2
.set COLL_PARAM_JOINTCOUNT, COLL_PARAM_JOINTDESCS + 4



.set STAGE_DATA, 0x8049e6c8
.set OFST_CAMLIMIT, 0x0

.set OFST_BLASTZONE, 0x74
	.set OFST_BZ_LEFT, 0x0
	.set OFST_BZ_RIGHT, 0x4
	.set OFST_BZ_TOP, 0x8
	.set OFST_BZ_BOT, 0xC

.set OFST_GOBJS, 0x180
.set OFST_POINTS, 0x280
.set OFST_COL, 0x6AC
.set OFST_LINES, 0x8
.set OFST_LINEGROUPS, 0x24

.set SZ_LINE, 0x10
.set SZ_VERT, 0x8

.set DOBJ_FLAGS, 0x00140048

.set Stage_GetMapHead, 0x801c6330
.set Stage_GetArchive, 0x801c6324

## returns blastzone + scale ofst in f1
.set Stage_GetLeftBlastzone, 0x80224b50
.set Stage_GetRightBlastzone, 0x80224b38
.set Stage_GetTopBlastzone, 0x80224b68
.set Stage_GetBottomBlastzone, 0x80224b80

.set Stage_GetCameraLimitLeft, 0x80224a54
.set Stage_GetCameraLimitRight, 0x80224a68
.set Stage_GetCameraLimitTop, 0x80224a80
.set Stage_GetCameraLimitBottom, 0x80224a98

.set GObj_GetJObjByIndex, 0x801c3fa4
.set Stage_GetPoint, 0x801c2d24
.set DObjLoad, 0x8035e0a4
.set CameraInfo_ExecuteScreenShake, 0x80030e44

.macro get_blastzones left, right, top, bottom
    branchl r12, Stage_GetLeftBlastzone
    fmr \left, f1
    branchl r12, Stage_GetRightBlastzone
    fmr \right, f1
    branchl r12, Stage_GetTopBlastzone
    fmr \top, f1
    branchl r12, Stage_GetBottomBlastzone
    fmr \bottom, f1
.endm

.macro get_camlimits left, right, top, bottom
    branchl r12, Stage_GetCameraLimitLeft
    fmr \left, f1
    branchl r12, Stage_GetCameraLimitRight
    fmr \right, f1
    branchl r12, Stage_GetCameraLimitTop
    fmr \top, f1
    branchl r12, Stage_GetCameraLimitBottom
    fmr \bottom, f1
.endm

.macro get_coll_data reg
    load \reg, STAGE_DATA
    lwz \reg, OFST_COL(\reg)
.endm

.macro get_map_gobj reg, index, reg_temp=r0
    li \reg_temp, \index
    load \reg, STAGE_DATA
    mulli \reg_temp, \reg_temp, 4
    addi \reg, \reg, OFST_GOBJS
    lwzx \reg, \reg, \reg_temp
.endm

.macro get_line reg, line, reg_temp=r0
    get_coll_data \reg
    lwz \reg, OFST_LINES(\reg)
    li \reg_temp, SZ_LINE
    mulli \reg_temp, \reg_temp, \line
    add \reg, \reg, \reg_temp
.endm

.macro line2vert reg, line, reg_temp=r0
    get_coll_data \reg
    lwz \reg, 0(\reg)
    li \reg_temp, SZ_VERT
    mulli \reg_temp, \reg_temp, \line
    add \reg, \reg, \reg_temp
    subi \reg, \reg, SZ_VERT
.endm

.macro vert_table_addr reg
    get_coll_data \reg
.endm

.macro line_table_addr reg
    get_coll_data \reg
    addi \reg, \reg, OFST_LINES
.endm

.macro linegroup_table_addr reg
    get_coll_data \reg
    addi \reg, \reg, OFST_LINEGROUPS
.endm

.macro get_dobj_child reg_jobj, child, reg_temp=r8, reg_dobj=r3
    li \reg_temp, 0
    lwz \reg_dobj, 0x18(\reg_jobj)
    MY_DOBJ_LOOP_START\@:
        lwz \reg_dobj, 0x4(\reg_dobj)

    MY_DOBJ_LOOP_CHECK\@:
        addi \reg_temp, \reg_temp, 1
        cmpwi \reg_temp, \child
        blt MY_DOBJ_LOOP_START\@
.endm

.macro dobj_setflagsall reg_dobj, flag
    li r0, \flag
    DOBJ_SETFLAGALL_START\@:
        cmpwi \reg_dobj, 0
        beq DOBJ_SETFLAGALL_EXIT\@

        stw r0, 0x14(\reg_dobj)
        lwz \reg_dobj, 0x4(\reg_dobj) # next dobj
        b DOBJ_SETFLAGALL_START\@

    DOBJ_SETFLAGALL_EXIT\@:
.endm

.macro play_warning_sfx
    # SetFGMFlags(0x18);
    li r3, 0x18
    branchl r12, 0x80026f2c
    # SFX_SetFGMGroupMask(8,unused,0x100,0);
    li r3, 8
    li r4, 0
    li r5, 0x100
    li r6, 0
    branchl r12, 0x8002702c
    # SFX_LoadFGMGroups();
    branchl r12, 0x80027168
    # CheckToSaveMemCard();
    branchl r12, 0x80027648

    load r3, 0x61a88
    li r4, 127
    li r5, 64
    li r6, 10
    branchl r12, 0x80023870
    # branchl r12, SFX_PlaySoundAtFullVolume
.endm

.macro  play_barrage_sfx
    # SetFGMFlags(0x18);
    li r3, 0x18
    branchl r12, 0x80026f2c
    # SFX_SetFGMGroupMask(8,unused,0x100,0);
    li r3, 8
    li r5, 0x40
    li r6, 0
    # li r3, 2
    # li r5, 0
    # li r6, 0x20

    # li r3, 0xc
    # li r4, 0x1
    # li r5, 0x40
    # load r6, 0x02400000

    li r4, 0
    branchl r12, 0x8002702c
    # SFX_LoadFGMGroups();
    branchl r12, 0x80027168
    # CheckToSaveMemCard();
    branchl r12, 0x80027648

    load r3, 0x5cc6a
    li r4, 127
    li r5, 64
    li r6, 100
    branchl r12, 0x80023870
    branchl r12, SFX_PlaySoundAtFullVolume
.endm

.macro stop_sfx
    # we are only stopping our own sfx, which is channel 10
    li r3, 100  # channel
    branchl r12, 0x8038be64 # SFX_StopSFX
.endm




.endif
.set HEADER_STAGE_HEADER, 1
