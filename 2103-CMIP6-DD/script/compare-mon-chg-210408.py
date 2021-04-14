import cmaps
import numpy as np
import xarray as xr
import cartopy.crs as ccrs
import matplotlib
import matplotlib.pyplot as plt
matplotlib.use('Agg') 

# Constants
BIGFONT=22
MIDFONT=18
SMFONT=14

MAP_RES='110m'
FIG_FMT='png'
MON='Sep'
CMIP_ARC='/home/metctm1/array/data/cmip6/cmip6-mpi-esm-hr/'

ds_ref=xr.load_dataset(CMIP_ARC+'ts_Amon_MPI-ESM1-2-HR_ssp245_r1i1p1f1_gn_202001-202412.nc')
ds_sen=xr.load_dataset(CMIP_ARC+'ts_Amon_MPI-ESM1-2-HR_ssp245_r1i1p1f1_gn_204501-204912.nc')

ts_ref=ds_ref['ts'].loc['2020-09-16',:,:]-273.15
ts_sen=ds_sen['ts'].loc['2045-09-16',:,:]-273.15



# Get the map projection information
fig = plt.figure(figsize=(12,8), frameon=True)
proj = ccrs.PlateCarree(central_longitude=180.0, globe=None) 
ax = fig.add_axes([0.08, 0.03, 0.8, 0.8], projection=proj)


cmap=cmaps.ViBlGrWhYeOrRe
levels=np.linspace(-4,4,36)
ts_diff=(ts_sen.values[0,:,:]-ts_ref.values[0,:,:])
cf=ax.contourf(ts_ref.lon, ts_ref.lat, ts_diff, 
    levels=levels, extend='both', transform=ccrs.PlateCarree(), cmap=cmap)
ax.coastlines()
ax.set_global()
plt.title('MPI-ESM1-2-HR 2045 (SSP245) minus 2020 (SSP245) '+MON+' TS',fontsize=MIDFONT)

# add color bar in final
cax=fig.add_axes([0.15, 0.05, 0.7, 0.051])# left, down, right, up
cbar = fig.colorbar(cf,ticks=range(-4, 5), cax=cax, orientation='horizontal')

plt.savefig('../fig/ts.'+MON+'.'+FIG_FMT, dpi=90, bbox_inches='tight')
plt.close('all')

