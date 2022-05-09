import numpy as np
import xarray as xr
import scipy.io as sp 

def find_nearest_idxy(array, value):
    idx = (np.abs(array - value)).argmin()
    return(idx)

lonl= 113.8257
lonr=114.4837
latb= 22.1209
latt= 22.6227


data_root='/home/metctm1/array/data/Calypso/'
all_grid_list=['rho', 'u', 'v', 'psi']

ls_mat = data_root+'land.mat'
lslat_mat = data_root+'lat.mat'
lslon_mat = data_root+'lon.mat'

lsmask = sp.loadmat(ls_mat)['land']
lat2d = sp.loadmat(lslat_mat)['lat']
lon2d = sp.loadmat(lslon_mat)['lon']

lsmask=np.where((lat2d>latb)&(lat2d<latt)&(lon2d>lonl)&(lon2d<lonr), lsmask, np.nan)
lsmask=lsmask[~np.isnan(lsmask)]

lat2d_sub=np.where((lat2d>latb)&(lat2d<latt)&(lon2d>lonl)&(lon2d<lonr), lat2d, np.nan)
lat2d_sub=lat2d_sub[~np.isnan(lat2d_sub)]

lon2d_sub=np.where((lat2d>latb)&(lat2d<latt)&(lon2d>lonl)&(lon2d<lonr), lon2d, np.nan)
lon2d_sub=lon2d_sub[~np.isnan(lon2d_sub)]


print(lsmask.shape)
print(lat2d_sub.shape)
print(lon2d_sub.shape)

ds_out= xr.Dataset(
    data_vars={   
        'lsmask':(['ngrid'], lsmask),
        'lat':(['ngrid'], lat2d_sub),
        'lon':(['ngrid'], lon2d_sub),
    },  
    coords={
        },
    attrs={
        }
)  

ds_out.to_netcdf(data_root+'hk_lsmask.nc')
