#/usr/bin/env python
'''
Date:  Nov 23, 2020 

Draw TC Track Comparison 

Zhenning LI

'''
from netCDF4 import Dataset
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import shapely.geometry as sgeom
import cartopy.crs as ccrs
import shapely.geometry as sgeom
from copy import copy
import xarray as xr

# Constants
BIGFONT=22
MIDFONT=18
SMFONT=14

MAP_RES='50m'
FIG_FMT='png'



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




nc_path='/home/lzhenn/array74/workspace/uranus/uranus/domaindb/njord_noluzon/roms_d01_omp.nc'
#province_shp_file=os.getenv('SHP_LIB')+'/cnmap/cnhimap.dbf'
# ----------Get NetCDF data------------
print('Read NC...')

ds = xr.open_dataset(nc_path) 
lsmask=ds['mask_rho']
lsmask.values=np.logical_not(lsmask.values)

# Get the lat/lon coordinates
lats, lons = ds['lat_rho'], ds['lon_rho'] 

# Province shp file
# read shp files
#province_shp=shpreader.Reader(province_shp_file).geometries()
# Create the figure
# ----------seperate land/sea---------

# Get the map projection information
fig = plt.figure(figsize=(12,8), frameon=True)
proj = ccrs.PlateCarree() 
ax = fig.add_axes([0.08, 0.05, 0.8, 0.94], projection=proj)

# Download and add the states and coastlines
ax.coastlines(MAP_RES, linewidth=0.8)
# Add ocean, land, rivers and lakes
#ax.add_feature(cfeature.OCEAN.with_scale(MAP_RES))
#ax.add_feature(cfeature.LAND.with_scale(MAP_RES))
#ax.add_feature(cfeature.LAKES.with_scale(MAP_RES))
# *must* call draw in order to get the axis boundary used to add ticks:
fig.canvas.draw()
# Define gridline locations and draw the lines using cartopy's built-in gridliner:
# xticks = np.arange(80,130,10)
# yticks = np.arange(15,55,5)
#xticks = np.arange(109,118.5,1.5).tolist() 
#yticks =  np.arange(18,27,1.5).tolist() 
#ax.gridlines(xlocs=xticks, ylocs=yticks,zorder=1,linestyle='--',lw=0.5,color='gray')
#gl = ax.gridlines(draw_labels=True, alpha=0.0)
#gl.right_labels = False
#gl.top_labels = False
#ax.set_xticks(xticks, crs=ccrs.PlateCarree())
#ax.set_yticks(yticks, crs=ccrs.PlateCarree())
#lon_formatter =LongitudeFormatter(number_format='.1f')
#lat_formatter = LatitudeFormatter(number_format='.1f')
#ax.xaxis.set_major_formatter(lon_formatter)
#ax.yaxis.set_major_formatter(lat_formatter)
#ax.tick_params(axis='both', which='major', labelsize=SMFONT)
#for tick in ax.xaxis.get_major_ticks():
#    tick.label.set_fontsize(SMFONT) 
# Label the end-points of the gridlines using the custom tick makers:
#ax.xaxis.set_major_formatter(LONGITUDE_FORMATTER) 
#ax.yaxis.set_major_formatter(LATITUDE_FORMATTER)
#mct_xticks(ax, xticks)
#mct_yticks(ax, yticks)

plt.pcolormesh(
    self.lons, self.lats, max_var.values[0,:,:],
    norm=norm,
    transform=ccrs.PlateCarree(), cmap=cmap)
# Set the map bounds
ax.set_xlim(cartopy_xlim(lsmask))
ax.set_ylim(cartopy_ylim(lsmask))




plt.title('LANDMASK',fontsize=MIDFONT)
plt.savefig('../fig/lndmask.'+FIG_FMT, dpi=300, bbox_inches='tight')
plt.close('all')
#plt.show()

  
