import xarray as xr
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.colors import ListedColormap
varname='zeta'
SHP='/home/lzhenn/array74/data/shp/gadm41_CHN_2.dbf'
# 2-ocean coast
MASK='/home/lzhenn/array74/workspace/uranus/uranus/domaindb/poseidon_1500m_L12/classified_mask.nc'
LU='/home/lzhenn/array74/data/hk_landuse/LUM_end2022_latlon.nc'
#MAX_FN=f'/home/lzhenn/array130/poseidon/2018091200_noluzon/roms_max_{varname}_d03.nc'
#MAX_FN=f'/home/lzhenn/array129/poseidon/2018091200_2050thermo/roms_max_{varname}_d03.nc'
MAX_FN=f'/home/lzhenn/array129/poseidon/2018091200/roms_max_{varname}_d03.nc'

STA_FN='../adhoc_data/station.csv'

SMFONT=14

# Load your original nc file
ds_lu = xr.open_dataset(LU)
fig, ax = plt.subplots(figsize=(10, 8))
lu=ds_lu['lu']
lu.values=np.where(lu==0,99,lu)
lu.values=np.where(lu<=62,1,np.nan)
lats,lons=ds_lu['lat'].values,ds_lu['lon'].values

colors = {
    0: 'blue',  # All human 
    1: 'white', # natural 
}

# Create a color map
cmap = ListedColormap([colors[0], colors[1]])
ax.pcolormesh(lons,lats, lu, cmap=cmap)

# Load mask 
ds_mask = xr.open_dataset(MASK)
# Create a figure with Cartopy
mask=ds_mask['mask_rho']
lats,lons=ds_mask['lat_rho'].values,ds_mask['lon_rho'].values

# Create a mask for coastal ocean (classified_mask_da == 2)
coastal_mask = mask == 2
land_mask = mask < 2

# Get coordinates of the grid
y_indices, x_indices = np.where(coastal_mask)

colors = {
    0: 'dodgerblue',  # All land
    1: 'gray', # Land with sea neighbor
}

# Create a color map
cmap = ListedColormap([colors[0], colors[1]])
ax.pcolormesh(lons,lats, land_mask, cmap=cmap, alpha=0.5)


'''
ds=xr.open_dataset(MAX_FN)
max_var = ds[varname][0,:,:].values 



# Define marker properties
marker_properties = {
    'extreme_high': {'size': 6, 'color': 'purple', 'label': '> 6.0 m'},
    'super_high': {'size': 5, 'color': 'violet', 'label': '> 5.0 m'},
    'very_high': {'size': 4, 'color': 'darkred', 'label': '> 4.0 m'},
    'high': {'size': 3, 'color': 'red', 'label': '> 3.0 m'},
    'medium': {'size': 2, 'color': 'orange', 'label': '> 2.0 m'},
    'low': {'size': 2, 'color': 'green', 'label': '> 1.0 m'},
    'very_low': {'size': 1, 'color': 'gray', 'label': '<= 1.0 m'},
}
# Plot markers based on max_hwave values
for y, x in zip(y_indices, x_indices):
    #value = max_var[y, x]
    value = max_var[y, x]+1.3
    lat,lon=lats[y,x],lons[y,x]
    if value > 6.0:
        ax.plot(lon,lat, 'o', markersize=marker_properties['extreme_high']['size'], color=marker_properties['extreme_high']['color'],zorder=99)
    elif value > 5.0:
        ax.plot(lon,lat, 'o', markersize=marker_properties['super_high']['size'], color=marker_properties['super_high']['color'],zorder=15)
    elif value > 4.0:
        ax.plot(lon,lat, 'o', markersize=marker_properties['very_high']['size'], color=marker_properties['very_high']['color'],zorder=10)
    elif value > 3.0:
        ax.plot(lon,lat, 'o', markersize=marker_properties['high']['size'], color=marker_properties['high']['color'],zorder=5)
    elif value > 2.0:
        ax.plot(lon,lat, 'o', markersize=marker_properties['medium']['size'], color=marker_properties['medium']['color'],zorder=2)
       
# Create legend handles for the markers
amp=1.5
handles = [
    plt.Line2D([0], [0], marker='o', color='w', label=marker_properties['extreme_high']['label'],
        markerfacecolor=marker_properties['extreme_high']['color'], markersize=marker_properties['extreme_high']['size']*amp),
    plt.Line2D([0], [0], marker='o', color='w', label=marker_properties['super_high']['label'],
        markerfacecolor=marker_properties['super_high']['color'], markersize=marker_properties['extreme_high']['size']*amp),
    plt.Line2D([0], [0], marker='o', color='w', label=marker_properties['very_high']['label'],
        markerfacecolor=marker_properties['very_high']['color'], markersize=marker_properties['very_high']['size']*amp),
    plt.Line2D([0], [0], marker='o', color='w', label=marker_properties['high']['label'],
               markerfacecolor=marker_properties['high']['color'], markersize=marker_properties['high']['size']*amp),
    plt.Line2D([0], [0], marker='o', color='w', label=marker_properties['medium']['label'],
               markerfacecolor=marker_properties['medium']['color'], markersize=marker_properties['high']['size']*amp),
 #   plt.Line2D([0], [0], marker='o', color='w', label=marker_properties['low']['label'],
 #              markerfacecolor=marker_properties['low']['color'], markersize=marker_properties['high']['size']*amp),
]

station_data=pd.read_csv(STA_FN)
# Plot each station with a marker and annotation
for index, row in station_data.iterrows():
    lon = row['lon']
    lat = row['lat']

    # Plot the station position
    ax.plot(lon, lat, marker='*', color='black', markersize=10, zorder=100)

    # Create the annotation text
    annotation_text = (
        f"{row['name']}\n"
        f"Obv: {row['all_obv']:.2f}m ({row['surge_obv']:.2f}m)\n"
        f"Sim: {row['all_sim']:.2f}m ({(row['all_sim']-row['tide_obv']):.2f}m)")
    # Annotate the station on the map
    ax.annotate(annotation_text, xy=(lon+0.05, lat-0.01), xytext=(3, 3), textcoords="offset points",
                fontsize=9, color='black', ha='right', va='top',zorder=999)

# Add the legend to the plot
ax.legend(handles=handles, title='Total Water Level',loc='lower right')
#ax.legend(handles=handles, title='Surge Level (above Astronomical Tide)',loc='lower right')
'''
plt.xticks( fontsize=SMFONT)
plt.yticks( fontsize=SMFONT)


plt.savefig(f'../fig/240930_LU.png', dpi=900, bbox_inches='tight')





