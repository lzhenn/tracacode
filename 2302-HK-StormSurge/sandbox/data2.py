import numpy as np
import xarray as xr
import os
##----------------------------- 第二部分  -----------------------------##
##------------  读取数据: 逐小时降水  ------------##
import os
f1 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2018091200/wrfout_d02_2018-09-17_00:00:00")
RAINNC_real_acc1 = f1.RAINNC[0,:,:]
f2 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2018091200pgw/wrfout_d02_2018-09-17_00:00:00")
RAINNC_pgw_acc1 = f2.RAINNC[0,:,:]


##------------  Mangkhut (2018)  ------------##
path='/home/lzhenn/cooperate/data/case_study/coupled/2018091200'
files_all = os.listdir(path)
files = []
for file2 in files_all:
    if os.path.basename(file2)[0:16] == 'wrfout_d02_2018-':
        files.append(file2)
rain_hourly_real1 = np.zeros((len(files)-1, np.shape(RAINNC_pgw_acc1)[0], np.shape(RAINNC_pgw_acc1)[1]))

for i in range(len(files)-1):
    print(' i = ',i,'     ',files[i])
    f4 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2018091200/"+files[i])
    f5 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2018091200/"+files[i+1])
    rain_hourly_real1[i,:,:] = f5.RAINNC[0,:,:].data - f4.RAINNC[0,:,:].data 



path='/home/lzhenn/cooperate/data/case_study/coupled/2018091200pgw'
files_all = os.listdir(path)
files = []
for file2 in files_all:
    if os.path.basename(file2)[0:16] == 'wrfout_d02_2018-':
        files.append(file2)
rain_hourly_pgw1 = np.zeros((len(files)-1, np.shape(RAINNC_pgw_acc1)[0], np.shape(RAINNC_pgw_acc1)[1]))

for i in range(len(files)-1):
    print(' i = ',i,'     ',files[i])
    f4 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2018091200pgw/"+files[i])
    f5 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2018091200pgw/"+files[i+1])
    rain_hourly_pgw1[i,:,:] = f5.RAINNC[0,:,:].data - f4.RAINNC[0,:,:].data 



##------------  Hato (2017)  ------------##
path='/home/lzhenn/cooperate/data/case_study/coupled/2017082100real'
files_all = os.listdir(path)
files = []
for file2 in files_all:
    if os.path.basename(file2)[0:16] == 'wrfout_d02_2017-':
        files.append(file2)
rain_hourly_real2 = np.zeros((len(files)-1, np.shape(RAINNC_pgw_acc1)[0], np.shape(RAINNC_pgw_acc1)[1]))

for i in range(len(files)-1):
    print(' i = ',i,'     ',files[i])
    f4 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2017082100real/"+files[i])
    f5 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2017082100real/"+files[i+1])
    rain_hourly_real2[i,:,:] = f5.RAINNC[0,:,:].data - f4.RAINNC[0,:,:].data 



path='/home/lzhenn/cooperate/data/case_study/coupled/2017082100pgw'
files_all = os.listdir(path)
files = []
for file2 in files_all:
    if os.path.basename(file2)[0:16] == 'wrfout_d02_2017-':
        files.append(file2)
rain_hourly_pgw2 = np.zeros((len(files)-1, np.shape(RAINNC_pgw_acc1)[0], np.shape(RAINNC_pgw_acc1)[1]))

for i in range(len(files)-1):
    print(' i = ',i,'     ',files[i])
    f4 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2017082100pgw/"+files[i])
    f5 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2017082100pgw/"+files[i+1])
    rain_hourly_pgw2[i,:,:] = f5.RAINNC[0,:,:].data - f4.RAINNC[0,:,:].data 




##------------  Vicente (2012)  ------------##
path='/home/lzhenn/cooperate/data/case_study/coupled/2012072000real'
files_all = os.listdir(path)
files = []
for file2 in files_all:
    if os.path.basename(file2)[0:16] == 'wrfout_d02_2012-':
        files.append(file2)
rain_hourly_real3 = np.zeros((len(files)-1, np.shape(RAINNC_pgw_acc1)[0], np.shape(RAINNC_pgw_acc1)[1]))

for i in range(len(files)-1):
    print(' i = ',i,'     ',files[i])
    f4 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2012072000real/"+files[i])
    f5 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2012072000real/"+files[i+1])
    rain_hourly_real3[i,:,:] = f5.RAINNC[0,:,:].data - f4.RAINNC[0,:,:].data 



