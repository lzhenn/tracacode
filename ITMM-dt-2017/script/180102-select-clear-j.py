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
    in_dir='../data/ITMM-dt-2017/'+sta_num+'/J/'

    # Select Source 
    select_dir='../data/ITMM-dt-2017/clear-time/'

    # Output Dir
    out_dir='../data/ITMM-dt-2017/'+sta_num+'/J/pro_data/selected/'
    
    # Species
    species=['H2O2','HCHO_M','HCHO_R','HONO','NO3_M','NO3_R','NO2','O1D']
    

    # Correct Algrithm
    #   C1 -- Both j and splined
    #   C2 == Only j
    corr_algthm='C2' 

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


        pd_date=pd.date_range(date_obj, periods=1)
        data0=np.zeros((1,len(species)))
        data0.fill(np.nan)
        ptout=pd.DataFrame(data0, index=pd_date, columns=species)
        for pos, spe in enumerate(species):
            try:
                pt=pd.read_csv(in_dir+get_file_name(sta_num, date_obj, corr_algthm, spe), parse_dates=True, skiprows=1, names=['time',spe], index_col='time')
                ptout[spe][0]=pt.loc[date_obj.strftime('%Y-%m-%d %H:%M:%S')].values
            except:
                print(date_obj.strftime('%Y-%m-%d %H:%M:%S')+' '+spe+' failed')
        with open(out_dir+'selected_min_'+corr_algthm+'.csv', 'a') as f:
            ptout.to_csv(f, header=False)

def get_file_name(sta_num, timestmp, corr, spe):
    time0=timestmp.strftime('%Y%m%d')   
    fname='j'+spe+'_'+time0+'_'+sta_num+'_'+corr+'_Min.csv'
    return fname

if __name__ == "__main__":
    main()




