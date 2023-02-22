#!/bin/env python3
import os
import cmaps
import cartopy.crs as ccrs
import cartopy.io.shapereader as shpreader
import matplotlib
import matplotlib.pyplot as plt
matplotlib.use('Agg')
import numpy as np 
import wrf
import subprocess
from netCDF4 import Dataset

cases= ['2018091200', '2017082100','2012072000']

sen_path='/home/lzhenn/array74/Njord_Calypso/case_study/aoe_projection/pgw/'
ctrl_path='/home/lzhenn/array74/Njord_Calypso/case_study/aoe_projection/present/'
var = 'wspd_wdir10'
dom_id='d02'


province_shp_file=os.getenv('SHP_LIB')+'/cnmap/cnhimap.dbf'
province_shp =shpreader.Reader(province_shp_file).geometries()

fn_stream=subprocess.check_output(
    'ls '+sen_path+'/'+cases[0]+'/wrfout_'+dom_id+'*', shell=True).decode('utf-8')
fn_list=fn_stream.split()
file_list=fn_list
wrf_list=[Dataset(itm) for itm in fn_list[-48:]]

       
var_sen_all=wrf.getvar(
    wrf_list,var,timeidx=wrf.ALL_TIMES, method='cat')
proj=wrf.get_cartopy(var_sen_all)
var_sen_max=var_sen_all.max(dim='Time')
lats, lons = wrf.latlon_coords(var_sen_all)

fn_stream=subprocess.check_output(
    'ls '+ctrl_path+'/'+cases[0]+'/wrfout_'+dom_id+'*', shell=True).decode('utf-8')
fn_list=fn_stream.split()
file_list=fn_list
wrf_list=[Dataset(itm) for itm in fn_list[-48:]]
       
var_ctrl_all=wrf.getvar(
    wrf_list,var,timeidx=wrf.ALL_TIMES, method='cat')
var_ctrl_max=var_ctrl_all.max(dim='Time')


cmap=cmaps.wind_17lev
levels=np.linspace(0,10,18)

fig = plt.figure(figsize=[10, 8],frameon=True)

# Set projection and plot the main figure
ax = fig.add_axes([0.08, 0.01, 0.8, 0.94], projection=proj)

# add gridlines
#gl = ax.gridlines(crs=ccrs.PlateCarree(), draw_labels=True,
#        color='grey', linestyle='--', linewidth=1)
#gl.top_labels = False
#gl.right_labels = False

ax.coastlines()

ax.add_geometries(
    province_shp, ccrs.PlateCarree(),facecolor='none', 
    edgecolor='black',linewidth=0.5, zorder = 2)

plt.contourf(
    wrf.to_np(lons), wrf.to_np(lats), 
    wrf.to_np(var_sen_max[0,:,:])-wrf.to_np(var_ctrl_max[0,:,:]),
    levels=levels, extend='both', 
    transform=ccrs.PlateCarree(), cmap=cmap)

plt.colorbar(ax=ax, shrink=0.7,extendfrac='auto')

plt.savefig(
        '../fig/230222-maxwind-plot.png', 
        dpi=120, bbox_inches='tight')
plt.close()
