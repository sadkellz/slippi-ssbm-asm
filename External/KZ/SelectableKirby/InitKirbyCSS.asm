################################################################################
# Address: 0x80266824 # CSS_Setup
################################################################################

.include "Common/Common.s"
.include "KZ/HSD_GOBJ.s"
.include "KZ/HSD_JOBJ.s"
.include "KZ/HSD_PAD.s"

.set GXProcJoint, 0x80391070
.set CSS_GObjCallback, 0x8025f0e0

.set MnSlChrModels, 0x804d6cd8
.set CSSPorts, 0x803f0dfc
.set CSSIcons, 0x803f0b24

.set OFST_SINGLEMENU, 0x60
.set OFST_PORTHOVER, 0x0E
.set OFST_ICONCHAR, 0
.set OFST_SLCTCHAR, 0x9

.set SZ_ICON, 0x1C
.set SZ_PORT, 0x24

b CODE_START

.set REG_GOBJ, 31
.set REG_JOBJ, 30
.set REG_DATA, 29
.set REG_MENU, 28
.set REG_STOCK, 27

.set SP_JOBJ, BKP_DEFAULT_FREE_SPACE_SIZE
.set SP_DOUBLE, SP_JOBJ + 4

DATA_BLRL:
blrl
.set MENU_JOBJ, 0
  .long 0
.set ICON_IDX, MENU_JOBJ + 4
  .byte 0xD # kirby
  .byte 0xD
  .byte 0xD
  .byte 0xD
.set ICON_POS, ICON_IDX + 4
  .float -17 # Y
  .float -21.0
  .float -5.6
  .float 9.8
  .float 25.2


CODE_START:
  backup

  bl DATA_BLRL
  mflr REG_DATA

  gobj_create GOBJ_CLASS_PLAYER, GOBJ_PLINK_STAGE, 128, REG_GOBJ

  load r3, MnSlChrModels
  lwz r3, 0(r3)
  addi REG_MENU, r3, OFST_SINGLEMENU

# load single menu model
  lwz r3, JOINT(REG_MENU)
  branchl r12, HSD_JObjLoadJoint
  mr REG_JOBJ, r3
  stw REG_JOBJ, MENU_JOBJ(REG_DATA)

# add to gobj
  mr r3, REG_GOBJ
  li r4, GOBJ_KIND_JOBJ
  mr r5, REG_JOBJ
  branchl r12, GObj_AddObj

# setup gx link
  mr r3, REG_GOBJ
  load r4, GXProcJoint
  li r5, GOBJ_GXLINK_LIGHT
  li r6, 128
  branchl r12, GObj_SetupGXLink

# setup proc  
  mr r3, REG_GOBJ
  # load r4, CSS_GObjCallback
  bl FN_IconProc
  mflr r4
  li r5, 4
  branchl r12, GObj_AddProc

# add our data to the gobj
	mr r3, REG_GOBJ
	li r4, 0
	load r5, 0x8021b2e0 # blr, crash without?
	mr r6, REG_DATA
	branchl r12, GObj_AddUserData # (GOBJ *gobj, int userDataKind, void *destructor, void *userData)

# hide jobj
  mr r3, REG_JOBJ
  li r4, JOBJFLAG_HIDDEN
  branchl r12, HSD_JObjSetFlagsAll

# get stock model
  mr r3, REG_JOBJ
  addi r4, sp, SP_JOBJ
  li r5, 52 # index
  li r6, -1
  branchl r12, JObj_GetJObjChild
  lwz REG_STOCK, SP_JOBJ(sp)

# unhide it
  mr r3, REG_STOCK
  li r4, JOBJFLAG_HIDDEN
  branchl r12, HSD_JObjClearFlagsAll
  
# anim stuff
  mr r3, REG_JOBJ
  lwz r4, ANIMJOINT(REG_MENU)
  lwz r5, MATANIMJOINT(REG_MENU)
  lwz r6, SHAPEANIMJOINT(REG_MENU)
  branchl r12, HSD_JObjAddAnimAll

# set stock model pos
  lwz r3, JOBJ_CHILD(REG_STOCK)
  # im way too lazy to setup float data
  lfs f2, ICON_POS(REG_DATA)
  lfs f1, ICON_POS+4(REG_DATA)
  stfs f1, JOBJ_POS(r3)
  stfs f2, JOBJ_POS+4(r3)

  lwz r3, JOBJ_NEXT(r3)
  lfs f1, ICON_POS+8(REG_DATA)
  stfs f1, JOBJ_POS(r3)
  stfs f2, JOBJ_POS+4(r3)

  lwz r3, JOBJ_NEXT(r3)
  lfs f1, ICON_POS+12(REG_DATA)
  stfs f1, JOBJ_POS(r3)
  stfs f2, JOBJ_POS+4(r3)

  lwz r3, JOBJ_NEXT(r3)
  lfs f1, ICON_POS+16(REG_DATA)
  stfs f1, JOBJ_POS(r3)
  stfs f2, JOBJ_POS+4(r3)

  # hide 5th jobj
  lwz r3, JOBJ_NEXT(r3)
  li r4, JOBJFLAG_HIDDEN
  branchl r12, HSD_JObjSetFlagsAll


