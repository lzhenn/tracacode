import numpy as np
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg') 
from netCDF4 import Dataset
from wrf import getvar, to_np, latlon_coords, interplevel
import cartopy.crs as crs
import cartopy.feature as cfeature

from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER

# Open the NetCDF file
ncfile = Dataset("/home/lzhenn/SEAtest/201311_1285x1055_25hpa/wrfout_d01_2013-11-14_19:00:00")

# Extract the U wind component
u = getvar(ncfile, "ua", timeidx=0)

# Extract the pressure levels
p = getvar(ncfile, "pressure", timeidx=0)

# Interpolate U to 75 mb
u_75 = interplevel(u, p, 75)

# Get the latitude and longitude points
lats, lons = latlon_coords(u_75)

# Create a plot
fig, ax = plt.subplots(figsize=(10, 8), subplot_kw={'projection': crs.PlateCarree()})
ax.coastlines(resolution='50m', linewidth=1)
ax.add_feature(cfeature.BORDERS, linewidth=0.5)

# Plot the U wind speed using pcolormesh
mesh = ax.pcolormesh(to_np(lons), to_np(lats), to_np(u_75), cmap='coolwarm', transform=crs.PlateCarree())

# Add a color bar
plt.colorbar(mesh, ax=ax, orientation='vertical', label='U Wind Speed (m/s)')

# Set the map bounds
ax.set_extent([np.min(to_np(lons)), np.max(to_np(lons)), np.min(to_np(lats)), np.max(to_np(lats))], crs=crs.PlateCarree())

# Add gridlines
gl = ax.gridlines(draw_labels=True, linewidth=0.5, color='gray', linestyle='--')
gl.xformatter = LONGITUDE_FORMATTER
gl.yformatter = LATITUDE_FORMATTER

# Add a title
plt.title("75 mb U Wind Speed")

# Save the figure
plt.savefig("75mb_u_wind_speed.png")

# Close the plot to free memory
plt.close()
