#!/usr/bin/python
# -*- coding: UTF-8 -*-
#   Fetch HYCOM data from HYCOM ftp
# 
#       L_Zealot
#       Jan 06, 2018
#
#

'''
https://ncss.hycom.org/thredds/ncss/GLBy0.08/expt_93.0/FMRC/runs/GLBy0.08_930_FMRC_RUN_
2020-12-29T12:00:00Z?var=salinity&north=23.0000&west=110.0000&east=120.9200&south=10.0000&disableProjSubset=on&horizStride=1&time=2021-01-06T00%3A00%3A00Z&vertCoord=&addLatLon=true&accept=netcdf4
'''

import os, sys
import json
import requests
import numpy as np
import datetime

#----------------------------------------------------
# User Defined Part
#----------------------------------------------------
def main():
    # arguments in
    args=sys.argv
    # init time
    g_init_time=args[1]
    # output dir
    fout_dir=args[2]
    
    # tframes
    tfrms=np.arange(0,8)

    
    # parser
    int_time_obj = datetime.datetime.strptime(g_init_time, '%Y%m%d')

    # URL base str for forecast data
    url_base='https://ncss.hycom.org/thredds/ncss/GLBy0.08/expt_93.0/FMRC/runs/GLBy0.08_930_FMRC_RUN_'+int_time_obj.strftime('%Y-%m-%d')+'T12:00:00Z?'
    url_var_range='var=surf_el&var=salinity&var=water_temp&var=water_u&var=water_v&north=30.0000&west=100.0000&east=130&south=10.0000&horizStride=1'
    url_tail='T12%3A00%3A00Z&vertCoord=&addLatLon=true&accept=netcdf4'

    # CONSTANTS for MATLAB
    var_list=['2d','ts3z','3zt','3zs','uv3z','3zu','3zv']

    
    for ifrm in tfrms:
        curr_filetime=int_time_obj+datetime.timedelta(days=int(ifrm))
        print('>>>>ROMS: Download %s...' % (curr_filetime.strftime('%Y%m%d')), end='')
        url_time='&time='+curr_filetime.strftime('%Y-%m-%d')
        url=url_base+url_var_range+url_time+url_tail
        print(url)
        rqst=requests.get(url)

        fn='hycom_glby_930_%s12_t%03d.nc' % (int_time_obj.strftime('%Y%m%d'), ifrm*24)
        if rqst.status_code == 200:
            f = open(fout_dir+fn, 'wb')
            f.write(rqst.content)
            f.close()
        print(rqst.status_code)
        # loop var list
        for itm in var_list:
            # convert the filename to maintain legacy matlab style
            fn_symb='archv.'+curr_filetime.strftime('%Y')+'_'+curr_filetime.strftime('%j')+'_12_'+itm+'.nc'
            os.system('ln -sf '+fout_dir+'/'+fn+' '+fout_dir+'/'+fn_symb)
            #break

    os.system('ln -sf '+fout_dir+'/'+fn+' '+fout_dir+'/hycom.grid.exp930.nc')
    print('>>>>ROMS: HYCOM DATA ARCHIVED SUCCESSFULLY!!!')
    
if __name__ == "__main__":
    main()



