#!/bin/bash

#PREFIX_ARR=("d02_SLP_" "droms_HWave_" "droms_ssta_area_" "droms_sst_")

#PREFIX_ARR=("d02_precip_" "droms_ssta_area_" "droms_sst_")
PREFIX_ARR=("d02_precip_")
STRT_F=17
END_F=59
FRAME_DT=30 # n/100 second

N_FRM=$(( $END_F - $STRT_F ))
cd ../../fig/ERA5_C2008 

rm -f *noborder*

L_PREFIX=${#PREFIX_ARR[@]}
for((IPRE=0;IPRE<=0;IPRE++))
#for((IPRE=0;IPRE<L_PREFIX;IPRE++))
do
    PREFIX=${PREFIX_ARR[$IPRE]}
    b=''
    for((I=$STRT_F;I<=${END_F};I++))
    do
        printf "[%-50s] %d/%d \r" "$b" "$I" "$N_FRM";
        b+='#'
        TFSTMP=`printf "%.3d" $I`
        #convert -trim +repage -bordercolor white -background white -flatten ${PREFIX}${TFSTMP}H.png ${PREFIX}noborder_${TFSTMP}H.png
        convert -trim +repage -bordercolor white -background white -flatten ${PREFIX}${TFSTMP}Frm.png ${PREFIX}noborder_${TFSTMP}Frm.png
    done
    echo "Convert to gif..."
    convert -delay ${FRAME_DT} ${PREFIX}noborder_* ${PREFIX}result.gif
    convert ${PREFIX}result.gif -layers Optimize ${PREFIX}result.gif
    #convert ${PREFIX}result.gif -fuzz 5% -layers Optimize ${PREFIX}result.gif
done
