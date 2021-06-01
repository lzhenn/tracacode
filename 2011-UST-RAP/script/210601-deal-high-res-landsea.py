
import scipy.io as sp 
ls_mat = '/home/metctm1/array/data/Calypso/land.mat'
lslat_mat = '/home/metctm1/array/data/Calypso/lat.mat'
lslon_mat = '/home/metctm1/array/data/Calypso/lon.mat'
lsmask = sp.loadmat(ls_mat)['land']
lat2d = sp.loadmat(lslat_mat)['lat']
lon2d = sp.loadmat(lslon_mat)['lon']
print(lat2d)
