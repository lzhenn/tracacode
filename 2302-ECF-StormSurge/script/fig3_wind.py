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
import pandas as pd
from cartopy.mpl.ticker import LongitudeFormatter, LatitudeFormatter

cases= ['2018091200', '2017082100','2012072000']

sen_path='/home/lzhenn/array74/Njord_Calypso/case_study/aoe_projection/pgw/'
ctrl_path='/home/lzhenn/array74/Njord_Calypso/case_study/aoe_projection/present/'
var = 'wspd_wdir10'
dom_id='d02'

'''

path_cma1 = "/home/lzhenn/array74/coop_fenying/1_TC_tracks/CH2018BST_Mangkhut.txt"
df_cma1 =pd.read_csv(path_cma1, sep='\s+', header=None, names=["date","Intensity","lat","lon","pres","wnd"])

## 两个模拟路径 ##
path_ctrl1 = "/home/lzhenn/array74/coop_fenying/1_TC_tracks/Mangkhut_ctrl.txt"
df_ctrl1 =pd.read_csv(path_ctrl1, sep='\s+', header=None, names=["lat","lon","slp","wnd"])
# print(df_ctrl1)

path_pgw1 = "/home/lzhenn/array74/coop_fenying/1_TC_tracks/Mangkhut_pgw.txt"
df_pgw1 =pd.read_csv(path_pgw1, sep='\s+', header=None, names=["lat","lon","slp","wnd"])


##--##--##   Hato (2017)   ##--##--##
path_cma1 = "/home/lzhenn/array74/coop_fenying/1_TC_tracks/CH2017BST_Hato.txt"
df_cma1 =pd.read_csv(path_cma1, sep='\s+', header=None, names=["date","Intensity","lat","lon","pres","wnd"])

path_ctrl1 = "/home/lzhenn/array74/coop_fenying/1_TC_tracks/Hato_ctrl.txt"
df_ctrl1 =pd.read_csv(path_ctrl1, sep='\s+', header=None, names=["lat","lon","slp","wnd"])

path_pgw1 = "/home/lzhenn/array74/coop_fenying/1_TC_tracks/Hato_pgw.txt"
df_pgw1 =pd.read_csv(path_pgw1, sep='\s+', header=None, names=["lat","lon","slp","wnd"])


'''
##--##--##   Vicente (2012)   ##--##--##
path_cma1 = "/home/lzhenn/array74/coop_fenying/1_TC_tracks/CH2012BST_Vicente.txt"
df_cma1 =pd.read_csv(path_cma1, sep='\s+', header=None, names=["date","Intensity","lat","lon","pres","wnd"])

path_ctrl1 = "/home/lzhenn/array74/coop_fenying/1_TC_tracks/Vicente_ctrl.txt"
df_ctrl1 =pd.read_csv(path_ctrl1, sep='\s+', header=None, names=["lat","lon","slp","wnd"])

path_pgw1 = "/home/lzhenn/array74/coop_fenying/1_TC_tracks/Vicente_pgw.txt"
df_pgw1 =pd.read_csv(path_pgw1, sep='\s+', header=None, names=["lat","lon","slp","wnd"])


province_shp_file=os.getenv('SHP_LIB')+'/cnmap/cnhimap.dbf'
province_shp =shpreader.Reader(province_shp_file).geometries()

fn_stream=subprocess.check_output(
    'ls '+sen_path+'/'+cases[2]+'/wrfout_'+dom_id+'*', shell=True).decode('utf-8')
fn_list=fn_stream.split()
file_list=fn_list
wrf_list=[Dataset(itm) for itm in fn_list[-48:]]

lsmask=wrf.getvar(wrf_list[0], 'LANDMASK')       
var_sen_all=wrf.getvar(
    wrf_list,var,timeidx=wrf.ALL_TIMES, method='cat')
proj=wrf.get_cartopy(var_sen_all)
var_sen_max=var_sen_all.max(dim='Time')
lats, lons = wrf.latlon_coords(var_sen_all)

fn_stream=subprocess.check_output(
    'ls '+ctrl_path+'/'+cases[2]+'/wrfout_'+dom_id+'*', shell=True).decode('utf-8')
fn_list=fn_stream.split()
file_list=fn_list
wrf_list=[Dataset(itm) for itm in fn_list[-48:]]
       
var_ctrl_all=wrf.getvar(
    wrf_list,var,timeidx=wrf.ALL_TIMES, method='cat')
var_ctrl_max=var_ctrl_all.max(dim='Time')


cmap=cmaps.wind_17lev
levels=np.linspace(0,16,17)

