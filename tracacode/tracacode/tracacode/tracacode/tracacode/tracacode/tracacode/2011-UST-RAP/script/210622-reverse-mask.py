import numpy as np
import xarray as xr

data_root='/home/metctm1/array/data/Calypso/'

roms_ds=xr.load_dataset(data_root+'roms_d03.nc.first_assign')
mask=roms_ds['mask_rho']
mask.values = 1 - mask.values
print(mask)
roms_ds.to_netcdf(data_root+'roms_d03.nc', mode='a')
