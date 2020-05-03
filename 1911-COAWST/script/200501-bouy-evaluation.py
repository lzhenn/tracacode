import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import xarray as xr
import datetime

def get_closest_data(var, lat2d, lon2d, lat0, lon0):
    dis_lat2d=lat2d-lat0
    dis_lon2d=lon2d-lon0
    dis=abs(dis_lat2d)+abs(dis_lon2d)
    var=var.where(dis==dis.min(),drop=True).squeeze()
    return var

def windspeed(var1,var2):
    return np.sqrt(var1*var1+var2*var2)

#open dataset
ds = xr.open_dataset('/disk/v092.yhuangci/lzhenn/1911-COAWST/ERA5_C2008/wrfout_d02')

wrf_time=ds['XTIME']
dateparse = lambda x: pd.datetime.strptime(x, '%Y-%m-%d %H:%M:%S')
obv_path='/disk/v092.yhuangci/lzhenn/1911-COAWST/obv/bouy/QF303.csv'
df_obv=pd.read_csv(obv_path,parse_dates=True,index_col='采集时间', header=1, date_parser=dateparse)
df_obv_period=df_obv[((df_obv.index>=wrf_time.values[0])&(df_obv.index<=wrf_time.values[-1]))]
print(df_obv_period['有效波高/m'])
exit()


uwind = ds['U'][:,0,:,:]
vwind = ds['V'][:,0,:,:]
lat2d_u, lon2d_u=ds['XLAT_U'][0,:,:],ds['XLONG_U'][0,:,:]
lat2d_v, lon2d_v=ds['XLAT_V'][0,:,:],ds['XLONG_V'][0,:,:]

uwind_sta=get_closest_data(uwind, lat2d_u,lon2d_u,21.11600, 112.6330)
vwind_sta=get_closest_data(vwind, lat2d_v,lon2d_v,21.11600, 112.6330)
ws_sta=windspeed(uwind_sta, vwind_sta)
print(ws_sta)
exit()
# Turn on chunking to activate dask and parallelize read/write.
ds = ds.chunk({'ocean_time': 1})

# Pick out some of the variables that will be included as coordinates
ds = ds.set_coords(['Cs_r', 'Cs_w', 'hc', 'h', 'Vtransform'])

# Select a a subset of variables. Salt will be visualized, zeta is used to
# calculate the vertical coordinate
variables = ['Uwind', 'Vwind']
ds[variables].isel(ocean_time=slice(47, None, 7*24),
                   xi_rho=slice(300, None)).to_netcdf('ROMS_example.nc', mode='w')

