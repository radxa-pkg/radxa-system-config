#!/bin/sh

# Following environment variables are needed for
# gstreamer to decode 10-bit H.265 video
export GST_MPP_NO_RGA=0
export GST_MPP_DEC_DISABLE_NV12_10=1
