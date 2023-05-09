import numpy as np
import xarray as xr
import os

##------------  读取数据: 累积降水  ------------##
f1 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2018091200/wrfout_d02_2018-09-17_00:00:00")
RAINNC_real_acc1 = f1.RAINNC[0,:,:]

print("RAINNC   Real   ",np.max(RAINNC_real_acc1).data, np.min(RAINNC_real_acc1).data)
f2 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2018091200pgw/wrfout_d02_2018-09-17_00:00:00")
RAINNC_pgw_acc1 = f2.RAINNC[0,:,:]
print("RAINNC   PGW   ",np.max(RAINNC_pgw_acc1).data, np.min(RAINNC_pgw_acc1).data)


f3 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2017082100real/wrfout_d02_2017-08-24_00:00:00")
RAINNC_real_acc2 = f3.RAINNC[0,:,:]
print("RAINNC   Real   ",np.max(RAINNC_real_acc2).data, np.min(RAINNC_real_acc2).data)
f4 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2017082100pgw/wrfout_d02_2017-08-24_00:00:00")
RAINNC_pgw_acc2 = f4.RAINNC[0,:,:]
print("RAINNC   PGW   ",np.max(RAINNC_pgw_acc2).data, np.min(RAINNC_pgw_acc2).data)


f5 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2012072000real/wrfout_d02_2012-07-25_00:00:00")
RAINNC_real_acc3 = f5.RAINNC[0,:,:]
print("RAINNC   Real   ",np.max(RAINNC_real_acc3).data, np.min(RAINNC_real_acc3).data)
f6 = xr.open_dataset("/home/lzhenn/cooperate/data/case_study/coupled/2012072000pgw/wrfout_d02_2012-07-25_00:00:00")
RAINNC_pgw_acc3 = f6.RAINNC[0,:,:]
print("RAINNC   PGW   ",np.max(RAINNC_pgw_acc3).data, np.min(RAINNC_pgw_acc3).data)



##------------  求累积降水的 pdf  ------------##
# 0-873，0-629，0-1156
RAINNC_real_a1 = []; RAINNC_pgw_a1 = []
RAINNC_real_a2 = []; RAINNC_pgw_a2 = []
RAINNC_real_a3 = []; RAINNC_pgw_a3 = []

for x in np.arange(50,850,50):
    print('x = ',x)
    RAINNC_real_a1.append(np.sum(np.sum(np.array(RAINNC_real_acc1>x-25) & np.array(RAINNC_real_acc1<=x+25))))
    RAINNC_pgw_a1.append(np.sum(np.sum(np.array(RAINNC_pgw_acc1>x-25) & np.array(RAINNC_pgw_acc1<=x+25))))
# print(RAINNC_real_a1)

for x in np.arange(50,650,50):
    print('x = ',x)
    RAINNC_real_a2.append(np.sum(np.sum(np.array(RAINNC_real_acc2>x-25) & np.array(RAINNC_real_acc2<=x+25))))
    RAINNC_pgw_a2.append(np.sum(np.sum(np.array(RAINNC_pgw_acc2>x-25) & np.array(RAINNC_pgw_acc2<=x+25))))

for x in np.arange(50,1150,50):
    print('x = ',x)
    RAINNC_real_a3.append(np.sum(np.sum(np.array(RAINNC_real_acc3>x-25) & np.array(RAINNC_real_acc3<=x+25))))
    RAINNC_pgw_a3.append(np.sum(np.sum(np.array(RAINNC_pgw_acc3>x-25) & np.array(RAINNC_pgw_acc3<=x+25))))


RAINNC_real_total1 = np.sum(np.sum(np.array(RAINNC_real_acc1>=1)))
RAINNC_real_total2 = np.sum(np.sum(np.array(RAINNC_real_acc2>=1)))
RAINNC_real_total3 = np.sum(np.sum(np.array(RAINNC_real_acc3>=1)))
RAINNC_pgw_total1 = np.sum(np.sum(np.array(RAINNC_pgw_acc1>=1)))
RAINNC_pgw_total2 = np.sum(np.sum(np.array(RAINNC_pgw_acc2>=1)))
RAINNC_pgw_total3 = np.sum(np.sum(np.array(RAINNC_pgw_acc3>=1)))

RAINNC_real_a1_ = RAINNC_real_a1 / RAINNC_real_total1
RAINNC_real_a2_ = RAINNC_real_a2 / RAINNC_real_total2
RAINNC_real_a3_ = RAINNC_real_a3 / RAINNC_real_total3
RAINNC_pgw_a1_ = RAINNC_pgw_a1 / RAINNC_pgw_total1
RAINNC_pgw_a2_ = RAINNC_pgw_a2 / RAINNC_pgw_total2
RAINNC_pgw_a3_ = RAINNC_pgw_a3 / RAINNC_pgw_total3

print(np.max(RAINNC_real_a1_),np.max(RAINNC_real_a2_),np.max(RAINNC_real_a3_))
print(np.max(RAINNC_pgw_a1_),np.max(RAINNC_pgw_a2_),np.max(RAINNC_pgw_a3_))

print("            ")






















##----------------------------- Plotting Import  -----------------------------##
import numpy as np
import xarray as xr
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


fig = plt.figure(dpi=400,figsize=(12,12))
ax1 = fig.add_axes([0.05, 0.6, 0.27, 0.2])
ax2 = fig.add_axes([0.4, 0.6, 0.27, 0.2])
ax3 = fig.add_axes([0.75, 0.6, 0.27, 0.2])
ax4 = fig.add_axes([0.05, 0.35, 0.27, 0.2])
ax5 = fig.add_axes([0.4, 0.35, 0.27, 0.2])
ax6 = fig.add_axes([0.75, 0.35, 0.27, 0.2])


