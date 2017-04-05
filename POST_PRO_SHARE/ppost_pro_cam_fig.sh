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
PRO_CTRL_DIR=\"/home/yangsong3/L_Zealot/data-mirror/data-model/L_Zealot/POST_SCRATCH-2017/ctrl/\"

# CTRL Case name
CTRL_CASENAME=\"as-bob-test\"


# Path of the post processed data
PRO_SEN_DIR=\"/home/yangsong3/L_Zealot/data-mirror/data-model/L_Zealot/POST_SCRATCH-2017/sen/\"

# SEN case name
SEN_CASENAME=\"as-bob-test\"

# Path of outfig
FIG_PATH=\"/home/yangsong3/L_Zealot/project/POST_PRO_SHARE/scrach_fig/\"



# CTRL TIME BOUND
# History file first year
FFRSTYEAR=1

# History file last year
FLSTYEAR=15

# Subset first year
SUB_FRSTYEAR=6

# Subset last year
SUB_LSTYEAR=15


# SEN TIME BOUND
# History file first year
SEN_FFRSTYEAR=1

# History file last year
SEN_FLSTYEAR=15

# Subset first year
SEN_SUB_FRSTYEAR=6

# Subset last year
SEN_SUB_LSTYEAR=15



# Draw flags
ANN_TS_FLAG=0
SNN_TS_FLAG=1

ANN_PR_U850_FLAG=0
SNN_PR_U850_FLAG=1



# Range of the map, R_FLAG: regional flag, 1 for regional
R_FLAG=1

#-----------------------------------------------------------

if  [ $R_FLAG == 1 ] ; then
#EA
    LATS=-0.
    LATN=45.
    LONW=30.
    LONE=100.
#EQ BAND
#    LATS=-30.
#    LATN=30.
#    LONW=0.
#    LONE=360.

else
    LATS=-90.
    LATN=90.
    LONW=0.
    LONE=360.
fi

#       ----    ann ts, with sig    (1)
if [ $ANN_TS_FLAG == 1 ] ; then
    echo "-----ann ts, with sig    (1)-----"
    ncl -nQ \
        pro_ctrl_dir=$PRO_CTRL_DIR              \
        ctrl_casename=$CTRL_CASENAME            \
        pro_sen_dir=$PRO_SEN_DIR                \
        sen_casename=$SEN_CASENAME              \
        ffrstyear=$FFRSTYEAR                    \
        flstyear=$FLSTYEAR                      \
        sub_frstyear=$SUB_FRSTYEAR              \
        sub_lstyear=$SUB_LSTYEAR                \
        sen_ffrstyear=$SEN_FFRSTYEAR            \
        sen_flstyear=$SEN_FLSTYEAR              \
        sen_sub_frstyear=$SEN_SUB_FRSTYEAR      \
        sen_sub_lstyear=$SEN_SUB_LSTYEAR        \
        lats=$LATS                              \
        latn=$LATN                              \
        lonw=$LONW                              \
        lone=$LONE                              \
        fig_path=$FIG_PATH                      \
        ./ncl/draw_diff-annual-TS_SEN-CTRL-20160113.ncl
fi

#       ----    ann ts, with sig    (4)
if [ $SNN_TS_FLAG == 1 ] ; then
    echo "-----ann ts, with sig    (4)-----"
    ncl -nQ \
        pro_ctrl_dir=$PRO_CTRL_DIR              \
        ctrl_casename=$CTRL_CASENAME            \
        pro_sen_dir=$PRO_SEN_DIR                \
        sen_casename=$SEN_CASENAME              \
        ffrstyear=$FFRSTYEAR                    \
        flstyear=$FLSTYEAR                      \
        sub_frstyear=$SUB_FRSTYEAR              \
        sub_lstyear=$SUB_LSTYEAR                \
        sen_ffrstyear=$SEN_FFRSTYEAR            \
        sen_flstyear=$SEN_FLSTYEAR              \
        sen_sub_frstyear=$SEN_SUB_FRSTYEAR      \
        sen_sub_lstyear=$SEN_SUB_LSTYEAR        \
        lats=$LATS                              \
        latn=$LATN                              \
        lonw=$LONW                              \
        lone=$LONE                              \
        fig_path=$FIG_PATH                      \
        ./ncl/draw_diff-season-TS_SEN-CTRL-20170403.ncl
fi
#       ----    ann uv850 + pr, with sig    (1)
if [ $ANN_PR_U850_FLAG == 1 ] ; then
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
        sen_ffrstyear=$SEN_FFRSTYEAR            \
        sen_flstyear=$SEN_FLSTYEAR              \
        sen_sub_frstyear=$SEN_SUB_FRSTYEAR      \
        sen_sub_lstyear=$SEN_SUB_LSTYEAR        \
        lats=$LATS                              \
        latn=$LATN                              \
        lonw=$LONW                              \
        lone=$LONE                              \
        fig_path=$FIG_PATH                      \
        ./ncl/draw_diff-annual-850UV_Pr_SEN-CTRL-20160113.ncl
fi


#       ----    SSN UV850 + Pr, with sig    (4)
if [ $SNN_PR_U850_FLAG == 1 ] ; then
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
        sen_ffrstyear=$SEN_FFRSTYEAR            \
        sen_flstyear=$SEN_FLSTYEAR              \
        sen_sub_frstyear=$SEN_SUB_FRSTYEAR      \
        sen_sub_lstyear=$SEN_SUB_LSTYEAR        \
        lats=$LATS                              \
        latn=$LATN                              \
        lonw=$LONW                              \
        lone=$LONE                              \
        fig_path=$FIG_PATH                      \
        ./ncl/draw_diff-season-850UV_Pr_SEN-CTRL-20151127.ncl
fi
echo "**************Post-post Processing Done!!!****************"
