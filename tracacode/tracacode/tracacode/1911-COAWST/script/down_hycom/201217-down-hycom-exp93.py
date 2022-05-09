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
    fout_dir='/users/b145872/project-dir/data/hycom/goni/'



    # CONSTANTS
    var_dic={'ssh':['2d'],'ts3z':['3zt','3zs'],'uv3z':['3zu','3zv']}


    # parser
    int_time_obj = datetime.datetime.strptime(g_init_time, '%Y%m%d')
    end_time_obj = datetime.datetime.strptime(g_end_time, '%Y%m%d')
    
    df_exp_info   =  pd.read_csv('hycom_list.txt',index_col='exp_name', parse_dates=True, sep='\s+')

    file_time_delta=datetime.timedelta(hours=24)

    curr_filetime=int_time_obj
    while curr_filetime <= end_time_obj:
        print(curr_filetime.strftime('Download %Y%m%d%HZ...'))

        # find exp binding
        url_base='ftp://ftp.hycom.org/datasets/GLBy0.08/expt_93.0/data/hindcasts/'+curr_filetime.strftime('%Y')
        
        # loop var list
        for key, values in var_dic.items():
            fn='hycom_glby_930_'+curr_filetime.strftime('%Y%m%d')+'12_t000_'+key+'.nc'
            url=url_base+'/'+fn
            print(url)
            os.system('wget '+url+' -O'+' '+fout_dir+'/'+fn)

            for symb in values:
                fn_symb='archv.'+curr_filetime.strftime('%Y')+'_'+curr_filetime.strftime('%j')+'_00_'+symb+'.nc'
                os.system('ln -sf '+fout_dir+'/'+fn+' '+fout_dir+'/'+fn_symb)

            #break
        # next day
        curr_filetime=curr_filetime+file_time_delta
    
if __name__ == "__main__":
    main()



