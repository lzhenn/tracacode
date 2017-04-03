#!/bin/sh
#-----------------------------------------------
#   This is a shell script for configuring the
# basic p-post processing tool of CAM model, 
# You should set the basic parameters as below. 
# 
# Good Luck!
#
# Basic Figures
#
#   --------THIS IS FOR CLIMATOLOGY!!!---------
#
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
PRO_CTRL_DIR=\"/home/yangsong3/L_Zealot/data-mirror/model/SPCAM-TEST-2016/SP_AMIP/\"

# CTRL Case name
CTRL_CASENAME=\"SP_AMIP\"

# CTRL data in one bulk file or severial files, 0 for files
CTRL_PFILE=1

# History pfile first year, set when when CTRL_PFILE=1
FFRSTYEAR=1979

# History pfile last year, set when CTRL_PFILE=1
FLSTYEAR=2005


#**************************FIGURE SETTINGS**************************
# Path of outfig
FIG_PATH=\"/home/yangsong3/L_Zealot/project/POST_PRO_SHARE/scrach_fig/\"


# Range of the map, R_FLAG: regional flag, 1 for regional
R_FLAG=1

# Draw flags
ANN_PR_FLAG=1
SNN_PR_FLAG=1


#**************************PROCESS SETTINGS**************************

if  [ $R_FLAG == 1 ] ; then
#Asia
    LATS=-30.
    LATN=45.
    LONW=60.
    LONE=180.
#MC
#    LATS=-30.
#    LATN=30.
#    LONW=80.
#    LONE=150.

#MC
    LATS=-30.
    LATN=30.
    LONW=0.
    LONE=360.


    
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
    echo "-----SSN UV850 + Pr    (4)-----"
    ncl -nQ \
        pro_ctrl_dir=$PRO_CTRL_DIR              \
        ctrl_casename=$CTRL_CASENAME            \
        pro_sen_dir=$PRO_SEN_DIR                \
        sen_casename=$SEN_CASENAME              \
        ffrstyear=$FFRSTYEAR                    \
        flstyear=$FLSTYEAR                      \
        sub_frstyear=$SUB_FRSTYEAR              \
        sub_lstyear=$SUB_LSTYEAR                \
        lats=$LATS                              \
        latn=$LATN                              \
        lonw=$LONW                              \
        lone=$LONE                              \
        fig_path=$FIG_PATH                      \
        ./ncl/draw_diff-season-850UV_Pr_SEN-CTRL-20151127.ncl

fi


