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

    # Output Dir
    out_dir='../data/ITMM-dt-2017/'+sta_num+'/splined/'
 
    # Start Year 
    start_year='2012'
    
    # End Year
    end_year='2017'

    # Correct Algrithm
    #   C1 -- Both j and splined
    #   C2 == Only j
    corr_algthm='C1' 

#----------------------------------------------------
# Main function
#----------------------------------------------------
    curr_year=start_year
    while curr_year<=end_year:
        start_time=curr_year+'-01-01 00:00:00'
        end_time=curr_year+'-12-31 23:59:00'
        
        int_time_obj = datetime.datetime.strptime(start_time, '%Y-%m-%d %H:%M:%S')
        end_time_obj = datetime.datetime.strptime(end_time, '%Y-%m-%d %H:%M:%S')
        
        file_time_delta=datetime.timedelta(days=1)
        curr_time_obj=int_time_obj

        while curr_time_obj <= end_time_obj:
            try:
                pt=pd.read_csv(in_dir+get_file_name(sta_num, curr_time_obj, corr_algthm))
            except:
                curr_time_obj=curr_time_obj+file_time_delta
                continue
            print('parsing '+in_dir+get_file_name(sta_num, curr_time_obj, corr_algthm))
            r_uva, r_uvb, r_total=cal_rad(pt)
            dfout = pd.DataFrame(np.append([r_uva.values, r_uvb.values], [r_total.values], axis=0).T, index=pt.iloc[:,0], columns=['uva', 'uvb', 'total'])
            
            with open(out_dir+get_outfile_name(sta_num, curr_time_obj, corr_algthm), 'w') as f:
                dfout.to_csv(f)
            curr_time_obj=curr_time_obj+file_time_delta

        curr_year=str(int(curr_year)+1)

def get_file_name(sta_num, timestmp, corr):
    time0=timestmp.strftime('%Y%m%d')   
    fname='splined_'+time0+'_'+sta_num+'_'+corr+'_Min.csv'
    return fname


def get_outfile_name(sta_num, timestmp, corr):
    time0=timestmp.strftime('%Y%m%d')   
    fname='Rad_'+time0+'_'+sta_num+'_'+corr+'_Min.csv'
    return fname

def cal_rad(pt):
    uva=pt.loc[:,'320.0':'422.0'].sum(axis=1)*0.5
    uvb=pt.loc[:,'290.0':'320.0'].sum(axis=1)*0.5
    total=pt.sum(axis=1)*0.5
    return uva, uvb, total




if __name__ == "__main__":
    main()




