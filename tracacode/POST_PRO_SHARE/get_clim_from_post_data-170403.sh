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
PRE_DIR=\"/home/yangsong3/L_Zealot/data-mirror/data-model/CESM_CTRL/F2000_F19_CAM4_CTRL/pro/\"

# Path of the post processed data
PRO_DIR=\"/home/yangsong3/L_Zealot/project/POST_PRO_SHARE/clim_mon_data/F2000_F19_CAM4_CTRL/\"

# Case name
CASENAME=\"CTRL\"


# Names of 2D fields
#FDNAME2D="(/\"PRECT\",\"FLUT\"/)" #often use
FDNAME2D="(/\"TS\",\"PRECL\",\"PRECC\"/)" #often use

# Names of 3D fields
#FDNAME3D="(/\"U\",\"V\"/)" #often use
FDNAME3D="(/\"U\",\"V\",\"T\",\"OMEGA\",\"Q\",\"RELHUM\",\"Z3\"/)" #often use
#FDNAME3D="(/\"U\",\"T\",\"Z3\"/)" #often use

# Names of 3D HY fields
#FDNAME3D_HY="(/\"U\",\"V\",\"T\",\"OMEGA\",\"Q\",\"RELHUM\",\"Z3\",\"DTCOND\"/)" # hybrid coordinate

# First year of the subset
FRSTYEAR=1

# Spin-up years, if=5, skip the first 5 years in the model
SPIN_YEAR=5

# Last year of the subset
LSTYEAR=110

# Process fig flag
FLAG2D=1
FLAG3D=1
FLAG3DHY=0

#-----------------------------------------------------------

#Output post processed 2D fields
if  [ $FLAG2D == 1 ] ; then
ncl -nQ pre_dir=$PRE_DIR            \
    pro_dir=$PRO_DIR            \
    fdname2d=$FDNAME2D          \
    frstyear=$FRSTYEAR          \
    spinyear=$SPIN_YEAR         \
    lstyear=$LSTYEAR            \
    case_name=$CASENAME         \
    ./ncl/get_2D_clim_from_post_data-170403.ncl
fi
#Output post processed 3D fields
if  [ $FLAG3D == 1 ] ; then
ncl -nQ pre_dir=$PRE_DIR            \
    pro_dir=$PRO_DIR            \
    fdname3d=$FDNAME3D          \
    frstyear=$FRSTYEAR          \
    spinyear=$SPIN_YEAR         \
    lstyear=$LSTYEAR            \
    case_name=$CASENAME         \
    ./ncl/get_3D_clim_from_post_data-170403.ncl
fi

##Output post processed 3D fields
if  [ $FLAG3DHY == 1 ] ; then
ncl pre_dir=$PRE_DIR            \
    pro_dir=$PRO_DIR            \
    fdname3d=$FDNAME3D_HY       \
    frstyear=$FRSTYEAR          \
    lstyear=$LSTYEAR            \
    case_name=$CASENAME         \
    ./ncl/take_3D_hybrid_from_raw_data-150921.ncl
fi

