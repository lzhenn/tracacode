#!/bin/sh

PREFIX=../fig/asym/pr-pt-asian
I_END=73


for((I=1;I<=$I_END;I++))
do
    TFSTMP=`printf "%.2d" $I`
    echo $TFSTMP
    convert -trim -geometry 800x800 +repage -border 8 -bordercolor white -background white -flatten ${PREFIX}${TFSTMP}.png ${PREFIX}${TFSTMP}.png
done
