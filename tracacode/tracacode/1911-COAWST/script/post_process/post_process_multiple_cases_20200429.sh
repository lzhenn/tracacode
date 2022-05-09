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

# Fig dir root
FIG_DIR_ROOT=/disk/hq247/yhuangci/lzhenn/project/1911-COAWST/fig

# Ref Track
TCK_OBV=hko.trck.mangkhut
TCK_NCL=\"${PRE_DIR}/hko.trck.mangkhut\"

# Case name

CASENAMES=( "ERA5_C2008" "ERA5_TY2001" "ERA5_WAOFF" "ERA5_WRFROMS" "ERA5_WRF" )
CASENAMES=( "ERA5_C2008_dynlim" "ERA5_TY2001_add" "ERA5_WRFROMS_add" "ERA5_WRF_add" )
CASENAMES=( "ERA5_TY2001_nolimit" "ERA5_TY2001_add" "ERA5_C2008_dynlim" "ERA5_C2008_add" "ERA5_WRFROMS_add" "ERA5_WRF_add")
CASENAMES=( "C2008" "TY2001" "WRFROMS" "WRFONLY" )
#CASENAMES=( "ERA5_C2008" "ERA5_TY2001" "ERA5_WAOFF" "ERA5_WRFROMS" "ERA5_WRF"\
#            "FNL0d25_C2008" "FNL0d25_WRFROMS" "FNL0d25_WRF" "FNL1d_TY2001" "FNL1d_WRF" )
            
            
#CASENAMES=( "ERA5_TY2001" "FNL0d25_WRF" "FNL1d_TY2001" "ERA5_WRF" "ERA5_C2008"\
#            "ERA5_WAOFF" "FNL0d25_C2008" "FNL0d25_WRFROMS" "FNL1d_WRF" )

#CASENAMES=( "mangkhut-era-caulliez2008"  "mangkhut-era-wrfonly"\
#            "mangkhut-fnl0d25-wrfonly" "mangkhut-wrfonly")

# Number of Domains
I_DOM_STRT=2
I_DOM_END=2

# Gif control parameters
PREFIX_ARR=("d02_precip_" "droms_ssta_area_" "droms_sst_")
STRT_F=18
END_F=72
FRAME_DT=30 # n/100 second



# Registered Steps:

# 0     step0_extract-tcInfo_200406.ncl
# 1     step1_plot_SLP_UV10_200406.ncl
# 2     step2_plot_frame_rain_200506.ncl + optxxx
# 3     step3_plot_tracks_200528.ncl
# 4     step4_plot_accum_rain_200530.ncl
#

FLAG_ARRAY=(0 0 0 1 0)
#FLAG_ARRAY=(0 0 1 0 0)

# 0     comp1_tc-intensity-obv-200429.py
# 1     compare-tc-intensity-ws-obv-200505.py
#COMP_ARRAY=(1 1)
COMP_ARRAY=(0 0)

# Composite D02
#COMP1_TSTRT=2018091518
#COMP1_TEND=2018091600

# Complete
COMP1_TSTRT=2018091506
COMP1_TEND=2018091700

echo "MASTER: Preprocessing..."
#-----------------------------------------------------------

