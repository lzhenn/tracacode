import sys, datetime
import numpy as np
import xarray as xr

args=sys.argv
if len(args)==2:
    WRK_DIR=args[1]

im_w=384
im_h=320
timestamp=datetime.datetime.now().strftime('%y%m%d')

bathy=np.fromfile(WRK_DIR+'topography_20090204.ieeei4',dtype='>i4') # '>i4' big-endian 4 byte int
ds_new=xr.open_dataset(WRK_DIR+'gx1v6_chg_'+timestamp+'.nc')
ds_org=xr.open_dataset(WRK_DIR+'gx1v6_090205.nc')

imask_new=ds_new.grid_imask
imask_org=ds_org.grid_imask

maskdiff=imask_new-imask_org

bathy=np.where(maskdiff<0, 0, bathy)
bathy.astype('>i4').tofile(WRK_DIR+'topography_'+timestamp+'.ieeei4')
