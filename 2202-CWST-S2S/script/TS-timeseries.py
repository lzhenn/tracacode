from netCDF4 import Dataset
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
matplotlib.use('Agg') 

import os, subprocess
import wrf


#from wrf import combine_files, getvar, get_cartopy, latlon_coords, cartopy_xlim, cartopy_ylim, to_np

# Constants
BIGFONT=22
MIDFONT=18
SMFONT=14



REF_DIR='/home/lzhenn/cooperate/data/case_study/wrfonly/2020060412/'
SEN_DIR='/home/lzhenn/cooperate/data/case_study/coupled/2020060412/'

varname='SST'
# Open the NetCDF file
fn_stream=subprocess.check_output('ls '+SEN_DIR+'wrfout_d01_*', shell=True).decode('utf-8')
fn_list=fn_stream.split()
wrf_list=[Dataset(itm) for itm in fn_list]
times=wrf.extract_times(
    wrf_list, timeidx=wrf.ALL_TIMES, meta=True)
times=times+np.timedelta64(132,'D')

var_temp=wrf.getvar(wrf_list[0],varname)
var_sen = wrf.getvar(wrf_list, varname, timeidx=wrf.ALL_TIMES, method='cat')
var_sen=var_sen[:,65:105,115:215].mean(dim='south_north')
var_sen=var_sen.mean(dim='west_east')
var_sen=var_sen-275.15
var_sen['Time']=var_sen['Time']
fn_stream=subprocess.check_output('ls '+REF_DIR+'wrfout_d01_*', shell=True).decode('utf-8')
fn_list=fn_stream.split()
wrf_list=[Dataset(itm) for itm in fn_list]
var_temp=wrf.getvar(wrf_list[0],varname)
var_ref = wrf.getvar(wrf_list, varname, timeidx=wrf.ALL_TIMES, method='cat')
var_ref=var_ref[:,65:105,115:215].mean(dim='south_north')
var_ref=var_ref.mean(dim='west_east')
var_ref=var_ref-275.15



# figure
fig,ax = plt.subplots()
width=14.0
height=6.0
#fig,ax = plt.subplots(figsize=(10,4))

# adjust to fit in the canvas 
fig.subplots_adjust(left=0.08, bottom=0.18, right=0.99, top=0.92, wspace=None, hspace=None) 

plt.plot(
    times, var_sen,  
    label='Coupled', linewidth=3, marker='o', color='blue')

plt.plot(
    times, var_ref,  
    label='WRFONLY', linewidth=3, marker='o', color='red')
plt.legend(loc='best', fontsize=SMFONT)
plt.xlabel('Time',fontsize=SMFONT)
plt.ylabel('SST ($\mathregular{^oC}$)',fontsize=SMFONT)
plt.xticks(fontsize=SMFONT,rotation=-30)
plt.yticks(fontsize=SMFONT)

# pletp(ax.get_xticklabels(), rotation=-60, ha="right",
# rotation_mode="anchor")
plt.title('SST Timeseries', fontsize=BIGFONT)
#    fig.tight_layout()
#    plt.show()
fig.set_size_inches(width, height)

plt.savefig('../fig/sst.png', dpi=120, bbox_inches='tight')
