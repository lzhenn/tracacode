#/usr/bin/env python3

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
