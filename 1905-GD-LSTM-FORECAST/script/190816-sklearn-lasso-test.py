#! /usr/bin/env python
#   Try sklearn lasso model 
#   
#               L_Zealot
#               Aug 16, 2019
#               Guangzhou, GD
#
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.linear_model import MultiTaskLasso, Lasso


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
    end_year=2018


    # N features used in the lasso model
    n_relavant_features=25


    df_tmp_features=pd.read_csv(in_dir+'possible_features.csv',index_col='time',parse_dates=True)
    df_label=pd.read_csv(in_dir+'label.csv',index_col='time')
    
    df_feature=pd.DataFrame()
    ii = 0
    for break_p in start_years[:-1]:
        ii = ii+1
        df_sample=df_tmp_features[df_tmp_features.index.year>=break_p]
        df_sample=df_sample[df_sample.index.year<start_years[ii]]
        df_feature=pd.concat([df_feature, dcomp_seasonality(df_sample)])
    df_feature=df_feature.dropna(axis=1, how='any')
    X = np.array(df_feature.values)
    df_tmp_label=pd.read_csv(in_dir+'label.csv', index_col='time', parse_dates=True)
    Y = np.array(df_tmp_label['avg_temp'].values)
    print(Y)
    coef_lasso_ = np.array([Lasso(alpha=0.5).fit(X, Y).coef_])
    print(coef_lasso_)
def dcomp_seasonality(df):
    df_season = df.groupby(df.index.month).mean() # climatological seasonal cycle
    df = df.groupby(df.index.month).transform(lambda x: x-x.mean()) # calculate monthly anomaly
    return df


if __name__ == "__main__":
    main()



