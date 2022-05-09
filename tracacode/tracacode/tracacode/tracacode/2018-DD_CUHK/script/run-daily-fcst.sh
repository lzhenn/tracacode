#!/bin/sh

LID=`date -d '1 days ago' +%Y%m%d`
LID_NLS=`date -d '1 days ago' +%Y-%m-%d`
LID_NLE=`date -d '-2 days ago' +%Y-%m-%d` # 3 days later, for forecast

WPSDIR=/home/lzhenn/package/WPS
WRFDIR=/home/lzhenn/array/lzhenn/WRFV3/run
WORKDIR=/home/lzhenn/workspace/wrf-sdpwfe
LOGFILE=/home/lzhenn/workspace/wrf-sdpwfe/sys-log/${LID}.log
GFSDIR=/home/lzhenn/array/lzhenn/gfs_fcst/$LID



############ Fetch GFS ##############

echo "Forecast ${LID_NLS} to ${LID_NLE}"
echo "Fetching GFS data..."
python fetch_gfs.py

############## WPS ##################
cd $WPSDIR 
# Clean WPS data

echo "Clean WPS..."
rm -f met_em.*
rm -f GFS:*
rm -f SST:*

# Process GFS

## Modify date and GFS
echo "Working on WPS..."
sed -i "/prefix/s/^.*/ prefix = 'GFS',/g" namelist.wps
sed -i "/start_date/s/^.*$/ start_date = '${LID_NLS}_12:00:00','${LID_NLS}_12:00:00','${LID_NLS}_12:00:00','${LID_NLS}_12:00:00',/g" namelist.wps
sed -i "/end_date/s/^.*$/ end_date = '${LID_NLE}_12:00:00','${LID_NLE}_12:00:00','${LID_NLE}_12:00:00','${LID_NLE}_12:00:00',/g" namelist.wps

echo "Working on WPS->Ungrib GFS..."
ln -sf ungrib/Variable_Tables/Vtable.GFS Vtable
./link_grib.csh $GFSDIR/gfs* 
./ungrib.exe >& $LOGFILE

## Modify  GFS SST
echo "Working on WPS->Ungrib SST..."
sed -i "/prefix/s/^.*/ prefix = 'SST',/g" namelist.wps

ln -sf ungrib/Variable_Tables/Vtable.SST Vtable
./ungrib.exe >& $LOGFILE

echo "Working on WPS->Metgrid..."
./metgrid.exe >& $LOGFILE

############## WRF ##################
echo "Working on WRF->REAL..."
cd $WRFDIR

YYYY_NLS=`date -d '1 days ago' +%Y`
YYYY_NLE=`date -d '-2 days ago' +%Y` # 3 days later, for forecast

MM_NLS=`date -d '1 days ago' +%m`
MM_NLE=`date -d '-2 days ago' +%m` # 3 days later, for forecast
  

DD_NLS=`date -d '1 days ago' +%d`
DD_NLE=`date -d '-2 days ago' +%d` # 3 days later, for forecast


sed -i "/start_year/s/^.*$/ start_year                          = ${YYYY_NLS}, ${YYYY_NLS}, ${YYYY_NLS}, ${YYYY_NLS},/g" namelist.input
sed -i "/end_year/s/^.*$/ end_year                            = ${YYYY_NLE}, ${YYYY_NLE}, ${YYYY_NLE}, ${YYYY_NLE},/g" namelist.input
sed -i "/start_month/s/^.*$/ start_month                          = ${MM_NLS}, ${MM_NLS}, ${MM_NLS}, ${MM_NLS},/g" namelist.input
sed -i "/end_month/s/^.*$/ end_month                          = ${MM_NLE}, ${MM_NLE}, ${MM_NLE}, ${MM_NLE},/g" namelist.input
sed -i "/start_day/s/^.*$/ start_day                          = ${DD_NLS}, ${DD_NLS}, ${DD_NLS}, ${DD_NLS},/g" namelist.input
sed -i "/end_day/s/^.*$/ end_day                          = ${DD_NLE}, ${DD_NLE}, ${DD_NLE}, ${DD_NLE},/g" namelist.input

rm -f met_em.d0*
rm -f wrfout_d0*
rm -f wrfinput_d0*
rm -f wrflowinp_d0*
rm -f wrfbdy_d0*
ln -sf $WPSDIR/met_em.d0* ./
./real.exe >& $LOGFILE

echo "Working on WRF->WRF..."
mpirun -np 18 ./wrf.exe

############## POST-PROCESS ##################
echo "Post-processing..."
cd $WORKDIR
sh post_process.sh


