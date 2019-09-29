#! /usr/bin/env python
#  Deal with 59287 station data 
#   
#               L_Zealot
#               Jul 17, 2019
#               Guangzhou, GD
#

import math
import os
import numpy as np
import pandas as pd
import datetime

#-------------------------------------
# Function Definition Part
#-------------------------------------
def main():

#----------------------------------------------------
# User Defined Part
#----------------------------------------------------

    # Station Number
    sta_num='59287'

    # Input File
    in_dir='/disk/hq247/yhuangci/lzhenn/data/station/post/'

    # Output File
    out_dir='../testdata/'

    # Start Year 
    start_years=[1957, 1996, 2011]
    
    # End Year
    end_year=2018

    # Var Name 
    var_name='TEM' 

    # Time period for calculating climatology
    clim_range=[1981, 2010]

#----------------------------------------------------
# Main function
#----------------------------------------------------
    fs_handl=os.walk(in_dir) 
    for path,dir_list,file_list in fs_handl:  
        for file_name in file_list:  
            infile=os.path.join(path, file_name)
            print('parser '+file_name)
            pt=pd.read_csv(infile, sep='\s+', header=None, names=['station', 'lat', 'lon', 'alt', 'year', 'month', 'day', 'avg_temp', 'max_temp', 'min_temp', 'avg_code', 'max_code', 'min_code'])
            sample_pt=pt[pt.year >= start_years[0]]
            sample_pt=reform_df(sample_pt)
    
            clim_df=cal_climatology(sample_pt, clim_range)
            
            # below for calculate monthly dmean values
            sample_pt=sample_pt.resample('M').mean()
            ii=0
            fn_pt=pd.DataFrame()
            for name, group in  sample_pt.groupby(sample_pt.index.month):   # group by month
                fn_pt=pd.concat([fn_pt, group.apply(lambda x: x-clim_df.iloc[ii,:], axis=1)])
                ii=ii+1
            print('write '+out_dir+'label_'+file_name)
            fn_pt.sort_values(by='time').to_csv(out_dir+'label_'+file_name)
    exit() 
    df0=combine_mon_anom(sample_pt0, sample_pt1, sample_pt2)
    df0[df0.index.year<2017].to_csv(out_dir)
    

def cal_climatology(df, clim_range):
    clim_df=df[(df.index.year>=clim_range[0]) & (df.index.year<=clim_range[1])]
    clim_df_season = clim_df.groupby(clim_df.index.month).mean() # climatological seasonal cycle
    return clim_df_season



def combine_mon_anom(*args):
    df=pd.DataFrame()
    for item in args:
        df_temp=reform_df(item)    
        df_temp=df_temp.resample('M').mean()
        df_temp=df_temp.to_period()
        df_anom, df_season=dcomp_seasonality(df_temp)
        df=pd.concat([df, df_anom])
    return df

def reform_df(pt):
    """
    reform df style:
    time             avg_temp  max_temp  min_temp
    2018-07-23       270       320       250
    """
    date_range=pd.to_datetime(pt.loc[:,['year','month','day']])
    df =pd.DataFrame(pt.loc[:,['avg_temp', 'max_temp', 'min_temp']].values, index=date_range, columns=['avg_temp', 'max_temp', 'min_temp'])
    df.index.set_names('time', inplace=True)
    return df

   
def dcomp_seasonality(df):
    df_season = df.groupby(df.index.month).mean() # climatological seasonal cycle
    print(df)
    df = df.groupby(df.index.month).transform(lambda x: (x-x.mean())) # calculate monthly anomaly
    #df = df.groupby(df.index.month).transform(lambda x: (x-x.mean())/x.std()) # calculate monthly anomaly
    return df, df_season


if __name__ == "__main__":
    main()




