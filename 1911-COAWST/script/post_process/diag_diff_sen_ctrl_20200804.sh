#!/bin/sh
#-----------------------------------------------
#    This is a shell script for configuring the
# basic post processing tool for WRF model, 
# targeting the tropical cyclone simulations. You 
# should set the basic parameters as below. 
# Good Luck!
#               Last Modified on  Apr 06, 2020
#               A L_Zealot Product
#-----------------------------------------------

# Path of the original data, without casename (the )
# Caution: DO NOT DELETE \" IN STRING!
PRE_DIR=/disk/v092.yhuangci/lzhenn/1911-COAWST
PRE_DIR_NCL=\"/disk/v092.yhuangci/lzhenn/1911-COAWST\"

# Fig dir root
FIG_DIR_NCL=\"/disk/hq247/yhuangci/lzhenn/project/1911-COAWST/fig\"

# Ref Track
TCK_OBV=cma.trck.mangkhut
TCK_NCL=\"${PRE_DIR}/cma.trck.mangkhut\"

# Case name

CASE_SEN=\"ERA5_C2008_add\"
CASE_CTRL=\"ERA5_WRFROMS_add\"

# Number of Domains
I_DOM=2

# Composite D02
COMP1_TSTRT=2018091520
COMP1_TEND=2018091600


echo "MASTER: *STEP02* D0"$I_DOM": plot_frame_rain_200506.ncl or opt ncls"
ncl -nQ                             \
    i_dom=$I_DOM                \
    pre_dir=$PRE_DIR_NCL       \
    case_sen=$CASE_SEN          \
    case_ctrl=$CASE_CTRL          \
    fig_path=$FIG_DIR_NCL           \
    trck_path=$TCK_NCL              \
    comp1_tstrt=$COMP1_TSTRT        \
    comp1_tend=$COMP1_TEND          \
   ./ncl/diff1_plot_box_comp_ust_200804.ncl
#   ./ncl/diff1_plot_box_comp_akms_200804.ncl
exit 0
