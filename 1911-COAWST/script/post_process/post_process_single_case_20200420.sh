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
PRE_DIR=/disk/v092.yhuangci/lzhenn/1911-COAWST/

# Ref Track
TCK_NCL=\"${PRE_DIR}/cma.trck.mangkhut\"

# Case name
CASENAME=ERA5_WRF
CASENAME_NCL=\"$CASENAME\"

# Path of the post processed data
FIG_DIR=/disk/hq247/yhuangci/lzhenn/project/1911-COAWST/fig/${CASENAME}
FIG_DIR_NCL=\"$FIG_DIR\"

# Number of Domains
I_DOM_STRT=1
I_DOM_END=2

# Gif control parameters
PREFIX_ARR=("d02_precip_" "droms_ssta_area_" "droms_sst_")
STRT_F=18
END_F=72
FRAME_DT=30 # n/100 second



# Registered Steps:

# 0     step0_extract-tcInfo_200406.ncl
# 1     step1_plot_SLP_UV10_200406.ncl
#
#

FLAG_ARRAY=(true false false false)



#-----------------------------------------------------------
CASE_DIR=$PRE_DIR/${CASENAME}
CASE_DIR_NCL=\"${CASE_DIR}\"

echo $CASE_DIR_NCL
# Step1: Rename the output files...
echo "Step1: Rename the output files..."

for(( I_DOM=$I_DOM_STRT;I_DOM<=$I_DOM_END;I_DOM++ ));  
do   
    mv $CASE_DIR/wrfout_d0${I_DOM}* $CASE_DIR/wrfout_d0${I_DOM}
done  


# Step2: Extract minSLP file to locate the TC center info 
# file: trck.$casename.$<domain> e.g. trck.mangkhut.d01
# file style: (timestamp, lat, lon, minSLP, maxWS, uRadius, vRadius)
echo "Step2: Extract TC track, minSLP, and windspeed info..."

for(( I_DOM=$I_DOM_STRT;I_DOM<=$I_DOM_END;I_DOM++ ));  
do   
    I_DOM_NCL=\"$I_DOM\"
    if [ ${FLAG_ARRAY[0]} == true ] ; then
        ncl -nQ                             \
            i_dom=$I_DOM_NCL                \
            wrfout_path=$CASE_DIR_NCL       \
            casename=$CASENAME_NCL          \
            ./ncl/step0_extract-tcInfo_200406.ncl
    fi
    if [ ${FLAG_ARRAY[1]} == true ] ; then
        ncl -nQ                             \
            i_dom=$I_DOM_NCL                \
            wrfout_path=$CASE_DIR_NCL       \
            casename=$CASENAME_NCL          \
            fig_path=$FIG_DIR_NCL           \
            trck_path=$TCK_NCL              \
            ./ncl/step1_plot_SLP_UV10_200406.ncl
    fi
done  

exit 0

#Output post processed 2D fields
if [ $FLAG_2D == 1 ] ; then
    echo "-----package 2D field    (1)-----"
    ncl -nQ \
        pre_dir=$PRE_DIR            \
        pro_dir=$PRO_DIR            \
        fdname2d=$FDNAME2D          \
        frstyear=$FRSTYEAR          \
        lstyear=$LSTYEAR           \
        case_name=$CASENAME         \
        ./ncl/package_2D_from_raw_data_daily-160402.ncl
fi


#Output post processed 3D fields
if [ $FLAG_3D == 1 ] ; then
    echo "-----package 3D field    (1)-----"
    ncl -nQ \
       pre_dir=$PRE_DIR            \
       pro_dir=$PRO_DIR            \
       fdname3d=$FDNAME3D          \
       n_esm=$N_ESM                \
       layers=$LAYERS              \
       plev=$PLEV                  \
       case_name=$CASENAME         \
       ./ncl/package_3D_from_raw_data_daily-160402.ncl
fi
