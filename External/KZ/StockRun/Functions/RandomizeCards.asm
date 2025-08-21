################################################################################
# Address: 0x804a3120
# r3 = max
# r4 = int array[4]
################################################################################
# Fisher-Yates shuffle

.include "./StockRun.s"
.include "Common/Common.s"

CODE_START:
.set REG_MAX, 31
.set REG_RESULT, 30
.set REG_POOL, 29
.set REG_I, 28
.set REG_RAND_IDX, 27
.set REG_TEMP, 26
  backup
  mr REG_MAX, r3
  mr REG_RESULT, r4
 
  # malloc(max * sizeof(int))
  mulli r3, REG_MAX, 4  # max * 4 bytes
  branchl r12, HSD_MemAlloc
  mr REG_POOL, r3
  
  # initialize pool with values 0 to max-1
  li REG_I, 0
  INIT_LOOP:
    cmpw REG_I, REG_MAX
    bge INIT_DONE
    mulli r0, REG_I, 4
    stwx REG_I, REG_POOL, r0  # pool[i] = i
    addi REG_I, REG_I, 1
    b INIT_LOOP
  INIT_DONE:
  
  # shuffle and take first 4
  li REG_I, 0
  SHUFFLE_LOOP:
    cmpwi REG_I, 4
    bge SHUFFLE_DONE
    
    # get random index: HSD_Randi(max - i)
    subf r3, REG_I, REG_MAX  # max - i
    branchl r12, HSD_Randi
    mr REG_RAND_IDX, r3
    
    # result[i] = pool[rand_index]
    mulli r0, REG_RAND_IDX, 4
    lwzx REG_TEMP, REG_POOL, r0
    mulli r0, REG_I, 4
    stwx REG_TEMP, REG_RESULT, r0
    
    # pool[rand_index] = pool[max - 1 - i]
    subf r4, REG_I, REG_MAX  # max - i
    subi r4, r4, 1           # max - 1 - i
    mulli r4, r4, 4          # offset for pool[max-1-i]
    lwzx r5, REG_POOL, r4    # load pool[max-1-i]
    mulli r0, REG_RAND_IDX, 4
    stwx r5, REG_POOL, r0    # store to pool[rand_index]
    
    addi REG_I, REG_I, 1
    b SHUFFLE_LOOP
  SHUFFLE_DONE:
  
  mr r3, REG_POOL
  branchl r12, HSD_Free

EXIT:
  restore
  blr
