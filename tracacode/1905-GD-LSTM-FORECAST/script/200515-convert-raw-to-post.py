#! /usr/bin/env python
#  Deal with 59287 station data 
#   
#               L_Zealot
#               Jul 17, 2019
#               Guangzhou, GD
#

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
    # Station list
    sta_meta_fn='/disk/hq247/yhuangci/lzhenn/data/station/SURF_CLI_CHN_PRE_MUT_HOMO_STATION.xls'

    # Raw Input File
    raw_in_dir='/disk/hq247/yhuangci/lzhenn/data/station/post/daily/Tave/'

    # Out Dir
    post_out_dir='/disk/hq247/yhuangci/lzhenn/data/station/post/mon/Tave/'

    # Var Name 
    fn_prefix='SURF_CLI_CHN_TEM_DAY_HOMO_Tave_' 

# Function def


#----------------------------------------------------
# Main function
#----------------------------------------------------
    df = pd.read_excel(sta_meta_fn)
    df=df.dropna()

    for idx, row in df.iterrows(): # loop thru all stations
        fn=fn_prefix+str(int(row['区站号']))+'.txt'
        print(fn)
        daily_sta_df=pd.read_csv(raw_in_dir+fn, sep='\s+', header=None, names=['year', 'month', 'day', 'tave'])
        
        date_range=pd.to_datetime(daily_sta_df.loc[:,['year','month','day']])
        daily_sta_df =pd.DataFrame(daily_sta_df.loc[:,'tave'].values, index=date_range, columns=['tave'])
        daily_sta_df.index.set_names('time', inplace=True)
        daily_sta_df=daily_sta_df.replace(-999.0,np.nan)  

        daily_sta_df=daily_sta_df.resample('M').mean() # resample to monthly mean
        daily_sta_df=daily_sta_df.to_period() # yyyy-mm-dd to yyyy-mm
        daily_sta_df=daily_sta_df.dropna()
        daily_sta_df.to_csv(post_out_dir+str(int(row['区站号']))+'.txt')


if __name__ == "__main__":
    main()




