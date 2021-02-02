import numpy as np
import xarray as xr

surf_ds=xr.open_dataset('/home/lzhenn/workspace/xmhu-largerAU/surfdata_1.9x2.5_simyr2000_c091005.nc')
lnd_new_ds=xr.open_dataset('/home/lzhenn/workspace/xmhu-largerAU/domain.lnd.fv19_25_gx1PT.210128.nc')
lnd_old_ds=xr.open_dataset('/home/lzhenn/workspace/xmhu-largerAU/domain.lnd.fv1.9x2.5_gx1v6.090206.nc')

imask_new=lnd_new_ds.mask
ifrac_new=lnd_new_ds.frac
ifrac_old=lnd_old_ds.frac

ifrac_diff=ifrac_new-ifrac_old
nsoil=surf_ds.nlevsoi
npft=surf_ds.lsmpft
# mask
surf_ds.PFTDATA_MASK.values=imask_new.values

# land frac
surf_ds.LANDFRAC_PFT.values=ifrac_new.values

# soil color
surf_ds.SOIL_COLOR.values=np.where(ifrac_diff >0, 20, surf_ds.SOIL_COLOR)

# pct sand
#for ii in nsoil.values:
#    surf_ds.PCT_SAND.values[ii,:,:]=np.where(ifrac_diff >0, 100, surf_ds.PCT_SAND[ii,:,:].values)

# wetland, lake, glacier
surf_ds.PCT_WETLAND.values=np.where(ifrac_diff >0, 0, surf_ds.PCT_WETLAND)
surf_ds.PCT_LAKE.values=np.where(ifrac_diff >0, 0, surf_ds.PCT_LAKE)
surf_ds.PCT_GLACIER.values=np.where(ifrac_diff >0, 0, surf_ds.PCT_GLACIER)
surf_ds.PCT_URBAN.values=np.where(ifrac_diff>0, 0, surf_ds.PCT_URBAN)

# set pct_pft 0 -- bare ground to 100%
surf_ds.PCT_PFT.values[0,:,:]=np.where(ifrac_diff>0, 100,surf_ds.PCT_PFT[0,:,:].values)

for ii in npft.values[1:]:
    surf_ds.PCT_PFT.values[ii,:,:]=np.where(ifrac_diff>0, 0,surf_ds.PCT_PFT[ii,:,:].values)


surf_ds.to_netcdf('/home/lzhenn/workspace/xmhu-largerAU/surfdata_1.9x2.5_simyr2000_c210202.nc')

