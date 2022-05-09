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
#PRE_DIR=\"/HOME/sysu_hjkx_ys/WORKSPACE/L_Zealot/cesm/B/B2000_f09_CAM5_spin-up/run/\"
PRE_DIR=\"/home/yangsong3/data/model/CESM_CTRL/B2000_F19G16_CAM4_CTRL/pre/\"

# Path of the post processed data
PRO_DIR=\"/home/yangsong3/L_Zealot/temp/\"

# Case name
CASENAME=\"B2000_f19g16_CP_CTRL\"


# Names of 2D fields
#FDNAME2D="(/\"PRECL\",\"PRECC\",\"LHFLX\",\"PS\",\"PSL\",\"QFLX\",\"TS\",\"TMQ\"/)" #often use

# Names of 3D fields
#FDNAME3D="(/\"U\",\"V\",\"T\",\"OMEGA\",\"Q\",\"RELHUM\",\"Z3\"/)" #often use
FDNAME3D="(/\"Z3\"/)" #often use

#FDNAME3D_HY="(/\"U\",\"V\",\"T\",\"OMEGA\",\"Q\",\"RELHUM\",\"Z3\",\"DTCOND\"/)" # hybrid coordinate

# Layers of 3D fields
# CAM4 = 26; CAM5 = 30
LAYERS=26

# Output specific pressure layers
# CAUTION: Do not leave species between element!
#PLEV="(/925,850,700,600,500,400,300,200,100,50/)"
PLEV="(/925,850,700,500,200/)"

# First year of the subset
FRSTYEAR=250

# Last year of the subset
LSTYEAR=255

# Process fig flag
#FIGFLAG=FALSE

#-----------------------------------------------------------

##Output post processed 2D fields
#ncl pre_dir=$PRE_DIR            \
#    pro_dir=$PRO_DIR            \
#    fdname2d=$FDNAME2D          \
#    frstyear=$FRSTYEAR          \
#    lstyear=$LSTYEAR            \
#    case_name=$CASENAME         \
#    ./ncl/take_2D_from_raw_data-150921.ncl
#
#Output post processed 3D fields
ncl pre_dir=$PRE_DIR            \
    pro_dir=$PRO_DIR            \
    fdname3d=$FDNAME3D          \
    layers=$LAYERS              \
    plev=$PLEV                  \
    frstyear=$FRSTYEAR          \
    lstyear=$LSTYEAR            \
    case_name=$CASENAME         \
    ./ncl/take_3D_from_raw_data-grads-151114.ncl


##Output post processed 3D fields
#ncl pre_dir=$PRE_DIR            \
#    pro_dir=$PRO_DIR            \
#    fdname3d=$FDNAME3D_HY       \
#    frstyear=$FRSTYEAR          \
#    lstyear=$LSTYEAR            \
#    case_name=$CASENAME         \
#    ./ncl/take_3D_hybrid_from_raw_data-150921.ncl
#

