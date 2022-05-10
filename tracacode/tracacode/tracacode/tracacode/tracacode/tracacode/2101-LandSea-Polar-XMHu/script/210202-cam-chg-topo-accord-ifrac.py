import sys, datetime
import numpy as np
import xarray as xr

args=sys.argv
if len(args)==2:
    WRK_DIR=args[1]

terrain_height=10 # in meter
terrain_phis=terrain_height*9.8 # in pgm


timestamp_grid=datetime.datetime.now().strftime('%y%m%d')

topo_ds=xr.open_dataset(WRK_DIR+'USGS-gtopo30_1.9x2.5_remap_c050602.nc')
lnd_new_ds=xr.open_dataset(WRK_DIR+'domain.lnd.fv19_25_gx1v6.'+timestamp_grid+'.nc')
lnd_old_ds=xr.open_dataset(WRK_DIR+'domain.lnd.fv1.9x2.5_gx1v6.090206.nc')
ifrac_new=lnd_new_ds.frac
ifrac_old=lnd_old_ds.frac

ifrac_diff=ifrac_new-ifrac_old

topo_ds.LANDFRAC.values=ifrac_new.values
topo_ds.PHIS.values=np.where(ifrac_diff > 0, terrain_phis, topo_ds.PHIS)

topo_ds.to_netcdf(WRK_DIR+'USGS-gtopo30_1.9x2.5_remap_c'+timestamp_grid+'.nc')

