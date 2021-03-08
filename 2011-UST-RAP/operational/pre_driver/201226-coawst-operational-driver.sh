# This script servers as the top driver of the operational
# forecast system of the COAWST system. It calls a series of 
# component drivers to preprocess and to coordinate the coupled 
# system run.


WRF_STRT_DATE="2020-12-19"
WRF_END_DATE="2020-12-26"
SWAN_STRT_DATE=${WRF_STRT_DATE//-/} # YYYYMMDD style
SWAN_END_DATE=${WRF_END_DATE//-/}

STRT_HR="12"

ATM_RA_ROOT=/home/metctm1/array/data/GBA_operational/gfs
OCN_RA_ROOT=/home/metctm1/array/data/GBA_operational/hycom

WRF_ROOT=/home/metctm1/array/app/WRF412
COAWST_ROOT=/home/metctm1/array/app/COAWST/COAWST_operational



PROJ_NAME=GBA_operational



# generate paths
CWST_PROJ_PATH=${COAWST_ROOT}/Projects/${PROJ_NAME}
WPS_PATH=$WRF_ROOT/WPS-4.1
WRF_PATH=$WRF_ROOT/WRF-4.1.2/run


# Execute preprocessings of the three components
sh wrf_prepro_driver_201226.sh  $WRF_PATH $COAWST_ROOT &
#sh roms_prepro_driver_201226.sh &
#sh swan_prepro_driver_201226.sh  $SWAN_STRT_DATE $SWAN_END_DATE $STRT_HR $CWST_PROJ_PATH &
wait
