#!/bin/sh

######################################################
# Only take out the 1 2 3 columns from splited files
#
#
#                               L_Zealot
######################################################
for FILE in ../data/daily-flow-full-record/sort/* 
#for FILE in ../data/test/* 
do
    awk 'BEGIN {FS=","} {print $1","$2","$3 >> "../data/daily-flow-full-record/uniq/"$1"-"substr($2,7,4) substr($2,1,2) substr($2,4,2)}' $FILE     
    echo $FILE
done
