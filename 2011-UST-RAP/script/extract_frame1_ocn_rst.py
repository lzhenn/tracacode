#/usr/bin/env python3

import lib
import datetime
import pandas as pd
import xarray as xr    
print('Read Config...')
cfg_hdl=lib.cfgparser.read_cfg('./conf/config.ini')

etl_strt_time=datetime.datetime.strptime(cfg_hdl['CORE']['etl_strt_ts'],'%Y%m%d%H%M')
etl_end_time=datetime.datetime.strptime(cfg_hdl['CORE']['etl_end_ts'],'%Y%m%d%H%M')
dt=datetime.timedelta(hours=6)

vtable=pd.read_csv('./db/vtable.min.csv')
    
print('Construct CMIP Container...')
#print(vtable)
for idx, itm in vtable.iterrows():
    # exceptions
    if itm['src_v']=='orog' or itm['src_v']=='sftlf':
        continue
    cmip=lib.cmip_container.cmip_container(cfg_hdl, itm)
    print('deal with'+cmip.fn)
    ds=xr.open_dataset(cmip.fn)
    ds.sel(time=slice(etl_strt_time,etl_end_time)).to_netcdf(cmip.etlfn)
    ds.close()