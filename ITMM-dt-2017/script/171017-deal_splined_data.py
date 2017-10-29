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
    start_year='2013'
    
    # End Year
    end_year='2017'

    # Input Dir
    in_dir='../data/ITMM-dt-2017/'+sta_num+'/splined/'
    
    # Output Dir 
    out_dir='../data/ITMM-dt-2017/'+sta_num+'/splined/pro_data/'

    # Correct Algrithm
    #   C1 -- Both j and splined
    #   C2 == Only j
    corr_algthm='C1' 


#----------------------------------------------------
# Main function
#----------------------------------------------------
 
    # Preparation
    curr_year=start_year
    while curr_year<=end_year:
        start_time=curr_year+'-01-01 00:00:00'
        end_time=curr_year+'-12-31 23:59:00'
        
        int_time_obj = datetime.datetime.strptime(start_time, '%Y-%m-%d %H:%M:%S')
        end_time_obj = datetime.datetime.strptime(end_time, '%Y-%m-%d %H:%M:%S')
        
        file_time_delta=datetime.timedelta(hours=1)
        curr_time_obj=int_time_obj

        

        fout_name=out_dir+get_outfile_name(sta_num, curr_year, corr_algthm)
        
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
            try:
                df_hour=df.resample('1H').mean()    # Resample into hourly data
            except:
                curr_time_obj=curr_time_obj+file_time_delta
                continue
            if os.path.isfile(fout_name):
                with open(fout_name, 'a') as f:
                    df_hour.loc[curr_time_obj:curr_time_obj,:].to_csv(f, header=False)
            else:
                with open(fout_name, 'w') as f:
                    df_hour.loc[curr_time_obj:curr_time_obj,:].to_csv(f)
            
            # Point to the next file
            curr_time_obj=curr_time_obj+file_time_delta
        curr_year=str(int(curr_year)+1)

def get_outfile_name(sta_num, curr_year, corr):
    fname='splined_'+curr_year+'_'+sta_num+'_'+corr+'_Hour.csv'
    return fname

def get_file_name(sta_num, timestmp):
    year0=timestmp.strftime('%Y')   
    time0=timestmp.strftime('%Y%m%d_%H%M')   
    if sta_num=='67606':
        fname=year0+'/'+time0+'_'+sta_num+'.ded'
    elif sta_num=='67605':
        fname=time0+'_'+sta_num+'.ded'
    return fname


# Organize all data into the dataframe
def org_data(lines, timestmp, corr_algthm, sta_num):

    # Initial
    yyyymmdd=timestmp.strftime('%Y%m%d') 
    time_frames=[]
    t_pos=-1                # start from 01 min 
    data0=np.empty((3600,761))
    # Loop the file
    for pos_line, line in enumerate(lines):
        
        # Skip the timestamp lines
        if len(line) <= 10:
            continue
        elif len(line)<=30:
            t_pos+=1
            l_pos=0
            t_line=line.split()
            t_line=t_line[0].strip() # taking out timestamp HH:MM:SS
            time0=datetime.datetime.strptime(yyyymmdd+' '+t_line, '%Y%m%d %H:%M:%S')
            time_frames.append(time0)
            continue
        content=line.split() # [0]--wavelength [1]--radiation
        try:
            wv_len=float(content[0])
            l_pos=int((wv_len-290.0)*2)
            value=content[1]
        except:
            continue
        if l_pos>760 or l_pos<0:
            continue
        try:
            data0[t_pos,l_pos]=value
        except:
            continue
    if not(sta_num == '67606' and timestmp >= datetime.datetime(2015,9,1)):
        data0=data_corr_algthm(data0, sta_num)
    df = pd.DataFrame(data0[0:t_pos+1,:], index=time_frames, columns=list(drange(290, 670.5, '0.5')))
    return df

def data_corr_algthm(data, sta_num):
    if sta_num == '67606':
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




