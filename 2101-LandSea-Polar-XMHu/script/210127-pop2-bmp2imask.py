import numpy as np
import xarray as xr
from PIL import Image, ImageDraw 

im_w=384
im_h=320
ds=xr.open_dataset('/home/metctm1/array/data/2101-LandSea-Polar-XMHu/gx1v6_090205.nc')
imask=ds.grid_imask

im = Image.open('../fig/bitmap_large_aus.bmp')
values=list(im.getdata())

for x in range(im_w):
    for y in range(im_h):
        imask.values[x*im_h+y]=values[y*im_w+x]

imask.values=imask.values/255
ds.to_netcdf('/home/metctm1/array/data/2101-LandSea-Polar-XMHu/gx1v6_larger_aus_090205.nc')

