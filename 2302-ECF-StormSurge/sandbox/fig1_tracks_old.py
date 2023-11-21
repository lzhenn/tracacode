# /usr/bin/env python

##--##--##--  引入库  ##--##--##
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
#from cartopy.mpl.gridliner import LATITUDE_FORMATTER, LONGITUDE_FORMATTER
from cartopy.mpl.ticker import LongitudeFormatter, LatitudeFormatter
import cartopy.io.shapereader as shpreader
import shapely.geometry as sgeom
from copy import copy

from wrf import (getvar, interplevel, to_np, latlon_coords, get_cartopy,
                 cartopy_xlim, cartopy_ylim, ALL_TIMES)
import os

# Constants
BIGFONT=22
MIDFONT=10
SMFONT=7.5

MAP_RES='10m'
FIG_FMT='pdf'



##--##--##--  绘图设置  ##--##--##
def find_side(ls, side):   ## 返回四个边的位置
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

def mct_xticks(ax, ticks):   ##  x轴坐标
    """Draw ticks on the bottom x-axis of a Lambert Conformal projection."""
    te = lambda xy: xy[0]
    lc = lambda t, n, b: np.vstack((np.zeros(n) + t, np.linspace(b[2], b[3], n))).T
    xticks, xticklabels = _mct_ticks(ax, ticks, 'bottom', lc, te)
    ax.xaxis.tick_bottom()
    ax.set_xticks(xticks)
    ax.set_xticklabels([ax.xaxis.get_major_formatter()(xtick) for xtick in xticklabels], fontsize=MIDFONT)
def mct_yticks(ax, ticks):   ##  y轴坐标
    """Draw ricks on the left y-axis of a Lamber Conformal projection."""
    te = lambda xy: xy[1]
    lc = lambda t, n, b: np.vstack((np.linspace(b[0], b[1], n), np.zeros(n) + t)).T
    yticks, yticklabels = _mct_ticks(ax, ticks, 'left', lc, te)
    ax.yaxis.tick_left()
    ax.set_yticks(yticks)
    ax.set_yticklabels([ax.yaxis.get_major_formatter()(ytick) for ytick in yticklabels], fontsize=MIDFONT)

##  调整一下 x 轴和 y 轴坐标
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





print('Read NC...')
##--##--##---------------------------------  读取数据   ---------------------------------##--##--##

nc_path='/home/lzhenn/cooperate/data/case_study/coupled/2018091200/wrfout_d02_2018-09-13_11:00:00'
province_shp_file=os.getenv('SHP_LIB')+'/cnmap/cnhimap.dbf'
ncfile = Dataset(nc_path)
lsmask=getvar(ncfile, 'LANDMASK')
lats, lons = latlon_coords(lsmask)
province_shp =shpreader.Reader(province_shp_file).geometries()
province_shp2 =shpreader.Reader(province_shp_file).geometries()
province_shp3 =shpreader.Reader(province_shp_file).geometries()
dateparse = lambda x: datetime.datetime.strptime(x, '%Y%m%d%H')

##--##--##   Mangkhut (2018)   ##--##--##
## 两个观测路径 ##
# path_cma1 = "/home/lzhenn/array74/coop_fenying/1_TC_tracks/CH2018BST_Mangkhut.txt"
# df_cma1 =pd.read_csv(path_cma, sep='\s+', header=None, names=["date","Intensity","lat","lon","pres","wnd"])

# hko_path1='/home/metctm1/array_hq86/data/1911-COAWST/hko.trck.mangkhut'
cma_path1='/home/metctm1/array_hq86/data/1911-COAWST/cma.trck.mangkhut'
# df_hko_obv1=pd.read_csv(hko_path1,parse_dates=True,index_col='time', sep='\s+', date_parser=dateparse)
df_cma1=pd.read_csv(cma_path1,parse_dates=True,index_col='time', sep='\s+', date_parser=dateparse)

## 两个模拟路径 ##
path_ctrl1 = "/home/lzhenn/array74/coop_fenying/1_TC_tracks/Mangkhut_ctrl.txt"
df_ctrl1 =pd.read_csv(path_ctrl1, sep='\s+', header=None, names=["lat","lon","slp","wnd"])
# print(df_ctrl1)

path_pgw1 = "/home/lzhenn/array74/coop_fenying/1_TC_tracks/Mangkhut_pgw.txt"
df_pgw1 =pd.read_csv(path_pgw1, sep='\s+', header=None, names=["lat","lon","slp","wnd"])



