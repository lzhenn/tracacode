for((I=0;I<=120;I++))
do
    TFSTMP=`printf "%.3d" $I`
    echo $TFSTMP
    convert -trim +repage -bordercolor white -background white -flatten sen_d01_SLP_${TFSTMP}H.png sen_d01_noborder_${TFSTMP}H.png
done
convert -delay 15 sen_d01_noborder_* result.gif
convert result.gif -fuzz 10% -layers Optimize result.gif
