.ifndef HEADER_HSD_PAD
# .include "Common/Common.s"

################################################################################
# Functions
################################################################################



################################################################################
# Struct
################################################################################

.set HSD_PadStatus, 0x804c1fac
.set HSD_PadGameStatus, 0x804c21cc
.set HSD_PadSize, 0x44

.set PAD_buttons, 0
.set PAD_last_button, PAD_buttons + 4
.set PAD_button_pressed, PAD_last_button + 4
.set PAD_button_repeated, PAD_button_pressed + 4
.set PAD_button_released, PAD_button_repeated + 4
.set PAD_repeat_count, PAD_button_released + 4
.set PAD_raw_stick_x, PAD_repeat_count + 4
.set PAD_raw_stick_y, PAD_raw_stick_x + 1
.set PAD_raw_cstick_x, PAD_raw_stick_y + 1
.set PAD_raw_cstick_y, PAD_raw_cstick_x + 1
.set PAD_raw_trigger_x, PAD_raw_cstick_y + 1
.set PAD_raw_trigger_y, PAD_raw_trigger_x + 1
.set PAD_raw_trigger_a, PAD_raw_trigger_y + 1
.set PAD_raw_trigger_b, PAD_raw_trigger_a + 1
.set PAD_stick_x, PAD_raw_trigger_b + 1
.set PAD_stick_y, PAD_stick_x + 4
.set PAD_cstick_x, PAD_stick_y + 4
.set PAD_cstick_y, PAD_cstick_x + 4
.set PAD_trigger_x, PAD_cstick_y + 4
.set PAD_trigger_y, PAD_trigger_x + 4
.set PAD_trigger_a, PAD_trigger_y + 4
.set PAD_trigger_b, PAD_trigger_a + 4
.set PAD_cross_dir, PAD_trigger_b + 4
.set PAD_err, PAD_cross_dir + 1
.set PAD_padding, PAD_err + 1

################################################################################
# ENUMS
################################################################################

.set PAD_BTN_DPadLeft,	    1
.set PAD_BTN_DPadRight,	    2
.set PAD_BTN_DPadDown,	    4
.set PAD_BTN_DPadUp,	    8
.set PAD_BTN_Z,	            16
.set PAD_BTN_R,	            32
.set PAD_BTN_L,	            64
.set PAD_BTN_A,	            256
.set PAD_BTN_B,	            512
.set PAD_BTN_X,	            1024
.set PAD_BTN_Y,	            2048
.set PAD_BTN_Start,	        4096
.set PAD_BTN_StickUp,	    65536
.set PAD_BTN_StickDown,	    131072
.set PAD_BTN_StickLeft,	    262144
.set PAD_BTN_StickRight,	524288
.set PAD_BTN_CStickUp,	    1048576
.set PAD_BTN_CStickDown,	2097152
.set PAD_BTN_CStickLeft,	4194304
.set PAD_BTN_CStickRight,	8388608
.set PAD_BTN_AnalogLR,	    2147483648
.set PAD_BTN_Confirm,	    4294967296
.set PAD_BTN_Cancel,	    8589934592
.set PAD_BTN_LRAStart,	    17179869184
.set PAD_BTN_AnyUp,	        68719476736
.set PAD_BTN_AnyDown,	    137438953472
.set PAD_BTN_AnyLeft,	    274877906944
.set PAD_BTN_AnyRight,	    549755813888


################################################################################
# Macros
################################################################################

.macro get_port_pad reg
    .set pad_master, 5
    load pad_master, HSD_PadStatus
    mulli \reg, \reg, HSD_PadSize
    add \reg, \reg, pad_master
.endm

.macro get_port_gamepad reg
    .set pad_master, 5
    load pad_master, HSD_PadGameStatus
    mulli \reg, \reg, HSD_PadSize
    add \reg, \reg, pad_master
.endm

.macro stick_curve input_x, input_y
    fmuls f0, \input_x, \input_x
    fmuls \input_x, f0, \input_x
    fmuls f0, \input_y, \input_y
    fmuls \input_y, f0, \input_y
.endm

.endif
.set HEADER_HSD_PAD, 1
