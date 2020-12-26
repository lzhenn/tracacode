#!/usr/bin/python
# -*- coding: UTF-8 -*-
#   Fetch HYCOM data from HYCOM ftp
# 
#       L_Zealot
#       Jan 06, 2018
#
#

'''
ftp://ftp.hycom.org/datasets/GLBy0.08/expt_93.0/data/forecasts/hycom_glby_930_2020121912_t000_ssh.nc
000-180
'''

import os
import json

import numpy as np
import datetime

#----------------------------------------------------
# User Defined Part
#----------------------------------------------------
def main():
    # exp series
    g_exp='GLBy'
    
    # init time
    g_init_time='20201219'
    
    # tframes
    tfrms=np.arange(0,8)*24
    # URL base str for forecast data
    url_base='ftp://ftp.hycom.org/datasets/GLBy0.08/expt_93.0/data/forecasts/'        
    
    # output dir
    fout_dir='/home/metctm1/array/data/GBA_operational/hycom/'


    # CONSTANTS
    var_dic={'ssh':['2d'],'ts3z':['3zt','3zs'],'uv3z':['3zu','3zv']}


    # parser
    int_time_obj = datetime.datetime.strptime(g_init_time, '%Y%m%d')
    
    for ifrm in tfrms:
        curr_filetime=int_time_obj+datetime.timedelta(hours=int(ifrm))
        print('Download %s+%03dH...' % (curr_filetime.strftime('%Y%m%d%HZ'), ifrm))

        # loop var list
        for key, values in var_dic.items():
            fn='hycom_glby_930_%s12_t%03d_%s.nc' % (int_time_obj.strftime('%Y%m%d'), ifrm, key)
            url=url_base+'/'+fn
            print(url)
            os.system('wget '+url+' -O'+' '+fout_dir+fn)

            # convert the filename to maintain legacy matlab style
            for symb in values:
                fn_symb='archv.'+curr_filetime.strftime('%Y')+'_'+curr_filetime.strftime('%j')+'_12_'+symb+'.nc'
                os.system('ln -sf '+fout_dir+'/'+fn+' '+fout_dir+'/'+fn_symb)

            #break
    
if __name__ == "__main__":
    main()



