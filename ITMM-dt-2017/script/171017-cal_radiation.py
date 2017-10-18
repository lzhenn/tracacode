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
    in_dir='../data/ITMM-dt-2017/sample/'+sta_num+'/splined-hourly/2012100206-2012101020_67605_C1.csv'

    # Output Dir
    out_dir='../data/ITMM-dt-2017/sample/'+sta_num+'/splined-hourly/R2012100206-2012101020_67605_C1.csv'
 

#----------------------------------------------------
# Main function
#----------------------------------------------------
    pt=pd.read_csv(in_dir)
    r_uva, r_uvb, r_total=cal_rad(pt)
    dfout = pd.DataFrame(np.append([r_uva.values, r_uvb.values], [r_total.values], axis=0).T, index=pt.iloc[:,0], columns=['uva', 'uvb', 'total'])
    
    with open(out_dir, 'w') as f:
        dfout.to_csv(f)
    exit()


def cal_rad(pt):
    uva=pt.loc[:,'320.0':'422.0'].sum(axis=1)*0.5
    uvb=pt.loc[:,'290.0':'320.0'].sum(axis=1)*0.5
    total=pt.sum(axis=1)*0.5
    return uva, uvb, total




if __name__ == "__main__":
    main()




