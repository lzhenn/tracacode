from cProfile import label
import xarray as xr
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

varname='Hwave'
SHP='/home/lzhenn/array74/data/shp/gadm41_CHN_2.dbf'
# 2-ocean coast
MASK='/home/lzhenn/array74/workspace/uranus/uranus/domaindb/poseidon_1500m_L12/classified_mask.nc'
MAX_FN=f'/home/lzhenn/array129/poseidon/2018091200/roms_max_{varname}_d03.nc'
#MAX_FN=f'/home/lzhenn/array129/poseidon/2018091200_2050thermo/roms_max_{varname}_d03.nc'

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
ax.pcolormesh(lons,lats, land_mask, cmap='Greys', alpha=0.5)

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
    value = max_var[y, x]
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
    elif value > 1.0:
        ax.plot(lon,lat, 'o', markersize=marker_properties['low']['size'], color=marker_properties['low']['color'],zorder=1)
       
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
    plt.Line2D([0], [0], marker='o', color='w', label=marker_properties['low']['label'],
               markerfacecolor=marker_properties['low']['color'], markersize=marker_properties['high']['size']*amp),
]

# Add the legend to the plot
ax.legend(handles=handles, title='Wave Height',loc='lower right')
plt.xticks( fontsize=SMFONT)
plt.yticks( fontsize=SMFONT)


plt.savefig(f'../fig/240923_coastal_max_{varname}_current.png', dpi=200, bbox_inches='tight')
