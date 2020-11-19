import os
import numpy as np
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
def lambert_xticks(ax, ticks):
    """Draw ticks on the bottom x-axis of a Lambert Conformal projection."""
    te = lambda xy: xy[0]
    lc = lambda t, n, b: np.vstack((np.zeros(n) + t, np.linspace(b[2], b[3], n))).T
    xticks, xticklabels = _lambert_ticks(ax, ticks, 'bottom', lc, te)
    ax.xaxis.tick_bottom()
    ax.set_xticks(xticks)
    ax.set_xticklabels([ax.xaxis.get_major_formatter()(xtick) for xtick in xticklabels], fontsize=MIDFONT)
def lambert_yticks(ax, ticks):
    """Draw ricks on the left y-axis of a Lamber Conformal projection."""
    te = lambda xy: xy[1]
    lc = lambda t, n, b: np.vstack((np.linspace(b[0], b[1], n), np.zeros(n) + t)).T
    yticks, yticklabels = _lambert_ticks(ax, ticks, 'left', lc, te)
    ax.yaxis.tick_left()
    ax.set_yticks(yticks)
    ax.set_yticklabels([ax.yaxis.get_major_formatter()(ytick) for ytick in yticklabels], fontsize=MIDFONT)
def _lambert_ticks(ax, ticks, tick_location, line_constructor, tick_extractor):
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

def get_station_df(sta_path):
    '''get station info'''
    df = pd.read_excel(sta_path)
    df=df.dropna()
    return(df)

def conv_deg(deg_str):
    '''convert to degree info'''
    value=int(deg_str)//100
    value=value+(int(deg_str)-value*100)/60
    return(value)

#--------------Function Defination----------------

def main():
    # Input File
    raw_file='/disk/hq247/yhuangci/lzhenn/data/2011-UST-RAP/a_precip_20201113141016.csv'

    # Province shp file
    province_shp_file=os.getenv('SHP_LIB')+'/cnmap/cnhimap.dbf'
    county_shp_file=os.getenv('SHP_LIB')+'/cnmap/county_2004.dbf'

    south_china_province=['广东', '广西', '海南']
    
    
    
    # deal with raw input
    df = pd.read_csv(raw_file,parse_dates=True) 
    df['id']=df['lon']*df['lat']
    df_process=df.groupby('id').sum()    # Resample into hourly data
    df_process['lon'] =df_process['lon']/df_process['val2']
    df_process['lat'] =df_process['lat']/df_process['val2']
    

    # read shp files
    province_shp=shpreader.Reader(province_shp_file).geometries()
    county_shp = shpreader.Reader(county_shp_file).geometries()
    
    
    
    # Set figure size
    proj = ccrs.Mercator(central_longitude=115., min_latitude=-80.0, max_latitude=84.0, globe=None, 
            latitude_true_scale=22.0, false_easting=0.0, false_northing=0.0, scale_factor=None)
    fig = plt.figure(figsize=[10, 8],frameon=True)
    # Set projection and plot the main figure
    ax = fig.add_axes([0.08, 0.01, 0.8, 0.94], projection=proj)
    # Set figure extent
    ax.set_extent([109, 118, 20, 26],crs=ccrs.PlateCarree())
    

    # plot shp boundaries
    ax.add_geometries(county_shp, ccrs.PlateCarree(),facecolor='none', edgecolor='gray',linewidth=0.5, zorder = 0)
    ax.add_geometries(province_shp, ccrs.PlateCarree(),facecolor='none', edgecolor='black',linewidth=1., zorder = 1)

    # Add ocean, land, rivers and lakes
    #ax.add_feature(cfeature.OCEAN.with_scale('50m'))
    #ax.add_feature(cfeature.LAND.with_scale('50m'))
    # *must* call draw in order to get the axis boundary used to add ticks:
    fig.canvas.draw()
    # Define gridline locations and draw the lines using cartopy's built-in gridliner:
    # xticks = np.arange(80,130,10)
    # yticks = np.arange(15,55,5)
    xticks = range(109, 118, 2)
    yticks = range(20, 26, 2) 
    #ax.gridlines(xlocs=xticks, ylocs=yticks,zorder=1,linestyle='--',lw=0.5,color='gray')

    # Label the end-points of the gridlines using the custom tick makers:
    ax.xaxis.set_major_formatter(LONGITUDE_FORMATTER) 
    ax.yaxis.set_major_formatter(LATITUDE_FORMATTER)
    lambert_xticks(ax, xticks)
    lambert_yticks(ax, yticks)

    # Marker size in units of points^2
    cmap=cmaps.precip2_17lev
    sc=ax.scatter( df_process['lon'], df_process['lat'], marker='.', c=df_process['val1'], 
            cmap=cmap, norm=matplotlib.colors.BoundaryNorm([0, 1, 2, 5, 10, 20, 30, 40, 50, 70, 100, 150, 200, 250, 300, 400, 500, 600], cmap.N),
            s=15,zorder=1, transform=ccrs.Geodetic(), label='pr')

    df_sig=df_process.where(df_process['val1']>250.)
    ax.scatter( df_sig['lon'], df_sig['lat'], marker='.', c=df_sig['val1'], 
            cmap=cmap, norm=matplotlib.colors.BoundaryNorm([0, 1, 2, 5, 10, 20, 30, 40, 50, 70, 100, 150, 200, 250, 300, 400, 500, 600], cmap.N),
            s=50,zorder=9, transform=ccrs.Geodetic())
    
    plt.title('Observed Accumulated Rainfall during Mangkhut (1822)')
    cax=fig.add_axes([0.15, 0.02, 0.7, 0.03])#位置[左,下,右,上]
    cbar = fig.colorbar(sc,ticks=[0, 1, 5, 20, 40, 70, 150, 250, 400], cax=cax, orientation='horizontal')
#    cbar = fig.colorbar(sc)

# Show figure
    plt.savefig('../fig/mangkhut_pr.png', dpi=120, bbox_inches='tight')
#    plt.show()



if __name__ == "__main__":
    main()


