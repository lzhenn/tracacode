
import xarray as xr
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('agg')
import cartopy.crs as ccrs
import cartopy.feature as cfeature

# Define the file paths
path = '/home/metctm1/array86/data/cmip6/cmip6-esm-bias-corrected/lnd/'
future_file_pattern = path + 'lnd.ssp585.{:04d}09.nc'
fyears=range(2015,2050)
var='tas'
# Create a list of files for the months of July, August, and September from 2040 to 2049
files = []
for year in fyears:
    files.append(future_file_pattern.format(year))
# Load all the files into a single dataset
ds_future = xr.open_mfdataset(files, combine='by_coords')
# Compute the mean along the time dimension
future_mean = ds_future[var].sel(
    lat=slice(-10,45), lon=slice(90, 160)).mean(dim=['lat','lon'])

# Plotting
# Plot the time series with the specified settings
plt.figure(figsize=(10, 6))
future_mean.plot(color='red')
plt.title("Sep SST (SSP5-8.5) Timeseries over 10S~45N, 90E-160E")
plt.ylabel("SST")
plt.xlabel("Date")
plt.grid(True)
plt.savefig('../fig/240730-sst-sep-ts.png', dpi=100,bbox_inches='tight')