path='/home/lzhenn/cooperate/data/case_study/coupled/2012072000pgw'
files_all = os.listdir(path)
files = []
for file2 in files_all:
    if os.path.basename(file2)[0:16] == 'wrfout_d02_2012-':
        files.append(file2)
rain_hourly_pgw3 = np.zeros((len(files)-1, np.shape(RAINNC_pgw_acc1)[0], np.shape(RAINNC_pgw_acc1)[1]))

for i in range(len(files)-1):
    print(' i = ',i,'     ',files[i])
    f4 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2012072000pgw/"+files[i])
    f5 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2012072000pgw/"+files[i+1])
    rain_hourly_pgw3[i,:,:] = f5.RAINNC[0,:,:].data - f4.RAINNC[0,:,:].data 





##------------  求Hourly降水的 pdf  ------------##
# 0-873，0-629，0-1156
rain_real_a1 = []; rain_pgw_a1 = []
rain_real_a2 = []; rain_pgw_a2 = []
rain_real_a3 = []; rain_pgw_a3 = []

for x in np.arange(5,155,10):
    print('x = ',x)
    if x == 5:
        rain_real_a1.append(np.sum(np.sum(np.array(rain_hourly_real1>=1) & np.array(rain_hourly_real1<=x+5))))
        rain_pgw_a1.append(np.sum(np.sum(np.array(rain_hourly_pgw1>=1) & np.array(rain_hourly_pgw1<=x+5))))
    elif x>10:
        rain_real_a1.append(np.sum(np.sum(np.array(rain_hourly_real1>x-5) & np.array(rain_hourly_real1<=x+5))))
        rain_pgw_a1.append(np.sum(np.sum(np.array(rain_hourly_pgw1>x-5) & np.array(rain_hourly_pgw1<=x+5))))
# print(rain_real_a1)

for x in np.arange(5,185,10):
    print('x = ',x)
    if x == 5:
        rain_real_a2.append(np.sum(np.sum(np.array(rain_hourly_real2>=1) & np.array(rain_hourly_real2<=x+5))))
        rain_pgw_a2.append(np.sum(np.sum(np.array(rain_hourly_pgw2>=1) & np.array(rain_hourly_pgw2<=x+5))))
    elif x>10:
        rain_real_a2.append(np.sum(np.sum(np.array(rain_hourly_real2>x-5) & np.array(rain_hourly_real2<=x+5))))
        rain_pgw_a2.append(np.sum(np.sum(np.array(rain_hourly_pgw2>x-5) & np.array(rain_hourly_pgw2<=x+5))))

for x in np.arange(5,195,10):
    print('x = ',x)
    if x == 5:
        rain_real_a3.append(np.sum(np.sum(np.array(rain_hourly_real3>=1) & np.array(rain_hourly_real3<=x+5))))
        rain_pgw_a3.append(np.sum(np.sum(np.array(rain_hourly_pgw3>=1) & np.array(rain_hourly_pgw3<=x+5))))
    elif x>10:
        rain_real_a3.append(np.sum(np.sum(np.array(rain_hourly_real3>x-5) & np.array(rain_hourly_real3<=x+5))))
        rain_pgw_a3.append(np.sum(np.sum(np.array(rain_hourly_pgw3>x-5) & np.array(rain_hourly_pgw3<=x+5))))


rain_real_total1 = np.sum(np.sum(np.array(rain_hourly_real1>=1)))
rain_real_total2 = np.sum(np.sum(np.array(rain_hourly_real2>=1)))
rain_real_total3 = np.sum(np.sum(np.array(rain_hourly_real3>=1)))
rain_pgw_total1 = np.sum(np.sum(np.array(rain_hourly_pgw1>=1)))
rain_pgw_total2 = np.sum(np.sum(np.array(rain_hourly_pgw2>=1)))
rain_pgw_total3 = np.sum(np.sum(np.array(rain_hourly_pgw3>=1)))

rain_real_a1_ = rain_real_a1 / rain_real_total1
rain_real_a2_ = rain_real_a2 / rain_real_total2
rain_real_a3_ = rain_real_a3 / rain_real_total3
rain_pgw_a1_ = rain_pgw_a1 / rain_pgw_total1
rain_pgw_a2_ = rain_pgw_a2 / rain_pgw_total2
rain_pgw_a3_ = rain_pgw_a3 / rain_pgw_total3

print(np.max(rain_real_a1_),np.max(rain_real_a2_),np.max(rain_real_a3_))
print(np.max(rain_pgw_a1_),np.max(rain_pgw_a2_),np.max(rain_pgw_a3_))

