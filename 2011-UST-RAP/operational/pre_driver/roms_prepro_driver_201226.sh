STRT_DATE=$1
END_DATE=$2
COAWST_ROOT=$3

STRT_DATE_PACK=${STRT_DATE//-/} # YYYYMMDD style
END_DATE_PACK=${END_DATE//-/}


OCN_RA_ROOT=/home/metctm1/array/data/GBA_operational/hycom_subset/

source ~/.bashrc
source ~/.bashrc_anaconda

echo ">>>>ROMS: Fetch HYCOM from "${STRT_DATE_PACK}"12Z to "${END_DATE_PACK}"12Z..."
cd ./roms_drv

#rm -f $OCN_RA_ROOT/*
#python down-hycom-exp930-fcst-subset.py $STRT_DATE_PACK $OCN_RA_ROOT

echo ">>>>ROMS: Create ICBC..."
MATLAB_DATE=${STRT_DATE//-/,}
sed -i "/T1 = /c\T1 = datetime(${MATLAB_DATE},12,0,0);" gen_icbc_fcst_exp930.m
matlab -nodesktop -nosplash -r gen_icbc_fcst_exp930

cd ..

