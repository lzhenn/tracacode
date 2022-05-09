#!/bin/bash

#CASENAMES=( "ERA5_C2008_add" "ERA5_TY2001_add" "ERA5_WAOFF_add" "ERA5_WRFROMS_add" "ERA5_WRF_add" )

CASENAMES_ROW1=( "WRFONLY" "WRFROMS" )
CASENAMES_ROW2=( "TY2001" "C2008" )
SCRIPT_DIR=`pwd`

SRC_STR=""
for CASENAME in ${CASENAMES_ROW1[@]}
do
    FILE_NAME=d02_acc_precip_2018091506-2018091700.png
    WRK_DIR=${SCRIPT_DIR}/../../fig/${CASENAME}
    cd $WRK_DIR
    echo $WRK_DIR
    
    rm -f *noborder*

    convert -trim +repage -bordercolor white -background white -flatten ${FILE_NAME} ../${CASENAME}_noborder_temp.png
    SRC_STR="${SRC_STR} ${CASENAME}_noborder_temp.png"
done

cd ..
convert +append $SRC_STR combine_row1.png


SRC_STR=""
for CASENAME in ${CASENAMES_ROW2[@]}
do
    FILE_NAME=d02_acc_precip_2018091506-2018091700.png
    WRK_DIR=${SCRIPT_DIR}/../../fig/${CASENAME}
    cd $WRK_DIR
    echo $WRK_DIR
    
    rm -f *noborder*

    convert -trim +repage -bordercolor white -background white -flatten ${FILE_NAME} ../${CASENAME}_noborder_temp.png
    SRC_STR="${SRC_STR} ${CASENAME}_noborder_temp.png"
done

cd ..
convert +append $SRC_STR combine_row2.png
convert -append combine_row1.png combine_row2.png combine.png
