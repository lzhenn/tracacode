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
# Caution: DO NOT DELETE /" IN STRING!
PRE_DIR=/users/yangsong3/L_Zealot/B/DATA_B20f19-spun-up/
#PRE_DIR=\"/HOME/sysu_hjkx_ys/WORKSPACE/data/model/L_Zealot/SCS_ANNCYC-2015/pre/B2000_f09_CAM5PM_SCS_ANNCYC/\"

# Path of the post processed data
PRO_DIR=\"/users/yangsong3/L_Zealot/B/DATA_B20f19-spun-up/pro/hybrid/\"

# Case name
CASENAME=\"B20f19-spun-up\"

# ESM folder prefix
ESM_NAME=ESM_off_eq_

# ESM folder memebers
ESM_STRT=1

# ESM folder memebers
ESM_LAST=6

# Names of 2D fields
#FDNAME2D="(/\"PRECT\",\"FLUT\"/)" #often use
FDNAME2D="(/\"TS\",\"PRECC\",\"PRECL\"/)" #often use

# Names of 3D fields
FDNAME3D="(/\"U\",\"V\",\"T\",\"Z3\"/)" #often use
#FDNAME3D="(/\"U\",\"V\",\"T\",\"OMEGA\",\"Q\",\"RELHUM\",\"Z3\"/)" #often use
#FDNAME3D="(/\"U\",\"T\",\"Z3\"/)" #often use

# Names of 3D HY fields
FDNAME3D_HY="(/\"U\",\"V\"/)" # hybrid coordinate

# Layers of 3D fields
# CAM4 = 26; CAM5 = 30
LAYERS=26

# Output specific pressure layers
# CAUTION: Do not leave species between element!
PLEV="(/1000,925,850,700,600,500,400,300,200,100/)"
#PLEV="(/500,300,200/)"

# First year of the subset
FRSTYEAR=252

# Last year of the subset
LSTYEAR=253

# Process fig flag
FLAG2D=1
FLAG3D=1
FLAG3DHY=1

#-----------------------------------------------------------
for II in `seq $ESM_STRT $ESM_LAST`
do
    FULL_PRE_DIR=\"${PRE_DIR}${ESM_NAME}${II}/\"
    OUT_NAME=\"${ESM_NAME}${II}\"
    echo "ESM $II is under processing..."
    #Output post processed 2D fields
    if  [ $FLAG2D == 1 ] ; then
    ncl -nQ pre_dir=$FULL_PRE_DIR       \
        pro_dir=$PRO_DIR            \
        fdname2d=$FDNAME2D          \
        frstyear=$FRSTYEAR          \
        lstyear=$LSTYEAR            \
        case_name=$CASENAME         \
        out_name=$OUT_NAME         \
        ./ncl/take_2D_esm_from_raw_data-161204.ncl
    fi
    #Output post processed 3D fields
    if  [ $FLAG3D == 1 ] ; then
    ncl -nQ pre_dir=$FULL_PRE_DIR       \
        pro_dir=$PRO_DIR            \
        fdname3d=$FDNAME3D          \
        layers=$LAYERS              \
        plev=$PLEV                  \
        frstyear=$FRSTYEAR          \
        lstyear=$LSTYEAR            \
        case_name=$CASENAME         \
        out_name=$OUT_NAME         \
        ./ncl/take_3D_esm_from_raw_data-grads-161204.ncl
    fi

    ##Output post processed 3D fields
    if  [ $FLAG3DHY == 1 ] ; then
    ncl -nQ pre_dir=$FULL_PRE_DIR       \
        pro_dir=$PRO_DIR            \
        fdname3d=$FDNAME3D_HY       \
        frstyear=$FRSTYEAR          \
        lstyear=$LSTYEAR            \
        case_name=$CASENAME         \
        out_name=$OUT_NAME         \
        ./ncl/take_3D_hybrid_esm_from_raw_data-170330.ncl
    fi
done
