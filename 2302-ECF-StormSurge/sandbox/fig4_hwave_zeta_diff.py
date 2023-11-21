import numpy as np
import xarray as xr


ds1 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2018091200/njord_his_d02.20180915.nc")
ds2 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2018091200/njord_his_d02.20180916.nc")
ds3 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2018091200pgw/njord_his_d02.20180915.nc")
ds4 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2018091200pgw/njord_his_d02.20180916.nc")

lon = ds1.lon_rho
lat = ds1.lat_rho
eta_rho = ds1.eta_rho
xi_rho  = ds1.xi_rho


zeta_real1 = np.concatenate([ds1.zeta[12:,:,:].copy().data, ds2.zeta.copy().data], axis=0)
zeta_pgw1 = np.concatenate([ds3.zeta[12:,:,:].copy().data, ds4.zeta.copy().data], axis=0)
hwave_real1 = np.concatenate([ds1.Hwave[12:,:,:].copy().data, ds2.Hwave.copy().data], axis=0)
hwave_pgw1 = np.concatenate([ds3.Hwave[12:,:,:].copy().data, ds4.Hwave.copy().data], axis=0)

zeta_real_max1 = zeta_real1.max(axis=0)
zeta_pgw_max1 = zeta_pgw1.max(axis=0)
hwave_real_max1 = hwave_real1.max(axis=0)
hwave_pgw_max1 = hwave_pgw1.max(axis=0)

zeta_diff1 = (zeta_pgw_max1 - zeta_real_max1) * 100.0
hwave_diff1 = (hwave_pgw_max1 - hwave_real_max1) * 100.0





ds1 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2017082100real/njord_his_d02.20170822.nc")
ds2 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2017082100real/njord_his_d02.20170823.nc")
ds3 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2017082100pgw/njord_his_d02.20170822.nc")
ds4 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2017082100pgw/njord_his_d02.20170823.nc")

zeta_real2 = np.concatenate([ds1.zeta[12:,:,:].data, ds2.zeta.data], axis=0)
zeta_pgw2 = np.concatenate([ds3.zeta[12:,:,:].data, ds4.zeta.data], axis=0)
hwave_real2 = np.concatenate([ds1.Hwave[12:,:,:].data, ds2.Hwave.data], axis=0)
hwave_pgw2 = np.concatenate([ds3.Hwave[12:,:,:].data, ds4.Hwave.data], axis=0)

zeta_real_max2 = zeta_real2.max(axis=0)
zeta_pgw_max2 = zeta_pgw2.max(axis=0)
hwave_real_max2 = hwave_real2.max(axis=0)
hwave_pgw_max2 = hwave_pgw2.max(axis=0)

zeta_diff2 = (zeta_pgw_max2 - zeta_real_max2) * 100.0
hwave_diff2 = (hwave_pgw_max2 - hwave_real_max2) * 100.0






ds1 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2012072000real/njord_his_d02.20120723.nc")
ds2 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2012072000real/njord_his_d02.20120724.nc")
ds3 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2012072000pgw/njord_his_d02.20120723.nc")
ds4 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2012072000pgw/njord_his_d02.20120724.nc")

zeta_real3 = np.concatenate([ds1.zeta[12:,:,:].data, ds2.zeta.data], axis=0)
zeta_pgw3 = np.concatenate([ds3.zeta[12:,:,:].data, ds4.zeta.data], axis=0)
hwave_real3 = np.concatenate([ds1.Hwave[12:,:,:].data, ds2.Hwave.data], axis=0)
hwave_pgw3 = np.concatenate([ds3.Hwave[12:,:,:].data, ds4.Hwave.data], axis=0)

zeta_real_max3 = zeta_real3.max(axis=0)
zeta_pgw_max3 = zeta_pgw3.max(axis=0)
hwave_real_max3 = hwave_real3.max(axis=0)
hwave_pgw_max3 = hwave_pgw3.max(axis=0)

zeta_diff3 = (zeta_pgw_max3 - zeta_real_max3) * 100.0
hwave_diff3 = (hwave_pgw_max3 - hwave_real_max3) * 100.0






