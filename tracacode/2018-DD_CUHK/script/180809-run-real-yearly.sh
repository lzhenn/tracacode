#!/bin/sh

WPSDIR=/users/yangsong3/L_Zealot/wrf/WPS
WRFDIR=../WRFV3/run
WORKDIR=/home/lzhenn/workspace/wrf-sdpwfe
LOGFILE=/home/lzhenn/workspace/wrf-sdpwfe/sys-log/${LID}.log
FNLDIR=../fnl



############## WPS ##################

cd $WRFDIR
for II in $( seq 2000 2005)
do    
    echo "Working on WRF->REAL..."

    ## Modify date and FILE 
    
    echo "Working on WRF->REAL in" $II
    sed -i "/start_year/s/^.*$/ start_year                          = ${II}, ${II}, ${II}, ${II},/g" namelist.input
    sed -i "/end_year/s/^.*$/ end_year                            = ${II}, ${II}, ${II}, ${II},/g" namelist.input

    rm -f met_em.d0*
    rm -f wrfout_d0*
    rm -f wrfinput_d0*
    rm -f wrflowinp_d0*
    rm -f wrfbdy_d0*
    ln -sf $WPSDIR/met_em/${II}/met_em* ./
    mpirun -np 16 ./real.exe

    mkdir ./precon/${II}
    mv wrfbdy* ./precon/${II}
    mv wrflowinp_d0* ./precon/${II}
    mv wrfinput* ./precon/${II}
    
    echo ${II} "REAL done!"
done


