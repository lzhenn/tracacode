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
        #if not (row['省份'] in province): #or (sta_num != tgt_sta_num):
        #    continue
        if sta_num in result_dic:
            icount=icount+1
            print(sta_num+' done, pass.')
            continue

        # Read station-based feature
       
        df_prec=pd.read_csv(prec_lib_dir+sta_num+'.prec.csv', index_col=0, parse_dates=True)
        df_prec=df_prec[(df_prec.index.year>=start_year) & (df_prec.index.year<=end_year)]
        lst_prec_lag, col_prec_lag=construct_lag_array1d(df_prec, lag_step, 'prec') 
        lst_prec_lag=np.squeeze(lst_prec_lag)
        
        X = np.concatenate((X_features, lst_prec_lag),axis=1) # with 74 cir index
        col_list_X.extend(col_prec_lag)
        
        # verify
        #print(len(col_list_X))
        #print(X_features.shape)

        # Read label
        #df_lbl=pd.read_csv(label_dir+sta_num+'.txt',index_col=0, parse_dates=True)
        
        mon_sta_df=pd.read_csv(label_dir+'SURF_CLI_CHN_PRE_MUT_HOMO-MON-'+sta_num+'.txt', sep='\s+', header=None, names=['year', 'month', 'day', 'prec'])
        mon_sta_df.loc[:,'day']=1 # uniform style

        date_range=pd.to_datetime(mon_sta_df.loc[:,['year','month', 'day']])
        mon_sta_df =pd.DataFrame(mon_sta_df.loc[:,'prec'].values, index=date_range, columns=['prec'])
        mon_sta_df.index.set_names('time', inplace=True)
        mon_sta_df=mon_sta_df.replace(-999.0,np.nan)  
        #mon_sta_df=mon_sta_df.to_period() # yyyy-mm-dd to yyyy-mm
        df_lbl=mon_sta_df.dropna()

        # Parser labels
        if df_lbl.index[0]>label_start_date:
            print(df_lbl.index[0].strftime('%Y-%m')+' start time beyond the least requirement!')
            continue
        
        df_lbl=df_lbl[(df_lbl.index >= label_start_date) & (df_lbl.index <= label_end_date)]
        df_lbl=dcomp_seasonality(df_lbl, False)
        
        Y = np.array(df_lbl['prec'].values)
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
#        lassocv_model=LassoCV(cv=10,normalize=True,n_jobs=10,max_iter=10000).fit(X_train,Y_train)
        lassocv_model=LassoCV(cv=10,normalize=True,n_jobs=10,max_iter=10000).fit(X,Y)
        magic_alpha = lassocv_model.alpha_
        
        print('best alpha:', magic_alpha)
        # above for lassocv

        lasso_model=Lasso( alpha=magic_alpha, normalize=True,max_iter=10000)
        lasso_model.fit(X, Y)

        joblib.dump(lasso_model, model_out_dir+sta_num+'.pr.fullXY.model')

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
        
#        trainPredict = lasso_model.predict(X_train)
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
    # end for

    with open('../result/whole_china_prec_full_XY_result.json', 'w') as f:
        json.dump(result_dic,f)

if __name__ == "__main__":
    main()



