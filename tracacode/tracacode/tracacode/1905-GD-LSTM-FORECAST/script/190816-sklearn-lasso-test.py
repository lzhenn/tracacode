#! /usr/bin/env python
#   Try sklearn lasso model 
#   
#               L_Zealot
#               Aug 16, 2019
#               Guangzhou, GD
#
import matplotlib
matplotlib.use('Agg') 
import matplotlib.pyplot as plt
from matplotlib.pyplot import savefig

import numpy as np
import pandas as pd
from sklearn.linear_model import LassoCV, Lasso


#----------------------------------------------------
# User Defined Part
#----------------------------------------------------
def main():
    # Station Number
    sta_num='59287'

    # Input File
    in_dir='../testdata/'

    # Output File
    out_dir='../testdata/label.csv'

    # Year Break Points 
    start_years=[1957, 1996, 2011, 9999]

    # End Year
    end_year=2016


    train_size=0.8
    lag_step=12


    # magic_alpha from lassoCV results
    #magic_alpha=0.802779265085
    #magic_alpha=1.0
    #magic_alpha=1.07682989906 train_data

    df_tmp_features     =   pd.read_csv(in_dir+'possible_features.csv',index_col='time',parse_dates=True)
    df_label            =   pd.read_csv(in_dir+'label.csv',index_col='time')
        
    df_nino             =   load_nino34_data('/home/lzhenn/array2/lzhenn/osci_idx/detrend.nino34.ascii', start_years[0], end_year)
    nino_lag, col_nino_list=construct_lag_array1d(df_nino, lag_step, 'nino34')
    
    print(len(col_nino_list))
    print(nino_lag.shape)

    #df_feature0=pd.DataFrame()
    #ii = 0
    # concat anomalies based on breaking points in the station record ? need it?
    #for break_p in start_years[:-1]:
    #    ii = ii+1
    #    df_sample=df_tmp_features[df_tmp_features.index.year>=break_p]
    #    df_sample=df_sample[df_sample.index.year<start_years[ii]]
    #    df_feature0=pd.concat([df_feature0, dcomp_seasonality(df_sample)])
    
    df_feature0=dcomp_seasonality(df_tmp_features, True)
    df_feature0=df_feature0.dropna(axis=1, how='any')
    df_feature0=df_feature0[df_feature0.index.year>=start_years[0]]
    X0= np.array(df_feature0.values) 
    X, col_list_X=construct_lag_array2d(df_feature0, lag_step)
    print(len(col_list_X))
    print(X.shape)

    df_tmp_label=pd.read_csv(in_dir+'label.csv', index_col='time', parse_dates=True)
    Y = np.array(df_tmp_label['avg_temp'].values)
    Y_lag, col_list_lagY=construct_lag_array1d(df_tmp_label['avg_temp'], lag_step, 'Y') 
    print(len(col_list_lagY))
    print(Y_lag.shape)

    
    X = np.concatenate((X, nino_lag,Y_lag),axis=1)
    col_list_X.extend(col_nino_list)
    col_list_X.extend(col_list_lagY)
    print(len(col_list_X))
    print(X.shape)
    Y = Y[lag_step:]
    
    (n_samples, n_features)=X.shape
    X_train=X[:int(train_size*n_samples),:]
    X_test=X[int(train_size*n_samples):,:]

    Y_train=Y[:int(train_size*n_samples)]
    Y_test=Y[int(train_size*n_samples):]   
    
    # below for lassocv
    lassocv_model=LassoCV(cv=10).fit(X_train,Y_train)
    magic_alpha = lassocv_model.alpha_
    print('best alpha:', magic_alpha)
    # above for lassocv

    lasso_model=Lasso( alpha=magic_alpha)
    lasso_model.fit(X_train, Y_train)

    w=lasso_model.coef_
    b=lasso_model.intercept_
    features=np.where(w>0)[0]
    print('w: ', w[w>0])
    for itm in features:
        print(itm)
        print(str(round(w[itm],4))+'x'+col_list_X[int(itm)])
    print('b: ', b)

# make predictions
    trainPredict = lasso_model.predict(X_train)
    testPredict = lasso_model.predict(X_test)
    
    direction_score=(sum((Y_test>0)*(testPredict>0))+sum((Y_test<0)*(testPredict<0)))/Y_test.shape[0]
    print(direction_score)

    plt.figure(figsize=(12, 8))
    plt.plot(Y_test, label='value', color='blue')
    plt.plot(testPredict, label='fit_value', color='red')
    plt.legend(loc='best')
    plt.show()
    savefig('../fig/lasso_test.png')

def load_nino34_data(path_nino34, yr_start, yr_end):
    df_nino_raw=pd.read_csv(path_nino34, sep='\s+')
    df_nino = df_nino_raw[df_nino_raw['YR']>=yr_start]
    df_nino = df_nino[df_nino['YR']<=yr_end]
    df_nino = df_nino['ANOM']
    return df_nino

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
    """
    org_col_list=list(array_name)
    col_list=[array_name+'_lag1']
    
    X_all = np.array(df.values)
    X=X_all[:-lag_step]
    X=X[:,np.newaxis]
    for ii in range(1, lag_step):
        X_tmp=X_all[ii:(-lag_step+ii)]
        X_tmp=X_tmp[:,np.newaxis]
        X=np.concatenate((X,X_tmp),axis=1)
        new_list=[array_name+'_lag'+str(ii+1)]
        col_list.extend(new_list)
    return X, col_list


def dcomp_seasonality(df, std_flag):
    df_season = df.groupby(df.index.month).mean() # climatological seasonal cycle
    df = df.groupby(df.index.month).transform(lambda x: (x-x.mean())/x.std()) # calculate monthly anomaly
    return df


if __name__ == "__main__":
    main()



