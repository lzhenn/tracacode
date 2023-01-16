#!/bin/env python3
import xarray as xr
import cmaps
import cartopy.crs as ccrs
import matplotlib
import matplotlib.pyplot as plt
matplotlib.use('Agg')
import numpy as np 
import wrf
from netCDF4 import Dataset

cases= ['20150301e%02d' % case for case in range(1, 5)]

sen_path='/home/lzhenn/array74/CMAQ2way-revised/cmaq_run/wrf-cmaq/outputs/'
ctrl_path='/home/metctm1/array_hq133/CMAQ2way-revised/cmaq_run/wrf-cmaq/outputs/'
var = 'ACSWDNBC'
#var = 'SW_ZBBCDDIR'


infn = sen_path+'/'+cases[0]+'/wrfout_d01_2015-03-01_00:00:00'

wrf_file=Dataset(infn)
senvar = wrf.getvar(wrf_file, var,timeidx=wrf.ALL_TIMES)
proj=wrf.get_cartopy(senvar)
lats, lons = wrf.latlon_coords(senvar)

infn = ctrl_path+'/'+cases[0]+'/wrfout_d01_2015-03-01_00:00:00'
wrf_file=Dataset(infn)
ctrlvar = wrf.getvar(wrf_file, var,timeidx=wrf.ALL_TIMES)

for case in cases[1:]:
    # sensitive run
    infn = sen_path+'/'+case+'/wrfout_d01_2015-03-01_00:00:00'
    wrf_file=Dataset(infn)
    tempvar=wrf.getvar(wrf_file, var,timeidx=wrf.ALL_TIMES)
    senvar=xr.concat([senvar, tempvar], dim='ens')
    
    # ctrl_run
    infn = ctrl_path+'/'+case+'/wrfout_d01_2015-03-01_00:00:00'
    wrf_file=Dataset(infn)
    tempvar=wrf.getvar(wrf_file, var,timeidx=wrf.ALL_TIMES)
    ctrlvar=xr.concat([ctrlvar, tempvar], dim='ens')

cmap=cmaps.BlGrYeOrReVi200
levels=np.linspace(-1000,1000,101)

senvar_mean=senvar.mean(dim=['ens', 'Time'])
ctrlvar_mean=ctrlvar.mean(dim=['ens', 'Time'])


fig = plt.figure(figsize=[10, 8],frameon=True)

# Set projection and plot the main figure
ax = fig.add_axes([0.08, 0.01, 0.8, 0.94], projection=proj)

# add gridlines
gl = ax.gridlines(crs=ccrs.PlateCarree(), draw_labels=True,
        color='grey', linestyle='--', linewidth=1)
gl.top_labels = False
gl.right_labels = False

ax.coastlines()

plt.contourf(
    wrf.to_np(lons), wrf.to_np(lats), 
    wrf.to_np(senvar_mean)-wrf.to_np(ctrlvar_mean),
    levels=levels, extend='both', 
    transform=ccrs.PlateCarree(), cmap=cmap)

plt.colorbar(ax=ax, shrink=0.7,extendfrac='auto')

plt.savefig(
        '../fig/230116-brc-plot.png', 
        dpi=120, bbox_inches='tight')
plt.close()
