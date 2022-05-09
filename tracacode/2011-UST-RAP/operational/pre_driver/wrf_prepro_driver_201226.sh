STRT_DATE=$1
END_DATE=$2
INIT_HR=$3
COAWST_ROOT=$4

STRT_DATE_PACK=${STRT_DATE//-/} # YYYYMMDD style
END_DATE_PACK=${END_DATE//-/}

ATM_RA_ROOT=/home/metctm1/array/data/GBA_operational/gfs
WRF_ROOT=/home/metctm1/array/app/WRF412/

WPS_PATH=$WRF_ROOT/WPS-4.1
WRF_PATH=$WRF_ROOT/WRF-4.1.2/run

cp ../lib/namelist.wps $WPS_PATH
cp ../lib/namelist.input $WRF_PATH
echo ">>>>WRF: Fetch GFS from "${STRT_DATE_PACK}${INIT_HR}"Z to "${END_DATE_PACK}${INIT_HR}"Z..."
/home/pathsys/bin/get_envf_gfs_0.25deg.archive ${STRT_DATE_PACK}${INIT_HR}  ${END_DATE_PACK}${INIT_HR} $ATM_RA_ROOT

cd wrf_drv/
sh auto_wps_gfs0d25.sh $STRT_DATE $END_DATE $INIT_HR $ATM_RA_ROOT $WPS_PATH
sh run_real.sh $STRT_DATE_PACK $END_DATE_PACK $WRF_PATH $WPS_PATH


ln -sf $WRF_PATH/wrflow* $COAWST_ROOT
ln -sf $WRF_PATH/wrffdda* $COAWST_ROOT
ln -sf $WRF_PATH/wrfinput* $COAWST_ROOT
ln -sf $WRF_PATH/wrfbdy* $COAWST_ROOT
cp $WRF_PATH/namelist.input $COAWST_ROOT