fig = plt.figure(figsize=[10, 8],frameon=True)

# Set projection and plot the main figure
ax = fig.add_axes([0.08, 0.01, 0.8, 0.94], projection=proj)

# add gridlines
#gl = ax.gridlines(crs=ccrs.PlateCarree(), draw_labels=True,
#        color='grey', linestyle='--', linewidth=1)
#gl.top_labels = False
#gl.right_labels = False

xticks = np.arange(109,121,3).tolist() 
yticks =  np.arange(18,27,1.5).tolist() 
#ax.gridlines(xlocs=xticks, ylocs=yticks,zorder=1,linestyle='--',lw=0.5,color='gray')
#gl = ax.gridlines(draw_labels=True, alpha=0.0)
#gl.right_labels = False
#gl.top_labels = False
ax.set_xticks(xticks, crs=ccrs.PlateCarree())
ax.set_xticklabels(xticks, fontsize=18)  
ax.set_yticks(yticks, crs=ccrs.PlateCarree())
ax.set_yticklabels(yticks, fontsize=18)  

ax.set_xlim(wrf.cartopy_xlim(lsmask))
ax.set_ylim(wrf.cartopy_ylim(lsmask))

lon_formatter =LongitudeFormatter(number_format='.1f')
lat_formatter = LatitudeFormatter(number_format='.1f')
ax.xaxis.set_major_formatter(lon_formatter)
ax.yaxis.set_major_formatter(lat_formatter)

ax.coastlines()

ax.add_geometries(
    province_shp, ccrs.PlateCarree(),facecolor='none', 
    edgecolor='black',linewidth=0.5, zorder = 2)

plt.contourf(
    wrf.to_np(lons), wrf.to_np(lats), 
    wrf.to_np(var_sen_max[0,:,:])-wrf.to_np(var_ctrl_max[0,:,:]),
    levels=levels, extend='both', 
    transform=ccrs.PlateCarree(), cmap=cmap)
'''
#ax.add_geometries(province_shp, ccrs.PlateCarree(),facecolor='none', edgecolor='black',linewidth=0.1, zorder = 2)
ax.plot(
    df_cma1['lon']/10., df_cma1['lat']/10., color='black', marker='o', 
    linewidth=3, markersize=4, transform=ccrs.Geodetic(), label=' CMA  bestTrack')
ax.plot(
    df_ctrl1.lon[83:120]/1., df_ctrl1.lat[83:120]/1., color='blue', 
    marker='^', linewidth=3, linestyle='dashed', markersize=4, transform=ccrs.Geodetic(), label=' CTRL')
ax.plot(df_pgw1.lon[83:120]/1., df_pgw1.lat[83:120]/1., color='red', 
        marker='s', linewidth=3, linestyle='dashed', markersize=4, transform=ccrs.Geodetic(), label=' PGW')
ax.plot(df_ctrl1.lon[26:72]/1., df_ctrl1.lat[26:72]/1., color='blue', marker='^', linewidth=3, linestyle='dashed', markersize=4, transform=ccrs.Geodetic(), label=' CTRL')
ax.plot(df_pgw1.lon[28:72]/1., df_pgw1.lat[28:72]/1., color='red', marker='s', linewidth=3, linestyle='dashed', markersize=4, transform=ccrs.Geodetic(), label=' PGW')
'''
ax.plot(df_ctrl1.lon[33:115:2]/1., df_ctrl1.lat[33:115:2]/1., color='blue', 
         marker='^', linewidth=3, linestyle='dashed', markersize=4, transform=ccrs.Geodetic(), label=' CTRL')
ax.plot(df_pgw1.lon[16:116:2]/1., df_pgw1.lat[16:116:2]/1., color='red', 
         marker='s', linewidth=3, linestyle='dashed', markersize=4, transform=ccrs.Geodetic(), label=' PGW')

#ax.text(108.8, 25.2, '(a)', fontsize = 24, backgroundcolor='white', transform=ccrs.PlateCarree())
#ax.text(108.8, 25.2, '(b)', fontsize = 24, backgroundcolor='white', transform=ccrs.PlateCarree())
ax.text(108.8, 25.2, '(c)', fontsize = 24, backgroundcolor='white', transform=ccrs.PlateCarree())



cbar=plt.colorbar(ax=ax, shrink=0.9,extendfrac='auto')
cbar.ax.tick_params(labelsize=18) 
plt.savefig(
        '../fig/230222-maxwind-plot.png', 
        dpi=120, bbox_inches='tight')
plt.close()
