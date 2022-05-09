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

# Constants
BIGFONT=22
MIDFONT=18
SMFONT=14

#years=['2020']
years=['2016','2017','2018','2019','2020']
varname='T2'
mon='06'
domain='01'
DIAG_HR='06'  # 06Z--14H, 18Z--02H
MAP_RES='110m'
SEN_DIR='/home/metctm1/array_hq132/cmip6-wrf-arch/bias_ref/cmip6/'
REF_DIR='/home/metctm1/array_hq132/cmip6-wrf-arch/bias_ref/era5/'

title_txt=varname+' Mean Bias (2016-2020, CMIP6-ERA5): '+DIAG_HR+' UTC'
print(DIAG_HR)
# Open the NetCDF file
wrf_list=[]
for iyear in years:
    fn_stream=subprocess.check_output('ls '+SEN_DIR+str(iyear)+'/wrfout_d'+domain+'_*-'+mon+'-??_'+DIAG_HR+'*', shell=True).decode('utf-8')
    fn_list=fn_stream.split()
    print(fn_list)
    wrf_list+=[Dataset(itm) for itm in fn_list]

var_temp=wrf.getvar(wrf_list[0],varname)
var_sen = wrf.getvar(wrf_list, varname, timeidx=wrf.ALL_TIMES, method='cat')
var_sen=var_sen.mean(dim='Time')

wrf_list=[]
for iyear in years:
    fn_stream=subprocess.check_output('ls '+REF_DIR+str(iyear)+'/wrfout_d'+domain+'_*-'+mon+'-??_'+DIAG_HR+'*', shell=True).decode('utf-8')
    fn_list=fn_stream.split()
    print(fn_list)
    wrf_list+=[Dataset(itm) for itm in fn_list]


var_ref = wrf.getvar(wrf_list, varname, timeidx=wrf.ALL_TIMES, method='cat')
var_ref=var_ref.mean(dim='Time')

# Get the latitude and longitude points
lats, lons = wrf.latlon_coords(var_ref)

# shp file
#coast_shp_file=os.getenv('SHP_LIB')+'/china_coast/china_coastline.dbf'
#    province_shp_file=os.getenv('SHP_LIB')+'/china_coast/'
#    county_shp_file=os.getenv('SHP_LIB')+'/cnmap/county_2004.dbf'

# read shp files
#coast_shp=shpreader.Reader(coast_shp_file).geometries()
#    province_shp=shpreader.Reader(province_shp_file).geometries()
#    county_shp = shpreader.Reader(county_shp_file).geometries()

# Set figure size
#proj = ccrs.Mercator(central_longitude=115., min_latitude=-80.0, max_latitude=84.0, globe=None, 
#        latitude_true_scale=22.0, false_easting=0.0, false_northing=0.0, scale_factor=None)
proj=wrf.get_cartopy(var_temp)

fig = plt.figure(figsize=[10, 8],frameon=True)

# Set projection and plot the main figure
ax = fig.add_axes([0.08, 0.01, 0.8, 0.94], projection=proj)

# Set figure extent
#ax.set_extent([109, 118, 20, 26],crs=ccrs.PlateCarree())

# plot shp boundaries
#ax.add_geometries(coast_shp, ccrs.PlateCarree(),facecolor='none', edgecolor='black',linewidth=.5, zorder = 1)
#    ax.add_geometries(county_shp, ccrs.PlateCarree(),facecolor='none', edgecolor='gray',linewidth=0.5, zorder = 0)
#    ax.add_geometries(province_shp, ccrs.PlateCarree(),facecolor='none', edgecolor='black',linewidth=1., zorder = 1)
# *must* call draw in order to get the axis boundary used to add ticks:
#fig.canvas.draw()

#xticks = range(109, 118, 2)
#yticks = range(20, 26, 2) 


cmap=cmaps.BlAqGrWh2YeOrReVi22
levels=np.linspace(-4.5,4.5,13)
plt.contourf(wrf.to_np(lons), wrf.to_np(lats), wrf.to_np(var_sen-var_ref),
        levels=levels, extend='both', transform=ccrs.PlateCarree(), cmap=cmap)


ax.coastlines()
plt.title(title_txt,fontsize=SMFONT)

# Add a color bar
plt.colorbar(ax=ax, shrink=0.7)

plt.savefig('../fig/t2_mean_bias_'+DIAG_HR+'H'+mon+'M_d'+domain+'.png', dpi=120, bbox_inches='tight')

