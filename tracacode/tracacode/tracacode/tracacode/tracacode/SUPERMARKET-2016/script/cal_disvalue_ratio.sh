#!/bin/sh
for FILE in ../data/daily-flow-full-record/sort/?-????????
#for FILE in ../data/test/* 
do
    BNAME=$(basename $FILE)
    ALL_ITEM=$(cat $FILE | wc -l)
    DISVALUE_ITEM=$(cat $FILE | awk '{FS=","} $10 > 0 {print $1}' | wc -l)
    DISVALUE_ITEM=$(( $DISVALUE_ITEM*1000 ))
    DISV_RATIO=$(( $DISVALUE_ITEM / $ALL_ITEM ))
    echo ${BNAME:2:8},$DISV_RATIO >> ../data/daily-flow-full-record/flow/disvalue-ratio-thousands-2-${BNAME:0:1}
    echo $FILE
done