zeta_diff_avg = (zeta_diff1 + zeta_diff2 + zeta_diff3)/3.0
hwave_diff_avg = (hwave_diff1 + hwave_diff2 + hwave_diff3)/3.0

dt2 = xr.open_dataset('/home/lzhenn/array74/coop_fenying/2_diff/roms_d02.nc')
lat2 = dt2.lat_rho[:,:]; lon2 = dt2.lon_rho[:,:]
# dt3 = xr.open_dataset('/home/lzhenn/array74/coop_fenying/2_diff/roms_d03.nc')
# lat3 = dt3.lat_rho[:,:]; lon3 = dt3.lon_rho[:,:]

d2 = xr.open_dataset('/home/lzhenn/array74/coop_fenying/2_diff/land_ocean_boundary_rho_d2.nc')
# d3 = xr.open_dataset('/home/lzhenn/array74/coop_fenying/2_diff/land_ocean_boundary_rho_d3.nc')
boundary_d2 = d2.ocean_land
# boundary_d3 = d3.ocean_land






## Plotting Import
import netCDF4 as nc
import pandas as pd
import cmasher as cmr

import matplotlib
matplotlib.use('Agg')
import matplotlib as mpl
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import matplotlib.colors as colors
from matplotlib.colors import BoundaryNorm


import cartopy.crs as ccrs
import cartopy.feature as cf
import cartopy.io.shapereader as shpreader
import cartopy.mpl.ticker as cticker
from cartopy.mpl.ticker import LongitudeFormatter,LatitudeFormatter
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER
import cmaps
import shapely.geometry as sgeom
import cartopy.io.shapereader as shpreader




## Define a Map Function for plotting
def create_map(ax):
    ## map
    # proj = ccrs.PlateCarree(central_longitude=60)  # read projection from ccrs
    ax.add_feature(cf.LAND.with_scale('50m'), color="white")  # Land
    # ax.add_feature(cf.COASTLINE.with_scale('10m'), lw=1.0, color="darkgreen")  # coastline
    # ax.add_feature(cf.RIVERS.with_scale('50m'), lw=0.2)  # rivers
    # extent = [95,135,0,35]
    # ax.set_extent(extent, crs=ccrs.PlateCarree())  # range of [xmin, xmax, ymin, ymax]

    ## ## ##
    cmap = cmaps.BlueDarkRed18  # color
    # norm = BoundaryNorm(levels, ncolors=cmap.N, clip=True)

    ## x,y tick
    extent = [112.4746-0.02, 114.9766+0.01, 21.483-0.02, 22.985+0.02]
    ax.set_extent(extent, crs=ccrs.PlateCarree())  # range of [xmin, xmax, ymin, ymax]
    ax.set_xticks(np.linspace(112.5,115.0,6), crs=ccrs.PlateCarree())  #; ax.set_xticklabels(np.linspace(112.5,115.0,6))
    ax.set_yticks(np.linspace(21.5,23.0,4), crs=ccrs.PlateCarree())    #; ax.set_yticklabels(np.arange(21.5,23.0,4))
    lon_formatter = cticker.LongitudeFormatter(); lat_formatter = cticker.LatitudeFormatter()
    ax.xaxis.set_major_formatter(lon_formatter); ax.yaxis.set_major_formatter(lat_formatter)
    ax.tick_params(axis='both',labelsize=12,direction='out',length=5.0,width=1.3,right=True,top=False)  # tick font format
    # ax.grid(linewidth=0.2, color='k', alpha=0.25, linestyle='--')  # grid line on

    amdn_shp=shpreader.Reader('/home/lzhenn/array74/workspace/njord_pipeline/postprocess/shp/china_coastline.dbf').geometries()
    # plot shp boundaries
    ax.add_geometries(amdn_shp, ccrs.PlateCarree(), facecolor='none', edgecolor='black',linewidth=.3, zorder = 1)

    return ax

