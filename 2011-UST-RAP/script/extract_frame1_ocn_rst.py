#/usr/bin/env python3

<<<<<<< HEAD
import xarray as xr    
in_fn='/home/lzhenn/Njord_dev/njord_rst_d01.bck.nc'
out_fn='/home/lzhenn/Njord_dev/njord_rst_d01.nc'

var3d_list=['zeta','ubar','vbar','ubar_stokes','vbar_stokes']
var4d_list=[
    'AKv','rho','salt','temp','u',
    'v','u_stokes','v_stokes']

ds=xr.load_dataset(in_fn)
for itm in var3d_list:
    ds[itm].values[0,:,:]=ds[itm].values[1,:,:]
for itm in var4d_list:
    ds[itm].values[0,:,:,:]=ds[itm].values[1,:,:,:]
ds.to_netcdf(in_fn,'a')
=======
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
>>>>>>> 1166f2bae7b90473a67c3d3008c33b2fdd22ce85
