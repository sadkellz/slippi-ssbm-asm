################################################################################
# Address: 0x804a3120
# r3 = max
# r4 = int array[4]
# r5 = player slot
################################################################################
# Fisher-Yates shuffle

.include "External/KZ/StockRun/StockRun.s"
.include "Common/Common.s"

CODE_START:
.set REG_MAX, 31
.set REG_RESULT, 30
.set REG_POOL, 29
.set REG_I, 28
.set REG_AVAILABLE_COUNT, 27
.set REG_RAND_IDX, 26
.set REG_TEMP, 25
.set REG_BITMASK, 24
.set REG_SLOT, 23
  backup
  mr REG_MAX, r3
  mr REG_RESULT, r4
  mr REG_SLOT, r5

  # malloc(max * sizeof(int)) for available pool
  mulli r3, REG_MAX, 4
  branchl r12, HSD_MemAlloc
  mr REG_POOL, r3

  # Build pool of available numbers
  li REG_I, 0
  li REG_AVAILABLE_COUNT, 0

  # Check if slot is -1 (all cards available)
  cmpwi REG_SLOT, -1
  beq ALL_CARDS_AVAILABLE

  # Load player-specific bitmask
  # load r3, stc_sr_plydata
  # mulli r0, REG_SLOT, SRP_SIZE
  mr r3, REG_SLOT
  branchl r12, PlayerBlock_GetGObj
  lwz r3, GOBJ_USERDATA(r3)
  addi r3, r3, FT_SRP_OFST
  lwz REG_BITMASK, SRP_CARDS(r3)
  b BUILD_POOL_LOOP

  ALL_CARDS_AVAILABLE:
    li REG_BITMASK, 0    # empty bitmask = all cards available

  BUILD_POOL_LOOP:
    cmpw REG_I, REG_MAX
    bge BUILD_POOL_DONE

    # Check if bit i is set in bitfield: !(SRP_CARDS & (1 << i))
    li r5, 1
    rlwnm r5, r5, REG_I, 0, 31    # create mask (1 << i)
    and. r0, REG_BITMASK, r5      # test if bit is set
    bne BUILD_POOL_NEXT           # if bit is set, skip this number

    # Rare% × 4 / Card count
    RARE_CARD_CHECK:
      cmpwi REG_I, SR_CARD_GRACE
      beq RARE_CARD_ROLL
      b ADD_TO_POOL               # not rare, add normally

    RARE_CARD_ROLL:
      li r3, 100                    # roll 0-99
      branchl r12, HSD_Randi
      cmpwi r3, SR_RARE_CHANCE
      bge BUILD_POOL_NEXT

    ADD_TO_POOL:
      # Add to available pool
      mulli r0, REG_AVAILABLE_COUNT, 4
      stwx REG_I, REG_POOL, r0      # available_pool[available_count] = i
      addi REG_AVAILABLE_COUNT, REG_AVAILABLE_COUNT, 1

    BUILD_POOL_NEXT:
      addi REG_I, REG_I, 1
      b BUILD_POOL_LOOP

  BUILD_POOL_DONE:
    # Check if we have enough available numbers
    cmpwi REG_AVAILABLE_COUNT, 4
    blt ERROR_EXIT                  # not enough available numbers

    # begin shuffle
    li REG_I, 0
    SHUFFLE_LOOP:
    cmpwi REG_I, 4
    bge SHUFFLE_DONE

    # get random index: HSD_Randi(available_count - i)
    subf r3, REG_I, REG_AVAILABLE_COUNT  # available_count - i
    branchl r12, HSD_Randi
    mr REG_RAND_IDX, r3

    # result[i] = available_pool[rand_index]
    mulli r0, REG_RAND_IDX, 4
    lwzx REG_TEMP, REG_POOL, r0
    mulli r0, REG_I, 4
    stwx REG_TEMP, REG_RESULT, r0

    # available_pool[rand_index] = available_pool[available_count - 1 - i]
    subf r4, REG_I, REG_AVAILABLE_COUNT  # available_count - i
    subi r4, r4, 1                       # available_count - 1 - i
    mulli r4, r4, 4                      # offset
    lwzx r5, REG_POOL, r4               # load available_pool[available_count-1-i]
    mulli r0, REG_RAND_IDX, 4
    stwx r5, REG_POOL, r0               # store to available_pool[rand_index]

    addi REG_I, REG_I, 1
    b SHUFFLE_LOOP

  SHUFFLE_DONE:
    mr r3, REG_POOL
    branchl r12, HSD_Free
    b EXIT

  ERROR_EXIT:
  b 0x0 # if we have enough cards, this shouldnt be possible

  EXIT:
  restore
  blr
