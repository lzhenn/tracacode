from cProfile import label
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
#MAX_FN=f'/home/lzhenn/array130/poseidon/2018091200_noluzon/roms_max_{varname}_d03.nc'
#MAX_FN=f'/home/lzhenn/array129/poseidon/2018091200_2050thermo/roms_max_{varname}_d03.nc'
#SETUP_FN=f'/home/lzhenn/array129/poseidon/2018091200_2050thermo/roms_max_Hwave_d03.nc'
MAX_FN=f'/home/lzhenn/array129/poseidon/2018091200/roms_max_{varname}_d03.nc'

STA_FN='../adhoc_data/station.csv'

SMFONT=14

# Load your dataset
ds_mask = xr.open_dataset(MASK)
ds=xr.open_dataset(MAX_FN)

max_var = ds[varname][0,:,:].values 


# Create a figure with Cartopy
fig, ax = plt.subplots(figsize=(10, 10))
mask=ds_mask['mask_rho']
lats,lons=ds_mask['lat_rho'].values,ds_mask['lon_rho'].values
# Create a mask for coastal ocean (classified_mask_da == 2)
coastal_mask = mask == 2
land_mask = mask < 2

# Get coordinates of the grid
y_indices, x_indices = np.where(coastal_mask)

# Create a figure and axis
fig, ax = plt.subplots(figsize=(10, 8))

colors = {
    0: 'dodgerblue',  # All land
    1: 'gray', # Land with sea neighbor
}

# Create a color map
cmap = ListedColormap([colors[0], colors[1]])
ax.pcolormesh(lons,lats, land_mask, cmap=cmap, alpha=0.5)

# Define marker properties
marker_properties = {
    'summit': {'size': 8, 'color': 'white', 'label': '> 10.0 m'},
    'suprime_high': {'size': 6, 'color': 'blueviolet', 'label': '> 9.0 m'},
    'extreme_high': {'size': 6, 'color': 'purple', 'label': '> 8.0 m'},
    'super_high': {'size': 5, 'color': 'violet', 'label': '> 7.0 m'},
    'very_high': {'size': 4, 'color': 'darkred', 'label': '> 6.0 m'},
    'high': {'size': 3, 'color': 'red', 'label': '> 5.0 m'},
    'medium': {'size': 2, 'color': 'orange', 'label': '> 4.0 m'},
    'low': {'size': 2, 'color': 'green', 'label': '> 3.0 m'},
    'very_low': {'size': 1, 'color': 'gray', 'label': '<= 1.0 m'},
}
# Plot markers based on max_hwave values
for y, x in zip(y_indices, x_indices):
    #value = max_var[y, x]+0.5
    value = max_var[y, x]+1.3
    lat,lon=lats[y,x],lons[y,x]
    if value > 10.0:
        ax.plot(lon,lat, 'o', markersize=marker_properties['summit']['size'], color=marker_properties['summit']['color'],edge_color='black',zorder=99)
    elif value > 9.0:
        ax.plot(lon,lat, 'o', markersize=marker_properties['suprime_high']['size'], color=marker_properties['suprim_high']['color'],zorder=7)
    elif value > 8.0:
        ax.plot(lon,lat, 'o', markersize=marker_properties['extreme_high']['size'], color=marker_properties['extreme_high']['color'],zorder=6)
    elif value > 7.0:
        ax.plot(lon,lat, 'o', markersize=marker_properties['super_high']['size'], color=marker_properties['super_high']['color'],zorder=5)
    elif value > 6.0:
        ax.plot(lon,lat, 'o', markersize=marker_properties['very_high']['size'], color=marker_properties['very_high']['color'],zorder=4)
    elif value > 5.0:
        ax.plot(lon,lat, 'o', markersize=marker_properties['high']['size'], color=marker_properties['high']['color'],zorder=3)
    elif value > 4.0:
        ax.plot(lon,lat, 'o', markersize=marker_properties['medium']['size'], color=marker_properties['medium']['color'],zorder=2)
    elif value > 3.0:
        ax.plot(lon,lat, 'o', markersize=marker_properties['low']['size'], color=marker_properties['low']['color'],zorder=1)
       
# Create legend handles for the markers
amp=1.5
handles = [
    plt.Line2D([0], [0], marker='o', color='w', label=marker_properties['summit']['label'],
        markerfacecolor=marker_properties['summit']['color'],markeredgecolor='black', markersize=marker_properties['summit']['size']*amp),
    plt.Line2D([0], [0], marker='o', color='w', label=marker_properties['suprime_high']['label'],
        markerfacecolor=marker_properties['suprime_high']['color'], markersize=marker_properties['suprime_high']['size']*amp),
    plt.Line2D([0], [0], marker='o', color='w', label=marker_properties['extreme_high']['label'],
        markerfacecolor=marker_properties['extreme_high']['color'], markersize=marker_properties['extreme_high']['size']*amp),
    plt.Line2D([0], [0], marker='o', color='w', label=marker_properties['super_high']['label'],
        markerfacecolor=marker_properties['super_high']['color'], markersize=marker_properties['extreme_high']['size']*amp),
    plt.Line2D([0], [0], marker='o', color='w', label=marker_properties['very_high']['label'],
        markerfacecolor=marker_properties['very_high']['color'], markersize=marker_properties['very_high']['size']*amp),
    plt.Line2D([0], [0], marker='o', color='w', label=marker_properties['high']['label'],
               markerfacecolor=marker_properties['high']['color'], markersize=marker_properties['high']['size']*amp),
    plt.Line2D([0], [0], marker='o', color='w', label=marker_properties['medium']['label'],
               markerfacecolor=marker_properties['medium']['color'], markersize=marker_properties['medium']['size']*amp),
    plt.Line2D([0], [0], marker='o', color='w', label=marker_properties['low']['label'],
               markerfacecolor=marker_properties['low']['color'], markersize=marker_properties['low']['size']*amp),
]

station_data=pd.read_csv(STA_FN)
# Plot each station with a marker and annotation
for index, row in station_data.iterrows():
    lon = row['lon']
    lat = row['lat']

    # Plot the station position
    ax.plot(lon, lat, marker='*', color='black', markersize=10, zorder=100)

    # Create the annotation text
    '''
    annotation_text = (
        f"{row['name']}\n"
        f"Obv: {row['all_obv']:.2f}m ({row['surge_obv']:.2f}m)\n"
        f"Sim: {row['all_sim']:.2f}m ({(row['all_sim']-row['tide_obv']):.2f}m)")
    '''
    annotation_text = (
        f"{row['name']}\n"
       #f"Obv:{row['surge_obv']:.2f}m\n"
       #f"{(row['all_sim']-row['tide_obv']):.2f}m")
        f"{(row['all_obv']):.2f}m\n"
        f"Tide: {row['tide_obv']:.2f}m\n"
        f"Surge: {row['surge_obv']:.2f}m")

    # Annotate the station on the map
    ax.annotate(annotation_text, xy=(lon+0.05, lat-0.01), xytext=(3, 3), textcoords="offset points",
                fontsize=9, color='black', ha='right', va='top',zorder=999)


# Add the legend to the plot
#ax.legend(handles=handles, title='Surge Level (above Chart Datum)',loc='lower right')
ax.legend(handles=handles, title='Total Water Level',loc='lower right')
plt.xticks( fontsize=SMFONT)
plt.yticks( fontsize=SMFONT)


plt.savefig(f'../fig/240923_coastal_max_{varname}.png', dpi=200, bbox_inches='tight')
