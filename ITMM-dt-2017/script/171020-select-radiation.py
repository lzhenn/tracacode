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
    in_dir='../data/ITMM-dt-2017/'+sta_num+'/splined/pro_data/'

    # Output Dir
    out_dir='../data/ITMM-dt-2017/'+sta_num+'/splined/pro_data/'
 
    # Start Year 
    start_year='2011'
    
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

        pt=pd.read_csv(in_dir+get_file_name(sta_num, curr_year, corr_algthm), parse_dates=True, skiprows=1, names=['time','uva','uvb','total'], index_col='time')
        print('parsing '+in_dir+get_file_name(sta_num, curr_year, corr_algthm))
        uva, uvb, total=reorg_rad(pt)

        exit()
        dfout = pd.DataFrame(np.append([r_uva.values, r_uvb.values], [r_total.values], axis=0).T, index=pt.iloc[:,0], columns=['uva', 'uvb', 'total'])
        with open(out_dir+get_outfile_name(sta_num, curr_year, corr_algthm), 'w') as f:
            dfout.to_csv(f)
        curr_year=str(int(curr_year)+1)

def get_file_name(sta_num, curr_year, corr):
    fname='Rad_'+curr_year+'_'+sta_num+'_'+corr+'_Hour.csv'
    return fname

def get_outfile_name(sta_num, curr_year, corr):
    fname='Rad_'+curr_year+'_'+sta_num+'_'+corr+'_Daily.csv'
    return fname

def reorg_rad(pt):
    pt_use=pt[pt.index.hour>=10]
    pt_use=pt_use[pt_use.index.hour<=16]
    pt_use0=pt_use.resample('D').max()
    pt_use_max=pt_use.resample('D').max()
    pt_use_max=pt_use.resample('D').max()
    pt_use['max_uva']=pt_use.index.strftime('%y%m%d')
    return uva, uvb, total

if __name__ == "__main__":
    main()




