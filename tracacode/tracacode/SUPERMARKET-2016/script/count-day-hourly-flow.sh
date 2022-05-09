#!/bin/sh
HOUR=(" 07" " 08" " 09" " 10" " 11" " 12" " 13" " 14" " 15" " 16" " 17" " 18" " 19" " 20" " 21" " 22" " 23")
for FILE in ../data/daily-flow-full-record/uniq/*u 
do
    BNAME=$(basename $FILE)
    FLOW=""
    for STR in ${HOUR[@]}; do
        FLOW=$FLOW,$(grep " $STR" $FILE | wc -l)
    done

    echo ${BNAME:2:8}$FLOW >> ../data/daily-flow-full-record/uniq/houly-day-flow-${BNAME:0:1}
    echo $FILE
done
