#!/bin/sh

LID_NLS=$1
LID_NLE=$2
STRT_HR=$3
GFSDIR=$4
WPSDIR=$5

LOGFILE=wps.log
echo ">>>>WRF-WPS: ${LID_NLS} to ${LID_NLE}"

############## WPS ##################
CURRDIR=`pwd`
cd $WPSDIR 
# Clean WPS data

echo ">>>>WRF-WPS:Clean Pre-existed Files..."
rm -f met_em.*
rm -f GFS:*
rm -f ERA*
rm -f SST:*

# Process GFS

## Modify date and GFS
sed -i "/prefix/s/^.*/ prefix = 'GFS',/g" namelist.wps
sed -i "/start_date/s/^.*$/ start_date = '${LID_NLS}_${STRT_HR}:00:00','${LID_NLS}_${STRT_HR}:00:00','${LID_NLS}_${STRT_HR}:00:00','${LID_NLS}_${STRT_HR}:00:00',/g" namelist.wps
sed -i "/end_date/s/^.*$/ end_date = '${LID_NLE}_${STRT_HR}:00:00','${LID_NLE}_${STRT_HR}:00:00','${LID_NLE}_${STRT_HR}:00:00','${LID_NLE}_${STRT_HR}:00:00',/g" namelist.wps

echo ">>>>WRF-WPS:Working on WPS->Ungrib GFS..."
ln -sf ungrib/Variable_Tables/Vtable.GFS Vtable
./link_grib.csh $GFSDIR/*.grib2
./ungrib.exe >& $LOGFILE

## Modify  GFS SST
echo ">>>>WRF-WPS:Working on WPS->Ungrib SST..."
sed -i "/prefix/s/^.*/ prefix = 'SST',/g" namelist.wps

ln -sf ungrib/Variable_Tables/Vtable.SST Vtable
./ungrib.exe >& $LOGFILE

echo ">>>>WRF-WPS:Working on WPS->Metgrid..."
sed -i "/fg_name/s/^.*/ fg_name = 'GFS', 'SST',/g" namelist.wps
mpirun -np 8 ./metgrid.exe >& $LOGFILE

cd $CURRDIR
