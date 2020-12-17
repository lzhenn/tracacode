#!/usr/bin/python
# -*- coding: UTF-8 -*-
#   Fetch HYCOM data from HYCOM ftp
# 
#       L_Zealot
#       Jan 06, 2018
#
#

'''
ftp://ftp.hycom.org/datasets/GLBa0.08/expt_91.2/2018/uvel
rchv.2018_258_00_3zt.nc

ftp://ftp.hycom.org/datasets/GLBy0.08/expt_93.0/data/hindcasts/2020/hycom_glby_930_2020010112_t000_ts3z.nc
hycom_glby_930_2020010112_t000_uv3z.nc
hycom_glby_930_2020010112_t000_ssh.nc
'''

import os
import json

import numpy as np
import pandas as pd
import datetime

#----------------------------------------------------
# User Defined Part
#----------------------------------------------------
def main():
    # exp series
    g_exp='GLBy'
    
    # init time
    g_init_time='20201027'
    
    # end time
    g_end_time='20201102'
    
    # output dir
    fout_dir='/home/metctm1/array/data/hycom'



    # CONSTANTS
    VAR_LIST=[{'ssh':['2d']},{'ts3z':['3zt','3zs']},{'uv3z':['3zu','3zv']}]


    # parser
    int_time_obj = datetime.datetime.strptime(g_init_time, '%Y%m%d')
    end_time_obj = datetime.datetime.strptime(g_end_time, '%Y%m%d')
    
    df_exp_info   =  pd.read_csv('hycom_list.txt',index_col='exp_name', parse_dates=True, sep='\s+')

    file_time_delta=datetime.timedelta(hours=24)

    curr_filetime=int_time_obj
    while curr_filetime <= end_time_obj:
        print(curr_filetime.strftime('Download %Y%m%d%HZ...'))

        # find exp binding
        if curr_filetime>=datetime.datetime.strptime(itm['date_strt'],'%Y-%m-%d') and curr_filetime<=datetime.datetime.strptime(itm['date_end'],'%Y-%m-%d'):
            url_base='ftp://ftp.hycom.org/datasets/GLBy0.08/expt_93.0/data/hindcasts/'+curr_filetime.strftime('%Y')
        # loop var list
        for itm in VAR_LIST:
                +'/hycom_glby_930_2020010112_t000_ts3z.nc'
                fn='hycom_glby_930_'+curr_filetime.strftime('%Y%m%d')+'_t000_'+itm+'.nc'
            url=url_base+'/'+itm[0]+'/'+fn
            print(url)
            os.system('wget '+url+' -O'+' '+fout_dir+'/'+fn)

            #break
        # next day
        curr_filetime=curr_filetime+file_time_delta
    
if __name__ == "__main__":
    main()



