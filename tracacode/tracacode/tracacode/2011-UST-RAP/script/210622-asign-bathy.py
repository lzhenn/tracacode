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

h_mat = data_root+'swan_d03_bathy/B.mat'
lat_mat = data_root+'swan_d03_bathy/Lat.mat'
lon_mat = data_root+'swan_d03_bathy/Long.mat'

rsp_n=10
h_src = sp.loadmat(h_mat)['B'][::rsp_n,::rsp_n]
lat_src = sp.loadmat(lat_mat)['Lat'][::rsp_n,::rsp_n]
lon_src = sp.loadmat(lon_mat)['Long'][::rsp_n,::rsp_n]

h_src_shp=h_src.shape

roms_nc=xr.load_dataset(data_root+'roms_d03.nc.first_assign')

h_tgt=roms_nc['h'].values
lat2d_tgt=roms_nc['lat_rho'].values
lon2d_tgt=roms_nc['lon_rho'].values
h_shp=h_tgt.shape

for irow in range(0, h_shp[0]):    
    for icol in range(0, h_shp[1]):    
        lat0=lat2d_tgt[irow,icol]
        lon0=lon2d_tgt[irow,icol]
        ix=find_nearest_2d(lat_src, lon_src, lat0, lon0)
        idx, idy = np.unravel_index(ix, h_src_shp)
        if h_src[idx,idy]>0: 
            h_tgt[irow, icol]=h_src[idx,idy]
    print(irow/h_shp[0])
    #if irow/h_shp[0]> 0.05:
    #    break
roms_nc.to_netcdf(data_root+'roms_d03.nc', mode='a')


