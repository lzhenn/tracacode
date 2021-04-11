from netCDF4 import Dataset
import cmaps
import numpy as np
import xarray as xr
import cartopy.crs as ccrs
import cartopy.io.shapereader as shpreader
import shapely.geometry as sgeom
import matplotlib
import matplotlib.pyplot as plt
matplotlib.use('Agg') 

import os, subprocess
import wrf
#from wrf import combine_files, getvar, get_cartopy, latlon_coords, cartopy_xlim, cartopy_ylim, to_np

REF_DIR='/home/metctm1/array_hq132/cmip6-wrf-arch/ref_2020/'
SEN_DIR='/home/metctm1/array_hq132/cmip6-wrf-arch/ssp245/2045/'

# Open the NetCDF file
fn_stream=subprocess.check_output('ls '+REF_DIR+'wrfout_d04_2020-06-0?_06*', shell=True).decode('utf-8')
fn_list=fn_stream.split()
wrf_list=[Dataset(itm) for itm in fn_list]
var_ref = wrf.getvar(wrf_list, 'TSK', timeidx=wrf.ALL_TIMES, method='cat')
print(var_ref)
exit()
#ncfile_ref = Dataset(REF_DIR+'wrfout_d04_2020-06-01_00:00:00')
# Get the TSK 
var_ref = getvar(ncfile_ref, "TSK")

# Get the latitude and longitude points
lats, lons = latlon_coords(var_ref)

# Province shp file
#province_shp_file=os.getenv('SHP_LIB')+'/cnmap/cnhimap.dbf'
#county_shp_file=os.getenv('SHP_LIB')+'/cnmap/county_2004.dbf'

# read shp files
#province_shp=shpreader.Reader(province_shp_file).geometries()
#county_shp = shpreader.Reader(county_shp_file).geometries()

# Set figure size
#proj = ccrs.Mercator(central_longitude=115., min_latitude=-80.0, max_latitude=84.0, globe=None, 
#        latitude_true_scale=22.0, false_easting=0.0, false_northing=0.0, scale_factor=None)
proj=get_cartopy(var_ref)

fig = plt.figure(figsize=[10, 8],frameon=True)

# Set projection and plot the main figure
ax = fig.add_axes([0.08, 0.01, 0.8, 0.94], projection=proj)

# Set figure extent
#ax.set_extent([109, 118, 20, 26],crs=ccrs.PlateCarree())

# plot shp boundaries
#ax.add_geometries(county_shp, ccrs.PlateCarree(),facecolor='none', edgecolor='gray',linewidth=0.5, zorder = 0)
#ax.add_geometries(province_shp, ccrs.PlateCarree(),facecolor='none', edgecolor='black',linewidth=1., zorder = 1)
# *must* call draw in order to get the axis boundary used to add ticks:
#fig.canvas.draw()

#xticks = range(109, 118, 2)
#yticks = range(20, 26, 2) 

cmap=cmaps.ViBlGrWhYeOrRe
plt.contourf(to_np(lons), to_np(lats), to_np(var_ref),50, transform=ccrs.PlateCarree(), cmap=cmap)

# Add a color bar
plt.colorbar(ax=ax, shrink=0.7)

plt.savefig('../fig/tsk.png', dpi=120, bbox_inches='tight')
