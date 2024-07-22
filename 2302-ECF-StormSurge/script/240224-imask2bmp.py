import numpy as np
import xarray as xr
from PIL import Image, ImageDraw 

ncfile='/home/lzhenn/array74/Njord_Calypso/domaindb/poseidon_1500m_L12/roms_d03_omp.nc.bck'
bmpfile='../fig/roms_d03_omp.bmp'
ds=xr.open_dataset(ncfile)

imask=ds['mask_rho'].values[::-1,:]
im_w, im_h = imask.shape
# Convert the mask to a PIL image
im = Image.fromarray(imask.astype(np.uint8) * 255, mode="L")
# Save the image as a BMP file
im.save(bmpfile)
