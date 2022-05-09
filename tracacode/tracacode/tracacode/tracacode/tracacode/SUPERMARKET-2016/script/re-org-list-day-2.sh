#!/bin/sh
######################################################
# Only take out the 1 2 3 columns from splited files
# and re-orgnize the file in date
#                               L_Zealot
######################################################

# re-org in N-yyyymmdd
for FILE in ../data/splited-noreject/* 
do
    awk 'BEGIN {FS=","} {print $1","$2","$3 >> "../data/daily-flow-noreject/"$1"-"substr($2,7,4) substr($2,1,2) substr($2,4,2)}' $FILE     
    echo $FILE
done

# get uniq record, `wc -l` will show the daily flow
for FILE in ../data/daily-flow-noreject/?-*
do
    BNAME=$(basename $FILE)
    cat $FILE | sort -u -t ',' -k 2 >> ../data/daily-flow-noreject/uniq/${BNAME}u
    echo $FILE
done
