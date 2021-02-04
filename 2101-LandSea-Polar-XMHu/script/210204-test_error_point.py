#/usr/bin/env python
'''
Date:  Feb 04, 2021 
Draw CESM cloudfrac error 
Zhenning LI
'''
import numpy as np
import pandas as pd
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

MAP_RES='110m'
FIG_FMT='pdf'


pt_path='~/temp/test.csv'

# ----------Get NetCDF data------------

# Read error points 
df_err=pd.read_csv(pt_path)
print(df_err)


print('Plot...')
# Create the figure


# ----------seperate land/sea---------

# Get the map projection information
fig = plt.figure(figsize=(12,8), frameon=True)
proj =ccrs.PlateCarree() 
ax = fig.add_axes([0.08, 0.05, 0.8, 0.94], projection=proj)

# Download and add the states and coastlines
ax.coastlines(MAP_RES, linewidth=0.8)



# Add ocean, land, rivers and lakes
ax.add_feature(cfeature.OCEAN.with_scale(MAP_RES))
ax.add_feature(cfeature.LAND.with_scale(MAP_RES))
ax.add_feature(cfeature.LAKES.with_scale(MAP_RES))
# *must* call draw in order to get the axis boundary used to add ticks:
fig.canvas.draw()
# Define gridline locations and draw the lines using cartopy's built-in gridliner:
# xticks = np.arange(80,130,10)
# yticks = np.arange(15,55,5)
xticks = np.arange(0,360,30).tolist() 
yticks =  np.arange(-90,90,15).tolist() 
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


ax.scatter(df_err['lon'], df_err['lat'],color='black', marker='o')

plt.legend(loc='best', fontsize=SMFONT)
plt.title('Error Points',fontsize=MIDFONT)
plt.savefig('../fig/err_points', dpi=300, bbox_inches='tight')
plt.close('all')
#plt.show()
