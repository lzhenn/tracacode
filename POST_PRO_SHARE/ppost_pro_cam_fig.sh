#!/bin/sh
#-----------------------------------------------
#   This is a shell script for configuring the
# basic p-post processing tool of CAM model, 
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
#               Last Modified on  2016-01-13
#               A L_Zealot Product
#-----------------------------------------------

echo "**************Post-post Processing Start******************"
echo "  "

# Path of the original data
# Caution: DO NOT DELETE \" IN STRING!
#PRE_DIR=\"/HOME/sysu_hjkx_ys/WORKSPACE/L_Zealot/cesm/B/B2000_f09_CAM5_spin-up/run/\"
PRO_CTRL_DIR=\"/home/yangsong3/data/model/CESM_CTRL/B2000_F09G16_CAM5PM_CTRL/pro/\"

# CTRL Case name
CTRL_CASENAME=\"B2000_f09_CAM5PM_spin-up\"


# Path of the post processed data
PRO_SEN_DIR=\"/home/yangsong3/L_Zealot/data-mirror/model/SCS_ANNCYC-2015/pro/\"

# SEN case name
SEN_CASENAME=\"B2000_f09_CAM5PM_SCS_ANNCYC\"

# Path of outfig
FIG_PATH=\"/home/yangsong3/L_Zealot/project/SCS_ANNCYC-2015/fig/auto-fig\"

# History file first year
FFRSTYEAR=201

# History file last year
FLSTYEAR=250

# Subset first year
SUB_FRSTYEAR=201

# Subset last year
SUB_LSTYEAR=250

# Range of the map, R_FLAG: regional flag, 1 for regional
R_FLAG=0

#-----------------------------------------------------------

if  [ $R_FLAG == 1 ] ; then
#EA
    LATS=-5.
    LATN=45.
    LONW=90.
    LONE=160.
else
    LATS=-90.
    LATN=90.
    LONW=0.
    LONE=360.
fi

#       ----    ann ts, with sig    (1)
echo "-----ann ts, with sig    (1)-----"
ncl -nQ \
    pro_ctrl_dir=$PRO_CTRL_DIR              \
    ctrl_casename=$CTRL_CASENAME            \
    pro_sen_dir=$PRO_SEN_DIR                \
    sen_casename=$SEN_CASENAME              \
    ffrstyear=$FFRSTYEAR                    \
    flstyear=$FLSTYEAR                    \
    sub_frstyear=$SUB_FRSTYEAR              \
    sub_lstyear=$SUB_LSTYEAR               \
    lats=$LATS                              \
    latn=$LATN                              \
    lonw=$LONW                              \
    lone=$LONE                              \
    fig_path=$FIG_PATH                      \
    ./ncl/draw_diff-annual-TS_SEN-CTRL-20160113.ncl

exit 0

#       ----    ann uv850 + pr, with sig    (1)
echo "-----ann uv850 + pr, with sig    (1)-----"
ncl -nQ \
    pro_ctrl_dir=$PRO_CTRL_DIR              \
    ctrl_casename=$CTRL_CASENAME            \
    pro_sen_dir=$PRO_SEN_DIR                \
    sen_casename=$SEN_CASENAME              \
    ffrstyear=$FFRSTYEAR              \
    flstyear=$FLSTYEAR                    \
    sub_frstyear=$SUB_FRSTYEAR \
    sub_lstyear=$SUB_LSTYEAR             \
    lats=$LATS                              \
    latn=$LATN                              \
    lonw=$LONW                              \
    lone=$LONE                              \
    fig_path=$FIG_PATH                      \
    ./ncl/draw_diff-annual-850UV_Pr_SEN-CTRL-20160113.ncl



#       ----    SSN UV850 + Pr, with sig    (4)
echo "-----SSN UV850 + Pr, with sig    (4)-----"
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

echo "**************Post-post Processing Done!!!****************"
