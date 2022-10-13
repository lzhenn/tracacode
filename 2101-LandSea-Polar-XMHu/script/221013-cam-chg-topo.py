#!/usr/bin/env python3
'''
 Change topo data of CESM1
'''

import xarray as xr

topo_in='~/USGS-gtopo30_1.9x2.5_remap_c050602.nc'
topo_out='!/no_topo_exan.nc'

vars=['SGH', 'SGH30']

ds_topo=xr.load_dataset(topo_in)

for var in vars:
    ds_topo[var].values=xr.where(
        ds_topo.lat>-60 & ds_topo['LANDFRAC']>0, 0.0, ts_topo[var])

ds_topo[var].values=xr.where(
    ds_topo.lat>-60 & ds_topo['LANDFRAC']>0, 50.0, ts_topo[var])

ds_topo.to_netcdf(topo_out)
