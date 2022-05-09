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
PRE_DIR=\"/users/yangsong3/L_Zealot/F/DATA_CLIM-Trans-2015/\"

# Path of the post processed data
PRO_DIR=\"/users/yangsong3/L_Zealot/F/DATA_CLIM-Trans-2015/pro/\"

# Case name
CASENAME=\"CLIM-Trans-2015\"


# Names of 2D fields
FDNAME2D="(/\"PRECL\",\"PRECC\",\"FLUT\",\"PSL\",\"TS\",\"TMQ\"/)" #often use
#FDNAME2D="(/\"TS\",\"TSMX\"/)" #often use
#FDNAME2D="(/\"PRECT\",\"PSL\",\"QBOT\",\"TSMN\",\"U200\",\"U850\",\"UBOT\",\"V200\",\"V850\",\"VBOT\",\"Z200\",\"Z500\"/)" #often use

# Names of 3D fields
FDNAME3D="(/\"U\",\"V\",\"T\",\"OMEGA\",\"Q\",\"RELHUM\",\"Z3\"/)" #often use
#FDNAME3D="(/\"RELHUM\"/)" #often use
#FDNAME3D_HY="(/\"RELHUM\"/)" #often use
#FDNAME3D_HY="(/\"U\",\"V\",\"T\",\"OMEGA\",\"Q\",\"RELHUM\",\"Z3\",\"DTCOND\"/)" # hybrid coordinate

# Number of Ensemble members
N_ESM=28

# ESM folder prefix
ESM_NAME=\"ESMc_add_\"


# Layers of 3D fields
# CAM4 = 26; CAM5 = 30
LAYERS=30

# Output specific pressure layers
# CAUTION: Do not leave species between element!
#PLEV="(/925,850,700,600,500,400,300,200,100,50/)"
PLEV="(/1000,925,850,700,500,200/)"


# Process fig flag
#FIGFLAG=FALSE

#-----------------------------------------------------------

##Output post processed 2D fields
#ncl pre_dir=$PRE_DIR            \
#    pro_dir=$PRO_DIR            \
#    fdname2d=$FDNAME2D          \
#    n_esm=$N_ESM                \
#    case_name=$CASENAME         \
#    esm_name=$ESM_NAME          \
#    ./ncl/take_2D_from_raw_data_esm_daily-151122.ncl

#Output post processed 3D fields
ncl pre_dir=$PRE_DIR           \
   pro_dir=$PRO_DIR            \
   fdname3d=$FDNAME3D          \
   n_esm=$N_ESM                \
   layers=$LAYERS              \
   plev=$PLEV                  \
   case_name=$CASENAME         \
   esm_name=$ESM_NAME          \
   ./ncl/take_3D_from_raw_data_esm_daily-151123.ncl


#Output post processed 3D fields
#ncl pre_dir=$PRE_DIR            \
#    pro_dir=$PRO_DIR            \
#    fdname3d=$FDNAME3D_HY       \
#    n_esm=$N_ESM                \
#    case_name=$CASENAME         \
#    ./ncl/take_3D_hybrid_from_raw_data_esm_daily-151123.ncl


