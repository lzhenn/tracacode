#!/bin/sh
source /home/yhuangci/bashrc_intel_amd
./clean -a
export WRF_CMAQ=1
export wrf_path=/home/lzhenn/array74/tracacode/2209-yeq-BB/CMAQ2way-revised/cmaq2way
./wrfcmaq_twoway_coupler/assemble
./configure

