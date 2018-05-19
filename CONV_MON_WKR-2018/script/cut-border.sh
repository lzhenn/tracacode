#!/bin/sh

PREFIX=../fig/year10/aqua-psl-500z3
I_END=59


for((I=1;I<=$I_END;I++))
do
    TFSTMP=`printf "%.3d" $I`
    echo $TFSTMP
    convert -trim +repage -bordercolor white -background white -flatten ${PREFIX}${TFSTMP}.png ${PREFIX}${TFSTMP}.png
done
