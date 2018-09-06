#!/bin/sh

WPSDIR=../WPS
WRFDIR=/home/lzhenn/array/lzhenn/WRFV3/run
WORKDIR=/home/lzhenn/workspace/wrf-sdpwfe
LOGFILE=/home/lzhenn/workspace/wrf-sdpwfe/sys-log/${LID}.log
FNLDIR=../fnl



############## WPS ##################
cd $WPSDIR 
# Clean WPS data

for II in $( seq 2000 2018)
do
    echo "Clean WPS"
    rm -f FILE:*
    LID_NLS=${II}-05-01
    LID_NLE=${II}-06-09

    ## Modify date and FILE 
    echo "Working on WPS in" $II
    sed -i "/start_date/s/^.*$/ start_date = '${LID_NLS}_00:00:00','${LID_NLS}_00:00:00','${LID_NLS}_00:00:00','${LID_NLS}_00:00:00',/g" namelist.wps
    sed -i "/end_date/s/^.*$/ end_date = '${LID_NLE}_12:00:00','${LID_NLE}_12:00:00','${LID_NLE}_12:00:00','${LID_NLE}_12:00:00',/g" namelist.wps

    echo "Working on WPS->Ungrib GFS..."
    ./link_grib.csh $FNLDIR/fnl_${II}0[5-6]* 
    ./ungrib.exe

    echo "Working on WPS->Metgrid..."
    ./metgrid.exe

    mkdir met_em/${II}
    mv met_em* met_em/${II}
    
    echo ${II} "WPS done!"
done


