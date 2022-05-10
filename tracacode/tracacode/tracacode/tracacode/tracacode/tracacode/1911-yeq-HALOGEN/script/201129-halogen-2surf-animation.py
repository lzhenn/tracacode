import numpy as np
import xarray as xr
import matplotlib.pyplot as plt
import matplotlib.ticker as tick
from mpl_toolkits.mplot3d import axes3d
import cartopy.crs as ccrs
from scipy.ndimage import gaussian_filter
from cartopy.feature import NaturalEarthFeature
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER
from cartopy.mpl.ticker import LatitudeFormatter, LongitudeFormatter
import imageio
import os

from datetime import datetime


grid_fn="/disk/hq247/yhuangci/resource/map_info/research_domains/27km/GRIDCRO2D.27km"
height_fn = "/disk/v092.yhuangci/halogen_output/mcip_dir/jan/METCRO3D.27km.20160105"
data_fn = "/disk/hq247/yhuangci/analy/halogen/result/data/cmaq/with/jan/COMBINE_CCTM_ACONC_27km_20160105.nc"
fig_dir='../fig/'
grid_ds=xr.open_dataset(grid_fn)
terr_h=grid_ds['HT'][0,0,:,:]
xlat=grid_ds['LAT'][0,0,:,:]
xlon=grid_ds['LON'][0,0,:,:]
height_ds=xr.open_dataset(height_fn)
surf_h=height_ds['ZF'][:,15,:,:]
data_ds=xr.open_dataset(data_fn)
bro=data_ds['BRO'][:,15,:,:]

images = []
filenames = []

# make individual still images at range of viewpoint elevations
nframe=24
iframe=0
while iframe<=nframe:
    print(iframe)
    plt.figure(iframe,figsize=plt.figaspect(0.5))

    ax=plt.gca(projection='3d')

    surf=ax.plot_surface(xlon,xlat,terr_h+surf_h[iframe,:,:],cmap="coolwarm",alpha=0.5,
                       rstride=1,cstride=1,
                       linewidth=0, antialiased=False)

    ax.plot_surface(xlon,xlat,terr_h,color="lightgray",
                       rstride=1,cstride=1,
                       linewidth=0, antialiased=False)
                       
    ax.set_zlim(0,7000)
#    ax.set_xlim(lon1,lon2)
#    ax.set_ylim(lat1,lat2)
    ax.view_init(elev=30 - iframe,azim=-90)
#    ax.view_init(elev=20, azim=-90)
    

    plt.title('BRO at Layer15 over Terrain')
    
    plt.colorbar(surf)
                    
    filename=fig_dir +'temp'+ '{:04d}'.format(iframe)+'.png'
    plt.savefig(filename, dpi=90, bbox_inches='tight')
    
    images.append(imageio.imread(filename))
    filenames.append(filename)
    
    plt.clf()
                    
    plt.close('all')
    iframe=iframe+1

# combine individual images into an animated gif    
imageio.mimsave(fig_dir+'tp_anom.gif', images)

