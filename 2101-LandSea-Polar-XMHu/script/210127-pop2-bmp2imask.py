import sys, datetime
import numpy as np
import xarray as xr
from PIL import Image, ImageDraw 

# arguments in
args=sys.argv
if len(args) ==3:
    WRK_DIR=args[1]
    BMP_FILE=args[2]
else:
    WRK_DIR='/home/lzhenn/workspace/xmhu-largerAU/'
    BMP_FILE='btmap_drake_closure.bmp'

timestamp=datetime.datetime.now().strftime('%y%m%d')
im_w=384
im_h=320

ds=xr.open_dataset(WRK_DIR+'gx1v6_090205.nc')
imask=ds.grid_imask
im = Image.open(WRK_DIR+BMP_FILE)
values=list(im.getdata())
for x in range(im_w):
    for y in range(im_h):
        imask.values[x*im_h+y]=values[y*im_w+x]

imask.values=imask.values/255
ds.to_netcdf(WRK_DIR+'gx1v6_chg_'+timestamp+'.nc')
