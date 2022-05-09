import sys, datetime
import numpy as np
import xarray as xr

args=sys.argv
if len(args)==2:
    WRK_DIR=args[1]

timestamp=datetime.datetime.now().strftime('%Y%m%d')
timestamp_grid=datetime.datetime.now().strftime('%y%m%d')

region_mask=np.fromfile(WRK_DIR+'region_mask_20090205.ieeei4',dtype='>i4') # '>i4' big-endian 4 byte int
ds_new=xr.open_dataset(WRK_DIR+'gx1v6_chg_'+timestamp_grid+'.nc')
ds_org=xr.open_dataset(WRK_DIR+'gx1v6_090205.nc')

imask_new=ds_new.grid_imask
imask_org=ds_org.grid_imask

maskdiff=imask_new-imask_org

region_mask=np.where(maskdiff<0, 0, region_mask)
region_mask.astype('>i4').tofile(WRK_DIR+'region_mask_'+timestamp+'.ieeei4')


