
STRT_DATE=$1
END_DATE=$2
STRT_HR=$3
CWST_PROJ_PATH=$4

STRT_DATE_PACK=${STRT_DATE//-/} # YYYYMMDD style
END_DATE_PACK=${END_DATE//-/}


SSYYYYMMDDHH=${STRT_DATE_PACK}.${STRT_HR}
EEYYYYMMDDHH=${END_DATE_PACK}.${STRT_HR}
echo ">>>>SWAN: Adjust files"
cp ${CWST_PROJ_PATH}/swan_d01.sample.in ${CWST_PROJ_PATH}/swan_d01.in
sed -i "s/ssyyyymmdd.hh/${SSYYYYMMDDHH}/g" ${CWST_PROJ_PATH}/swan_d01.in
sed -i "s/eeyyyymmdd.hh/${EEYYYYMMDDHH}/g" ${CWST_PROJ_PATH}/swan_d01.in
