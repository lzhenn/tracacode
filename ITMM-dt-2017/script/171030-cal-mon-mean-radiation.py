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

    # Start Year 
    start_year='2017'
    
    # End Year
    end_year='2018'

    # Input Dir
    in_dir='/home/yangsong3/L_Zealot/project/ITMM-dt-2017/data/ITMM-dt-2017/17-18new/'+sta_num+'/splined/pro_data/'
    out_dir=in_dir 

    # Correct Algrithm
    #   C1 -- Both j and splined
    #   C2 == Only j
    corr_algthm='C1' 

    file_profix=['10H', '12H', '14H', '16H', 'max_daily'] 
#----------------------------------------------------
# Main function
#----------------------------------------------------
    for pos, spe in enumerate(file_profix):
        pt=pd.read_csv(in_dir+get_file_name(sta_num, corr_algthm, spe), parse_dates=True, skiprows=1, names=['time', 'uva', 'uvb', 'total'], index_col='time')
        print('parsing '+in_dir+get_file_name(sta_num, corr_algthm, spe))
        pt_out=reorg_rad(pt)

        fout_name=out_dir+get_outfile_name(sta_num, corr_algthm, spe)
        with open(fout_name, 'w') as f:
            pt_out.to_csv(f)


def get_file_name(sta_num, corr, spe):
    fname='Rad_'+sta_num+'_'+corr+'_'+spe+'.csv'
    return fname

def get_outfile_name(sta_num, corr, spe):
    fname='Rad_'+sta_num+'_'+corr+'_'+spe+'_Mon.csv'
    return fname
def reorg_rad(pt):
    pt_all=pt.resample('m').mean()
    pt_all.index=pt_all.index.strftime('%Y-%m')
    return pt_all

if __name__ == "__main__":
    main()




