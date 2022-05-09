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
import datetime


# function defination part
def get_station_df(sta_path):
    '''get station meta info (lat, lon, elev)'''
    df = pd.read_excel(sta_path)
    df=df.dropna()
    return(df)


def construct_lag_array2d(df, lag_step):
    """
        construct lag array 2d (n features x m samples)
        from -lag_step to -1
    """
    org_col_list=df.columns.values.tolist()
    col_list=[itm+'_lag1' for itm in org_col_list]
    X_all = np.array(df.values)
    X=X_all[:-lag_step,:]    
    for ii in range(1, lag_step):
        X_tmp=X_all[ii:(-lag_step+ii),:]
        X=np.concatenate((X,X_tmp),1)
        new_list=[itm+'_lag'+str(ii+1) for itm in org_col_list]
        col_list.extend(new_list)
    return X, col_list

def construct_lag_array1d(df, lag_step,array_name):
    """
        construct lag array 1d (1 feature and m samples)
        from -lag_step to -1
        args:
            df          dataframe contains series
            lag_step    how long the lag takes
            array_name  series name, e.g. 'aao_idx'
        returns:
            X           lagged series, 2-D
            col_list    col names
    """
    org_col_list=list(array_name)
    col_list=[array_name+'_lag1']
    
    X_all = np.array(df.values)
    X=X_all[:-lag_step]
    X=X[:,np.newaxis]   # change to 2-D
    for ii in range(1, lag_step):
        X_tmp=X_all[ii:(-lag_step+ii)]
        X_tmp=X_tmp[:,np.newaxis]
        X=np.concatenate((X,X_tmp),axis=1)
        new_list=[array_name+'_lag'+str(ii+1)]
        col_list.extend(new_list)
    return X, col_list


def dcomp_seasonality(df, std_flag):
    df_season = df.groupby(df.index.month).mean() # climatological seasonal cycle
    if std_flag:
        df = df.groupby(df.index.month).transform(lambda x: (x-x['1981-01-01':'2010-12-31'].mean())/x.std()) # calculate monthly anomaly
    else:
        df = df.groupby(df.index.month).transform(lambda x: (x-x['1981-01-01':'2010-12-31'].mean())) # calculate monthly anomaly
    return df

def conv_deg(deg_str):
    '''convert to degree info'''
    value=int(deg_str)//100
    value=value+(int(deg_str)-value*100)/60
    return(value)


#----------------------------------------------------
# User Defined Part
#----------------------------------------------------
def main():
    # Station Number
    tgt_sta_num='59287'

    # meta file
    sta_meta_file='/disk/hq247/yhuangci/lzhenn/data/station/SURF_CLI_CHN_PRE_MUT_HOMO_STATION.xls'
    
    # Label Dir
    label_dir='/disk/hq247/yhuangci/lzhenn/data/station/post/mon/prec/'

    # Feature lib
    cpc_prim_lib_dir="/disk/hq247/yhuangci/lzhenn/workspace/spellcaster-local/data/all_feature/all_org_features.csv"
    prec_lib_dir="/disk/hq247/yhuangci/lzhenn/workspace/spellcaster-local/data/all_feature/prec-bind-s2s/"
   
    # Model Storage Dir
    model_out_dir='/disk/hq247/yhuangci/lzhenn/workspace/spellcaster-local/data/model_archive/'
    # interim output
    result_in_file='../result/china_result950.json'

    # Year Break Points 
    start_year=1979

    # End Year
    end_year=2018

    # Model Parameter
    train_size=0.75
    lag_step=24

    # define label start time according to lag step
    label_start_date=datetime.datetime.strptime(str(start_year)+'0101', '%Y%m%d')
    label_end_date=datetime.datetime.strptime(str(end_year)+'1231', '%Y%m%d')
   
    # region list
    province=['广东']

    # magic_alpha from lassoCV results
    #magic_alpha=0.802779265085
    #magic_alpha=1.0
    #magic_alpha=1.07682989906 train_data
    
    

    result_dic={}

# ------------------------ Data Loading ----------------------

    # get in previous json data   
    #with open(result_in_file) as f:
    #    result_dic=json.load(f)

    # Get in Station meta
    sta_df=get_station_df(sta_meta_file)
    
    for idx, row in sta_df.iterrows():
        sta_num=str(int(row['区站号']))
        print(sta_num+' '+row['省份']+' '+row['站名'])
        
        mon_sta_df=pd.read_csv(label_dir+'SURF_CLI_CHN_PRE_MUT_HOMO-MON-'+sta_num+'.txt', sep='\s+', header=None, names=['year', 'month', 'day', 'prec'])
        mon_sta_df.loc[:,'day']=1 # uniform style

        date_range=pd.to_datetime(mon_sta_df.loc[:,['year','month', 'day']])
        mon_sta_df =pd.DataFrame(mon_sta_df.loc[:,'prec'].values, index=date_range, columns=['prec'])
        mon_sta_df.index.set_names('time', inplace=True)
        mon_sta_df=mon_sta_df.replace(-999.0,np.nan)  
        #mon_sta_df=mon_sta_df.to_period() # yyyy-mm-dd to yyyy-mm
        df_lbl=mon_sta_df.dropna()
        df_monlist=df_lbl.groupby(df_lbl.index.month).mean().T.values/30. # calculate monthly anomaly
        df_monlist=df_monlist.tolist()
        result_dic[sta_num]=df_monlist[0]
    
    with open('../result/pr_mon_clim_mmperday.json', 'w') as f:
        json.dump(result_dic,f)

 
       
if __name__ == "__main__":
    main()



