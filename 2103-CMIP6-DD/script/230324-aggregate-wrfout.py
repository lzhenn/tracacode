import os
import glob
import numpy as np
import netCDF4 as nc
import xarray as xr
from wrf import getvar, ALL_TIMES

# Define the path to the directory containing the wrfout files
input_dir = "/home/lzhenn/cmip6-wrf-arch/ssp585_2090s_wholeyear/2100/analysis/"
# Define the output filename and path
output_file = "/home/lzhenn/array74/data/temp/agg_file.nc"


# Find all wrfout files in the input directory
wrfout_files = sorted(glob.glob(os.path.join(input_dir, "wrfout_d02*")))

vars=['T2','uvmet10','slp','rh2']

# Load the first file to get the grid and dimensions
ds = nc.Dataset(wrfout_files[0])
lat, lon = getvar(ds, "XLAT"), getvar(ds, "XLONG")
time_dim = len(ds.dimensions["Time"])
var_all=[]
for var in vars:
    tempvar=getvar(ds, var, timeidx=ALL_TIMES)
    tempvar.attrs['projection'] = 'lambert_conformal' 
    var_all.append(tempvar)
ds.close()

# Loop over the wrfout files and aggregate the data
for wrfout_file in wrfout_files[1:]:
    print(f"Processing {wrfout_file}")
    with nc.Dataset(wrfout_file) as ds:
        for i,var in enumerate(vars):
            var_all[i] = xr.concat(
                [var_all[i],getvar(ds, var, timeidx=ALL_TIMES)],'time') 
    var_all[i].attrs['projection'] = 'lambert_conformal'

# Create a new Dataset and copy the grid and dimensions
ds_out = xr.Dataset()
for i, var in enumerate(vars):
    ds_out[var] = var_all[i]


# Write the aggregated data to a netCDF file
print(ds_out['T2'])
ds_out.to_netcdf(output_file, mode="w")

