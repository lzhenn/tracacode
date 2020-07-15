#!/bin/bash

#CASENAMES=( "ERA5_C2008_add" "ERA5_TY2001_add" "ERA5_WAOFF_add" "ERA5_WRFROMS_add" "ERA5_WRF_add" )

CASENAMES=( "ERA5_C2008" "ERA5_TY2001" "ERA5_WAOFF" "ERA5_WRFROMS" "ERA5_WRF" )
SCRIPT_DIR=`pwd`

SRC_STR=""
for CASENAME in ${CASENAMES[@]}
do
    WRK_DIR=${SCRIPT_DIR}/../../fig/${CASENAME}
    cd $WRK_DIR
    echo $WRK_DIR
    
    rm -f *noborder*

    FILE_NAME=d02_UST_${CASENAME}_box_comp.png
    convert -trim +repage -bordercolor white -background white -flatten ${FILE_NAME} ../${CASENAME}_noborder_temp.png
    SRC_STR="${SRC_STR} ${CASENAME}_noborder_temp.png"
done

cd ..
convert +append $SRC_STR combine.png
