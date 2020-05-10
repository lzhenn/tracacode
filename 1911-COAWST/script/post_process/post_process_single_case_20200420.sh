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
CASENAME=ERA5_WRFROMS
CASENAME_NCL=\"$CASENAME\"

# Path of the post processed data
FIG_DIR=/disk/hq247/yhuangci/lzhenn/project/1911-COAWST/fig/${CASENAME}
FIG_DIR_NCL=\"$FIG_DIR\"

# Number of Domains
I_DOM_STRT=1
I_DOM_END=2

# Gif control parameters
TSTRT=2018091506
TEND=2018091700
PREFIX_ARR=("d02_precip_" "droms_ssta_area_" "droms_sst_")
STRT_F=18
END_F=72
FRAME_DT=30 # n/100 second



# Registered Steps:

# 0     step0_extract-tcInfo_200406.ncl
# 1     step1_plot_SLP_UV10_200406.ncl
# 2     step2_plot_frame_rain_200506.ncl 
#
#

FLAG_ARRAY=(1 1 0 0)



#-----------------------------------------------------------

# Path of the post processed data
mkdir $FIG_DIR

CASE_DIR=$PRE_DIR/${CASENAME}
CASE_DIR_NCL=\"${CASE_DIR}\"

echo $CASE_DIR_NCL
# Step1: Rename the output files...
echo "MASTER: Rename the output files..."

for(( I_DOM=$I_DOM_STRT;I_DOM<=$I_DOM_END;I_DOM++ ));  
do   
    mv $CASE_DIR/wrfout_d0${I_DOM}* $CASE_DIR/wrfout_d0${I_DOM}
done  


# Step2: Extract minSLP file to locate the TC center info 
# file: trck.$casename.$<domain> e.g. trck.mangkhut.d01
# file style: (timestamp, lat, lon, minSLP, maxWS, uRadius, vRadius)

echo "MASTER: Info extraction and plotting figure..."
for(( I_DOM=$I_DOM_STRT;I_DOM<=$I_DOM_END;I_DOM++ ));  
do   
    I_DOM_NCL=\"$I_DOM\"
    if [ ${FLAG_ARRAY[0]} == 1 ] ; then
        echo "MASTER: *STEP00* D0"${I_DOM}" Extract TC track, minSLP, and windspeed info..."
        ncl -nQ                             \
            i_dom=$I_DOM_NCL                \
            wrfout_path=$CASE_DIR_NCL       \
            casename=$CASENAME_NCL          \
            ./ncl/step0_extract-tcInfo_200406.ncl
    fi
    if [ ${FLAG_ARRAY[1]} == 1 ] ; then
        echo "MASTER: *STEP01* D0"$I_DOM": plot_SLP_UV10_200406.ncl"
        ncl -nQ                             \
            i_dom=$I_DOM_NCL                \
            wrfout_path=$CASE_DIR_NCL       \
            casename=$CASENAME_NCL          \
            fig_path=$FIG_DIR_NCL           \
            trck_path=$TCK_NCL              \
            ./ncl/step1_plot_SLP_UV10_200406.ncl
    fi
    if [ ${FLAG_ARRAY[2]} == 1 ] ; then
        echo "MASTER: *STEP02* D0"$I_DOM": plot_frame_rain_200506.ncl"
        ncl -nQ                             \
            i_dom=$I_DOM_NCL                \
            wrfout_path=$CASE_DIR_NCL       \
            casename=$CASENAME_NCL          \
            fig_path=$FIG_DIR_NCL           \
            trck_path=$TCK_NCL              \
            ./ncl/step2_opt_plot_box_comp_rain_200507.ncl 
#            ./ncl/step2_opt_plot_box_frame_rain_200507.ncl 
#            ./ncl/step2_plot_frame_rain_200506.ncl
    fi


done  

exit 0

