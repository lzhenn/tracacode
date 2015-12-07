#!/bin/sh
#-----------------------------------------------
#   This is a shell script for configuring the
# basic p-post processing tool of CAM model, 
# You should set the basic parameters as below. 
# 
# Good Luck!
#
# Basic Figures
#       ----    UV850, with sig    
#       ----    UV850, without sig    
#       ----    Pr, with sig
#       ----    Pr, without sig
#       ----    UV850 + Pr, with sig
#       ----    UV850 + Pr, without sig
#
#
#
#
#
#               Last Modified on  2015-11-27
#               A L_Zealot Product
#-----------------------------------------------


# Path of the original data
# Caution: DO NOT DELETE \" IN STRING!
#PRE_DIR=\"/HOME/sysu_hjkx_ys/WORKSPACE/L_Zealot/cesm/B/B2000_f09_CAM5_spin-up/run/\"
PRO_CTRL_DIR=\"/users/yangsong3/wzq/CTRL_TP_HEAT/post/\"

# CTRL Case name
CTRL_CASENAME=\"CTRL_TP_HEAT\"


# Path of the post processed data
PRO_SEN_DIR=\"/users/yangsong3/wzq/TP_noPBL_HEAT/post/\"

# SEN case name
SEN_CASENAME=\"TP_noPBL_HEAT\"

# Path of outfig
FIG_PATH=\"/users/yangsong3/L_Zealot/temp/\"

# History file first year
FFRSTYEAR=1

# History file last year
FLSTYEAR=50

# Subset first year
SUB_FRSTYEAR=11

# Subset last year
SUB_LSTYEAR=50

# Range of the map, R_FLAG: regional flag, 1 for regional
R_FLAG=1

#-----------------------------------------------------------

if  [ $R_FLAG == 1 ] ; then
#EA
#    LATS=-5.
#    LATN=45.
#    LONW=90.
#    LONE=160.
#Arab-EA
    LATS=-5.
    LATN=60.
    LONW=30.
    LONE=160.
else
    LATS=-90.
    LATN=90.
    LONW=0.
    LONE=360.
fi
#tten_PBL
ncl pro_ctrl_dir=$PRO_CTRL_DIR              \
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
    ./ncl/draw_diff-season-hybrid-tten_PBL_SEN-CTRL-20151207.ncl
exit


#Output post processed 2D fields
ncl pro_ctrl_dir=$PRO_CTRL_DIR              \
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

#SHFLX
ncl pro_ctrl_dir=$PRO_CTRL_DIR              \
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
    ./ncl/draw_diff-season-SHFLX_SEN-CTRL-20151207.ncl


    

##Output post processed 3D fields
#ncl pre_dir=$PRE_DIR            \
#    pro_dir=$PRO_DIR            \
#    fdname3d=$FDNAME3D_HY       \
#    frstyear=$FRSTYEAR          \
#    lstyear=$LSTYEAR            \
#    case_name=$CASENAME         \
#    ./ncl/take_3D_hybrid_from_raw_data-150921.ncl


