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
    in_dir='/home/yangsong3/L_Zealot/project/ITMM-dt-2017/data/ITMM-dt-2017/17-18new/'+sta_num+'/splined/pro_data/'
    
    # Output Dir
    out_dir=in_dir
 
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
    pt=pd.read_csv(in_dir+get_file_name(sta_num, corr_algthm), parse_dates=True, skiprows=1, names=['time','uva','uvb','total'], index_col='time')
    print('parsing '+in_dir+get_file_name(sta_num, corr_algthm))
    pt_use, pt_use_max=reorg_rad(pt)
    for item in [10,12,14,16]:
        with open(out_dir+get_outfile_name(sta_num, corr_algthm, item), 'w') as f:
            pt_use[pt_use.index.hour==item].to_csv(f)
    with open(out_dir+get_outfile_name_max(sta_num, corr_algthm, 'max'), 'w') as f:
        pt_use_max.to_csv(f)

def get_file_name(sta_num,  corr):
    fname='Rad_'+sta_num+'_'+corr+'_Hourly.csv'
    return fname

def get_outfile_name(sta_num, corr, item):
    fname='Rad_'+sta_num+'_'+corr+'_'+str(item)+'H.csv'
    return fname

def get_outfile_name_max(sta_num, corr, item):
    fname='Rad_'+sta_num+'_'+corr+'_'+item+'_daily.csv'
    return fname


def reorg_rad(pt):
    pt_use=pt[pt.index.hour>=10]
    pt_use=pt_use[pt_use.index.hour<=16]
    pt_use_max=pt_use.resample('D').max()
    return pt_use, pt_use_max 

if __name__ == "__main__":
    main()




