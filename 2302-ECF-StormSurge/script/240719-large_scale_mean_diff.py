
import xarray as xr
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('agg')
import cartopy.crs as ccrs
import cartopy.feature as cfeature

# Define the file paths
path = '/home/metctm1/array86/data/cmip6/cmip6-esm-bias-corrected/'
future_file_pattern = path + 'atm_ssp585_{:04d}_{:02d}.nc4'
present_file_pattern = path + 'atm_hist_{:04d}_{:02d}.nc4'
fyears=range(2040,2050)
pyears=range(2000,2004)
mons=[7,8,9]
var='hur'
# Create a list of files for the months of July, August, and September from 2040 to 2049
files = []
for year in fyears:
    for month in mons:
        files.append(future_file_pattern.format(year, month))
# Load all the files into a single dataset
ds_future = xr.open_mfdataset(files, combine='by_coords')
# Compute the mean along the time dimension
future_mean = ds_future[var].sel(lev=100000,lat=slice(-10,45), lon=slice(90, 160)).mean(dim='time')

files = []
for year in pyears:
    for month in mons:
        files.append(present_file_pattern.format(year, month))
# Load all the files into a single dataset
ds_present = xr.open_mfdataset(files, combine='by_coords')
# Compute the mean along the time dimension
present_mean = ds_present[var].sel(lev=100000,lat=slice(-10,45), lon=slice(90, 160)).mean(dim='time')

diff = future_mean - present_mean 

# Plotting
fig = plt.figure(figsize=(10, 8))
ax = plt.axes(projection=ccrs.PlateCarree())
ax.coastlines()
img = diff.plot(
    ax=ax,
    transform=ccrs.PlateCarree(),
    cmap='BrBG',
    vmin=-5,
    vmax=5,
    cbar_kwargs={
        'label': 'Specific Humidity Difference (g/kg)',
        'shrink': 0.6,  # Adjust the shrink parameter to make the colorbar smaller
        #'orientation': 'horizontal',  # Change orientation to horizontal for better visualization
        #'pad': 0.1  # Adjust the padding between the plot and the colorbar
    }
)
ax.coastlines()
ax.add_feature(cfeature.BORDERS, linestyle=':')

#ax.add_feature(cfeature.BORDERS, linestyle=':')
ax.set_extent([90, 160, -10, 45], crs=ccrs.PlateCarree())
ax.set_title('Surface Specific Humidity Difference (2040s - 2010s)')
plt.savefig('../fig/240719-large_scale_mean_diff_hus.png', dpi=100)

