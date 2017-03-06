import math
from numpy import *
from netCDF4 import Dataset
import numpy as np
import datetime




def read_era_all(pfname, varname):
    era = Dataset(pfname)
    lat =era.variables["g4_lat_1"][:]
    lon =era.variables["g4_lon_2"][:]
    lev =era.variables["lv_ISBL0"][:]
    var  = era.variables[varname][:,:,:]
    return lat, lon, lev, var

def read_era_field(pfname, varname):
    era = Dataset(pfname)
    var  = era.variables[varname][:,:,:]
    return var


def create_partical_array(lat_range, lon_range, latS, latN, lonW, lonE, g_astep, g_int_hr):
    valid_lats=[lat0 for lat0 in lat_range if ((lat0>latS) and (lat0<latN))]
    valid_lons=[lon0 for lon0 in lon_range if (lon0>lonW) and (lon0<lonE)]

    n_points=len(valid_lats)*len(valid_lons)
    n_timesteps=g_int_hr/g_step

    pt_array=np.zeros((n_points,n_timesteps,2))
    ii=0
    for lat0 in valid_lats:
        for lon0 in valid_lons:
            pt_array[ii,0,:]=[lat0, lon0]  #[dim0]--Points, [dim1]--timesteps, [dim2]--(lat/0, lon/1)
            ii+=1
    return pt_array

def find_nearest(latx,lonx,lat_array,lon_array):
    idx = (np.abs(lat_array-latx)).argmin()
    idy = (np.abs(lon_array-lonx)).argmin()
    return idx, idy, lat_array[idx], lon_array[idy]

def cal_field_next(var1f,var2f,var1b,var2b,wgt):
    var1_nx=var1b+wgt*(var1f-var1b)
    var2_nx=var2b+wgt*(var2f-var2b)
    return var1_nx, var2_nx

def cal_nextstep(pr_array_istep,lat_array,lon_array,var1_nx,var2_nx,g_step,CONST):
    n_points=len(pr_array_istep[:,0])
    pt_next_array=np.zeros((n_points,2))
    for pt in range(n_points):
        idx, idy, lat0, lon0=find_nearest(pr_array_istep[pt,0],pr_array_istep[pt,1],lat_array,lon_array)
        pt_next_array[pt,0]=cal_next_lat(var2_nx(idx),CONST,g_step)        



#----------------------------------------------------
# User Defined Part
#----------------------------------------------------

# Integration timebound
g_init_time='1979-04-28 00:00:00'
g_back_time='1979-04-25 00:00:00'

# File timestep
g_fstep=6

# Integration timestep
g_step=1

# Level
g_level=700

# Points bound
g_latS=9
g_latN=15
g_lonW=87.5
g_lonE=100


# CONSTANT
PI=3.14159
R_EARTH=6371000
DIS2DGR=180/(PI*R_EARTH)        #Distance to Latitude
CONST={'pi':PI,'a':r_earth,'dis2dgr':DIS2DGR}

#--------------------------
# Model body
#--------------------------

# Prepare 
int_time_obj = datetime.datetime.strptime(g_init_time, '%Y-%m-%d %H:%M:%S')
end_time_obj = datetime.datetime.strptime(g_back_time, '%Y-%m-%d %H:%M:%S')
file_time_delta=datetime.timedelta(hours=-g_fstep)
curr_filetime=int_time_obj

totol_period=int_time_obj-end_time_obj
nsteps=totol_period.total_seconds()/(g_step*3600)

pfname = "/Users/zhenningli/data/obv/ERA-daily/uvw/ei.oper.an.pl.regn128uv.%04d%02d%02d%02d.nc" % (curr_filetime.year, curr_filetime.month, curr_filetime.day, curr_filetime.hour)

# Initialization
lat_array, lon_array, lev_array, var1f = read_era_profile(pfname, "U_GDS4_ISBL")
var2f = read_era_field(pfname, "V_GDS4_ISBL")
pr_array=create_partical_array(lat_array, lon_array, g_latS, g_latN, g_lonW, g_lonE, g_astep, g_int_hr)

curr_filetime+=file_time_delta
pfname = "/Users/zhenningli/data/obv/ERA-daily/uvw/ei.oper.an.pl.regn128uv.%04d%02d%02d%02d.nc" % (curr_filetime.year, curr_filetime.month, curr_filetime.day, curr_filetime.hour)
var1b = read_era_field(pfname, "U_GDS4_ISBL")
var2b = read_era_field(pfname, "V_GDS4_ISBL")

# Integration
for istep in range(int(nsteps)):
    
    step_class=(istep+1)%g_fstep
    fwgt_ratio=1-step_class/float(g_fstep)

    var1_nx, var2_nx=cal_field_next(var1f,var2f,var1b,var2b,fwgt_ratio)
    pr_array[:,istep+1,:]=cal_nextstep(pr_array[:,istep,:],lat_array,lon_array,var1_nx,var2_nx,g_step,CONST)
   
    if step_class ==0:
        var1f=var1b
        var2f=var2b
        curr_filetime+=file_time_delta
        pfname = "/Users/zhenningli/data/obv/ERA-daily/uvw/ei.oper.an.pl.regn128uv.%04d%02d%02d%02d.nc" % (curr_filetime.year, curr_filetime.month, curr_filetime.day, curr_filetime.hour)
        var1b = read_era_field(pfname, "U_GDS4_ISBL")
        var2b = read_era_field(pfname, "V_GDS4_ISBL")
     
   
    break

print pr_array[:,0,:]

