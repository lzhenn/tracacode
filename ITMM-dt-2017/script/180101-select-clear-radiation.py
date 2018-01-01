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
    sta_num='67605'

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

#----------------------------------------------------
# Main function
#----------------------------------------------------
    
    
    select_pt=pd.read_csv(select_dir+"Dubovik_stats_Panyu_20131220-dengtao1.csv")
    time_delta=datetime.timedelta(hours=8)
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
        try:
            pt=pd.read_csv(in_dir+get_file_name(sta_num, date_obj, corr_algthm), parse_dates=True, skiprows=1, names=['time','uva','uvb','total'], index_col='time')
            with open(out_dir+'selected_min.csv', 'a') as f:
                pt.loc[date_obj].to_csv(f)
        except:
            print(date_obj.strftime('%Y-%m-%d %H:%M:%S')+' failed')
    
    exit()

def get_file_name(sta_num, timestmp, corr):
    time0=timestmp.strftime('%Y%m%d')   
    fname='Rad_'+time0+'_'+sta_num+'_'+corr+'_Min.csv'
    return fname


def get_outfile_name(sta_num, corr, item):
    fname='Rad_clear_'+sta_num+'_'+corr+'_'+str(item)+'H.csv'
    return fname

def reorg_rad(pt):
    pt_use=pt[pt.index.hour>=10]
    pt_use=pt_use[pt_use.index.hour<=16]
    pt_use_max=pt_use.resample('D').max()
    return pt_use, pt_use_max 

if __name__ == "__main__":
    main()




