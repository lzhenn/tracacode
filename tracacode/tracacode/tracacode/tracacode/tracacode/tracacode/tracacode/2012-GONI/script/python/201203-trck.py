#/usr/bin/env python
'''
Date:  Nov 23, 2020 

Draw TC Track Comparison 

Zhenning LI

'''
from netCDF4 import Dataset
import numpy as np
import datetime, csv
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.cm import get_cmap
import shapely.geometry as sgeom
import cartopy.crs as ccrs
import cartopy.feature as cfeature
from cartopy.mpl.gridliner import LATITUDE_FORMATTER, LONGITUDE_FORMATTER
import cartopy.io.shapereader as shpreader
import shapely.geometry as sgeom
from copy import copy

from wrf import (getvar, interplevel, to_np, latlon_coords, get_cartopy,
                 cartopy_xlim, cartopy_ylim, ALL_TIMES)
import os

# Constants
BIGFONT=22
MIDFONT=18
SMFONT=14



def find_side(ls, side):
    """
 Given a shapely LineString which is assumed to be rectangular, return the
 line corresponding to a given side of the rectangle.
 """
    minx, miny, maxx, maxy = ls.bounds
    points = {'left': [(minx, miny), (minx, maxy)],
              'right': [(maxx, miny), (maxx, maxy)],
              'bottom': [(minx, miny), (maxx, miny)],
              'top': [(minx, maxy), (maxx, maxy)],}
    return sgeom.LineString(points[side])

def mct_xticks(ax, ticks):
    """Draw ticks on the bottom x-axis of a Lambert Conformal projection."""
    te = lambda xy: xy[0]
    lc = lambda t, n, b: np.vstack((np.zeros(n) + t, np.linspace(b[2], b[3], n))).T
    xticks, xticklabels = _mct_ticks(ax, ticks, 'bottom', lc, te)
    ax.xaxis.tick_bottom()
    ax.set_xticks(xticks)
    ax.set_xticklabels([ax.xaxis.get_major_formatter()(xtick) for xtick in xticklabels], fontsize=MIDFONT)
def mct_yticks(ax, ticks):
    """Draw ricks on the left y-axis of a Lamber Conformal projection."""
    te = lambda xy: xy[1]
    lc = lambda t, n, b: np.vstack((np.linspace(b[0], b[1], n), np.zeros(n) + t)).T
    yticks, yticklabels = _mct_ticks(ax, ticks, 'left', lc, te)
    ax.yaxis.tick_left()
    ax.set_yticks(yticks)
    ax.set_yticklabels([ax.yaxis.get_major_formatter()(ytick) for ytick in yticklabels], fontsize=MIDFONT)
def _mct_ticks(ax, ticks, tick_location, line_constructor, tick_extractor):
    """Get the tick locations and labels for an axis of a Lambert Conformal projection."""
    outline_patch = sgeom.LineString(ax.outline_patch.get_path().vertices.tolist())
    axis = find_side(outline_patch, tick_location)
    n_steps = 30
    extent = ax.get_extent(ccrs.PlateCarree())
    _ticks = []
    for t in ticks:
        xy = line_constructor(t, n_steps, extent)
        proj_xyz = ax.projection.transform_points(ccrs.Geodetic(), xy[:, 0], xy[:, 1])
        xyt = proj_xyz[..., :2]
        ls = sgeom.LineString(xyt.tolist())
        locs = axis.intersection(ls)
        if not locs:
            tick = [None]
        else:
            tick = tick_extractor(locs.xy)
        _ticks.append(tick[0])
    # Remove ticks that aren't visible: 
    ticklabels = copy(ticks)
    while True:
        try:
            index = _ticks.index(None)
        except ValueError:
            break
        _ticks.pop(index)
        ticklabels.pop(index)
    return _ticks, ticklabels



jma_path='/home/metctm1/array/data/GONI2020/GONI2020.JMA.csv'

