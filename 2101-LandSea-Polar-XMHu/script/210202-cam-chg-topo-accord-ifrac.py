import numpy as np
import xarray as xr

topo_ds=xr.open_dataset('/home/lzhenn/workspace/xmhu-largerAU/USGS-gtopo30_1.9x2.5_remap_c050602.nc')
lnd_new_ds=xr.open_dataset('/home/lzhenn/workspace/xmhu-largerAU/domain.lnd.fv19_25_gx1PT.210128.nc')
lnd_old_ds=xr.open_dataset('/home/lzhenn/workspace/xmhu-largerAU/domain.lnd.fv1.9x2.5_gx1v6.090206.nc')
ifrac_new=lnd_new_ds.frac
ifrac_old=lnd_old_ds.frac

ifrac_diff=ifrac_new-ifrac_old

topo_ds.LANDFRAC.values=ifrac_new.values
topo_ds.PHIS.values=np.where(ifrac_diff > 0, 98.0, topo_ds.PHIS)

topo_ds.to_netcdf('/home/lzhenn/workspace/xmhu-largerAU/USGS-gtopo30_1.9x2.5_remap_c210202.nc')

