#! /usr/bin/env python
#  Deal with 59287 station data 
#   
#               L_Zealot
#               Jul 17, 2019
#               Guangzhou, GD
#

import math
import os
import numpy as np
import pandas as pd
import datetime

import matplotlib
matplotlib.use('Agg') 
import matplotlib.pylab as plt
from matplotlib.pyplot import savefig

from keras.models import Sequential
from keras.layers import Dense
from keras.layers import LSTM
from sklearn.preprocessing import MinMaxScaler
from sklearn.metrics import mean_squared_error

#-------------------------------------
# Function Definition Part
#-------------------------------------
def main():

#----------------------------------------------------
# User Defined Part
#----------------------------------------------------

    # Station Number
    sta_num='59287'

    # Input File
    in_dir='/home/lzhenn/array2/lzhenn/station/post/'

    # Start Year 
    start_year=2011
    
    # End Year
    end_year=2018

    # Var Name 
    var_name='TEM' 

#----------------------------------------------------
# Main function
#----------------------------------------------------
    
    pt=pd.read_csv(in_dir+sta_num+var_name+'.txt', sep='\s+', header=None, names=['station', 'lat', 'lon', 'alt', 'year', 'mon', 'day', 'avg_temp', 'max_temp', 'min_temp', 'avg_code', 'max_code', 'min_code'])
    sample_pt=pt[pt.year >= start_year]
    df0=reform_df(sample_pt)
    df0, df0_season= dcomp_seasonality(df0)
    print(df0_season.loc[731])
    print(df0)

    # normalize the dataset
    scaler = MinMaxScaler(feature_range=(0, 1))
    dataset = scaler.fit_transform(dataset)


    # split into train and test sets
    train_size = int(len(dataset) * 0.67)
    test_size = len(dataset) - train_size
    train, test = dataset[0:train_size,:], dataset[train_size:len(dataset),:]  

    plt.plot(df0['avg_temp'])
    plt.show()
    savefig('../fig/test.png')
    
    exit()

def reform_df(pt):
    start_time=str(pt.iloc[0]['year'])+'-'+str(pt.iloc[0]['mon'])+'-'+str(pt.iloc[0]['day'])
    end_time=str(pt.iloc[-1]['year'])+'-'+str(pt.iloc[-1]['mon'])+'-'+str(pt.iloc[-1]['day'])
    date_range = pd.date_range(start=start_time, end=end_time)
    series=pd.Series(pt['mon'].values*100+pt['day'].values, name='aux', index=pt.index)
    pt=pd.concat([pt, series], axis=1)
    df =pd.DataFrame(pt.loc[:,['avg_temp', 'max_temp', 'min_temp', 'aux']].values, index=date_range, columns=['avg_temp', 'max_temp', 'min_temp', 'aux'])
    return df

def dcomp_seasonality(df):
    df_season=df.groupby('aux').mean()
    df = df.groupby('aux').transform(lambda x: x-x.mean())
    return df, df_season

# X is the number of passengers at a given time (t) and Y is the number of passengers at the next time (t + 1).

# convert an array of values into a dataset matrix
def create_dataset(dataset, look_back=1):
    dataX, dataY = [], []
    for i in range(len(dataset)-look_back-1):
        a = dataset[i:(i+look_back), 0]
        dataX.append(a)
        dataY.append(dataset[i + look_back, 0])
    return numpy.array(dataX), numpy.array(dataY)

# fix random seed for reproducibility
numpy.random.seed(7)




if __name__ == "__main__":
    main()




