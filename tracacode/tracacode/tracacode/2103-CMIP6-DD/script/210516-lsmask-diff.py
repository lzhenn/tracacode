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

varname='LANDMASK'
year='2040'
mon='06'
SEN_DIR='/home/metctm1/array_hq133/cmip6-wrf-arch/projection/ssp245/'+year+'/analysis/'
REF_DIR='/home/metctm1/array_hq133/cmip6-wrf-arch/bias_ref/cmip6/2020/'

for i in range(6,24):
    DIAG_HR='%02d' % i
    title_txt=' Diff between 2040 and 2020 Landmask'
    print(DIAG_HR)
    # Open the NetCDF file
    fn_stream=subprocess.check_output('ls '+SEN_DIR+'wrfout_d04_*-'+mon+'-??_'+DIAG_HR+'*', shell=True).decode('utf-8')
    fn_list=fn_stream.split()
    print(fn_list)
    wrf_list=[Dataset(itm) for itm in fn_list]
    var_temp=wrf.getvar(wrf_list[0],varname)
    var_sen = wrf.getvar(wrf_list, varname, timeidx=wrf.ALL_TIMES, method='cat')
    var_sen=var_sen.mean(dim='Time')

    fn_stream=subprocess.check_output('ls '+REF_DIR+'wrfout_d04_*-'+mon+'-??_'+DIAG_HR+'*', shell=True).decode('utf-8')
    fn_list=fn_stream.split()
    wrf_list=[Dataset(itm) for itm in fn_list]
    var_ref = wrf.getvar(wrf_list, varname, timeidx=wrf.ALL_TIMES, method='cat')
    var_ref=var_ref.mean(dim='Time')

    # Get the latitude and longitude points
    lats, lons = wrf.latlon_coords(var_ref)

    # Province shp file
    coast_shp_file=os.getenv('SHP_LIB')+'/china_coast/china_coastline.dbf'
#    province_shp_file=os.getenv('SHP_LIB')+'/china_coast/'
#    county_shp_file=os.getenv('SHP_LIB')+'/cnmap/county_2004.dbf'

    # read shp files
    coast_shp=shpreader.Reader(coast_shp_file).geometries()
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
    ax.add_geometries(coast_shp, ccrs.PlateCarree(),facecolor='none', edgecolor='black',linewidth=.5, zorder = 1)
#    ax.add_geometries(county_shp, ccrs.PlateCarree(),facecolor='none', edgecolor='gray',linewidth=0.5, zorder = 0)
#    ax.add_geometries(province_shp, ccrs.PlateCarree(),facecolor='none', edgecolor='black',linewidth=1., zorder = 1)
    # *must* call draw in order to get the axis boundary used to add ticks:
    #fig.canvas.draw()

    #xticks = range(109, 118, 2)
    #yticks = range(20, 26, 2) 

    cmap=cmaps.precip_diff_1lev
    levels=np.linspace(0,1,2)
    plt.contourf(wrf.to_np(lons), wrf.to_np(lats), wrf.to_np(var_sen-var_ref),
            levels=levels, extend='both', transform=ccrs.PlateCarree(), cmap=cmap)

    #ax.coastlines()
    plt.title(title_txt,fontsize=SMFONT)

    # Add a color bar
    plt.colorbar(ax=ax, shrink=0.7)

    plt.savefig('../fig/land_mask_diff.png', dpi=120, bbox_inches='tight')

    exit()
