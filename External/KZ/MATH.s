.ifndef HEADER_MATH
.include "Common/Common.s"

################################################################################
# Math Functions
################################################################################

.set    tanf, 0x8000cee0
.set    tan, 0x803261bc
.set    atan2, 0x80022c30
.set    acos, 0x80022d1c

.set		shl2i, 0x80322d30

################################################################################
# MTX Functions
################################################################################

.set    makeProjectionMtx, 0x80367b68
.set    GXGetProjectionv, 0x80341390
.set    HSD_MtxInverseConcat, 0x80379598

.set    PSMTXConcat, 0x80342204
.set    PSMTXMultVec, 0x80342aa8
.set    PSMTXMultVecSR, 0x80342afc
.set    PSMTXInverse, 0x80342320
.set    PSMTXRotAxisRad, 0x80342530
.set    PSMTXMultVec, 0x80342aa8
.set    PSMTXCopy, 0x803421d0

.set    MTXPerspective, 0x80342bec
.set    MTXLookAt, 0x80342734

.set    HSD_MtxAlloc, 0x8037a68c

################################################################################
# Vector Functions
################################################################################

.set    PSVECAdd, 0x80342d54
.set    PSVECCrossProduct, 0x80342e58
.set    PSVECDotProduct, 0x80342e38
.set    PSVECMag, 0x80342dfc
.set    PSVECNormalize, 0x80342db8
.set    PSVECScale, 0x80342d9c
.set    PSVECSubtract, 0x80342d78

.set    VectorRotate, 0x8000db00
.set    VectorAdd, 0x8000d46c
.set    VectorSubtract, 0x8000d4f8

################################################################################
# Macros
################################################################################

# Macro to get row/column of a matrix
# Usage: get_row_col <mtx_reg> <row_reg> <col_reg> <return reg>
.macro get_row_col mtx, row, col, ret
	mulli \row, \row, 0x10
	add \ret, \mtx, \row
	mulli \col, \col, 0x04
	add \ret, \ret, \col
.endm

.macro mtx_rowcol_ofst row, col, ret
	mulli \row, \row, 16
	mulli \col, \col, 4
	add \ret, \row, \col
.endm

# t = (current_frame - start_frame) / (end_frame - start_frame);
.macro lerp_get_t start, end, current, result
	fsubs \result, \current, \start
	fsubs f0, \end, \start
	fdivs \result, \result, f0
.endm

# t = (current_frame - start_frame) / (end_frame - start_frame);
.macro lerp_get_t_int start, end, current, result
	sub \result, \current, \start
	sub r0, \end, \start
	divw \result, \result, r0
.endm

# start + t * (end - start)
.macro lerp start, end, t, result
	fsubs f0, \end, \start
	fmuls f0, f0, \t
	fadds \result, \start, f0
.endm

# start + t * (end - start)
.macro lerp_int start, end, t, result
	sub r0, \end, \start
	mullw r0, \t, r0
	add \result, \start, r0
.endm



################################################################################
# Directives
################################################################################

.set X, 0
.set Y, 4
.set Z, 8
.set W, 12

.set SZ_VEC3, 12
.set SZ_MTX34, 48
.set SZ_MTX44, 64


################################################################################
# Structs
################################################################################

# frustum planes
.set NEAR_TL, 0
.set NEAR_TR, NEAR_TL + SZ_VEC3
.set NEAR_BL, NEAR_TR + SZ_VEC3
.set NEAR_BR, NEAR_BL + SZ_VEC3
.set FAR_TL, 	NEAR_BR + SZ_VEC3
.set FAR_TR, 	FAR_TL + SZ_VEC3
.set FAR_BL, 	FAR_TR + SZ_VEC3
.set FAR_BR, 	FAR_BL + SZ_VEC3




.endif
.set HEADER_MATH, 1
