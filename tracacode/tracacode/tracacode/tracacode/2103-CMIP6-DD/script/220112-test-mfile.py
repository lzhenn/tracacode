from netCDF4 import Dataset
import numpy as np
import xarray as xr
import wrf, subprocess


SEN_DIR='/home/metctm1/cmip-wrfltm-arch/hist_2010s/2011/analysis/'
# Open the NetCDF file
fn_stream=subprocess.check_output(
        'ls '+SEN_DIR+'wrfout_d04_*-0[6-9]-*', shell=True).decode('utf-8')
fn_list=fn_stream.split()
print(len(fn_list))
files=xr.open_mfdataset(SEN_DIR+'wrfout_d04_*-0[6-9]-*')
#wrf_list=[Dataset(itm) for itm in fn_list]
#var_temp=wrf.getvar(wrf_list[0],'U')

