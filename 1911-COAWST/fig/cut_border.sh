for((I=0;I<=120;I++))
do
    TFSTMP=`printf "%.3d" $I`
    convert -trim +repage -bordercolor white -background white -flatten ctrl_d01_SLP_Wind10m_${TFSTMP}H.png ctrl_d01_SLP_Wind10m_${TFSTMP}H.png
done
