
PREFIX=sen_d01_HWave_
STEP_H=6
TOTAL_STEP=20
FRAME_DT=$(expr 15 \* ${STEP_H})

for((I=0;I<=${TOTAL_STEP};I++))
do
    TF=$(expr $I \* ${STEP_H})
    TFSTMP=`printf "%.3d" $TF`
    echo $TFSTMP
    convert -trim +repage -bordercolor white -background white -flatten ${PREFIX}${TFSTMP}H.png ${PREFIX}noborder_${TFSTMP}H.png
done

convert -delay ${FRAME_DT} ${PREFIX}noborder_* result.gif
convert result.gif -fuzz 5% -layers Optimize result.gif
