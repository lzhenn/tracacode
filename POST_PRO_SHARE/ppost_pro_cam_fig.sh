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
PRO_CTRL_DIR=\"/HOME/sysu_hjkx_ys/WORKSPACE/data/model/L_Zealot/SCS_ANNCYC-2015/pro/\"

# CTRL Case name
CTRL_CASENAME=\"B2000_f09_CAM5PM_spin-up\"


# Path of the post processed data
PRO_SEN_DIR=\"/HOME/sysu_hjkx_ys/WORKSPACE/data/model/L_Zealot/SCS_ANNCYC-2015/pro/\"

# SEN case name
SEN_CASENAME=\"B2000_f09_CAM5PM_SCS_ANNCYC\"

# Path of outfig
FIG_PATH=\"/HOME/sysu_hjkx_ys/WORKSPACE/L_Zealot/project/SCS_ANNCYC-2015/fig/auto-fig\"

# History file first year
FFRSTYEAR=201

# History file last year
FLSTYEAR=250

# Subset first year
SUB_FRSTYEAR=201

# Subset last year
SUB_LSTYEAR=250

# Range of the map, R_FLAG: regional flag, 1 for regional
R_FLAG=1

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

    

##Output post processed 3D fields
#ncl pre_dir=$PRE_DIR            \
#    pro_dir=$PRO_DIR            \
#    fdname3d=$FDNAME3D_HY       \
#    frstyear=$FRSTYEAR          \
#    lstyear=$LSTYEAR            \
#    case_name=$CASENAME         \
#    ./ncl/take_3D_hybrid_from_raw_data-150921.ncl


