#! /usr/bin/env python
#   Try sklearn lasso model 
#   
#               L_Zealot
#               Aug 16, 2019
#               Guangzhou, GD
#

import os
import json

import numpy as np
import pandas as pd
import matplotlib
#matplotlib.use('Agg') 
import matplotlib.pyplot as plt
import datetime
from matplotlib.pyplot import savefig


#----------------------------------------------------
# User Defined Part
#----------------------------------------------------
def dis_latlon(lat0, lon0, lat1, lon1, deg_flag):
    '''
        Calculate Haversine formula: 
        the great-circle distance between two points 
        on a sphere given their longitudes and latitudes
    '''
    R=6371.
    if deg_flag:
        [lat0, lon0, lat1, lon1] = [itm*np.pi/180 for itm in [lat0, lon0, lat1, lon1]]
    p1=np.sin((lat1-lat0)/2)**2
    p2=np.cos(lat0)*np.cos(lat1)*np.sin((lon1-lon0)/2)**2
    dis=2*R*np.arcsin(np.sqrt(p1+p2))
    return dis

def main():
    
    BIGFONT=22
    MIDFONT=18
    SMFONT=16
    casename='mangkhut' 
    
    cases=["FNL1d_TY2001", "FNL1d_WRF","ERA5_TY2001", "ERA5_C2008","ERA5_WAOFF",
            "ERA5_WRF","FNL0d25_C2008", "FNL0d25_WRFROMS", "FNL0d25_WRF"]

    wrf_root='/disk/v092.yhuangci/lzhenn/1911-COAWST/'
    best_trck_path='/disk/v092.yhuangci/lzhenn/1911-COAWST/cma.trck.mangkhut'
    
    strt_time_str='201809150600'
    end_time_str='201809170000'
    strt_time_obj=datetime.datetime.strptime(strt_time_str, '%Y%m%d%H%M')
    end_time_obj=datetime.datetime.strptime(end_time_str, '%Y%m%d%H%M')

    dateparse = lambda x: pd.datetime.strptime(x, '%Y%m%d%H')   
    df_obv=pd.read_csv(best_trck_path,parse_dates=True,index_col='time', sep='\s+', date_parser=dateparse)
    df_obv_period=df_obv[((df_obv.index>=strt_time_obj)&(df_obv.index<=end_time_obj))]

    dateparse = lambda x: pd.datetime.strptime(x, '%Y%m%d%H%M%S')   
    for case in cases:
        case_path=wrf_root+case+'/trck.'+case+'.d02'
        df_case=pd.read_csv(case_path,parse_dates=True,index_col='timestamp', sep='\s+', date_parser=dateparse)
        df_case_period=df_case[((df_case.index>=strt_time_obj)&(df_case.index<=end_time_obj))]
        idx_case_obv=df_case_period.index.intersection(df_obv_period.index)
        dis_list=[]
        for ix in idx_case_obv:
            dis_list.append(dis_latlon(lat0=df_obv_period.loc[ix]['lat']/10,
            lon0=df_obv_period.loc[ix]['lon']/10,lat1=df_case_period.loc[ix]['lat'],
            lon1=df_case_period.loc[ix]['lon'],deg_flag=True))
        print(sum(dis_list)/idx_case_obv.size)
if __name__ == "__main__":
    main()



