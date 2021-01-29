import numpy as np
import xarray as xr
im_w=384
im_h=320

bathy=np.fromfile('/home/lzhenn/workspace/xmhu-largerAU/topography_20090204_larger_aus.ieeei4',dtype='>i4') # '>i4' big-endian 4 byte int
print(bathy.tolist())
ds_new=xr.open_dataset('/home/lzhenn/workspace/xmhu-largerAU/gx1v6_larger_aus_090205.nc')
ds_org=xr.open_dataset('/home/lzhenn/workspace/xmhu-largerAU/gx1v6_090205.nc')

imask_new=ds_new.grid_imask
imask_org=ds_org.grid_imask

maskdiff=imask_new-imask_org

bathy=np.where(maskdiff<0, 0, bathy)
bathy.astype('>i4').tofile('/home/lzhenn/workspace/xmhu-largerAU/topography_20090204_larger_aus.ieeei4')