print("            ")
print("RAINNC   Real   ",np.max(rain_hourly_real1), np.max(rain_hourly_real2), np.max(rain_hourly_real3))
print("RAINNC   PGW   ",np.max(rain_hourly_pgw1), np.max(rain_hourly_pgw2), np.max(rain_hourly_pgw3))

print(rain_real_a1_)
print(rain_real_a1_.data)
nc_dict1 = {
  "dims": {"rainfall": np.shape(np.arange(5,155,10))[0],   ### 维度信息
  "coords": {  # nc文件的维度信息的坐标信息 (lat,lon,time等)
    "rainfall": {
      "dims": ("rainfall"),
      "data": np.arange(5,155,10),
    }
  },
  "data_vars": {   ### 变量
    "rain_real_a1_": {
      "dims": ("rainfall"),
      "data": rain_real_a1_.data
    }
  }
}
}
ds1 = xr.Dataset.from_dict(nc_dict1)
ds1.to_netcdf("/home/lzhenn/array74/coop_fenying/7_article_FIG/hourlyRainPer_real1.nc")
ds1.close()


nc_dict2 = {
  "dims": {"rainfall": np.shape(np.arange(5,185,10))[0],   ### 维度信息
  "coords": {  # nc文件的维度信息的坐标信息 (lat,lon,time等)
    "rainfall": {
      "dims": ("rainfall"),
      "data": np.arange(5,185,10),
    }
  },
  "data_vars": {   ### 变量
    "rain_real_a2_": {
      "dims": ("rainfall"),
      "data": rain_real_a2_
    }
  }
}
}
ds2 = xr.Dataset.from_dict(nc_dict2)
ds2.to_netcdf("/home/lzhenn/array74/coop_fenying/7_article_FIG/hourlyRainPer_real2.nc")
ds2.close()


nc_dict3 = {
  "dims": {"rainfall": np.shape(np.arange(5,195,10))[0],   ### 维度信息
  "coords": {  # nc文件的维度信息的坐标信息 (lat,lon,time等)
    "rainfall": {
      "dims": ("rainfall"),
      "data": np.arange(5,195,10),
    }
  },
  "data_vars": {   ### 变量
    "rain_real_a3_": {
      "dims": ("rainfall"),
      "data": rain_real_a3_
    }
  }
}
}
ds3 = xr.Dataset.from_dict(nc_dict3)
ds3.to_netcdf("/home/lzhenn/array74/coop_fenying/7_article_FIG/hourlyRainPer_real3.nc")
ds3.close()




nc_dict4 = {
  "dims": {"rainfall": np.shape(np.arange(5,155,10))[0],   ### 维度信息
  "coords": {  # nc文件的维度信息的坐标信息 (lat,lon,time等)
    "rainfall": {
      "dims": ("rainfall"),
      "data": np.arange(5,155,10),
    }
  },
  "data_vars": {   ### 变量
    "rain_pgw_a1_": {
      "dims": ("rainfall"),
      "data": rain_pgw_a1_
    }
  }
}
}
ds4 = xr.Dataset.from_dict(nc_dict4)
ds4.to_netcdf("/home/lzhenn/array74/coop_fenying/7_article_FIG/hourlyRainPer_pgw1.nc")
ds4.close()


nc_dict5 = {
  "dims": {"rainfall": np.shape(np.arange(5,185,10))[0],   ### 维度信息
  "coords": {  # nc文件的维度信息的坐标信息 (lat,lon,time等)
    "rainfall": {
      "dims": ("rainfall"),
      "data": np.arange(5,185,10),
    }
  },
  "data_vars": {   ### 变量
    "rain_pgw_a2_": {
      "dims": ("rainfall"),
      "data": rain_pgw_a2_
    }
  }
}
}
ds5 = xr.Dataset.from_dict(nc_dict5)
ds5.to_netcdf("/home/lzhenn/array74/coop_fenying/7_article_FIG/hourlyRainPer_pgw2.nc")
ds5.close()


nc_dict6 = {
  "dims": {"rainfall": np.shape(np.arange(5,195,10))[0],   ### 维度信息
  "coords": {  # nc文件的维度信息的坐标信息 (lat,lon,time等)
    "rainfall": {
      "dims": ("rainfall"),
      "data": np.arange(5,195,10),
    }
  },
  "data_vars": {   ### 变量
    "rain_pgw_a3_": {
      "dims": ("rainfall"),
      "data": rain_pgw_a3_
    }
  }
}
}
ds6 = xr.Dataset.from_dict(nc_dict6)
ds6.to_netcdf("/home/lzhenn/array74/coop_fenying/7_article_FIG/hourlyRainPer_pgw3.nc")
ds6.close()