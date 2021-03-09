# This script servers as the top driver of the operational
# forecast system of the COAWST system. It calls a series of 
# component drivers to preprocess and to coordinate the coupled 
# system run.


# Set up Constants

## Set Basics
STRT_DATE="2020-12-27"
END_DATE="2021-01-03"
INIT_HR="12"

PROJ_NAME=GBA_operational
CPL_IN=coupling_gba.in

## Set Paths
COAWST_ROOT=/home/metctm1/array/app/COAWST/COAWST_operational

## Generate Paths
CWST_PROJ_PATH=${COAWST_ROOT}/Projects/${PROJ_NAME}

# Load-balancing Configurations for Processors Layer
NTASKS_ATM=38
#N_ITAKS_ATM=5
#N_JTAKS_ATM=8

NTASKS_OCN=6
N_ITAKS_OCN=2
N_JTAKS_OCN=3

NTASKS_WAV=4

source ~/.bashrc

# Preprocessing
echo ">>PREPROCESSING..."
cd ./pre_driver
#sh wrf_prepro_driver_201226.sh $STRT_DATE $END_DATE $INIT_HR $COAWST_ROOT
sh roms_prepro_driver_201226.sh $STRT_DATE $END_DATE $COAWST_ROOT
#sh swan_prepro_driver_201226.sh  $STRT_DATE $END_DATE $INIT_HR $CWST_PROJ_PATH 
cd ..
## Change Processors Layer
sed -i "/NnodesATM =/c\ \ \ NnodesATM = ${NTASKS_ATM}" ${CWST_PROJ_PATH}/${CPL_IN}
sed -i "/NnodesWAV =/c\ \ \ NnodesWAV = ${NTASKS_WAV}" ${CWST_PROJ_PATH}/${CPL_IN}
sed -i "/NnodesOCN =/c\ \ \ NnodesOCN = ${NTASKS_OCN}" ${CWST_PROJ_PATH}/${CPL_IN}

sed -i "/NtileI ==/c\ \ \ NtileI == ${N_ITAKS_OCN}" ${CWST_PROJ_PATH}/roms_d01.in
sed -i "/NtileJ ==/c\ \ \ NtileJ == ${N_JTAKS_OCN}" ${CWST_PROJ_PATH}/roms_d01.in

# Run script
cd $COAWST_ROOT
#sh run.sh


# Postprocessing
