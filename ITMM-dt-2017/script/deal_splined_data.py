#! /usr/bin/env python
#  Deal with splined data 
#   
#               L_Zealot
#               Oct 16, 2017
#               Guangzhou, GD
#
import math
#from numpy import *
import numpy as np
import datetime

#-------------------------------------
# Function Definition Part
#-------------------------------------
def main():

#----------------------------------------------------
# User Defined Part
#----------------------------------------------------

    # Station Number
    sta_num='67606'

    # Start Time 
    start_time='2012-10-02 06:00:00'

    # End Time 
    end_time='2012-10-10 20:00:00'

    # Input Dir
    in_dir='../data/ITMM-dt-2017/sample/'+sta_num+'/splined/'
    
    # Output Dir
    out_dir='../data/ITMM-dt-2017/sample/'+sta_num+'/splined-hourly/'




#----------------------------------------------------
# Main function
#----------------------------------------------------
 
    # Preparation
    int_time_obj = datetime.datetime.strptime(start_time, '%Y-%m-%d %H:%M:%S')
    end_time_obj = datetime.datetime.strptime(end_time, '%Y-%m-%d %H:%M:%S')
    file_time_delta=datetime.timedelta(hours=1)
    curr_time_obj=int_time_obj

    # Main Loop...
    while curr_time_obj <= end_time_obj:
        fname=in_dir+get_file_name(sta_num, curr_time_obj)
        
        # Point to next file
        curr_time_obj=curr_time_obj+file_time_delta
        
        try:
            fr = open(fname, 'r')
            print('parsing '+fname+'...')
            lines=fr.readlines()
            fr.close()
        except:
            continue

def get_file_name(sta_num, timestmp):
#    20121010_1100_67606.ded
    time0=timestmp.strftime('%Y%m%d_%H%M')   
    fname=time0+'_'+sta_num+'.ded'
    return fname
if __name__ == "__main__":
    main()