##--##--##   Hato (2017)   ##--##--##
path_cma2 = "/home/lzhenn/array74/coop_fenying/1_TC_tracks/CH2017BST_Hato.txt"
df_cma2 =pd.read_csv(path_cma2, sep='\s+', header=None, names=["date","Intensity","lat","lon","pres","wnd"])

path_ctrl2 = "/home/lzhenn/array74/coop_fenying/1_TC_tracks/Hato_ctrl.txt"
df_ctrl2 =pd.read_csv(path_ctrl2, sep='\s+', header=None, names=["lat","lon","slp","wnd"])

path_pgw2 = "/home/lzhenn/array74/coop_fenying/1_TC_tracks/Hato_pgw.txt"
df_pgw2 =pd.read_csv(path_pgw2, sep='\s+', header=None, names=["lat","lon","slp","wnd"])



##--##--##   Vicente (2012)   ##--##--##
path_cma3 = "/home/lzhenn/array74/coop_fenying/1_TC_tracks/CH2012BST_Vicente.txt"
df_cma3 =pd.read_csv(path_cma3, sep='\s+', header=None, names=["date","Intensity","lat","lon","pres","wnd"])

path_ctrl3 = "/home/lzhenn/array74/coop_fenying/1_TC_tracks/Vicente_ctrl.txt"
df_ctrl3 =pd.read_csv(path_ctrl3, sep='\s+', header=None, names=["lat","lon","slp","wnd"])

path_pgw3 = "/home/lzhenn/array74/coop_fenying/1_TC_tracks/Vicente_pgw.txt"
df_pgw3 =pd.read_csv(path_pgw3, sep='\s+', header=None, names=["lat","lon","slp","wnd"  ])







fig = plt.figure(dpi=60,figsize=(9,9), frameon=True)
# fig.canvas.draw()
proj = get_cartopy(lsmask)
# proj = ccrs.PlateCarree(central_longitude=114)
def create_map(ax):
    # Download and add the states and coastlines
    ax.coastlines(MAP_RES, linewidth=0.1)

    # plot province/city shp boundaries
    #ax.add_geometries(county_shp, ccrs.PlateCarree(),facecolor='none', edgecolor='gray',linewidth=0.5, zorder = 0)
    # ax.add_geometries(province_shp, ccrs.PlateCarree(),facecolor='none', edgecolor='black',linewidth=0.3, zorder = 1)

    # Add ocean, land, rivers and lakes
    ax.add_feature(cfeature.OCEAN.with_scale(MAP_RES))
    ax.add_feature(cfeature.LAND.with_scale(MAP_RES))
    ax.add_feature(cfeature.LAKES.with_scale(MAP_RES))
    # *must* call draw in order to get the axis boundary used to add ticks:
    # fig.canvas.draw()
    # Define gridline locations and draw the lines using cartopy's built-in gridliner:
    # xticks = np.arange(80,130,10)
    # yticks = np.arange(15,55,5)
    xticks = np.arange(109,118,2).tolist() 
    yticks =  np.arange(18,27,1.5).tolist() 
    #ax.gridlines(xlocs=xticks, ylocs=yticks,zorder=1,linestyle='--',lw=0.5,color='gray')
    #gl = ax.gridlines(draw_labels=True, alpha=0.0)
    #gl.right_labels = False
    #gl.top_labels = False
    ax.set_xticks(xticks, crs=ccrs.PlateCarree())
    ax.set_yticks(yticks, crs=ccrs.PlateCarree())
    lon_formatter =LongitudeFormatter(number_format='.1f')
    lat_formatter = LatitudeFormatter(number_format='.1f')
    ax.xaxis.set_major_formatter(lon_formatter)
    ax.yaxis.set_major_formatter(lat_formatter)
    ax.tick_params(axis='both', which='major', labelsize=SMFONT)
    #for tick in ax.xaxis.get_major_ticks():
    #    tick.label.set_fontsize(SMFONT) 
    # Label the end-points of the gridlines using the custom tick makers:
    #ax.xaxis.set_major_formatter(LONGITUDE_FORMATTER) 
    #ax.yaxis.set_major_formatter(LATITUDE_FORMATTER)
    #mct_xticks(ax, xticks)
    #mct_yticks(ax, yticks)
    # Set the map bounds
    ax.set_xlim(cartopy_xlim(lsmask))
    ax.set_ylim(cartopy_ylim(lsmask))

    return ax

