import matplotlib,os
import xarray as xr
import numpy as np
import matplotlib.pyplot as plt
matplotlib.use('agg')
# Constants
BIGFONT=32
MIDFONT=12
SMFONT=10

work_path='/home/lzhenn/array130/poseidon/2018091200_noluzon/'
#work_path='/home/lzhenn/array129/poseidon/2018091200/'
# File paths
roms_fn=f'{work_path}/roms_his_d03_00001.nc'

ds= xr.load_dataset(roms_fn)
ix = 476
iys = 384
iye = 404 

# Extract h values for the specified longitude and latitude range
h_slice = ds.h.isel(xi_rho=ix, eta_rho=slice(iys, iye))
# Extract the corresponding latitudes
lats_slice = ds.lat_rho.isel(xi_rho=ix, eta_rho=slice(iys,iye))
h_slice=xr.where(h_slice==2,0,h_slice)
h_slice=-h_slice
# Create a plot
plt.figure(figsize=(10, 6))
# Plot the data
plt.plot(layout='tight' )

plt.fill_between(
        lats_slice,0, 3,
        color='lightblue',alpha=0.8)
plt.fill_between(
        lats_slice, h_slice, 0,
        label='Bathymetry',color='blue',alpha=0.8)
plt.fill_between(
        lats_slice, -22,h_slice, 
        color='gray',alpha=0.8)
plt.plot(lats_slice, h_slice, color='black',linestyle='-')

plt.grid(True)
    
# Add labels, title, legend, and grid
plt.xticks( fontsize=SMFONT, rotation=15)
plt.yticks( fontsize=SMFONT) 
plt.xlabel('Latitude', fontsize=SMFONT)
plt.ylabel('Bathymetry (m)', fontsize=SMFONT)
plt.title(f'Bathymetry Cross Section', fontsize=MIDFONT)
plt.legend(fontsize=SMFONT)
plt.ylim((-22,3.0))
plt.savefig(os.path.join(f'../fig/tolo_harbour_bathy_sect.png'), 
    dpi=300, bbox_inches='tight', pad_inches=0)
