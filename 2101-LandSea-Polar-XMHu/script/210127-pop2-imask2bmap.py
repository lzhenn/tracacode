import numpy as np
import xarray as xr
from PIL import Image, ImageDraw 

im_w=384
im_h=320
ds=xr.open_dataset('/home/metctm1/array/data/2101-LandSea-Polar-XMHu/gx1v6_larger_aus_090205.nc')
imask=ds.grid_imask.values.reshape((im_w,im_h))

image = Image.new('1', (im_w, im_h), 0)
draw = ImageDraw.Draw(image)
for x in range(im_w):
    for y in range(im_h):
        draw.point((x, y), fill=int(imask[x,y]))
image.save('../fig/bitmap_larger_aus.bmp', 'bmp')
