
PREFIX=ts_2d.
TOTAL_STEP=48
STRT_F=1
FRAME_DT=30 # n/100 second

cd ../fig

rm -f *noborder*

for((I=$STRT_F;I<=${TOTAL_STEP};I++))
do
    TFSTMP=`printf "%.6d" $I`
    echo $TFSTMP
    #convert -trim +repage -bordercolor white -background white -flatten ${PREFIX}${TFSTMP}H.png ${PREFIX}noborder_${TFSTMP}H.png
    convert -trim +repage -bordercolor white -background white -flatten ${PREFIX}${TFSTMP}.png ${PREFIX}noborder_${TFSTMP}.png
done

convert -delay ${FRAME_DT} ${PREFIX}noborder_* ${PREFIX}result.gif
convert ${PREFIX}result.gif -layers Optimize ${PREFIX}result.gif
#convert result.gif -fuzz 5% -layers Optimize result.gif
