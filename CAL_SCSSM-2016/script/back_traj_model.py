#! /usr/bin/env python
#   Backward trajectory model
#               L_Zealot
#               Mar 6, 2017
#               Albany, CA
#
import math
#from numpy import *
from netCDF4 import Dataset
import numpy as np
import datetime

#-------------------------------------
# Function Definition Part
#-------------------------------------
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


def create_partical_array(lat_range, lon_range, latS, latN, lonW, lonE, g_step, n_timesteps, start_level):
    valid_lats=[lat0 for lat0 in lat_range if ((lat0>latS) and (lat0<latN))]
    valid_lons=[lon0 for lon0 in lon_range if (lon0>lonW) and (lon0<lonE)]

    n_points=len(valid_lats)*len(valid_lons)

    pt_array=np.zeros((n_points,n_timesteps+1,3))
    ii=0
    for lat0 in valid_lats:
        for lon0 in valid_lons:
            pt_array[ii,0,:]=[lat0, lon0, start_level]  #[dim0]--Points, [dim1]--timesteps, [dim2]--(lat/0, lon/1)
            ii+=1
    return pt_array

def find_nearest(latx,lonx,levx, lat_array,lon_array,lev_array):
    idx = (np.abs(lat_array-latx)).argmin()
    idy = (np.abs(lon_array-lonx)).argmin()
    idz = (np.abs(lev_array-levx)).argmin()
    return idx, idy, idz

def cal_field_next(var1f,var2f,var3f,var1b,var2b,var3b,wgt):
    var1_nx=var1b+wgt*(var1f-var1b)
    var2_nx=var2b+wgt*(var2f-var2b)
    var3_nx=var3b+wgt*(var3f-var3b)
    return var1_nx, var2_nx, var3_nx

def cal_next_lat(olat, vwnd,CONST,dt):
    dy=-vwnd*dt*3600
    dlat=dy*CONST['dis2lat']
    return olat+dlat

def cal_next_lon(olat,olon,uwnd,CONST,dt):
    dx=-uwnd*dt*3600
    dlon=dx*180/(CONST['a']*math.sin(math.pi/2-math.radians(olat))*math.pi)
    return olon+dlon

def cal_next_levp(oz,vv,dt):
    dz=-vv*dt*3600/100 # Pa/s-->hPa/s
    return oz+dz 

def cal_nextstep(pr_array_istep,lat_array,lon_array,lev_array,var1_nx,var2_nx,var3_nx, g_step,CONST,g_level):
    n_points=len(pr_array_istep[:,0])
    pt_next_array=np.zeros((n_points,3))

    for pt in range(n_points):
        idx, idy, idz=find_nearest(pr_array_istep[pt,0],pr_array_istep[pt,1],pr_array_istep[pt,2],lat_array,lon_array,lev_array)
        pt_next_array[pt,0]=cal_next_lat(pr_array_istep[pt,0],var2_nx[idz, idx, idy],CONST,g_step)        
        pt_next_array[pt,1]=cal_next_lon(pr_array_istep[pt,0],pr_array_istep[pt,1],var1_nx[idz,idx,idy],CONST,g_step)        
        pt_next_array[pt,2]=cal_next_levp(pr_array_istep[pt,2],var3_nx[idz,idx,idy],g_step)        
    
    return pt_next_array

def get_next_files(currtime):
    pfname = "/Users/zhenningli/data/obv/ERA-daily/uvw/ei.oper.an.pl.regn128uv.%04d%02d%02d%02d.nc" % (currtime.year, currtime.month, currtime.day, currtime.hour)
    pfname2 = "/Users/zhenningli/data/obv/ERA-daily/uvw/ei.oper.an.pl.regn128sc.%04d%02d%02d%02d.nc" % (currtime.year, currtime.month, currtime.day, currtime.hour)
    var1b = read_era_field(pfname, "U_GDS4_ISBL")
    var2b = read_era_field(pfname, "V_GDS4_ISBL")
    var3b = read_era_field(pfname2, "W_GDS4_ISBL")
    return var1b, var2b, var3b
