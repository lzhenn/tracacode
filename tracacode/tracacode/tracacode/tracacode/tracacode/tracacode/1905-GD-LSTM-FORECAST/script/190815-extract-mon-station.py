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
    in_dir='/home/lzhenn/array2/lzhenn/station/post/'

    # Output File
    out_dir='../testdata/label.csv'

    # Start Year 
    start_years=[1957, 1996, 2011]
    
    # End Year
    end_year=2018

    # Var Name 
    var_name='TEM' 

#----------------------------------------------------
# Main function
#----------------------------------------------------
    
    pt=pd.read_csv(in_dir+sta_num+var_name+'.txt', sep='\s+', header=None, names=['station', 'lat', 'lon', 'alt', 'year', 'mon', 'day', 'avg_temp', 'max_temp', 'min_temp', 'avg_code', 'max_code', 'min_code'])
    sample_pt=pt[pt.year >= start_years[0]]
    sample_pt0=sample_pt[sample_pt.year < start_years[1]]
    sample_pt1=sample_pt[sample_pt.year >= start_years[1]]
    sample_pt1=sample_pt1[sample_pt1.year < start_years[2]]
    sample_pt2=sample_pt[sample_pt.year >= start_years[2]]
    df0=combine_mon_anom(sample_pt0, sample_pt1, sample_pt2)
    df0[df0.index.year<2017].to_csv(out_dir)

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
    start_time=str(pt.iloc[0]['year'])+'-'+str(pt.iloc[0]['mon'])+'-'+str(pt.iloc[0]['day'])
    end_time=str(pt.iloc[-1]['year'])+'-'+str(pt.iloc[-1]['mon'])+'-'+str(pt.iloc[-1]['day'])
    date_range = pd.date_range(start=start_time, end=end_time)
    df =pd.DataFrame(pt.loc[:,['avg_temp', 'max_temp', 'min_temp']].values, index=date_range, columns=[ 'avg_temp', 'max_temp', 'min_temp'])
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




