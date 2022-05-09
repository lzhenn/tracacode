#! /usr/bin/env python
#   Try sklearn lasso model 
#   
#               L_Zealot
#               Aug 16, 2019
#               Guangzhou, GD
#

import os
import json

import numpy as np
import pandas as pd
from sklearn.linear_model import LassoCV, Lasso
import matplotlib
matplotlib.use('Agg') 
import matplotlib.pyplot as plt
import datetime
from matplotlib.pyplot import savefig


#----------------------------------------------------
# User Defined Part
#----------------------------------------------------
def main():

    # Label File
    label_dir='../testdata/label/'

    # Feature lib
    cpc_prim_lib="/disk/hq247/yhuangci/lzhenn/data/osci_idx/cpc.prim.1950.index.txt"
    cpc_aao_lib="/disk/hq247/yhuangci/lzhenn/data/osci_idx/cpc.aao.1979.index.txt"
    
    # Year Break Points 
    start_year=1990

    # End Year
    end_year=2016

    # define label start time according to lag step
    label_start_date=datetime.datetime.strptime(str(start_year)+'0101', '%Y%m%d')
    label_end_date=datetime.datetime.strptime(str(end_year)+'1231', '%Y%m%d')
    
    # magic_alpha from lassoCV results
    #magic_alpha=0.802779265085
    #magic_alpha=1.0
    #magic_alpha=1.07682989906 train_data
    
    
    # Read circulation features
    """
    df_tmp_features     =   pd.read_csv(in_dir+'possible_features.csv',index_col='time',parse_dates=True)
    df_feature0=dcomp_seasonality(df_tmp_features, True)
    df_feature0=df_feature0.dropna(axis=1, how='any')
    df_feature0=df_feature0[df_feature0.index.year>=start_years[0]]
    X0= np.array(df_feature0.values) 
    X, col_list_X=construct_lag_array2d(df_feature0, lag_step)
    print(len(col_list_X))
    print(X.shape)
    """

    

    # loop stations start here
    fs_handl=os.walk(label_dir) 
    
    for path,dir_list,file_list in fs_handl:  
        for file_name in file_list:  
            sta_num=file_name[6:11]
            
            # Read labels
            df_tmp_label=pd.read_csv(label_dir+file_name, index_col='time', parse_dates=True)
            
            # Parser labels
            if df_tmp_label.index[0]>label_start_date:
                print('start time beyond the least requirement!')
                continue

            df_tmp_label=df_tmp_label[(df_tmp_label.index >= label_start_date) & (df_tmp_label.index <= label_end_date)]
            rst_lst=[]
            for ii in range(1,13):
                mon_slice=df_tmp_label[df_tmp_label.index.month==ii]
                mon_pos_prob=mon_slice[mon_slice>0].count()/mon_slice.count()
                rst_lst.append(mon_pos_prob.loc['avg_temp'])
            print(sta_num, ',',rst_lst)
if __name__ == "__main__":
    main()



