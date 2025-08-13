.ifndef HEADER_DATA

.macro table_load_w reg_target, reg_table, table, label
lwz \reg_target,  \label - \table(\reg_table)
.endm

.macro table_load_b reg_target, reg_table, table, label
lbz \reg_target,  \label - \table(\reg_table)
.endm

.macro table_load_h reg_target, reg_table, table, label
lhz \reg_target,  \label - \table(\reg_table)
.endm

.macro table_load_f reg_target, reg_table, table, label
lfs \reg_target,  \label - \table(\reg_table)
.endm

.macro table_load_ptr reg_target, reg_table, table, label
addi \reg_target,  \reg_table, \label - \table
.endm


# bl Code

# ###### Link table ######
# Table: 

# WordConst1: .long 0
# Text1: .string "text1"
# .align 2

# ###### Link table end ######

# Code:

# mflr r12   #load link table pointer to r12
# table_load_w r3, r12, Table, WordConst1   # load word constant 'WordConst1' to r3
# table_load_ptr r4, r12, Table, Text1    # load pointer to 'Text1' string variable to r4

.endif
.set HEADER_DATA, 1