def create_map2(ax):
    ax.add_feature(cf.LAND.with_scale('50m'), color="white")  # Land

    ## ## ##
    cmap = cmaps.BlueDarkRed18  # color
    # norm = BoundaryNorm(levels, ncolors=cmap.N, clip=True)

    ## x,y tick
    extent = [112.4746-0.02, 114.9766+0.01, 21.483-0.02, 22.985+0.02]
    ax.set_extent(extent, crs=ccrs.PlateCarree())  # range of [xmin, xmax, ymin, ymax]
    ax.set_xticks(np.linspace(112.5,115.0,6), crs=ccrs.PlateCarree())  #; ax.set_xticklabels(np.linspace(112.5,115.0,6))
    ax.set_yticks(np.linspace(21.5,23.0,4), crs=ccrs.PlateCarree())    #; ax.set_yticklabels(np.arange(21.5,23.0,4))
    lon_formatter = cticker.LongitudeFormatter(); lat_formatter = cticker.LatitudeFormatter()
    ax.xaxis.set_major_formatter(lon_formatter); ax.yaxis.set_major_formatter(lat_formatter)
    ax.tick_params(axis='both',labelsize=12,direction='out',length=5.0,width=1.3,right=True,top=False)  # tick font format
    # ax.grid(linewidth=0.2, color='k', alpha=0.25, linestyle='--')  # grid line on

    return ax





##--##--##--  create figure  --##--##--##
# fig = plt.figure(figsize=(12,8), frameon=True)
fig = plt.figure(dpi=200,figsize=(12,12), frameon=True)
proj = ccrs.PlateCarree(central_longitude=60)  # read projection from ccrs
ax1 = plt.axes([0.1,0.8, 0.3,0.2], projection=proj)
ax2 = plt.axes([0.5,0.8, 0.3,0.2], projection=proj)
ax3 = plt.axes([0.1,0.598, 0.3,0.2], projection=proj)
ax4 = plt.axes([0.5,0.598, 0.3,0.2], projection=proj)
ax5 = plt.axes([0.1,0.348, 0.3,0.25], projection=proj)
ax6 = plt.axes([0.5,0.348, 0.3,0.25], projection=proj)
ax7 = plt.axes([0.1,0.13, 0.3,0.2], projection=proj)
ax8 = plt.axes([0.5,0.13, 0.3,0.2], projection=proj)
create_map(ax1)
create_map(ax2)
create_map(ax3)
create_map(ax4)
create_map(ax5)
create_map(ax6)
create_map2(ax7)
create_map2(ax8)



color1 = cmr.get_sub_cmap("RdBu",1.0, 0.0, N=30)  # define colors
norm1 = BoundaryNorm([-10000,-200.0,-150,-100,-50,0,50,100,150,200.0,10000],color1.N)
color2 = cmr.get_sub_cmap("PiYG",0.0, 1.0, N=30)  # define colors
norm2 = BoundaryNorm([-10000,-80.0,-60,-40,-20,0,20,40,60,80.0,10000],color2.N)



ax1.set_xticklabels(['','','','','',''])
cf_a1 = ax1.pcolormesh(lon,lat, hwave_diff1, cmap=color1,norm=norm1,transform=ccrs.PlateCarree())
ax1.text(112.53, 22.83, '(a)', fontsize = 15, backgroundcolor='white', transform=ccrs.PlateCarree())
ax1.text(112.4, 23.25, 'Wave  height  difference  (cm)', fontsize = 16, fontweight='semibold', transform=ccrs.PlateCarree())
ax1.text(111.6, 21.55, 'Mangkhut (2018)', fontsize = 16, rotation = 'vertical', fontweight='semibold', transform=ccrs.PlateCarree())


ax2.set_xticklabels(['','','','','',''])
cf_a2 = ax2.pcolormesh(lon,lat, zeta_diff1, cmap=color2,norm=norm2,transform=ccrs.PlateCarree())
ax2.text(112.53, 22.83, '(b)', fontsize = 15, backgroundcolor='white', transform=ccrs.PlateCarree())
ax2.text(112.4, 23.25, 'Storm  surge  difference  (cm)', fontsize = 16, fontweight='semibold', transform=ccrs.PlateCarree())


