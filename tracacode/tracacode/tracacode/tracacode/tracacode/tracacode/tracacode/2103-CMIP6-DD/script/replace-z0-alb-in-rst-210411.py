import xarray as xr
import os 

SRC_DIR='/home/metctm1/array/workspace/cmip6-to-wrfinterm/db/restart_2040/'
REP_DIR='/home/metctm1/array_hq132/cmip6-wrf-arch/ssp585/'
TGT_DIR=REP_DIR

var_list=['NOAH_ALB', 'NOAH_Z0', 'ALBEDO', 'ALBBCK', 'Z0']
domain_list=['d01','d02','d03','d04']

for year in range(2040, 2050):
    syear=str(year)
    for domain in domain_list:
        src_fn=SRC_DIR+'wrfrst_'+domain+'_2040-05-21_01:00:00'
        rep_fn=REP_DIR+syear+'/wrfrst_'+domain+'_'+syear+'-05-21_00:00:00'
        tgt_fn=rep_fn

        print('deal with '+rep_fn)
        ds_src=xr.load_dataset(src_fn)
        ds_tgt=xr.load_dataset(rep_fn)

        for var in var_list:
            ds_tgt[var].values=ds_src[var].values

        ds_tgt.to_netcdf(tgt_fn, mode='a')

