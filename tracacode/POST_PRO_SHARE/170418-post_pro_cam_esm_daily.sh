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
PRE_DIR=/users/yangsong3/L_Zealot/F/AMIP_C5PM/exe/

# Path of the post processed data
PRO_DIR=\"/users/yangsong3/L_Zealot/F/AMIP_C5PM/post_data/\"

# Case name
CASENAME=\"AMIP_C5PM\"

# ESM folder prefix
ESM_NAME=ESMn4_

# ESM folder memebers
ESM_STRT=1

# ESM folder memebers
ESM_LAST=8



# Names of 2D fields
FDNAME2D="(/\"PRECL\",\"PRECC\",\"FLUT\",\"PS\",\"TS\",\"TMQ\"/)" #often use
#FDNAME2D="(/\"TS\"/)" #often use
#FDNAME2D="(/\"PRECT\",\"PSL\",\"QBOT\",\"TSMN\",\"U200\",\"U850\",\"UBOT\",\"V200\",\"V850\",\"VBOT\",\"Z200\",\"Z500\"/)" #often use

# Names of 3D fields
FDNAME3D="(/\"U\",\"V\",\"T\",\"OMEGA\",\"Q\",\"Z3\"/)" #often use
#FDNAME3D="(/\"RELHUM\"/)" #often use
#FDNAME3D_HY="(/\"RELHUM\"/)" #often use
#FDNAME3D_HY="(/\"U\",\"V\",\"T\",\"OMEGA\",\"Q\",\"RELHUM\",\"Z3\",\"DTCOND\"/)" # hybrid coordinate

# Names of 3D HY fields
#FDNAME3D_HY="(/\"U\",\"V\"/)" # hybrid coordinate
FDNAME3D_HY="(/\"T\"/)" # hybrid coordinate



# Layers of 3D fields
# CAM4 = 26; CAM5 = 30
LAYERS=30

# Output specific pressure layers
# CAUTION: Do not leave species between element!
#PLEV="(/925,850,700,600,500,400,300,200,100,50/)"
PLEV="(/1000,925,850,700,600,500,400,300,200,150/)"


# Process fig flag
FLAG2D=0
FLAG3D=1
FLAG3DHY=0


#-----------------------------------------------------------
ESM_NAME0=\"${ESM_NAME}\"
for II in `seq $ESM_STRT $ESM_LAST`
do
    FULL_PRE_DIR=\"${PRE_DIR}${ESM_NAME}${II}/\"
    echo "ESM $II is under processing..."
    #Output post processed 2D fields
    if  [ $FLAG2D == 1 ] ; then
    #Output post processed 2D fields
    ncl -nQ pre_dir=$FULL_PRE_DIR            \
        pro_dir=$PRO_DIR            \
        fdname2d=$FDNAME2D          \
        n_esm=$II                   \
        case_name=$CASENAME         \
        esm_name=$ESM_NAME0          \
        ./ncl/take_2D_from_raw_data_esm_daily-170418.ncl
    fi
    if  [ $FLAG3D == 1 ] ; then
    #Output post processed 3D fields
    ncl -nQ pre_dir=$FULL_PRE_DIR           \
       pro_dir=$PRO_DIR            \
       fdname3d=$FDNAME3D          \
       n_esm=$II                \
       layers=$LAYERS              \
       plev=$PLEV                  \
       case_name=$CASENAME         \
       esm_name=$ESM_NAME0          \
       ./ncl/take_3D_from_raw_data_esm_daily-170418.ncl
    fi

    if  [ $FLAG3DHY == 1 ] ; then
    #Output post processed 3D fields
    ncl -nQ pre_dir=$FULL_PRE_DIR            \
        pro_dir=$PRO_DIR            \
        fdname3d=$FDNAME3D_HY       \
        n_esm=$II                \
        case_name=$CASENAME         \
        esm_name=$ESM_NAME0        \
        ./ncl/take_3D_hybrid_from_raw_data_esm_daily-170418.ncl
    fi
done
