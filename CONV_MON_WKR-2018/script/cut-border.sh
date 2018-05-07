#!/bin/sh

PREFIX=../fig/asym/pr-pt-asian
I_END=73


for((I=1;I<=$I_END;I++))
do
    TFSTMP=`printf "%.2d" $I`
    echo $TFSTMP
    convert ${PREFIX}${TFSTMP}.png -bordercolor white -trim ${PREFIX}${TFSTMP}.png
done

