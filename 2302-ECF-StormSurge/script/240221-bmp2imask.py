import xarray as xr
import numpy as np
from PIL import Image
work_dir='/home/lzhenn/array74/Njord_Calypso/domaindb/poseidon_LTtmr_L12/'
ncfile=f'{work_dir}/roms_d03_omp.nc.bck'
bmpfile=f'{work_dir}/LTtmr_binary.bmp'
outfile=f'{work_dir}/roms_d03.nc'


ds=xr.open_dataset(ncfile)
im = Image.open(bmpfile)
bmp_array = np.array(im)
bmp_array = bmp_array[::-1,:] 
print(bmp_array)
ds['mask_rho'].values=bmp_array
ds.to_netcdf(outfile)
