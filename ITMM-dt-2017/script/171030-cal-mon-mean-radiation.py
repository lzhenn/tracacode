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

    # Start Year 
    start_year='2011'
    
    # End Year
    end_year='2017'

    # Input Dir
    in_dir='../data/ITMM-dt-2017/'+sta_num+'/splined/pro_data/'
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
        curr_year=start_year
        while curr_year<=end_year:
            pt=pd.read_csv(in_dir+get_file_name(sta_num, curr_year, corr_algthm, spe), parse_dates=True, skiprows=1, names=['time', 'uva', 'uvb', 'total'], index_col='time')
            print('parsing '+in_dir+get_file_name(sta_num, curr_year, corr_algthm, spe))
            pt_out=reorg_rad(pt)

            fout_name=out_dir+get_outfile_name(sta_num, corr_algthm, spe)
            if os.path.isfile(fout_name):
                with open(fout_name, 'a') as f:
                    pt_out.to_csv(f, header=False)
            else:
                with open(fout_name, 'w') as f:
                    pt_out.to_csv(f)
            curr_year=str(int(curr_year)+1)


def get_file_name(sta_num, curr_year, corr, spe):
    fname='Rad_'+curr_year+'_'+sta_num+'_'+corr+'_'+spe+'.csv'
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