ax3.set_xticklabels(['','','','','',''])
cf_a3 = ax3.pcolormesh(lon,lat, hwave_diff2, cmap=color1,norm=norm1,transform=ccrs.PlateCarree())
ax3.text(112.53, 22.83, '(c)', fontsize = 15, backgroundcolor='white', transform=ccrs.PlateCarree())
ax3.text(111.6, 21.75, 'Hato (2017)', fontsize = 16, rotation = 'vertical', fontweight='semibold', transform=ccrs.PlateCarree())


ax4.set_xticklabels(['','','','','',''])
cf_a4 = ax4.pcolormesh(lon,lat, zeta_diff2, cmap=color2,norm=norm2,transform=ccrs.PlateCarree())
ax4.text(112.53, 22.83, '(d)', fontsize = 15, backgroundcolor='white', transform=ccrs.PlateCarree())

cf_a5 = ax5.pcolormesh(lon,lat, hwave_diff3, cmap=color1,norm=norm1,transform=ccrs.PlateCarree())
cb5 = fig.colorbar(
    cf_a5,ax=ax5,orientation="horizontal",
    fraction=0.08, aspect=45, pad=0.15, extend='neither', #extendfrac='auto',
    ticks=[-200.0,-100,0,100,200.0], spacing='uniform'
)
cb5.ax.tick_params(labelsize=12)  # label font
for l in cb5.ax.yaxis.get_ticklabels():
    l.set_family('semibold')
ax5.text(112.53, 22.83, '(e)', fontsize = 15, backgroundcolor='white', transform=ccrs.PlateCarree())
ax5.text(111.6, 21.63, 'Vicente (2012)', fontsize = 16, rotation = 'vertical', fontweight='semibold', transform=ccrs.PlateCarree())



cf_a6 = ax6.pcolormesh(lon,lat, zeta_diff3, cmap=color2,norm=norm2,transform=ccrs.PlateCarree())
cb6 = fig.colorbar(
    cf_a6,ax=ax6,orientation="horizontal",
    fraction=0.08, aspect=45, pad=0.15, extend='neither', #extendfrac='auto',
    ticks=[-80.0,-60,-40,-20,0,20,40,60,80.0], spacing='uniform'
)
cb6.ax.tick_params(labelsize=12)  # label font
for l in cb6.ax.yaxis.get_ticklabels():
    l.set_family('semibold')
ax6.text(112.53, 22.83, '(f)', fontsize = 15, backgroundcolor='white', transform=ccrs.PlateCarree())






for y in range(0, np.shape(hwave_diff_avg)[0]):
  if y%50==0: print('y=',y)
  for x in range(0, np.shape(hwave_diff_avg)[1]):
    if boundary_d2[y,x] == 3:
      if hwave_diff_avg[y,x]>=60 : co = '#8B0000'; ms = 0.6
      elif hwave_diff_avg[y,x]>=40 and hwave_diff_avg[y,x]<60 : co = '#FF0000'; ms = 0.6
      elif hwave_diff_avg[y,x]>=20 and hwave_diff_avg[y,x]<40 : co = '#EE9A00'; ms = 0.6
      elif hwave_diff_avg[y,x]>=0 and hwave_diff_avg[y,x]<20 : co = '#EEE8AA'; ms = 0.6
      elif hwave_diff_avg[y,x]<0 : co = '#D3D3D3'; ms = 0.05
      ax7.plot(lon2[y,x], lat2[y,x], marker='s', markersize=ms, color=co, transform=ccrs.Geodetic())

ax7.plot(114.2, 21.85, marker='s',mec='#8B0000', mfc='#8B0000', markersize=6.0, transform=ccrs.PlateCarree())
ax7.plot(114.2, 21.70, marker='s', mec='#FF0000', mfc='#FF0000', markersize=6.0, transform=ccrs.PlateCarree())
ax7.plot(114.2, 21.55, marker='s', mec='#EE9A00', mfc='#EE9A00', markersize=6.0, transform=ccrs.PlateCarree())
ax7.plot(114.64, 21.85, marker='s', mec='#EEE8AA', mfc='#EEE8AA', markersize=6.0, transform=ccrs.PlateCarree())
ax7.plot(114.64, 21.70, marker='s', mec='#D3D3D3', mfc='#D3D3D3', markersize=2.0, transform=ccrs.PlateCarree())

