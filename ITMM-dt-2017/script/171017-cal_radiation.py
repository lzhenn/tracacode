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
    start_year='2017'
    
    # End Year
    end_year='2018'

    # Correct Algrithm
    #   C1 -- Both j and splined
    #   C2 == Only j
    corr_algthm='C1' 

#----------------------------------------------------
# Main function
#----------------------------------------------------
    curr_year=start_year
    while curr_year<=end_year:

        pt=pd.read_csv(in_dir+get_file_name(sta_num, curr_year, corr_algthm))
        print('parsing '+in_dir+get_file_name(sta_num, curr_year, corr_algthm))
        r_uva, r_uvb, r_total=cal_rad(pt)
        dfout = pd.DataFrame(np.append([r_uva.values, r_uvb.values], [r_total.values], axis=0).T, index=pt.iloc[:,0], columns=['uva', 'uvb', 'total'])
        fout_name=out_dir+get_outfile_name(sta_num, curr_year, corr_algthm)
        if os.path.isfile(fout_name):
            with open(fout_name, 'a') as f:
                dfout.to_csv(f, header=False)
        else:
            with open(fout_name, 'w') as f:
                dfout.to_csv(f)
        curr_year=str(int(curr_year)+1)

def get_file_name(sta_num, curr_year, corr):
    fname='splined_'+curr_year+'_'+sta_num+'_'+corr+'_Hour.csv'
    return fname
def get_outfile_name(sta_num, curr_year, corr):
    fname='Rad_'+sta_num+'_'+corr+'_Hour.csv'
    return fname

def cal_rad(pt):
    uva=pt.loc[:,'320.0':'422.0'].sum(axis=1)*0.5
    uvb=pt.loc[:,'290.0':'320.0'].sum(axis=1)*0.5
    total=pt.sum(axis=1)*0.5
    uva[uva<0]=np.nan
    uvb[uvb<0]=np.nan
    total[total<0]=np.nan
    return uva, uvb, total




if __name__ == "__main__":
    main()




