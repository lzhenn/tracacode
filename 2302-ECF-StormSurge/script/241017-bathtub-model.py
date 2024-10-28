import xarray as xr
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
def find_nearest(lat2d, lon2d, lat0, lon0):
    # Calculate the squared distance for efficiency
    distance_squared = (lat2d - lat0)**2 + (lon2d - lon0)**2
    # Find the index of the minimum distance
    index = np.unravel_index(np.argmin(distance_squared.values), lat2d.shape)
    return index

# Tolo Harbour
#latS, latN, lonW, lonE = 22.37, 22.4964, 114.15, 114.2671
# Victoria Harbour
#latS, latN, lonW, lonE = 22.2577, 22.3633, 114.1111, 114.2806
# all
latS, latN, lonW, lonE = 22.1165, 22.6227, 113.8239, 114.4804
# deviation
tide_dev=2.3
slr_dev=0.3
hwave='/home/lzhenn/poseidon/2018091200_noluzon_warm/roms_max_Hwave_d03.nc'
zeta='/home/lzhenn/poseidon/2018091200_noluzon_warm/roms_max_zeta_d03.nc'
#hwave='/home/lzhenn/poseidon/2018091200/roms_max_Hwave_d03.nc'
#zeta='/home/lzhenn/poseidon/2018091200/roms_max_zeta_d03.nc'
lu5m='/home/lzhenn/array74/data/hk_landuse/LUM_end2022_5m.nc'
dtm5m='/home/lzhenn/array74/data/hk_dtm/HK_DTM_5m_rectified.nc'

# load maximum zeta
print('process zeta and hwave...')
ds_zeta = xr.open_dataset(zeta)
ds_wave = xr.open_dataset(hwave)
lat2d,lon2d=ds_zeta['lat_rho'],ds_zeta['lon_rho']
zeta=ds_zeta['zeta']

#----------bias correction
zeta.values=np.where(lon2d.values<lonW+0.18,zeta.values-1.0,zeta.values)
#----------bias correction

idx0,idy0=find_nearest(lat2d,lon2d,latS,lonW)
idx1,idy1=find_nearest(lat2d,lon2d,latN,lonE)

total=zeta+ds_wave['Hwave']*0.3+tide_dev+slr_dev
total_sub=total.sel(eta_rho=slice(idx0, idx1), xi_rho=slice(idy0, idy1))

lat_1d = total_sub.lat_rho.mean(dim='xi_rho')
lon_1d = total_sub.lon_rho.mean(dim='eta_rho')
total_sub.coords['lat'] = lat_1d
total_sub.coords['lon'] = lon_1d
# Remove the old 2D coordinates
total_sub = total_sub.drop_vars(['lat_rho', 'lon_rho'])
# Rename dimensions
total_sub = total_sub.swap_dims({'eta_rho': 'lat', 'xi_rho': 'lon'})

print('process LU...')
ds_lu=xr.open_dataset(lu5m)
ds_lu = ds_lu.sel(lat=slice(None, None, -1))
ds_lu_sub=ds_lu.sel(lat=slice(latS, latN), lon=slice(lonW, lonE))
lu_sub=ds_lu_sub['lu']

# Load terrain datasets
print('process dtm...')
ds_dtm=xr.open_dataset(dtm5m)
# Reverse the latitude dimension
ds_dtm = ds_dtm.sel(lat=slice(None, None, -1))
ds_dtm_sub=ds_dtm.sel(lat=slice(latS, latN), lon=slice(lonW, lonE))
dtm_sub=ds_dtm_sub['dtm']
lat_sub,lon_sub=ds_dtm_sub['lat'],ds_dtm_sub['lon']

print('calculate inun...')

total_sub=total_sub.interpolate_na(
    dim='lat', method='nearest')
total_sub=total_sub.interpolate_na(
    dim='lon', method='nearest')
total_sub=total_sub.ffill(dim='lon')
total_sub=total_sub.bfill(dim='lon')


total_sub=total_sub.ffill(dim='lat')
total_sub=total_sub.bfill(dim='lat')
# Reindex the total_sub data to the DTM grid
total_sub = total_sub.interp(
    lat=ds_dtm_sub['lat'], lon=ds_dtm_sub['lon'], method='nearest')




inun=total_sub
inun=inun.values[0,:,:]-dtm_sub


print('deal with land use...')
inun=inun.where(inun>0.0,np.nan)
# 0 -- ocean, 91 -- reservoir, 92 -- river
inun=xr.where(lu_sub==0,np.nan,inun)
inun=xr.where(lu_sub==91,np.nan,inun)
inun=xr.where(lu_sub==92,np.nan,inun)


print('plot inun...')


# Create a figure and axis
fig, ax = plt.subplots(figsize=(10, 6.5))
# ocean 
lu_sub.values=np.where(lu_sub==0,99,lu_sub)
# artificial
lu_sub.values=np.where(lu_sub<=62,1,lu_sub)
# natural
lu_sub.values=np.where((lu_sub<91) & (lu_sub>62),50,lu_sub)
colors = {
    0: 'gray',  # All human 
    1: 'white', # natural 
    2: 'dodgerblue', # river and reservoir, ocean
}

# Create a color map
cmap = ListedColormap([colors[0], colors[1], colors[2]])
c=ax.pcolormesh(lon_sub,lat_sub, inun, vmax=4,vmin=0.0, cmap='turbo')
fig.colorbar(c, ax=ax, label='Water Depth (m)')
plt.xlabel('Longitude')
plt.ylabel('Latitude')

ax.pcolormesh(lon_sub,lat_sub, lu_sub, cmap=cmap, alpha=0.3)

plt.savefig('../fig/hk_inun_noluzon_warm.png', dpi=200, bbox_inches='tight')


