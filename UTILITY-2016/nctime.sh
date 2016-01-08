#!/bin/sh

NC=\"`pwd`/$1\" #for the nc filename
SCRIPT_DIR=/home/yangsong3/L_Zealot/project/UTILITY-2016/ncl

# -n no line number
# -Q no copyright info
ncl -nQ nc=$NC $SCRIPT_DIR/take_nc_time-20160108.ncl 
