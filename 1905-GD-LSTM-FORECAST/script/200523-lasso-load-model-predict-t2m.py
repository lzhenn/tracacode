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
from sklearn.linear_model import Lasso
import joblib
import matplotlib
matplotlib.use('Agg') 
import matplotlib.pyplot as plt
import datetime
from matplotlib.pyplot import savefig


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

def scaling_predict(y, obv_series, predict_series):

#----------------------------------------------------
# User Defined Part
#----------------------------------------------------
def main():
    # Station Number
    tgt_sta_num='59287'

    # meta file
    sta_meta_file='/disk/hq247/yhuangci/lzhenn/data/station/SURF_CLI_CHN_PRE_MUT_HOMO_STATION.xls'
    
    # Label Dir
    label_dir='/disk/hq247/yhuangci/lzhenn/data/station/post/mon/Tave/'

    # Feature lib
    cpc_prim_lib_dir="/disk/hq247/yhuangci/lzhenn/workspace/spellcaster-local/data/all_feature/all_org_features.csv"
    era5_lib_dir="/disk/hq247/yhuangci/lzhenn/workspace/spellcaster-local/data/all_feature/era-bind-s2s/"
    giss_lib_dir="/disk/hq247/yhuangci/lzhenn/workspace/spellcaster-local/data/all_feature/giss-bind-s2s/"
    
    # Model Storage Dir
    model_out_dir='/disk/hq247/yhuangci/lzhenn/workspace/spellcaster-local/data/model_archive/'
    
    # Result Dict File
    result_in_file='../testdata/result.json'
    
    # Model Parameter
    lag_step=24
    data_feed_year=5    # feed in previous 3 yrs

    # define label start time according to lag step
    label_init_date=datetime.datetime.now()
    # 
    start_year=label_init_date.year-data_feed_year
    label_start_date=datetime.datetime.strptime(str(start_year)+'0101', '%Y%m%d')

    # magic_alpha from lassoCV results
    #magic_alpha=0.802779265085
    #magic_alpha=1.0
    #magic_alpha=1.07682989906 train_data
    
# ------------------------ Data Loading ----------------------

    # Get in Station meta
    sta_df=get_station_df(sta_meta_file)
    
    # CPC Features
    df_cpc_prim         =  pd.read_csv(cpc_prim_lib_dir, index_col=0, parse_dates=True)
    df_cpc_prim = df_cpc_prim[df_cpc_prim.index.year>=start_year]
    df_cpc_prim.loc[label_init_date]=df_cpc_prim.iloc[-1].values
    df_cpc_prim_lag, cpc_prim_list=construct_lag_array2d(df_cpc_prim, lag_step)
   
    X_features = np.array(df_cpc_prim_lag) 
    col_list_X=cpc_prim_list
    # 74 idx
    #df_feature0=dcomp_seasonality(df_tmp_features, True)
    #df_feature0=df_feature0.dropna(axis=1, how='any')
    #df_feature0=df_feature0[df_feature0.index.year>=start_year]
    #X, col_list_X=construct_lag_array2d(df_feature0, lag_step)

    # 
    #X_features = np.concatenate((cpc_aao_lag, cpc_prim_lag,X),axis=1) # with 74 cir index
    #X_features = np.concatenate((cpc_aao_lag, cpc_prim_lag),axis=1) # without 74 cir index
    #col_list_X.extend(cpc_prim_list)
    #col_list_X.extend(col_list_X)

    icount=0
    for idx, row in sta_df.iterrows():
        sta_num=str(int(row['区站号']))
        print(sta_num+' '+row['省份']+' '+row['站名'])
 
        # Read station-based feature, era5 deg in anom, not era5 is combined with dyn forecast
        # so it has T+1 (lag0) info
        df_era5=pd.read_csv(era5_lib_dir+sta_num+'.t2m.csv', index_col=0, parse_dates=True)
        df_era5=df_era5[df_era5.index.year>=start_year]
        
        # note we remove the combined part
        lst_era5_lag, col_era5_lag=construct_lag_array1d(df_era5.loc[:label_init_date], lag_step, 'era5') 
        lst_era5_lag=np.squeeze(lst_era5_lag)
        
        # giss deg in anom, also combined dyn forecast, treat it as lag1 when conducting lag generation
        df_giss=pd.read_csv(giss_lib_dir+sta_num+'.t2m.csv', index_col=0, parse_dates=True)
        df_giss=df_giss[df_giss.index.year>=start_year]
        lst_giss_lag, col_giss_lag=construct_lag_array1d(df_giss, lag_step, 'giss') 
        lst_giss_lag=np.squeeze(lst_giss_lag)
        
        X = np.concatenate((X_features, lst_era5_lag, lst_giss_lag),axis=1) # with 74 cir index
        col_list_X.extend(col_era5_lag)
        col_list_X.extend(col_giss_lag)
        
        # verify
        #print(len(col_list_X))
        #print(X_features.shape)


        (n_samples, n_features)=X.shape
        
        lasso_model = joblib.load( model_out_dir+sta_num+'.t2m.model')

        w=lasso_model.coef_
        b=lasso_model.intercept_
        features=np.where(w!=0)[0]

        # print result
        #print('w: ', w[w!=0])
        #print('w_idx: ', features)
        print('w_name: ', [col_list_X[itm] for itm in features])
        if len(features) == 0:
            y_lasso=0.0
        else:
            # make prediction
            predict_Y=lasso_model.predict(X)
            y_lasso=predict_Y[-1]
        # determine std range:
        # Read label
        df_lbl=pd.read_csv(label_dir+sta_num+'.txt',index_col=0, parse_dates=True)
        
       
        df_lbl=df_lbl[(df_lbl.index >= label_start_date) & (df_lbl.index <= label_end_date)]
 


        # all we need is the prediction value after scaling!
        y_predict=(predict_Y[-1], )
                   
        icount=icount+1
    # end for

if __name__ == "__main__":
    main()



