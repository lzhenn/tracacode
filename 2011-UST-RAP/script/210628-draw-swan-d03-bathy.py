import os
import numpy as np
import xarray as xr

import cmaps
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.colors as colors

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
class MidpointNormalize(colors.Normalize):
    def __init__(self, vmin=None, vmax=None, vcenter=None, clip=False):
        self.vcenter = vcenter
        super().__init__(vmin, vmax, clip)

    def __call__(self, value, clip=None):
        # I'm ignoring masked values and all kinds of edge cases to make a
        # simple example...
        # Note also that we must extrapolate beyond vmin/vmax
        x, y = [self.vmin, self.vcenter, self.vmax], [0, 0.5, 1.]
        return np.ma.masked_array(np.interp(value, x, y,
                                            left=-np.inf, right=np.inf))

    def inverse(self, value):
        y, x = [self.vmin, self.vcenter, self.vmax], [0, 0.5, 1]
        return np.interp(value, x, y, left=-np.inf, right=np.inf)

def main():
    # Input File
    bath_fn='/home/lzhenn/cooperate/data/dtm_bathymetry_100m3.nc'

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
    ax.add_geometries(
       coast_shp, ccrs.PlateCarree(), facecolor='None', edgecolor='black',linewidth=.5)

    
    # make a colormap that has land and ocean clearly delineated and of the
    # same length (256 + 256)
    colors_undersea = plt.cm.terrain(np.linspace(0, 0.18, 64))
    colors_land = plt.cm.terrain(np.linspace(0.25, 0.8, 64))
    all_colors = np.vstack((colors_undersea, colors_land))
    terrain_map = colors.LinearSegmentedColormap.from_list(
    'terrain_map', all_colors)

    # make the norm:  Note the center is offset so that the land has more
    # dynamic range:
    divnorm = MidpointNormalize(vmin=-50., vcenter=0, vmax=700)

    print('plot')
    vlevels=[-50, -40, -30, -20, -10, 0, 100, 200, 300, 400, 500, 600, 700]
    pcm = ax.pcolormesh(lon, lat, bath, norm=divnorm, 
                    cmap=terrain_map, rasterized=True,shading='auto', transform=ccrs.PlateCarree()) 

    # Add a color bar
    #plt.colorbar(ax=ax, shrink=0.7)
    cb = fig.colorbar(pcm, shrink=0.6)
    cb.set_ticks(vlevels)
    print('savefig')
    plt.savefig('../fig/bath.png',dpi=120, bbox_inches='tight')

if __name__ == "__main__":
    main()


