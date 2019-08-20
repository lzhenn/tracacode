#! /usr/bin/env python
#  Deal with 59287 station data 
#   
#               L_Zealot
#               Jul 17, 2019
#               Guangzhou, GD
#

import math
import os
import numpy as np
import pandas as pd
import datetime

#-------------------------------------
# Function Definition Part
#-------------------------------------
def main():

#----------------------------------------------------
# User Defined Part
#----------------------------------------------------

    # Input File
    in_dir='/home/lzhenn/array2/lzhenn/circlt_idx/'

    # Output File
    out_dir='../testdata/possible_features.csv'

    # Start Years
    start_years=[1956, 1996, 2011]
    
    # End Year
    end_year=2016

#----------------------------------------------------
# Main function
#----------------------------------------------------
    start_time=str(start_years[0])+'-01-01'
    end_time=str(end_year)+'-12-31'
    date_range = pd.date_range(start=start_time, end=end_time, freq='M')
    pt=pd.read_csv(in_dir+'idx1.txt', sep='\s+', header=6, names=['year','jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec', 'avg', 'rmean-5yr'], index_col='year')
    pt=pt.drop(['avg','rmean-5yr'], axis=1)
    df = pd.DataFrame(pt.stack().values, index=date_range, columns=['idx1'])# pd.stack() will convert row-arranged data into column-arranged data
    df.index.name='time'
    df = df.to_period()

    for idx in range(2,75): 
        pt=pd.read_csv(in_dir+'idx'+str(idx)+'.txt', sep='\s+', header=6, names=['year','jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec', 'avg', 'rmean-5yr'], index_col='year')
        pt=pt.drop(['avg','rmean-5yr'], axis=1)
        df['idx'+str(idx)] =pt.stack().values

    df=df.replace(999, np.nan)
    df.to_csv(out_dir)
if __name__ == "__main__":
    main()




