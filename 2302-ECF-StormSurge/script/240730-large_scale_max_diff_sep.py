
import xarray as xr
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('agg')
import cartopy.crs as ccrs
import cartopy.feature as cfeature

# Define the file paths
path = '/home/metctm1/array86/data/cmip6/cmip6-esm-bias-corrected/'
future_file_pattern = path + 'atm_ssp585_2050_09.nc4'
present_file_pattern = path + 'atm_hist_2014_09.nc4'
var='tos'
ds_future = xr.open_dataset(future_file_pattern)
# Compute the mean along the time dimension
future_mean = ds_future[var].sel(lat=slice(-10,45), lon=slice(90, 160)).mean(dim='time')

ds_present = xr.open_dataset(present_file_pattern)
# Compute the mean along the time dimension
present_mean = ds_present[var].sel(lat=slice(-10,45), lon=slice(90, 160)).mean(dim='time')

diff = future_mean - present_mean 

# Plotting
fig = plt.figure(figsize=((8, 15)))
ax = plt.axes(projection=ccrs.PlateCarree())
ax.coastlines()
img = diff.plot(
    ax=ax,
    transform=ccrs.PlateCarree(),
    cmap='coolwarm',
    vmin=-2.0,
    vmax=2.0,
    cbar_kwargs={
        'label': 'Temperature Difference (K)',
        'shrink': 0.6,  # Adjust the shrink parameter to make the colorbar smaller
        #'orientation': 'horizontal',  # Change orientation to horizontal for better visualization
        #'pad': 0.1  # Adjust the padding between the plot and the colorbar
    }
)
ax.coastlines()
ax.add_feature(cfeature.BORDERS, linestyle=':')

#ax.add_feature(cfeature.BORDERS, linestyle=':')
ax.set_extent([90, 160, -10, 45], crs=ccrs.PlateCarree())
ax.set_title('Sep SST Difference (2050 - 2018)')
plt.savefig('../fig/240730-large_scale_max_diff.png', dpi=100, bbox_inches='tight')

