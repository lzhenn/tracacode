#!/usr/bin/python
# -*- coding: UTF-8 -*-
#
#
#       L_Zealot
#       May 1, 2017
#
#
import scipy.io as sio 
from netCDF4 import Dataset
import numpy as np
import json
import datetime

# Time settings
start_time='2015-01-01 00:00:00'
end_time='2015-01-27 00:00:00'

# Integration step in Hour
int_step=24

# Number of points
npoints=16720

# Operation
int_time_obj = datetime.datetime.strptime(start_time, '%Y-%m-%d %H:%M:%S')
end_time_obj = datetime.datetime.strptime(end_time, '%Y-%m-%d %H:%M:%S')
time_delta=datetime.timedelta(hours=int_step)

# parser path
inv_path='/home/yangsong3/data-model/L_Zealot/HKUST_yeq-2016/resident-time_output/data/hysplit/prd/population/01/'


def read_latlon(pfname):
    corfile= Dataset(pfname)
    lat=corfile.variables['LAT'][0,0,:,:]
    lon=corfile.variables['LON'][0,0,:,:]
    return lat, lon

# Get gridsystem
pfname='/home/yangsong3/L_Zealot/data-mirror/data-model/L_Zealot/HKUST_yeq-2016/gridsys/GRIDCRO2D_3km'
lat, lon = read_latlon(pfname)

# Get population
mat_contents=sio.loadmat('../data/obv/population_output_D3.mat')
pop=mat_contents['population_output'] #list
pop_array=np.array(pop)
pop_array=pop_array.transpose()
print(lat[10,130])
print(lon[10,130])
print(pop_array[10,90:130])



