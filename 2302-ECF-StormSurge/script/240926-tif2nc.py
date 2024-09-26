import rasterio
import xarray as xr

# Specify your input GeoTIFF file and output NetCDF file
input_geotiff = 'input_file.tif'
output_netcdf = 'output_file.nc'

# Open the GeoTIFF file
with rasterio.open(input_geotiff) as src:
    # Read the data and metadata
    data = src.read(1)  # Read the first band
    transform = src.transform
    crs = src.crs
    height, width = data.shape

    # Create coordinates based on the raster's transform
    x_coords = transform * (np.arange(width), np.zeros(width))
    y_coords = transform * (np.zeros(height), np.arange(height))

# Create a DataArray using xarray
data_array = xr.DataArray(
    data,
    coords={
        'y': ('y', y_coords[1]),
        'x': ('x', x_coords[0]),
    },
    dims=('y', 'x'),
)

# Create a Dataset and assign attributes
dataset = xr.Dataset({'variable_name': data_array})
dataset.attrs['crs'] = str(crs)

# Save to NetCDF
dataset.to_netcdf(output_netcdf)

print(f"Converted {input_geotiff} to {output_netcdf}")