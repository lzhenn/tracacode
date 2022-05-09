
if [ -n "$1" ]; then
    PREFIX=
else
    PREFIX=droms_zeta_
fi
STRT_F=0
END_F=0
FRAME_DT=15 # n/100 second

rm -f *noborder*




for((I=$STRT_F;I<=${TOTAL_STEP};I++))
do
    TFSTMP=`printf "%.3d" $I`
    echo $TFSTMP
    #convert -trim +repage -bordercolor white -background white -flatten ${PREFIX}${TFSTMP}H.png ${PREFIX}noborder_${TFSTMP}H.png
    convert -trim +repage -bordercolor white -background white -flatten ${PREFIX}${TFSTMP}Frm.png ${PREFIX}noborder_${TFSTMP}Frm.png
done

convert -delay ${FRAME_DT} ${PREFIX}noborder_* ${PREFIX}result.gif
convert ${PREFIX}result.gif -layers Optimize ${PREFIX}result.gif
#convert result.gif -fuzz 5% -layers Optimize result.gif