nc_path='/home/metctm1/array/data/GONI2020/WRFONLY_3DOMAIN/wrfout_d02'
province_shp_file=os.getenv('SHP_LIB')+'/cnmap/cnhimap.dbf'

cases=['WRFONLY_2DOMAIN', 'WRFONLY_3DOMAIN']
line_libs=['r-^','b-s','b-.*','g--o']


# ----------Get NetCDF data------------
print('Read NC...')

ncfile = Dataset(nc_path)
lsmask=getvar(ncfile, 'LANDMASK')

# Get the lat/lon coordinates
lats, lons = latlon_coords(lsmask)

# Province shp file
# read shp files
#province_shp=shpreader.Reader(province_shp_file).geometries()

# Read bestTrck Data JMA
dateparse = lambda x: datetime.datetime.strptime(x, '%Y%m%d%H')
df_jma_obv=pd.read_csv(jma_path,parse_dates=True,index_col='time', date_parser=dateparse)

print('Plot...')
# Create the figure


# ----------seperate land/sea---------

# Get the map projection information
fig = plt.figure(figsize=(12,8), frameon=True)
proj = get_cartopy(lsmask)

ax = fig.add_axes([0.1, 0.1, 0.8, 0.94], projection=proj)

# Download and add the states and coastlines
ax.coastlines('50m', linewidth=0.8)


# plot province/city shp boundaries
#ax.add_geometries(county_shp, ccrs.PlateCarree(),facecolor='none', edgecolor='gray',linewidth=0.5, zorder = 0)
#ax.add_geometries(province_shp, ccrs.PlateCarree(),facecolor='none', edgecolor='black',linewidth=1., zorder = 1)


# Add ocean, land, rivers and lakes
ax.add_feature(cfeature.OCEAN.with_scale('50m'))
ax.add_feature(cfeature.LAND.with_scale('50m'))
ax.add_feature(cfeature.LAKES.with_scale('50m'))
# *must* call draw in order to get the axis boundary used to add ticks:
fig.canvas.draw()
# Define gridline locations and draw the lines using cartopy's built-in gridliner:
# xticks = np.arange(80,130,10)
# yticks = np.arange(15,55,5)
xticks = np.arange(125,140,5).tolist() 
yticks =  np.arange(12,20,2).tolist() 
#ax.gridlines(xlocs=xticks, ylocs=yticks,zorder=1,linestyle='--',lw=0.5,color='gray')

# Label the end-points of the gridlines using the custom tick makers:
ax.xaxis.set_major_formatter(LONGITUDE_FORMATTER) 
ax.yaxis.set_major_formatter(LATITUDE_FORMATTER)
mct_xticks(ax, xticks)
mct_yticks(ax, yticks)


# Set the map bounds
ax.set_xlim(cartopy_xlim(lsmask))
ax.set_ylim(cartopy_ylim(lsmask))


ax.plot(df_jma_obv['Lon'], df_jma_obv['Lat'],
        color='black', marker='o', linewidth=2, markersize=5, transform=ccrs.Geodetic(), label='JMA bestTrack')

dateparse = lambda x: datetime.datetime.strptime(x, '%Y%m%d%H%M%S')
for (line_type,casename) in zip(line_libs,cases):
    sen_path='/home/metctm1/array/data/GONI2020/'+casename+'/trck.'+casename+'.d01'
    df_sen=pd.read_csv(sen_path,parse_dates=True,index_col='timestamp', sep='\s+', date_parser=dateparse)
    df_sen_period=df_sen
    df_sen_period.replace(0, np.nan, inplace=True) # replace 0 by nan
    df_sen_period=df_sen_period.dropna()
    
    ax.plot(df_sen_period['lon'], df_sen_period['lat'],
        line_type, linewidth=1, markersize=3, transform=ccrs.Geodetic(), label=casename)


plt.legend(loc='best', fontsize=SMFONT)
plt.title('Observational and Simulated Tracks of GONI (202019#)',fontsize=MIDFONT)
plt.savefig("../../fig/trck.png",dpi=300, bbox_inches='tight')
plt.close('all')

#plt.show()

  
