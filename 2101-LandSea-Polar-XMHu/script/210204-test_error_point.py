#/usr/bin/env python
'''
Date:  Feb 04, 2021 
Draw CESM cloudfrac error 
Zhenning LI
'''
import numpy as np
<<<<<<< HEAD
import pandas as pd
=======
>>>>>>> 75a837b9114fa700d7c747568656409a749565ac
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.cm import get_cmap
import cartopy.crs as ccrs
import cartopy.feature as cfeature
#from cartopy.mpl.gridliner import LATITUDE_FORMATTER, LONGITUDE_FORMATTER
from cartopy.mpl.ticker import LongitudeFormatter, LatitudeFormatter
import cartopy.io.shapereader as shpreader


# Constants
BIGFONT=22
MIDFONT=18
SMFONT=14

<<<<<<< HEAD
MAP_RES='110m'
FIG_FMT='pdf'


=======
MAP_RES='10m'
FIG_FMT='pdf'



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



>>>>>>> 75a837b9114fa700d7c747568656409a749565ac
pt_path='~/temp/test.csv'

# ----------Get NetCDF data------------

# Read error points 
df_err=pd.read_csv(pt_path)
print(df_err)
<<<<<<< HEAD
=======
exit()
# Read bestTrck Data CMA
dateparse = lambda x: datetime.datetime.strptime(x, '%Y%m%d%H')
df_cma_obv=pd.read_csv(cma_path,parse_dates=True,index_col='time', sep='\s+', date_parser=dateparse)

>>>>>>> 75a837b9114fa700d7c747568656409a749565ac


print('Plot...')
# Create the figure


# ----------seperate land/sea---------

# Get the map projection information
fig = plt.figure(figsize=(12,8), frameon=True)
<<<<<<< HEAD
proj =ccrs.PlateCarree() 
=======
proj = get_cartopy(lsmask)

>>>>>>> 75a837b9114fa700d7c747568656409a749565ac
ax = fig.add_axes([0.08, 0.05, 0.8, 0.94], projection=proj)

# Download and add the states and coastlines
ax.coastlines(MAP_RES, linewidth=0.8)


<<<<<<< HEAD
=======
# plot province/city shp boundaries
#ax.add_geometries(county_shp, ccrs.PlateCarree(),facecolor='none', edgecolor='gray',linewidth=0.5, zorder = 0)
ax.add_geometries(province_shp, ccrs.PlateCarree(),facecolor='none', edgecolor='black',linewidth=1., zorder = 1)

>>>>>>> 75a837b9114fa700d7c747568656409a749565ac

# Add ocean, land, rivers and lakes
ax.add_feature(cfeature.OCEAN.with_scale(MAP_RES))
ax.add_feature(cfeature.LAND.with_scale(MAP_RES))
ax.add_feature(cfeature.LAKES.with_scale(MAP_RES))
# *must* call draw in order to get the axis boundary used to add ticks:
fig.canvas.draw()
# Define gridline locations and draw the lines using cartopy's built-in gridliner:
# xticks = np.arange(80,130,10)
# yticks = np.arange(15,55,5)
<<<<<<< HEAD
xticks = np.arange(0,360,30).tolist() 
yticks =  np.arange(-90,90,15).tolist() 
=======
xticks = np.arange(109,118.5,1.5).tolist() 
yticks =  np.arange(18,27,1.5).tolist() 
>>>>>>> 75a837b9114fa700d7c747568656409a749565ac
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
<<<<<<< HEAD


ax.scatter(df_err['lon'], df_err['lat'],color='black', marker='o')

plt.legend(loc='best', fontsize=SMFONT)
plt.title('Error Points',fontsize=MIDFONT)
plt.savefig('../fig/err_points', dpi=300, bbox_inches='tight')
=======
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


ax.plot(df_hko_obv['lon']/10., df_hko_obv['lat']/10.,
        color='black', marker='o', linewidth=2, markersize=5, transform=ccrs.Geodetic(), label='HKO bestTrack')
ax.plot(df_cma_obv['lon']/10., df_cma_obv['lat']/10.,
        color='dimgray', marker='*', linewidth=2, linestyle='dashed', markersize=8, transform=ccrs.Geodetic(), label='CMA bestTrack')

dateparse = lambda x: datetime.datetime.strptime(x, '%Y%m%d%H%M%S')
for (line_type,casename) in zip(line_libs,cases):
    sen_path='/home/metctm1/array/data/1911-COAWST/'+casename+'/trck.'+casename+'.d02'
    df_sen=pd.read_csv(sen_path,parse_dates=True,index_col='timestamp', sep='\s+', date_parser=dateparse)
    df_sen_period=df_sen
    df_sen_period.replace(0, np.nan, inplace=True) # replace 0 by nan
    df_sen_period=df_sen_period.dropna()
    
    ax.plot(df_sen_period['lon'], df_sen_period['lat'],
        line_type, linewidth=1, markersize=3, transform=ccrs.Geodetic(), label=casename)


plt.legend(loc='best', fontsize=SMFONT)
plt.title('Observational and Simulated Tracks of Mangkhut (1822)',fontsize=MIDFONT)
plt.savefig('../../fig/paper/trck.'+FIG_FMT, dpi=300, bbox_inches='tight')
>>>>>>> 75a837b9114fa700d7c747568656409a749565ac
plt.close('all')
#plt.show()
