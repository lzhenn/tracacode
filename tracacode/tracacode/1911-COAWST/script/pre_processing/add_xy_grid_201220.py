import xarray as xr
import numpy as np
ds_grid = xr.open_dataset('/users/b145872/project-dir/data/hycom/goni/hycom_glby_930_2020102712_t000_ts3z.nc', decode_times=False)
print(ds_grid)

ds_grid['X']=np.linspace(0,1000)

