#!/bin/sh
#-----------------------------------------------
#   This is a shell script for configuring the
# basic p-post processing tool of CAM model, 
# especially for the runtime plotting.
# You should set the basic parameters as below. 
# 
# Good Luck!
#
# Basic Figures
#    ANN-->Annual Mean, SSN-->Season Mean
#
#       ----    ANN UV850 + Pr, with sig    (1)
#       ----    SSN UV850 + Pr, with sig    (4)
#       ----    ANN TS, with sig            (1)
#       ----    SSN TS, with sig            (4)
#       ----    ANN PSL, with sig           (1)
#       ----    SSN PSL, with sig           (4)
#
#
#               Last Modified on  2016-01-16
#               A L_Zealot Product
#-----------------------------------------------

echo "**************Post-post Processing Start******************"
echo "  "

# Path of the original data
# Caution: DO NOT DELETE \" IN STRING!

#**************************CTRL SETTINGS**************************
#PRE_DIR=\"/HOME/sysu_hjkx_ys/WORKSPACE/L_Zealot/cesm/B/B2000_f09_CAM5_spin-up/run/\"
PRO_CTRL_DIR=\"/Users/zhenningli/project/POST_PRO_SHARE/clim_mon_data/F2000_F19_CAM4_CTRL/\"

# CTRL Case name
CTRL_CASENAME=\"CTRL\"


#**************************SEN SETTINGS**************************
# Path of the post processed data
PRO_SEN_DIR=\"/users/yangsong3/L_Zealot/F/as-bob-test/exe/\"

# SEN case name
SEN_CASENAME=\"as-bob-test\"

# Subset first year in SEN
SEN_FRSTYEAR=1

# Subset last year in SEN
SEN_LSTYEAR=15



#**************************FIGURE SETTINGS**************************
# Path of outfig
FIG_PATH=\"/Users/zhenningli/project/POST_PRO_SHARE/scrach_fig/\"


# Range of the map, R_FLAG: regional flag, 1 for regional
R_FLAG=1

# Draw flags
ANN_TS_FLAG=0
SNN_TS_FLAG=0

SNN_PR_FLAG=1


#**************************PROCESS SETTINGS**************************

if  [ $R_FLAG == 1 ] ; then
#EA
    LATS=-30.
    LATN=45.
    LONW=60.
    LONE=180.
else
    LATS=-90.
    LATN=90.
    LONW=0.
    LONE=360.
fi


#********************************************************************
#--------------------------ACTION NOW!-------------------------------
#********************************************************************

#       ----    ann uv850 + pr, with sig    (1)
if [ $SNN_PR_FLAG == 1 ] ; then
    echo "-----season pr, with sig    (4)-----"
    ncl -nQ \
        pro_ctrl_dir=$PRO_CTRL_DIR              \
        ctrl_casename=$CTRL_CASENAME            \
        pro_sen_dir=$PRO_SEN_DIR                \
        sen_casename=$SEN_CASENAME              \
        sen_frstyear=$SEN_FRSTYEAR              \
        sen_lstyear=$SEN_LSTYEAR               \
        lats=$LATS                              \
        latn=$LATN                              \
        lonw=$LONW                              \
        lone=$LONE                              \
        fig_path=$FIG_PATH                      \
        ./ncl/quickplot_diff-season-850UV_Pr_SEN-CTRL-clim-20170403.ncl
fi

echo "**************Post-post Processing Done!!!****************"
