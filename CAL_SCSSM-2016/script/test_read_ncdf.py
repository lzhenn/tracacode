import math
from numpy import *
from netCDF4 import Dataset
import numpy as np





def read_era_profile(pfname):
    era = Dataset(pfname)
    #merra2 = Dataset("./MERRA2_400.instM_3d_ana_Np.201201.nc4")
    lat =era.variables["g4_lat_1"][:]
    lon =era.variables["g4_lon_2"][:]
    lev =era.variables["lv_ISBL0"][:]
    var  = era.variables["W_GDS4_ISBL"][:,:,:]
    return lat, lon, lev, var

# Backward integration period (hr)
g_int_hr=72

# File timestep
g_fstep=6

# Integration timestep
g_step=6

# 

pfname = "/Users/zhenningli/data/obv/ERA-daily/uvw/ei.oper.an.pl.regn128sc.1979050100.nc"
lat, lon, lev, var = read_era_profile(pfname)
print lat

