################################################################################
# Address: 0x801ba2ec
################################################################################

.include "Common/Common.s"
.include "Online/Online.s"
.include "KZ/DATA.s"


.set HSD_ImageDescInit, 0x800121fc
.set CameraBlur, 0x800138ec
.set Archive_LoadAndGetSymbols, 0x80016dbc


.set REG_IMAGE, 31
.set REG_GOBJ, 30
.set REG_DATA, 29

.set REG_LOBJ, 20

backup
bl CODE_START

TABLE3: .byte 0
FILE_NAME: .string "GmRegClr"
.align 2
FILE_SYMBOL: .string "ScGamRegClear_scene_data"
.align 2
ONE: .float 1.0
BLUR: .float 2.0

.set SP_SCN_DESC, BKP_FREE_SPACE_OFFSET
.set SP_LIGHT_GOBJ, SP_SCN_DESC + 0x10
.set SP_UI_GOBJ, SP_LIGHT_GOBJ + 4

CODE_START:
    mflr REG_DATA

    # li r0, 0
    # stw r0, SP_SCN_DESC(sp)

    # bp
    # table_load_ptr r3, REG_DATA, TABLE3, FILE_NAME
    # # load r3, 0x803d8b9c
    # addi r4, sp, SP_SCN_DESC
    # table_load_ptr r5, REG_DATA, TABLE3, FILE_SYMBOL
    # # load r5, 0x803d8ba8
    # branchl r12, Archive_LoadAndGetSymbols
    # load r4, 0x80472d70
    # li r6, 0
    # stw r3, 0(r4)


    # lwz r3, SP_SCN_DESC(sp)
    # lwz r3, 0(r3)
    # load r4, 0x80472d74
    # li r5, 0
    # branchl r12, 0x80168a6c # unk

    # li r3, 11
    # li r4, 3
    # li r5, 0
    # branchl r12, GObj_Create # light
    # mr REG_GOBJ, r3
    # # stw r3, SP_LIGHT_GOBJ(sp)

    # load r3, 0x80472d84
    # branchl r12, 0x80011ac4 # HSD_LObjLoadDescList
    # mr r5, r3
    # mr r3, REG_GOBJ
    # lbz r4, -0x3E56(r13)
    # branchl r12, GObj_AddToObj

    # mr r3, REG_GOBJ
    # load r4, 0x80391044
    # li r5, 10
    # li r6, 0
    # branchl r12, GObj_SetupGXLink


# # UI
#     li r3, 14
#     li r4, 14
#     li r5, 0
#     branchl r12, GObj_Create # ui
#     mr REG_GOBJ, r3

#     load r3, 0x80472d88
#     branchl r12, 0x8036a590 # HSD_CObjLoadDesc
#     mr r5, r3
#     mr r3, REG_GOBJ
#     lbz r4, -0x3E55(r13)
#     branchl r12, GObj_AddToObj

#     mr r3, REG_GOBJ
#     load r4, 0x803910d8
#     li r5, 8
#     branchl r12, GObj_SetupGXLink
#     li r0, 0x4C00
#     stw r0, 0x24(REG_GOBJ) # gxlink prios?
#     li r0, 0
#     stw r0, 0x20(REG_GOBJ) # gxlink prios?

    load r3, 0x80472d58
    li r4, 640
    li r5, 480
    li r6, 5
    li r7, 0
    branchl r12, HSD_ImageDescInit
    mr REG_IMAGE, r3

    li r3, 0
    lfs f1, 0(r3)
    lfs f2, 0(r3)
    table_load_f f3, REG_DATA, TABLE3, ONE
    table_load_f f4, REG_DATA, TABLE3, ONE
    load r3, 0x80472d58
    li r4, 0
    li r5, 2
    li r6, 50
    # mr r7, REG_IMAGE
    branchl r12, CameraBlur
    mr REG_GOBJ, r3
    load r4, 0x80472d54
    stw r3, 0(r4)

    table_load_f f0, REG_DATA, TABLE3, BLUR
    load r3, 0x80472d28
    stfs f0, 0x10C(r3)

    # mr r3, REG_GOBJ
    # li r4, 1
    # branchl r12, 0x800138d8

    mr r3, REG_GOBJ
    load r4, 0x8017fe54
    branchl r12, 0x800138cc

    # li r3, 0
    # branchl r12, 0x8002f7ac

EXIT:
    restore
    # li	r3, 0
    blr