#----------------------------------------------------
# User Defined Part
#----------------------------------------------------

# Output Dir
out_dir='/Users/zhenningli/data/CAL_SCSSM-2016/back_traj/'

# File timestep
g_fstep=6

# Integration timestep
g_step=1

# Level
g_start_level=925

# Points bound
g_latS=9
g_latN=15
g_lonW=87.5
g_lonE=100

# Integration timebound
fr = open('CONTROL', 'r')
lines=fr.readlines()
fr.close()
g_init_time=str(lines[0])
g_back_time=str(lines[1])
g_init_time=g_init_time.strip('\n')
g_back_time=g_back_time.strip('\n')

# CONSTANT
R_EARTH=6371000
DIS2LAT=180/(math.pi*R_EARTH)        #Distance to Latitude
CONST={'a':R_EARTH,'dis2lat':DIS2LAT}

#--------------------------
# Model body
#--------------------------

# Preparation
int_time_obj = datetime.datetime.strptime(g_init_time, '%Y-%m-%d %H:%M:%S')
end_time_obj = datetime.datetime.strptime(g_back_time, '%Y-%m-%d %H:%M:%S')
file_time_delta=datetime.timedelta(hours=-g_fstep)
curr_filetime=int_time_obj

print curr_filetime.strftime("Initializing %Y%m%d%HZ...") 

totol_period=int_time_obj-end_time_obj
nsteps=totol_period.total_seconds()/(g_step*3600)

pfname = "/Users/zhenningli/data/obv/ERA-daily/uvw/ei.oper.an.pl.regn128uv.%04d%02d%02d%02d.nc" % (curr_filetime.year, curr_filetime.month, curr_filetime.day, curr_filetime.hour)
pfname2 = "/Users/zhenningli/data/obv/ERA-daily/uvw/ei.oper.an.pl.regn128sc.%04d%02d%02d%02d.nc" % (curr_filetime.year, curr_filetime.month, curr_filetime.day, curr_filetime.hour)

# Initialization
lat_array, lon_array, lev_array, var1f = read_era_all(pfname, "U_GDS4_ISBL")
var2f = read_era_field(pfname, "V_GDS4_ISBL")
var3f = read_era_field(pfname2, "W_GDS4_ISBL")
pr_array=create_partical_array(lat_array, lon_array, g_latS, g_latN, g_lonW, g_lonE, g_step, nsteps, g_start_level)

curr_filetime+=file_time_delta
var1b,var2b,var3b=get_next_files(curr_filetime)

# Main Loop: Integration
print curr_filetime.strftime("Calculating %Y%m%d%HZ...") 
for istep in range(int(nsteps)):
    step_class=((istep+1)*g_step)%g_fstep
    fwgt_ratio=1-step_class/float(g_fstep)

    var1_nx, var2_nx, var3_nx=cal_field_next(var1f,var2f,var3f,var1b,var2b,var3b,fwgt_ratio)
    pr_array[:,istep+1,:]=cal_nextstep(pr_array[:,istep,:],lat_array,lon_array,lev_array,var1_nx,var2_nx,var3_nx,g_step,CONST,g_start_level)
   
    if step_class ==0 and istep != int(nsteps)-1:
        var1f=var1b
        var2f=var2b
        var3f=var3b
        curr_filetime+=file_time_delta
        var1b,var2b,var3b=get_next_files(curr_filetime)

        print curr_filetime.strftime("Calculating %Y%m%d%HZ...") 

# Output
print curr_filetime.strftime("Output...") 

fr2=open(out_dir+int_time_obj.strftime('%Y%m%d%H')+'-'+int_time_obj.strftime('%Y%m%d%H')+'_'+str(g_start_level)+'hPa.txt','w')
for ii in range(int(nsteps)+1):
    for pt in range(len(pr_array[:,0,0])):
        lat=pr_array[pt,ii,0]
        lon=pr_array[pt,ii,1]
        lev=pr_array[pt,ii,2]
        fr2.write('%4d %8.3f %8.3f %8.3f %8.3f\n' % (pt, ii*g_step, lat, lon, lev))
fr2.close()

