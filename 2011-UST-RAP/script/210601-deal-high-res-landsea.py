import numpy as np
import xarray as xr
import scipy.io as sp 

def find_nearest_idxy(array, value):
    idx = (np.abs(array - value)).argmin()
    return(idx)


all_grid_list=['rho', 'u', 'v', 'psi']

roms_domain_in = '/home/metctm1/array/app/WRF412/WPS-4.1/roms_d03.nc.bck'
ls_mat = '/home/metctm1/array/data/Calypso/land.mat'
lslat_mat = '/home/metctm1/array/data/Calypso/lat.mat'
lslon_mat = '/home/metctm1/array/data/Calypso/lon.mat'

lsmask = sp.loadmat(ls_mat)['land']
lat2d = sp.loadmat(lslat_mat)['lat']
lon2d = sp.loadmat(lslon_mat)['lon']

lsmask=lsmask.where(lat2d>)
print(lat2d)
