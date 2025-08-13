################################################################################
# Address: 0x802f74b4
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"
.include "KZ/DATA.s"

.set GXSetScissor, 0x8034175c
.set HSD_CObjSetScissorx4, 0x8036a010

.set REG_DATA, 20

backup
bl CODE_START

TABLE: .long 0
TIME: .short 0
top_start: .short 0
top_end: .short 100
bot_start: .short 480
bot_end: .short 380
max: .short 150
cobj: .long 0
.align 2

CODE_START:
    mflr REG_DATA

    table_load_h r5, REG_DATA, TABLE, TIME
    table_load_h r6, REG_DATA, TABLE, max
    cmpw r5, r6
    bge EXIT

    table_load_h r3, REG_DATA, TABLE, top_start
    table_load_h r4, REG_DATA, TABLE, top_end
    table_load_h r5, REG_DATA, TABLE, TIME
    table_load_h r6, REG_DATA, TABLE, max
    bl LERP
    table_load_ptr r7, REG_DATA, TABLE, top_start
    sth r3, 0(r7)

    table_load_h r3, REG_DATA, TABLE, bot_start
    table_load_h r4, REG_DATA, TABLE, bot_end
    table_load_h r5, REG_DATA, TABLE, TIME
    table_load_h r6, REG_DATA, TABLE, max
    bl LERP
    table_load_ptr r7, REG_DATA, TABLE, bot_start
    sth r3, 0(r7)

    # mr r5, r3
    # logf LOG_LEVEL_NOTICE, "Scissor: %d"

    table_load_ptr r3, REG_DATA, TABLE, TIME
    lhz r5, 0(r3)
    addi r5, r5, 1
    sth r5, 0(r3)

    # lbz r3, 0x30(r31)
    load r3, 0x80452c68 # MainCamera ptr
    lwz r3, 0(r3)
    lwz r3, 0x28(r3) # cobj
    li r4, 0
    li r5, 640
    table_load_h r6, REG_DATA, TABLE, top_start
    table_load_h r7, REG_DATA, TABLE, bot_start
    branchl r12, HSD_CObjSetScissorx4


    table_load_w r3, REG_DATA, TABLE, cobj
    li r4, 0
    li r5, 640
    table_load_h r6, REG_DATA, TABLE, top_start
    table_load_h r7, REG_DATA, TABLE, bot_start
    branchl r12, HSD_CObjSetScissorx4
    

    b EXIT

LERP:
    # r3 = start
    # r4 = end
    # r5 = time
    # r6 = max
    # cmpw r3, r6
    # bge lerp_exit
    sub r0, r4, r3 # end - start
    mullw r0, r0, r5 # delta * t
    divw r0, r0, r6 # delta * t / max
    add r3, r3, r0 # start + delta * t / max
    lerp_exit:
    blr

EXIT:
    restore
    lwz	r0, 0x0024 (sp)
