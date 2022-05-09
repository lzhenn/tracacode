import numpy as np
import xarray as xr
from PIL import Image, ImageDraw 

im_w=556
im_h=334
ds=xr.open_dataset('/home/lzhenn/cooperate/data/new_roms_d02.nc')

imask=ds['mask_rho'].values

image = Image.new('1', (im_w, im_h), 0)
draw = ImageDraw.Draw(image)
for x in range(im_w):
    for y in range(im_h):
        draw.point((x, y), fill=int(imask[y,-x]))
image.save('../fig/bitmap_d02_rho.bmp', 'bmp')
