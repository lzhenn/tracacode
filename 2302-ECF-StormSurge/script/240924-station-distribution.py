from cProfile import label
import xarray as xr
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.colors import ListedColormap
import pandas as pd

varname='zeta'
SHP='/home/lzhenn/array74/data/shp/gadm41_CHN_2.dbf'
# 2-ocean coast
MASK='/home/lzhenn/array74/workspace/uranus/uranus/domaindb/poseidon_1500m_L12/classified_mask.nc'
STA_FN='../adhoc_data/station.csv'
SMFONT=14

# Load your dataset
ds_mask = xr.open_dataset(MASK)

# Create a figure with Cartopy
mask=ds_mask['mask_rho']
lats,lons=ds_mask['lat_rho'].values,ds_mask['lon_rho'].values
# Create a mask for coastal ocean (classified_mask_da == 2)
land_mask = mask < 2

# Create a figure and axis
fig, ax = plt.subplots(figsize=(10, 8))

colors = {
    0: 'dodgerblue',  # All land
    1: 'gray', # Land with sea neighbor
}

# Create a color map
cmap = ListedColormap([colors[0], colors[1]])
ax.pcolormesh(lons,lats, land_mask, cmap=cmap, alpha=0.7)


station_data=pd.read_csv(STA_FN)
# Plot each station with a marker and annotation
for index, row in station_data.iterrows():
    lon = row['lon']
    lat = row['lat']

    # Plot the station position
    ax.plot(lon, lat, marker='*', color='black', markersize=10, zorder=100)

    # Create the annotation text
    annotation_text = (
        f"{row['name']} ({row['short']})")
    # Annotate the station on the map
    ax.annotate(annotation_text, xy=(lon+0.05, lat-0.01), xytext=(3, 3), textcoords="offset points",
                fontsize=SMFONT, color='black', ha='right', va='top',zorder=999)

#ax.legend(handles=handles, title='Surge Level (above Astronomical Tide)',loc='lower right')
plt.xticks( fontsize=SMFONT)
plt.yticks( fontsize=SMFONT)


plt.savefig(f'../fig/240924_station_distribution.png', dpi=200, bbox_inches='tight')
