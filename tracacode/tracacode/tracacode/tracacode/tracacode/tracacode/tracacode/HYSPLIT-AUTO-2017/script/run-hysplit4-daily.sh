#!/bin/bash

#-----------------------------------------------
#   This is a shell script for automatically run
# the hysplit model every day. Good Luck!
#
# 2016-11-21 Created
#
#                      A L_Zealot Product
#-----------------------------------------------

# WRFOUT dir
WRFOUT=/disk/hq247/yhuangci/cmaq-run/data/wrf-fc

# WRFOUT PREFIX
WRFPRE=wrfout_d03_

# Point List
PTLIST_FILE=ptlist.txt

# Backward Flag 1--backward 0--foreward
BGFG=1

# Height
HGT=150

# Runtime (hr)
RTIME=72

rm -rf ./wrf-link/*

python run-hysplit4-daily.py $WRFOUT $PTLIST_FILE $BGFG $HGT $RTIME $WRFPRE

