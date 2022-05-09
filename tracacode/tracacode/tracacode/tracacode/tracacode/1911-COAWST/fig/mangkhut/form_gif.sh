#/bin/sh

STRT_F=0
END_F=193
PREFIX=droms_zeta_
FRAME_DT=15 # n/100 second

if [ -n "$1" ]; then
    PREFIX="$1"
fi

if [ -n "$2" ]; then
    STRT_F="$2"
fi

if [ -n "$3" ]; then
    END_F="$3"
fi

if [ -n "$4" ]; then
    FRAME_DT="$4"
fi

rm -f *noborder*


for((I=$STRT_F;I<=${END_F};I++))
do
    TFSTMP=`printf "%.3d" $I`
    echo $TFSTMP
    #convert -trim +repage -bordercolor white -background white -flatten ${PREFIX}${TFSTMP}H.png ${PREFIX}noborder_${TFSTMP}H.png
    convert -trim +repage -bordercolor white -background white -flatten ${PREFIX}${TFSTMP}Frm.png ${PREFIX}noborder_${TFSTMP}Frm.png
done

convert -delay ${FRAME_DT} ${PREFIX}noborder_* ${PREFIX}result.gif
convert ${PREFIX}result.gif -layers Optimize ${PREFIX}result.gif
#convert result.gif -fuzz 5% -layers Optimize result.gif
