#!/bin/sh

DATE0=`date -d '1 days ago' +%y%m%d`
for FILE in ./gold/$DATE0/* 
do
    TSTAMP=${FILE:19}    
    #World gold гд 
    WD_RMB_IN=$(awk 'BEGIN {FS=">"} NR==19 {print $2}' $FILE | awk 'BEGIN {FS="<"} {print $1}')
    WD_RMB_OUT=$(awk 'BEGIN {FS=">"} NR==20 {print $2}' $FILE | awk 'BEGIN {FS="<"} {print $1}')

    #World gold $
    WD_USD_IN=$(awk 'BEGIN {FS=">"} NR==27 {print $2}' $FILE | awk 'BEGIN {FS="<"} {print $1}')
    WD_USD_OUT=$(awk 'BEGIN {FS=">"} NR==28 {print $2}' $FILE | awk 'BEGIN {FS="<"} {print $1}')

    #Bank gold $
    BK_USD_IN=$(awk 'BEGIN {FS=">"} NR==282 {print $2}' $FILE | awk 'BEGIN {FS="<"} {print $1}')
    BK_USD_OUT=$(awk 'BEGIN {FS=">"} NR==283 {print $2}' $FILE | awk 'BEGIN {FS="<"} {print $1}')

    #Bank gold гд
    BK_RMB_IN=$(awk 'BEGIN {FS=">"} NR==330 {print $2}' $FILE | awk 'BEGIN {FS="<"} {print $1}')
    BK_RMB_OUT=$(awk 'BEGIN {FS=">"} NR==331 {print $2}' $FILE | awk 'BEGIN {FS="<"} {print $1}')
    printf "%10s %8s %8s %8s %8s %8s %8s %8s %8s\n" $TSTAMP $WD_RMB_IN $WD_RMB_OUT $WD_USD_IN $WD_USD_OUT $BK_USD_IN $BK_USD_OUT $BK_RMB_IN $BK_RMB_OUT >> ./refine-gold/$DATE0

done