# reset idx
  load r3, 0x0D0D0D0D
  stw r3, ICON_IDX(REG_DATA)

  li r3, 180
  branchl r12, FN_IntToFloat
  crclr 6
  mr r3, REG_JOBJ
  branchl r12, HSD_JObjReqAnimAll

  mr r3, REG_JOBJ
  branchl r12, HSD_JObjAnimAll


b EXIT


################################################################################

FN_IconProc:
blrl

.set REG_DATA2, 19
.set REG_IDX, 20
.set REG_JOBJ, 21
.set REG_JOBJIDX, 22
.set REG_STOCK, 23
.set REG_PAD, 24
.set REG_SLOT, 25

.set SP_JOBJ, BKP_DEFAULT_FREE_SPACE_SIZE

FN_Icon_Body:
  backup

  mr REG_GOBJ, r3
  lwz REG_DATA, GOBJ_USERDATA(REG_GOBJ)
  lwz REG_JOBJ, MENU_JOBJ(REG_DATA)
  addi REG_DATA2, REG_DATA, ICON_IDX
  
li REG_SLOT, 0
li REG_JOBJIDX, 53
SET_ANIM_LOOP:
# check if kirby is selected
  load r3, CSSPorts
  mulli r0, REG_SLOT, SZ_PORT
  add r4, r0, r3
  lbz r5, OFST_SLCTCHAR(r4)
  li r3, 0xD
  cmpwi r5, 0
  beq STORE_IDX
  lbz r5, OFST_PORTHOVER(r4)
  cmpwi r5, 0xD # Kirby
  bne STORE_IDX

# button check
  mr r3, REG_SLOT
  get_port_pad r3
  mr REG_PAD, r3

  lwz r3, PAD_button_pressed(REG_PAD)
  rlwinm.	r0, r3, 0, 30, 30 # DPAD_LEFT
  bne INCREMENT
  rlwinm.	r0, r3, 0, 31, 31 # DPAD_RIGHT
  bne DECREMENT
  b FN_Icon_Exit

  INCREMENT:
    lbzx r3, REG_SLOT, REG_DATA2
    addi r3, r3, 1
    cmpwi r3, 24
    ble STORE_IDX
      li r3, 0 # wrap around
      b STORE_IDX
  
  DECREMENT:
    lbzx r3, REG_SLOT, REG_DATA2
    subi r3, r3, 1
    cmpwi r3, 0
    bge STORE_IDX
      li r3, 24
      b STORE_IDX

  STORE_IDX:
    stbx r3, REG_SLOT, REG_DATA2
    mr r3, REG_JOBJ
    addi r4, sp, SP_JOBJ
    mr r5, REG_JOBJIDX
    li r6, -1
    branchl r12, JObj_GetJObjChild
    lwz REG_STOCK, SP_JOBJ(sp)

    ANIM:
      lbzx r3, REG_SLOT, r19
      load r4, CSSIcons
      mulli r0, r3, SZ_ICON
      add r4, r0, r4
      lbz r3, OFST_ICONCHAR(r4)
      cmpwi r3, 4 # kirby
      bne SET_FRAME
        li r3, 180 # invis

      SET_FRAME:
        branchl r12, FN_IntToFloat
        fmr f25, f1
        crclr 6
        mr r3, REG_STOCK
        branchl r12, HSD_JObjReqAnimAll

        mr r3, REG_STOCK
        branchl r12, HSD_JObjAnimAll
  
ANIM_LOOP_CHECK:
# store our idx to SpawnAsKirby
  computeBranchTargetAddress r3, 0x800692dc
  addi r3, r3, 8
  lbzx r4, REG_SLOT, REG_DATA2
  stbx r4, REG_SLOT, r3

  addi REG_SLOT, REG_SLOT, 1
  addi REG_JOBJIDX, REG_JOBJIDX, 1
  cmpwi REG_SLOT, 4
  blt SET_ANIM_LOOP

  # fmr f1, f25
  # lwz r5, ICON_IDX(REG_DATA)
  # logf LOG_LEVEL_WARN, "icon: %f ---- %d\n"

FN_Icon_Exit:
  restore
  blr


EXIT:
  restore
  branch r12, 0x80266830 # css setup exit
