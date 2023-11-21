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
var = 'RAINNC'
dom_id='d02'
for case in cases:
    fn_stream=subprocess.check_output(
        'ls '+sen_path+'/'+case+'/wrfout_'+dom_id+'*', shell=True).decode('utf-8')
    fn_list=fn_stream.split()
    wrf_file=Dataset(fn_list[-1])
    wrf_list=[Dataset(itm) for itm in fn_list[-96:]]
        
    var_sen=wrf.getvar(
        wrf_file,var,timeidx=wrf.ALL_TIMES, method='cat')

    var_sen_all=wrf.getvar(
        wrf_file,var,timeidx=wrf.ALL_TIMES, method='cat')
    var_sen_all=var_sen_all[1:,:,:]-var_sen_all[:-1,:,:]

    fn_stream=subprocess.check_output(
        'ls '+ctrl_path+'/'+case+'/wrfout_'+dom_id+'*', shell=True).decode('utf-8')
    fn_list=fn_stream.split()
    wrf_file=Dataset(fn_list[-1])
    wrf_list=[Dataset(itm) for itm in fn_list[-96:]]
        
    var_ctrl=wrf.getvar(
        wrf_file,var,timeidx=wrf.ALL_TIMES, method='cat')

    var_ctrl_all=wrf.getvar(
        wrf_file,var,timeidx=wrf.ALL_TIMES, method='cat')
    var_ctrl_all=var_ctrl_all[1:,:,:]-var_ctrl_all[:-1,:,:]


    var_sen_all=var_sen_all.where(var_sen_all>0.1)
    var_ctrl_all=var_ctrl_all.where(var_ctrl_all>0.1)

    var_sen=var_sen.where(var_sen>1.0)
    var_ctrl=var_ctrl.where(var_ctrl>1.0)
    print('---mean---')
    print(case+' pgw:%5.1f' % var_sen.mean(dim='south_north',skipna=True).mean(dim='west_east',skipna=True).values)
    print(case+' ctrl:%5.1f' % var_ctrl.mean(dim='south_north',skipna=True).mean(dim='west_east',skipna=True).values)

    print(np.count_nonzero(var_sen>200.0)/np.count_nonzero(var_sen>1.0))
    print(np.count_nonzero(var_ctrl>200.0)/np.count_nonzero(var_ctrl>1.0))

    print('---percentile---')
    print(case+' pgw:%5.1f' % np.nanpercentile(var_sen,99.9))
    print(case+' ctrl:%5.1f' % np.nanpercentile(var_ctrl,99.9))

    print('---hourly_rain_rate---')