# xticks = np.arange(109,118,2).tolist() 
# print(xticks)

df_ctrl1.lon[103] = df_ctrl1.lon[102]
df_ctrl1.lat[103] = df_ctrl1.lat[102]
df_pgw1.lon[101] = df_pgw1.lon[100]
df_pgw1.lat[101] = df_pgw1.lat[100]
df_pgw1.lon[102] = df_pgw1.lon[100]
df_pgw1.lat[102] = df_pgw1.lat[100]




print('Plot...')
# Create the figure
# ----------seperate land/sea---------

# Get the map projection information




ax1 = fig.add_axes([0.05, 0.2, 0.27, 0.26], projection=proj)
# ax2 = fig.add_axes([0.4, 0.2, 0.27, 0.26], projection=proj)
# ax3 = fig.add_axes([0.75, 0.2, 0.27, 0.26], projection=proj)
ax2 = fig.add_axes([0.35, 0.2, 0.27, 0.26], projection=proj)
ax3 = fig.add_axes([0.65, 0.2, 0.27, 0.26], projection=proj)
ax1 = create_map(ax1)
ax2 = create_map(ax2)
ax3 = create_map(ax3)


ax1.add_geometries(province_shp, ccrs.PlateCarree(),facecolor='none', edgecolor='black',linewidth=0.1, zorder = 2)
# fig.canvas.draw()
ax1.plot(df_cma1['lon']/10., df_cma1['lat']/10., color='black', marker='o', linewidth=1, markersize=2, transform=ccrs.Geodetic(), label=' CMA  bestTrack')
ax1.plot(df_ctrl1.lon[83:120]/1., df_ctrl1.lat[83:120]/1., color='blue', marker='^', linewidth=1, linestyle='dashed', markersize=2, transform=ccrs.Geodetic(), label=' CTRL')
ax1.plot(df_pgw1.lon[83:120]/1., df_pgw1.lat[83:120]/1., color='red', marker='s', linewidth=1, linestyle='dashed', markersize=2, transform=ccrs.Geodetic(), label=' PGW')

ax1.legend(loc='best', fontsize=8)
ax1.set_title('(a)  Mangkhut (2018)',fontsize=10)




ax2.add_geometries(province_shp2, ccrs.PlateCarree(),facecolor='none', edgecolor='black',linewidth=0.1, zorder = 2)
ax2.set_yticklabels(['','','','','',''])
# fig.canvas.draw()
ax2.plot(df_cma2['lon']/10., df_cma2['lat']/10.,color='black', marker='o', linewidth=1, markersize=3, transform=ccrs.Geodetic(), label=' CMA  bestTrack')
ax2.plot(df_ctrl2.lon[26:72]/1., df_ctrl2.lat[26:72]/1., color='blue', marker='^', linewidth=1, linestyle='dashed', markersize=2, transform=ccrs.Geodetic(), label=' CTRL')
ax2.plot(df_pgw2.lon[28:72]/1., df_pgw2.lat[28:72]/1., color='red', marker='s', linewidth=1, linestyle='dashed', markersize=2, transform=ccrs.Geodetic(), label=' PGW')
ax2.set_title('(b)  Hato (2017)',fontsize=10)



ax3.add_geometries(province_shp3, ccrs.PlateCarree(),facecolor='none', edgecolor='black',linewidth=0.1, zorder = 2)
# fig.canvas.draw()
ax3.set_yticklabels(['','','','','',''])
ax3.plot(df_cma3['lon']/10., df_cma3['lat']/10.,color='black', marker='o', linewidth=1, markersize=2, transform=ccrs.Geodetic(), label=' CMA  bestTrack')
ax3.plot(df_ctrl3.lon[33:115:2]/1., df_ctrl3.lat[33:115:2]/1., color='blue', marker='^', linewidth=1, linestyle='dashed', markersize=2, transform=ccrs.Geodetic(), label=' CTRL')
ax3.plot(df_pgw3.lon[16:116:2]/1., df_pgw3.lat[16:116:2]/1., color='red', marker='s', linewidth=1, linestyle='dashed', markersize=2, transform=ccrs.Geodetic(), label=' PGW')
ax3.set_title('(c)  Vicente (2012)',fontsize=10)


print("abcdefg")


plt.savefig('/home/lzhenn/array74/coop_fenying/7_article_FIG/Fig1_tracks.pdf', dpi=60, bbox_inches='tight')  #+FIG_FMT
plt.close('all')
#plt.show()

  