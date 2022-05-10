#!/bin/sh
#-----------------------------------------------
#   This is a shell script for configuring the
# basic post processing tool of CAM model, You 
# should set the basic parameters as below. 
# Good Luck!
#               Last Modified on  2015-09-21
#               A L_Zealot Product
#-----------------------------------------------

# Path of the original data
# Caution: DO NOT DELETE \" IN STRING!
PRE_DIR=\"/home/lzhenn/array/lzhenn/data/CONV_MON_WRK-2018/REAL_WORLD_SCYC/\"
#PRE_DIR=\"/HOME/sysu_hjkx_ys/WORKSPACE/data/model/L_Zealot/SCS_ANNCYC-2015/pre/B2000_f09_CAM5PM_SCS_ANNCYC/\"

# Path of the post processed data
PRO_DIR=\"/home/lzhenn/array/lzhenn/data/CONV_MON_WRK-2018/REAL_WORLD_SCYC/pro/\"

# Case name
CASENAME=\"B20f19-realworld\"


# Names of 3D fields need to be extracted
FDNAME2D="(/\"U\",\"V\"/)" #often use
#FDNAME3D="(/\"U\",\"T\",\"Z3\"/)" #often use


# Layers of 3D fields
# CAM4 = 26; CAM5 = 30
LAYERS=26

# First year of the subset
FRSTYEAR=1

# Last year of the subset
LSTYEAR=100

#-----------------------------------------------------------

#Output post processed 2D fields
ncl pre_dir=$PRE_DIR            \
    pro_dir=$PRO_DIR            \
    fdname2d=$FDNAME2D          \
    frstyear=$FRSTYEAR          \
    lstyear=$LSTYEAR            \
    case_name=$CASENAME         \
    layers=$LAYERS              \
    ./ncl/take_2D_lowest_var-160120.ncl
