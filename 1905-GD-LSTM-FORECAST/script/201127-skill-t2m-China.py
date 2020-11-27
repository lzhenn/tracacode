#! /usr/bin/env python
#  Draw scores of LASSO prediction in mainland China 
#   
#               L_Zealot
#               Nov 27, 2020
#               Clear Water Bay, Hong Kong 
#

import cmaps
import numpy as np
import pandas as pd
import matplotlib, json, os 
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

#-------------------------------------
# Function Definition Part
#-------------------------------------

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


def main():

#----------------------------------------------------
# User Defined Part
#----------------------------------------------------

    # Result Input File
    result_in_file='/home/metctm1/array/workspace/spellcaster-local/json_base/whole_china_t2m_full_XY_result.json'
    
    sta_meta_file='/home/metctm1/array/workspace/spellcaster-local/data/station/SURF_CLI_CHN_PRE_MUT_HOMO_STATION.xls'

    # Province shp file
    province_shp_file=os.getenv('SHP_LIB')+'/cnmap/cnhimap.dbf'
    county_shp_file=os.getenv('SHP_LIB')+'/cnmap/county_2004.dbf'


#----------------------------------------------------
# Main function
#----------------------------------------------------
    # read shp files
    province_shp=shpreader.Reader(province_shp_file).geometries()
    county_shp = shpreader.Reader(county_shp_file).geometries()
    
    
    # get Sta meta
    sta_df=get_station_df(sta_meta_file)
    sta_df = sta_df.filter(['区站号','纬度(度分)','经度(度分)'], axis=1)
    sta_df['sta_num']=sta_df['区站号'].transform(lambda x: int(x))
    sta_df['lat']=sta_df['纬度(度分)'].transform(lambda x: conv_deg(x[0:-1]))
    sta_df['lon']=sta_df['经度(度分)'].transform(lambda x: conv_deg(x[0:-1]))
    sta_df['score']=0.0
    sta_df=sta_df.set_index('sta_num')

    # get score 
    with open(result_in_file) as f:
        result_dic=json.load(f)
    
    for idx, itm in result_dic.items():
        sta_df.at[int(idx),'score']=float(itm['sign_score'])
    
    # Set figure size
    proj = ccrs.LambertConformal(central_longitude=105, central_latitude=90,
                                 false_easting=400000, false_northing=400000)#,standard_parallels=(46, 49))

    fig = plt.figure(figsize=[10, 8],frameon=True)
    # Set projection and plot the main figure
    ax = fig.add_axes([0.08, 0.01, 0.8, 0.94], projection=proj)
    # Set figure extent
    ax.set_extent([80, 128, 18, 55],crs=ccrs.PlateCarree())
    

    # plot shp boundaries
    #ax.add_geometries(county_shp, ccrs.PlateCarree(),facecolor='none', edgecolor='gray',linewidth=0.5, zorder = 0)
    ax.add_geometries(province_shp, ccrs.PlateCarree(),facecolor='none', edgecolor='black',linewidth=1., zorder = 1)

    # Add ocean, land, rivers and lakes
    ax.add_feature(cfeature.OCEAN.with_scale('50m'))
    ax.add_feature(cfeature.LAND.with_scale('50m'))
    # *must* call draw in order to get the axis boundary used to add ticks:
    fig.canvas.draw()
    # Define gridline locations and draw the lines using cartopy's built-in gridliner:
    # xticks = np.arange(80,130,10)
    # yticks = np.arange(15,55,5)
    xticks = range(55, 165, 10) 
    yticks = range(0, 65, 5) 
    #ax.gridlines(xlocs=xticks, ylocs=yticks,zorder=1,linestyle='--',lw=0.5,color='gray')

    # Label the end-points of the gridlines using the custom tick makers:
    ax.xaxis.set_major_formatter(LONGITUDE_FORMATTER) 
    ax.yaxis.set_major_formatter(LATITUDE_FORMATTER)
#    lambert_xticks(ax, xticks)
#    lambert_yticks(ax, yticks)

    # Marker size in units of points^2
    cmap=cmaps.BlAqGrYeOrReVi200
    sc=ax.scatter( sta_df['lon'], sta_df['lat'], marker='.', c=sta_df['score'], 
            cmap=cmap, norm=matplotlib.colors.BoundaryNorm([0.5, 0.6, 0.7, 0.8], cmap.N),
            s=15,zorder=1, transform=ccrs.Geodetic(), label='pr')

    plt.title('T2m Pc on Test Set')
    cax=fig.add_axes([0.15, 0.02, 0.7, 0.03])#位置[左,下,右,上]
    cbar = fig.colorbar(sc,ticks=[0.5, 0.6, 0.7, 0.8], cax=cax, orientation='horizontal')
#    cbar = fig.colorbar(sc)

# Show figure
    plt.savefig('../fig/t2m_score.png', dpi=120, bbox_inches='tight')
#



if __name__ == "__main__":
    main()


