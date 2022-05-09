
CESMROOT=/WORK/sysu_hjkx_ys/soft/cesm1_2_2
INPUTDIR=/WORK/sysu_hjkx_ys/cesm/input
WRK_DIR=/WORK/sysu_hjkx_ys/huxm/Drake_Closure
LID_SHORT=`date +%y%m%d`
LID_LONG=`date +%Y%m%d`

cd $WRK_DIR
${CESMROOT}/tools/mapping/gen_mapping_files/gen_cesm_maps.sh -fatm ${INPUTDIR}/share/scripgrids/fv1.9x2.5_090205.nc -natm fv19_25 -focn gx1v6_chg_${LID_SHORT}.nc -nocn gx1v6 --nogridcheck

${CESMROOT}/tools/mapping/gen_domain_files/gen_domain -m ${WRK_DIR}/map_gx1v6_TO_fv19_25_aave.${LID_SHORT}.nc -o gx1v6 -l fv19_25

