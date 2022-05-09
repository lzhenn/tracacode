
CASE_DIR=/WORK/sysu_hjkx_ys/huxm/CESM/B2000_Drake_Closure/
CESM_INPUT=/WORK/sysu_hjkx_ys/cesm/input/
WRK_DIR=/WORK/sysu_hjkx_ys/huxm/Drake_Closure/
SCRIPT_DIR=`pwd`

LID=`date +%y%m%d`
LID_LONG=`date +%Y%m%d`
cd $CASE_DIR

echo "M1. link mapping/domain files" 

ln -sf ${WRK_DIR}/domain.lnd.fv19_25_gx1v6.${LID}.nc ${CESM_INPUT}/share/domains/
ln -sf ${WRK_DIR}/domain.ocn.gx1v6.${LID}.nc ${CESM_INPUT}/share/domains/

./xmlchange LND_DOMAIN_FILE=domain.lnd.fv19_25_gx1v6.${LID}.nc
./xmlchange ATM_DOMAIN_FILE=domain.lnd.fv19_25_gx1v6.${LID}.nc
./xmlchange ICE_DOMAIN_FILE=domain.ocn.gx1v6.${LID}.nc
./xmlchange OCN_DOMAIN_FILE=domain.ocn.gx1v6.${LID}.nc

ln -sf ${WRK_DIR}/map_fv19_25_TO_gx1v6_*.${LID}.nc ${CESM_INPUT}/cpl/gridmaps/fv1.9x2.5/
ln -sf ${WRK_DIR}/map_gx1v6_TO_fv19_25_*.${LID}.nc ${CESM_INPUT}/cpl/gridmaps/gx1v6/


./xmlchange ATM2OCN_FMAPNAME=cpl/gridmaps/fv1.9x2.5/map_fv19_25_TO_gx1v6_aave.${LID}.nc
./xmlchange ATM2OCN_SMAPNAME=cpl/gridmaps/fv1.9x2.5/map_fv19_25_TO_gx1v6_blin.${LID}.nc
./xmlchange ATM2OCN_VMAPNAME=cpl/gridmaps/fv1.9x2.5/map_fv19_25_TO_gx1v6_patc.${LID}.nc

./xmlchange OCN2ATM_FMAPNAME=cpl/gridmaps/gx1v6/map_gx1v6_TO_fv19_25_aave.${LID}.nc
./xmlchange OCN2ATM_SMAPNAME=cpl/gridmaps/gx1v6/map_gx1v6_TO_fv19_25_aave.${LID}.nc
./xmlchange CLM_FORCE_COLDSTART=on

echo "M2. Config template files"

cp ${SCRIPT_DIR}/../template/user_nl_* ./
WRK_DIR_ESC=${WRK_DIR//\//\\/}
# cam
sed -i "/bnd_topo/s/^.*/bnd_topo = \'${WRK_DIR_ESC}USGS-gtopo30_1.9x2.5_remap_c${LID}.nc\'/g" user_nl_cam # be careful to modify '/' to '\/' in sed command
# cice
sed -i "/kmt_file/s/^.*/kmt_file = \'${WRK_DIR_ESC}topography_${LID_LONG}.ieeei4\'/g" user_nl_cice # be careful to modify '/' to '\/' in sed command
# pop2
sed -i "/topography_file/s/^.*/topography_file = \'${WRK_DIR_ESC}topography_${LID_LONG}.ieeei4\'/g" user_nl_pop2 # be careful to modify '/' to '\/' in sed command
sed -i "/region_mask_file/s/^.*/region_mask_file = \'${WRK_DIR_ESC}region_mask_${LID_LONG}.ieeei4\'/g" user_nl_pop2 # be careful to modify '/' to '\/' in sed command
sed -i "/init_ts_file/s/^.*/init_ts_file = \'${WRK_DIR_ESC}ts_PHC2_jan_ic_gx1v6_${LID_LONG}.ieeer8\'/g" user_nl_pop2 # be careful to modify '/' to '\/' in sed command
sed -i "/region_mask_file/s/^.*/region_mask_file = \'${WRK_DIR_ESC}region_mask_${LID_LONG}.ieeei4\'/g" user_nl_pop2 # be careful to modify '/' to '\/' in sed command
# clm
sed -i "/fsurdat/s/^.*/fsurdat = \'${WRK_DIR_ESC}surfdata_1.9x2.5_simyr2000_c${LID}.nc\'/g" user_nl_clm # be careful to modify '/' to '\/' in sed command


# Source mod

echo "M3. SourceMod F90"
cp $SCRIPT_DIR/../f90/* ${CASE_DIR}/SourceMods/src.cam/



