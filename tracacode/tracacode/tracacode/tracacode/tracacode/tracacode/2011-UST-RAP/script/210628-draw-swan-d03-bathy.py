import os
import numpy as np
import xarray as xr

import cmaps
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

import cartopy.crs as ccrs
import cartopy.feature as cfeature
from copy import copy
from cartopy.mpl.gridliner import LATITUDE_FORMATTER, LONGITUDE_FORMATTER
import cartopy.io.shapereader as shpreader
import shapely.geometry as sgeom
import datetime

# Constants
BIGFONT=18
MIDFONT=14
SMFONT=10

#--------------Function Defination----------------

def main():
    # Input File
    bath_fn='/home/metctm1/array/data/Calypso/roms_d03.nc'

    ds=xr.load_dataset(bath_fn)
    bath=ds['h']
    lmask=ds['mask_rho']
    lat=ds['lat_rho']
    lon=ds['lon_rho']

    lat_bottom=lat.min()
    lat_top=lat.max()
    lon_left=lon.min()
    lon_right=lon.max()

    # shp file
    coast_shp_file=os.getenv('SHP_LIB')+'/china_coast/china_coastline.dbf'
    # read shp files
    coast_shp=shpreader.Reader(coast_shp_file).geometries()

    # Set projection
    proj = ccrs.Mercator(central_longitude=114., min_latitude=-80.0, max_latitude=84.0, globe=None, 
            latitude_true_scale=22.0, false_easting=0.0, false_northing=0.0, scale_factor=None)

    fig = plt.figure(figsize=[10, 8],frameon=True)

    # Set projection and plot the main figure
    ax = fig.add_axes([0.08, 0.01, 0.8, 0.94], projection=proj)

    # Set figure extent
    ax.set_extent([lon_left, lon_right, lat_bottom, lat_top],crs=ccrs.PlateCarree())

    # plot shp boundaries
    ax.add_geometries(coast_shp, ccrs.PlateCarree(),facecolor='tan', edgecolor='black',linewidth=.5, zorder = 1)

    cmap=cmaps.cmocean_dense
    levels=np.linspace(0,45,91)
    plt.contourf(lon, lat, bath, levels=levels, 
                extend='both', transform=ccrs.PlateCarree(), cmap=cmap)


    # Add a color bar
    plt.colorbar(ax=ax, shrink=0.7)

    plt.savefig('../fig/bath.png', dpi=120, bbox_inches='tight')

if __name__ == "__main__":
    main()


