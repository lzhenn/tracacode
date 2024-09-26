import xarray as xr
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
import cartopy.crs as ccrs
import geopandas as gpd
import cartopy.io.shapereader as shpreader

SHP='/home/lzhenn/array74/data/shp/gadm41_CHN_2.dbf'
#SHP='/home/lzhenn/array74/data/shp/Hong_Kong/DCD.shp'
# Load your dataset
ds = xr.open_dataset('/home/lzhenn/array74/workspace/uranus/uranus/domaindb/poseidon_1500m_L12/classified_mask.nc')
# Define colors for each classification
colors = {
    0: 'green',  # All land
    1: 'yellow', # Land with sea neighbor
    2: 'blue',   # Sea with land neighbor
    3: 'lightblue'  # All sea
}

# Create a color map
cmap = ListedColormap([colors[0], colors[1], colors[2], colors[3]])

   
# Create a figure with Cartopy
fig, ax = plt.subplots(figsize=(10, 10), subplot_kw={'projection': ccrs.PlateCarree()})
mask=ds['mask_rho']
# Plot the classified grid
pcolormesh = ax.pcolormesh(ds['lon_rho'], ds['lat_rho'], mask,
                            cmap=cmap, shading='auto', transform=ccrs.PlateCarree())
# Plot the shapefile

amdn_shp=shpreader.Reader(SHP).geometries()
ax.add_geometries(
    amdn_shp, ccrs.PlateCarree(),
    facecolor='none', edgecolor='black',linewidth=1, zorder = 1)
    
# Add features
ax.set_title('Hong Kong Administrative Region with Classified Grids')
ax.set_xlabel('Longitude')
ax.set_ylabel('Latitude')

plt.savefig('../fig/classified_grids.png', dpi=300)

