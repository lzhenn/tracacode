import numpy as np
import xarray as xr
from PIL import Image, ImageDraw 

ds=xr.open_dataset('/home/lzhenn/array74/Njord_Calypso/domaindb/poseidon_lantau_tmr_L12/roms_d03_omp.nc')

imask=ds['mask_rho'].values
im_h, im_w = imask.shape
image = Image.new('1', (im_w, im_h), 0)
draw = ImageDraw.Draw(image)
for x in range(im_w):
    for y in range(im_h):
        draw.point((x, y), fill=int(imask[y,-x]))
image.save('../fig/bitmap_d03_rho.bmp', 'bmp')
