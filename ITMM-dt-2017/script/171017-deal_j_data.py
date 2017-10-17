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
import csv
#-------------------------------------
# Function Definition Part
#-------------------------------------
def main():

#----------------------------------------------------
# User Defined Part
#----------------------------------------------------

    # Station Number
    sta_num='67605'

    # Start Date in Julian Day 
    start_time='2012276'

    # End Date in Julian Day
    end_time='2012284'

    # Input Dir
    in_dir='../data/ITMM-dt-2017/sample/'+sta_num+'/j/'
    
    # Output Dir 
    out_dir='../data/ITMM-dt-2017/sample/'+sta_num+'/j-hourly/'

    # Correct Algrithm
    #   C1 -- Both j and splined
    #   C2 == Only j
    corr_algthm='C1' 

    # Species
    species=['H2O2','HCHO_M','HCHO_R','HONO','NO3_M','NO3_R','NO2','O1D']
    
    # base time
    time_base='190001010000'

#----------------------------------------------------
# Main function
#----------------------------------------------------
 
    # Preparation
    int_time_obj = datetime.datetime.strptime(start_time, '%Y%j')
    end_time_obj = datetime.datetime.strptime(end_time, '%Y%j')
    time0 = datetime.datetime.strptime(time_base,'%Y%m%d%H%M')
    file_time_delta=datetime.timedelta(days=1)
    record_time_delta=datetime.timedelta(hours=23)
    curr_time_obj=int_time_obj

    
    # Main Loop...
    while curr_time_obj <= end_time_obj:
        time0_str=curr_time_obj.strftime('%y%j')   
  
        # Loop the individual species
        for pos_line, spe in enumerate(species):
            
            fn=in_dir+'j'+spe+time0_str+'.ded'
            try:
                fr = open(fn, 'r')
            except:
                continue
            print('parsing '+fn+'...')
            lines=fr.readlines()
            fr.close()
            df = org_data(lines, time0, spe, corr_algthm, sta_num)
            df_hour=df.resample('1H').mean()    # Resample into hourly data
            fout_name=out_dir+get_outfile_name(sta_num, int_time_obj, end_time_obj, corr_algthm, spe)
            if os.path.isfile(fout_name):
                with open(fout_name, 'a') as f:
                    df_hour.loc[curr_time_obj:curr_time_obj+record_time_delta,:].to_csv(f, header=False)
            else:
                with open(fout_name, 'w') as f:
                    df_hour.loc[curr_time_obj:curr_time_obj+record_time_delta,:].to_csv(f)
        # Point to next file
        curr_time_obj=curr_time_obj+file_time_delta


def get_outfile_name(sta_num, strt_time, end_time, corr, spe):
    time0=strt_time.strftime('%Y%m%d%H')
    time1=end_time.strftime('%Y%m%d%H')
    fname='j'+spe+'_'+time0+'-'+time1+'_'+sta_num+'_'+corr+'.csv'
    return fname

def get_file_name(timestmp, species):
    time0=timestmp.strftime('%Y%j')   
    fnames=species
    fnames='j'+species+time0+'.ded'
    return fnames


# Organize all data into the dataframe
def org_data(lines, time0, spe, corr_algthm, sta_num):
    time_str=time0.strftime('%Y%m%d%H')
    timestamp=[]
    values=[]
    for pos_line, line in enumerate(lines):
        content=line.split() # [0]--timeshift [1]--j ratio
        timeshift=float(content[0])
        value=float(content[1])
        date_delta=datetime.timedelta(days=timeshift-2.0)
        time_now=time0+date_delta
        timestamp.append(time_now)
        values.append(value)
    values=np.array(values)
    if time0 < datetime.datetime(2015,9,1):
        values=data_corr_algthm(values, corr_algthm, sta_num, spe)
    df= pd.DataFrame(values,index=timestamp,columns=[spe])
    return df

def data_corr_algthm(data, alg, sta_num, spe):

    cor_dic={'H2O2':[0.197, -4e-7],
             'HCHO_M':[0.2065, -2e-6],
             'HCHO_R':[0.2198, 2e-7],
             'HONO':[0.2083, -7e-5],
             'NO3_M':[0.2127, -0.018],
             'NO3_R':[0.2121,-0.0136],
             'NO2':[0.2079, -0.0004],
             'O1D':[0.1191, -7e-6]}

    if sta_num == '67606':
        if alg=='C1':
            data=data/4.91
        elif alg=='C2':
            data=cor_dic[spe][0]*data+cor_dic[spe][1]
    elif sta_num == '67605':
        data=data/0.7
    return data

if __name__ == "__main__":
    main()




