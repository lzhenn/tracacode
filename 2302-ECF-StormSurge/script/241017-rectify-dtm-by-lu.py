import xarray as xr
# Load the datasets
lu_data = xr.open_dataset('/home/lzhenn/array74/data/hk_landuse/LUM_end2022_5m.nc')
dtm_data = xr.open_dataset('/home/lzhenn/array74/data/hk_dtm/Whole_HK_DTM_5m.nc')

dtm=dtm_data['dtm']
lu=lu_data['lu']

#airport
dtm=xr.where(
    (lu==43) & (dtm<7),7,dtm)
dtm=xr.where(
    (lu==53) & (dtm<7),7,dtm)
dtm=xr.where(
    (lu==31) & (dtm<7),7,dtm)


# others
dtm=xr.where(
    (lu>0) & (lu<54) & (dtm<4),4,dtm)

result = xr.Dataset({'dtm': dtm})
# Optionally, save the result to a new NetCDF file
result.to_netcdf('/home/lzhenn/array74/data/hk_dtm/HK_DTM_5m_rectified.nc')
