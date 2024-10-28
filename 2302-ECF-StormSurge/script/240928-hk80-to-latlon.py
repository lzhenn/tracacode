# Specify your input GeoTIFF file and output NetCDF file
import xarray as xr
import numpy as np
from hk80 import HK80 

# Load your original nc file
input_file_path = '/home/lzhenn/array74/data/hk_landuse/LUM_end2022.nc'  # Replace with your input file path
ds = xr.open_dataset(input_file_path)

# Assuming you have x and y coordinates in the dataset
x_coords = ds['x'].values  # Replace 'x' with the actual variable name
y_coords = ds['y'].values  # Replace 'y' with the actual variable name
# Get the variable 'lu' from the dataset
lu = ds['variable_name'].values  # Replace 'lu' with the actual variable name

lon=np.zeros(len(x_coords))
lat=np.zeros(len(y_coords))
for nx in range(0,len(x_coords)):
    if nx % 500 == 0:
        print('nx=',nx,'/',len(x_coords))
    p= HK80(northing=y_coords[0], easting=x_coords[nx]).to_wgs84()
    lon[nx] = p.longitude
for ny in range(0,len(y_coords)):
    if ny % 500 == 0:
        print('ny=',ny,'/',len(y_coords))
    p= HK80(northing=y_coords[ny], easting=x_coords[0]).to_wgs84()
    lat[ny] = p.latitude

# Create a new xarray Dataset
new_ds = xr.Dataset(
    {
        'lon': (('x',), lon),  # 1D array for longitude
        'lat': (('y',), lat),  # 1D array for latitude
        'lu': (('y', 'x'), lu),  # 2D array for lu
    },
    coords={
        'x': ('x',lon),  # Coordinate for x
        'y': ('y',lat),  # Coordinate for y
    }
)

# Add attributes (optional)
new_ds['lon'].attrs['units'] = 'degrees_east'
new_ds['lat'].attrs['units'] = 'degrees_north'
new_ds['lu'].attrs['units'] = 'code'  # Replace with actual units for 'lu'

# Save to a new NetCDF file
output_file_path = '/home/lzhenn/array74/data/hk_landuse/LUM_end2022_latlon.nc'  # Replace with your desired output file path
new_ds.to_netcdf(output_file_path)

print(f"New NetCDF file created: {output_file_path}")