for CASENAME in ${CASENAMES[@]}
do
    CASENAME_NCL=\"$CASENAME\"
    
    # Path of the post processed data
    FIG_DIR=${FIG_DIR_ROOT}/${CASENAME}
    mkdir $FIG_DIR
    FIG_DIR_NCL=\"$FIG_DIR\"

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
                ./ncl/step0.1_extract-wsInfo_200728.ncl
        #       ./ncl/step0_extract-tcInfo_200406.ncl
        #        ./ncl/step0.1_extract-wsInfo_200728.ncl
        fi
        if [ ${FLAG_ARRAY[1]} == 1 ] ; then
            echo "MASTER: *STEP01* D0"$I_DOM": plot_SLP_UV10_200406.ncl"
            ncl -nQ                             \
                i_dom=$I_DOM_NCL                \
                wrfout_path=$CASE_DIR_NCL       \
                casename=$CASENAME_NCL          \
                fig_path=$FIG_DIR_NCL           \
                trck_path=$TCK_NCL              \
                comp1_tstrt=$COMP1_TSTRT        \
                comp1_tend=$COMP1_TEND          \
                ./ncl/step1_plot_SLP_UV10_200406.ncl &
        fi

        if [ ${FLAG_ARRAY[2]} == 1 ] ; then
            echo "MASTER: *STEP02* D0"$I_DOM": opt ncls"
            ncl -nQ                             \
                i_dom=$I_DOM_NCL                \
                wrfout_path=$CASE_DIR_NCL       \
                casename=$CASENAME_NCL          \
                fig_path=$FIG_DIR_NCL           \
                trck_path=$TCK_NCL              \
                comp1_tstrt=$COMP1_TSTRT        \
                comp1_tend=$COMP1_TEND          \
                ./ncl/opt2.6_plot_box_comp_wind_streamline_200627.ncl
    #            ./ncl/opt3.5_plot_box_comp_lh_radius.ncl
    #           ./ncl/opt2.5_plot_box_comp_wind_radius_200602.ncl
    #            ./ncl/opt3_plot_box_comp_lh_200516.ncl 
    #            ./ncl/opt2.6_plot_box_comp_wind_streamline_200627.ncl
    #           ./ncl/opt1_plot_box_comp_rain_200507.ncl
    #           ./ncl/opt2.8_plot_box_comp_wind_inflow_angle_200629.ncl
    #           ./ncl/opt2.5_plot_box_comp_wind_radius_200602.ncl
    #            ./ncl/opt8.1_plot_box_comp_z0_radius.ncl
    #            ./ncl/opt9_plot_box_comp_ustar_200713.ncl
    #            ./ncl/opt10_plot_box_comp_ckcd_200713.ncl
    #            ./ncl/step2_plot_frame_rain_200506.ncl &
    #            ./ncl/opt2.8_plot_box_comp_wind_inflow_angle_200629.ncl
    #            ./ncl/opt1.5_opt_plot_box_frame_rain_200702.ncl
    #            ./ncl/step2_opt_plot_box_frame_rain_200507.ncl 
    #            ./ncl/opt2.6.1_plot_box_frame_wind_streamline_200702.ncl
    #            ./ncl/opt2.6_plot_box_comp_wind_streamline_200627.ncl
    #            ./ncl/opt5.1_plot_box_comp_hfx_radius.ncl
    #            ./ncl/opt3.5_plot_box_comp_lh_radius.ncl
    #            ./ncl/opt3.4_plot_box_comp_lh_acentrosymmetric_200516.ncl
    #            ./ncl/opt3.3_plot_box_comp_lh_centrosymmetric_200516.ncl
    #            ./ncl/opt2.4_plot_box_comp_wind_acentrosymmetric_NW-SE_200602.ncl
    #            ./ncl/opt3.1_plot_box_comp_lh_symmetric_NW-SE_200516.ncl
    #            ./ncl/opt3.2_plot_box_comp_lh_asymmetric_NW-SE_200516.ncl
    #            ./ncl/opt2.2_plot_box_comp_wind_asymmetric_NW-SE_200514.ncl
    #           ./ncl/opt2.1_plot_box_comp_wind_symmetric_NW-SE_200514.ncl
    #           ./ncl/opt1.41_plot_box_comp_rain_percent_asymmetric_NW-SE_200601.ncl
    #           ./ncl/opt1.3_plot_box_comp_rain_symmetric_NW-SE_200601.ncl
    #           ./ncl/opt1.4_plot_box_comp_rain_asymmetric_NW-SE_200601.ncl
    #           ./ncl/opt1.3_plot_box_comp_rain_symmetric_NW-SE_200601.ncl
    #           ./ncl/opt1.2_plot_box_comp_rain_asymmetric_vertical_200507.ncl
    #           ./ncl/opt1.1_plot_box_comp_rain_symetric_vertical_200507.ncl
    #            ./ncl/opt6_plot_box_comp_tsk_200516.ncl 
    #            ./ncl/opt7_plot_box_comp_q2_200516.ncl 
    #            ./ncl/opt5_plot_box_comp_hfx_200516.ncl 
    #           ./ncl/opt4_plot_box_comp_hwave_200516.ncl 
    #            ./ncl/opt3_plot_box_comp_lh_200516.ncl 
    #            ./ncl/opt2_plot_box_comp_wind_200514.ncl 
    #           ./ncl/opt1_plot_box_comp_rain_200507.ncl 
    #            ./ncl/step2_opt_plot_box_frame_rain_200507.ncl 
    #            ./ncl/step2_plot_frame_rain_200506.ncl
        fi
        if [ ${FLAG_ARRAY[3]} == 1 ] ; then
        echo "MASTER: *STEP03* D0"$I_DOM": plot_frame_tack_200528.ncl"
        ncl -nQ                             \
            i_dom=$I_DOM_NCL                \
            wrfout_path=$CASE_DIR_NCL       \
            casename=$CASENAME_NCL          \
            fig_path=$FIG_DIR_NCL           \
            trck_path=$TCK_NCL              \
            tstrt=$COMP1_TSTRT        \
            tend=$COMP1_TEND          \
            ./ncl/step3_plot_tracks_200528.ncl &
        fi
        if [ ${FLAG_ARRAY[4]} == 1 ] ; then
        echo "MASTER: *STEP04* D0"$I_DOM": plot_accum_rain_200530.ncl"
        ncl -nQ                             \
            i_dom=$I_DOM_NCL                \
            wrfout_path=$CASE_DIR_NCL       \
            casename=$CASENAME_NCL          \
            fig_path=$FIG_DIR_NCL           \
            trck_path=$TCK_NCL              \
            tstrt=$COMP1_TSTRT        \
            tend=$COMP1_TEND          \
            ./ncl/step4_plot_accum_rain_200530.ncl &
        fi

    
        wait
    done  
done # done casenames loop

for(( I_DOM=$I_DOM_STRT;I_DOM<=$I_DOM_END;I_DOM++ ));  
do
    if [ ${COMP_ARRAY[0]} == 1 ] ; then
        
        echo "COMP1: Intensity"
        python ./python/compare-tc-intensity-obv-200429.py $PRE_DIR $TCK_OBV $FIG_DIR_ROOT \
            $COMP1_TSTRT $COMP1_TEND $I_DOM ${CASENAMES[*]}
        echo "COMP1: Done"

    fi
    if [ ${COMP_ARRAY[1]} == 1 ]; then
        echo "COMP2: Wind Speed Intensity"
        python ./python/compare-tc-intensity-ws-individual-file-obv-200725.py $PRE_DIR $TCK_OBV $FIG_DIR_ROOT \
            $COMP1_TSTRT $COMP1_TEND $I_DOM ${CASENAMES[*]}
#        python ./python/compare-tc-intensity-ws-obv-200505.py $PRE_DIR $TCK_OBV $FIG_DIR_ROOT \
#            $COMP1_TSTRT $COMP1_TEND $I_DOM ${CASENAMES[*]}
        echo "COMP2: Done"
    fi
done

exit 0
