
PREFIX=sandy_d02_precip_
TOTAL_STEP=72
FRAME_DT=15
for((I=0;I<=${TOTAL_STEP};I++))
do
    TFSTMP=`printf "%.3d" $I`
    echo $TFSTMP
    convert -trim +repage -bordercolor white -background white -flatten ${PREFIX}${TFSTMP}Frm.png ${PREFIX}noborder_${TFSTMP}Frm.png
done

convert -delay ${FRAME_DT} ${PREFIX}noborder_* result.gif
#convert result.gif -fuzz 5% -layers Optimize result.gif
