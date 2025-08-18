.ifndef HEADER_OS

# also putting archive related stuff here

################################################################################
# Functions
################################################################################

.set OS_DisableInterrupts, 0x80347364 #
.set OS_RestoreInterrupts, 0x8034738c # (bool enabled)

.set HSD_ArchiveLoad, 0x80016be0 # (char* path)
.set HSD_ArchiveGetSymbol, 0x80380358 # (HSD_Archive *archive, char *symbol)
.set HSD_Randf, 0x80380528

.set memzero, 0x8000c160

################################################################################
# Structs
################################################################################

# Text - Move this to its own header
.set TEXT_TRANS, 0
.set TEXT_TEXTBOX, TEXT_TRANS + 12
.set TEXT_CLIP_TOP, TEXT_TEXTBOX + 8
.set TEXT_CLIP_BOTTOM, TEXT_CLIP_TOP + 4
.set TEXT_CLIP_LEFT, TEXT_CLIP_BOTTOM + 4
.set TEXT_CLIP_RIGHT, TEXT_CLIP_LEFT + 4
.set TEXT_STRETCH, TEXT_CLIP_RIGHT + 4
.set TEXT_BACKGROUND_CLR, TEXT_STRETCH + 8
.set TEXT_DEFAULT_COLOR, TEXT_BACKGROUND_CLR + 4
.set TEXT_DEFAULT_SCALE, TEXT_DEFAULT_COLOR + 4
.set TEXT_DEFAULT_SPACING, TEXT_DEFAULT_SCALE + 8
.set TEXT_DEFAULT_TYPE_SPEED_CHAR, TEXT_DEFAULT_SPACING + 8
.set TEXT_DEFAULT_TYPE_SPEED_LINE, TEXT_DEFAULT_TYPE_SPEED_CHAR + 2
.set TEXT_DEFAULT_USE_ASPECT, TEXT_DEFAULT_TYPE_SPEED_LINE + 2
.set TEXT_DEFAULT_KERNING, TEXT_DEFAULT_USE_ASPECT + 1
.set TEXT_DEFAULT_ALIGN, TEXT_DEFAULT_KERNING + 1
.set TEXT_DEPTH_TEST, TEXT_DEFAULT_ALIGN + 2
.set TEXT_HIDDEN, TEXT_DEPTH_TEST + 1
.set TEXT_USE_CLIPPING, TEXT_HIDDEN + 1
.set TEXT_SIS_ID, TEXT_USE_CLIPPING + 1
.set TEXT_NEXT, TEXT_SIS_ID + 1
.set TEXT_GOBJ, TEXT_NEXT + 4
.set TEXT_CALLBACK, TEXT_GOBJ + 4
.set TEXT_DATA, TEXT_CALLBACK + 4
.set TEXT_FADE_IN_LAST_CHAR, TEXT_DATA + 4
.set TEXT_SUBTEXT_DATA, TEXT_FADE_IN_LAST_CHAR + 4
.set TEXT_SUBTEXT_START, TEXT_SUBTEXT_DATA + 4
.set TEXT_SUBTEXT_OFFSET, TEXT_SUBTEXT_START + 4
.set TEXT_SUBTEXT_SIZE, TEXT_SUBTEXT_OFFSET + 2
.set TEXT_OFFSET, TEXT_SUBTEXT_SIZE + 2
.set TEXT_SPACING, TEXT_OFFSET + 8
.set TEXT_SCALE, TEXT_SPACING + 8
.set TEXT_FIT_SCALE, TEXT_SCALE + 8
.set TEXT_COLOR, TEXT_FIT_SCALE + 4
.set TEXT_TYPE_SPEED_CHAR, TEXT_COLOR + 4
.set TEXT_TYPE_SPEED_LINE, TEXT_TYPE_SPEED_CHAR + 2
.set TEXT_FADE_IN_TIME, TEXT_TYPE_SPEED_LINE + 2
.set TEXT_TYPE_INDEX, TEXT_FADE_IN_TIME + 4
.set TEXT_FITTING, TEXT_TYPE_INDEX + 4
.set TEXT_KERNING, TEXT_FITTING + 1
.set TEXT_ALIGN, TEXT_KERNING + 1

################################################################################
# Directives
################################################################################

.endif
.set HEADER_OS, 1
