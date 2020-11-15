#! /usr/bin/env python
#  Deal with raw precip data 
#   
#               L_Zealot
#               Nov 15, 2020 
#               Hong Kong 
#
import os
import numpy as np
import pandas as pd
import datetime

#-------------------------------------
# Function Definition Part
#-------------------------------------
def main():

# Input File
    in_file='/disk/hq247/yhuangci/lzhenn/data/2011-UST-RAP/a_precip_20201113141016.csv'
    out_file='/disk/hq247/yhuangci/lzhenn/data/2011-UST-RAP/mangkhut_precip.csv'
    df = pd.read_csv(in_file,parse_dates=True) 
    df['id']=df['lon']*df['lat']
    df_process=df.groupby('id').sum()    # Resample into hourly data
    df_process.to_csv(out_file)
if __name__ == "__main__":
    main()

   

