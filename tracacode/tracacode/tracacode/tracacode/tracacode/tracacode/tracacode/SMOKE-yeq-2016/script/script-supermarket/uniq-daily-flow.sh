#!/bin/sh
for FILE in ../data/daily-flow-full-record/uniq/?-201????? 
#for FILE in ../data/test/* 
do
    BNAME=$(basename $FILE)
    cat $FILE | uniq >> ../data/daily-flow-full-record/uniq/${BNAME}u
    echo $FILE
done
