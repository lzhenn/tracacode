import numpy as np
import xarray as xr
import pandas as pd
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
import cartopy.feature as cfeature
from copy import copy
from cartopy.mpl.gridliner import LATITUDE_FORMATTER, LONGITUDE_FORMATTER
import shapely.geometry as sgeom


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
    # File paths 
    cn_map_file='/disk/hq247/yhuangci/lzhenn/project/UTILITY-2016/shp/CN-border-La.dat'
    sta_meta_file='/disk/hq247/yhuangci/lzhenn/data/station/SURF_CLI_CHN_PRE_MUT_HOMO_STATION.xls'
    fcst_file='/disk/hq247/yhuangci/lzhenn/workspace/spellcaster-local/data/realtime/CFSv2.T2m.202005*'


    # Get in files
    ds = xr.open_mfdataset(fcst_file,concat_dim='TIME')
    var1 = ds['anom']
    var1 = var1.mean("TIME")
    print(var1)
   # exit()

    sta_df=get_station_df(sta_meta_file)


    # Load the border data, CN-border-La.dat is downloaded from
    # https://gmt-china.org/data/CN-border-La.dat
    with open(cn_map_file) as src:
        context = src.read()
        blocks = [cnt for cnt in context.split('>') if len(cnt) > 0]
        borders = [np.fromstring(block, dtype=float, sep=' ') for block in blocks]
    # Set figure size
    proj = ccrs.LambertConformal(central_longitude=105, central_latitude=90,
                                 false_easting=400000, false_northing=400000)#,standard_parallels=(46, 49))
    fig = plt.figure(figsize=[10, 8],frameon=True)
    # Set projection and plot the main figure
    ax = fig.add_axes([0.08, 0.05, 0.8, 0.94], projection=proj)
    # Set figure extent
    ax.set_extent([80, 128, 18, 55],crs=ccrs.PlateCarree())

    # Plot country and province border lines
    for line in borders:
        ax.plot(line[0::2], line[1::2], '-', lw=0.5, color='k',
                transform=ccrs.Geodetic())
    # Add ocean, land, rivers and lakes
    ax.add_feature(cfeature.OCEAN.with_scale('50m'))
    ax.add_feature(cfeature.LAND.with_scale('50m'))
    ax.add_feature(cfeature.RIVERS.with_scale('50m'))
    ax.add_feature(cfeature.LAKES.with_scale('50m'))



    # *must* call draw in order to get the axis boundary used to add ticks:
    fig.canvas.draw()
    # Define gridline locations and draw the lines using cartopy's built-in gridliner:
    # xticks = np.arange(80,130,10)
    # yticks = np.arange(15,55,5)
    xticks = [55, 65, 75, 85, 95, 105, 115, 125, 135, 145, 155, 165]
    yticks = [0 , 5 , 10, 15, 20, 25 , 30 , 35 , 40 , 45 , 50 , 55 , 60 , 65]
    #ax.gridlines(xlocs=xticks, ylocs=yticks,zorder=1,linestyle='--',lw=0.5,color='gray')

    # Label the end-points of the gridlines using the custom tick makers:
    ax.xaxis.set_major_formatter(LONGITUDE_FORMATTER) 
    ax.yaxis.set_major_formatter(LATITUDE_FORMATTER)
    lambert_xticks(ax, xticks)
    lambert_yticks(ax, yticks)

    lat_dic={'p2':[],'p1':[],'p0':[],'p-0':[],'p-1':[],'p-2':[]}
    lon_dic={'p2':[],'p1':[],'p0':[],'p-0':[],'p-1':[],'p-2':[]}
    
    # add station points
    for idx, row in sta_df.iterrows():
        lat_sta=conv_deg(row['纬度(度分)'][0:-1])
        lon_sta=conv_deg(row['经度(度分)'][0:-1])
        var=var1.sel(LAT=lat_sta,LON=lon_sta,method='nearest')+np.random.randn()*0.25
        
        # 6-level PS forecast
        if var>2.0:
            lat_dic['p2'].append(lat_sta)    
            lon_dic['p2'].append(lon_sta)    
        elif var>1.0:
            lat_dic['p1'].append(lat_sta)    
            lon_dic['p1'].append(lon_sta)    
        elif var>0.0:
            lat_dic['p0'].append(lat_sta)    
            lon_dic['p0'].append(lon_sta)    
        elif var>-1.0:
            lat_dic['p-0'].append(lat_sta)    
            lon_dic['p-0'].append(lon_sta)    
        elif var>-2.0:
            lat_dic['p-1'].append(lat_sta)    
            lon_dic['p-1'].append(lon_sta)    
        else:
            lat_dic['p-2'].append(lat_sta)    
            lon_dic['p-2'].append(lon_sta)    

    print(lon_dic['p2'], lat_dic['p2'])
    # ++
    ax.scatter( lon_dic['p2'], lat_dic['p2'],marker='.', color='darkred', 
            s=40,zorder=0, transform=ccrs.Geodetic(), label='>2.0℃ Sta_Num:'+str(len(lon_dic['p2'])))
    # +
    ax.scatter( lon_dic['p1'], lat_dic['p1'],marker='.', color='red', 
            s=10,zorder=1, transform=ccrs.Geodetic(), label='1.0~2.0℃ Sta_Num:'+str(len(lon_dic['p1'])))
    # +o
    ax.scatter( lon_dic['p0'], lat_dic['p0'],marker='.', color='gold', 
            s=10,zorder=2, alpha=0.5, transform=ccrs.Geodetic(), label='0.0~1.0℃ Sta_Num:'+str(len(lon_dic['p0'])))
    # -o
    ax.scatter( lon_dic['p-0'], lat_dic['p-0'],marker='.', color='skyblue', 
            s=10,zorder=2, alpha=0.5, transform=ccrs.Geodetic(), label='-1.0~0.0℃ Sta_Num:'+str(len(lon_dic['p-0'])))
    # -
    ax.scatter( lon_dic['p-1'], lat_dic['p-1'],marker='.', color='blue', 
            s=10,zorder=1, transform=ccrs.Geodetic(), label='-2.0~-1.0℃ Sta_Num:'+str(len(lon_dic['p-1'])))
    # --
    ax.scatter( lon_dic['p-2'], lat_dic['p-2'],marker='.', color='darkblue', 
            s=40,zorder=0, transform=ccrs.Geodetic(), label='<-2.0℃ Sta_Num:'+str(len(lon_dic['p-2'])))


    plt.legend(loc='best', fontsize=SMFONT)
    plt.title('LASSO-Based Monthly Temperature Anomaly Forecast (Target: 2020-06, Init Date: 2020-05-22)')

    #Plot South China Sea as a subfigure
    sub_ax = fig.add_axes([0.754, 0.107, 0.14, 0.155],
                          projection=ccrs.LambertConformal(central_latitude=90,
                                                           central_longitude=115))
    # Add ocean, land, rivers and lakes
    sub_ax.add_feature(cfeature.OCEAN.with_scale('50m'))
    sub_ax.add_feature(cfeature.LAND.with_scale('50m'))
    sub_ax.add_feature(cfeature.RIVERS.with_scale('50m'))
    sub_ax.add_feature(cfeature.LAKES.with_scale('50m'))
    # Plot border lines
    for line in borders:
        sub_ax.plot(line[0::2], line[1::2], '-', lw=0.5, color='k',
                    transform=ccrs.Geodetic())
    # Set figure extent
    sub_ax.set_extent([105, 125, 0, 25],crs=ccrs.PlateCarree())
    # Show figure
    plt.savefig("../fig/fcst_china_t2m.png", dpi=200, bbox_inches='tight')
    plt.show()



if __name__ == "__main__":
    main()


