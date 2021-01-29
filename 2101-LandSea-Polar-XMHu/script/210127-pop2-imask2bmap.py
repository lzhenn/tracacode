import numpy as np
import xarray as xr
from PIL import Image, ImageDraw 

im_w=384
im_h=320
<<<<<<< HEAD
ds=xr.open_dataset('/home/metctm1/array/data/2101-LandSea-Polar-XMHu/gx1v6_larger_aus_090205.nc')
=======
ds=xr.open_dataset('/home/lzhenn/workspace/xmhu-largerAU/gx1v6_larger_aus_090205.nc')
>>>>>>> 3a1678884c09f43da01d0c3444f6b8e14c4f3b0c
imask=ds.grid_imask.values.reshape((im_w,im_h))

image = Image.new('1', (im_w, im_h), 0)
draw = ImageDraw.Draw(image)
for x in range(im_w):
    for y in range(im_h):
        draw.point((x, y), fill=int(imask[x,y]))
image.save('../fig/bitmap_larger_aus.bmp', 'bmp')
