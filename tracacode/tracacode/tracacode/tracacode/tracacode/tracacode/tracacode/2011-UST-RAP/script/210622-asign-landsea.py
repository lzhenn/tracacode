import numpy as np
import xarray as xr
import scipy.io as sp 

def find_nearest_2d(lat2d, lon2d, lat0, lon0):
    dis_x = (np.abs(lat2d - lat0))
    dis_y = (np.abs(lon2d - lon0))
    dis=dis_x+dis_y
    idx=dis.argmin()
    return(idx)

lonl= 113.8257
lonr=114.4837
latb= 22.1209
latt= 22.6227


all_grid_list=['rho', 'u', 'v', 'psi']
data_root='/home/metctm1/array/data/Calypso/'



hk_nc=xr.load_dataset(data_root+'hk_lsmask.nc')
src_mask=hk_nc['lsmask'].values
src_lat=hk_nc['lat'].values
src_lon=hk_nc['lon'].values

roms_nc=xr.load_dataset(data_root+'roms_d03.nc.bck')

for grid in all_grid_list:
    mask=roms_nc['mask_'+grid].values
    lat2d=roms_nc['lat_'+grid].values
    lon2d=roms_nc['lon_'+grid].values
    mask_shp=mask.shape
    print(mask_shp)
    for irow in range(0, mask_shp[0]):    
        for icol in range(0, mask_shp[1]):    
            lat0=lat2d[irow,icol]
            lon0=lon2d[irow,icol]
            ix=find_nearest_2d(src_lat, src_lon, lat0, lon0)
            mask[irow, icol]=src_mask[ix]
        print(irow/mask_shp[0])
    break
roms_nc.to_netcdf(data_root+'roms_d03.nc', mode='a')



