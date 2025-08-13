################################################################################
# Address: 0x801c0f48
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"
.include "KZ/DATA.s"

.set GXSetScissor, 0x8034175c
.set HSD_CObjSetScissorx4, 0x8036a010

.set REG_DATA, 20

backup
bl CODE_START

TABLE2: .long 0
TIME2: .short 0
top_start2: .short 100
top_end2: .short 0
bot_start2: .short 380
bot_end2: .short 480
max2: .short 30
cobj2: .long 0
.align 2

CODE_START:
    mflr REG_DATA
    bp
    table_load_h r5, REG_DATA, TABLE2, TIME2
    cmpwi r5, 100
    bge EXIT
    
    table_load_h r3, REG_DATA, TABLE2, top_start2
    table_load_h r4, REG_DATA, TABLE2, top_end2
    table_load_h r5, REG_DATA, TABLE2, TIME2
    table_load_h r6, REG_DATA, TABLE2, max2

    bl LERP
    table_load_ptr r7, REG_DATA, TABLE2, top_start2
    sth r3, 0(r7)
    bp
    table_load_h r3, REG_DATA, TABLE2, bot_start2
    table_load_h r4, REG_DATA, TABLE2, bot_end2
    table_load_h r5, REG_DATA, TABLE2, TIME2
    table_load_h r6, REG_DATA, TABLE2, max2
    bl LERP
    table_load_ptr r7, REG_DATA, TABLE2, bot_start2
    sth r3, 0(r7)

    # mr r5, r3
    # logf LOG_LEVEL_NOTICE, "Scissor: %d"

    table_load_ptr r3, REG_DATA, TABLE2, TIME2
    lhz r5, 0(r3)
    addi r5, r5, 1
    sth r5, 0(r3)

    # lbz r3, 0x30(r31)
    load r3, 0x80452c68 # MainCamera ptr
    lwz r3, 0(r3)
    lwz r3, 0x28(r3) # cobj
    li r4, 0
    li r5, 640
    table_load_h r6, REG_DATA, TABLE2, top_start2
    table_load_h r7, REG_DATA, TABLE2, bot_start2
    branchl r12, HSD_CObjSetScissorx4

    table_load_w r3, REG_DATA, TABLE2, cobj2
    li r4, 0
    li r5, 640
    table_load_h r6, REG_DATA, TABLE2, top_start2
    table_load_h r7, REG_DATA, TABLE2, bot_start2
    branchl r12, HSD_CObjSetScissorx4
    

    b EXIT

LERP:
    # r3 = start
    # r4 = end
    # r5 = TIME2
    # r6 = max2
    # cmpw r3, r6
    # bge lerp_exit
    sub r0, r4, r3 # end - start
    mullw r0, r0, r5 # delta * t
    divw r0, r0, r6 # delta * t / max2
    add r3, r3, r0 # start + delta * t / max2
    lerp_exit:
    blr

EXIT:
    restore
    lwz	r0, 0x0094 (sp)
