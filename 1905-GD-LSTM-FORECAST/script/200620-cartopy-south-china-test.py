import matplotlib as plt
import cartopy.crs as ccrs
import cartopy.feature as cfeature
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER
import cartopy.mpl.ticker as cticker
import cartopy.io.shapereader as shpreader

#建立画布(这部分没啥好说的，跳过)
fig2 = plt.figure(figsize=(15,15))
proj = ccrs.PlateCarree(central_longitude=105) 
leftlon, rightlon, lowerlat, upperlat = (70,140,15,55)
#绘制地图
f2_ax1 = fig2.add_axes([0.1, 0.1, 0.5, 0.3],projection = proj)
#在画布的绝对坐标建立子图
f2_ax1.set_extent([leftlon, rightlon, lowerlat, upperlat], crs=ccrs.PlateCarree())
#海岸线，50m精度
f2_ax1.add_feature(cfeature.COASTLINE.with_scale('50m'))
#湖泊数据(但是这个貌似只画了比较大的湖泊，比如贝湖巴湖)
f2_ax1.add_feature(cfeature.LAKES, alpha=0.5)
#以下6条语句是定义地理坐标标签格式
f2_ax1.set_xticks(np.arange(leftlon,rightlon+10,10), crs=ccrs.PlateCarree())
f2_ax1.set_yticks(np.arange(lowerlat,upperlat+10,10), crs=ccrs.PlateCarree())
lon_formatter = cticker.LongitudeFormatter()
lat_formatter = cticker.LatitudeFormatter()
f2_ax1.xaxis.set_major_formatter(lon_formatter)
f2_ax1.yaxis.set_major_formatter(lat_formatter)
f2_ax1.set_title('Station',loc='center',fontsize =15)
#读取shp文件
china = shpreader.Reader('/disk/hq247/yhuangci/lzhenn/project/UTILITY-2016/shp/cnmap/cnmap.shp').geometries()
#绘制中国国界省界九段线等等
f2_ax1.add_geometries(china, ccrs.PlateCarree(),facecolor='none', edgecolor='black',zorder = 1)
#添加南海，实际上就是新建一个子图覆盖在之前子图的右下角
f2_ax2 = fig2.add_axes([0.5175, 0.0935, 0.08, 0.13],projection = proj)
f2_ax2.set_extent([105, 125, 0, 25], crs=ccrs.PlateCarree())
f2_ax2.add_feature(cfeature.COASTLINE.with_scale('50m'))
china = shpreader.Reader('/data/home/zenggang/yxy/shp/bou2_4l.dbf').geometries()
f2_ax2.add_geometries(china, ccrs.PlateCarree(),facecolor='none', edgecolor='black',zorder = 1)
