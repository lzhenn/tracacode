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

    # Start Time 
    start_time='2012-10-02 06:00:00'

    # End Time 
    end_time='2012-10-10 20:00:00'

    # Input Dir
    in_dir='../data/ITMM-dt-2017/sample/'+sta_num+'/splined/'
    
    # Output Dir 
    out_dir='../data/ITMM-dt-2017/sample/'+sta_num+'/splined-hourly/'

    # Correct Algrithm
    #   C1 -- Both j and splined
    #   C2 == Only j
    corr_algthm='C1' 


#----------------------------------------------------
# Main function
#----------------------------------------------------
 
    # Preparation
    int_time_obj = datetime.datetime.strptime(start_time, '%Y-%m-%d %H:%M:%S')
    end_time_obj = datetime.datetime.strptime(end_time, '%Y-%m-%d %H:%M:%S')
    file_time_delta=datetime.timedelta(hours=1)
    curr_time_obj=int_time_obj

    fout_name=out_dir+get_outfile_name(sta_num, int_time_obj, end_time_obj, corr_algthm)
    
    # Main Loop...
    while curr_time_obj <= end_time_obj:
        fname=in_dir+get_file_name(sta_num, curr_time_obj)
        
        try:    
            fr = open(fname, 'r')
        except:
            curr_time_obj=curr_time_obj+file_time_delta
            continue
        print('parsing '+fname+'...')
        lines=fr.readlines()
        fr.close()
        df=org_data(lines, curr_time_obj, corr_algthm, sta_num)
        df_hour=df.resample('1H').mean()    # Resample into hourly data

        if os.path.isfile(fout_name):
            with open(fout_name, 'a') as f:
                df_hour.loc[curr_time_obj:curr_time_obj,:].to_csv(f, header=False)
        else:
            with open(fout_name, 'w') as f:
                df_hour.loc[curr_time_obj:curr_time_obj,:].to_csv(f)
        #     df_ht.to_csv(f, header=False)
        # Point to next file
        curr_time_obj=curr_time_obj+file_time_delta


def get_outfile_name(sta_num, strt_time, end_time, corr):
    time0=strt_time.strftime('%Y%m%d%H')
    time1=end_time.strftime('%Y%m%d%H')
    fname=time0+'-'+time1+'_'+sta_num+'_'+corr+'.csv'
    return fname

def get_file_name(sta_num, timestmp):
    time0=timestmp.strftime('%Y%m%d_%H%M')   
    fname=time0+'_'+sta_num+'.ded'
    return fname


# Organize all data into the dataframe
def org_data(lines, timestmp, corr_algthm, sta_num):
    
    # Construct the dataframe
    record_time_delta=datetime.timedelta(minutes=1)
    timestmp+=record_time_delta
    time_frames=pd.date_range(timestmp, periods=60, freq='Min')
    df = pd.DataFrame(np.zeros((60,761)), index=time_frames, columns=list(drange(290, 670.5, '0.5')))
    
    # Initial the timestmp
    timestmp-=record_time_delta
    t_pos=-1                # start from 01 min 
    data0=np.zeros((60,761))
    
    # Loop the file
    for pos_line, line in enumerate(lines):
        
        # Skip the timestamp lines
        if len(line) <= 10:
            continue
        elif len(line)<=30:
            t_pos+=1
            l_pos=0
            continue
        
        # skip the redundant data
        if t_pos >= 60: 
            break

        content=line.split() # [0]--wavelength [1]--radiation
        value=content[1]
        data0[t_pos,l_pos]=value
        l_pos+=1
    data0=data_corr_algthm(data0, corr_algthm, sta_num)
    df.loc[:,:]=data0
    return df

def data_corr_algthm(data, alg, sta_num):
    if sta_num == '67606':
        if alg=='C1':
            data=data/4.91
    elif sta_num == '67605':
        data=data/0.7
    return data


def drange(x, y, jump):
    while x < y:
        yield float(x)
        x += decimal.Decimal(jump)

if __name__ == "__main__":
    main()




