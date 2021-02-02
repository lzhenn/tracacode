import numpy as np
import xarray as xr
im_w=384
im_h=320

topo_ds=xr.open_dataset('/home/lzhenn/workspace/xmhu-largerAU/USGS-gtopo30_1.9x2.5_remap_c050602.nc')
lnd_ds=xr.open_dataset('/home/lzhenn/workspace/xmhu-largerAU/domain.lnd.fv19_25_gx1PT.210128.nc')

ifrac_new=lnd_ds.frac
topo_ds.LANDFRAC.values=ifrac_new.values
topo_ds.to_netcdf('/home/lzhenn/workspace/xmhu-largerAU/USGS-gtopo30_1.9x2.5_remap_c210202.nc')

