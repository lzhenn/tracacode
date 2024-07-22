import xarray as xr
import os
import matplotlib
import matplotlib.pyplot as plt
matplotlib.use('agg')
import numpy as np

# set the paths to the two directories containing the ROMS output files
path1 = '/home/lzhenn/array74/data/archive/poseidon/2018091600LTtmr/mean/'
path2 = '/home/lzhenn/array74/data/archive/poseidon/2018091600/mean/'
var='zeta'
dom='d03'
ibnd=(0,276)
jbnd=(75,276)
# create empty lists to hold the Hwave data for each directory
data1 = []
data2 = []

# loop over each file in the first directory and read in the Hwave data
for idx, file in enumerate(os.listdir(path1)):
    if file.startswith(f'roms_his_{dom}'):
        file_path = os.path.join(path1, file)
        ds=xr.open_dataset(file_path)
        data1.append(ds[var])
        if idx==0:
            # create a meshgrid of the latitudes and longitudes
            lon, lat = ds['lon_rho'].values, ds['lat_rho'].values


# loop over each file in the second directory and read in the Hwave data
for file in os.listdir(path2):
    if file.startswith(f'roms_his_{dom}'):
        file_path = os.path.join(path2, file)
        data2.append(xr.open_dataset(file_path)[var])

# combine the Hwave data for each directory into a single xarray dataset
dataset1 = xr.concat(data1, dim='ocean_time')
dataset2 = xr.concat(data2, dim='ocean_time')

# calculate the mean Hwave for each directory along the ocean_time dimension
mean1 = dataset1.max(dim='ocean_time')
mean2 = dataset2.max(dim='ocean_time')

# calculate the difference in the mean Hwave between the two directories
diff = mean1 - mean2
#diff=diff[0:ibnd[1],jbnd[0]:jbnd[1]]
#lat=lat[0:ibnd[1],jbnd[0]:jbnd[1]]
#lon=lon[0:ibnd[1],jbnd[0]:jbnd[1]]
# plot the Hwave difference using matplotlib's contourf function
fig = plt.figure(figsize=[10.24, 7.68],frameon=True)
plt.pcolormesh(lon, lat, diff, vmax=0.4,vmin=-0.4, cmap='RdBu_r')
plt.colorbar()
plt.gca().set_facecolor("black") 
plt.title(f'{var}_diff: LTtmr - CTRL')
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.savefig(os.path.join('../fig', f'{var}_diff'), dpi=100)