ax7.text(114.25, 21.85-0.025, '> 60', fontsize = 9, transform=ccrs.PlateCarree())
ax7.text(114.25, 21.70-0.025, '(40,60)', fontsize = 9, transform=ccrs.PlateCarree())
ax7.text(114.25, 21.55-0.025, '(20,40)', fontsize = 9, transform=ccrs.PlateCarree())
ax7.text(114.69, 21.85-0.025, '(0,20)', fontsize = 9, transform=ccrs.PlateCarree())
ax7.text(114.69, 21.70-0.025, '< 0', fontsize = 9, transform=ccrs.PlateCarree())
ax7.text(111.6, 21.93, 'Average', fontsize = 16, rotation = 'vertical', fontweight='semibold', transform=ccrs.PlateCarree())
ax7.text(112.53, 22.83, '(g)', fontsize = 15, backgroundcolor='white', transform=ccrs.PlateCarree())



for y in range(0, np.shape(zeta_diff_avg)[0]):
  if y%50==0: print('y=',y)
  for x in range(0, np.shape(zeta_diff_avg)[1]):
    if boundary_d2[y,x] == 3:
      if zeta_diff_avg[y,x]>=60 : 
        co = '#8B0000'; ms = 0.6
      elif zeta_diff_avg[y,x]>=40 and zeta_diff_avg[y,x]<60 : 
        co = '#FF0000'; ms = 0.6
      elif zeta_diff_avg[y,x]>=20 and zeta_diff_avg[y,x]<40 : 
        co = '#EE9A00'; ms = 0.6
      elif zeta_diff_avg[y,x]>=0 and zeta_diff_avg[y,x]<20 : 
        co = '#EEE8AA'; ms = 0.6
      elif zeta_diff_avg[y,x]<0 : 
        co = '#D3D3D3'; ms = 0.05
      ax8.plot(lon2[y,x], lat2[y,x], marker='s', markersize=ms, color=co, transform=ccrs.Geodetic())
ax8.plot(114.2, 21.85, marker='s',mec='#8B0000', mfc='#8B0000', markersize=6.0, transform=ccrs.PlateCarree())
ax8.plot(114.2, 21.70, marker='s', mec='#FF0000', mfc='#FF0000', markersize=6.0, transform=ccrs.PlateCarree())
ax8.plot(114.2, 21.55, marker='s', mec='#EE9A00', mfc='#EE9A00', markersize=6.0, transform=ccrs.PlateCarree())
ax8.plot(114.64, 21.85, marker='s', mec='#EEE8AA', mfc='#EEE8AA', markersize=6.0, transform=ccrs.PlateCarree())
ax8.plot(114.64, 21.70, marker='s', mec='#D3D3D3', mfc='#D3D3D3', markersize=2.0, transform=ccrs.PlateCarree())

ax8.text(114.25, 21.85-0.025, '> 60', fontsize = 9, transform=ccrs.PlateCarree())
ax8.text(114.25, 21.70-0.025, '(40,60)', fontsize = 9, transform=ccrs.PlateCarree())
ax8.text(114.25, 21.55-0.025, '(20,40)', fontsize = 9, transform=ccrs.PlateCarree())
ax8.text(114.69, 21.85-0.025, '(0,20)', fontsize = 9, transform=ccrs.PlateCarree())
ax8.text(114.69, 21.70-0.025, '< 0', fontsize = 9, transform=ccrs.PlateCarree())
ax8.text(112.53, 22.83, '(h)', fontsize = 15, backgroundcolor='white', transform=ccrs.PlateCarree())


fig.savefig('/home/lzhenn/array74/coop_fenying/7_article_FIG/Fig4_diff.pdf', bbox_inches = 'tight')
# fig.show()






