import numpy as np
import xarray as xr
import scipy.io as sp 


def get_closest_idx(lat2d, lon2d, lat0, lon0):
    dis_lat2d=lat2d-lat0
    dis_lon2d=lon2d-lon0
    dis=abs(dis_lat2d)+abs(dis_lon2d)
    idx=np.argwhere(dis==dis.min()).tolist()[0] # x, y position
    return idx 


lonl= 113.8257
lonr=114.4837
latb= 22.1209
latt= 22.6227


all_grid_list=['rho', 'u', 'v', 'psi']

file_dir='/home/lzhenn/array74/workspace/calypso_pipeline/domaindb/swant1t2/'
ds_in=xr.load_dataset(file_dir+'roms_d02_lp0d1.bck.nc')
ds_out=xr.load_dataset(file_dir+'roms_d02.nc')

for var in all_grid_list:
    lat2d_org=ds_in['lat_'+var]
    lon2d_org=ds_in['lon_'+var]
    lat2d_tgt=ds_out['lat_'+var]
    lon2d_tgt=ds_out['lon_'+var]
    
    mask_org=ds_in['mask_'+var]
    mask_tgt=ds_out['mask_'+var]
    
    dom_shp=lat2d_tgt.shape
    for irow in range(0, dom_shp[0]):    
        for icol in range(0, dom_shp[1]):    
            idx, idy=get_closest_idx(
                lat2d_org.values, lon2d_org.values, 
                lat2d_tgt[irow,icol].values, lon2d_tgt[irow,icol].values)
            mask_tgt[irow, icol]=mask_org[idx,idy]
        print(irow/dom_shp[0])
ds_out.to_netcdf(file_dir+'roms_d02.nc', mode='a')


