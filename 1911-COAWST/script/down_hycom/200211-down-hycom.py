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
    g_exp='GLBa'
    
    # init time
    g_init_time='20180913'
    
    # end time
    g_end_time='20180913'
    
    # output dir
    fout_dir='/users/b145872/project-dir/data/hycom'



    # CONSTANTS
    VAR_LIST=[('2d','2d'),('salt','s'),('temp','t'),('uvel','u'),('vvel','v')]


    # parser
    int_time_obj = datetime.datetime.strptime(g_init_time, '%Y%m%d')
    end_time_obj = datetime.datetime.strptime(g_end_time, '%Y%m%d')
    
    df_exp_info   =  pd.read_csv('hycom_list.txt',index_col='exp_name', parse_dates=True, sep='\s+')

    file_time_delta=datetime.timedelta(hours=24)

    curr_filetime=int_time_obj
    while curr_filetime <= end_time_obj:
        print(curr_filetime.strftime('Download %Y%m%d%HZ...'))

        # find exp binding
        for idx, itm in df_exp_info.iterrows():
            if curr_filetime>=datetime.datetime.strptime(itm['date_strt'],'%Y-%m-%d') and curr_filetime<=datetime.datetime.strptime(itm['date_end'],'%Y-%m-%d') and g_exp == itm['exp_series']:
                url_base='ftp://ftp.hycom.org/datasets/GLBa0.08/'+idx+'/'+curr_filetime.strftime('%Y')

        # loop var list
        for itm in VAR_LIST:
            if itm[0] == '2d':
                fn='archv.'+curr_filetime.strftime('%Y')+'_'+curr_filetime.strftime('%j')+'_00_'+itm[1]+'.nc'
            else:
                fn='archv.'+curr_filetime.strftime('%Y')+'_'+curr_filetime.strftime('%j')+'_00_3z'+itm[1]+'.nc'
            url=url_base+'/'+itm[0]+'/'+fn
            print(url)
            os.system('wget '+url+' -O'+' '+fout_dir+'/'+fn)
            #break
        # next day
        curr_filetime=curr_filetime+file_time_delta
    
if __name__ == "__main__":
    main()



