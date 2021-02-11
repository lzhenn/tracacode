import sys, datetime
import numpy as np
import xarray as xr

args=sys.argv
if len(args)==2:
    WRK_DIR=args[1]
timestamp=datetime.datetime.now().strftime('%Y%m%d')
timestamp_grid=datetime.datetime.now().strftime('%y%m%d')

n_tr=2
n_layer=60
n_w=384
n_h=320

tracer=np.fromfile(WRK_DIR+'ts_PHC2_jan_ic_gx1v6_20090205.ieeer8',dtype='>f8') # '>f8' big-endian 8 byte float
tracer=np.reshape(tracer, (n_tr, n_layer, n_w*n_h), order='A')

ds_new=xr.open_dataset(WRK_DIR+'gx1v6_chg_'+timestamp_grid+'.nc')
ds_org=xr.open_dataset(WRK_DIR+'gx1v6_090205.nc')

imask_new=ds_new.grid_imask
imask_org=ds_org.grid_imask

maskdiff=imask_new-imask_org
for ii in range(0, n_tr):
    for jj in range(0, n_layer):
        tracer[ii,jj,:]=np.where(maskdiff<0, -99.0, tracer[ii,jj,:])
tracer.astype('>f8').tofile(WRK_DIR+'ts_PHC2_jan_ic_gx1v6_'+timestamp+'.ieeer8')


