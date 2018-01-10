#! /usr/bin/env python
#  Deal with splined data 
#   
#               L_Zealot
#               Oct 16, 2017
#               Guangzhou, GD
#
import math
import os
import numpy as np
import pandas as pd
import datetime
import decimal
#-------------------------------------
# Function Definition Part
#-------------------------------------
def main():

#----------------------------------------------------
# User Defined Part
#----------------------------------------------------

    # Station Number
    sta_num='67606'

    # Input File
    in_dir='../data/ITMM-dt-2017/'+sta_num+'/splined/'

    # Select Source 
    select_dir='../data/ITMM-dt-2017/clear-time/'

    # Output Dir
    out_dir='../data/ITMM-dt-2017/'+sta_num+'/splined/pro_data/selected/'
 
    # Correct Algrithm
    #   C1 -- Both j and splined
    #   C2 == Only j
    corr_algthm='C1' 
    
    # Time range (min)
    delta_time=7


#----------------------------------------------------
# Main function
#----------------------------------------------------
    
    
    select_pt=pd.read_csv(select_dir+"Dubovik_stats_Panyu_20131220-dengtao1.csv")
    time_delta=datetime.timedelta(hours=8) # for UTC2BJT
    avg_delta=datetime.timedelta(minutes=delta_time)
    for item in select_pt.index:
        yyyy=int(select_pt.iloc[item]['year'])
        mm=int(select_pt.iloc[item]['mm'])
        dd=int(select_pt.iloc[item]['dd'])
        HH=int(select_pt.iloc[item]['hh'])
        MM=int(select_pt.iloc[item]['MM'])
        SS=int(select_pt.iloc[item]['ss'])
        date_str=str(yyyy)+'-'+str(mm)+'-'+str(dd)+' '+str(HH)+':'+str(MM)
        date_obj=datetime.datetime.strptime(date_str, '%Y-%m-%d %H:%M') # UTC
        date_obj=date_obj+time_delta


        pd_date=pd.date_range(date_obj, periods=1)
        try:
            pt=pd.read_csv(in_dir+get_file_name(sta_num, date_obj, corr_algthm), parse_dates=True, skiprows=1, names=['time','uva','uvb','total'], index_col='time')
            ptout=pt.loc[date_obj-avg_delta:date_obj+avg_delta].mean()
        except:
            print(date_obj.strftime('%Y-%m-%d %H:%M:%S')+' failed')
            ptout=pd.DataFrame(np.array([np.nan, np.nan, np.nan]).reshape(1,3), index=pd_date, columns=['uva','uvb','total'])
        
        with open(out_dir+'selected_min.csv', 'a') as f:
            values=ptout.values
            if len(values)==3:
                values=values.reshape(1,3)
                ptout=pd.DataFrame(values, index=pd_date, columns=['uva','uvb','total'])
            ptout.to_csv(f, header=False)
def get_file_name(sta_num, timestmp, corr):
    time0=timestmp.strftime('%Y%m%d')   
    fname='Rad_'+time0+'_'+sta_num+'_'+corr+'_Min_Clean.csv'
    return fname

if __name__ == "__main__":
    main()




