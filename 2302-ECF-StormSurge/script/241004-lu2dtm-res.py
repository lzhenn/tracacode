import xarray as xr

# Load the datasets
lu_data = xr.open_dataset('/home/lzhenn/array74/data/hk_landuse/LUM_end2022_latlon.nc')
dtm_data = xr.open_dataset('/home/lzhenn/array74/data/hk_dtm/Whole_HK_DTM_5m.nc')

# Check the variable names in the datasets
print(lu_data)
print(dtm_data)

# Interpolate the land use data to the DTM grid
# Assuming 'LU' is the variable name for land use in the land use dataset
# and the DTM dataset has coordinates 'lat' and 'lon'.

# Reindex the LU data to the DTM grid
lu_interpolated = lu_data['lu'].interp(y=dtm_data['lat'], x=dtm_data['lon'], method='linear')

# Create a new dataset with the interpolated land use data
result = xr.Dataset({'lu': lu_interpolated})

# Optionally, save the result to a new NetCDF file
result.to_netcdf('/home/lzhenn/array74/data/hk_landuse/LUM_end2022_5m.nc')

print("Interpolation completed and saved to 'LU_interpolated_to_DTM.nc'.")