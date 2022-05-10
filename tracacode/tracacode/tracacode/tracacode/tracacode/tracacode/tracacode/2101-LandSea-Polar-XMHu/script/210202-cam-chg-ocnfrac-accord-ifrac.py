import numpy as np
import xarray as xr
im_w=384
im_h=320

ocnfra_ds=xr.open_dataset('/home/lzhenn/workspace/xmhu-largerAU/domain.camocn.1.9x2.5_gx1v6_090403.nc')
lnd_ds=xr.open_dataset('/home/lzhenn/workspace/xmhu-largerAU/domain.lnd.fv19_25_gx1PT.210128.nc')

ifrac_new=lnd_ds.frac
ocnfra_ds.frac.values=1-ifrac_new.values
ocnfra_ds.to_netcdf('/home/lzhenn/workspace/xmhu-largerAU/domain.camocn.1.9x2.5_gx1v6_210202.nc')

