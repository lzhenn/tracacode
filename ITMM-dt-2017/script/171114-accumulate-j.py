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
    start_year='2011'
    
    # End Year
    end_year='2017'

    # Input Dir
    in_dir='../data/ITMM-dt-2017/'+sta_num+'/J/pro_data/'
    out_dir=in_dir 

    # Correct Algrithm
    #   C1 -- Both j and splined
    #   C2 == Only j
    corr_algthm='C1' 

    # Species
    species=['H2O2','HCHO_M','HCHO_R','HONO','NO3_M','NO3_R','NO2','O1D']
 
#----------------------------------------------------
# Main function
#----------------------------------------------------
    curr_year=start_year
    while curr_year<=end_year:
        for pos, spe in enumerate(species):
            pt=pd.read_csv(in_dir+get_file_name(sta_num, curr_year, corr_algthm, spe), parse_dates=True, skiprows=1, names=['time', 'mean'], index_col='time')
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
    fname='j'+spe+'_'+curr_year+'_'+sta_num+'_'+corr+'_Hour.csv'
    return fname

def get_outfile_name(sta_num, corr, spe):
    fname='j'+spe+'_'+sta_num+'_'+corr+'_Hour.csv'
    return fname

def reorg_rad(pt):
    pt_all=pt.resample('H').mean()
    pt_all=pt_all[pt_all.index.hour>=6]
    pt_all=pt_all[pt_all.index.hour<=20]
    return pt_all

if __name__ == "__main__":
    main()




