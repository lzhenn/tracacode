#! /usr/bin/env python
#  Select J data to 10H 12H 14H and 16H
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

    # Input Dir
    in_dir='/home/yangsong3/L_Zealot/project/ITMM-dt-2017/data/ITMM-dt-2017/17-18new/'+sta_num+'/J/pro_data/'
    out_dir=in_dir 

    # Correct Algrithm
    #   C1 -- Both j and splined
    #   C2 == Only j
    corr_algthm='C1' 

    # Species
    species=['H2O2','HCHO_M','HCHO_R','HONO','NO3_M','NO3_R','NO2','O1D']


    pd.set_option('display.max_rows',None)
#----------------------------------------------------
# Main function
#----------------------------------------------------
    for pos, spe in enumerate(species):
        pt=pd.read_csv(in_dir+get_file_name(sta_num,  corr_algthm, spe), parse_dates=True, skiprows=1, names=['time', 'max'], index_col='time')
        print('parsing '+in_dir+get_file_name(sta_num,  corr_algthm, spe))
        pt_out=reorg_rad(pt)
        fout_name=out_dir+get_outfile_name(sta_num, corr_algthm, spe)
        with open(fout_name, 'w') as f:
            pt_out.to_csv(f)

def get_file_name(sta_num,  corr, spe):
    fname='j'+spe+'_'+sta_num+'_'+corr+'_Hour.csv'
    return fname

def get_outfile_name(sta_num, corr, spe):
    fname='j'+spe+'_'+sta_num+'_'+corr+'_Daily.csv'
    return fname

def reorg_rad(pt):
    pt_use=pt[pt.index.hour>=10]
    pt_use=pt_use[pt_use.index.hour<=16]
    pt_all=pt_use.resample('D').max()
    #Only fit the hour start at even values!#
    if pt_use.index[0].hour % 2 ==0:
        pt_use=pt_use.resample('2H').first() # bug: we got an all day result...
    else:
        pt_use=pt_use.resample('2H').second() # bug: we got an all day result...
    pt_use=pt_use[pt_use.index.hour>=10]
    pt_use=pt_use[pt_use.index.hour<=16]

    len_out_s=(pt_use.index[0].hour-10)/2 # How many hours need we add in the start time, e.g. start at 16H, need 3 (10 12 14)
    while len_out_s >0:          # if not start at a good point, add hour to fit 10 12 14 16
        # hard work to insert before the first row
        insert_date=pd.date_range(pt_use.index[0]-datetime.timedelta(hours=2), periods=1)
        insert_row=pd.DataFrame(np.nan, index=insert_date, columns=pt_use.columns)
        pt_use=insert_row.append(pt_use)
        len_out_s = len_out_s -1
    len_out_e=(16-pt_use.index[-1].hour)/2 # How many hours need we add in the end time, e.g. end at 10H, need 3 (12 14 16)
    while len_out_e >0 :
        pt_use.loc[pt_use.index[-1]+datetime.timedelta(hours=2)]=np.nan
        len_out_e = len_out_e -1
    len_row=len(pt_use.index) # New length
    pt_value=pt_use.values.reshape((len_row/4,4))
    pt_hour=pd.DataFrame(pt_value, index=pt_all.index, columns=['10H','12H','14H','16H'])
    pt_all=pd.concat([pt_hour, pt_all], axis=1)
    return pt_all

if __name__ == "__main__":
    main()




