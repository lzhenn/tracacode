#!/bin/sh
for FILE in ../data/daily-flow-full-record/?-* 
#for FILE in ../data/test/* 
do
    BNAME=$(basename $FILE)
    cat $FILE | sort -t ',' -k 2 >> ../data/daily-flow-full-record/sort/${BNAME}
    echo $FILE
done
