import matplotlib
import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
matplotlib.use('Agg')
import shapely.geometry as sgeom

import cartopy.crs as ccrs
import cartopy.io.shapereader as shpreader

def main():
    # to get the effect of having just the states without a map "background"
    # turn off the background patch and axes frame
    
    
    # Set projection and plot the main figure
    proj = ccrs.Mercator(central_longitude=115., min_latitude=-80.0, max_latitude=84.0, globe=None, 
            latitude_true_scale=21.0, false_easting=0.0, false_northing=0.0, scale_factor=None)
    fig = plt.figure(figsize=[10, 8],frameon=True)
    
    ax = fig.add_axes([0.08, 0.05, 0.8, 0.94], projection=proj)
    
    # Set figure extent
    ax.set_extent([104, 118, 16, 27],crs=ccrs.PlateCarree())
    province_shp=shpreader.Reader('../../UTILITY-2016/shp/cnmap/cnhimap.dbf').geometries()
    county_shp = shpreader.Reader('../../UTILITY-2016/shp/cnmap/county_2004.dbf').geometries()
    ax.add_geometries(county_shp, ccrs.PlateCarree(),facecolor='none', edgecolor='gray',linewidth=0.5, zorder = -1)
    ax.add_geometries(province_shp, ccrs.PlateCarree(),facecolor='none', edgecolor='black',linewidth=1., zorder = 0)
#    ax.add_geometries(province_shp, proj,facecolor='none', edgecolor='black',linewidth=1., zorder = 0)


    plt.savefig("../fig/test2.png", dpi=200, bbox_inches='tight')


if __name__ == '__main__':
    main()
