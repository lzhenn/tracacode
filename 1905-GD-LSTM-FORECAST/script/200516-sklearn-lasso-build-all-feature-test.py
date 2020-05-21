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
        df = df.groupby(df.index.month).transform(lambda x: (x-x.mean())/x.std()) # calculate monthly anomaly
    else:
        df = df.groupby(df.index.month).transform(lambda x: (x-x.mean())) # calculate monthly anomaly
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
    label_dir='/disk/hq247/yhuangci/lzhenn/data/station/post/mon/Tave/'

    # Feature lib
    cpc_prim_lib_dir="/disk/hq247/yhuangci/lzhenn/workspace/spellcaster-local/data/all_feature/all_org_features.csv"
    era5_lib_dir="/disk/hq247/yhuangci/lzhenn/workspace/spellcaster-local/data/all_feature/era-bind-s2s/"
    giss_lib_dir="/disk/hq247/yhuangci/lzhenn/workspace/spellcaster-local/data/all_feature/giss-bind-s2s/"
        
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
    
    # magic_alpha from lassoCV results
    #magic_alpha=0.802779265085
    #magic_alpha=1.0
    #magic_alpha=1.07682989906 train_data
    
    

    result_dic={}

# ------------------------ Data Loading ----------------------

    # Get in Station meta
    sta_df=get_station_df(sta_meta_file)
    
    # CPC Features
    df_cpc_prim         =  pd.read_csv(cpc_prim_lib_dir, index_col=0, parse_dates=True)
    df_cpc_prim = df_cpc_prim[df_cpc_prim.index.year<=end_year]
    df_cpc_prim_lag, cpc_prim_list=construct_lag_array2d(df_cpc_prim, lag_step)
    
   
    # 74 idx
    #df_feature0=dcomp_seasonality(df_tmp_features, True)
    #df_feature0=df_feature0.dropna(axis=1, how='any')
    #df_feature0=df_feature0[df_feature0.index.year>=start_year]
    #X, col_list_X=construct_lag_array2d(df_feature0, lag_step)

    # 
    #X_features = np.concatenate((cpc_aao_lag, cpc_prim_lag,X),axis=1) # with 74 cir index
    #X_features = np.concatenate((cpc_aao_lag, cpc_prim_lag),axis=1) # without 74 cir index
    X_features = np.array(df_cpc_prim_lag) 
    col_list_X=cpc_prim_list
    #col_list_X.extend(cpc_prim_list)
    #col_list_X.extend(col_list_X)

    icount=0
    for idx, row in sta_df.iterrows():
        sta_num=str(int(row['区站号']))
        print(sta_num+' '+row['省份']+' '+row['站名'])
        
        # Read station-based feature
        df_era5=pd.read_csv(era5_lib_dir+sta_num+'.t2m.csv', index_col=0, parse_dates=True)
        df_era5=df_era5[(df_era5.index.year>=start_year) & (df_era5.index.year<=end_year)]

        lst_era5_lag, col_era5_lag=construct_lag_array1d(df_era5, lag_step, 'era5') 
        lst_era5_lag=np.squeeze(lst_era5_lag)
        
        df_giss=pd.read_csv(giss_lib_dir+sta_num+'.t2m.csv', index_col=0, parse_dates=True)
        df_giss=df_giss[(df_giss.index.year>=start_year) & (df_giss.index.year<=end_year)]
        lst_giss_lag, col_giss_lag=construct_lag_array1d(df_giss, lag_step, 'giss') 
        lst_giss_lag=np.squeeze(lst_giss_lag)
        
        X = np.concatenate((X_features, lst_era5_lag, lst_giss_lag),axis=1) # with 74 cir index
        col_list_X.extend(col_era5_lag)
        col_list_X.extend(col_giss_lag)
        
        # verify
        #print(len(col_list_X))
        #print(X_features.shape)



        # Read label
        df_lbl=pd.read_csv(label_dir+sta_num+'.txt',index_col=0, parse_dates=True)
        
        # Parser labels
        if df_lbl.index[0]>label_start_date:
            print(df_lbl.index[0].strftime('%Y-%m')+' start time beyond the least requirement!')
            continue
        
        df_lbl=df_lbl[(df_lbl.index >= label_start_date) & (df_lbl.index <= label_end_date)]
        df_lbl=dcomp_seasonality(df_lbl, False)
        Y = np.array(df_lbl['tave'].values)
        # predict label
        Y = Y[lag_step:]
        
        print('X size:', X.shape)
        print('Y size:', Y.shape)

        (n_samples, n_features)=X.shape
        
        if n_samples!= Y.shape[0]:
            continue

        X_train=X[:int(train_size*n_samples),:]
        X_test=X[int(train_size*n_samples):,:]

        Y_train=Y[:int(train_size*n_samples)]
        Y_test=Y[int(train_size*n_samples):]   
        
        # below for lassocv
        lassocv_model=LassoCV(cv=10,normalize=True,n_jobs=10,max_iter=10000).fit(X_train,Y_train)
        magic_alpha = lassocv_model.alpha_
        
        print('best alpha:', magic_alpha)
        # above for lassocv

        lasso_model=Lasso( alpha=magic_alpha, normalize=True,max_iter=10000)
        lasso_model.fit(X_train, Y_train)

        w=lasso_model.coef_
        b=lasso_model.intercept_
        features=np.where(w!=0)[0]

        # print result
        #print('w: ', w[w!=0])
        #print('w_idx: ', features)
        print('w_name: ', [col_list_X[itm] for itm in features])
        if len(features) == 0:
            continue
        #print('b: ', b)


        # -----------make predictions-----------------
        
        trainPredict = lasso_model.predict(X_train)
        testPredict = lasso_model.predict(X_test)
        
        direction_score=(sum((Y_test>0)*(testPredict>0))+sum((Y_test<0)*(testPredict<0)))/Y_test.shape[0]
        print('****sign direction score:', direction_score)
        result_dic[sta_num]={
            'best_alpha':           magic_alpha,
            'w':                    w[w!=0].tolist(),
            'w_idx':                features.tolist(),
            'w_name':               [col_list_X[itm] for itm in features],
            'b':                    b,
            'sign_score':           direction_score
            }
            
        print(result_dic[sta_num])
        icount=icount+1
        if icount%50 == 0:
            with open('../result/china_result'+str(icount)+'.json', 'w') as f:
                json.dump(result_dic,f)

if __name__ == "__main__":
    main()



