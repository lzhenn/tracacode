#!/bin/sh
#-----------------------------------------------
#   This is a shell script for calculating the
# climatology from post-processed data, You 
# should set the basic parameters as below. 
# Good Luck!
#               Last Modified on  2015-09-21
#               Last Modified on  2017-04-03
#               A L_Zealot Product
#-----------------------------------------------

# Path of the original data
# Caution: DO NOT DELETE /" IN STRING!
# With only ensemble output in it
PRE_DIR_ORG=\"/home/yangsong3/data/observation/ERA-interim/pressure/air/\"

PRO_DIR_ORG=\"/home/yangsong3/data/observation/ERA-interim/pressure/daily-clim/\"

FDNAME=\"air\" #often use

#-----------------------------------------------------------


#Output post processed 2D fields
ncl -nQ pre_dir=$PRE_DIR        \
    pro_dir=$PRO_DIR          \
    fdname=$FDNAME          \
    ./ncl/170614-extract-daily-clim-obv.ncl