ax1.set_xlim(45,900)
ax1.set_ylim(0.0,0.35)
ax1.set_xscale('log')
ax1.tick_params(axis='both',labelsize=12,direction='out',length=5.0,width=1.3,right=True,top=False) 
ax1.plot(np.arange(50,850,50), RAINNC_real_a1_, label='CTRL', color='blue', marker='^', linewidth=1.5,  markersize=4.0)
ax1.plot(np.arange(50,850,50), RAINNC_pgw_a1_, label='PGW', color='red', marker='s', linewidth=1.5,  markersize=4.0)
ax1.set_xticks([50, 100, 200, 500])
ax1.get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
ax1.legend(loc='best', fontsize=12.5)
ax1.text(50, 0.02, '(a)', fontsize = 15, backgroundcolor='white')
ax1.text(80, 0.4, 'Mangkhut (2018)', fontsize = 16, fontweight='semibold')
ax1.text(17, 0.06, 'Total  rainfall', fontsize = 16, rotation = 'vertical', fontweight='semibold')

ax2.set_xlim(45,700)
ax2.set_ylim(0.0,0.35)
ax2.set_xscale('log')
ax2.tick_params(axis='both',labelsize=12,direction='out',length=5.0,width=1.3,right=True,top=False) 
ax2.plot(np.arange(50,650,50), RAINNC_real_a2_, label='CTRL', color='blue', marker='^', linewidth=1.5,  markersize=4.0)
ax2.plot(np.arange(50,650,50), RAINNC_pgw_a2_, label='PGW', color='red', marker='s', linewidth=1.5,  markersize=4.0)
ax2.set_xticks([50, 100, 200, 500])
ax2.get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
ax2.text(50, 0.02, '(b)', fontsize = 15, backgroundcolor='white')
ax2.text(97, 0.4, 'Hato (2017)', fontsize = 16, fontweight='semibold')

ax3.set_xlim(45,1200)
ax3.set_ylim(0.0,0.35)
ax3.set_xscale('log')
ax3.tick_params(axis='both',labelsize=12,direction='out',length=5.0,width=1.3,right=True,top=False) 
ax3.plot(np.arange(50,1150,50), RAINNC_real_a3_, label='CTRL', color='blue', marker='^', linewidth=1.5,  markersize=4.0)
ax3.plot(np.arange(50,1150,50), RAINNC_pgw_a3_, label='PGW', color='red', marker='s', linewidth=1.5,  markersize=4.0)
ax3.set_xticks([50, 100, 200, 500, 1000])
ax3.get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
ax3.text(50, 0.02, '(c)', fontsize = 15, backgroundcolor='white')
ax3.text(86.5, 0.4, 'Vicente (2013)', fontsize = 16, fontweight='semibold')












##----------------------------- 第二部分  -----------------------------##
##------------  读取数据: 逐小时降水  ------------##
import os


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





##------------  第二部分：绘图  ------------##
ax4.set_xlim(4.5,155)
ax4.set_ylim(0.0,0.82)
ax4.set_xscale('log')
ax4.tick_params(axis='both',labelsize=12,direction='out',length=5.0,width=1.3,right=True,top=False) 
ax4.plot(np.arange(5,155,10), rain_real_a1_, label='CTRL', color='blue', marker='^', linewidth=1.5,  markersize=4.0)
ax4.plot(np.arange(5,155,10), rain_pgw_a1_, label='PGW', color='red', marker='s', linewidth=1.5,  markersize=4.0)
ax4.set_xticks([5, 10, 20, 50, 100])
ax4.get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
ax4.legend(loc='best', fontsize=12.5)
ax4.text(5, 0.08, '(d)', fontsize = 15, backgroundcolor='white')
ax4.text(2.5, 0.02, 'Hourly  rainfall', fontsize = 16, rotation = 'vertical', fontweight='semibold')


ax5.set_xlim(4.5,185)
ax5.set_ylim(0.0,0.82)
ax5.set_xscale('log')
ax5.tick_params(axis='both',labelsize=12,direction='out',length=5.0,width=1.3,right=True,top=False) 
ax5.plot(np.arange(5,185,10), rain_real_a2_, label='CTRL', color='blue', marker='^', linewidth=1.5,  markersize=4.0)
ax5.plot(np.arange(5,185,10), rain_pgw_a2_, label='PGW', color='red', marker='s', linewidth=1.5,  markersize=4.0)
ax5.set_xticks([5, 10, 20, 50, 100])
ax5.get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
ax5.text(5, 0.08, '(e)', fontsize = 15, backgroundcolor='white')


ax6.set_xlim(4.5,195)
ax6.set_ylim(0.0,0.82)
ax6.set_xscale('log')
ax6.tick_params(axis='both',labelsize=12,direction='out',length=5.0,width=1.3,right=True,top=False) 
ax6.plot(np.arange(5,195,10), rain_real_a3_, label='CTRL', color='blue', marker='^', linewidth=1.5,  markersize=4.0)
ax6.plot(np.arange(5,195,10), rain_pgw_a3_, label='PGW', color='red', marker='s', linewidth=1.5,  markersize=4.0)
ax6.set_xticks([5, 10, 20, 50, 100])
ax6.get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
ax6.text(5, 0.08, '(f)', fontsize = 15, backgroundcolor='white')







plt.savefig('/home/lzhenn/array74/coop_fenying/7_article_FIG/Fig2_rainfall_pdf.pdf', dpi=200, bbox_inches='tight')  #+FIG_FMT
plt.close('all')


