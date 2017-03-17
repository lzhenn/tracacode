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
def read_era_all(pfname, varname, cornames):
    era = Dataset(pfname)
    lat =era.variables[cornames[2]][:]
    lon =era.variables[cornames[3]][:]
    lev =era.variables[cornames[1]][:]
    ftstep =era.variables[cornames[0]][:]
    var  = era.variables[varname][:,:,:,:]
    return ftstep, lat, lon, lev, var

def read_era_field(pfname, varname):
    era = Dataset(pfname)
    var  = era.variables[varname][:,:,:,:]
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

#----------------------------------------------------
# User Defined Part
#----------------------------------------------------

# Process cases
casename='clim'

# Output Dir
out_dir='/Users/zhenningli/data/CAL_SCSSM-2016/back_traj/'+casename+'/'


# Integration timestep (hr)
g_step=1

# Initial interval. Default 24 (hr)
g_itvl=24

# Individual integration period (hr)
g_int=96

#g_lvls=[1000,925,850,700,600,500,200
g_lvls=[600]
# Points bound
g_latS=9
g_latN=15
g_lonW=87.5
g_lonE=100

# Var names
varnames=['uwnd','vwnd','vv']
cornames=['time','lev','lat','lon']

# CONSTANT
R_EARTH=6371000
DIS2LAT=180/(math.pi*R_EARTH)        #Distance to Latitude
CONST={'a':R_EARTH,'dis2lat':DIS2LAT}

#--------------------------
# Model body
#--------------------------

# Preparation

print ('Initializing...') 

pfname = '/Users/zhenningli/data/CAL_SCSSM-2016/onset_comp_uvw/'+casename+'/cmp_uvw.nc'
# Initialization
fsteps, lat_array, lon_array, lev_array, var1 = read_era_all(pfname, varnames[0], cornames)
g_fstep=fsteps[1]-fsteps[0]         # Timestep between input field 
insteps=g_int/g_step         # Individual integration timesteps
n_initials=(fsteps[-1]-g_int)/g_itvl-1  # Total initial times


var2 = read_era_field(pfname, varnames[1])
var3 = read_era_field(pfname, varnames[2])



# Main Loop: Integration
for g_start_level in g_lvls:
    pr_array=create_partical_array(lat_array, lon_array, g_latS, g_latN, g_lonW, g_lonE, g_step, insteps, g_start_level)
    for idx_ini in range(n_initials):
        ini_day=idx_ini*g_itvl/24.0+1
        stop_day=ini_day+g_int/24.0
        print 'Integrate Day%5.1f <-- Day%5.1f, %4dhPa' % (ini_day, stop_day, g_start_level) 

        fpos=((idx_ini*g_itvl)+g_int)/g_fstep     # Reset pointer to the initial point in the file stream
        for istep in range(int(insteps)):
            step_class=((istep+1)*g_step)%g_fstep   # for weighting the velocity
            fwgt_ratio=1-step_class/float(g_fstep)  # istep

            
            var1_nx, var2_nx, var3_nx=cal_field_next(var1[fpos,:,:,:],var2[fpos,:,:,:],var3[fpos,:,:,:],var1[fpos-1,:,:,:],var2[fpos-1,:,:,:],var3[fpos-1,:,:,:],fwgt_ratio)
            pr_array[:,istep+1,:]=cal_nextstep(pr_array[:,istep,:],lat_array,lon_array,lev_array,var1_nx,var2_nx,var3_nx,g_step,CONST,g_start_level)
           
            if step_class ==0 and istep != int(insteps)-1:
                fpos=fpos-1
        # Output
        print('Output...')
        out_fn=out_dir+'Day'+str(ini_day)+'_'+str(g_int)+'hr_'+str(g_start_level)+'hPa.txt'
        fr2=open(out_fn,'w')
        for ii in range(int(insteps)+1):
            for pt in range(len(pr_array[:,0,0])):
                lat=pr_array[pt,ii,0]
                lon=pr_array[pt,ii,1]
                lev=pr_array[pt,ii,2]
                fr2.write('%4d %8.3f %8.3f %8.3f %8.3f\n' % (pt, ii*g_step, lat, lon, lev))
        fr2.close()
